//
//  TempMagFieldUtilities.swift
//  ParticleSimulatorApp
//
//  Created by DY on 17/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Foundation
import simd
import SwiftUI

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

/// Utility function to compactly create both a buffer and its associated buffer pointer
 func createBufferAndPointer<T>(metalDevice: MTLDevice?, of type: T.Type) async throws -> (MTLBuffer, UnsafeMutablePointer<T>) {
    
    var buffer = try await createSingleTypeBuffer(metalDevice: metalDevice, of: T.self)
    var pointer = createSingleTypeBufPointer(buf: &buffer, of: T.self)
    
    return (buffer, pointer)
}

/// Runs a GPU function a single time
 func singleGPUCall(metalDevice mtlDevice: MTLDevice?, gpuFunction: (_ encoder: MTLComputeCommandEncoder, _ commandBuffer: MTLCommandBuffer) -> Void) async throws {
    
    guard let queue = mtlDevice?.makeCommandQueue(),
          let commandBuffer = queue.makeCommandBuffer(),
          let encoder = commandBuffer.makeComputeCommandEncoder()
            else {
        fatalError("Failed to create command buffer/encoder for test dispatch")
    }
    
    gpuFunction(encoder, commandBuffer)
    
    encoder.endEncoding()
    commandBuffer.commit()
    await commandBuffer.completed()
}

/// Converts geographic  (lR, lat, lon) from degrees to radians
 func convertGeographicDegToRad(alt: Double, lat: Double, lon: Double) -> SIMD3<Float>{
    // Conversion radians
    let trueAlt = Float(alt)
    
    let radLat = Float(lat * .pi / 180)
    let radLon = Float(lon * .pi / 180)
    
    // convert to polar
    let testPolarCoord = SIMD3<Float>(trueAlt, radLat, radLon)
    
    print("Alt, RadLat, RadLon: \(trueAlt), \(radLat), \(radLon)")
    return testPolarCoord
}


 /// Returns true if `value0` and `value1` are equal within the tolerance `epsilon`.
     func approximatelyEqual(_ value0: Float, _ value1: Float, epsilon: Float = 0.000_001) -> Bool {
        return abs(value0 - value1) <= epsilon
    }
    
    /// Returns true if `point0` and `point1` are equal within the tolerance `epsilon`.
     func approximatelyEqual(_ point0: SIMD3<Float>, _ point1: SIMD3<Float>, epsilon: Float = 0.000_001) -> Bool {
        return distance(point0, point1) <= epsilon
    }
    
    /// Returns a rotation matrix that maps the vector `[0, 0, 1]` to `forward`.
    ///
    /// The matrix is guaranteed to be ortho-normal (so, all columns are unit length and orthogonal).
    ///
    /// - Parameters:
    ///   - forward: The returned matrix will map `[0, 0, 1]` to this value.  Behavior is undefined if this is `[0, 0, 0]`.
    ///   - desiredUp: The returned matrix is chosen such that it maps `[0, 1, 0]` to `desiredUp` as closely as
    ///         possible. Note that if `forward` and `desiredUp` are not perpendicular, the actual mapping may differ.
     func orthonormalFrame(forward: SIMD3<Float> = [0, 0, 1], up desiredUp: SIMD3<Float> = [0, 1, 0]) -> simd_float3x3 {
        assert(all(isnan(forward) .== 0), "forward vector contains NaN")
        assert(all(isnan(desiredUp) .== 0), "up vector contains NaN")
        
        // Detect if either of the input values contains zero, and fall back to cardinal directions if so.
        let desiredUp = approximatelyEqual(desiredUp, .zero) ? [0, 1, 0] : desiredUp
        let forward = approximatelyEqual(forward, .zero) ? [0, 0, 1] : forward
        
        // Normalize `forward`.
        let forwardLen = length(forward)
        let forwardNorm = forward / forwardLen
        
        // Attempt to find a vector perpendicular to both forwardNorm and `desiredUp`.
        var right = cross(forwardNorm, desiredUp)
        
        // Determine if `right` has zero length. This happens when `forward` and `desiredUp` are parallel/antiparallel.
        var rightLength = length(right)
        if rightLength < 0.01 {
            right = cross(forwardNorm, SIMD3<Float>(0, 0, 1))
            rightLength = length(right)
        }
        
        // If `right` still has zero length then `forward` is parallel to `desiredUp` and `[0, 0, 1]`.
        if rightLength < 0.01 {
            right = cross(forwardNorm, SIMD3<Float>(1, 0, 0))
            rightLength = length(right)
        }
        
        // It is guaranteed mathematically that `right` has nonzero length at this point.
        right /= rightLength
        
        // Compute the final up vector as perpendicular to `right` and `forward`.
        // Guaranteed to be normalized as `right` and `forwardNorm` are both normalized and orthogonal.
        let finalUp = cross(right, forwardNorm)
        return simd_float3x3(columns: (-right, finalUp, forwardNorm))
    }
    
    /// Creates a 2D circle polyline centered at the origin. Points are listed in counter-clockwise order.
    ///
    /// - Parameters:
    ///   - radius: Radius of the circle.
    ///   - segmentCount: The number of segments to use for the circle.
     func makeCircle(radius: Float, segmentCount: Int) -> [SIMD2<Float>] {
        var circle: [SIMD2<Float>] = []
        circle.reserveCapacity(segmentCount)
        
        for segmentIndex in 0..<segmentCount {
            let radians = 2 * Float.pi * (Float(segmentIndex) / Float(segmentCount))
            circle.append(SIMD2<Float>(cos(radians), sin(radians)) * radius)
        }
        
        return circle
    }
    
    /// Returns a uniformly random direction, in other words a random point on a sphere with radius 1.
     func randomDirection() -> SIMD3<Float> {
        // Use rejection sampling to guarantee a uniform probability over all directions.
        while true {
            let randomVector = SIMD3<Float>(Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -1...1))
            let randomVectorLength = length(randomVector)
            if randomVectorLength > 1e-8 && randomVectorLength < 1 {
                return randomVector / randomVectorLength
            }
        }
    }
    
    /// Returns a uniformly random position within a sphere of radius 1
     func randomUniformDistribute() -> SIMD3<Float> {
        // Use rejection sampling to guarantee a uniform probability
        while true {
            let randomVector = SIMD3<Float>(Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -1...1))
            let randomVectorLength = length(randomVector)
            if randomVectorLength > 1e-8 && randomVectorLength < 1 {
                return randomVector
            }
        }
    }
    
    /// Linearly interpolates between `value0` and `value1` based on the parameter `parameter`.
    ///
    /// `parameter = 0` corresponds with `value0` and `parameter = 1` corresponds with `value1`.
     func mix(_ value0: Float, _ value1: Float, t parameter: Float) -> Float {
        return value0 + (value1 - value0) * parameter
    }
    
    /// Clamps `value` to be at least `min` and at most `max`.
     func clamp(_ value: Float, min: Float, max: Float) -> Float {
        return Float.minimum(Float.maximum(value, min), max)
    }
    
    /// Applies a smoothing function to `value` such that `edge0` maps to 0, `edge1` maps to 1, and an easing curve
    /// is applied to values in between.
     func smoothstep (_ value: Float, minEdge edge0: Float, maxEdge edge1: Float) -> Float {
        // Scale, and clamp x to 0..1 range.
        let value = clamp((value - edge0) / (edge1 - edge0), min: 0.0, max: 1.0)
        return value * value * (3.0 - 2.0 * value)
     }

