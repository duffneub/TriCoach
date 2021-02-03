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
    private let categoryFormatter = GranularRelativeDateFormatter(granularity: .week)
    private let activityDateFormatter = GranularRelativeDateFormatter(granularity: .day)
    private let measurementFormatter = MeasurementFormatter()
    private let categoryComponents: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear]
    
    var calendar: Calendar = .current {
        didSet {
            categoryFormatter.calendar = calendar
            activityDateFormatter.calendar = calendar
            measurementFormatter.locale = calendar.locale
        }
    }
    
    var currentDate: () -> Date = Date.init {
        didSet {
            categoryFormatter.currentDate = currentDate()
            activityDateFormatter.currentDate = currentDate()
        }
    }
    
    init(activityRepo: ActivityRepository) {
        self.activityRepo = activityRepo
    }
    
    // MARK: - Access to Model
    
    @Published var recentActivity: [Category<ActivitySummaryViewModel>] = []
    
    // MARK: - Intents
    
    func loadRecentActivity() {
        activityRepo.getAll()
            .assertNoFailure()
            .map(group(activities:))
            .assign(to: &$recentActivity)
    }
    
    private func group(activities: [Activity]) -> [Category<ActivitySummaryViewModel>] {
        Dictionary(grouping: activities) { activity -> Date in
            calendar.date(from: calendar.dateComponents(categoryComponents, from: activity.date))!
        }
        .sorted {  $0.key > $1.key }
        .enumerated()
        .compactMap { offset, item in
            Category(
                title: categoryFormatter.string(from: item.key),
                position: offset,
                content: item.value.map {
                    .init(
                        activity: $0,
                        dateFormatter: activityDateFormatter,
                        measurementFormatter: measurementFormatter)
                }.sorted())
        }
    }
}

// MARK: - Category

struct Category<Content : Identifiable & Comparable> : Identifiable, Comparable {
    let id = UUID()
    let title: String
    let position: Int
    let content: [Content]
    
    // MARK: - Comparable

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.position < rhs.position
    }
}

// MARK: - ActivitySummaryViewModel

struct ActivitySummaryViewModel : Identifiable, Comparable {
    private let activity: Activity
    private let dateFormatter: DateFormatter
    private let measurementFormatter: MeasurementFormatter
    
    let id = UUID()
    
    var sport: Activity.Sport {
        activity.sport
    }
    
    var title: String {
        activity.workout
    }
    
    var summary: String {
        [
            measurementFormatter.hoursAndMinutes(from: activity.duration),
            activity.sport == .swim ?
                measurementFormatter.swimDistance(from: activity.distance) :
                measurementFormatter.bikeOrRunDistance(from: activity.distance)
        ]
        .joined(separator: " · ")
    }
    
    var date: String {
        dateFormatter.string(from: activity.date)
    }

    init(activity: Activity, dateFormatter: DateFormatter, measurementFormatter: MeasurementFormatter) {
        self.activity = activity
        self.dateFormatter = dateFormatter
        self.measurementFormatter = measurementFormatter
    }
    
    // MARK: - Comparable

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.activity.date > rhs.activity.date
    }
}
