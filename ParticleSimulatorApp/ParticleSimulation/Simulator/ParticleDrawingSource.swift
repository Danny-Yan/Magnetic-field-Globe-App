/*
 ParticleDrawingSource.swift
 
 Abstract:
 Evaluates and stores information about strokes based on someone's inputs and style parameters.

 Created by: Danny Yan
 */

import Algorithms
import Collections
import Foundation
import RealityKit

import SwiftUI
import RealityKitContent

import MetalKit
import os

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

/// Instantiates `ParticleMeshGenerator`, draws particles to the screen
public struct ParticleDrawingSource {
    private let rootEntity: Entity
    private var particleMeshGen: ParticleMeshGenerator
    private var inputsOverTime: Deque<(SIMD3<Float>, TimeInterval)> = []
    
    @MainActor
    init(rootEntity: Entity, withSettings: Binding<ParticleSystemSettings>) async {
        self.rootEntity = rootEntity
        let particleMeshEntity = Entity()
        rootEntity.addChild(particleMeshEntity)
        particleMeshGen = await ParticleMeshGenerator(rootEntity: particleMeshEntity,
                                                      withSettings: withSettings
        )
    }
    
    /// Draws particle to the screen
    @MainActor
    func drawParticleSystemPointSynthetic(point: ParticleSystemPoint) {
        particleMeshGen.traceSingular(point: point)
    }
}

