//
//  ParticleMeshGenerator+Trail.swift
//  ParticleSimulatorApp
//
//  Created by DY on 13/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import RealityKit
import Metal

extension ParticleMeshGenerator {

    /// Compute pipeline corresponding to the Metal compute kernel `particleBrushPopulate`.
    ///
    /// See `particleBrushSimulation.metal`.
    private static let trailPopulatePipeline: MTLComputePipelineState? = makeComputePipeline(named: AppConstants.Sim.trailPipelineName)

    
    /// A minimal unlit, alpha-blended material for the trail lines. Vertex color (including the alpha we
    /// write per-vertex in `geoMagneticTrailPopulate`) drives both color and fade, so nothing else needs
    /// to be configured here. Swap this out for a `ShaderGraphMaterial` if you want a glow/bloom look.
    @MainActor
    static func makeTrailMaterial() -> Material {
        var material = UnlitMaterial(color: .white)
        material.blending = .transparent(opacity: .init(floatLiteral: 1.0))
        material.faceCulling = .none
        return material
    }
    
    /// Creates a trail low level mesh suitable for this mesh generator to render.
    ///
    /// - Parameters:
    ///   - particleCapacity: The number of particles the `LowLevelMesh` is to support.
    @MainActor
    static func makeTrailLowLevelMesh(particleCapacity: Int) throws -> LowLevelMesh {
        let trailLength = Int(MAX_TRAIL_LENGTH)
        let segmentsPerParticle = trailLength - 1
        var descriptor = LowLevelMesh.Descriptor()

        descriptor.vertexCapacity = trailLength * particleCapacity
        descriptor.indexCapacity = 2 * segmentsPerParticle * particleCapacity
        descriptor.vertexAttributes = ParticleTrailVertex.vertexAttributes

        let stride = MemoryLayout<ParticleTrailVertex>.stride
        descriptor.vertexLayouts = [.init(bufferIndex: 0, bufferStride: stride)]

        let mesh = try LowLevelMesh(descriptor: descriptor)

        // The bounding box is used to occlude parts of your mesh when it isn't seen.
        // The drawing app should display all brush strokes, so use an arbitrarily large bounds.
        let bounds = BoundingBox(min: AppConstants.Sim.MeshBounds.lower, max: AppConstants.Sim.MeshBounds.upper)
        mesh.parts.append(LowLevelMesh.Part(indexOffset: 0, indexCount: 0,
                                            topology: .line, materialIndex: 0,
                                            bounds: bounds))

        mesh.withUnsafeMutableIndices { buffer in
            let typedBuffer = buffer.bindMemory(to: UInt32.self)
            
           // For each particle, wire up `segmentsPerParticle` independent 2-index line segments
           // (vertex i -> vertex i+1) within that particle's own block of `trailLength` vertices.
            for particleIndex in 0..<particleCapacity {
                let vertexBase = UInt32(particleIndex * trailLength)
                let indexBase = particleIndex * segmentsPerParticle * 2
                for segment in 0..<segmentsPerParticle {
                    typedBuffer[indexBase + segment * 2] = vertexBase + UInt32(segment)
                    typedBuffer[indexBase + segment * 2 + 1] = vertexBase + UInt32(segment) + 1
                }
            }
        }
        return mesh
    }
    
    /// Populates the `TrailLowLevelMesh` vertex buffer with `particle.trailPositions`
    ///
    /// - Parameters:
    ///   - input: The particle simulation buffer, which determines particle positions.
    ///   - output: The `LowLevelMesh` to write to.
    ///   - particleCount: The number of particles active in `input`.
    ///   - commandBuffer: The Metal command buffer to use.
    ///   - encoder: The Metal compute command encoder to use.
    @MainActor
    static func populateTrails(input: MTLBuffer,
                         output: LowLevelMesh,
                         particleCount: Int,
                         commandBuffer: MTLCommandBuffer,
                         encoder: MTLComputeCommandEncoder) throws {
        precondition(particleCount > 0)
        
        guard let trailPopulatePipeline = Self.trailPopulatePipeline else {
            throw particleBrushGenerationError.unableToCreateComputePipeline
        }
        
        let particleStride = MemoryLayout<ParticleAttributes>.stride
        precondition(input.length >= particleCount * particleStride)
        
        let trailLength = Int(MAX_TRAIL_LENGTH)
        precondition(output.descriptor.vertexCapacity >= trailLength * particleCount)
        
        let groupSize = trailPopulatePipeline.maxTotalThreadsPerThreadgroup
        encoder.setComputePipelineState(trailPopulatePipeline)
        
        encoder.setBuffer(input, offset: 0, index: 0)
        
        let vertexBuffer = output.replace(bufferIndex: 0, using: commandBuffer)
        encoder.setBuffer(vertexBuffer, offset: 0, index: 1)
        
        var particleCountUInt = UInt32(particleCount)
        encoder.setBytes(&particleCountUInt, length: MemoryLayout<UInt32>.size, index: 2)
        
        let numGroups = (particleCount + groupSize - 1) / groupSize
        encoder.dispatchThreadgroups(MTLSizeMake(numGroups, 1, 1),
                                     threadsPerThreadgroup: MTLSizeMake(groupSize, 1, 1))
        
        output.parts[0].indexCount = 2 * (trailLength - 1) * particleCount
    }

}
