//
//  ParticleSystemSettings.swift
//  ParticleSimulatorApp
//
//  Created by DY on 3/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

/// System settings for passing UI info to the particle system
struct ParticleSystemSettings {
    var particleLifeSpan: Float = AppConstants.Particle.lifeSpanSeconds.isFinite ? Float(AppConstants.Particle.lifeSpanSeconds) : -1
    var particleSize: Float = AppConstants.Particle.size
    
    // Layer settings
    var chosenLayer: ParticleVisualisationLayer = .normalLayer
    
    struct NormalLayer{
        var colour: SIMD3<Float16> = AppConstants.Particle.Colour.maxColour
    }
    var normalLayer: NormalLayer = NormalLayer()
    
    struct HeatMapLayer{
        var maxSpeedColour: Float = AppConstants.Particle.Colour.maxSpeedColour
        var minColour: SIMD3<Float16> = AppConstants.Particle.Colour.minColour
        var maxColour: SIMD3<Float16> = AppConstants.Particle.Colour.maxColour
    }
    var heatMapLayer: HeatMapLayer = HeatMapLayer()
   
    /// Function to convert type ParticleSystemSettings to ParticleSimulationParams struct
    func convertToMetalStruct(
        particleCount: Int,
        deltaTime: Float,
        southPoleCentre: SIMD3<Float>
    ) -> ParticleSimulationParams {
        
        var normalLayer = SimulationNormalLayerParams(
            colour: normalLayer.colour.packed3
        )
        var heatMapLayer = SimulationHeatMapLayerParams(
            maxSpeedColour: heatMapLayer.maxSpeedColour,
            minColour: heatMapLayer.minColour.packed3,
            maxColour: heatMapLayer.maxColour.packed3
        )

        let parameters = ParticleSimulationParams(
            particleCount: UInt32(particleCount),
            southPoleSpawnCentre: southPoleCentre.packed3,
            particleBoundingBox: AppConstants.Particle.boundingBox.packed3,
            particleLifeSpan: particleLifeSpan,
            deltaTime: deltaTime,
            
            chosenLayerEnum: chosenLayer,
            normalLayer: normalLayer,
            heatMapLayer: heatMapLayer,
        )
        
        return parameters
    }
}

// TODO: Point of expansion for enum (MetalFunctions.h, ParticleSystemSettings.h) MAYBE MACRO????
extension ParticleVisualisationLayer: CaseIterable {
    public static var allCases: [ParticleVisualisationLayer] {
        return [.normalLayer, .heatMapLayer]
    }
}
