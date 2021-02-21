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

    init() {
        let backgroundColor = UIColor.systemGroupedBackground

        let appearance = UIBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor
        UINavigationBar.appearance().scrollEdgeAppearance = .init(barAppearance: appearance)

        UINavigationBar.appearance().standardAppearance.backgroundColor = backgroundColor
        UIScrollView.appearance().backgroundColor = backgroundColor
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $app.selectedSection) {
                ForEach(TriCoach.Section.allCases, id: \.self) { section in
                    Group {
                        switch section {
                        case .history:
                            ActivityBrowser(app.activityStore)
                                .environmentObject(app.activityStore)
                        default:
                            Color.red
                        }
                    }
                    .tag(section)
                    .tabItem {
                        Image(systemName: app.selectedSection == section ? section.selectedImage : section.unselectedImage)
                        Text(section.name)
                    }

                }
            }
        }
    }
}

private struct AppTabView : View {
    @ObservedObject var app: TriCoach

    var body: some View {
        TabView(selection: $app.selectedSection) {
            ForEach(TriCoach.Section.allCases, id: \.self) { section in
                Group {
                    switch section {
                    case .history:
                        ActivityBrowser(app.activityStore)
                    default:
                        Color.red
                    }
                }
                .tag(section)
                .tabItem {
                    Image(systemName: app.selectedSection == section ?
                            section.selectedImage :
                            section.unselectedImage)
                    Text(section.name)
                }

            }
        }
    }
}
