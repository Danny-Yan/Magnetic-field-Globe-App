/*
 ParticleMeshGenerator.swift

 Abstract:
 A class that manages the generation of meshes for the particle brush, using `LowLevelMesh` and a GPU particle simulation.

 Created by: Danny Yan
 */

import Collections
import Foundation
import Metal
import RealityKit


import SwiftUI
import RealityKitContent

import MetalKit
import os

final class ParticleMeshGenerator {

    @Binding var settings: ParticleSystemSettings
    
    /// The GPU command queue to store incoming GPU commands
    private static let commandQueue: MTLCommandQueue? = {
        if let metalDevice, let queue = metalDevice.makeCommandQueue() {
            queue.label = "particle Brush Command Queue"
            return queue
        } else {
            return nil
        }
    }()
    /// Struct of all model coefficients as metal buffers
    internal var coefficientBuffers: CoefficientBuffers
    
    /// Buffer containing the magnetic model
    internal var magneticModelBuffer: MTLBuffer
    // Direct pointer access to the magneticModel struct
    var modelPointer: UnsafeMutablePointer<MagneticFieldModel> {
        magneticModelBuffer.contents().bindMemory(
            to: MagneticFieldModel.self,
            capacity: 1
        )
    }

    /// The `LowLevelMesh` currently being written to.  Contains capacity for `particleCapacity` particles.
    private var lowLevelMesh: LowLevelMesh?
    
    /// The `TrailLowLevelMesh` currently being written to.  Contains capacity for `MAX_TRAIL_LENGTH` particles.
    private var trailLowLevelMesh: LowLevelMesh?

    /// The particle simulation buffer.  Contains capacity for `particleCapacity` articles.
    internal var simulationBuffer: MTLBuffer?

    /// The number of particles supported by `lowLevelMesh` and `simulationBuffer` without reallocation.
    internal var particleCapacity: Int = 0

    /// The number of initialized particles in `lowLevelMesh` and `simulationBuffer`.
    /// Must be less than or equal to `particleCapacity`.
    private var particleCount: Int = 0

    /// The entity which is populated by this mesh generator.
    private var rootEntity: Entity

    /// List of particles that must spawn into the scene when calling `populate`.
    private var particlesToSpawn: ContiguousArray<ParticleAttributes> = []

    /// If there is an active stroke, contains the most recently-traced point.  Else, contains `nil`.
    private var lastTracedPoint: ParticleSystemPoint?

    /// True if a command buffer is currently in flight.  Concurrent updates aren't permitted due to contention
    /// over `lowLevelMesh` and `simulationBuffer`.
    private var isMeshUpdateInFlight: Bool = false

    /// True if there is an active stroke.
    var isDrawing: Bool { lastTracedPoint != nil }

    /// Log command buffer to wait for it externally
    internal private(set) var lastCommandBuffer: MTLCommandBuffer?
    internal func waitUntilSimulationComplete() {
        lastCommandBuffer?.waitUntilCompleted()
    }

    /// Errors that could occur during mesh generation.
    enum particleBrushGenerationError: Error {
        /// Unable to create the metal compute pipeline.
        case unableToCreateComputePipeline

        /// Unable to create the metal compute command encoder.
        case unableToCreateComputeEncoder

        /// Unable to create the simulation buffer.
        case unableToCreateBuffer
    }
    
    static var southPoleCentre: SIMD3<Float> = AppConstants.Spawn.centre * 2 + SIMD3<Float>(0, 0, 0)


    @MainActor
    init(
        rootEntity: Entity,
        withSettings: Binding<ParticleSystemSettings>
    ) async {
        self._settings = withSettings
        self.rootEntity = rootEntity

        (self.coefficientBuffers, self.magneticModelBuffer) =
            Self.createModelBuffers(
                chosenModel: withSettings.wrappedValue.sChosenVersion,
                metalDevice: metalDevice
            )
        // Sets ParticleComponent as its new root
        rootEntity.position = .zero
        
        let trailEntity = Entity()
        trailEntity.name = "Particle Trails"
        rootEntity.addChild(trailEntity)
        
        let particleComponent = ParticleComponent(
            generator: self,
            material: await Self.makeParticleMaterial() ?? SimpleMaterial(),
            trailEntity: trailEntity,
            trailMaterial: await Self.makeTrailMaterial() ?? SimpleMaterial()
        )
        rootEntity.components.set(particleComponent)

        try? initModelClass()
    }

    /// Called to  initialise magnetic model class with the parsed coefficients
    @MainActor
    func initModelClass() throws {
        // Create a Metal command buffer and compute command encoder to execute GPU work.
        guard let commandBuffer = Self.commandQueue?.makeCommandBuffer(),
            let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw particleBrushGenerationError.unableToCreateComputeEncoder
        }
        commandBuffer.enqueue()

