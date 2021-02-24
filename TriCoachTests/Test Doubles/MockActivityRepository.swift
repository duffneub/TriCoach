//
//  MockActivityRepository.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 2/2/21.
//

import Combine
import CoreLocation
import Foundation
@testable import TriCoach

class MockActivityRepository : ActivityRepository {
    private var activities: [Activity.Summary] = []
    private var subject = PassthroughSubject<[Activity.Summary], Error>()
    
    var holdResponse = false {
        didSet {
            if !holdResponse {
                subject.send(activities)
                subject.send(completion: .finished)
            }
        }
    }
    
    func getAll() -> AnyPublisher<[Activity.Summary], Error> {
        if !holdResponse {
            return Just(activities)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return subject.eraseToAnyPublisher()
        }
    }
    
    func add(_ activity: Activity.Summary) {
        add([activity])
    }
    
    func add(_ activities: [Activity.Summary]) {
        self.activities.append(contentsOf: activities)
    }
}
