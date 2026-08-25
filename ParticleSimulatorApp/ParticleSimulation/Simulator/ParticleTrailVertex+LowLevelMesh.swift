//
//  ParticleTrailVertex+LowLevelMesh.swift
//  ParticleSimulatorApp
//
//  Created by DY on 13/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import RealityKit

extension ParticleTrailVertex {
    static var vertexAttributes: [LowLevelMesh.Attribute] {
        typealias Attribute = LowLevelMesh.Attribute

        return [
            Attribute(semantic: .position, format: .float3, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.attributes.position)!),

            Attribute(semantic: .color, format: .half4, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.attributes.color)!),
            
            Attribute(semantic: .uv0, format: .half2, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.uv)!),
            
            Attribute(semantic: .uv1, format: .float, layoutIndex: 0,
                      offset: MemoryLayout.offset(of: \Self.attributes.size)!),
        ]
    }
}
