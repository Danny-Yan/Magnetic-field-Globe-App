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
    @Binding var settings: ParticleSystemSettings
    
    private let particleSpawner = ParticlePointSpawner()
    
    /// The particle system entity.
    private let particleSystemEntity = Entity()
    private var source: ParticleDrawingSource
    
    
    ///  Initalise particle providers and entity
    init(to content: RealityViewContent, withSettings: Binding<ParticleSystemSettings>) async {
        self._settings = withSettings
        
        source = await ParticleDrawingSource(rootEntity: particleSystemEntity, withSettings: withSettings)
        instantiateParticleSystemEntity(to: content)
        
        await addParticles(to: content)
    }
    
    internal func instantiateParticleSystemEntity (to content: RealityViewContent) {
        ParticleSimulatorSystem.registerSystem()
        
        particleSystemEntity.name = "Particle System"
        content.add(particleSystemEntity)
        
        let simulatedBounds: Float = AppConstants.Sim.simulatedBounds
        let entityScale: Float = AppConstants.Sim.entityScale

        let selectionShape = ShapeResource.generateBox(size: SIMD3<Float>(repeating: simulatedBounds))
        
        let shaderInputs = HoverEffectComponent.ShaderHoverEffectInputs.default
        let hoverEffect = HoverEffectComponent.HoverEffect.shader(shaderInputs)
        let hoverEffectComponent = HoverEffectComponent(hoverEffect)
        
        let inputTargetComponent = InputTargetComponent()
        let collisionComponent = CollisionComponent(shapes: [selectionShape], isStatic: true)

        particleSystemEntity.components.set([hoverEffectComponent, inputTargetComponent, collisionComponent])
        
        // As generated the stroke fills a 1 x 1 x 1 meter box. Scale down the entity to fit.
        particleSystemEntity.scale = SIMD3<Float>(repeating: entityScale)
    }
    
    internal func addParticles(to content: RealityViewContent) async {
        // Create Particle
        let spawnCentre = AppConstants.Spawn.centre * 2
        let particle = particleSpawner.createParticle(position: spawnCentre)
        
        // Load particle into rendering queue
        await source.drawParticleSystemPointSynthetic(point: particle)
    }
}
