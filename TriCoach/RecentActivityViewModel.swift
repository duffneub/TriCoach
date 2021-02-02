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
    private let dateFormatter: GranularRelativeDateFormatter
    var calendar: Calendar = .current
    
    var getCurrentDate: () -> Date = Date.init
    
    init(activityRepo: ActivityRepository, dateFormatter: GranularRelativeDateFormatter = .init()) {
        self.activityRepo = activityRepo
        self.dateFormatter = dateFormatter
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
        dateFormatter.currentDate = getCurrentDate()
        
        return Dictionary(grouping: activities) { activity -> Date in
            calendar.date(from: calendar.dateComponents(components, from: activity.date))!
        }
        .sorted {  $0.key > $1.key }
        .enumerated()
        .compactMap { offset, item in
            Category(
                title: dateFormatter.string(from: item.key, toGranularity: .week),//categoryTitle(from: item.key),
                position: offset,
                content: item.value.map {
                    .init(
                        activity: $0,
                        date: dateFormatter.string(from: $0.date, toGranularity: .day),
                        locale: calendar.locale ?? .current)
                }.sorted())
        }
    }
    
    private func categoryTitle(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM d")
        
        return formatter.string(from: date)
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

class GranularRelativeDateFormatter : Formatter {
    var currentDate: Date?
    var calendar: Calendar = .current
    
    override func string(for obj: Any?) -> String? {
        guard let date = obj as? Date else {
            return  nil
        }
        
        return string(from: date, toGranularity: .day)
    }
    
    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        false
    }
    
    // Day => Today, Yesterday, Day before Yesterday, Wednesday, Tuesday, ..., last Saturday, ..., Month/Day/Year
    // Week => This Week, Last Week, ..., Month/Day/Year
    // Month => This Month, Last Month, March, February, ..., Last
    
    // 1. Is Same Unit => Named Relative Unit || This Unit
    // 2. Is Same Unit as -1 => Named Relative Unit || Last
    // 3. If named unit & is > -1 * num_named_units => Named Unit
    // 4. If named unit & is > -2 * num_named_units => Last \(Named Unit)
    
    func string(from date: Date, toGranularity granularity: Granularity) -> String {
        let today = currentDate ?? Date()
    
        if granularity == .day {
            if calendar.isDate(date, inSameDayAs: today) {
                return "Today"
            }
            
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if calendar.isDate(date, inSameDayAs: yesterday) {
                return "Yesterday"
            }
            
            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today)!
            if date > lastWeek {
                return dayOfWeek(from: date)
            }
            
            let twoWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -2, to: today)!
            if date > twoWeeksAgo {
                return "Last \(dayOfWeek(from: date))"
            }
            
            return shortString(from: date)
        } else {
            if calendar.compare(date, to: today, toGranularity: .weekOfYear) == .orderedSame {
                return "This Week"
            }

            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today)!
            if calendar.compare(date, to: lastWeek, toGranularity: .weekOfYear) == .orderedSame {
                return "Last Week"
            }
         
            return weekString(from: date)
        }
        
        
    }
    
//    private func relativeToToday(_ date: Date) -> RelativeDateComparisonResult {
//        let today = currentDate ?? Date()
//
//        if calendar.isDate(date, inSameDayAs: today) {
//            return .today
//        }
//
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
//        if calendar.isDate(date, inSameDayAs: yesterday) {
//            return .yesterday
//        }
//
//        if calendar.compare(date, to: today, toGranularity: .weekOfYear) == .orderedSame {
//            return .thisWeek
//        }
//
//        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today)!
//        if calendar.compare(date, to: lastWeek, toGranularity: .weekOfYear) == .orderedSame {
//            return .lastWeek
//        }
//
//        return .other
//    }
    
    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter.string(from: date)
    }
    
    private func shortString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("M/d/yy")
        return formatter.string(from: date)
    }
    
    private func weekString(from date: Date) -> String {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM d")
        return formatter.string(from: startOfWeek)
    }
    
    // MARK: - Granularity
    
    enum Granularity {
        case day
        case week
    }
    
    // MARK: - RelativeDateComparisonResult
    
    private enum RelativeDateComparisonResult {
        case today
        case yesterday
        case thisWeek
        case lastWeek
        case other
    }
}

// MARK: - ActivitySummaryViewModel

struct ActivitySummaryViewModel : Comparable {
    private let activity: Activity
    private let locale: Locale
    
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
    
    let date: String

    init(activity: Activity, date: String, locale: Locale) {
        self.activity = activity
        self.date = date
        self.locale = locale
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

extension Date {
    func previousWeek(_ calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .weekOfYear, value: -1, to: self)!
    }
}
