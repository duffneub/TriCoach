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

    @Published var details: [Activity.Summary.ID: AsyncState<Activity.Details>] = [:]

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

    func details(of activity: Activity.Summary.ID) -> AsyncState<Activity.Details> {
        details[activity, default: .ready]
    }

    func loadDetails(of activity: Activity.Summary.ID) {
        guard details[activity] == nil else {
            return
        }

        details[activity] = .loading

        activityRepo.loadDetails(of: activity)
            .assertNoFailure()
            .map { AsyncState.success($0) }
            .map {
                var update = self.details
                update[activity] = $0
                return update
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$details)
    }

    private func updateCatalog() -> State {
        guard activities.count > 0 else {
            return .ready
        }
        let groups = Dictionary(grouping: activities) { activity -> Date in
            calendar.date(from: calendar.dateComponents(grouping, from: activity.date))!
        }
        .sorted {  $0.key > $1.key }
        .map { (date: $0.key, activities: $0.value.sorted()) }

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
