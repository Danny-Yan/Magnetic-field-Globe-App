//
//  ParticleMeshGenerator+InitialiseClass.swift
//  ParticleSimulatorApp
//
//  Created by DY on 21/6/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

extension ParticleMeshGenerator {

    /// Create Initialise magnetic field class pipeline
    private static let initialisePipeline: MTLComputePipelineState? =
        makeComputePipeline(named: AppConstants.Sim.initialiseMagneticModel)

    static func initialiseMagneticModelClass(
        coefficientBuffers: CoefficientBuffers,
        outputModel: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        guard let initialisePipeline = Self.initialisePipeline else {
            throw particleBrushGenerationError.unableToCreateComputePipeline
        }

        encoder.setComputePipelineState(initialisePipeline)

        encoder.setBuffer(coefficientBuffers.entryBuffer, offset: 0, index: 0)
        encoder.setBuffer(coefficientBuffers.indexBuffer, offset: 0, index: 1)

        var length = UInt32(coefficientBuffers.modelBufferLength)
        encoder.setBytes(&length, length: MemoryLayout<UInt32>.stride, index: 2)
        encoder.setBuffer(coefficientBuffers.timeBuffer, offset: 0, index: 3)
        encoder.setBuffer(outputModel, offset: 0, index: 4)

        //       Dispatch on a single thread
        encoder.dispatchThreadgroups(
            MTLSizeMake(1, 1, 1),
            threadsPerThreadgroup: MTLSizeMake(1, 1, 1)
        )
    }

}
