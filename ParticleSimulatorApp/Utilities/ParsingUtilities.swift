//
//  ParsingUtilities.swift
//  ParticleSimulatorApp
//
//  Created by DY on 8/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import Foundation
import simd
import SwiftUI

/// Given a day, month, year, hour, minute and timezone, create the corresponding date
func createDateFromDMY(hour: Int = 0, minute: Int = 0,
                       day: Int = AppConstants.Spawn.spawnDate[0],
                       month: Int = AppConstants.Spawn.spawnDate[1],
                       year: Int = AppConstants.Spawn.spawnDate[2],
                       timeZoneIdentifier: String = "Australia/Sydney") -> Date? {
    
    var dateComponents = DateComponents()
    dateComponents.day = day
    dateComponents.month = month
    dateComponents.year = year
    
    dateComponents.timeZone = TimeZone(identifier: timeZoneIdentifier)
    
    dateComponents.hour = hour
    dateComponents.minute = minute
    let calendar = Calendar(identifier: .gregorian)
    guard let someDateTime = calendar.date(from: dateComponents) else { return nil }
    
    return someDateTime
}

/// Given a year fraction, determines what the corresponding Date will look like
func createDateFromFraction(yearFraction: Float) -> Date? {
    
    // Seperate out decimal portion of fraction
    let currentYear = Int(yearFraction)
    let remaindingYear: Float = Float( currentYear ) - yearFraction
    
    // Create calendar and data components
    let dateComponents = DateComponents(
        year: currentYear,
        month: 1,
        day: 1
    )
    let calendar = Calendar(identifier: .gregorian)
    
    // Calculate the target year
    guard let startOfYear = calendar.date(from: dateComponents) else { return nil }
    let yearLength = calendar.range(of: .day, in: .year, for: startOfYear)!.count
    
    // Calculate number of seconds in said year
    let secondsInYear: Float = Float(yearLength * 24 * 60 * 60)
    
    // Calculate number of seconds passed since
    // the start of the year according to year fraction
    let secondsElapsed: Float = remaindingYear * secondsInYear
    
    // Account for number of seconds elapsed in Date Component
    return startOfYear.addingTimeInterval(Double(secondsElapsed))
}

/// Give a Date type, create the corresponding year fraction
func createYearFractionFromDate(date: Date = Date.init()) -> Float {
    let calendar = Calendar(identifier: .gregorian)
    let year: Int = calendar.component(.year, from: date)
    let yearLength: Int = calendar.range(of: .day, in: .year, for: date)!.count
    
    let yearFraction: Float = Float(year) + Float(calendar.ordinality(of: .day, in: .year, for: date)!)
    // If range returns an invalid value, use leap year test
    / Float(yearLength >= 365 ? yearLength : (year % 4 == 0 && (year % 25 != 0 || (year % 400 == 0 && year % 4000 != 0)) ? 366 : 365))
    
    return yearFraction
}

/// Parses txt file into [String]
func parseDataFile(path: String, parser: (_ str: [String]) throws -> Void) -> Void {
    
    let pathArray = Array(path.split(separator: ".")
        .map {
            String($0)
        }.prefix(2)
    )
    
    if let fileURL = Bundle.main.url(forResource: pathArray[0], withExtension: pathArray[1]) {
        do {
            
            let str = try Array(String(contentsOf: fileURL, encoding: .utf8).split{
                $0.isNewline
            }.map{
                String($0)
            })
            
            try parser(str)
            
        } catch {
            fatalError("Error reading file: \(error)")
        }
    }
}

/// Converts a given encodable object into a string
func convertEncodableToString(target: Encodable) -> String {
    var entryString: String = ""
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let entryData = try encoder.encode(target)
        if let convertedString = String(data: entryData, encoding: .utf8){
            entryString = convertedString
        }
    } catch {
        fatalError("Failed to parse struct into string with error: \(error)")
    }
    
    return entryString
}

