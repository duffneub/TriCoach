//
//  MockActivityRepository.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 2/2/21.
//

import Combine
import Foundation
@testable import TriCoach

class MockActivityRepository : ActivityRepository {
    private var activities: [Activity] = []
    
    func getAll() -> AnyPublisher<[Activity], Error> {
        Just(activities)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func add(_ activity: Activity) {
        add([activity])
    }
    
    func add(_ activities: [Activity]) {
        self.activities.append(contentsOf: activities)
    }
}
