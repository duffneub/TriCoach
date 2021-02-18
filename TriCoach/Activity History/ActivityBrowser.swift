//
//  ActivityBrowser.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/17/21.
//

import SwiftUI

// MARK - ActivityBrowser

struct ActivityBrowser : View {
    @ObservedObject var store: ActivityStore

    init(_ store: ActivityStore) {
        self.store = store
    }

    var body: some View {
        NavigationView {
            ActivityCatalog(content: store.sections ?? placeholder, selection: $store.selectedActivity)
                .allowsHitTesting(!store.isLoading)
                .redacted(reason: store.isLoading ? .placeholder : [])
                .onAppear(perform: store.loadCatalog)
                .navigationTitle("Recent")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - View Constants

    private var maxHeight: CGFloat = 80
    private var placeholder: [Section] = [
        .init(
            date: Date(),
            activities: ["Placeholder", "Pretty Long Placeholder", "Another Placeholder"].map {
                Activity(
                    sport: .swim,
                    workout: $0,
                    duration: .init(value: 100, unit: .hours),
                    distance: .init(value: 100, unit: .miles),
                    date: Date())
        })
    ]
}

struct NewActivityDetailsView : View {
    var activity: Activity

    init(_ activity: Activity) {
        self.activity = activity
    }

    var body: some View {
        EmptyView()
    }
}

// MARK: - Previews

struct ActivityBrowser_Previews : PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            ActivityBrowser(TestActivityStore()).preferredColorScheme($0)
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
    }
}
