//
//  PreviewData.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import Foundation

struct PreviewData {
    static let recentActivities: [Activity] = [
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
    
    static var activityViewModel = TestActivityViewModel(
        sport: .bike,
        name: "Aerobic Endurance",
        shortDate: "Sun, Dec 13",
        longDate: "Sun, Dec 13 2020",
        time: "7:01 - 8:29 AM",
        measurements: [
            TestActivityViewModel.TestMeasurementViewModel(
                name: "Duration",
                value: "01:27:34",
                unit: "elapsed"),
            TestActivityViewModel.TestMeasurementViewModel(
                name: "Distance",
                value: "56.5",
                unit: "kilometers"),
            TestActivityViewModel.TestMeasurementViewModel(
                name: "Normalized Power",
                value: "300",
                unit: "watts/kg"),
            TestActivityViewModel.TestMeasurementViewModel(
                name: "Avg. Heart Rate",
                value: "150",
                unit: "beats per minute"),
        ])
    
    struct TestActivityViewModel : ActivityViewModel {
        let sport: Activity.Sport
        let name: String
        let shortDate: String
        let longDate: String
        let time: String
        let measurements: [TestMeasurementViewModel]
        
        struct TestMeasurementViewModel : MeasurementViewModel {
            let name: String
            let value: String
            let unit: String
            
            var id: String {
                name
            }
        }
    }
    
    struct FakeActivityRepository : ActivityRepository {
        let delay: TimeInterval
        
        init(delay: TimeInterval = 0) {
            self.delay = delay
        }
        
        func getAll() -> AnyPublisher<[Activity], Error> {
            Future { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    promise(.success(PreviewData.recentActivities))
                }
            }
            .eraseToAnyPublisher()
        }
    }
}
