//
//  GPUTester+TrailPopulateLowLevelMesh.swift
//  ParticleSimulatorApp
//
//  Created by DY on 18/8/2026.
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
    
//    private func trailPopulatePipeline(
//        particle: MTLBuffer,
//        outputTrailVertices: MTLBuffer,
//        encoder: MTLComputeCommandEncoder
//    ) throws {
//        testPipelineTemplate(encoder: encoder, name: "testTrailPopulatePipeline", pipeline: { (encoder) in
//            encoder.setBuffer(particle, offset: 0, index: 0)
//            encoder.setBuffer(outputTrailVertices, offset: 0, index: 1)
//            
//        })
//    }
//
//    private func testTrailPopulate(polarCoord: SIMD3<Float>, date: Date) async throws -> ParticleAttributes {
//        
//        let (particleBuffer, particlePointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: ParticleAttributes.self)
//        particlePointer.pointee.attributes.polarCoordinate = polarCoord.packed3
//        particlePointer.pointee.attributes.position = polarCoord.toCartesian().packed3
//        particlePointer.pointee.attributes.yearFraction = createYearFractionFromDate(date: date)
//        
//        // Create Trail Buffer
//        // oh wait this doesn't make buffers fuckkkkk
//        let (particleTrailBuffer, particleTrailPointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: ParticleTrailVertex.self)
//
//        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { encoder in
//            try? trailPopulatePipeline(particle: particleBuffer, outputTrailVertices: particleTrailBuffer, encoder: encoder)
//        })
//        
//        return particlePointer.pointee
//    }
//    
//    func testTrailPopulateForPosition(
//        alt: Double, lat: Double, lon: Double,
//        day: Int = 1, month: Int = 1, year: Int = 2020
//    ) async throws -> [Float] {
//        
//        let testPolarCoord = convertGeographicDegToRad(alt: alt, lat: lat, lon: lon)
//        let testDate = createDateFromDMY(day: day, month: month, year: year)!
//        let particle = try await testTrailPopulate(polarCoord: testPolarCoord, date: testDate)
//        
//        let pos = particle.attributes.position.toArray()
//        return pos
//    }

    @MainActor
    private func testTrailPopulateLowLevelMesh(polarCoord: SIMD3<Float>,
                                               date : Date) async throws -> LowLevelMesh {
        let particleCount: Int = 1
        
        let (particleBuffer, particlePointer) = try await createBufferAndPointer(
            metalDevice: metalDevice,
            of: ParticleAttributes.self
        )
        
        particlePointer.pointee.attributes.polarCoordinate = polarCoord.packed3
        particlePointer.pointee.attributes.position = polarCoord.toCartesian().packed3
        particlePointer.pointee.attributes.yearFraction = createYearFractionFromDate(date: date)

        let output: LowLevelMesh = try ParticleMeshGenerator.makeTrailLowLevelMesh(
            particleCapacity: particleCount * Int(MAX_TRAIL_LENGTH),
            particleCount: particleCount
        )
        
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { (encoder, commandBuffer) in
            
            
            try? ParticleMeshGenerator.populateTrails(
                input: particleBuffer,
                output: output,
                particleCount: particleCount,
                commandBuffer: commandBuffer,
                encoder: encoder
            )
        })
        
        return output
    }
    
    
    @MainActor
    func testTrailPopulateForPosition(
        alt: Double, lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020
    ) async throws -> ([[Float]], [[Float16]]) {
        let testPolarCoord = convertGeographicDegToRad(alt: alt, lat: lat, lon: lon)
        let testDate = createDateFromDMY(day: day, month: month, year: year)!
        let lowLevelMesh: LowLevelMesh = try await testTrailPopulateLowLevelMesh(polarCoord: testPolarCoord, date: testDate)
        
        var positionOutput: [[Float]] = []
        var colorOutput: [[Float16]] = []
        lowLevelMesh.withUnsafeBytes(bufferIndex: 0, { buffer in
            let vertices = buffer.bindMemory(to: [ParticleTrailVertex].self)
           
            // Parsing position and color outputs into float arrays
            let vertexArray = Array(vertices)
            
            let _ = vertices.map{
                
                // Parsing position
                positionOutput = $0.map {$0.attributes.position.simd3.toArray()}
                
                // Parsing color
                colorOutput = $0.map {$0.attributes.color.simd.toArray()}
            }
        })
        
        return (positionOutput, colorOutput)
        
    }
}
