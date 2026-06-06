/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Evaluates and stores information about strokes based on someone's inputs and style parameters.
*/

import Algorithms
import Collections
import Foundation
import RealityKit

private extension Collection where Element: FloatingPoint {
    
    /// Computes the average over this collection, omitting a number of the largest and smallest values.
    ///
    /// - Parameter truncation: The number or largest and smallest values to omit.
    /// - Returns: The mean value of the collection, after the truncated values are omitted.
    func truncatedMean(truncation: Int) -> Element {
        guard !isEmpty else { return .zero }
        
        var sortedSelf = Deque(sorted())
        let truncationLimit = (count - 1) / 2
        sortedSelf.removeFirst(Swift.min(truncationLimit, truncation))
        sortedSelf.removeLast(Swift.min(truncationLimit, truncation))
        return sortedSelf.reduce(Element.zero) { $0 + $1 } / Element(sortedSelf.count)
    }
}

public struct DrawingSource {
    private let rootEntity: Entity
    private var particleMaterial: RealityKit.Material
    
    private var particleMeshGenerator: particleDrawingMeshGenerator
    
    private var inputsOverTime: Deque<(SIMD3<Float>, TimeInterval)> = []
    
    private var particleProvider = particleBrushStyleProvider()
    
    @MainActor
    init(rootEntity: Entity, particleMaterial: Material? = nil) async {
        self.rootEntity = rootEntity
        let particleMeshEntity = Entity()
        rootEntity.addChild(particleMeshEntity)
        self.particleMaterial = particleMaterial ?? SimpleMaterial()
        particleMeshGenerator = particleDrawingMeshGenerator(rootEntity: particleMeshEntity,
                                                           material: self.particleMaterial)
    }
    
    @MainActor
    mutating func receiveSynthetic(position: SIMD3<Float>, speed: Float, state: BrushState) {
        let styled = particleProvider.styleInput(position: position, speed: speed,
                                                settings: state.particleStyleSettings)
        
        particleMeshGenerator.traceSingular(point: styled)
    }
    
    
    
//    @MainActor
//    mutating func receive(input: InputData?, time: TimeInterval, state: BrushState) {
//        while let (_, headTime) = inputsOverTime.first, time - headTime > 0.1 {
//            inputsOverTime.removeFirst()
//        }
//        
//        if let brushTip = input?.brushTip {
//            let lastInputPosition = inputsOverTime.last?.0
//            inputsOverTime.append((brushTip, time))
//            
//            if let lastInputPosition, lastInputPosition == brushTip {
//                return
//            }
//        }
//        
//        let speedsOverTime = inputsOverTime.adjacentPairs().map { input0, input1 in
//            let (point0, time0) = input0
//            let (point1, time1) = input1
//            let distance = distance(point0, point1)
//            let time = abs(time0 - time1)
//            return distance / Float(time)
//        }
//        
//        let smoothSpeed = speedsOverTime.truncatedMean(truncation: 2)
//        
//        if let input, input.isDrawing {
//            trace(position: input.brushTip, speed: smoothSpeed, state: state)
//        } else {
//            
//            if particleMeshGenerator.isDrawing {
//                particleMeshGenerator.endStroke()
//            }
//        }
//    }
}

