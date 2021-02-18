//
//  ActivityCatalogViewModelTests.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import XCTest
@testable import TriCoach

class ActivityCatalogViewModelTests : XCTestCase {
//    private let settings = SettingsStore()
//    private let activityRepo = MockActivityRepository()
//    var subject: ActivityCatalogViewModel!
//    
//    override func setUp() {
//        super.setUp()
//        
//        continueAfterFailure = false
//
//        subject = ActivityCatalogViewModel(
//            activity: ActivityStore(
//                activityRepo: activityRepo,
//                calendar: Just<Calendar>(.current).eraseToAnyPublisher()),
//            settings: settings)
//    }
//    
//    func testIsLoading() {
//        XCTAssertFalse(subject.isLoading)
//        
//        activityRepo.holdResponse = true
//        subject.loadCatalog()
//        XCTAssertTrue(await(subject.$isLoading.subscribe(on: DispatchQueue.main)))
//        
//        activityRepo.holdResponse = false
//        _ = await(subject.$catalog.subscribe(on: DispatchQueue.main))
//        XCTAssertFalse(subject.isLoading)
//    }
//    
//    func testRecentActivity_shouldGroupActivitiesByWeekAndSortInDescendingOrderOfDate() {
//        settings.currentDate = { Date.thu_march_26_2020 }
//        
//        let last21Days = (0..<21).map {
//            Calendar.current.date(byAdding: .day, value: -1 * $0, to: settings.currentDate())!
//        }
//        activityRepo.add(last21Days.shuffled().map { Activity.test(date: $0) })
//
//        subject.loadCatalog()
//        let recentActivity = await(subject.$catalog.subscribe(on: DispatchQueue.main))
//
//        XCTAssertEqual(4, recentActivity.count)
//        
//        // "Today" is a Thursday so there's only 5 days in "This Week"
//        XCTAssertEqual("This Week", recentActivity[0].title)
//        XCTAssertEqual(5, recentActivity[0].content.count)
//        
//        XCTAssertEqual("Last Week", recentActivity[1].title)
//        XCTAssertEqual(7, recentActivity[1].content.count)
//        
//        XCTAssertEqual("March 8", recentActivity[2].title)
//        XCTAssertEqual(7, recentActivity[2].content.count)
//        
//        XCTAssertEqual("March 1", recentActivity[3].title)
//        XCTAssertEqual(2, recentActivity[3].content.count)
//    }
//    
//    func testRecentActivity_shouldOrderActivitiesByDateInDescendingOrder() {
//        let today = Date()
//        activityRepo.add([
//            Activity.test(sport: .swim, workout: "Pool Swim", date: today.addingTimeInterval(1_000)),
//            Activity.test(sport: .bike, workout: "Outdoor Cycle", date: today),
//            Activity.test(sport: .run, workout: "Outdoor Run", date: today.addingTimeInterval(2_000))
//        ])
//
//        subject.loadCatalog()
//        let recentActivity = await(subject.$catalog.subscribe(on: DispatchQueue.main))
//
//        XCTAssertEqual(1, recentActivity.count)
//        XCTAssertEqual(3, recentActivity[0].content.count)
//        
//        let activities = recentActivity[0].content
//        let run = activities[0]
//        let swim = activities[1]
//        let bike = activities[2]
//        
//        XCTAssertEqual(.run, run.sport)
//        XCTAssertEqual("Outdoor Run", run.title)
//        
//        XCTAssertEqual(.swim, swim.sport)
//        XCTAssertEqual("Pool Swim", swim.title)
//        
//        XCTAssertEqual(.bike, bike.sport)
//        XCTAssertEqual("Outdoor Cycle", bike.title)
//    }
//    
//    func testActivitySummary_shouldUseHoursAndMinutes() {
//        let today = Date()
//        activityRepo.add([
//            Activity.test(duration: .init(value: 0.5, unit: .hours), date: today.addingTimeInterval(1_000)),
//            Activity.test(duration: .init(value: 120, unit: .minutes), date: today),
//            Activity.test(duration: .init(value: 95, unit: .minutes), date: today.addingTimeInterval(2_000))
//        ])
//
//        subject.loadCatalog()
//        let recentActivity = await(subject.$catalog.subscribe(on: DispatchQueue.main))
//        let activities = recentActivity[0].content
//
//        XCTAssertEqual(1, recentActivity.count)
//        XCTAssertEqual(3, recentActivity[0].content.count)
//        
//        XCTAssertEqual("1 hr 35 min", activities[0].summary.components(separatedBy: " · ").first!)
//        XCTAssertEqual("30 min", activities[1].summary.components(separatedBy: " · ").first!)
//        XCTAssertEqual("2 hr", activities[2].summary.components(separatedBy: " · ").first!)
//    }
//    
//    func testActivitySummary_withBikeOrRun_withImperial_shouldUseMiles() {
//        var calendar = Calendar.current
//        calendar.locale = Locale(identifier: "en_US")
//        settings.calendar = calendar
//        
//        activityRepo.add([
//            Activity.test(
//                sport: .run,
//                duration: .init(value: 0.5, unit: .hours),
//                distance: .init(value: 1_609.34, unit: .meters),
//                date: Date().addingTimeInterval(1_000)),
//            Activity.test(
//                sport: .bike, duration: .init(value: 0.5, unit: .hours), distance: .init(value: 2.9, unit: .kilometers))
//        ])
//        
//        subject.loadCatalog()
//        let recentActivity = await(subject.$catalog.subscribe(on: DispatchQueue.main))
//        let run = recentActivity[0].content[0]
//        let bike = recentActivity[0].content[1]
//
//        XCTAssertEqual(1, recentActivity.count)
//        XCTAssertEqual(2, recentActivity[0].content.count)
//        
//        XCTAssertEqual("30 min · 1 mi", run.summary)
//        XCTAssertEqual("30 min · 1.8 mi", bike.summary)
//    }
//    
//    func testActivitySummary_withBikeOrRun_withMetric_shouldUseKilometers() {
//        var calendar = Calendar.current
//        calendar.locale = Locale(identifier: "nn_NO")
//        settings.calendar = calendar
//
//        activityRepo.add([
//            Activity.test(
//                sport: .run,
//                duration: .init(value: 0.5, unit: .hours),
//                distance: .init(value: 3_280, unit: .feet),
//                date: Date().addingTimeInterval(1_000)),
//            Activity.test(
//                sport: .bike, duration: .init(value: 0.5, unit: .hours), distance: .init(value: 1.12, unit: .miles))
//        ])
//        
//        subject.loadCatalog()
//        let recentActivity = await(subject.$catalog.subscribe(on: DispatchQueue.main))
//        let run = recentActivity[0].content[0]
//        let bike = recentActivity[0].content[1]
//
//        XCTAssertEqual(1, recentActivity.count)
//        XCTAssertEqual(2, recentActivity[0].content.count)
//
//        XCTAssertEqual("30 min · 1 km", run.summary)
//        XCTAssertEqual("30 min · 1,8 km", bike.summary)
//    }
//    
//    func testActivitySummary_withSwim_withImperial_shouldUseYards() {
//        var calendar = Calendar.current
//        calendar.locale = Locale(identifier: "en_US")
//        settings.calendar = calendar
//
//        activityRepo.add(
//            Activity.test(
//                sport: .swim, duration: .init(value: 0.5, unit: .hours), distance: .init(value: 914.4, unit: .meters)))
//        
//        subject.loadCatalog()
//        let recentActivity = await(subject.$catalog.subscribe(on: DispatchQueue.main))
//        let swim = recentActivity[0].content[0]
//
//        XCTAssertEqual(1, recentActivity.count)
//        XCTAssertEqual(1, recentActivity[0].content.count)
//
//        XCTAssertFalse(calendar.locale!.usesMetricSystem)
//        XCTAssertEqual("30 min · 1,000 yd", swim.summary)
//    }
//    
//    func testActivitySummary_withSwim_withMetric_shouldUseMeters() {
//        var calendar = Calendar.current
//        calendar.locale = Locale(identifier: "nn_NO")
//        settings.calendar = calendar
//
//        activityRepo.add(
//            Activity.test(
//                sport: .swim, duration: .init(value: 0.5, unit: .hours), distance: .init(value: 1_093.61, unit: .yards)))
//        
//        subject.loadCatalog()
//        let recentActivity = await(subject.$catalog.subscribe(on: DispatchQueue.main))
//        let swim = recentActivity[0].content[0]
//
//        XCTAssertEqual(1, recentActivity.count)
//        XCTAssertEqual(1, recentActivity[0].content.count)
//
//        XCTAssertTrue(calendar.locale!.usesMetricSystem)
//        XCTAssertEqual("30 min · 1 000 m", swim.summary)
//    }
//
//    func testActivityDate_shouldBeRelativeToToday() {
//        settings.currentDate = { Date.thu_march_26_2020 }
//        
//        let last21Days = (0..<21).map {
//            Calendar.current.date(byAdding: .day, value: -1 * $0, to: settings.currentDate())!
//        }
//        activityRepo.add(last21Days.shuffled().map { Activity.test(date: $0) })
//
//        subject.loadCatalog()
//        let activities = await(subject.$catalog.subscribe(on: DispatchQueue.main)).flatMap { $0.content }
//        
//        [
//            "Today",
//            "Yesterday",
//            "Tue",
//            "Mon",
//            "Sun",
//            "Sat",
//            "Fri",
//            "Last Thu",
//            "Last Wed",
//            "Last Tue",
//            "Last Mon",
//            "Last Sun",
//            "Last Sat",
//            "Last Fri",
//            "3/12/20",
//            "3/11/20",
//            "3/10/20",
//            "3/9/20",
//            "3/8/20",
//            "3/7/20",
//            "3/6/20"
//        ].enumerated().forEach {
//            XCTAssertEqual($0.element, activities[$0.offset].date)
//        }
//    }
}
