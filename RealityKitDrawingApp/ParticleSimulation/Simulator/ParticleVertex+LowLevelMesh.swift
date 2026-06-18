/*
 ParticleVertex+LowLevelMesh.swift

 Abstract:
 A listing of the `LowLevelMesh` attributes that correspond with the structure,
 `ParticleVertex`, in the Metal Shading Language.
 
 Created by: Danny Yan
 */

import RealityKit

extension ParticleVertex {
    static var vertexAttributes: [LowLevelMesh.Attribute] {
        typealias Attribute = LowLevelMesh.Attribute

        return [
            Attribute(semantic: .position, format: .float3, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.attributes.position)!),

            Attribute(semantic: .color, format: .half3, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.attributes.color)!),
            
            Attribute(semantic: .uv0, format: .half2, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.uv)!),
            
            Attribute(semantic: .uv1, format: .float, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.attributes.curveDistance)!),
            
            Attribute(semantic: .uv2, format: .float, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.attributes.size)!)
        ]
    }
}
