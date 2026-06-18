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

struct ParticleSystemEntity {
    
    /// Settings of a given preset.
    let preset: BrushPreset
    
    /// The particle system entity.
    private let ParticleSystemEntity = Entity()
    
    private func instantiateParticleSystemEntity (to content: RealityViewContent) {
        ParticleBrushSystem.registerSystem()
        
        ParticleSystemEntity.name = "Brush Preset"
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
        
     func addParticles(to content: RealityViewContent) async {
        instantiateParticleSystemEntity(to: content)
         
        let presetBrushState = BrushState(preset: preset)
        
        var particleMaterial = try? await ShaderGraphMaterial(named: "/Root/SparklePresetBrushMaterial",
                                                             from: "PresetBrushMaterial",
                                                             in: realityKitContentBundle)
        particleMaterial?.writesDepth = false
        try? particleMaterial?.setParameter(name: "ParticleUVScale", value: .float(8))
        
        var source = await DrawingSource(rootEntity: ParticleSystemEntity, particleMaterial: particleMaterial)
        
        let spawnCentre = AppConstants.Spawn.centre * 2
         await source.receiveSynthetic(position: spawnCentre,
                                speed: presetBrushState.particleStyleSettings.initialSpeed,
                                state: presetBrushState)
    }
}
