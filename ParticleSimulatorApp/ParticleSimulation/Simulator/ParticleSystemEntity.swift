//
//  ParticleSystemEntity.swift
//  ParticleSimulatorApp
//
//  Created by DY on 26/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import SwiftUI
import RealityKit
import RealityKitContent

import MetalKit
import os


/// `ParticleSystemEntity` describes the  entire particle system
struct ParticleSystemEntity {
    /// The particle system entity.
    private let ParticleSystemEntity = Entity()
    
    private let particleProvider = ParticleSettingProvider(
        initialSpeed: AppConstants.Particle.initialSpeed,
        size: AppConstants.Particle.size,
        color: AppConstants.Particle.color,
    )
    
    private func instantiateParticleSystemEntity (to content: RealityViewContent) {
        ParticleBrushSystem.registerSystem()
        
        ParticleSystemEntity.name = "Particle System"
        content.add(ParticleSystemEntity)
        
        let simulatedBounds: Float = AppConstants.Sim.simulatedBounds
        let entityScale: Float = AppConstants.Sim.entityScale

        let selectionShape = ShapeResource.generateBox(size: SIMD3<Float>(repeating: simulatedBounds))
        
        let shaderInputs = HoverEffectComponent.ShaderHoverEffectInputs.default
        let hoverEffect = HoverEffectComponent.HoverEffect.shader(shaderInputs)
        let hoverEffectComponent = HoverEffectComponent(hoverEffect)
        
        let inputTargetComponent = InputTargetComponent()
        let collisionComponent = CollisionComponent(shapes: [selectionShape], isStatic: true)

        ParticleSystemEntity.components.set([hoverEffectComponent, inputTargetComponent, collisionComponent])
        
        // As generated the stroke fills a 1 x 1 x 1 meter box. Scale down the entity to fit.
        ParticleSystemEntity.scale = SIMD3<Float>(repeating: entityScale)
    }
    private func instantiateParticleMaterial(to content: RealityViewContent) async -> ShaderGraphMaterial? {
        var particleMaterial = try? await ShaderGraphMaterial(named: "/Root/SparklePresetBrushMaterial",
                                                             from: "PresetBrushMaterial",
                                                             in: realityKitContentBundle)
        particleMaterial?.writesDepth = false
        try? particleMaterial?.setParameter(name: "ParticleUVScale", value: .float(8))
        return particleMaterial
    }
    
    
    func addParticles(to content: RealityViewContent) async {
        // Initialise Particle
        instantiateParticleSystemEntity(to: content)
        let particleMaterial = await instantiateParticleMaterial(to: content)
        var source = await ParticleDrawingSource(rootEntity: ParticleSystemEntity, particleMaterial: particleMaterial)
        
        // Create Particle
        let spawnCentre = AppConstants.Spawn.centre * 2
        let particlePoint = particleProvider.createParticle(position: spawnCentre)
        await source.drawParticlePointSynthetic(point: particlePoint)
    }
}

/// `ParticlePoints` are emitted by the `ParticleSettingProvider` and consumed by the `ParticleMeshGenerator`.
///
/// These are the styled points  to be meshed by the `ParticleMeshGenerator`.
struct ParticlePoint {
    /// Position of this point.
    var position: SIMD3<Float>
    
    /// Add in new polar position struct
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

struct ParticleSettingProvider {
    var initialSpeed: Float
    var size: Float
    var color: SIMD3<Float>
    
    func createParticle(position: SIMD3<Float>) -> ParticlePoint {
        return ParticlePoint(position: position,
                             initialSpeed: self.initialSpeed,
                                       size: self.size,
                                       color: self.color)
    }
}


