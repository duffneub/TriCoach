//
//  ContentView.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/26/21.
//

import SwiftUI

struct ActivityViewModel : Identifiable {
    let sport: String
    let title: String
    let duration: String
    let distance: String
    let date: String
    
    var id: String {
        title + date
    }
}

struct ActivityGroup : Identifiable {
    let title: String
    let activities: [ActivityViewModel]
    
    var id: String {
        title
    }
}

struct ContentView : View {
    let activities: [ActivityGroup]
    
    init(activities: [ActivityGroup] = []) {
        self.activities = activities
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
            ForEach(activities) { group in
                VStack {
                    HStack {
                        Text(group.title)
                            .font(.headline)
                        Spacer()
                    }
                    VStack {
                        ForEach(group.activities) { activity in
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
    }
}

struct ActivityCard : View {
    let activity: ActivityViewModel

    var body: some View {
        HStack {
            ZStack {
                Color(red: (251/255), green: (241/255), blue: (236/255))
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                Text(activity.sport)
                    .font(.title)
            }
            VStack(alignment: .leading) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                HStack {
                    Text(activity.duration)
                    Text(activity.distance)
                }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ContentView(activities: PreviewData.recentActivities)
            }
        }
    }
}
