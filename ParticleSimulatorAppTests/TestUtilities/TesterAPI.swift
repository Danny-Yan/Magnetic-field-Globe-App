//
//  GPUTester.swift
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

struct GPUTester {
    var coefficientBuffers: CoefficientBuffers? = nil
    var magneticModelBuffer: MTLBuffer? = nil
    var magneticModelPointer: UnsafeMutablePointer<MagneticFieldModel>? = nil
    var computeEncoder: MTLComputeCommandEncoder? = nil
    var commandBuffer: MTLCommandBuffer? = nil
    
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
    
    
    func testPipelineTemplate(encoder: MTLComputeCommandEncoder, name: String, pipeline: (_ encoder: MTLComputeCommandEncoder) -> Void){
        guard
            let testingPipeline =
                makeComputePipeline(
                    named: name
                )
        else {
            Issue.record("Test pipeline failed to initlaise")
            return
        }
        encoder.setComputePipelineState(testingPipeline)
        
        pipeline(encoder)
        
        // Dispatch on a single thread
        encoder.dispatchThreadgroups(
            MTLSizeMake(1, 1, 1),
            threadsPerThreadgroup: MTLSizeMake(1, 1, 1)
        )
    }
    
}

struct ExternalTester {
    // External tests (Probs move to seperate file later on)
    func testForComponent(
        alt: Double,
        lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020
    ) async throws -> [Float]{
        let testDateTime: Date = try createDateFromDMY(day: day, month: month, year: year)
        let gm = ExternalGeomagnetism(longitude: lon, latitude: lat, altitude: alt, date: testDateTime)
        
        printClassEntries(headline: "External Variables", for: gm)
        
        let components = [Float(gm.northIntensity), Float(gm.eastIntensity), Float(gm.verticalIntensity)]
        return components
    }
}

// Testing API Structs
struct TesterAPI {
    var gpu: GPUTester = GPUTester()
    var external: ExternalTester = ExternalTester()
}

