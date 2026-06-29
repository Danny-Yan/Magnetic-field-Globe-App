//
//  ParticleSimulatorAppTests.swift
//  ParticleSimulatorAppTests
//
//  Created by DY on 27/6/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Testing
@testable import ParticleSimulatorApp
import SwiftUI
import RealityKit
import RealityKitContent
import Foundation
import Collections

struct ParticleSimulatorAppTests {
    
    @Test func example() async throws {
        AppConstants.Spawn.maxSpawnCount = 1
        AppConstants.Spawn.minSpawnCount = 1
        
        AppConstants.Spawn.centre = [0, 1.5, -1]
        AppConstants.Spawn.radius = 1
        
        AppConstants.Particle.initialSpeed = 0
        AppConstants.Particle.size = 0.3
        
        AppConstants.Earth.showEarth = false
        AppConstants.Sim.skipSplashScreen = true
        AppConstants.Sim.showSim = true
        
        let _ = RealityView { content in
            let rootEntity = Entity()
            
            // Create Material
            let particleMaterial = await ParticleSystemEntity.instantiateParticleMaterial()
            let material: RealityKit.Material = particleMaterial ?? SimpleMaterial()
            
            let testParticleGen = ParticleMeshGenerator(rootEntity: rootEntity, material: material, modelCoefficientString: AppConstants.modelCoefficients.igrfCoefficients)
            
            // Create particle and call a single instance of simulation
            for _ in 0...5 {
                try? testParticleGen.update(deltaTime: 0.1) { _ in }
            }
            
            // Direct pointer access to the particleBuffer struct
            var modelPointer: UnsafeMutablePointer<[ParticleAttributes]> {
                (testParticleGen.simulationBuffer?.contents().bindMemory(to: [ParticleAttributes].self, capacity: 1))!
            }
            
            // Show result
            print(modelPointer.pointee[0].attributes.magField)
        }
    }
}
