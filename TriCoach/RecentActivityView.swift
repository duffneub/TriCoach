//
//  RecentActivityView.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/26/21.
//

import Combine
import SwiftUI

struct RecentActivityView : View {
    @ObservedObject var activity: RecentActivityViewModel
    
    init(activity: RecentActivityViewModel) {
        self.activity = activity
        let appearance = UIBarAppearance()
        appearance.backgroundColor = .systemGroupedBackground
        
        let transparentAppearance = UIBarAppearance()
        transparentAppearance.configureWithTransparentBackground()
        transparentAppearance.backgroundColor = .systemGroupedBackground
        
        UINavigationBar.appearance().standardAppearance = .init(barAppearance: appearance)
        UINavigationBar.appearance().scrollEdgeAppearance = .init(barAppearance: transparentAppearance)
    }
    
    var body: some View {
        ScrollView {
            ForEach(activity.recentActivity) { category in
                VStack {
                    HStack {
                        Text(category.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    VStack {
                        ForEach(category.content) { activity in
                            ActivityCard(activity: activity)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Recent")
        .onAppear {
            activity.loadRecentActivity()
        }
    }
}

struct ActivityCard : View {
    let activity: ActivitySummaryViewModel

    var body: some View {
        HStack {
            ActivityThumbnail(sport: activity.sport)
            VStack(alignment: .leading) {
                Text(activity.title)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(activity.summary)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(Color.secondary)
            }
            Spacer()
            VStack {
                Spacer()
                Text(activity.date)
                    .font(.caption2)
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .frame(maxHeight: 80)
        .shadow(color: Color(white: 0, opacity: 0.1), radius: 1, x: 0, y: 2)
    }
}

struct ActivityThumbnail : View {
    let sport: Activity.Sport
    
    var body: some View {
        ZStack {
            Color("AccentColor")
                .opacity(0.1)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)
            Image(sport.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(12.0)
                .foregroundColor(Color("AccentColor"))
        }
    }
}

extension Activity.Sport {
    fileprivate var imageName: String {
        switch self {
        case .swim:
            return "Swimming_Filled"
        case .bike:
            return "Cycling_Filled"
        case .run:
            return "Running_Filled"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecentActivityView(activity: .init(activityRepo: PreviewData.FakeActivityRepository()))
        }
    }
}
