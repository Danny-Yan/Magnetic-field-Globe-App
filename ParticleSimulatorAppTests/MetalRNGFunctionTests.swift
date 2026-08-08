//
//  MetalRNGFunctionTests.swift
//  ParticleSimulatorAppTests
//
//  Created by DY on 6/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Testing

struct MetalRNGFunctionTests {
    var testAPI: TesterAPI
    var id: Float
    var seed: Float
    
    init() async throws {
        testAPI = TesterAPI()
        id = 3000
        seed = 200
    }
    
    @Test func `lower: 0, upper: 1`() async throws {
        let output: [Float] = try await testAPI.gpu.testMetalRNGFunction(lower: 1, upper: 2, id: id, seed: seed)
        let res: [Float] = [0.5, 0.5, 0.5]
        #expect(output.elementsEqual(res))
    }

}
