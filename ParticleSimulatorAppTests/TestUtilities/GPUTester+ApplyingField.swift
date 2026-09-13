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
        model: MTLBuffer,
        params: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        testPipelineTemplate(encoder: encoder, name: "testApplyMagneticField", pipeline: { (encoder) in
            encoder.setBuffer(particle, offset: 0, index: 0)
            encoder.setBuffer(model, offset: 0, index: 1)
            encoder.setBuffer(params, offset: 0, index: 2)
        })
    }

    private mutating func testApplyField(polarCoord: SIMD3<Float>, date: Date) async throws -> ParticleAttributes {
        
        // Run initialise pipeline
        var (magneticModelBuffer, magneticModelPointer) = try await initialiseMagneticModel(chosenModel: .WMM2020)
        
        // Particle initialisation
        let (particleBuffer, ParticleSystemPointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: ParticleAttributes.self)
        ParticleSystemPointer.pointee.attributes.polarCoordinate = polarCoord.packed3
        ParticleSystemPointer.pointee.attributes.position = polarCoord.toCartesian().packed3
        magneticModelPointer.pointee.yearFraction = createYearFractionFromDate(date: date)
        
        // Params initialisation
        let (paramsBuffer, paramsPointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: ParticleSimulationParams.self)
        paramsPointer.pointee.deltaTime = 0.01
        paramsPointer.pointee.forceMultiplier = 1.0
        
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { (encoder, _) in
            try? applyFieldPipeline(
                particle: particleBuffer,
                model: magneticModelBuffer,
                params: paramsBuffer,
                encoder: encoder
            )
        })
        
        return ParticleSystemPointer.pointee
    }
    
    mutating func testApplyFieldForPosition(
        alt: Double, lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020
    ) async throws -> [Float] {
        
        let testPolarCoord = convertGeographicDegToRad( alt: alt, lat: lat, lon: lon )
        let testDate = createDateFromDMY( day: day, month: month, year: year )
        let particle = try await testApplyField( polarCoord: testPolarCoord, date: testDate! )
        
        let pos = particle.attributes.position.toArray()
        return pos
    }
    
    mutating func testApplyFieldForVelocity(
        alt: Double, lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020
    ) async throws -> SIMD3<Float> {
        
        let testPolarCoord = convertGeographicDegToRad( alt: alt, lat: lat, lon: lon )
        let testDate = createDateFromDMY( day: day, month: month, year: year)
        let particle = try await testApplyField( polarCoord: testPolarCoord, date: testDate! )
        
        let vel = particle.velocity.simd3
        return vel
    }
}
