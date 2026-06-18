/*
 ParticleSimulatorApp.swift
 
 Abstract:
 The SwiftUI `App` structure, which acts as the entry point of the app.
 Defines the windows and spaces used by the app as well as global state.
 
 Created by: Danny Yan
 */

import SwiftUI

@main
struct ParticleSimulatorApp: App {
    private static let ImmersiveGlobeSpace: String = "ImmersiveGlobeSpace"
    private static let splashScreenWindowId: String = "SplashScreen"
    
    /// The mode of the app determines which windows and immersive spaces should be open.
    enum Mode: Equatable {
        case splashScreen
        case drawing
        
        var needsImmersiveSpace: Bool {
            return self != .splashScreen
        }
        
        var needsSpatialTracking: Bool {
            return self != .splashScreen
        }
        
        fileprivate var windowId: String {
            switch self {
            case .splashScreen: return splashScreenWindowId
            case .drawing: return ImmersiveGlobeSpace
            }
        }
    }
        
    @State private var mode: Mode = .splashScreen
    @State private var canvas = DrawingCanvasSettings()
    @State private var brushState = BrushState()
    
    @State private var immersiveSpacePresented: Bool = false
    @State private var immersionStyle: ImmersionStyle = .mixed
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @MainActor private func setMode(_ newMode: Mode) async {
        let oldMode = mode
        guard newMode != oldMode else { return }
        
        if newMode.windowId == Mode.drawing.windowId {
            await openImmersiveSpace(id: newMode.windowId)
        } else {
            openWindow(id: newMode.windowId)
        }

        dismissWindow(id: oldMode.windowId)
    }

    var body: some Scene {
        Group {
            WindowGroup(id: Self.splashScreenWindowId) {
                SplashScreenView()
                    .environment(\.setMode, setMode)
                    .frame(width: 1000, height: 700)
                    .fixedSize()
            }
            .windowResizability(.contentSize)
            .windowStyle(.plain)
            
            ImmersiveSpace(id: Self.ImmersiveGlobeSpace){
                ImmersiveContentViewMemoryManager(brushState: $brushState)
            }
            .immersionStyle(selection: $immersionStyle, in: .mixed)
        }
    }
}

struct SetModeKey: EnvironmentKey {
    typealias Value = (ParticleSimulatorApp.Mode) async -> Void
    static let defaultValue: Value = { _ in }
}

extension EnvironmentValues {
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}
