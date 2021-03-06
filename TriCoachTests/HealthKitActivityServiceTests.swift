//
//  HealthKitActivityServiceTests.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 2/3/21.
//

import HealthKit
import XCTest
@testable import TriCoach

class HealthKitActivityServiceTests : XCTestCase {
    
    func testInfoPlist_shouldContainReasonToReadHealthData() {
        let bundle = Bundle(identifier: "com.duffneubauer.TriCoach")!
        let reason = bundle.object(forInfoDictionaryKey: "NSHealthShareUsageDescription") as? String
        
        XCTAssertEqual("TriCoach reads your health information to display activity history.", reason)
    }
    
    func testMakeActivityFromHKWorkout() {
        let date = Date()
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .swim,
                workout: "Pool Swim",
                duration: .init(value: 100, unit: .seconds),
                distance: .init(value: 1, unit: .miles),
                date: date),
            HKWorkout(
                activityType: .swimming,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .mile(), doubleValue: 1),
                metadata: nil).makeActivity()
        )
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .swim,
                workout: "Pool Swim",
                duration: .init(value: 100, unit: .seconds),
                distance: .init(value: 1, unit: .miles),
                date: date),
            HKWorkout(
                activityType: .swimming,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .mile(), doubleValue: 1),
                metadata: [
                    HKMetadataKeySwimmingLocationType: NSNumber(value: HKWorkoutSwimmingLocationType.pool.rawValue)
                ]).makeActivity()
        )
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .swim,
                workout: "Open Water Swim",
                duration: .init(value: 100, unit: .seconds),
                distance: .init(value: 1, unit: .miles),
                date: date),
            HKWorkout(
                activityType: .swimming,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .mile(), doubleValue: 1),
                metadata: [
                    HKMetadataKeySwimmingLocationType: NSNumber(value: HKWorkoutSwimmingLocationType.openWater.rawValue)
                ]).makeActivity()
        )
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .bike,
                workout: "Outdoor Ride",
                duration: .init(value: 100, unit: .minutes),
                distance: .init(value: 1, unit: .kilometers),
                date: date),
            HKWorkout(
                activityType: .cycling,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100 * 60,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: 1),
                metadata: nil).makeActivity()
        )
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .bike,
                workout: "Outdoor Ride",
                duration: .init(value: 100, unit: .minutes),
                distance: .init(value: 1, unit: .kilometers),
                date: date),
            HKWorkout(
                activityType: .cycling,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100 * 60,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: 1),
                metadata: [
                    HKMetadataKeyIndoorWorkout: false
                ]).makeActivity()
        )
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .bike,
                workout: "Indoor Ride",
                duration: .init(value: 100, unit: .minutes),
                distance: .init(value: 1, unit: .kilometers),
                date: date),
            HKWorkout(
                activityType: .cycling,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100 * 60,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: 1),
                metadata: [
                    HKMetadataKeyIndoorWorkout: true
                ]).makeActivity()
        )
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .run,
                workout: "Outdoor Run",
                duration: .init(value: 100, unit: .hours),
                distance: .init(value: 1, unit: .meters),
                date: date),
            HKWorkout(
                activityType: .running,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100 * 60 * 60,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .meter(), doubleValue: 1),
                metadata: nil).makeActivity()
        )
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .run,
                workout: "Outdoor Run",
                duration: .init(value: 100, unit: .hours),
                distance: .init(value: 1, unit: .meters),
                date: date),
            HKWorkout(
                activityType: .running,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100 * 60 * 60,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .meter(), doubleValue: 1),
                metadata: [
                    HKMetadataKeyIndoorWorkout: false
                ]).makeActivity()
        )
        
        XCTAssertEqual(
            Activity.Summary(
                sport: .run,
                workout: "Indoor Run",
                duration: .init(value: 100, unit: .hours),
                distance: .init(value: 1, unit: .meters),
                date: date),
            HKWorkout(
                activityType: .running,
                start: date,
                end: date.addingTimeInterval(100000),
                duration: 100 * 60 * 60,
                totalEnergyBurned: nil,
                totalDistance: HKQuantity(unit: .meter(), doubleValue: 1),
                metadata: [
                    HKMetadataKeyIndoorWorkout: true
                ]).makeActivity()
        )
    }
}
