/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
App state to describe the current state of the brush.
*/

enum BrushPreset: Equatable {
    case particle(settings: particleBrushStyleProvider.Settings)
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
    var particleStyleSettings = particleBrushStyleProvider.Settings()
    
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
