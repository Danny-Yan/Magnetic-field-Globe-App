//
//  PrintLogger.swift
//  ParticleSimulatorApp
//
//  Created by DY on 21/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

// Source - https://stackoverflow.com/a/53392944
// Posted by user2777364, modified by community. See post 'Timeline' for change history
// Retrieved 2026-07-21, License - CC BY-SA 4.0

final class PrintLogger: TextOutputStream {
  private let path: String
  init() {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    path = paths.first! + "/log"
  }

  func write(_ string: String) {
    if let data = string.data(using: .utf8), let fileHandle = FileHandle(forWritingAtPath: path) {
      defer {
        fileHandle.closeFile()
      }
      fileHandle.seekToEndOfFile()
      fileHandle.write(data)
    }
  }
}
