//
//  ParticleSimulatorAppTests.swift
//  ParticleSimulatorAppTests
//
//  Created by DY on 27/6/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Collections
import Foundation
import RealityKit
import RealityKitContent
import SwiftUI
import Testing

@testable import ParticleSimulatorApp
struct MetalCodeTests {
    
    var testAPI: TesterAPI
        
    //    private var testParticleGen: ParticleMeshGenerator
    init() async throws {
        testAPI = TesterAPI()
        try await testAPI.gpu.initialiseMetalApp()
    }
    
    @Test func `External Class, Location: Default, Date = Epoch`() async throws {
        let componentsArray = try await testAPI.external.testForComponent(alt: 0, lat: 0, lon: 0, day: 1, month: 1, year: 2020)
        let testResult: [Float] = [27536.389, -2248.371, -16022.489]
        #expect(componentsArray.elementsEqual(testResult))
    }
    
    @Test func `Interal function, Location: Default, Date = Epoch`() async throws {
        let componentsArray = try await testAPI.gpu.testForComponent(alt: 0, lat: 0, lon: 0, day: 1, month: 1, year: 2020)
        let testResult: [Float] = [27536.389, -2248.371, -16022.489]
        #expect(componentsArray.elementsEqual(testResult))
    }
}
