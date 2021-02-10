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
            ForEach(activity.isLoading ? activity.placeholder : activity.recentActivity) { category in
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
        .redacted(reason: activity.isLoading ? .placeholder : [])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .navigationTitle("Recent")
        .onAppear(perform: activity.loadRecentActivity)
    }
}

struct ActivityCard : View {
    let activity: ActivitySummaryViewModel
    
    init(activity: ActivitySummaryViewModel) {
        self.activity = activity
    }

    var body: some View {
        HStack {
            ActivityThumbnail(sport: activity.sport)
            VStack(alignment: .leading) {
                Text(activity.title)
                    .font(.subheadline)
                    .lineLimit(titleLineLimit)
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
        .tile()
        .frame(maxHeight: maxHeight)
    }
    
    // MARK: - View Constants
    
    private var titleLineLimit = 1
    private var cornerRadius: CGFloat = 16
    private var maxHeight: CGFloat = 80
    private var shadowColor = Color(white: 0, opacity: 0.1)
    private var shadowRadius: CGFloat = 1
    private var shadowPosition: CGPoint = .init(x: 0, y: 2)
}

struct ActivityThumbnail : View {
    let sport: Activity.Sport
    
    init(sport: Activity.Sport) {
        self.sport = sport
    }
    
    var body: some View {
        ZStack {
            Color.accent
                .opacity(opacity)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(cornerRadius)
            Image(sport.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(padding)
                .foregroundColor(.accent)
        }
    }
    
    // MARK: - View Constants
    
    private var opacity = 0.1
    private var cornerRadius: CGFloat = 8
    private var padding: CGFloat = 12
}

extension Activity.Sport {
    var imageName: String {
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
