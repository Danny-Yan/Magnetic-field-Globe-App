/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Various math functions to supplement built-in math.
*/

import Foundation
import simd
import SwiftUI

/// Call `MagneticFieldType(SIMD4<Float>)`
extension SIMD4 where Scalar: BinaryFloatingPoint {
    /// Extract the X, Y, and Z components of a SIMD4 as a SIMD3.
    var xyz: SIMD3<Scalar> { .init(Scalar(x), Scalar(y), Scalar(z)) }

    /// Convert to float array
    func toArray() -> [Scalar]{
        return [x, y, z, w]
    }
    
    func toColor() -> Color {
        Color(red: Double(x), green: Double(y), blue: Double(z), opacity: Double(w))
    }
}

extension SIMD3 where Scalar: BinaryFloatingPoint {
    /// Reinterpret a vectors X, Y, and Z components as red, green, and blue components of SwiftUI Color, respectively.
    func toColor() -> Color {
        Color(red: Double(x), green: Double(y), blue: Double(z))
    }
}

extension MTLPackedFloat3 {
    /// Convert a `MTLPackedFloat3` to a `SIMD3<Float>`.
    var simd3: SIMD3<Float> { return .init(x, y, z) }
   
    /// Convert to float array
    func toArray() -> [Float]{
        return [x, y, z]
    }
}

extension SIMD3 where Scalar == Float {
    /// Convert a `SIMD3<Float>` to a `MTLPackedFloat3`.
    var packed3: MTLPackedFloat3 { return .init(.init(elements: (x, y, z))) }
    
    /// Convert to float array
    func toArray() -> [Scalar]{
        return [x, y, z]
    }
    
    /// Convert spherical geographic (R, Lat, Lon) to cartesian (x, y, z)
    func toCartesian() -> SIMD3<Scalar>{
        let radius = x
        let lat = y
        let lon = z
        return SIMD3<Scalar>(
            radius * cos(lat) * cos(lon),
            radius * cos(lat) * sin(lon),
            radius * sin(lat)
        )
    }
   
    /// Convert cartesian (x, y, z) to spherical geographic (R, Lat, Lon)
    func toGeographic() -> SIMD3<Scalar>{
        let radius = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
        let lat = asin(z / radius)
        let lon = atan2(y, x)
        
        return SIMD3<Scalar>(radius, lat, lon)
    }
    
    /// Finds the size of the vector
    func magnitude() -> Scalar{
        return sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
}

extension SIMD3 where Scalar == Float16 {
    /// Convert a `SIMD3<Float16>` to a `packed_half3`.
    var packed3: packed_half3 { return .init(x: x, y: y, z: z) }
    
    var toFloat: SIMD3<Float>{
        return .init(Float(x), Float(y), Float(z))
    }
    
    /// Convert to float array
    func toArray() -> [Scalar]{
        return [x, y, z]
    }
}

extension packed_half3 {
    /// Convert a `packed_half3` to a `SIMD3<Float>`.
    var simd: SIMD3<Float16> {
        return .init(x, y, z)
    }
}

extension packed_half4 {
    /// Convert a `packed_half4` to a `SIMD4<Float>`.
    var simd: SIMD4<Float16> {
        return .init(x, y, z, w)
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
    /// Determines if elements of two arrays are equal given a certain tolerance
    func elementsEqual(_ other: [Element], tolerance: Element) -> Bool {
        guard self.count == other.count else { return false }
        return self.elementsEqual(other) { abs($0 - $1) <= tolerance }
    }
}

extension Binding where Value: Equatable {
    /// Equates a binding value with a regular value
    static func ==(a: Binding<Value>, other: Value) -> Bool {
        return a.wrappedValue == other
    }
}

extension Binding {
    
    /// Converts between bindings of integer and floats, used primarily for swift UI slider conversions
    static func convert<TInt, TFloat>(_ intBinding: Binding<TInt>) -> Binding<TFloat>
    where TInt:   BinaryInteger,
          TFloat: BinaryFloatingPoint{

        Binding<TFloat> (
            get: { TFloat(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = TInt($0) }
        )
    }

    static func convert<TFloat, TInt>(_ floatBinding: Binding<TFloat>) -> Binding<TInt>
    where TFloat: BinaryFloatingPoint,
          TInt:   BinaryInteger {

        Binding<TInt> (
            get: { TInt(floatBinding.wrappedValue) },
            set: { floatBinding.wrappedValue = TFloat($0) }
        )
    }
}

/// Returns true if `value0` and `value1` are equal within the tolerance `epsilon`.
func approximatelyEqual(_ value0: Float, _ value1: Float, epsilon: Float = 0.000_001) -> Bool {
    return abs(value0 - value1) <= epsilon
}

/// Returns true if `point0` and `point1` are equal within the tolerance `epsilon`.
func approximatelyEqual(_ point0: SIMD3<Float>, _ point1: SIMD3<Float>, epsilon: Float = 0.000_001) -> Bool {
    return distance(point0, point1) <= epsilon
}

/// Returns a uniformly random position within a sphere of radius 1
func randomUniformDistributeSphere() -> SIMD3<Float> {
    // Use rejection sampling to guarantee a uniform probability
    while true {
        let randomVector = SIMD3<Float>(Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -1...1))
        let randomVectorLength = length(randomVector)
        if randomVectorLength > 1e-8 && randomVectorLength < 1 {
            return randomVector
        }
    }
}

/// Returns a uniformly random position within a 1x1x1 cube
func randomUniformDistributeCube() -> SIMD3<Float> {
    let randomVector = SIMD3<Float>(Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -1...1))
    return randomVector
}

// BELOW FUNCTIONS ONLY USED IN SPLASH SCREEN

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

