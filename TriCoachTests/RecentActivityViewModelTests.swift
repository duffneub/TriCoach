//
//  RecentActivityViewModelTests.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import XCTest
@testable import TriCoach

class RecentActivityViewModelTests : XCTestCase {
    private let activityRepo = MockActivityRepository()
    private let dateFormatter = DateFormatter()
    var subject: RecentActivityViewModel!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        dateFormatter.timeStyle = .full
        subject = RecentActivityViewModel(activityRepo: activityRepo, dateFormatter: dateFormatter)
    }
    
    func testShouldGroupActivitiesByWeekAndSortInDescendingOrderOfDate() throws {
        let thisWeek = Date().startOfWeek()
        let lastWeek = thisWeek.previousWeek()
        let twoWeeksAgo = lastWeek.previousWeek()
        
        let activitiesThisWeek = (0..<5).map { _ in Activity(date: thisWeek) }
        let activitiesLastWeek = (0..<10).map { _ in Activity(date: lastWeek) }
        let activities2WeeksAgo = (0..<20).map { _ in Activity(date: twoWeeksAgo) }

        var activities = activitiesThisWeek + activitiesLastWeek + activities2WeeksAgo
        activities.shuffle()
        
        activityRepo.add(activities)
        
        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)
        
        XCTAssertEqual(3, recentActivity.count)
        
        [thisWeek, lastWeek, twoWeeksAgo].enumerated().forEach { offset, date in
            XCTAssertEqual(dateFormatter.string(from: date), recentActivity[offset].title)
        }
        
        [activitiesThisWeek, activitiesLastWeek, activities2WeeksAgo].enumerated().forEach { offset, activities in
            XCTAssertEqual(activities.count, recentActivity[offset].content.count)
        }
    }
    
    func testShouldOrderActivitiesWithinGroupingInDescendingOrderOfDate() {
        let first = Activity(date: Date())
        let second = Activity(date: Date().addingTimeInterval(-1))
        let third = Activity(date: Date().addingTimeInterval(-2))
        activityRepo.add([second, third, first])

        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        XCTAssertEqual(1, recentActivity.count)
        XCTAssertEqual(3, recentActivity[0].content.count)
        
        let activities = recentActivity[0].content
        XCTAssertEqual(dateFormatter.string(from: first.date), activities[0].date)
        XCTAssertEqual(dateFormatter.string(from: second.date), activities[1].date)
        XCTAssertEqual(dateFormatter.string(from: third.date), activities[2].date)
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
    
    func add(_ activity: Activity) {
        add([activity])
    }
    
    func add(_ activities: [Activity]) {
        self.activities.append(contentsOf: activities)
    }
}

extension Date {
    func startOfWeek(_ calendar: Calendar = .current) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    func previousWeek(_ calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .weekOfYear, value: -1, to: self)!
    }
}
