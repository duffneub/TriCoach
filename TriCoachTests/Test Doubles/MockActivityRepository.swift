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
    private var activities: [Activity] = []
    private var subject = PassthroughSubject<[Activity], Error>()
    
    var holdResponse = false {
        didSet {
            if !holdResponse {
                subject.send(activities)
                subject.send(completion: .finished)
            }
        }
    }
    
    func getAll() -> AnyPublisher<[Activity], Error> {
        if !holdResponse {
            return Just(activities)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return subject.eraseToAnyPublisher()
        }
    }

    func loadRoute(of activity: Activity) -> AnyPublisher<[CLLocationCoordinate2D]?, Error> {
        Just<[CLLocationCoordinate2D]?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func loadHeartRate(of activity: Activity) -> AnyPublisher<[Double], Error> {
        Just<[Double]>([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func add(_ activity: Activity) {
        add([activity])
    }
    
    func add(_ activities: [Activity]) {
        self.activities.append(contentsOf: activities)
    }
}
