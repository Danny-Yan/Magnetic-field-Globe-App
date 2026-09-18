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
            
            HStack {
                Text("Force multiplier")
                sliderWithNumbersShown(value: $settings.forceMultipler, in: 0.00...20.00)
            }

            // TODO: FIX SO THIS WORKS
            HStack {
                Text("Particle Size")
                sliderWithNumbersShown(value: $settings.particleSize, in: 0.000_15...0.00_35)
            }
            
            HStack {
                Text("Bounding Box Size")
                sliderWithNumbersShown(value: $settings.boundingBoxSize, in: 1.000...10.00)
            }
            
            Spacer()
            
            Divider()
                .padding(.horizontal, 20)
            
            LayerToggleUI(settings: $settings)
        }
    }
}
