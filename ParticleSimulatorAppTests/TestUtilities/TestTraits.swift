//
//  TestTraits.swift
//  ParticleSimulatorApp
//
//  Created by DY on 25/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Collections
import Foundation
import RealityKit
import RealityKitContent
import SwiftUI
import Testing

@testable import ParticleSimulatorApp


// Source - https://stackoverflow.com/a/79856742
// Posted by Sweeper, modified by community. See post 'Timeline' for change history
// Retrieved 2026-07-25, License - CC BY-SA 4.0

struct InitialiseLoggerTrait: SuiteTrait, TestScoping {
    func provideScope(for test: Test, testCase: Test.Case?, performing function: @concurrent @Sendable () async throws -> Void) async throws {
        print("Clearing Log file ...")
        clearLogFile()
        
        try await function()
    }
}

extension SuiteTrait where Self == InitialiseLoggerTrait {
    static var initialiseLogger: InitialiseLoggerTrait { .init() }
}

//protocol TesterProtocol {
//    var testAPI: TesterAPI { get set }
//    init() async throws
//}
//
//extension TesterProtocol {
//    init() async throws {
//        try await self.init()
//        testAPI = TesterAPI()
//    }
//}

