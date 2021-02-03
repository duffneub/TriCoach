//
//  Activity.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/28/21.
//

import Foundation

struct Activity {
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
