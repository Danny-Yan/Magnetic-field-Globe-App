/*
 ParticlePoint.swift
 
 Abstract:
    A styled point to be passed to the `ParticleMeshGenerator`.
    A list of these defines the curve of a particle brush stroke.
 
 Created by: Danny yan
 */

/// `ParticlePoints` are emitted by the `ParticleStyleProvider` and consumed by the `ParticleMeshGenerator`.
///
/// These are the styled points on the curve of points to be meshed by the `ParticleMeshGenerator`.
struct ParticlePoint {
    /// Position of this point.
    var position: SIMD3<Float>
//    Add in new polar position struct
    var polarPosition: SIMD3<Float> = SIMD3<Float>(repeating: 0.0)
    
    
    /// Initial speed of particles emitted from this point.
    var initialSpeed: Float
    
    /// Size of particles emitted from this point.
    var size: Float
    
    /// Color of particles emitted from this point.
    var color: SIMD3<Float>
    
    init(position: SIMD3<Float>, initialSpeed: Float, size: Float, color: SIMD3<Float>) {
        self.position = position
        self.initialSpeed = initialSpeed
        self.size = size
        self.color = color
        self.polarPosition = convertToPolar(position: position)
    }
    
    private mutating func convertToPolar(position: SIMD3<Float>) -> SIMD3<Float>{
        return SIMD3<Float>(
            atan(position.x + position.y),
            sin(position.x),
            cos(position.z)
        )
    }
}

/// Interpolate between two `ParticlePoints` by the blend value `blend`.
///
/// - Parameters:
///   - point0: The first point to interpolate, corresponding with `blend == 0`.
///   - point1: The second point to interpolate, corresponding with `blend == 1`.
///   - blend: The blend of the interpolation, typically ranging from 0 to 1.
func mix(_ point0: ParticlePoint, _ point1: ParticlePoint, t blend: Float) -> ParticlePoint {
    return ParticlePoint(position: mix(point0.position, point1.position, t: blend),
                                  initialSpeed: mix(point0.initialSpeed, point1.initialSpeed, t: blend),
                                  size: mix(point0.size, point1.size, t: blend),
                                  color: mix(point0.color, point1.color, t: blend))
}
