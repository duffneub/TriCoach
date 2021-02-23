//
//  ActivityCatalog.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/11/21.
//

import Combine
import HealthKit
import Foundation
import CoreLocation

struct Section : Identifiable {
    let date: Date
    let activities: [Activity.Summary]

    var id: Int {
        var hasher = Hasher()
        activities.forEach { hasher.combine($0.id) }
        return hasher.finalize()
    }
}

class ActivityCatalog : ObservableObject {
    typealias Group = (date: Date, activities: [Activity.Summary])

    private let grouping: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear]
    private let activityRepo: ActivityRepository

    private var calendar: Calendar = .current
    private var activities: [Activity.Summary] = []

    @Published var routes: [Activity.Summary.ID: AsyncState<[CLLocationCoordinate2D]?>] = [:]
    @Published var heartRate: [Activity.Summary.ID: AsyncState<[Double]>] = [:]

    @Published var state: State = .ready
    @Published var selectedActivity: Activity.Summary?

    var isLoading: Bool {
        state.isLoading
    }

    var sections: [Section]? {
        state.catalog.map { $0.map { Section(date: $0.date, activities: $0.activities) } }
    }

    private var subscriptions = Set<AnyCancellable>()
    
    init(activityRepo: ActivityRepository, calendar: AnyPublisher<Calendar, Never>) {
        self.activityRepo = activityRepo
        calendar
            .handleEvents(receiveOutput: { self.calendar = $0 })
            .map { _ in self.updateCatalog() }
            .assign(to: &$state)
    }
    
    func loadCatalog() {
        guard case .ready = state else {
            return
        }
        state = .loading
        
        activityRepo.getAll()
            .assertNoFailure()
            .handleEvents(receiveOutput: { self.activities = $0 })
            .map { _ in self.updateCatalog() }
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
            
    }

    func route(of activity: Activity.Summary) -> AsyncState<[CLLocationCoordinate2D]?> {
        routes[activity.id, default: .ready]
    }

    func loadRoute(of activity: Activity.Summary) {
        guard routes[activity.id] == nil else {
            return
        }

        routes[activity.id] = .loading

        activityRepo.loadRoute(of: activity)
            .assertNoFailure()
            .map { AsyncState.success($0) }
            .map {
                var newRoutes = self.routes
                newRoutes[activity.id] = $0
                return newRoutes
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$routes)
    }

    func heartRate(of activity: Activity.Summary) -> AsyncState<[Double]> {
        heartRate[activity.id, default: .ready]
    }

    func loadHeartRate(of activity: Activity.Summary) {
        guard heartRate[activity.id] == nil else {
            return
        }

        heartRate[activity.id] = .loading

        activityRepo.loadHeartRate(of: activity)
            .assertNoFailure()
            .handleEvents(receiveOutput: { samples in
                samples.forEach {
                    print($0)
                }
            })
            .map { AsyncState.success($0) }
            .map {
                var new = self.heartRate
                new[activity.id] = $0
                return new
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$heartRate)
    }

    private func updateCatalog() -> State {
        guard activities.count > 0 else {
            return .ready
        }
        let groups = Dictionary(grouping: activities) { activity -> Date in
            calendar.date(from: calendar.dateComponents(grouping, from: activity.date))!
        }
        .sorted {  $0.key > $1.key }
        .map { (date: $0.key, activities: $0.value) }

        return .success(groups)
    }

    func select(_ activity: Activity.Summary) {
        selectedActivity = activity
    }
    
    func deselect(_ activity: Activity.Summary) {
        selectedActivity = nil
    }

    // MARK: - State
    
    enum State {
        case ready
        case loading
        case success([Group])

        var isLoading: Bool {
            if case .loading = self {
                return true
            }

            return false
        }

        var catalog: [Group]? {
            if case let .success(catalog) = self {
                return catalog
            }

            return nil
        }
    }
}

// MARK: - State

enum AsyncState<T> {
    case ready
    case loading
    case success(T)

    var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    var value: T? {
        if case let .success(value) = self {
            return value
        }

        return nil
    }
}
