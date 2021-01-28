//
//  PreviewData.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Foundation

struct PreviewData {
    static let recentActivities: [ActivityGroup] = [
        .init(title: "This Week",
              activities: [
                .init(sport: "🏃‍♂️",
                      title: "Recovery",
                      duration: "49min",
                      distance: "7.01km",
                      date: "Today"),
                .init(sport: "🏊‍♂️",
                      title: "Threshold Swim",
                      duration: "37min",
                      distance: "1,367yd",
                      date: "Yesterday"),
                .init(sport: "🚴‍♂️",
                      title: "Aerobic Endurance",
                      duration: "2hr 49min",
                      distance: "80.24km",
                      date: "Friday"),
                .init(sport: "🏊‍♂️",
                      title: "Aerobic Endurance",
                      duration: "45min",
                      distance: "2,100yd",
                      date: "Thursday")
            ]),
        .init(title: "Last Week",
              activities: [
                .init(sport: "🏃‍♂️",
                      title: "Recovery",
                      duration: "49min",
                      distance: "7.01km",
                      date: "Today"),
                .init(sport: "🏊‍♂️",
                      title: "Threshold Swim",
                      duration: "37min",
                      distance: "1,367yd",
                      date: "Yesterday"),
                .init(sport: "🚴‍♂️",
                      title: "Aerobic Endurance",
                      duration: "2hr 49min",
                      distance: "80.24km",
                      date: "Friday"),
                .init(sport: "🏊‍♂️",
                      title: "Aerobic Endurance",
                      duration: "45min",
                      distance: "2,100yd",
                      date: "Thursday")
            ]),
    ]
}
