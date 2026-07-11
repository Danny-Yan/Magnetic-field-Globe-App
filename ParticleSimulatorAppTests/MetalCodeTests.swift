//
//  ParticleSimulatorAppTests.swift
//  ParticleSimulatorAppTests
//
//  Created by DY on 27/6/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Collections
import Foundation
import RealityKit
import RealityKitContent
import SwiftUI
import Testing

@testable import ParticleSimulatorApp

struct MetalCodeTests {
    
    var coefficientBuffers: CoefficientBuffers
    var magneticModelBuffer: MTLBuffer
    let magneticModelPointer: UnsafeMutablePointer<MagneticFieldModel>
    var computeEncoder: MTLComputeCommandEncoder
    var commandBuffer: MTLCommandBuffer

    //    private var testParticleGen: ParticleMeshGenerator
    init() async throws {
        AppConstants.Spawn.maxSpawnCount = 1
        AppConstants.Spawn.minSpawnCount = 1

        AppConstants.Spawn.centre = [-0.5, 1.5, -1]
        AppConstants.Spawn.radius = 0  // Remove Randomness from sphere position

        AppConstants.Particle.initialSpeed = 0
        AppConstants.Particle.size = 0.3

        AppConstants.Earth.showEarth = false
        AppConstants.Sim.skipSplashScreen = true
        AppConstants.Sim.showSim = true
        
        /// The GPU command queue to store incoming GPU commands
        let commandQueue: MTLCommandQueue? = {
            if let metalDevice, let queue = metalDevice.makeCommandQueue() {
                queue.label = "particle Brush Command Queue"
                return queue
            } else {
                return nil
            }
        }()

        (coefficientBuffers, magneticModelBuffer) =
            ParticleMeshGenerator.createModelBuffers(
                modelCoefficients: AppConstants.modelCoefficients.igrf,
                metalDevice: metalDevice
            )
        
        magneticModelPointer = createSingleTypeBufPointer(buf: &magneticModelBuffer, of: MagneticFieldModel.self)

        guard let commandBuf = commandQueue?.makeCommandBuffer(),
              let compute = commandBuf.makeComputeCommandEncoder()
        else {
            fatalError("Command buffer failed to initalise")
        }
        
        computeEncoder = compute
        commandBuffer = commandBuf
        
        commandBuffer.enqueue()

        try? ParticleMeshGenerator.initialiseMagneticModelClass(
            coefficientBuffers: coefficientBuffers,
            outputModel: magneticModelBuffer,
            encoder: computeEncoder
        )

        computeEncoder.endEncoding()
        commandBuffer.commit()
        await commandBuffer.completed()


        // Create Material
        //        let particleMaterial = await ParticleSystemEntity.instantiateParticleMaterial()
        //        let material: RealityKit.Material = particleMaterial ?? SimpleMaterial()

        //        let rootEntity = Entity()
        //        testParticleGen = ParticleMeshGenerator(rootEntity: rootEntity,
        //                                                    material: material,
        //                                                    modelCoefficientString: AppConstants.modelCoefficients.igrf)
    }

