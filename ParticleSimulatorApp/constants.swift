/*
 constants.swift

 Abstract:
 All constants for the entire app
 
 Created by: Danny Yan
*/
import Foundation

// System wide defaults for Particle Simulator
enum AppConstants {
    enum Sim {
        static var simulatedBounds: Float = 1.0
        static var entityScale: Float = 0.5
        
        // The bounding box is used to occlude parts of the mesh when it isn't seen.
        enum MeshBounds{
            static var lower: SIMD3<Float> = [-10000, -10000, -10000]
            static var upper: SIMD3<Float> = [10000, 10000, 10000]
        }
        
        // Metal Pipeline Paths
        static var populatePipelineName: String = "particleBrushPopulate"
        static var simulatePipelineName: String = "geoMagneticFieldSimulate"
        static var initialiseMagneticModel: String = "initialiseMagneticModel"
        static var trailPipelineName: String = "geoMagneticTrailPopulate"
        
        // Version of magnetic model used along with the corresponding file path
        static var chosenDataSet: MagneticModelVersion = .WMM2025
        
        static var showSim: Bool = true
        static var skipSplashScreen: Bool = false
        
        // Scaling factor for Magnetic Field's intensity
        static var forceMultipler: Float = 10
    }
    
    enum Spawn{
        static var maxSpawnCount: Int = 30000
        static var minSpawnCount: Int = 1024
        
        static var centre: SIMD3<Float> = [0, 1.5, -1]
        static var radius: Float = 1
        
        static var randomSpawn: Bool = true
        
        // TODO: MAKE THIS DEPENDENT ON MODEL FILE
        static var spawnDate: [Int] = [1, 1, 2026]
    }
    
    enum Particle {
        // Size of particle entity
        static var size: Float = 0.002
        
        // Particle will only exist within this bounding box
        static var boundingBox: SIMD3<Float> = [1, 1, 1] * 5
        
        // Lifespan of particles
        // If lifespan = -1 => Infinite lifespan
        static var lifeSpanSeconds: Float = -1
        
        enum Colour {
            static var defaultColourLayer: ParticleVisualisationLayer = .heatMapLayer
           
            // Max and Min Speed bounds for colours
            static var minSpeed: Float  = 0
            static var maxSpeed: Float  = 30000
            
            // Blue to red (RGB)
            static var minColour: SIMD3<Float16> = [84, 133, 250] / 255
            static var maxColour: SIMD3<Float16> = [232, 87, 87] / 255
        }
    }
    
    enum Earth {
        static var radius: Float = 0.5
        static var showEarth: Bool = true
    }
}

/// Particle model version with its corresponding coefficient file
enum MagneticModelVersion: String, CaseIterable {
    case WMM2020 = "WMM_COEFF2020.COF"
    case WMM2025 = "WMM2025.COF"
}

/// Test file paths for each model version where avaliable
enum MagneticModelTestFilePaths: String {
    case WMM2025 = "WMM2025_TestValues.txt"
}


