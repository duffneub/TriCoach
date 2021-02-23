//
//  ActivityBrowser.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/17/21.
//

import SwiftUI

// MARK - ActivityBrowser

struct ActivityBrowser : View {
    @ObservedObject var catalog: ActivityCatalog

    init(_ store: ActivityCatalog) {
        self.catalog = store
    }

    var body: some View {
        NavigationView {
            ActivityCatalogView(content: catalog.sections ?? placeholder, selection: $catalog.selectedActivity)
                .allowsHitTesting(!catalog.isLoading)
                .redacted(reason: catalog.isLoading ? .placeholder : [])
                .onAppear(perform: catalog.loadCatalog)
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
                Activity.Summary(
                    sport: .swim,
                    workout: $0,
                    duration: .init(value: 100, unit: .hours),
                    distance: .init(value: 100, unit: .miles),
                    date: Date())
        })
    ]
}

struct NewActivityDetailsView : View {
    var activity: Activity.Summary

    init(_ activity: Activity.Summary) {
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
            ActivityBrowser(TestActivityCatalog()).preferredColorScheme($0)
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
    }
}
