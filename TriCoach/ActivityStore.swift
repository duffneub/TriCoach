//
//  ActivityStore.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/11/21.
//

import Combine
import HealthKit
import Foundation

class ActivityStore : ObservableObject {
    private var calendar: Calendar = .current
    private var grouping: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear]
    private var subscriptions = Set<AnyCancellable>()
    private let activityRepo: ActivityRepository
    
    typealias Group = (date: Date, activities: [Activity])
    
    @Published var state: State = .ready
    @Published var catalog: [Group] = []
    
    init(activityRepo: ActivityRepository) {
        self.activityRepo = activityRepo
    }
    
    func loadCatalog() {
        guard case .ready = state else {
            return
        }
        state = .loading
        
        activityRepo.getAll()
            .assertNoFailure()
            .map { activities in
                Dictionary(grouping: activities) { activity -> Date in
                    self.calendar.date(from: self.calendar.dateComponents(self.grouping, from: activity.date))!
                }
                .sorted {  $0.key > $1.key }
                .map { (date: $0.key, activities: $0.value) }
            }
            .map {
                State.success($0)
            }
            .assign(to: &$state)
            
    }
    
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
