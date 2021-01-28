//
//  Activity.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/28/21.
//

import Foundation

struct Activity {
    let date: Date
}

extension Activity : Comparable {
    static func < (lhs: Activity, rhs: Activity) -> Bool {
        lhs.date > rhs.date
    }
}
