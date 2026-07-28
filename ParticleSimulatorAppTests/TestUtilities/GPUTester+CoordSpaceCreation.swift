//
//  TestCoordSpaceCreation.swift
//  ParticleSimulatorApp
//
//  Created by DY on 27/7/2026.
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
    private func coordinateSpaceCreationPipeline(
        particle: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        testPipelineTemplate(encoder: encoder, name: "testCreateCoordSpace", pipeline: { (encoder) in
            encoder.setBuffer(particle, offset: 0, index: 0)
        })
    }
    
    private func testCoordSpaceCreation(polarCoord: SIMD3<Float>) async throws -> (ParticleAttributes){
        
        let (particleBuffer, particlePointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: ParticleAttributes.self)
        particlePointer.pointee.attributes.polarCoordinate = polarCoord.packed3
        particlePointer.pointee.attributes.position = polarCoord.toCartesian().packed3
        
        print("Polar Coordinate: \(polarCoord)")
        print("Cartesian Coordinate: \(polarCoord.toCartesian())")

        // Call GPU function a single time
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { encoder in
            try? coordinateSpaceCreationPipeline(particle: particleBuffer, encoder: encoder)
        })
        
        return particlePointer.pointee
    }
    
    func testCoordSpaceComponents(alt: Double, lat: Double, lon: Double) async throws -> [[Float]]{
        
        let testPolarCoord = convertGeographicDegToRad(alt: alt, lat: lat, lon: lon)
        let particle = try! await testCoordSpaceCreation(polarCoord: testPolarCoord)
        
        let coordSpace = particle.attributes.coordSpace
        let coordSpaceComponents = [
            coordSpace.northVector.toArray(),
            coordSpace.eastVector.toArray(),
            coordSpace.verticalVector.toArray()
        ]
        return coordSpaceComponents
    }
}
