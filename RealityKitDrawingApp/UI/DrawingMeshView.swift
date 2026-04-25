/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays a person's drawing in an immersive space and handles their input.
*/

import Collections
import Foundation
import RealityKit
import RealityKitContent
import SwiftUI

struct DrawingMeshView: View {
    let canvas: DrawingCanvasSettings
    
    @Binding var brushState: BrushState

    private let rootEntity = Entity()
    private let inputEntity = Entity()
    
    var body: some View {
        RealityView { content in
            SparkleBrushSystem.registerSystem()
            SparkleBrushComponent.registerComponent()
            
            rootEntity.position = .zero
            content.add(rootEntity)
            content.add(inputEntity)
        }
    }
}
