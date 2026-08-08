//
//  GPUTester+InitialiseField.swift
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

extension GPUTester {
    
    mutating func initialiseMetalApp() async throws {
        AppConstants.Spawn.maxSpawnCount = 1
        AppConstants.Spawn.minSpawnCount = 1
        
        AppConstants.Spawn.centre = [-0.5, 1.5, -1]
        AppConstants.Spawn.radius = 0  // Remove Randomness from sphere position
        
        AppConstants.Particle.initialSpeed = 0
        AppConstants.Particle.size = 0.3
        
        AppConstants.Earth.showEarth = false
        AppConstants.Sim.skipSplashScreen = true
        AppConstants.Sim.showSim = true
        
        /// The GPU command queue to store incoming GPU commands
        let commandQueue: MTLCommandQueue? = {
            if let metalDevice, let queue = metalDevice.makeCommandQueue() {
                queue.label = "particle Brush Command Queue"
                return queue
            } else {
                return nil
            }
        }()
        
        (coefficientBuffers, magneticModelBuffer) =
        ParticleMeshGenerator.createModelBuffers(
            modelCoefficients: AppConstants.modelCoefficients.igrf,
            metalDevice: metalDevice
        )
        
        magneticModelPointer = createSingleTypeBufPointer(buf: &magneticModelBuffer!, of: MagneticFieldModel.self)
        
        guard let commandBuf = commandQueue?.makeCommandBuffer(),
              let compute = commandBuf.makeComputeCommandEncoder()
        else {
            fatalError("Command buffer failed to initalise")
        }
        
        computeEncoder = compute
        commandBuffer = commandBuf
        commandBuffer!.enqueue()
        
        try? ParticleMeshGenerator.initialiseMagneticModelClass(
            coefficientBuffers: coefficientBuffers!,
            outputModel: magneticModelBuffer!,
            encoder: computeEncoder!
        )
        
        computeEncoder!.endEncoding()
        commandBuffer!.commit()
        await commandBuffer!.completed()
    }
}
