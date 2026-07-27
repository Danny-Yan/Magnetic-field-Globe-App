//
//  PrintLogger.swift
//  ParticleSimulatorApp
//
//  Created by DY on 21/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

// Source - https://stackoverflow.com/a/78192559
// Posted by FPP
// Retrieved 2026-07-25, License - CC BY-SA 4.0

internal import UniformTypeIdentifiers

final class LogDestination: TextOutputStream {
    static var dest = LogDestination()
    
    let logURL: URL
    init() {
//        Let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let paths = URL.documentsDirectory
        logURL = paths.appendingPathComponent("log.txt", conformingTo: .plainText)
    }
    
    func write(_ string: String) {
        do {
//            print("\(logURL)")
            if !FileManager.default.fileExists(atPath: logURL.path) {   // does it exits?
                FileManager.default.createFile(atPath: logURL.path, contents: nil)
            }
            if let data = string.data(using: .utf8) {
                let fileHandle = try FileHandle(forWritingTo: logURL)
                try fileHandle.seekToEnd()
                try fileHandle.write(contentsOf: data)
                try fileHandle.close()
            }
        } catch let error as NSError {                              // something wrong
            print("Unable to write log: \(error.debugDescription)") // debug printout
        }
    }
}

func printClassEntries(headline: String = "", for target: Any){
    // Print out all elements in the output
    
    var logDest = LogDestination.dest
    
    print(" ---------------------- \(headline) ---------------------- \n", to: &logDest)
    let outputMirror = Mirror(reflecting: target)
    for child in outputMirror.children{
        if let propertyName = child.label{
            print("\(propertyName): \(child.value)", to: &logDest)
        }
    }
}

func clearLogFile(){
    let logger = LogDestination()
    let logURL = logger.logURL
    
    let text = ""
    do {
         try text.write(to: logURL, atomically: false, encoding: .utf8)
       } catch {
         print(error)
       }

}

func printHeadlineSpacer(headline: String = ""){

    var logDest = LogDestination.dest
    
    print("\n", to: &logDest)
    print(" >>>>>>>>>> \(headline) <<<<<<<<<< \n", to: &logDest)
    print("\n", to: &logDest)
}
