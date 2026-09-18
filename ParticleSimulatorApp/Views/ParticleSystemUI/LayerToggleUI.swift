//
//  LayerToggleUI.swift
//  ParticleSimulatorApp
//
//  Created by DY on 15/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
import RealityKit
import Collections

struct LayerToggleUI: View {
    
    @Binding var settings: ParticleSystemSettings
    
    var body: some View {
        VStack {
            
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
            if ( $settings.chosenLayer == .normalLayer ){
                VStack{
                    ColorPicker("Choose Colour", selection: Color.makeBinding(from: $settings.normalLayer.normalColour))
                }
            }
            
            // Heat Map Mode
            if ( $settings.chosenLayer == .heatMapLayer ){
                VStack{
                    HStack {
                        Text("Max Colour Speed")
                        sliderWithNumbersShown(value: $settings.heatMapLayer.minSpeed, in: 0.000...50000.0)
                            .transaction { $0.animation = nil }
                    }
                    HStack {
                        Text("Max Colour Speed")
                        sliderWithNumbersShown(value: $settings.heatMapLayer.maxSpeed, in: 0.000...50000.0)
                            .transaction { $0.animation = nil }
                    }
                    ColorPicker("Min Colour", selection: Color.makeBinding(from: $settings.heatMapLayer.minColour))
                    
                    ColorPicker("Max Colour", selection: Color.makeBinding(from: $settings.heatMapLayer.maxColour))
                    
                }
            }
        }
    }
}
