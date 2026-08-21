//
//  ParticleAttributes+Util.swift
//  ParticleSimulatorApp
//
//  Created by DY on 13/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

extension ParticleAttributes{
    
    /// Workaround to initialising the particle attributes struct without initialising the trailPositions array
    init(attributes: ParticlePointAttributes, velocity: packed_float3){
        self = withUnsafeTemporaryAllocation(of: ParticleAttributes.self, capacity: 1) { buffer in
            let ptr = buffer.baseAddress!
            memset(ptr, 0, MemoryLayout<ParticleAttributes>.stride)
            ptr.pointee.attributes = attributes
            ptr.pointee.velocity = velocity
            ptr.pointee.trailCurrentIndex = 0
            return ptr.pointee
        }
    }
}
