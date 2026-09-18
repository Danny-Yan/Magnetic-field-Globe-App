//
//  ParticleSystemSettings.swift
//  ParticleSimulatorApp
//
//  Created by DY on 3/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

/// System settings for passing UI info to the particle system
///
/// Settings denoted with `s` prefix (short for `static configuration`)
/// should only be changed at compile time by restarting the system
struct ParticleSystemSettings {
    var particleLifeSpan: Float = AppConstants.Particle.lifeSpanSeconds.isFinite ? Float(AppConstants.Particle.lifeSpanSeconds) : -1
    var particleSize: Float = AppConstants.Particle.size
    var forceMultipler: Float = AppConstants.Sim.forceMultipler
    var timeOfSimulation: Date = createDateFromDMY()!
    var boundingBoxSize: Float = AppConstants.Particle.boundingBox.x
    
    // Static Config (Require restart to change)
    var sChosenVersion: MagneticModelVersion = AppConstants.Sim.chosenDataSet
    var sNumberOfParticles: Int = AppConstants.Spawn.maxSpawnCount
    
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
            particleSize: particleSize,
            southPoleSpawnCentre: southPoleCentre.packed3,
            particleBoundingBox: (SIMD3<Float>(1, 1, 1) * boundingBoxSize).packed3,
            particleLifeSpan: particleLifeSpan,
            deltaTime: deltaTime,
            forceMultiplier: forceMultipler,

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
