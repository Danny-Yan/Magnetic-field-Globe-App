/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Views that control the settings selection on the palette for each style of brush.
*/

import SwiftUI
import RealityKit
import Collections


struct ParticleSystemUI: View {
    
    @Binding var settings: ParticleSystemSettings
    @State var isDrawing: Bool = false
    @State var isSettingsPopoverPresented: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.title)
                    .padding()
            }
            
            Divider()
                .padding(.horizontal, 20)
            
            ParticleSystemSettingsUI(settings: $settings)
                .padding(.horizontal, 20)
            
            Spacer()
            
            Divider()
                .padding(.horizontal, 20)
        }
    }
}

struct ParticleSystemSettingsUI: View {
    @Binding var settings: ParticleSystemSettings

    var body: some View {
        VStack {
            
            // Chose Date Picker
            DatePicker("Select Date", selection: $settings.timeOfSimulation)
            
            // TODO: MAKE TOGGLE ACTUALLY HIDE/GREYOUT UNINTERACTABLE UI
            // Toggle Button
            Picker(selection: $settings.chosenLayer, label: EmptyView()) {
                
                // Hard coded array
                let activeLayerArray = ["Normal", "Heat Map"]
                let zippedUI = Array(zip(ParticleVisualisationLayer.allCases, activeLayerArray))
                    
                ForEach(zippedUI, id: \.0) { (layer, text) in
                    Text(text).tag(layer)
                }
                
            }
            .pickerStyle(.menu)
            
            // Normal Mode
            VStack{
                ColorPicker("Choose Colour", selection: Color.makeBinding(from: $settings.normalLayer.normalColour))
            }
            .disabled( !$settings.chosenLayer.valueEqual(.normalLayer) )

            // Heat Map Mode
            VStack{
                HStack {
                    Text("Max Colour Speed")
                    Slider(value: $settings.heatMapLayer.minSpeed, in: 0.000...50000.0)
                        .transaction { $0.animation = nil }
                }
                HStack {
                    Text("Max Colour Speed")
                    Slider(value: $settings.heatMapLayer.maxSpeed, in: 0.000...50000.0)
                        .transaction { $0.animation = nil }
                }
                ColorPicker("Min Colour", selection: Color.makeBinding(from: $settings.heatMapLayer.minColour))
                ColorPicker("Max Colour", selection: Color.makeBinding(from: $settings.heatMapLayer.maxColour))
                
            }
            .disabled( !$settings.chosenLayer.valueEqual(.heatMapLayer) )
            
            HStack {
                Text("Particle Size")
                Slider(value: $settings.particleSize, in: 0.000_15...0.00_35)
                    .transaction { $0.animation = nil }
            }
        }
    }
}
