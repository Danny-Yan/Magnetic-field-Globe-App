/*
 constants.swift

 Abstract:
 All constants for the entire app
 
 Created by: Danny Yan
*/
import Foundation

enum AppConstants {
    enum Sim {
        static var simulatedBounds: Float = 1.0
        static var entityScale: Float = 0.5
        
        // The bounding box is used to occlude parts of your mesh when it isn't seen.
        // The drawing app should display all brush strokes, so use an arbitrarily large bounds.
        enum MeshBounds{
            static var lower: SIMD3<Float> = [-10000, -10000, -10000]
            static var upper: SIMD3<Float> = [10000, 10000, 10000]
        }
        
        static var populatePipelineName: String = "particleBrushPopulate"
        static var simulatePipelineName: String = "geoMagneticFieldSimulate"
        static var initialiseMagneticModel: String = "initialiseMagneticModel"
        static var trailPipelineName: String = "geoMagneticTrailPopulate"
        
        static var chosenDataSet: MagneticModelVersion = .WMM2025
        
        static var showSim: Bool = true
        static var skipSplashScreen: Bool = false
    }
    
    enum Spawn{
        static var maxSpawnCount: Int = (pow(2, 14) as NSDecimalNumber).intValue
        static var minSpawnCount: Int = 1024
        
        static var centre: SIMD3<Float> = [0, 1.5, -1]
        static var radius: Float = 4
        static var randomSpawn: Bool = true
        
        // TODO: MAKE THIS DEPENDENT ON MODEL FILE
        static var spawnDate: [Int] = [1, 1, 2020]
    }
    
    enum Particle {
        static var initialSpeed: Float = 0.3
        static var size: Float = 0.002
        
        enum Colour {
            
            static var defaultColourLayer: ParticleVisualisationLayer = .heatMapLayer
           
            // Max and Min Speed bounds for colours
            static var minSpeed: Float  = 0
            static var maxSpeed: Float  = 30000
            
            // Blue to red (RGB)
            static var minColour: SIMD3<Float16> = [84, 133, 250] / 255
            static var maxColour: SIMD3<Float16> = [232, 87, 87] / 255
        }
        
        static var boundingBox: SIMD3<Float> = [20, 20, 20]
        static var lifeSpanSeconds: Float = -1
    }
    
    enum Earth {
        static var radius: Float = 0.5
        static var showEarth: Bool = false
    }   
}

enum MagneticModelVersion: String {
    case WMM2020 = "WMM_COEFF2020.COF"
    case WMM2025 = "WMM2025.COF"
}

enum MagneticModelTestFilePaths: String {
    case WMM2025 = "WMM2025_TestValues.txt"
}


