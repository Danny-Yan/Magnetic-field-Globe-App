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
    
    var coefficientBuffers: CoefficientBuffers? = nil
    var magneticModelBuffer: MTLBuffer? = nil
    var magneticModelPointer: UnsafeMutablePointer<MagneticFieldModel>? = nil
    var computeEncoder: MTLComputeCommandEncoder? = nil
    var commandBuffer: MTLCommandBuffer? = nil
        
    //    private var testParticleGen: ParticleMeshGenerator
    init() async throws {
        try await initParticleSimulatorApp()
    }
    
    private mutating func initParticleSimulatorApp() async throws {
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
    private func testMagneticModelPipeline(
        polarCoord: SIMD3<Float>,
        yearFraction: Float,
        outputResult: MTLBuffer,
        localVariableBuffer: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        guard
            let testingPipeline =
                makeComputePipeline(
                    named: "testCalculateMagneticField"
                )
        else {
            Issue.record("Test pipeline failed to initlaise")
            return
        }
        
        encoder.setComputePipelineState(testingPipeline)
        
        withUnsafePointer(to: polarCoord) {coord in
            encoder.setBytes(coord, length: MemoryLayout<SIMD3<Float>>.size,  index: 0)
        }
        withUnsafePointer(to: yearFraction) { yearFrac in
            encoder.setBytes(yearFrac, length: MemoryLayout<Float>.size,  index: 1)
        }
        
        encoder.setBuffer(magneticModelBuffer, offset: 0,  index: 2)
        encoder.setBuffer(localVariableBuffer, offset: 0, index: 3)
        encoder.setBuffer(outputResult, offset: 0, index: 4)
        
        //       Dispatch on a single thread
        encoder.dispatchThreadgroups(
            MTLSizeMake(1, 1, 1),
            threadsPerThreadgroup: MTLSizeMake(1, 1, 1)
        )
    }
    
    // Test magnetic field with a single point and single date time
    private func testGeomagneticFieldMetalFunction(polarCoord testPolarCoord: SIMD3<Float>, date testDateTime: Date) async throws -> (MagneticFieldPerParticleVariables, MagneticField) {
        
        let yearFraction = createYearFractionFromDate(date: testDateTime)
        
        // Create output and local variable buffer and buffer pointers
        let (outputBuffer, outputPointer) =  try await createBufferAndPointer(metalDevice: metalDevice, of: MagneticField.self)
        let (localVariableBuffer, localVariablePointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: MagneticFieldPerParticleVariables.self)
        
        // Assign local variable pointer with buffers created in the initialisation step
        localVariablePointer.pointee.snorm = magneticModelPointer!.pointee.snorm
        
        // Call GPU function a single time
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { encoder in
            try? testMagneticModelPipeline(polarCoord: testPolarCoord, yearFraction: yearFraction, outputResult: outputBuffer, localVariableBuffer: localVariableBuffer, encoder: encoder)
        })
        
        return (localVariablePointer.pointee, outputPointer.pointee)
    }
    
    // Generalised implementation
    private func privateTestForComponent(
        alt: Double,
        lat: Double, lon: Double,
        day: Int = 0, month: Int = 0, year: Int = 2020
    ) async throws -> [Float]{
        
        // Conversion radians
        let trueAlt = Float(alt)
        let radLat = Float(Angle.degrees(lat).radians)
        let radLon = Float(Angle.degrees(lon).radians)

        // convert to polar
        let testPolarCoord = SIMD3<Float>(trueAlt, radLat, radLon)
        let testDateTime: Date = try createDateFromDMY(day: day, month: month, year: year)
        // Test metal function
        let (internalVar, res) = try! await testGeomagneticFieldMetalFunction(polarCoord: testPolarCoord, date: testDateTime)
        
        // Parse output and test
        let components = res.components
        let componentsArray = [components.x, components.y, components.z]
        
        // Print Out Info
//        let model: MagneticFieldModel = magneticModelPointer.pointee
//        printClassEntries(headline: "Magnetic Model", for: model)
//        printClassEntries(headline: "Local Variables", for: internalVar)
//        printClassEntries(headline: "Ouput Field", for: res)
        
        print("----------------- Radians -----------------")
        print("Altitude: \(trueAlt)")
        print("latitude: \(radLat)")
        print("longitude: \(radLon)")
        
        return componentsArray
    }
    
    // Raw Altitude Variation
    func testForComponent(
        alt: Double,
        lat: Double, lon: Double,
        day: Int = 0, month: Int = 0, year: Int = 2020
    ) async throws -> [Float]{
        let trueAlt = alt
        return try await privateTestForComponent(alt: trueAlt, lat: lat, lon: lon, day: day, month: month, year: year)
    }
    
    // Elevation from mean sea level Variation
    func testForComponent(
        elevation: Double,
        lat: Double, lon: Double,
        day: Int = 0, month: Int = 0, year: Int = 2020
    ) async throws -> [Float]{
        let earthSeaLevel: Double = 6000
        let trueAlt = earthSeaLevel + elevation
        return try await privateTestForComponent(alt: trueAlt, lat: lat, lon: lon, day: day, month: month, year: year)
    }
    
    
    // External tests (Probs move to seperate file later on)
    func testExternalForComponent(
        alt: Double,
        lat: Double, lon: Double,
        day: Int = 0, month: Int = 0, year: Int = 2020
    ) async throws -> [Float]{
        let testDateTime: Date = try createDateFromDMY(day: day, month: month, year: year)
        let gm = ExternalGeomagnetism(longitude: lon, latitude: lat, altitude: alt, date: testDateTime)
        let components = [Float(gm.northIntensity), Float(gm.eastIntensity), Float(gm.verticalIntensity)]
        return components
    }
    
    @Test func `External Class, Location: Default, Date = Epoch`() async throws {
        let componentsArray = try await testExternalForComponent(alt: 0, lat: 0, lon: 0, day: 1, month: 1, year: 2020)
        let testResult: [Float] = [27536.389, -2248.371, -16022.489]
        #expect(componentsArray.elementsEqual(testResult))
    }
    
    @Test func `Interal function, Location: Default, Date = Epoch`() async throws {
        let componentsArray = try await testForComponent(alt: 0, lat: 0, lon: 0, day: 1, month: 1, year: 2020)
        let testResult: [Float] = [27536.389, -2248.371, -16022.489]
        #expect(componentsArray.elementsEqual(testResult))
    }
}
