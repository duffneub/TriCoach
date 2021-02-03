//
//  MeasurementFormatter+Sports.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/2/21.
//

import Foundation

extension MeasurementFormatter {
    func hoursAndMinutes(from duration: Measurement<UnitDuration>) -> String {
        let unitStyleCache = unitStyle
        let maximumFractionDigitsCache = numberFormatter.maximumFractionDigits
        defer {
            unitStyle = unitStyleCache
            numberFormatter.maximumFractionDigits = maximumFractionDigitsCache
        }
        
        unitStyle = .medium
        numberFormatter.maximumFractionDigits = 1
        
        let total = duration.converted(to: .hours)
        let hours = Measurement<UnitDuration>(value: total.value.rounded(.towardZero), unit: .hours)
        let minutes = (total - hours).converted(to: .minutes)
        
        return [
            hours.value >= 1 ? string(from: hours) : nil,
            minutes.value >= 1 ? string(from: minutes) : nil
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }
    
    func swimDistance(from distance: Measurement<UnitLength>) -> String {
        let unitStyleCache = unitStyle
        let maximumFractionDigitsCache = numberFormatter.maximumFractionDigits
        let unitOptionsCache = unitOptions
        defer {
            unitStyle = unitStyleCache
            unitOptions = unitOptionsCache
            numberFormatter.maximumFractionDigits = maximumFractionDigitsCache
        }

        unitStyle = .medium
        unitOptions = .providedUnit
        numberFormatter.maximumFractionDigits = 0
        let swimDistance = distance.converted(to: locale.usesMetricSystem ? .meters : .yards)
        
        return string(from: swimDistance)
    }
    
    func bikeOrRunDistance(from distance: Measurement<UnitLength>) -> String {
        let unitStyleCache = unitStyle
        let maximumFractionDigitsCache = numberFormatter.maximumFractionDigits
        defer {
            unitStyle = unitStyleCache
            numberFormatter.maximumFractionDigits = maximumFractionDigitsCache
        }
        
        unitStyle = .medium
        numberFormatter.maximumFractionDigits = 1
        
        return string(from: distance)
    }
}
