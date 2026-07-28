//
//  MagneticFieldCalculationTests.swift
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

@Suite(.serialized, .initialiseLogger)
struct ParticleSimulatorAppTests {
    var testAPI: TesterAPI
    
    init() async throws {
        testAPI = TesterAPI()
        try await testAPI.gpu.initialiseMetalApp()
    }
    
    //    private var testParticleGen: ParticleMeshGenerator
    private func compareComponents(tolerance: Float = 0.005, alt: Double, latLon: [Double], day: Int = 1, month: Int = 1, year: Int = 2020 ) async throws -> ([Float],[Float],Float) {
        
        let expectedComponents = try await testAPI.external.testForComponent(alt: alt, lat: latLon[0], lon: latLon[1],
                                                                             day: day, month: month, year: year)
        let testComponents = try await testAPI.gpu.testForComponent(alt: alt, lat: latLon[0], lon: latLon[1],
                                                                    day: day, month: month, year: year)
//        print("\(expectedComponents)")
        return (expectedComponents, testComponents, tolerance)
    }
   
    // Seperate External and  Internal Tests
    @Test func `External Class, Location: Default, Date = Epoch`() async throws {
        printHeadlineSpacer(headline: "External")
        let componentsArray = try await testAPI.external.testForComponent(alt: 0, lat: 0, lon: 0, day: 1, month: 1, year: 2020)
        let testResult: [Float] = [27536.389, -2248.371, -16022.489]
        #expect(componentsArray.elementsEqual(testResult))
    }
    
    @Test func `Interal function, Location: Default, Date = Epoch`() async throws {
        printHeadlineSpacer(headline: "Internal")
        let componentsArray = try await testAPI.gpu.testForComponent(alt: 0, lat: 0, lon: 0, day: 1, month: 1, year: 2020)
        let testResult: [Float] = [27536.389, -2248.371, -16022.489]
        #expect(componentsArray.elementsEqual(testResult, tolerance: 0.5))
    }
    
    
    @Test func `External Class, Location: Flinder's Street, Date = Epoch`() async throws {
        printHeadlineSpacer(headline: "External")
        let componentsArray = try await testAPI.external.testForComponent(alt: 0, lat: -37.81851266233545, lon: 144.9635253288237, day: 1, month: 1, year: 2020)
        let testResult: [Float] = [21313.947, 4418.773, -55914.684]
        #expect(componentsArray.elementsEqual(testResult))
    }
    
    @Test func `Internal Class, Location: Flinder's Street, Date = Epoch`() async throws {
        printHeadlineSpacer(headline: "External")
        let componentsArray = try await testAPI.gpu.testForComponent(alt: 0, lat: -37.81851266233545, lon: 144.9635253288237, day: 1, month: 1, year: 2020)
        let testResult: [Float] = [21313.947, 4418.773, -55914.684]
        #expect(componentsArray.elementsEqual(testResult, tolerance: 0.5))
    }
    
    // Comparative tests
    @Test func `Location: Flinder's Street, Australia; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [-37.81851266233545, 144.9635253288237])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }

    @Test func `Location: London central, Britian; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [51.52048993008768, -0.12772529284162018])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
        
    @Test func `Location: New York, America; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [40.71344519957176, -73.99195321101882])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Seoul, South Korea; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [37.58015473802953, 126.99976870339971])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: South Pole; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [-84.99996978514692, 44.99942532642137])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: North Pole; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [84.99844471402558, -135.00398416004066])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Ouaguadougou, Burkina Faso; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [12.371918233382686, -1.5177017098658734])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Ouaguadougou, Burkina Faso; Date = Invalid`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [12.371918233382686, -1.5177017098658734],
                                                                                    day: -1, month: -1, year: -1)
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Ouaguadougou, Burkina Faso; Date = Before Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 0, latLon: [12.371918233382686, -1.5177017098658734],
                                                                                    day: 5, month: 10, year: 1998)
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }   
    @Test func `Location: Invalid Altitude, below minimum; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: -10000, latLon: [12.371918233382686, -1.5177017098658734])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    
    @Test func `Location: Invalid Altitude, too high; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 100000000000000, latLon: [12.371918233382686, -1.5177017098658734])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Ouaguadougou, 500km altitude; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 500, latLon: [12.371918233382686, -1.5177017098658734])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Ouaguadougou, 1000km altitude; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 1000, latLon: [12.371918233382686, -1.5177017098658734])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Ouaguadougou, 2000km altitude; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 2000, latLon: [12.371918233382686, -1.5177017098658734])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Ouaguadougou, 10,000km altitude; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 10000, latLon: [12.371918233382686, -1.5177017098658734])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
    
    @Test func `Location: Ouaguadougou, 100,000km altitude; Date = Epoch`() async throws {
        let (expectedOutcome, testOutcome, tolerance) = try await compareComponents(alt: 100000, latLon: [12.371918233382686, -1.5177017098658734])
        #expect(expectedOutcome.elementsEqual(testOutcome, tolerance: tolerance))
    }
}
