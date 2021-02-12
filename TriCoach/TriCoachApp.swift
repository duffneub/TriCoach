//
//  TriCoachApp.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/26/21.
//

import HealthKit
import SwiftUI

@main
struct TriCoachApp: App {
    private let config = AppConfiguration()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    RecentActivityView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Recent")
                }
                Color.red.tabItem {
                    Image(systemName: "2.circle")
                }
                Color.red.tabItem {
                    Image(systemName: "3.circle")
                }
                Color.red.tabItem {
                    Image(systemName: "4.circle")
                }
            }
            .environmentObject(RecentActivityViewModel(activity: config.activityStore, settings: config.settingsStore))
        }
    }
}

#if IOS_SIMULATOR

private struct AppConfiguration {
    let settingsStore: SettingsStore
    let activityStore: ActivityStore

    init() {
        settingsStore = SettingsStore()
        activityStore = ActivityStore(
            activityRepo: PreviewData.FakeActivityRepository(delay: 1),
            calendar: settingsStore.$calendar.eraseToAnyPublisher())
    }
}

#else

private struct AppConfiguration {
    let settingsStore: SettingsStore
    let activityStore: ActivityStore

    init() {
        settingsStore = SettingsStore()
        activityStore = ActivityStore(
            activityRepo: ActivityServiceRepository(service: HKHealthStore()),
            calendar: settingsStore.$calendar.eraseToAnyPublisher())
    }
}

#endif
