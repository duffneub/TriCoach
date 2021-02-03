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
    private let categoryComponents: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear]
    
    var calendar: Calendar = .current {
        didSet {
            categoryFormatter.calendar = calendar
            activityDateFormatter.calendar = calendar
        }
    }
    
    var getCurrentDate: () -> Date = Date.init {
        didSet {
            categoryFormatter.currentDate = getCurrentDate()
            activityDateFormatter.currentDate = getCurrentDate()
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
                        locale: calendar.locale ?? .current,
                        dateFormatter: activityDateFormatter)
                }.sorted())
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
    private let locale: Locale
    private let dateFormatter: DateFormatter
    
    var sport: Activity.Sport {
        activity.sport
    }
    
    var title: String {
        activity.workout
    }
    
    var summary: String {
        [hoursAndMinutesString(from: activity.duration), sportDistanceString(from: activity.distance)]
            .joined(separator: " · ")
    }
    
    var date: String {
        dateFormatter.string(from: activity.date)
    }

    init(activity: Activity, locale: Locale, dateFormatter: DateFormatter) {
        self.activity = activity
        self.locale = locale
        self.dateFormatter = dateFormatter
    }

    private func hoursAndMinutesString(from duration: Measurement<UnitDuration>) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.numberFormatter.maximumFractionDigits = 1

        let total = duration.converted(to: .hours)
        let hours = Measurement<UnitDuration>(value: total.value.rounded(.towardZero), unit: .hours)
        let minutes = (total - hours).converted(to: .minutes)
        
        let durationStrings: [String?] = [
            hours.value >= 1 ? formatter.string(from: hours) : nil,
            minutes.value >= 1 ? formatter.string(from: minutes) : nil
        ]
        
        return durationStrings.compactMap { $0 }.joined(separator: " ")
    }
    
    private func sportDistanceString(from length: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.numberFormatter.locale = locale
        formatter.unitStyle = .medium
        
        var distance = activity.distance
        if activity.sport == .swim {
            formatter.unitOptions = .providedUnit
            formatter.numberFormatter.maximumFractionDigits = 0
            distance.convert(to: locale.usesMetricSystem ? .meters : .yards)
        } else {
            formatter.unitOptions = .providedUnit
            formatter.numberFormatter.maximumFractionDigits = 1
            distance.convert(to: locale.usesMetricSystem ? .kilometers : .miles)
        }
        
        return formatter.string(from: distance)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.activity.date > rhs.activity.date
    }
}
