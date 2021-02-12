//
//  ActivityStore.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/11/21.
//

import Combine
import HealthKit
import Foundation

class ActivityStore {
    typealias Group = (date: Date, activities: [Activity])

    private let grouping: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear]
    private let activityRepo: ActivityRepository

    private var calendar: Calendar = .current
    private var activities: [Activity] = []

    @Published var state: State = .ready

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
            .assign(to: &$state)
            
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