        // Initialise Magnetic Model Class
        try Self.initialiseMagneticModelClass(
            coefficientBuffers: self.coefficientBuffers,
            outputModel: self.magneticModelBuffer,
            encoder: computeEncoder
        )

        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        print("WGS84_A: \(self.modelPointer.pointee.WGS84_A)")
        print("WGS84_B: \(self.modelPointer.pointee.WGS84_B)")
    }

    /// Spawns particles until max spawn count is reached
    func traceSingular(point centre: ParticleSystemPoint) {
        // Spawn particles
        while particlesToSpawn.count < $settings.wrappedValue.sNumberOfParticles {
            spawnParticle(at: centre)
        }
    }

    /// Spawns a single particle with at a random positon around a centre point
    private func spawnParticle(at point: ParticleSystemPoint) {
        guard particlesToSpawn.count < $settings.wrappedValue.sNumberOfParticles else {
            return
        }
        
        // Generate random position within a sphere
        let randPosition: SIMD3<Float> =
            AppConstants.Spawn.radius * randomUniformDistribute()
            + point.centre
    
        // initialise particle and add it to the spawn queue
        let particleAttributes = point.convertToMetalStruct(spawnPosition: randPosition)
        particlesToSpawn.append( particleAttributes )
    }

    /// Reallocates `lowLevelMesh` and `simulationBuffer` to a capacity of at least `newParticleCount`.
    @MainActor
    private func reallocateBuffers(newParticleCount: Int) throws {
        guard newParticleCount > particleCapacity else {
            // This particle count is already supported by the current `LowLevelMesh`.
            return
        }

        // Double the particle capacity until it exceeds `newParticleCount`, or set to a minimum capacity of 1024.
        var newParticleCapacity = max(
            AppConstants.Spawn.minSpawnCount,
            particleCapacity
        )
        while newParticleCapacity < newParticleCount {
            newParticleCapacity *= 2
        }

        // Allocate a new simulation buffer with room for `newParticleCapacity` particles.
        let simBufferLength =
            newParticleCapacity * MemoryLayout<ParticleAttributes>.stride
        guard let metalDevice = metalDevice,
            let newBuffer = metalDevice.makeBuffer(
                length: simBufferLength,
                options: .storageModeShared
            )
        else {
            throw particleBrushGenerationError.unableToCreateBuffer
        }

        // Allocate a new `LowLevelMesh` with room for `newParticleCapacity` particles.
        lowLevelMesh = try Self.makeLowLevelMesh(
            particleCapacity: newParticleCapacity,
            particleCount: particleCount
        )
        
        // Allocate a new `TrailLowLevelMesh` with room for `newParticleCapacity` particles.
        trailLowLevelMesh = try Self.makeTrailLowLevelMesh(
            particleCapacity: newParticleCapacity,
            particleCount: particleCount
        )
        
        simulationBuffer = newBuffer
        particleCapacity = newParticleCapacity
    }

    @MainActor
    func update(
        deltaTime: Float,
        _ onCreatedNewMesh: @escaping @MainActor (_ particleMesh: LowLevelMesh, _ trailMesh: LowLevelMesh) async -> Void
    ) throws {
        let oldBuffer = simulationBuffer

        // Halt if a mesh update is already in flight. Need to wait for a command buffer from a previous frame.
        guard !isMeshUpdateInFlight else { return }

        // If there are no particles, and none have been queued for spawning, there is nothing to do.
        guard particleCount > 0 || !particlesToSpawn.isEmpty else { return }

        // Buffers need to be reallocated when the number of particles exceeds the current `particleCapacity`.
        let didReallocate: Bool =
            particleCount + particlesToSpawn.count > particleCapacity
        if didReallocate {
            let newParticleCount = particleCount + particlesToSpawn.count
            try reallocateBuffers(newParticleCount: newParticleCount)
        }

        // Create a Metal command buffer and compute command encoder to execute GPU work.
        guard let commandBuffer = Self.commandQueue?.makeCommandBuffer(),
            let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw particleBrushGenerationError.unableToCreateComputeEncoder
        }

        // When the Metal command buffer completes, mark the update as no-longer in flight.
        // If a new `LowLevelMesh` was created, notify the caller.
        commandBuffer.addCompletedHandler { [self] commandBuffer in
            Task(priority: .high) { @MainActor in
                if didReallocate {
                    await onCreatedNewMesh(lowLevelMesh!, trailLowLevelMesh!)  // THIS IS WHERE THE APP PLACES THE LOW LEVEL MESH
                }

                precondition(isMeshUpdateInFlight)
                isMeshUpdateInFlight = false
            }
        }

        isMeshUpdateInFlight = true
        lastCommandBuffer = commandBuffer
        commandBuffer.enqueue()

        defer {
            computeEncoder.endEncoding()
            commandBuffer.commit()
        }

        // Simulate the particles that already exist in the simulation buffer.
        if particleCount > 0, let oldBuffer {
            
            let parameters = settings.convertToMetalStruct(
                particleCount: particleCount,
                deltaTime: deltaTime,
                southPoleCentre: Self.southPoleCentre
            )
            
            try Self.simulate(
                input: oldBuffer,
                output: simulationBuffer!,
                particleCount: particleCount,
                parameters: parameters,
                modelBuffer: magneticModelBuffer,
                encoder: computeEncoder
            )
        }

        // Add any new particles to the simulation.
        if !particlesToSpawn.isEmpty {
            try particlesToSpawn.withUnsafeBufferPointer { bufferPointer in
                try addParticlesToSimulation(
                    input: bufferPointer,
                    output: simulationBuffer!,
                    particleOffsetInOutput: particleCount,
                    encoder: computeEncoder,
                    modelBuffer: magneticModelBuffer
                )
            }
            particleCount += particlesToSpawn.count
            particlesToSpawn.removeAll()
        }

        // Populate the particle `LowLevelMesh` with the result of the particle simulation.
        try Self.populate(
            input: simulationBuffer!,
            output: lowLevelMesh!,
            particleCount: particleCount,
            commandBuffer: commandBuffer,
            encoder: computeEncoder
        )
        
        // Populate the trail `LowLevelMesh` from the same post-simulation buffer, so each particle's
        // trail always reflects the position it was just simulated to this frame.
        try Self.populateTrails(
            input: simulationBuffer!,
            output: trailLowLevelMesh!,
            particleCount: particleCount,
            commandBuffer: commandBuffer,
            encoder: computeEncoder
        )
    }
}
