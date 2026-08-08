//
//  GPUTester+RNGFunctions.swift
//  ParticleSimulatorApp
//
//  Created by DY on 6/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

//
//  GPUTester+ApplyingField.swift
//  ParticleSimulatorAppTests
//
//  Created by DY on 29/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import Collections
import Foundation
import RealityKit
import RealityKitContent
import SwiftUI
import Testing

@testable import ParticleSimulatorApp
extension GPUTester {
    
    private func rngFunctionPipeline(
        params: SIMD4<Float>,
        output: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        testPipelineTemplate(encoder: encoder, name: "testMetalRNGFunction", pipeline: { (encoder) in
            withUnsafePointer(to: params) { p in
                encoder.setBytes(p, length: MemoryLayout<SIMD4<Float>>.size,  index: 0)
            }
            
            encoder.setBuffer(output, offset: 0, index: 1)
            
        })
    }

    func testMetalRNGFunction(lower: Float, upper: Float, id: Float, seed: Float) async throws -> [Float] {
        let params: SIMD4<Float> = SIMD4<Float>(lower, upper, id, seed)
        let (outputBuffer, outputPointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: SIMD3<Float>.self)
        
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { encoder in
            try? rngFunctionPipeline(params: params, output: outputBuffer, encoder: encoder)
        })
        
        return outputPointer.pointee.toArray()
    }
}
