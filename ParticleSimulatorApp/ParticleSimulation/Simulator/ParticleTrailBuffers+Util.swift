//
//  ParticleAttributes+Util.swift
//  ParticleSimulatorApp
//
//  Created by DY on 13/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

extension ParticleTrailBuffers{
    
    /// Workaround to initialising the particle attributes struct without initialising the trail array buffers
    init(){
        self = withUnsafeTemporaryAllocation(of: ParticleTrailBuffers.self, capacity: 1) { buffer in
            let ptr = buffer.baseAddress!
            memset(ptr, 0, MemoryLayout<ParticleTrailBuffers>.stride)
            ptr.pointee.trailCurrentIndex = 0
            return ptr.pointee
        }
    }
}
