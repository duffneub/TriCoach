//
//  PreviewData.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import Foundation

class TestActivityStore : ActivityStore {
    init() {
        super.init(
            activityRepo: TestActivityRepository(),
            calendar: Just<Calendar>(.current).eraseToAnyPublisher())
    }
}

// MARK: -

import CoreLocation

fileprivate struct TestActivityRepository : ActivityRepository {
    let delay: TimeInterval
    let activities: [Activity]

    init(delay: TimeInterval = 0) {
        self.delay = delay

        self.activities = (0..<16).map {
            Activity(sport: Activity.Sport.allCases[$0 % 3],
                  workout: "\(Activity.Sport.allCases[$0 % 3])",
                  duration: .init(value: Double(Int.random(in: 30..<120)), unit: .minutes),
                  distance: .init(value: Double(Int.random(in: 1..<15)), unit: .miles),
                  date: Calendar.current.date(byAdding: .day, value: -1 * $0, to: .init())!)
        }
    }

    func getAll() -> AnyPublisher<[Activity], Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                promise(.success(PreviewData.activities))
            }
        }
        .eraseToAnyPublisher()
    }

    func loadRoute(of activity: Activity) -> AnyPublisher<[CLLocationCoordinate2D]?, Swift.Error> {
        Just<[CLLocationCoordinate2D]?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

struct PreviewData {
    static let activities: [Activity] = [
        .init(sport: .run,
              workout: "Recovery",
              duration: .init(value: 49, unit: .minutes),
              distance: .init(value: 7.01, unit: .kilometers),
              date: Date()),
        .init(sport: .swim,
              workout: "Threshold Swim",
              duration: .init(value: 37, unit: .minutes),
              distance: .init(value: 1_367, unit: .yards),
              date: Calendar.current.date(byAdding: .day, value: -1, to: .init())!),
        .init(sport: .bike,
              workout: "Aerobic Endurance",
              duration: .init(value: 169, unit: .minutes),
              distance: .init(value: 80.24, unit: .kilometers),
              date: Calendar.current.date(byAdding: .day, value: -2, to: .init())!),
        .init(sport: .swim,
              workout: "Aerobic Endurance",
              duration: .init(value: 45, unit: .minutes),
              distance: .init(value: 2_100, unit: .yards),
              date: Calendar.current.date(byAdding: .day, value: -3, to: .init())!),
        .init(sport: .run,
              workout: "Recovery",
              duration: .init(value: 49, unit: .minutes),
              distance: .init(value: 7.01, unit: .kilometers),
              date: Calendar.current.date(byAdding: .day, value: -4, to: .init())!),
        .init(sport: .swim,
              workout: "Threshold Swim",
              duration: .init(value: 37, unit: .minutes),
              distance: .init(value: 1_367, unit: .yards),
              date: Calendar.current.date(byAdding: .day, value: -5, to: .init())!),
        .init(sport: .bike,
              workout: "Aerobic Endurance",
              duration: .init(value: 169, unit: .minutes),
              distance: .init(value: 80.24, unit: .kilometers),
              date: Calendar.current.date(byAdding: .day, value: -6, to: .init())!),
        .init(sport: .swim,
              workout: "Aerobic Endurance",
              duration: .init(value: 45, unit: .minutes),
              distance: .init(value: 2_100, unit: .yards),
              date: Calendar.current.date(byAdding: .day, value: -7, to: .init())!),
        .init(sport: .run,
              workout: "Recovery",
              duration: .init(value: 49, unit: .minutes),
              distance: .init(value: 7.01, unit: .kilometers),
              date: Calendar.current.date(byAdding: .day, value: -8, to: .init())!),
        .init(sport: .swim,
              workout: "Threshold Swim",
              duration: .init(value: 37, unit: .minutes),
              distance: .init(value: 1_367, unit: .yards),
              date: Calendar.current.date(byAdding: .day, value: -9, to: .init())!),
        .init(sport: .bike,
              workout: "Aerobic Endurance",
              duration: .init(value: 169, unit: .minutes),
              distance: .init(value: 80.24, unit: .kilometers),
              date: Calendar.current.date(byAdding: .day, value: -10, to: .init())!),
        .init(sport: .swim,
              workout: "Aerobic Endurance",
              duration: .init(value: 45, unit: .minutes),
              distance: .init(value: 2_100, unit: .yards),
              date: Calendar.current.date(byAdding: .day, value: -11, to: .init())!),
        .init(sport: .run,
              workout: "Recovery",
              duration: .init(value: 49, unit: .minutes),
              distance: .init(value: 7.01, unit: .kilometers),
              date: Calendar.current.date(byAdding: .day, value: -12, to: .init())!),
        .init(sport: .swim,
              workout: "Threshold Swim",
              duration: .init(value: 37, unit: .minutes),
              distance: .init(value: 1_367, unit: .yards),
              date: Calendar.current.date(byAdding: .day, value: -13, to: .init())!),
        .init(sport: .bike,
              workout: "Aerobic Endurance",
              duration: .init(value: 169, unit: .minutes),
              distance: .init(value: 80.24, unit: .kilometers),
              date: Calendar.current.date(byAdding: .day, value: -14, to: .init())!),
        .init(sport: .swim,
              workout: "Aerobic Endurance",
              duration: .init(value: 45, unit: .minutes),
              distance: .init(value: 2_100, unit: .yards),
              date: Calendar.current.date(byAdding: .day, value: -15, to: .init())!)
    ]
    
    struct FakeActivityRepository : ActivityRepository {
        let delay: TimeInterval
        
        init(delay: TimeInterval = 0) {
            self.delay = delay
        }
        
        func getAll() -> AnyPublisher<[Activity], Error> {
            Future { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    promise(.success(PreviewData.activities))
                }
            }
            .eraseToAnyPublisher()
        }

        func loadRoute(of activity: Activity) -> AnyPublisher<[CLLocationCoordinate2D]?, Swift.Error> {
            Just<[CLLocationCoordinate2D]?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
}
