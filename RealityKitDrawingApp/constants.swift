//
//  constants.swift
//  RealityKitDrawingApp
//
//  Created by DY on 25/4/2026.
//  Copyright © 2026 Apple. All rights reserved.


enum AppConstants {
    enum Sim {
        static let simulatedBounds: Float = 1.0
        static let entityScale: Float = 0.5
        
        
        // The bounding box is used to occlude parts of your mesh when it isn't seen.
        // The drawing app should display all brush strokes, so use an arbitrarily large bounds.
        enum MeshBounds{
            static let lower: SIMD3<Float> = [-10000, -10000, -10000]
            static let upper: SIMD3<Float> = [10000, 10000, 10000]
        }
    }
    
    enum Spawn{
        static let maxSpawnCount: Int = 2048
        static let minSpawnCount: Int = 1024
        
        static let centre: SIMD3<Float> = [0, 5, 0]
    }
    
    enum Particle {
        static let initialSpeed: Float = 0.3
        static let size: Float = 0.005
        static let color: SIMD3<Float> = [1, 1, 1]
    }
}

