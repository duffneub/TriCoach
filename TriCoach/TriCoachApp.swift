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
    private let appConfig = AppConfiguration()

    var body: some Scene {
        WindowGroup {
            TabView {
                appConfig.makeRecentActivityModule().tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Recent")
                }
                Color.red.tabItem {
                    Image(systemName: "questionmark.circle")
                }
                Color.red.tabItem {
                    Image(systemName: "questionmark.circle")
                }
                Color.red.tabItem {
                    Image(systemName: "questionmark.circle")
                }
            }
            .colorScheme(.light)
        }
    }
}

private struct AppConfiguration {
    private let healthStore = HKHealthStore()
    
    func makeRecentActivityModule() -> some View {
        let repo = ActivityServiceRepository(service: healthStore)
        let viewModel = RecentActivityViewModel(activityRepo: repo)

        return NavigationView {
            RecentActivityView(activity: viewModel)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
