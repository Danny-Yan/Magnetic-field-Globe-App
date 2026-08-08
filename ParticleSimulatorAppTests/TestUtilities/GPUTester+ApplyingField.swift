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
    
    private func applyFieldPipeline(
        particle: MTLBuffer,
        model: MTLBuffer?,
        deltaTime: Float,
        encoder: MTLComputeCommandEncoder
    ) throws {
        testPipelineTemplate(encoder: encoder, name: "testApplyMagneticField", pipeline: { (encoder) in
            encoder.setBuffer(particle, offset: 0, index: 0)
            encoder.setBuffer(model, offset: 0, index: 1)
            
            withUnsafePointer(to: deltaTime) { dt in
                encoder.setBytes(dt, length: MemoryLayout<Float>.size,  index: 2)
            }
        })
    }

    private func testApplyField(polarCoord: SIMD3<Float>, date: Date) async throws -> ParticleAttributes {
        
        let (particleBuffer, particlePointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: ParticleAttributes.self)
        particlePointer.pointee.attributes.polarCoordinate = polarCoord.packed3
        particlePointer.pointee.attributes.position = polarCoord.toCartesian().packed3
        particlePointer.pointee.attributes.yearFraction = createYearFractionFromDate(date: date)
        
        let deltaTime: Float  = 0.01
        
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { encoder in
            try? applyFieldPipeline(particle: particleBuffer, model: magneticModelBuffer, deltaTime: deltaTime , encoder: encoder)
        })
        
        return particlePointer.pointee
    }
    
    func testApplyFieldForPosition(
        alt: Double, lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020
    ) async throws -> [Float] {
        
        let testPolarCoord = convertGeographicDegToRad(alt: alt, lat: lat, lon: lon)
        let testDate = try createDateFromDMY(day: day, month: month, year: year)
        let particle = try await testApplyField(polarCoord: testPolarCoord, date: testDate)
        
        let pos = particle.attributes.position.toArray()
        return pos
    }

}
