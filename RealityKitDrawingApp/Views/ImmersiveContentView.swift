/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view to display a preview of a brush preset, and a view to display a collection of these presets.
*/

import SwiftUI
import RealityKit
import RealityKitContent

import MetalKit
import os

struct ImmersiveContentView: View {
    /// The current state of the brush.
    @Binding var brushState: BrushState
    
    /// Settings of a given preset.
    let preset: BrushPreset
    
    /// Function to represent deleting a preset.
    let deleteAction: () -> Void
    
    var body: some View {
        RealityView { content in
            
            let particleSystemEntity = ParticleSystemEntity(preset: preset)
            let globeEntity = GlobeEntity()
            
            do{
                try await globeEntity.addEarthGeometry(to: content)
            } catch {
                print("Unable to load earth geometry")
            }
            
            await particleSystemEntity.addParticles(to: content)
        }
            .frame(depth: 0)
    }
}


struct ImmersiveContentViewMemoryManager: View {
    
    private static let defaultPresets: [BrushPreset] = [
        .particle(settings: .init())
    ]
    
    private struct BrushPresetEntry: Identifiable {
            let id: UUID = UUID()
            var preset: BrushPreset
    }
    
    @Binding var brushState: BrushState
    
    @State private var presets: [BrushPresetEntry] = defaultPresets.map { BrushPresetEntry(preset: $0) }
    
    var body: some View {
        ForEach($presets) { presetEntry in
            ImmersiveContentView(brushState: $brushState,
                            preset: presetEntry.preset.wrappedValue,
                            deleteAction: {
                withAnimation {
                    presets.removeAll(where: { $0.id == presetEntry.id })
                }
            })
        }
    }
}
