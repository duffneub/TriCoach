//
//  Activity+TestHelpers.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 2/2/21.
//

import Foundation
@testable import TriCoach

extension Activity.Summary {
    static func test(
        sport: Sport = .swim,
        workout: String = "Test Workout",
        duration: Measurement<UnitDuration> = .init(value: 0, unit: UnitDuration.hours),
        distance: Measurement<UnitLength> = .init(value: 0, unit: UnitLength.miles),
        date: Date = .init()
    ) -> Activity.Summary {
        .init(sport: sport, workout: workout, duration: duration, distance: distance, date: date)
    }
}
