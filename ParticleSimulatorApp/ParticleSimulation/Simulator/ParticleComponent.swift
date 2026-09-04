/*
 ParticleComponent.swift
 
 Abstract:
 A RealityKit component and system to facilitate the generation of particle brush strokes.
 
 Created by: Danny Yan
 */

import Foundation
import RealityKit

struct ParticleComponent: Component {
    var generator: ParticleMeshGenerator
    var material: Material
    
    var trailEntity: Entity
    var trailMaterial: Material
}

class ParticleBrushSystem: System {
    private static let query = EntityQuery(where: .has(ParticleComponent.self))
    
    required init(scene: RealityKit.Scene) {}
    
    private var lastUpdateTime: Date?
    
    func update(context: SceneUpdateContext) {
        let now = Date.now
        let deltaTime = Float(lastUpdateTime?.distance(to: now) ?? 0)
        lastUpdateTime = now
        
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            let particleComponent: ParticleComponent = entity.components[ParticleComponent.self]!
            let generator = particleComponent.generator
            let trailEntity = particleComponent.trailEntity
            
            // Calls `update` on the generator.
            // This returns a non-nil `LowLevelMesh` if a new mesh had to be allocated.
            // This can happen when the number of samples exceeds the capacity of the mesh.
            //
            // If the generator returns a new `LowLevelMesh`,
            // apply to the entity's `ModelComponent`.
            try? generator.update(deltaTime: deltaTime) { (newMesh, trailMesh) in
                guard let resource = try? await MeshResource(from: newMesh) else { return }
                
                if entity.components.has(ModelComponent.self) {
                    entity.components[ModelComponent.self]!.mesh = resource
                } else {
                    let modelComponent = ModelComponent(mesh: resource, materials: [particleComponent.material])
                    entity.components.set(modelComponent)
                }
            
                guard let trailResource = try? await MeshResource(from: trailMesh) else { return }
                
                if trailEntity.components.has(ModelComponent.self) {
                    trailEntity.components[ModelComponent.self]!.mesh = trailResource
                } else {
                    let trailModelComponent = ModelComponent(mesh: trailResource, materials: [particleComponent.trailMaterial])
                    trailEntity.components.set(trailModelComponent)
                }
            }
        }
    }
}
