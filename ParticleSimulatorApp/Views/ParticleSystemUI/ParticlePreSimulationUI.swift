//
//  ParticlePreSimulationUI.swift
//  ParticleSimulatorApp
//
//  Created by DY on 15/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

/// UI that is shown before the simulation starts
struct ParticlePreSimulationUI: View {
    
    @Binding var settings: ParticleSystemSettings
    @Environment(\.setMode) var setMode
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Pre Simulation Settings")
                    .font(.title)
                    .padding()
            }
            
            // Toggle Button
            Picker(selection: $settings.sChosenVersion, label: EmptyView()) {
                let textArray = ["WMM2020", "WMM2025"]
                let zippedUI = Array(zip(MagneticModelVersion.allCases, textArray))
                
                ForEach(zippedUI, id: \.0) { (layer, text) in
                    Text(text).tag(layer)
                }
            }
            
            VStack {
                Text("Number of Particles")
                    .padding(.bottom, 10)
                sliderWithNumbersShown(value: .convert($settings.sNumberOfParticles),
                       in: 1.00...100000.00,
                       step: 1.0)
            }
            .padding(.vertical, 10)

            Button {
                Task {
                    await setMode(.drawing)
                    print("Done!")
                }
            } label: {
                Text("Run Simulation").frame(minWidth: 150)
            }
            .controlSize(.extraLarge)
        }
    }
}

