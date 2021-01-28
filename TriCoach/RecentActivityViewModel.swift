//
//  RecentActivityViewModel.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import Foundation

class RecentActivityViewModel : ObservableObject {
    private let activityRepo: ActivityRepository
    
    init(activityRepo: ActivityRepository) {
        self.activityRepo = activityRepo
    }
    
    // MARK: - Access to Model
    
    @Published var recentActivity: [Section] = []
    
    // MARK: - Intents
    
    func loadRecentActivity() {
        activityRepo.getAll()
            .assertNoFailure()
            .map(groupByWeek)
            .assign(to: &$recentActivity)
    }
    
    private func groupByWeek(_ activities: [Activity]) -> [Section] {
        Dictionary(grouping: activities) { activity -> DateComponents in
            var comps = Calendar.current.dateComponents([.year, .weekOfYear], from: activity.date)
            comps.weekday = 1 // Set to first day of week
            return comps
        }.sorted { lhs, rhs -> Bool in
            let lhs = Calendar.current.date(from: lhs.key) ?? .distantPast
            let rhs = Calendar.current.date(from: rhs.key) ?? .distantPast
            return lhs > rhs
        }.map {
            Section(activities: $1)
        }
    }
}

// MARK: - RecentActivityViewModel.Section

extension RecentActivityViewModel {
    struct Section {
//        let title: String
        let activities: [Activity]
    }
}

//fileprivate extension DateComponents {
//    func title(inRelationTo date: Date) -> String {
//        ""
//    }
//}
