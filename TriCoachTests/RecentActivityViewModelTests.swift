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
    private let measurementFormatter = MeasurementFormatter()
    private let listFormatter = ListFormatter()
    var subject: RecentActivityViewModel!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        subject = RecentActivityViewModel(activityRepo: activityRepo)
    }
    
    func testShouldGroupActivitiesByWeekAndSortInDescendingOrderOfDate() {
        let today = Date.thu_march_26_2020
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tuesday = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let monday = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let sunday = Calendar.current.date(byAdding: .day, value: -4, to: today)!
        let saturday = Calendar.current.date(byAdding: .day, value: -5, to: today)!
        let friday = Calendar.current.date(byAdding: .day, value: -6, to: today)!

        let lastThursday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: today)!
        let lastWednesday = Calendar.current.date(byAdding: .day, value: -1, to: lastThursday)!
        let lastTuesday = Calendar.current.date(byAdding: .day, value: -2, to: lastThursday)!
        let lastMonday = Calendar.current.date(byAdding: .day, value: -3, to: lastThursday)!
        let lastSunday = Calendar.current.date(byAdding: .day, value: -4, to: lastThursday)!
        let lastSaturday = Calendar.current.date(byAdding: .day, value: -5, to: lastThursday)!
        let lastFriday = Calendar.current.date(byAdding: .day, value: -6, to: lastThursday)!

        let someThursday = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: today)!
        let someWednesday = Calendar.current.date(byAdding: .day, value: -1, to: someThursday)!
        let someTuesday = Calendar.current.date(byAdding: .day, value: -2, to: someThursday)!
        let someMonday = Calendar.current.date(byAdding: .day, value: -3, to: someThursday)!
        let someSunday = Calendar.current.date(byAdding: .day, value: -4, to: someThursday)!
        let someSaturday = Calendar.current.date(byAdding: .day, value: -5, to: someThursday)!
        let someFriday = Calendar.current.date(byAdding: .day, value: -6, to: someThursday)!

        activityRepo.add([
            today,
            yesterday,
            tuesday,
            monday,
            sunday,
            saturday,
            friday,
            lastThursday,
            lastWednesday,
            lastTuesday,
            lastMonday,
            lastSunday,
            lastSaturday,
            lastFriday,
            someThursday,
            someWednesday,
            someTuesday,
            someMonday,
            someSunday,
            someSaturday,
            someFriday
        ].reversed().map { Activity.test(date: $0) })
        
        subject.getCurrentDate = { today }
        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        XCTAssertEqual(4, recentActivity.count)
        
        XCTAssertEqual("This Week", recentActivity[0].title)
        XCTAssertEqual(5, recentActivity[0].content.count)
        
        XCTAssertEqual("Last Week", recentActivity[1].title)
        XCTAssertEqual(7, recentActivity[1].content.count)
        
        XCTAssertEqual("March 8", recentActivity[2].title)
        XCTAssertEqual(7, recentActivity[2].content.count)
        
        XCTAssertEqual("March 1", recentActivity[3].title)
        XCTAssertEqual(2, recentActivity[3].content.count)
    }
    
    func testActivitiesAreOrderedByDateInDescendingOrder() {
        let today = Date()
        activityRepo.add([
            Activity.test(sport: .swim, workout: "Pool Swim", date: today.addingTimeInterval(1_000)),
            Activity.test(sport: .bike, workout: "Outdoor Cycle", date: today),
            Activity.test(sport: .run, workout: "Outdoor Run", date: today.addingTimeInterval(2_000))
        ])

        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        XCTAssertEqual(1, recentActivity.count)
        XCTAssertEqual(3, recentActivity[0].content.count)
        
        let activities = recentActivity[0].content
        let run = activities[0]
        let swim = activities[1]
        let bike = activities[2]
        
        XCTAssertEqual(.run, run.sport)
        XCTAssertEqual("Outdoor Run", run.title)
        
        XCTAssertEqual(.swim, swim.sport)
        XCTAssertEqual("Pool Swim", swim.title)
        
        XCTAssertEqual(.bike, bike.sport)
        XCTAssertEqual("Outdoor Cycle", bike.title)
    }
    
    func testSummary_shouldUseHoursAndMinutes() {
        let today = Date()
        activityRepo.add([
            Activity.test(duration: .init(value: 0.5, unit: .hours), date: today.addingTimeInterval(1_000)),
            Activity.test(duration: .init(value: 120, unit: .minutes), date: today),
            Activity.test(duration: .init(value: 95, unit: .minutes), date: today.addingTimeInterval(2_000))
        ])

        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        XCTAssertEqual(1, recentActivity.count)
        XCTAssertEqual(3, recentActivity[0].content.count)
        
        let activities = recentActivity[0].content
        XCTAssertEqual("1 hr 35 min", activities[0].summary.components(separatedBy: " · ").first!)
        XCTAssertEqual("30 min", activities[1].summary.components(separatedBy: " · ").first!)
        XCTAssertEqual("2 hr", activities[2].summary.components(separatedBy: " · ").first!)
    }
    
    func testSummary_withBikeOrRun_withImperial_shouldUseMiles() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US")
        subject.calendar = calendar
        
        activityRepo.add([
            Activity.test(
                sport: .run,
                duration: .init(value: 0.5, unit: .hours),
                distance: .init(value: 1_609.34, unit: .meters),
                date: Date().addingTimeInterval(1_000)),
            Activity.test(
                sport: .bike, duration: .init(value: 0.5, unit: .hours), distance: .init(value: 2.9, unit: .kilometers))
        ])
        
        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        XCTAssertEqual(1, recentActivity.count)
        XCTAssertEqual(2, recentActivity[0].content.count)
        
        let run = recentActivity[0].content[0]
        XCTAssertEqual("30 min · 1 mi", run.summary)
        
        let bike = recentActivity[0].content[1]
        XCTAssertEqual("30 min · 1.8 mi", bike.summary)
    }
    
    func testSummary_withBikeOrRun_withMetric_shouldUseKilometers() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_GB")
        subject.calendar = calendar

        activityRepo.add([
            Activity.test(
                sport: .run,
                duration: .init(value: 0.5, unit: .hours),
                distance: .init(value: 3_280, unit: .feet),
                date: Date().addingTimeInterval(1_000)),
            Activity.test(
                sport: .bike, duration: .init(value: 0.5, unit: .hours), distance: .init(value: 1.12, unit: .miles))
        ])
        
        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        XCTAssertEqual(1, recentActivity.count)
        XCTAssertEqual(2, recentActivity[0].content.count)

        let run = recentActivity[0].content[0]
        XCTAssertEqual("30 min · 1 km", run.summary)
        
        let bike = recentActivity[0].content[1]
        XCTAssertEqual("30 min · 1.8 km", bike.summary)
    }
    
    func testSummary_withSwim_withImperial_shouldUseYards() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US")
        subject.calendar = calendar

        activityRepo.add(
            Activity.test(
                sport: .swim, duration: .init(value: 0.5, unit: .hours), distance: .init(value: 914.4, unit: .meters)))
        
        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        XCTAssertEqual(1, recentActivity.count)
        XCTAssertEqual(1, recentActivity[0].content.count)
        
        let swim = recentActivity[0].content[0]
        XCTAssertFalse(calendar.locale!.usesMetricSystem)
        XCTAssertEqual("30 min · 1,000 yd", swim.summary)
    }
    
    func testSummary_withSwim_withMetric_shouldUseMeters() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_GB")
        subject.calendar = calendar

        activityRepo.add(
            Activity.test(
                sport: .swim, duration: .init(value: 0.5, unit: .hours), distance: .init(value: 1_093.61, unit: .yards)))
        
        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        XCTAssertEqual(1, recentActivity.count)
        XCTAssertEqual(1, recentActivity[0].content.count)
        
        let swim = recentActivity[0].content[0]
        XCTAssertTrue(calendar.locale!.usesMetricSystem)
        XCTAssertEqual("30 min · 1,000 m", swim.summary)
    }

    func testDate_shouldBeRelativeToToday() {
        let today = Date.thu_march_26_2020
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tuesday = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let monday = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let sunday = Calendar.current.date(byAdding: .day, value: -4, to: today)!
        let saturday = Calendar.current.date(byAdding: .day, value: -5, to: today)!
        let friday = Calendar.current.date(byAdding: .day, value: -6, to: today)!

        let lastThursday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: today)!
        let lastWednesday = Calendar.current.date(byAdding: .day, value: -1, to: lastThursday)!
        let lastTuesday = Calendar.current.date(byAdding: .day, value: -2, to: lastThursday)!
        let lastMonday = Calendar.current.date(byAdding: .day, value: -3, to: lastThursday)!
        let lastSunday = Calendar.current.date(byAdding: .day, value: -4, to: lastThursday)!
        let lastSaturday = Calendar.current.date(byAdding: .day, value: -5, to: lastThursday)!
        let lastFriday = Calendar.current.date(byAdding: .day, value: -6, to: lastThursday)!

        let someThursday = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: today)!
        let someWednesday = Calendar.current.date(byAdding: .day, value: -1, to: someThursday)!
        let someTuesday = Calendar.current.date(byAdding: .day, value: -2, to: someThursday)!
        let someMonday = Calendar.current.date(byAdding: .day, value: -3, to: someThursday)!
        let someSunday = Calendar.current.date(byAdding: .day, value: -4, to: someThursday)!
        let someSaturday = Calendar.current.date(byAdding: .day, value: -5, to: someThursday)!
        let someFriday = Calendar.current.date(byAdding: .day, value: -6, to: someThursday)!

        activityRepo.add([
            today,
            yesterday,
            tuesday,
            monday,
            sunday,
            saturday,
            friday,
            lastThursday,
            lastWednesday,
            lastTuesday,
            lastMonday,
            lastSunday,
            lastSaturday,
            lastFriday,
            someThursday,
            someWednesday,
            someTuesday,
            someMonday,
            someSunday,
            someSaturday,
            someFriday
        ].reversed().map { Activity.test(date: $0) })

        subject.getCurrentDate = { today }
        subject.loadRecentActivity()
        let recentActivity = await(subject.$recentActivity)

        let activities = recentActivity.flatMap { $0.content }

        XCTAssertEqual("Today", activities[0].date)
        XCTAssertEqual("Yesterday", activities[1].date)
        XCTAssertEqual("Tuesday", activities[2].date)
        XCTAssertEqual("Monday", activities[3].date)
        XCTAssertEqual("Sunday", activities[4].date)
        XCTAssertEqual("Saturday", activities[5].date)
        XCTAssertEqual("Friday", activities[6].date)

        XCTAssertEqual("Last Thursday", activities[7].date)
        XCTAssertEqual("Last Wednesday", activities[8].date)
        XCTAssertEqual("Last Tuesday", activities[9].date)
        XCTAssertEqual("Last Monday", activities[10].date)
        XCTAssertEqual("Last Sunday", activities[11].date)
        XCTAssertEqual("Last Saturday", activities[12].date)
        XCTAssertEqual("Last Friday", activities[13].date)

        XCTAssertEqual("3/12/20", activities[14].date)
        XCTAssertEqual("3/11/20", activities[15].date)
        XCTAssertEqual("3/10/20", activities[16].date)
        XCTAssertEqual("3/9/20", activities[17].date)
        XCTAssertEqual("3/8/20", activities[18].date)
        XCTAssertEqual("3/7/20", activities[19].date)
        XCTAssertEqual("3/6/20", activities[20].date)
    }
}

extension Activity {
    static func test(
        sport: Sport = .swim,
        workout: String = "Test Workout",
        duration: Measurement<UnitDuration> = .init(value: 0, unit: UnitDuration.hours),
        distance: Measurement<UnitLength> = .init(value: 0, unit: UnitLength.miles),
        date: Date = .init()
    ) -> Activity {
        .init(sport: sport, workout: workout, duration: duration, distance: distance, date: date)
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
    static var thu_march_26_2020: Date {
        Date(timeIntervalSince1970: 1585206000)
    }
    
    func startOfWeek(_ calendar: Calendar = .current) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    func previousWeek(_ count: Int = 1, _ calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .weekOfYear, value: -1 * count, to: self)!
    }
}
