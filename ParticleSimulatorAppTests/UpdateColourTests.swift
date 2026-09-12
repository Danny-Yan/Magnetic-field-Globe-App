//
//  UpdateColourTests.swift
//  ParticleSimulatorAppTests
//
//  Created by DY on 6/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Testing

@testable import ParticleSimulatorApp

struct UpdateColourTests {
    
    var testAPI: TesterAPI
    init(){
        testAPI = TesterAPI()
    }
    
    @Test func `Speed: (0, 0, 0), MaxSpeed: 3, MinColour: Blue, MaxColour: Red`() async throws {
        let velocity: [Float] = [0, 0, 0]
        let maxSpeed: Float = 3
        let minColour: SIMD3<Float16> = [84, 133, 250] / 255
        let maxColour: SIMD3<Float16> = [232, 87, 87] / 255
        
        let colour = try await testAPI.gpu.testHeatMapColourPipeline(
            velocity: velocity,
            maxSpeed: maxSpeed,
            minColour: minColour,
            maxColour: maxColour
        )
        let targetColour: [Float16] = minColour.toArray()
        
        #expect(colour.elementsEqual(targetColour, tolerance: 0.01))
    }
    
    @Test func `Speed: (0, 0, 3), MaxSpeed: 3, MinColour: Blue, MaxColour: Red`() async throws {
        let velocity: [Float] = [0, 0, 3]
        let maxSpeed: Float = 3
        let minColour: SIMD3<Float16> = [84, 133, 250] / 255
        let maxColour: SIMD3<Float16> = [232, 87, 87] / 255
        
        let colour = try await testAPI.gpu.testHeatMapColourPipeline(
            velocity: velocity,
            maxSpeed: maxSpeed,
            minColour: minColour,
            maxColour: maxColour
        )
        let targetColour: [Float16] = maxColour.toArray()
        
        #expect(colour.elementsEqual(targetColour, tolerance: 0.01))
    }
    
    @Test func `Speed: (0, 0, 1.5), MaxSpeed: 3, MinColour: Blue, MaxColour: Red`() async throws {
        let velocity: [Float] = [5340.87, 9178.838, 749.4607]
        let maxSpeed: Float = 30000
        let minColour: SIMD3<Float16> = [84, 133, 250] / 255
        let maxColour: SIMD3<Float16> = [232, 87, 87] / 255

        let colour = try await testAPI.gpu.testHeatMapColourPipeline(
            velocity: velocity,
            maxSpeed: maxSpeed,
            minColour: minColour,
            maxColour: maxColour
        )
        let targetColour: [Float16] = maxColour.toArray()
        #expect(colour.elementsEqual(targetColour, tolerance: 0.01))
    }
}
