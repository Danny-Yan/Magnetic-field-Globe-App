//
//  ApplyFieldTests.swift
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

struct ApplyFieldTests {
    
    var testAPI: TesterAPI
    var tolerance: Float = 0.005
    
    init() async throws {
        testAPI = TesterAPI()
        try await testAPI.gpu.initialiseMetalApp()
    }
    
    @Test func `Polar Coord: Default`() async throws {
        let particlePos = try await testAPI.gpu.testApplyFieldForPosition(alt: 1, lat: 0, lon: 0)
        let testPos: [Float] = [0, 0, 0]
        #expect(particlePos.elementsEqual(testPos, tolerance: tolerance))
    }
    
    @Test func `Polar Coord: (alt: 1, lat: 10, lon: 0)`() async throws {
        let particlePos = try await testAPI.gpu.testApplyFieldForPosition(alt: 1, lat: 10, lon: 0)
        let testPos: [Float] = [0, 0, 0]
        #expect(particlePos.elementsEqual(testPos, tolerance: tolerance))
    }
    
    @Test func `Polar Coord: (alt: 1, lat: -10, lon: 0)`() async throws {
        let particlePos = try await testAPI.gpu.testApplyFieldForPosition(alt: 1, lat: -10, lon: 0)
        let testPos: [Float] = [0, 0, 0]
        #expect(particlePos.elementsEqual(testPos, tolerance: tolerance))
    }
    
    @Test func `Polar Coord: (alt: 1, lat: 0, lon: 10)`() async throws {
        let particlePos = try await testAPI.gpu.testApplyFieldForPosition(alt: 1, lat: 0, lon: 10)
        let testPos: [Float] = [0, 0, 0]
        #expect(particlePos.elementsEqual(testPos, tolerance: tolerance))
    }
    
    @Test func `Polar Coord: (alt: 1, lat: 0, lon: -10)`() async throws {
        let particlePos = try await testAPI.gpu.testApplyFieldForPosition(alt: 1, lat: 0, lon: -10)
        let testPos: [Float] = [0, 0, 0]
        #expect(particlePos.elementsEqual(testPos, tolerance: tolerance))
    }
    
    @Test func `Polar Coord: (alt: 0.5, lat: 0, lon: 0)`() async throws {
        let particlePos = try await testAPI.gpu.testApplyFieldForPosition(alt: 0.5, lat: 0, lon: 0)
        let testPos: [Float] = [0, 0, 0]
        #expect(particlePos.elementsEqual(testPos, tolerance: tolerance))
    }
    
    @Test func `Polar Coord: (alt: 1.5, lat: 0, lon: 0)`() async throws {
        let particlePos = try await testAPI.gpu.testApplyFieldForPosition(alt: 1.5, lat: 0, lon: 0)
        let testPos: [Float] = [0, 0, 0]
        #expect(particlePos.elementsEqual(testPos, tolerance: tolerance))
    }
}
