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
    
    var timeOfSimulation: Date = createDateFromDMY()!
    
    // Layer settings
    var chosenLayer: ParticleVisualisationLayer = AppConstants.Particle.Colour.defaultColourLayer
    
    struct NormalLayer{
        var normalColour: SIMD3<Float16> = AppConstants.Particle.Colour.maxColour
    }
    var normalLayer: NormalLayer = NormalLayer()
    
    struct HeatMapLayer{
        var minSpeed: Float = AppConstants.Particle.Colour.minSpeed
        var maxSpeed: Float = AppConstants.Particle.Colour.maxSpeed
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
        let normalLayer = SimulationNormalLayerParams(
            normalColour: normalLayer.normalColour.packed3
        )
        let heatMapLayer = SimulationHeatMapLayerParams(
            minSpeed: heatMapLayer.minSpeed,
            maxSpeed: heatMapLayer.maxSpeed,
            minColour: heatMapLayer.minColour.packed3,
            maxColour: heatMapLayer.maxColour.packed3
        )

        let parameters = ParticleSimulationParams(
            particleCount: UInt32(particleCount),
            southPoleSpawnCentre: southPoleCentre.packed3,
            particleBoundingBox: AppConstants.Particle.boundingBox.packed3,
            particleLifeSpan: particleLifeSpan,
            deltaTime: deltaTime,
            
            // TODO: SLOW
            yearFraction: createYearFractionFromDate(date: timeOfSimulation),
            
            chosenLayerEnum: chosenLayer,
            normalLayer: normalLayer,
            heatMapLayer: heatMapLayer,
        )
        
        return parameters
    }
}

// TODO: Hardcoded Array MAYBE MACRO????
extension ParticleVisualisationLayer: CaseIterable {
    public static var allCases: [ParticleVisualisationLayer] {
        return [.normalLayer, .heatMapLayer]
    }
}