    //    @Test @MainActor func testGeomagneticFieldSimulation() async throws {
    //        // Add particle point to sim
    //        let particlePoint = ParticlePoint(position: AppConstants.Spawn.centre,
    //                                          initialSpeed: AppConstants.Particle.initialSpeed,
    //                                          size: AppConstants.Particle.size,
    //                                          color: AppConstants.Particle.color)
    //
    //        testParticleGen.traceSingular(point: particlePoint)
    //
    //        // Drive the simulation. Each call enqueues GPU work asynchronously, so we wait for the
    //        // most recently-submitted command buffer to finish before issuing the next one and before
    //        // reading results back - otherwise the readback below races the GPU.
    //        for _ in 0...1 {
    //            try testParticleGen.update(deltaTime: 0.1) { _ in }
    //            testParticleGen.waitUntilSimulationComplete()
    //        }
    //
    //        // Direct pointer access to the particleBuffer struct.
    //        // `simulationBuffer` now uses `.storageModeShared`, so `.contents()` is safe to read from the CPU.
    //        // Bind directly to `ParticleAttributes` (the buffer's actual element type) - binding to
    //        // `[ParticleAttributes]` (a Swift Array) was reinterpreting raw GPU bytes as if they were an
    //        // Array's internal object representation, which is meaningless.
    //        guard let simulationBuffer = testParticleGen.simulationBuffer else {
    //            Issue.record("simulationBuffer was nil after update")
    //            return
    //        }
    //        let count = testParticleGen.particleCapacity
    //        let particlesPtr = simulationBuffer.contents().bindMemory(to: ParticleAttributes.self, capacity: count)
    //        let bufferPtr = UnsafeBufferPointer(start: particlesPtr, count: count)
    //        let particles = Array(bufferPtr)
    //
    //        let numberOfParticles = particles.count
    //        /// Show number of particles
    //        print("number of particles: \(numberOfParticles)")
    //
    //        // Test First particle
    //        let particle = particles[0]
    //        let magField = particle.attributes.magField
    //
    //        /* Magnetic Components */
    //        let magComp = magField.components
    //        let magCompArray = [magComp.x, magComp.y, magComp.z]
    //        /// Show component array
    //        print("magComponents: \(magCompArray)")
    //
    //        /* Position */
    //        let position = particle.attributes.position
    //        let positionArray = [position.x, position.y, position.z]
    //        /// Show particle position
    //        print("Position: \(positionArray)")
    //
    //
    //        /* Polar position */
    //        let polarPos = particle.attributes.polarCoordinate
    //        let polarPosArray = [polarPos.x, polarPos.y, polarPos.z]
    //        /// Show polar particle position
    //        print("Polar Position: \(polarPosArray)")
    //
    //
    //        /* Test position */
    //        let testPositionArray = [AppConstants.Spawn.centre.x, AppConstants.Spawn.centre.y, AppConstants.Spawn.centre.z]
    //        #expect(positionArray == testPositionArray)
    //    }

    @Test mutating func testGeomagneticFieldMetalFunction() async throws {
        
        let testPolarCoord = SIMD3<Float>(7000,0.453,0.36786)
        let testDateTime: Date = try createDateFromDMY(day: 10, month: 12, year: 2020)
        let yearFraction = createYearFractionFromDate(date: testDateTime)
        
        print("YearFraction: \(yearFraction)")
        
        let (outputBuffer, outputPointer) =  try await createBufferAndPointer(metalDevice: metalDevice, of: MagneticField.self)
        let (localVariableBuffer, localVariablePointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: MagneticFieldPerParticleVariables.self)
        
        localVariablePointer.pointee.snorm = magneticModelPointer.pointee.snorm
        
        try? testMagneticModelPipeline(polarCoord: testPolarCoord, yearFraction: yearFraction, outputResult: outputBuffer, localVariableBuffer: localVariableBuffer)
       
        // Parse output and test
        let components = outputPointer.pointee.components
        let componentsArray = [components.x, components.y, components.z]
        let testResult: [Float] = [2, 3, 4]
        
        // Print Out Info
        let model: MagneticFieldModel = magneticModelPointer.pointee
        printClassEntries(headline: "Magnetic Model", for: model)
        printClassEntries(headline: "Local Variables", for: localVariablePointer.pointee)
        printClassEntries(headline: "Ouput Field", for: outputPointer.pointee)

        #expect(componentsArray == testResult)
    }
    
    // GPU function to call test magnetic field calc function
    private func testMagneticModelPipeline(
        polarCoord: SIMD3<Float>,
        yearFraction: Float,
        outputResult: MTLBuffer,
        localVariableBuffer: MTLBuffer
    ) throws {
        let encoder: MTLComputeCommandEncoder = computeEncoder
        guard
            let testingPipeline =
                makeComputePipeline(
                    named: "testCalculateMagneticField"
                )
        else {
            Issue.record("Test pipeline failed to initlaise")
            return
        }
        
        encoder.setComputePipelineState(testingPipeline)
        
        withUnsafePointer(to: polarCoord) {coord in
            encoder.setBytes(coord, length: MemoryLayout<SIMD3<Float>>.size,  index: 0)
        }
        withUnsafePointer(to: yearFraction) { yearFrac in
            encoder.setBytes(yearFrac, length: MemoryLayout<Float>.size,  index: 1)
        }
        
        encoder.setBuffer(magneticModelBuffer, offset: 0,  index: 2)
        encoder.setBuffer(localVariableBuffer, offset: 0, index: 3)
        encoder.setBuffer(outputResult, offset: 0, index: 4)

        //       Dispatch on a single thread
        encoder.dispatchThreadgroups(
            MTLSizeMake(1, 1, 1),
            threadsPerThreadgroup: MTLSizeMake(1, 1, 1)
        )
    }

}
