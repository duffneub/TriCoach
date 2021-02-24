//
//  Activity.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/28/21.
//

import Combine
import Foundation

// MARK: - Activity

struct Activity {
    struct Summary : Identifiable, Hashable {
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

    // TODO: Convert values to `Measurement`
    struct Details {
        let route: [Coordinate]?
        let elevation: [Measurement<UnitLength>]?
        let heartRate: [Double] // Value is measured in beats per minute
        let speed: [Measurement<UnitSpeed>]?

    }
}

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

extension Activity.Summary {
    enum Sport : String, CaseIterable {
        case swim = "Swim"
        case bike = "Bike"
        case run = "Run"
    }
}

extension Activity.Summary : Comparable {
    static func < (lhs: Activity.Summary, rhs: Activity.Summary) -> Bool {
        lhs.date > rhs.date
    }
}

// MARK: - ActivityRepository

import CoreLocation

protocol ActivityRepository {
    func getAll() -> AnyPublisher<[Activity.Summary], Error>
    func loadDetails(of activity: Activity.Summary.ID) -> AnyPublisher<Activity.Details, Error>
}
