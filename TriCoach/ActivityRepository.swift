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

class ActivityServiceRepository : ActivityRepository {
    enum Error : Swift.Error {
        case unavailable
    }
    
    private let service: ActivityService
    init(service: ActivityService) {
        self.service = service
    }
    
    func getAll() -> AnyPublisher<[Activity], Swift.Error> {
        Result {
            guard service.isAvailable else {
                throw Error.unavailable
            }
        }
        .publisher
        .flatMap(self.service.requestAuthorization)
        .flatMap(self.service.getActivities)
        .eraseToAnyPublisher()
    }
}

protocol ActivityService {
    var isAvailable: Bool { get }
    func requestAuthorization() -> AnyPublisher<Void, Error>
    func getActivities() -> AnyPublisher<[Activity], Error>
}

extension HKHealthStore : ActivityService {
    var isAvailable: Bool {
        Self.isHealthDataAvailable()
    }
    
    func requestAuthorization() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.requestAuthorization(toShare: nil, read: [HKWorkoutType.workoutType()]) { _, error in
                promise(error.map { .failure($0) } ?? .success(()))
            }
        }.eraseToAnyPublisher()
    }

    func getActivities() -> AnyPublisher<[Activity], Error> {
        Future { promise in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: NSCompoundPredicate(orPredicateWithSubpredicates: Activity.Sport.allCases.map {
                    HKQuery.predicateForWorkouts(with: .init($0))
                }),
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
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

extension HKWorkout {
    func makeActivity() -> Activity? {
        guard let sport = workoutActivityType.sport,
              let distance = totalDistance?.doubleValue(for: .mile())
        else {
            return nil
        }
        
        return .init(
            sport: sport,
            workout: name,
            duration: .init(value: duration, unit: .seconds),
            distance: .init(value: distance, unit: .miles),
            date: startDate)
    }
    
    private var name: String {
        switch workoutActivityType {
        case .cycling, .running:
            let isIndoorWorkout = (metadata?[HKMetadataKeyIndoorWorkout] as? Bool) ?? false
            return ( isIndoorWorkout ? "Indoor" : "Outdoor") + " " + workoutActivityType.name
        case .swimming:
            var isPoolSwim = true
            if let rawValue = metadata?[HKMetadataKeySwimmingLocationType] as? NSNumber,
               let swimLocation = HKWorkoutSwimmingLocationType(rawValue: rawValue.intValue)
            {
                isPoolSwim = swimLocation == .pool
            }
            
            return ( isPoolSwim ? "Pool" : "Open Water") + " " + workoutActivityType.name
        default:
            return ""
        }
    }
}

extension HKWorkoutActivityType {
    init(_ sport: Activity.Sport) {
        switch sport {
        case .swim:
            self = .swimming
        case .bike:
            self = .cycling
        case .run:
            self = .running
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
    
    var name: String {
        switch self {
        case .swimming:
            return "Swim"
        case .cycling:
            return "Ride"
        case .running:
            return "Run"
        default:
            return ""
        }
    }
}
