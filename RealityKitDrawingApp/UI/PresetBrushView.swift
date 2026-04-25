/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view to display a preview of a brush preset, and a view to display a collection of these presets.
*/

import SwiftUI
import RealityKit
import RealityKitContent

struct PresetBrushView: View {
    /// The current state of the brush.
    @Binding var brushState: BrushState
    
    /// Settings of a given preset.
    let preset: BrushPreset

    /// Function to represent deleting a preset.
    let deleteAction: () -> Void
    
    /// Whether the delete button is visible.
    @State var isDeletePopoverPresented: Bool = false
    
    /// The brush entity.
    private let entity = Entity()
    
    var body: some View {
        RealityView { content in
            SparkleBrushSystem.registerSystem()
            
            entity.name = "Brush Preset"
            content.add(entity)
            
            let simulatedBounds: Float = 1.0
            let entityScale: Float = 0.5

            let selectionShape = ShapeResource.generateBox(size: SIMD3<Float>(repeating: simulatedBounds))
            
            let shaderInputs = HoverEffectComponent.ShaderHoverEffectInputs.default
            let hoverEffect = HoverEffectComponent.HoverEffect.shader(shaderInputs)
            let hoverEffectComponent = HoverEffectComponent(hoverEffect)
            
            let inputTargetComponent = InputTargetComponent()
            let collisionComponent = CollisionComponent(shapes: [selectionShape], isStatic: true)

            entity.components.set([hoverEffectComponent, inputTargetComponent, collisionComponent])
            
            let presetBrushState = BrushState(preset: preset)
            
            var sparkleMaterial = try? await ShaderGraphMaterial(named: "/Root/SparklePresetBrushMaterial",
                                                                 from: "PresetBrushMaterial",
                                                                 in: realityKitContentBundle)
            sparkleMaterial?.writesDepth = false
            try? sparkleMaterial?.setParameter(name: "ParticleUVScale", value: .float(8))
            
            var source = await DrawingSource(rootEntity: entity, sparkleMaterial: sparkleMaterial)
            
            let sample = PresetBrushStroke.sample
            let brushTip = sample * simulatedBounds
            source.receiveSynthetic(position: brushTip,
                                    speed: presetBrushState.sparkleStyleSettings.initialSpeed,
                                    state: presetBrushState)
            
            // As generated the stroke fills a 1 x 1 x 1 meter box. Scale down the entity to fit.
            entity.scale = SIMD3<Float>(repeating: entityScale)
        }
            .frame(depth: 0)
    }
}


struct PresetBrushSelectorView: View {
    
    private static let defaultPresets: [BrushPreset] = [
        //        .solid(settings: .init(thicknessType: .calligraphic())),
        //        .solid(settings: .init(thicknessType: .uniform)),
        .sparkle(settings: .init())
    ]
    
    private struct BrushPresetEntry: Identifiable {
            let id: UUID = UUID()
            var preset: BrushPreset
    }
    
    @Binding var brushState: BrushState
    
    @State private var presets: [BrushPresetEntry] = defaultPresets.map { BrushPresetEntry(preset: $0) }
    
    var body: some View {
        ForEach($presets) { presetEntry in
            PresetBrushView(brushState: $brushState,
                            preset: presetEntry.preset.wrappedValue,
                            deleteAction: {
                withAnimation {
                    presets.removeAll(where: { $0.id == presetEntry.id })
                }
            })
        }
    }
}
