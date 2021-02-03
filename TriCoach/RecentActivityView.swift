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
                            .font(.headline)
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
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(activity.summary)
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            Spacer()
            VStack {
                Spacer()
                Text(activity.date)
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
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
            Color(red: (251/255), green: (241/255), blue: (236/255))
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)
            Text("?")
                .font(.title)
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
