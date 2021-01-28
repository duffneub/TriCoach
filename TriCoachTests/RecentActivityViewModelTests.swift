//
//  RecentActivityViewModelTests.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import XCTest
@testable import TriCoach

class RecentActivityViewModelTests: XCTestCase {
    private let activityRepo = MockActivityRepository()
    var subject: RecentActivityViewModel!
    
    override func setUp() {
        super.setUp()
        
        subject = RecentActivityViewModel(activityRepo: activityRepo)
    }
    
    func testLoadActivity_shouldGroupActivitiesByWeek() throws {
        let thisWeek = Date()
        let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: thisWeek)!
        let twoWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: thisWeek)!
        
        let activitiesThisWeek = (0..<5).map { _ in Activity(date: thisWeek) }
        let activitiesLastWeek = (0..<10).map { _ in Activity(date: lastWeek) }
        let activities2WeeksAgo = (0..<20).map { _ in Activity(date: twoWeeksAgo) }

        var activities = activitiesThisWeek + activitiesLastWeek + activities2WeeksAgo
        activities.shuffle()
        
        activityRepo.add(activities)
        
        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)
        
        XCTAssertEqual(3, recentActivity.count)
        XCTAssertEqual(activitiesThisWeek.count, recentActivity[0].activities.count)
        XCTAssertEqual(activitiesLastWeek.count, recentActivity[1].activities.count)
        XCTAssertEqual(activities2WeeksAgo.count, recentActivity[2].activities.count)
    }
    
}

extension XCTestCase {
    func await<P : Publisher>(_ publisher: P, timeout: TimeInterval = 1.0) -> P.Output where P.Failure == Never {
        try! _await(publisher, timeout: timeout)
    }
    
    private func _await<P : Publisher>(_ publisher: P, timeout: TimeInterval = 1.0) throws -> P.Output {
        let expectation = self.expectation(description: "Publisher to either receive value or complete with error")
        var cancellable: AnyCancellable?
        
        var result: Result<P.Output, P.Failure>!
        cancellable = publisher.sink { completion in
            if case let .failure(error) = completion {
                result = .failure(error)
                expectation.fulfill()
                cancellable?.cancel()
            }
        } receiveValue: { value in
            result = .success(value)
            expectation.fulfill()
            cancellable?.cancel()
        }

        waitForExpectations(timeout: timeout)
        return try result.get()
    }
}

class MockActivityRepository : ActivityRepository {
    private var activities: [Activity] = []
    
    func getAll() -> AnyPublisher<[Activity], Error> {
        Just(activities)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func add(_ activities: [Activity]) {
        self.activities.append(contentsOf: activities)
    }
}
