//
//  ActivityServiceRepositoryTests.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 2/4/21.
//

import CoreLocation
import Combine
import XCTest
@testable import TriCoach

class ActivityServiceRepositoryTests: XCTestCase {
    private let service = MockActivityService()
    private var subject: ActivityServiceRepository!
    
    override func setUp() {
        super.setUp()
        
        subject = ActivityServiceRepository(service: service)
    }

    func testGetAll_shouldReturnActivitiesFromService() throws {
        let activities = (0..<100).map { Activity.test(workout: "#\($0 + 1)") }
        service.activitiesResponse = .success(activities)
        
        XCTAssertEqual(activities, try await(subject.getAll()))
    }
    
    func testGetAll_withUnavailableService_shouldFail() {
        service.isAvailable = false
        
        XCTAssertThrowsError(try await(subject.getAll()))
    }
    
    func testGetAll_withAuthorizationError_shouldFail() {
        service.authorizationResponse = .failure(.test)
        
        XCTAssertThrowsError(try await(subject.getAll()))
    }
    
    func testGetAll_withFetchError_shouldFail() {
        service.activitiesResponse = .failure(.test)
        
        XCTAssertThrowsError(try await(subject.getAll()))
    }

}

class MockActivityService : ActivityService {
    var isAvailable: Bool = true
    var authorizationResponse = Result<Void, Error>.success(())
    var activitiesResponse = Result<[Activity], Error>.success([])
    
    func requestAuthorization() -> AnyPublisher<Void, Swift.Error> {
        authorizationResponse.publisher.mapError { $0 as Swift.Error }.eraseToAnyPublisher()
    }
    
    func getActivities() -> AnyPublisher<[Activity], Swift.Error> {
        activitiesResponse.publisher.mapError { $0 as Swift.Error }.eraseToAnyPublisher()
    }


    func getRoute(for activity: UUID) -> AnyPublisher<[CLLocationCoordinate2D]?, Swift.Error> {
        Just<[CLLocationCoordinate2D]?>(nil).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
    }

    func loadHeartRate(of activity: Activity) -> AnyPublisher<[Double], Swift.Error> {
        Just<[Double]>([]).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
    }
    
    // MARK: - Error
    
    enum Error : Swift.Error {
        case test
    }
}
