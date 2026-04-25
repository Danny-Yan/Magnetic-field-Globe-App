/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that encapsulates the palette functionality, including settings and preset selectors.
*/

import SwiftUI
import RealityKit
import RealityKitContent

struct PaletteView: View {
    @Binding var brushState: BrushState

    @State var isDrawing: Bool = false
    @State var isSettingsPopoverPresented: Bool = false

    var body: some View {
        PresetBrushSelectorView(brushState: $brushState)
    }
}
