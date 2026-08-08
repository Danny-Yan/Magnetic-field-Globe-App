//
//  ParticleMeshGenerator+Util.swift
//  ParticleSimulatorApp
//
//  Created by DY on 3/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

struct CoefficientBuffers {
    var entryBuffer: MTLBuffer
    var indexBuffer: MTLBuffer
    var timeBuffer: MTLBuffer
    var modelBufferLength: Int
}

extension ParticleMeshGenerator {

    /// Function for initialising coefficient buffers and magnetic model buffer
    static func createModelBuffers(
        modelCoefficients: [String],
        metalDevice: MTLDevice?
    ) -> (CoefficientBuffers, MTLBuffer) {

        var (modelIndices, modelCoefficients, dateTime):
            ([SIMD2<Float>], [SIMD4<Float>], SIMD4<Float>) =
                Self.createModelCoefficientArray(
                    modelCoefficients: modelCoefficients
                )

        // Safely unwrap metalDevice and create buffer
        guard let metalDevice = metalDevice,
            let coefficientsBuffer = metalDevice.makeBuffer(
                bytes: modelCoefficients,
                length: modelCoefficients.count
                    * MemoryLayout<SIMD4<Float>>.stride,
                options: .storageModeShared
            ),
            let coefficientsBufferIndices = metalDevice.makeBuffer(
                bytes: modelIndices,
                length: modelIndices.count * MemoryLayout<SIMD2<Float>>.stride,
                options: .storageModeShared
            ),
            let coefficientTimeBuffer = metalDevice.makeBuffer(
                bytes: &dateTime,
                length: MemoryLayout<SIMD4<Float>>.stride,
                options: .storageModeShared
            ),
            let magneticModelBuffer = metalDevice.makeBuffer(
                length: MemoryLayout<MagneticFieldModel>.stride,
                options: .storageModeShared  // shared so CPU can read it back
            )
        else {
            fatalError("Failed to create magnetic model coefficient buffer")
        }

        let metalCoefficients = CoefficientBuffers(
            entryBuffer: coefficientsBuffer,
            indexBuffer: coefficientsBufferIndices,
            timeBuffer: coefficientTimeBuffer,
            modelBufferLength: modelCoefficients.count
        )
        return (metalCoefficients, magneticModelBuffer)

    }

    /// Parses coefficient string into index, entry and date time arrays
    static func createModelCoefficientArray(modelCoefficients: [String]) -> (
        [SIMD2<Float>], [SIMD4<Float>], SIMD4<Float>
    ) {

        // Coefficient index array
        var coeffIndexSIMD: [SIMD2<Float>] = []

        // Coefficient entry array
        var coeffFloatArray: [SIMD4<Float>] = []

        // Date time index array
        var dateTime: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 0)

        // Iterate through rows
        for (rowIndex, row) in modelCoefficients.enumerated() {
            if rowIndex == 0 {
                parseTimeRow(row: row, outputTimeArray: &dateTime)
            } else {
                parseModelRow(
                    row: row,
                    outputIndexArray: &coeffIndexSIMD,
                    outputModelEntryArray: &coeffFloatArray
                )
            }
        }
        return (coeffIndexSIMD, coeffFloatArray, dateTime)
    }

    private static func parseTimeRow(
        row: String,
        outputTimeArray: inout SIMD4<Float>
    ) {
        let components = row.components(separatedBy: " ").filter { !$0.isEmpty }
        var tempArray: [Float] = []

        // Parse model time row
        for (colIndex, e) in components.enumerated() {
            switch colIndex {
            case 0:
                // Model Year
                parseEntry(entry: e, outputArray: &tempArray)
            case 1:
                // Model Name
                continue
            case 2:
                // Model start time
                parseDateTime(entry: e, outputArray: &tempArray)
            default:
                continue
            }
        }

        outputTimeArray = SIMD4<Float>(
            tempArray[0],
            tempArray[1],
            tempArray[2],
            tempArray[3]
        )
    }

    private static func parseDateTime(entry: String, outputArray: inout [Float])
    {
        let components = entry.components(separatedBy: "/").filter {
            !$0.isEmpty
        }

        // Parse Date Time Entry
        for (_, e) in components.enumerated() {
            parseEntry(entry: e, outputArray: &outputArray)
        }
    }

    private static func parseModelRow(
        row: String,
        outputIndexArray: inout [SIMD2<Float>],
        outputModelEntryArray: inout [SIMD4<Float>]
    ) {
        var tempIndexArray: [Float] = []
        var tempModelEntriesArray: [Float] = []
        let components = row.components(separatedBy: " ").filter { !$0.isEmpty }
        for (colIndex, e) in components.enumerated() {
            if colIndex <= 1 {
                parseEntry(entry: e, outputArray: &tempIndexArray)
            } else {
                parseEntry(entry: e, outputArray: &tempModelEntriesArray)
            }
        }
        outputIndexArray.append(
            SIMD2<Float>(tempIndexArray[0], tempIndexArray[1])
        )
        outputModelEntryArray.append(
            SIMD4<Float>(
                tempModelEntriesArray[0],
                tempModelEntriesArray[1],
                tempModelEntriesArray[2],
                tempModelEntriesArray[3]
            )
        )

    }

    private static func parseEntry(entry: String, outputArray: inout [Float]) {
        if let floatEntry = Float(entry) {
            outputArray.append(floatEntry)
        }
    }
}
