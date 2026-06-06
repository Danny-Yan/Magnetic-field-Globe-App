//
//  constants.swift
//  RealityKitDrawingApp
//
//  Created by DY on 25/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
import Foundation

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
        
        static let populatePipelineName: String = "particleBrushPopulate"
        static let simulatePipelineName: String = "geoMagneticFieldSimulate"
    }
    
    enum Spawn{
        static let maxSpawnCount: Int = (pow(2, 18) as NSDecimalNumber).intValue
        static let minSpawnCount: Int = 1024
        
        static let centre: SIMD3<Float> = [0, 1.5, -1]
        static let radius: Float = 2
    }
    
    enum Particle {
        static let initialSpeed: Float = 0.3
        static let size: Float = 0.002
        static let color: SIMD3<Float> = [1, 1, 1]
    }
    
    enum Earth {
        static let radius: Float = 0.5
    }
}

