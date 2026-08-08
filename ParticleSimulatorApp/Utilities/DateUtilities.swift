//
//  DateUtilities.swift
//  ParticleSimulatorApp
//
//  Created by DY on 8/7/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import Foundation
import simd
import SwiftUI

func createDateFromDMY(hour: Int = 0, minute: Int = 0,
                       day: Int = AppConstants.Spawn.particleSpawnDate[0],
                       month: Int = AppConstants.Spawn.particleSpawnDate[1],
                       year: Int = AppConstants.Spawn.particleSpawnDate[2],
                       timeZoneIdentifier: String = "Australia/Sydney") throws -> Date {
    
    var dateComponents = DateComponents()
    dateComponents.day = day
    dateComponents.month = month
    dateComponents.year = year
    
    dateComponents.timeZone = TimeZone(identifier: timeZoneIdentifier)
    
    dateComponents.hour = hour
    dateComponents.minute = minute
    let userCalendar = Calendar(identifier: .gregorian)
    let someDateTime = userCalendar.date(from: dateComponents)
    
    return someDateTime!
}


func createYearFractionFromDate(date: Date = Date.init()) -> Float {
    let calendar = Calendar.init(identifier: .gregorian)
    let year: Int = calendar.component(.year, from: date)
    let yearLength: Int = calendar.range(of: .day, in: .year, for: date)!.count
    
    let yearFraction: Float = Float(year) + Float(calendar.ordinality(of: .day, in: .year, for: date)!)
    // If range returns an invalid value, use leap year test
    / Float(yearLength >= 365 ? yearLength : (year % 4 == 0 && (year % 25 != 0 || (year % 400 == 0 && year % 4000 != 0)) ? 366 : 365))
    
    return yearFraction
}
