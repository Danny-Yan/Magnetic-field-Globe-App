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
    
    /// Converts `ParticleSystemPoint` to `ParticleAttributes` metal struct
    func convertToMetalStruct(spawnPosition: SIMD3<Float>) -> ParticleAttributes{
        
        // Attributes used for rendering just particles to the screen
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
