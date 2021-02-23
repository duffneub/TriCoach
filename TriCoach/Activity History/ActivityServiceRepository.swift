//
//  ActivityServiceRepository.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/5/21.
//

import Combine
import Foundation
import HealthKit
import CoreLocation

// MARK: - ActivityServiceRepository

class ActivityServiceRepository : ActivityRepository {
    enum Error : Swift.Error {
        case unavailable
    }
    
    private let service: ActivityService
    init(service: ActivityService) {
        self.service = service
    }

    private var subscriptions = Set<AnyCancellable>()
    
    func getAll() -> AnyPublisher<[Activity.Summary], Swift.Error> {
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

    func loadRoute(of activity: Activity.Summary) -> AnyPublisher<[CLLocationCoordinate2D]?, Swift.Error> {
        Result {
            guard service.isAvailable else {
                throw Error.unavailable
            }
        }
        .publisher
        .flatMap(self.service.requestAuthorization)
        .flatMap { self.service.getRoute(for: activity.id) }
        .eraseToAnyPublisher()
    }

    func loadHeartRate(of activity: Activity.Summary) -> AnyPublisher<[Double], Swift.Error> {
        Result {
            guard service.isAvailable else {
                throw Error.unavailable
            }
        }
        .publisher
        .flatMap(self.service.requestAuthorization)
        .flatMap { self.service.loadHeartRate(of: activity) }
        .eraseToAnyPublisher()
    }
}

// MARK: - ActivityService

protocol ActivityService {
    var isAvailable: Bool { get }
    func requestAuthorization() -> AnyPublisher<Void, Error>
    func getActivities() -> AnyPublisher<[Activity.Summary], Error>
    func getRoute(for activity: UUID) -> AnyPublisher<[CLLocationCoordinate2D]?, Error>
    func loadHeartRate(of activity: Activity.Summary) -> AnyPublisher<[Double], Error>
}

// MARK: - HKHealthStore + ActivityService

extension HKHealthStore : ActivityService {
    var isAvailable: Bool {
        Self.isHealthDataAvailable()
    }
    
    func requestAuthorization() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.requestAuthorization(
                toShare: nil,
                read: [
                    HKWorkoutType.workoutType(),
                    HKSeriesType.workoutRoute(),
                    HKQuantityType.quantityType(forIdentifier: .heartRate)!
                ]) { _, error in
                promise(error.map { .failure($0) } ?? .success(()))
            }
        }.eraseToAnyPublisher()
    }

    func getActivities() -> AnyPublisher<[Activity.Summary], Error> {
        Future { promise in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: NSCompoundPredicate(orPredicateWithSubpredicates: Activity.Summary.Sport.allCases.map {
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

    func getRoute(for activity: UUID) -> AnyPublisher<[CLLocationCoordinate2D]?, Error> {
        fetchSamples(
            sampleType: .workoutType(),
            predicate: HKQuery.predicateForObject(with: activity),
            limit: 1,
            sortDescriptors: nil
        )
        .map { ($0 as! [HKWorkout]).first! }
        .flatMap { workout in
            self.fetchSamples(
                sampleType: HKSeriesType.workoutRoute(),
                predicate: HKQuery.predicateForObjects(from: workout),
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            )
            .flatMap { samples -> AnyPublisher<[CLLocationCoordinate2D]?, Error> in
                guard let route = (samples as? [HKWorkoutRoute])?.first else {
                    return Just<[CLLocationCoordinate2D]?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
                }

                return self.workoutRouteQuery(route)
                    .map { $0.map { $0.coordinate } }
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    func loadHeartRate(of activity: Activity.Summary) -> AnyPublisher<[Double], Error> {
        fetchSamples(
            sampleType: .workoutType(),
            predicate: HKQuery.predicateForObject(with: activity.id),
            limit: 1,
            sortDescriptors: nil
        )
        .map { ($0 as! [HKWorkout]).first! }
        .flatMap(self.beatsPerMinute)
        .eraseToAnyPublisher()
    }

    private func beatsPerMinute(_ workout: HKWorkout) -> AnyPublisher<[Double], Error> {
        var intervalComps = DateComponents()
        intervalComps.second = 1

        return fetchStatisticsCollection(
            quantityType: HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            quantitySamplePredicate: HKQuery.predicateForObjects(from: workout),
            options: HKStatisticsOptions.discreteAverage,
            anchorDate: Date(),
            intervalComponents: intervalComps
        )
        .map { $0.statistics().map {
            $0.averageQuantity()!.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        } }
        .eraseToAnyPublisher()

    }

    private func fetchSamples(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?
    ) -> AnyPublisher<[HKSample], Error> {
        Future { promise in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: limit,
                sortDescriptors: sortDescriptors
            ) { _, samples, error in
                guard error == nil else {
                    promise(.failure(error!))
                    return
                }
                promise(.success(samples!))
            }

            self.execute(query)
        }.eraseToAnyPublisher()
    }

    private func fetchStatisticsCollection(
        quantityType: HKQuantityType,
        quantitySamplePredicate: NSPredicate?,
        options: HKStatisticsOptions,
        anchorDate: Date,
        intervalComponents: DateComponents
    ) -> AnyPublisher<HKStatisticsCollection, Error> {
        Future { promise in
            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: quantitySamplePredicate,
                options: options,
                anchorDate: anchorDate,
                intervalComponents: intervalComponents)
            query.initialResultsHandler = { _, result, error in
                guard error == nil else {
                    promise(.failure(error!))
                    return
                }
                promise(.success(result!))
            }

            self.execute(query)
        }.eraseToAnyPublisher()
    }

    private func workoutRouteQuery(_ workoutRoute: HKWorkoutRoute) -> AnyPublisher<[CLLocation], Error> {
        Future { promise in
            var route: [CLLocation] = []

            let query = HKWorkoutRouteQuery(route: workoutRoute) { _, locations, done, error in
                guard error == nil else {
                    return promise(.failure(error!))
                }
                route.append(contentsOf: locations!)

                if done {
                    promise(.success(route))
                }
            }
            self.execute(query)
        }.eraseToAnyPublisher()
    }
}

// MARK: - HKWorkout +

extension HKWorkout {
    func makeActivity() -> Activity.Summary? {
        guard let sport = workoutActivityType.sport,
              let distance = totalDistance?.doubleValue(for: .mile())
        else {
            return nil
        }
        
        return .init(
            id: uuid,
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

// MARK: - HKWorkoutActivityType +

extension HKWorkoutActivityType {
    init(_ sport: Activity.Summary.Sport) {
        switch sport {
        case .swim:
            self = .swimming
        case .bike:
            self = .cycling
        case .run:
            self = .running
        }
    }
    
    var sport: Activity.Summary.Sport? {
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
