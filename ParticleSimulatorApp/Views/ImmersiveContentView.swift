/*
 ImmersiveContentView.swift
 
 Abstract:
 A view to display a preview of a brush preset, and a view to display a collection of these presets.

 Created by: Danny Yan
 */

import SwiftUI
import RealityKit
import RealityKitContent

import MetalKit
import os

struct ImmersiveContentView: View {
    var body: some View {
        RealityView { content in
            
            let particleSystemEntity = ParticleSystemEntity()
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
