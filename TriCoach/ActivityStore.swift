//
//  ActivityStore.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/11/21.
//

import Foundation

class ActivityStore {
    private var calendar: Calendar = .current
    private var grouping: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear]
    
    typealias Group = (date: Date, activities: [Activity])
    
    @Published var catalog: [Group] = []
    
    func update(_ activities: [Activity]) {
        catalog = Dictionary(grouping: activities) { activity -> Date in
            calendar.date(from: calendar.dateComponents(grouping, from: activity.date))!
        }
        .sorted {  $0.key > $1.key }
        .map { (date: $0.key, activities: $0.value) }
    }
}
