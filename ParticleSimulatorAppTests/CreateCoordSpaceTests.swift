//
//  CreateCoordSpaceTests.swift
//  ParticleSimulatorAppTests
//
//  Created by DY on 27/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Testing

struct CreateCoordSpaceTests {
    var testAPI: TesterAPI
    
    init() async throws {
        testAPI = TesterAPI()
    }
    
    @Test func `PolarCoord: Default`() async throws {

        let coordSpace = try await testAPI.gpu.testCoordSpaceComponents(alt: 0, lat: 0, lon: 0)
        
        let coordSpaceResult: [[Float]] = [
            [0, 0, 0],
            [0, 0, 0],
            [0, 0, 0]
        ]
        
        #expect(coordSpace.elementsEqual(coordSpaceResult))
    }

}
