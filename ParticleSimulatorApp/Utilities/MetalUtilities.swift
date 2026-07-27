/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Utilities for interfacing with Metal.
*/

import Metal

/// A metal device to use throughout the app.
let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

/// Create a `MTLComputePipelineState` for a Metal compute kernel named `name`, using a default Metal device.
func makeComputePipeline(named name: String) -> MTLComputePipelineState? {
    if let metalDevice, let function = metalDevice.makeDefaultLibrary()?.makeFunction(name: name) {
        return try? metalDevice.makeComputePipelineState(function: function)
    } else {
        return nil
    }
}

extension MTLPackedFloat3 {
    /// Convert a `MTLPackedFloat3` to a `SIMD3<Float>`.
    var simd3: SIMD3<Float> { return .init(x, y, z) }
}

extension SIMD3 where Scalar == Float {
    /// Convert a `SIMD3<Float>` to a `MTLPackedFloat3`.
    var packed3: MTLPackedFloat3 { return .init(.init(elements: (x, y, z))) }
}

extension SIMD3 where Scalar == Float16 {
    /// Convert a `SIMD3<Float16>` to a `packed_half3`.
    var packed3: packed_half3 { return .init(x: x, y: y, z: z) }
}

/// Function for creating a buffer of a single type, non array type
func createSingleTypeBuffer<T>(metalDevice: MTLDevice?, of type: T.Type) async throws -> MTLBuffer {
    guard let metalDevice = metalDevice,
        let outputBuffer = metalDevice.makeBuffer(
            length: MemoryLayout<T>.stride,
            options: .storageModeShared  // shared so CPU can read it back
        )
    else {
        fatalError("Failed to create magnetic model coefficient buffer")
    }
    return outputBuffer
}

/// Creates a buffer pointer to an inputted pointer
func createSingleTypeBufPointer<T>(buf: inout MTLBuffer, of type: T.Type) -> UnsafeMutablePointer<T> {
    // Direct pointer access to the magneticModel struct
    var modelPointer: UnsafeMutablePointer<T>{
        buf.contents().bindMemory(
            to: type.self,
            capacity: 1
        )
    }
    
    return modelPointer
}


func createBufferAndPointer<T>(metalDevice: MTLDevice?, of type: T.Type) async throws -> (MTLBuffer, UnsafeMutablePointer<T>) {
    
    var buffer = try await createSingleTypeBuffer(metalDevice: metalDevice, of: T.self)
    var pointer = createSingleTypeBufPointer(buf: &buffer, of: T.self)
    
    return (buffer, pointer)
}

func singleGPUCall(metalDevice mtlDevice: MTLDevice?, gpuFunction: (_ encoder: MTLComputeCommandEncoder) -> Void) async throws {
    
    guard let queue = mtlDevice?.makeCommandQueue(),
          let commandBuffer = queue.makeCommandBuffer(),
          let encoder = commandBuffer.makeComputeCommandEncoder()
    else {
        fatalError("Failed to create command buffer/encoder for test dispatch")
    }

    gpuFunction(encoder)
    
    encoder.endEncoding()
    commandBuffer.commit()
    await commandBuffer.completed()
}

func convertGeographicToPolarCoords(alt: Double, lat: Double, lon: Double) -> SIMD3<Float>{
    // Conversion radians
    let trueAlt = Float(alt)
    
    let radLat = Float(lat * .pi / 180)
    let radLon = Float(lon * .pi / 180)
    
    // convert to polar
    let testPolarCoord = SIMD3<Float>(trueAlt, radLat, radLon)
    
    print("Alt, RadLat, RadLon: \(trueAlt), \(radLat), \(radLon)")
    return testPolarCoord
}

func convertPackedToFloat(array: MTLPackedFloat3)-> [Float]{
    return [array.x, array.y, array.z]
}
