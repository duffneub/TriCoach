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
    let id = UUID()
    let sport: Sport
    let workout: String
    let duration: Measurement<UnitDuration>
    let distance: Measurement<UnitLength>
    let date: Date
}

extension Activity {
    enum Sport : CaseIterable {
        case swim
        case bike
        case run
    }
}

extension Activity : Comparable {
    static func < (lhs: Activity, rhs: Activity) -> Bool {
        lhs.date > rhs.date
    }
}

// MARK: - ActivityRepository

protocol ActivityRepository {
    func getAll() -> AnyPublisher<[Activity], Error>
}
