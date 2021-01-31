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
    private let dateFormatter: DateFormatter
    private let calendar: Calendar
    
    init(activityRepo: ActivityRepository, dateFormatter: DateFormatter = .init(), calendar: Calendar = .current) {
        self.activityRepo = activityRepo
        self.dateFormatter = dateFormatter
        self.calendar = calendar
    }
    
    // MARK: - Access to Model
    
    @Published var recentActivity: [Category<ActivitySummaryViewModel>] = []
    
    // MARK: - Intents
    
    func loadRecentActivity() {
        activityRepo.getAll()
            .assertNoFailure()
            .map { activities in
                self.group(activities, by: [.yearForWeekOfYear, .weekOfYear])
            }
            .assign(to: &$recentActivity)
    }
    
    private func group(
        _ activities: [Activity], by components: Set<Calendar.Component>
    ) -> [Category<ActivitySummaryViewModel>] {
        Dictionary(grouping: activities) { activity -> Date in
            calendar.date(from: calendar.dateComponents(components, from: activity.date))!
        }
        .sorted {  $0.key > $1.key }
        .enumerated()
        .compactMap { offset, item in
            Category(
                title: dateFormatter.string(from: item.key),
                position: offset,
                content: item.value.map { .init(activity: $0, dateFormatter: dateFormatter) }.sorted())
        }
    }
}

// MARK: - Category

struct Category<Content : Comparable> : Comparable {
    let title: String
    let position: Int
    let content: [Content]

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.position < rhs.position
    }
}

// MARK: - ActivitySummaryViewModel

struct ActivitySummaryViewModel : Comparable {
    private let activity: Activity
    let date: String

    init(activity: Activity, dateFormatter: DateFormatter) {
        self.activity = activity
        self.date = dateFormatter.string(from: activity.date)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.activity.date > rhs.activity.date
    }
}
