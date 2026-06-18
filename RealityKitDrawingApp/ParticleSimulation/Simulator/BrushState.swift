/*
 BrushState.swift
 
 Abstract:
 App state to describe the current state of the brush.
 
 Created by: Danny Yan
 */

enum BrushPreset: Equatable {
    case particle(settings: ParticleStyleProvider.Settings)
}

enum BrushType: Hashable, Equatable, CaseIterable, Identifiable {
    case particle
    
    var id: Self { return self }
    
    var label: String {
        return "particle"
    }
}

@Observable
class BrushState {
    /// Type of brush being used.
    var brushType: BrushType = .particle

    /// Style settings for the particle brush type.
    var particleStyleSettings = ParticleStyleProvider.Settings()
    
    init() {}
    
    init(preset: BrushPreset) { apply(preset: preset) }
    
    var asPreset: BrushPreset {
        .particle(settings: particleStyleSettings)
    }
    
    func apply(preset: BrushPreset) {
        switch preset {
        case let .particle(settings):
            brushType = .particle
            particleStyleSettings = settings
        }
    }
}
