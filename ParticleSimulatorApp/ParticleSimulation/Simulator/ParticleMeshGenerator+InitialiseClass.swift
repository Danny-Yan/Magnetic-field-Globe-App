//
//  ParticleMeshGenerator+InitialiseClass.swift
//  ParticleSimulatorApp
//
//  Created by DY on 21/6/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

extension ParticleMeshGenerator {
    
    /// Create Initialise magnetic field class pipeline
    private static let initialisePipeline: MTLComputePipelineState? = makeComputePipeline(named: AppConstants.Sim.initialiseMagneticModel)
    
    
    static func initialiseMagneticModelClass(
                        coefficientBuffer: MTLBuffer,
                        coefficientBufferIndices: MTLBuffer,
                        coefficientBufferLength: Int,
                        outputModel: MTLBuffer,
                         encoder: MTLComputeCommandEncoder) throws {
        guard let initialisePipeline = Self.initialisePipeline else {
            throw particleBrushGenerationError.unableToCreateComputePipeline
        }
        
        encoder.setComputePipelineState(initialisePipeline)
                             
        encoder.setBuffer(coefficientBuffer, offset: 0, index: 0)
        encoder.setBuffer(coefficientBufferIndices, offset: 0, index: 1)

        var length = UInt32(coefficientBufferLength)
        encoder.setBytes(&length, length: MemoryLayout<UInt32>.stride, index: 2)

        encoder.setBuffer(outputModel, offset: 0, index: 3)
                             
//       Dispatch on a single thread
        encoder.dispatchThreadgroups(MTLSizeMake(1, 1, 1),
                                     threadsPerThreadgroup: MTLSizeMake(Int(length), 1, 1))
    }
    
    
}
