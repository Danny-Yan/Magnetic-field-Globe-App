//
//  GPUTester+UpdateColour.swift
//  ParticleSimulatorApp
//
//  Created by DY on 6/9/2026.
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
    
    private func updateColourPipeline(
        particle: MTLBuffer,
        params: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        testPipelineTemplate(encoder: encoder, name: "testUpdateColour", pipeline: { (encoder) in
            
            encoder.setBuffer(particle, offset: 0, index: 0)
            encoder.setBuffer(params, offset: 0, index: 1)
            
        })
    }

    func testHeatMapColourPipeline(
        velocity: [Float],
        maxSpeed: Float,
        minColour: SIMD3<Float16>,
        maxColour: SIMD3<Float16>
    ) async throws -> [Float16] {
        
        let (particleBuffer, particlePointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: ParticleAttributes.self)
        var particle = particlePointer.pointee
        particle.velocity = SIMD3(velocity).packed3
        particlePointer.pointee = particle
        
        let (paramsBuffer, paramsPointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: ParticleSimulationParams.self)
        
        var params = paramsPointer.pointee
        params.chosenLayerEnum = .heatMapLayer
        
        params.heatMapLayer.maxSpeed = maxSpeed
        params.heatMapLayer.minColour = minColour.packed3
        params.heatMapLayer.maxColour = maxColour.packed3
        
        paramsPointer.pointee = params
        
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { (encoder, _) in
            try? updateColourPipeline(particle: particleBuffer, params: paramsBuffer, encoder: encoder)
        })
        
        let sizeFloat = particlePointer.pointee.attributes.size
        print("HeatMapLayer: \(sizeFloat)")
        
        return particlePointer.pointee.attributes.color.simd.toArray()
    }
}
