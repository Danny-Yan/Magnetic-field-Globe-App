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
    // GPU function to call test magnetic field calc function
    private func magneticModelPipeline(
        polarCoord: SIMD3<Float>,
        modelBuffer: MTLBuffer,
        localVariableBuffer: MTLBuffer,
        outputResult: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        testPipelineTemplate(encoder: encoder, name: "testCalculateMagneticField", pipeline: { (encoder) in
            withUnsafePointer(to: polarCoord) {coord in
                encoder.setBytes(coord, length: MemoryLayout<SIMD3<Float>>.size,  index: 0)
            }
            
            encoder.setBuffer(modelBuffer, offset: 0,  index: 1)
            encoder.setBuffer(localVariableBuffer, offset: 0, index: 2)
            encoder.setBuffer(outputResult, offset: 0, index: 3)
        })
    }
    
    // Test magnetic field with a single point and single date time
    private mutating func testGeomagneticFieldMetalFunction(
        polarCoord testPolarCoord: SIMD3<Float>,
        date testDateTime: Date,
        chosenModel: MagneticModelVersion = .WMM2020
    ) async throws -> (MagneticFieldModel, MagneticFieldPerParticleVariables, MagneticField) {
        
        // Initialises model struct with chosen version
        var (magneticModelBuffer, magneticModelPointer) = try await initialiseMagneticModel(chosenModel: chosenModel)
        
        // Assign time of magnetic model simulation
        let yearFraction = createYearFractionFromDate(date: testDateTime)
        magneticModelPointer.pointee.yearFraction = yearFraction
        
        // Create output and local variable buffer and buffer pointers
        let (outputBuffer, outputPointer) =  try await createBufferAndPointer(metalDevice: metalDevice, of: MagneticField.self)
        let (localVariableBuffer, localVariablePointer) = try await createBufferAndPointer(metalDevice: metalDevice, of: MagneticFieldPerParticleVariables.self)
        
        // Assign local variable pointer with buffers created in the initialisation step
        localVariablePointer.pointee.snorm = magneticModelPointer.pointee.snorm
        localVariablePointer.pointee.olat = -1000
        localVariablePointer.pointee.olon = -1000
        localVariablePointer.pointee.oalt = -1000
        localVariablePointer.pointee.otime = -1000

        // Call GPU function a single time
        try? await singleGPUCall(metalDevice: metalDevice, gpuFunction: { (encoder, _) in
            try? magneticModelPipeline(
                polarCoord: testPolarCoord,
                modelBuffer: magneticModelBuffer,
                localVariableBuffer: localVariableBuffer,
                outputResult: outputBuffer,
                encoder: encoder
            )
        })
        
        return (magneticModelPointer.pointee, localVariablePointer.pointee, outputPointer.pointee)
    }
    
    // Generalised implementation
    private mutating func privateTestForComponent(
        alt: Double,
        lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020,
        chosenModel: MagneticModelVersion = .WMM2020
    ) async throws -> [Float]{
        
        // Conversion radians
        let testPolarCoord = convertGeographicDegToRad(alt: alt, lat: lat, lon: lon)
        let testDateTime: Date = createDateFromDMY(day: day, month: month, year: year)!
        
        // Test metal function
        let (model, internalVar, res) = try! await testGeomagneticFieldMetalFunction(
            polarCoord: testPolarCoord,
            date: testDateTime,
            chosenModel: chosenModel
        )
        
        // Parse output and test
        let components = res.components
        let componentsArray = components.toArray()
        
        // Print Out Info
        printClassEntries(headline: "Magnetic Model", for: model)
        printClassEntries(headline: "Local Variables", for: internalVar)
        printClassEntries(headline: "Ouput Field", for: res)

        print("Components: \(componentsArray[0]), \(componentsArray[1]), \(componentsArray[2])")
        
        return componentsArray
    }
    
    // Raw Altitude Variation
    mutating func testForComponent(
        alt: Double,
        lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020,
        chosenModel: MagneticModelVersion = .WMM2020
    ) async throws -> [Float]{
        let trueAlt = alt
        return try await privateTestForComponent(alt: trueAlt, lat: lat, lon: lon, day: day, month: month, year: year, chosenModel: chosenModel)
    }
    
    // Elevation from mean sea level Variation
    mutating func testForComponent(
        elevation: Double,
        lat: Double, lon: Double,
        day: Int = 1, month: Int = 1, year: Int = 2020,
        chosenModel: MagneticModelVersion = .WMM2020
    ) async throws -> [Float]{
        let earthSeaLevel: Double = 6000
        let trueAlt = earthSeaLevel + elevation
        return try await privateTestForComponent(alt: trueAlt, lat: lat, lon: lon, day: day, month: month, year: year, chosenModel: chosenModel)
    }
}
