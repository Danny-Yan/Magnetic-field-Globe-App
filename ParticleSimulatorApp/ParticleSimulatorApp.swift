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
    private static let paletteWindowId: String      = "Palette"
    private static let immersiveGlobeSpace: String  = "ImmersiveGlobeSpace"
    private static let preSimulationPhaseId: String = "PreSimulationPhase"
    private static let splashScreenWindowId: String = "SplashScreen"
    
    /// The mode of the app determines which windows and immersive spaces should be open.
    enum Mode: Equatable, CaseIterable {
        case splashScreen
        case preSimulationPhase
        case drawing
        
        var needsImmersiveSpace: Bool {
            return self == .drawing
        }
        
        var needsSpatialTracking: Bool {
            return self == .drawing
        }
        
        fileprivate var windowId: String {
            switch self {
            case .splashScreen:         return splashScreenWindowId
            case .drawing:              return paletteWindowId
            case .preSimulationPhase:   return preSimulationPhaseId
            }
        }
    }
    
    @State private var settings: ParticleSystemSettings = ParticleSystemSettings()
    @State private var mode: Mode = .splashScreen
    @State private var canvas = DrawingCanvasSettings()
    
    @State private var immersiveSpacePresented: Bool = false
    @State private var immersionStyle: ImmersionStyle = .mixed
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @MainActor private func setMode(_ newMode: Mode) async {
        let oldMode = mode
        guard newMode != oldMode else { return }
        mode = newMode
 
        // Open whatever the new mode needs.
        if newMode.needsImmersiveSpace && !immersiveSpacePresented {
            switch await openImmersiveSpace(id: Self.immersiveGlobeSpace) {
            case .opened:
                immersiveSpacePresented = true
            case .error, .userCancelled:
                // Immersive space failed to open; bail out so that
                // the app isn't left in a half-transitioned state.
                mode = oldMode
                return
            @unknown default:
                mode = oldMode
                return
            }
        }
        openWindow(id: newMode.windowId)
 
        // Close whatever the old mode had open that the new mode doesn't need.
        if immersiveSpacePresented && !newMode.needsImmersiveSpace {
            await dismissImmersiveSpace()
            immersiveSpacePresented = false
        }
 
        // Dismiss every window that isn't the one the user just opened
        for candidateId in Mode.allCases
                where candidateId.windowId != newMode.windowId {
            dismissWindow(id: candidateId.windowId)
        }
    }
    
    var body: some Scene {
        Group {
            WindowGroup(id: Self.splashScreenWindowId) {
                
                if AppConstants.Sim.skipSplashScreen {
                    Text("Loading...").task {
                        do {
                            await setMode(.drawing)
                        }
                    }
                } else {
                    ZStack{
                        SplashScreenView()
                            .environment(\.setMode, setMode)
                            .frame(width: 1000, height: 700)
                            .fixedSize()
                    }
                }
            }
            
            WindowGroup(id: Self.preSimulationPhaseId) {
                ParticlePreSimulationUI(settings: $settings)
                    .environment(\.setMode, setMode)
                    .frame(width: 700, height: 700, alignment: .top)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .windowResizability(.contentSize)
            .windowResizability(.contentSize)
            .windowStyle(.plain)
            

            WindowGroup(id: Self.paletteWindowId) {
                ParticleSystemUI(settings: $settings)
                    .frame(width: 700, height: 700, alignment: .top)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .windowResizability(.contentSize)
            .windowResizability(.contentSize)
            .windowStyle(.plain)
            
            
            ImmersiveSpace(id: Self.immersiveGlobeSpace){
                ImmersiveContentView(settings: $settings)
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
