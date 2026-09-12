//
//  ModelDataConversionTests.swift
//
//  Created by DY on 3/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Testing
@testable import ParticleSimulatorApp

struct ModelDataConversionTests {
    private typealias dataSet = TestingDataSets
    
    @Test func testMagneticConversion() async throws {
        
        let (testModelIndices, testModelCoefficients, testDateTime) = ParticleMeshGenerator.parseModelCoefficientFile(chosenModel: .WMM2020)
        
        #expect(testModelIndices        == dataSet.modelIndicesWMM2020)
        #expect(testModelCoefficients   == dataSet.modelEntriesWMM2020)
        #expect(testDateTime            == dataSet.modelTimeDataWMM2020)
    }

    @Test func `testMagneticFileConversion: WMM2020`() async throws {
        
        let (testModelIndices, testModelCoefficients, testDateTime) = ParticleMeshGenerator.parseModelCoefficientFile(chosenModel: .WMM2020)
        
        #expect(testModelIndices        == dataSet.modelIndicesWMM2020)
        #expect(testModelCoefficients   == dataSet.modelEntriesWMM2020)
        #expect(testDateTime            == dataSet.modelTimeDataWMM2020)
    }
    
    @Test func `testMagneticFileConversion: WMM2025`() async throws {
        
        let (testModelIndices, testModelCoefficients, testDateTime) = ParticleMeshGenerator.parseModelCoefficientFile(chosenModel: .WMM2025)

        #expect(testModelIndices        == dataSet.modelIndicesWMM2025)
        #expect(testModelCoefficients   == dataSet.modelEntriesWMM2025)
        #expect(testDateTime            == dataSet.modelTimeDataWMM2025)
    }
}
