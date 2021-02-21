//
//  Activity.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/28/21.
//

import Combine
import Foundation

// MARK: - Activity

struct Activity : Identifiable, Hashable {
    let id: UUID
    let sport: Sport
    let workout: String
    let duration: Measurement<UnitDuration>
    let distance: Measurement<UnitLength>
    let date: Date

    init(
        id: UUID = UUID(),
        sport: Sport,
        workout: String,
        duration: Measurement<UnitDuration>,
        distance: Measurement<UnitLength>,
        date: Date
    ) {
        self.id = id
        self.sport = sport
        self.workout = workout
        self.duration = duration
        self.distance = distance
        self.date = date
    }
}

extension Activity {
    enum Sport : String, CaseIterable {
        case swim = "Swim"
        case bike = "Bike"
        case run = "Run"
    }
}

extension Activity : Comparable {
    static func < (lhs: Activity, rhs: Activity) -> Bool {
        lhs.date > rhs.date
    }
}

// MARK: - ActivityRepository

import CoreLocation

protocol ActivityRepository {
    func getAll() -> AnyPublisher<[Activity], Error>
    func loadRoute(of activity: Activity) -> AnyPublisher<[CLLocationCoordinate2D]?, Swift.Error>
}
