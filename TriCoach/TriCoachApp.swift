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
            }.environmentObject(RecentActivityViewModel(activityRepo: config.activityRepo))
        }
    }
}

#if IOS_SIMULATOR

private struct AppConfiguration {
    let activityRepo: ActivityRepository = PreviewData.FakeActivityRepository(delay: 1)
}

#else

private struct AppConfiguration {
    let activityRepo: ActivityRepository = ActivityServiceRepository(service: HKHealthStore())
}

#endif
