//
//  GranularRelativeDateFormatter.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/2/21.
//

import Foundation

class RelativeDateFormatter : DateFormatter {
    var currentDate = Date()
}

class GranularRelativeDateFormatter : RelativeDateFormatter {
    var granularity: Granularity
    
    init(granularity: Granularity = .day) {
        self.granularity = granularity
        super.init()
    }
    
    required init?(coder: NSCoder) {
        self.granularity = .day
        super.init(coder: coder)
    }
    
    override func string(from date: Date) -> String {
        let formatter = granularity.dateFormatter()
        formatter.currentDate = currentDate
        
        return formatter.string(from: date)
    }
    
    // MARK: - Granularity
    
    enum Granularity {
        case day
        case week
        
        fileprivate func dateFormatter() -> RelativeDateFormatter {
            switch self {
            case .day:
                return RelativeDayFormatter()
            default:
                return RelativeWeekFormatter()
            }
        }
    }
    
    // MARK: - RelativeDayFormatter
    
    private class RelativeDayFormatter : RelativeDateFormatter {
        
        override func string(from date: Date) -> String {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                return "Today"
            }
            
            let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if calendar.isDate(date, inSameDayAs: yesterday) {
                return "Yesterday"
            }
            
            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
            if date > lastWeek {
                setLocalizedDateFormatFromTemplate("EEEE")
                return super.string(from: date)
            }
            
            let twoWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -2, to: currentDate)!
            if date > twoWeeksAgo {
                setLocalizedDateFormatFromTemplate("EEEE")
                return "Last \(super.string(from: date))"
            }
            
            setLocalizedDateFormatFromTemplate("M/d/yy")
            return super.string(from: date)
        }
    }
    
    // MARK: - RelativeWeekFormatter
    
    private class RelativeWeekFormatter : RelativeDateFormatter {
        override func string(from date: Date) -> String {
            if calendar.compare(date, to: currentDate, toGranularity: .weekOfYear) == .orderedSame {
                return "This Week"
            }

            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
            if calendar.compare(date, to: lastWeek, toGranularity: .weekOfYear) == .orderedSame {
                return "Last Week"
            }
         
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            setLocalizedDateFormatFromTemplate("MMMM d")
            return super.string(from: startOfWeek)
        }
    }
}
