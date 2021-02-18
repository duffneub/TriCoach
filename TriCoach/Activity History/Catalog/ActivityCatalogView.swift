//
//  ActivityCatalogView.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/26/21.
//

import SwiftUI

struct ActivityCatalog : View {
    var content: [Section]
    @Binding var selection: Activity?

    init(content: [Section], selection: Binding<Activity?>) {
        self.content = content
        self._selection = selection
    }

    var body: some View {
        FlatList(content) { section in
            FlatListSection(header: SectionHeaderView(section)) {
                FlatInnerList(section.activities) { activity in
                    NavigationLink(
                        destination: ActivityDetailsView(activity),
                        tag: activity,
                        selection: $selection
                    ) {
                        ActivitySummaryView(activity)
                    }
                    .tile()
                    .frame(maxHeight: maxHeight)
                }
            }
        }
    }

    // MARK: - View Constants

    private var maxHeight: CGFloat = 80
}

private struct SectionHeaderView : View {
    private let dateFormatter = GranularRelativeDateFormatter(granularity: .week)
    private var section: Section

    init(_ section: Section) {
        self.section = section
    }

    var body: some View {
        HeaderView(title)
    }

    // MARK: - Access to Model

    var title: String {
        dateFormatter.string(from: section.date)
    }
}

// MARK - HeaderView

private struct HeaderView : View {
    var title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
    }
}

