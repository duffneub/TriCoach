//
//  ActivityRepository.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import Foundation
import HealthKit

protocol ActivityRepository {
    func getAll() -> AnyPublisher<[Activity], Error>
}

protocol ActivityService {
    var isAvailable: Bool { get }
    func requestAuthorization() -> AnyPublisher<Bool, Error>
    func getActivities() -> AnyPublisher<[Activity], Error>
}

extension HKHealthStore : ActivityService {
    var isAvailable: Bool {
        Self.isHealthDataAvailable()
    }
    
    func requestAuthorization() -> AnyPublisher<Bool, Error> {
        Future { promise in
            self.requestAuthorization(toShare: nil, read: [HKWorkoutType.workoutType()]) { success, error in
                promise(error.map { .failure($0) } ?? .success(success))
            }
        }.eraseToAnyPublisher()
    }
    
    // TODO: Extract predicate, limit, sort into `ActivityServiceQuery` object and test
    func getActivities() -> AnyPublisher<[Activity], Error> {
        Future { promise in
            let activityTypes: [HKWorkoutActivityType] = [.swimming, .cycling, .running]
            
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: NSCompoundPredicate(orPredicateWithSubpredicates: activityTypes.map { HKQuery.predicateForWorkouts(with: $0) }),
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
            ) { _, samples, error in
                guard error == nil else {
                    promise(.failure(error!))
                    return
                }
                let samples = samples as! [HKWorkout]
                promise(.success(samples.compactMap { $0.makeActivity() }))
            }
            
            self.execute(query)
        }.eraseToAnyPublisher()
    }
}

// TODO: Test Me
extension HKWorkout {
    func makeActivity() -> Activity? {
        guard let sport = workoutActivityType.sport,
              let distance = totalDistance?.doubleValue(for: .mile())
        else {
            return nil
        }
        
        return .init(
            sport: sport,
            workout: "",
            duration: .init(value: duration, unit: .seconds),
            distance: .init(value: distance, unit: .miles),
            date: startDate)
    }
}

// TODO: Test Me
extension HKWorkoutActivityType {
    init(_ sport: Activity.Sport) {
        switch sport {
        case .swim:
            self = .swimming
        case .run:
            self = .running
        case .bike:
            self = .cycling
        }
    }
    
    var sport: Activity.Sport? {
        switch self {
        case .swimming:
            return .swim
        case .cycling:
            return .bike
        case .running:
            return .run
        default:
            return nil
        }
    }
}
