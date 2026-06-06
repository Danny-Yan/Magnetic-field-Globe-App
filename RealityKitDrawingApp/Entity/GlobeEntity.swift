//
//  GlobeEntity.swift
//  RealityKitDrawingApp
//
//  Created by DY on 27/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//


import SwiftUI
import RealityKit
import RealityKitContent

import MetalKit
import os


struct GlobeEntity {
    
    /// Small roughness results in shiny reflection, large roughness results in matte appearance
    let roughness: Float = 0.4
    
    /// Simulate clear transparent coating between 0 (none) and 1
    let clearcoat: Float = 0.05
    
    @MainActor
    let globe = Globe(
        name: "Bellerby World Globe",
        shortName: "World Globe",
        nameTranslated: nil,
        authorSurname: "Peter",
        authorFirstName: "Bellerby",
        date: "2023",
        description: "Peter Bellerby makes modern globes with old world craftsmanship. Many consider him the finest living globe maker.",
        infoURL: URL(string: "https://www.davidrumsey.com/luna/servlet/s/cd8p41"),
        radius: 0.325,
        texture: "Bellerby65cmSchminkeGagarin"
    )
    
    
    @MainActor
    func addEarthGeometry(to content: RealityViewContent) async throws{
        
        let earthMaterial = try await ResourceLoader.loadMaterial(
            globe: globe,
            loadPreviewTexture: false,
            roughness: roughness,
            clearcoat: clearcoat
        )
        
        let sphereEntity: Entity = {
            // Create a new entity instance.
            let entity = Entity()

            // Create a new mesh resource.
            let sphereRadius: Float = AppConstants.Earth.radius
            let boxMesh = MeshResource.generateSphere(radius: sphereRadius)

            // Add the mesh resource to a model component, and add it to the entity.
            entity.components.set(ModelComponent(mesh: boxMesh, materials: [earthMaterial]))

            return entity
        }()
        
        sphereEntity.position = AppConstants.Spawn.centre
        
        
        // Add the entity to the `RealityView` content.
        content.add(sphereEntity)
    }
    
}