extension SIMD4<Float> {
    /// Extract the X, Y, and Z components of a SIMD4 as a SIMD3.
    var xyz: SIMD3<Float> { .init(x, y, z) }
    
    func toColor() -> Color {
        Color(red: Double(x), green: Double(y), blue: Double(z), opacity: Double(w))
    }
}


extension SIMD3<Float> {
    /// Reinterpret a vectors X, Y, and Z components as red, green, and blue components of SwiftUI Color, respectively.
    func toColor() -> Color {
        Color(red: Double(x), green: Double(y), blue: Double(z))
    }
}

extension SIMD3<Float16> {
    /// Reinterpret a vectors X, Y, and Z components as red, green, and blue components of SwiftUI Color, respectively.
    func toColor() -> Color {
        Color(red: Double(x), green: Double(y), blue: Double(z))
    }
}

extension [Float] {
    static func /(lhs: [Float], rhs: [Float]) -> [Float] {
        return zip(lhs, rhs).map{ $0 / $1 }
    }
}

extension Color {
    /// Converts a vector binding into a color binding.  The X, Y, and Z components of the vector correspond with the
    /// red, green and blue channels of the color, respectively.
    static func makeBinding(from simdBinding: Binding<SIMD3<Float>>) -> Binding<Color> {
        return Binding<Color>(get: { simdBinding.wrappedValue.toColor() },
                              set: { simdBinding.wrappedValue = $0.toSIMD() })
    }
    
    static func makeBinding(from simdBinding: Binding<SIMD4<Float>>) -> Binding<Color> {
        return Binding<Color>(get: { simdBinding.wrappedValue.toColor() },
                              set: { simdBinding.wrappedValue = $0.toSIMD() })
    }
    
    static func makeBinding(from simdBinding: Binding<SIMD3<Float16>>) -> Binding<Color> {
        return Binding<Color>(get: { simdBinding.wrappedValue.toColor() },
                              set: { simdBinding.wrappedValue = $0.toSIMD() })
    }
    
    /// Converts a SwiftUI Color to a vector, such that red, green, and blue maps to X, Y, and Z, respectively.
    func toSIMD(in environment: EnvironmentValues = EnvironmentValues()) -> SIMD3<Float> {
        let resolved = resolve(in: environment)
        return .init(x: resolved.red, y: resolved.green, z: resolved.blue)
    }
    
    func toSIMD(in environment: EnvironmentValues = EnvironmentValues()) -> SIMD4<Float> {
        let resolved = resolve(in: environment)
        return .init(x: resolved.red, y: resolved.green, z: resolved.blue, w: resolved.opacity)
    }
    
    func toSIMD(in environment: EnvironmentValues = EnvironmentValues()) -> SIMD3<Float16> {
        let resolved = resolve(in: environment)
        return .init(x: Float16(resolved.red),
                     y: Float16(resolved.green),
                     z: Float16(resolved.blue)
        )
    }
}

extension Array where Element: FloatingPoint {
    func elementsEqual(_ other: [Element], tolerance: Element) -> Bool {
        guard self.count == other.count else { return false }
        return self.elementsEqual(other) { abs($0 - $1) <= tolerance }
    }
}

/// Equates a binding value with a regular value
extension Binding where Value: Equatable {
    static func ==(a: Binding<Value>, other: Value) -> Bool {
        return a.wrappedValue == other
    }
}
