/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure that receives input events and uses them to style points for the particle brush.
*/

/// Receives input events and generates a `particleBrushCurvePoint` for that event.
///
/// "Drawing Styles" can modify attributes such as color as the curve is drawn.
struct particleBrushStyleProvider {
    struct Settings: Equatable, Hashable {
        var initialSpeed: Float = AppConstants.Particle.initialSpeed
        var size: Float = AppConstants.Particle.size
        var color: SIMD3<Float> = AppConstants.Particle.color
    }
    
    func styleInput(position: SIMD3<Float>, speed: Float, settings: Settings) -> particleBrushCurvePoint {
        return particleBrushCurvePoint(position: position,
                                       initialSpeed: settings.initialSpeed,
                                       size: settings.size,
                                       color: settings.color)
    }
}
