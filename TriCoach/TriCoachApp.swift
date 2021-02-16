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
    #if targetEnvironment(simulator)
    @StateObject private var app = TriCoach(config: .simulator)
    #else
    @StateObject private var app = TriCoach(config: .production)
    #endif

    var body: some Scene {
        WindowGroup {
            TabView(selection: $app.selectedSection) {
                ForEach(TriCoach.Section.allCases, id: \.self) { section in
                    SectionView(section)
                        .tabItem {
                            Image(systemName: app.selectedSection == section ? section.selectedImage : section.unselectedImage)
                            Text(section.name)
                        }

                }
            }
            .environmentObject(ActivityCatalogViewModel(activity: app.activityStore, settings: app.settingsStore)) // This is causing tab view to be slow, but will probably be better after refactor
        }
    }
}

private struct SectionView : View {
    private var section: TriCoach.Section

    init(_ section: TriCoach.Section) {
        self.section = section
    }

    var body: some View {
        NavigationView {
            switch section {
            case .history:
                ActivityCatalogView()
            default:
                Color.red
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tag(section)
    }
}
