//
//  ParticleSystemPoint.swift
//  ParticleSimulatorApp
//
//  Created by DY on 13/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

/// `ParticleSystemPoints` are emitted by the `ParticlePointerSpawner` and consumed/ meshed by the `ParticleMeshGenerator`.
struct ParticleSystemPoint {
    /// Spawn Centre of this point.
    var centre: SIMD3<Float>
    
    /// Size of particles emitted from this point.
    var size: Float
    
    /// Color of particles emitted from this point.
    var color: SIMD3<Float>
    
    var coordSpace: CoordSpace = CoordSpace(
        northVector: SIMD3<Float>(repeating: 0.0).packed3,
        eastVector:  SIMD3<Float>(repeating: 0.0).packed3,
        verticalVector: SIMD3<Float>(repeating: 0.0).packed3,
    )
    
    init(centre: SIMD3<Float>, size: Float, color: SIMD3<Float>) {
        self.centre = centre
        self.size = size
        self.color = color
    }
    
    func convertToMetalStruct(spawnPosition: SIMD3<Float>) -> ParticleAttributes{
        
        // Attributes used for rendering
        let polarPosition = spawnPosition.toGeographic()
        let particleAttributes = ParticlePointAttributes(
            position: spawnPosition.packed3,
            polarCoordinate: polarPosition.packed3,
            color: SIMD3<Float16>(color).packed3,
            size: size,
        )
        
        // Trail buffers stored per particle
        let particleTrailBuffers = ParticleTrailBuffers()

        // Overall particle attributes struct
        return ParticleAttributes(
            attributes: particleAttributes,
            trailBuffers: particleTrailBuffers,
            velocity: SIMD3<Float>(repeating: 0.0).packed3,
            centre: centre.packed3,
            coordSpace: coordSpace,
            age: 0,
            particleIdx: 0,
        )
    }
}

/// Interpolate between two `ParticleSystemPoints` by the blend value `blend`.
///
/// - Parameters:
///   - point0: The first point to interpolate, corresponding with `blend == 0`.
///   - point1: The second point to interpolate, corresponding with `blend == 1`.
///   - blend: The blend of the interpolation, typically ranging from 0 to 1.
func mix(_ point0: ParticleSystemPoint, _ point1: ParticleSystemPoint, t blend: Float) -> ParticleSystemPoint {
    return ParticleSystemPoint(centre: mix(point0.centre, point1.centre, t: blend),
                               size: mix(point0.size, point1.size, t: blend),
                               color: mix(point0.color, point1.color, t: blend))
}

/// Spawns `ParticleSystemPoints` with some initial speed, size and colour, spawns them at a specified location
struct ParticlePointSpawner {
    
    var size: Float = AppConstants.Particle.size
    var color: SIMD3<Float> = [1, 1, 1]
    
    func createParticle(position: SIMD3<Float>) -> ParticleSystemPoint {
        return ParticleSystemPoint(centre: position,
                                   size: self.size,
                                   color: self.color)
    }
}
