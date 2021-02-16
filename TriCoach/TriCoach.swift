//
//  TriCoach.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/16/21.
//

import Combine
import HealthKit
import Foundation

class TriCoach : ObservableObject {
    @Published var selectedSection: TriCoach.Section = .history

    let settingsStore: SettingsStore
    let activityStore: ActivityStore

    init(config: Configuration = .production) {
        settingsStore = SettingsStore()

        switch config {
        case .simulator:
            activityStore = ActivityStore(
                activityRepo: PreviewData.FakeActivityRepository(delay: 1),
                calendar: settingsStore.$calendar.eraseToAnyPublisher())
        case .production:
            activityStore = ActivityStore(
                activityRepo: ActivityServiceRepository(service: HKHealthStore()),
                calendar: settingsStore.$calendar.eraseToAnyPublisher())
        }
    }

    // MARK: - Configuration

    enum Configuration {
        case simulator
        case production
    }

    // MARK: - Section

    enum Section : CaseIterable {
        case history
        case profile
        case record
        case workouts
        case settings

        var name: String {
            switch self {
            case .history:
                return "History"
            case .profile:
                return "Profile"
            case .record:
                return "Record"
            case .workouts:
                return "Workouts"
            case .settings:
                return "Settings"
            }
        }

        var unselectedImage: String {
            switch self {
            case .history:
                return "clock.arrow.circlepath"
            case .profile:
                return "person.crop.circle"
            case .record:
                return "record.circle"
            case .workouts:
                return "chart.bar.doc.horizontal"
            case .settings:
                return "gearshape"
            }
        }

        var selectedImage: String {
            switch self {
            case .history:
                return "clock.arrow.circlepath"
            case .profile:
                return "person.crop.circle.fill"
            case .record:
                return "record.circle.fill"
            case .workouts:
                return "chart.bar.doc.horizontal.fill"
            case .settings:
                return "gearshape.fill"
            }
        }
    }
}
