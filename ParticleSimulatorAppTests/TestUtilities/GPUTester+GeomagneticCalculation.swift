//
//  TestGeomagneticCalculation.swift
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
    
    
    // GPU function to call test magnetic field calc function
    private func magneticModelPipeline(
        polarCoord: SIMD3<Float>,
        yearFraction: Float,
        outputResult: MTLBuffer,
        localVariableBuffer: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        testPipelineTemplate(encoder: encoder, name: "testCalculateMagneticField", pipeline: { (encoder) in
            withUnsafePointer(to: polarCoord) {coord in
                encoder.setBytes(coord, length: MemoryLayout<SIMD3<Float>>.size,  index: 0)
            }
            withUnsafePointer(to: yearFraction) { yearFrac in
                encoder.setBytes(yearFrac, length: MemoryLayout<Float>.size,  index: 1)
            }
            
            encoder.setBuffer(magneticModelBuffer, offset: 0,  index: 2)
            encoder.setBuffer(localVariableBuffer, offset: 0, index: 3)
            encoder.setBuffer(outputResult, offset: 0, index: 4)
        })
    }
    
    // Test magnetic field with a single point and single date time
    func testGeomagneticFieldMetalFunction(polarCoord testPolarCoord: SIMD3<Float>, date testDateTime: Date) async throws -> (MagneticFieldPerParticleVariables, MagneticField) {
        
        let yearFraction = createYearFractionFromDate(date: testDateTime)
        
        print("DateTime: \(testDateTime)")
        print("YearFraction: \(createYearFractionFromDate(date: testDateTime))")
        
        // Create output and local variable buffer and buffer pointers
        let (outputBuffer, outputPointer) =  try await createBufferAndPointer(metalDevice: metalDevice, of: MagneticField.self)
        let (localVariableBuffer, localVariablePointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: MagneticFieldPerParticleVariables.self)
        
        // Assign local variable pointer with buffers created in the initialisation step
        localVariablePointer.pointee.snorm = magneticModelPointer!.pointee.snorm
        localVariablePointer.pointee.olat = -1000
        localVariablePointer.pointee.olon = -1000
        localVariablePointer.pointee.oalt = -1000
        localVariablePointer.pointee.otime = -1000

        
        // Call GPU function a single time
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { encoder in
            try? magneticModelPipeline(polarCoord: testPolarCoord, yearFraction: yearFraction, outputResult: outputBuffer, localVariableBuffer: localVariableBuffer, encoder: encoder)
        })
        
        return (localVariablePointer.pointee, outputPointer.pointee)
    }
    
    // Generalised implementation
    private func privateTestForComponent(
        alt: Double,
        lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020
    ) async throws -> [Float]{
        
        // Conversion radians
        let testPolarCoord = convertGeographicToPolarCoords(alt: alt, lat: lat, lon: lon)
        let testDateTime: Date = try createDateFromDMY(day: day, month: month, year: year)
        
        // Test metal function
        let (internalVar, res) = try! await testGeomagneticFieldMetalFunction(polarCoord: testPolarCoord, date: testDateTime)
        
        // Parse output and test
        let components = res.components
        let componentsArray = convertPackedToFloat(array: components)
        
        // Print Out Info
        let model: MagneticFieldModel = magneticModelPointer!.pointee
        printClassEntries(headline: "Magnetic Model", for: model)
        printClassEntries(headline: "Local Variables", for: internalVar)
        printClassEntries(headline: "Ouput Field", for: res)

        print("Components: \(componentsArray[0]), \(componentsArray[1]), \(componentsArray[2])")
        
        return componentsArray
    }
    
    // Raw Altitude Variation
    func testForComponent(
        alt: Double,
        lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020
    ) async throws -> [Float]{
        let trueAlt = alt
        return try await privateTestForComponent(alt: trueAlt, lat: lat, lon: lon, day: day, month: month, year: year)
    }
    
    // Elevation from mean sea level Variation
    func testForComponent(
        elevation: Double,
        lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020
    ) async throws -> [Float]{
        let earthSeaLevel: Double = 6000
        let trueAlt = earthSeaLevel + elevation
        return try await privateTestForComponent(alt: trueAlt, lat: lat, lon: lon, day: day, month: month, year: year)
    }
}
