//
//  File.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/17/21.
//

import SwiftUI

// MARK: - ActivitySummaryView

struct ActivitySummaryView : View {
    private let dateFormatter = GranularRelativeDateFormatter(granularity: .day)
    private let measurementFormatter = MeasurementFormatter()
    private var activity: Activity.Summary

    init(_ activity: Activity.Summary) {
        self.activity = activity

        measurementFormatter.unitStyle = .medium
        measurementFormatter.numberFormatter.maximumFractionDigits = 1
    }

    var body: some View {
        FlatListCell(image: image, primaryText: title, secondaryText: summary, tertiaryText: date)
    }

    // MARK: - Access to Model

    var image: String {
        switch activity.sport {
        case .swim:
            return "Swimming_Filled"
        case .bike:
            return "Cycling_Filled"
        case .run:
            return "Running_Filled"
        }
    }

    var title: String {
        activity.workout
    }

    var summary: String {
        [
            measurementFormatter.hoursAndMinutes(from: activity.duration),
            activity.sport == .swim ?
                measurementFormatter.swimDistance(from: activity.distance) :
                measurementFormatter.bikeOrRunDistance(from: activity.distance)
        ]
        .joined(separator: " · ")
    }

    var date: String {
        dateFormatter.string(from: activity.date)
    }
}

// MARK: - FlatListCell

private struct FlatListCell : View {
    var image: String
    var primaryText: String
    var secondaryText: String
    var tertiaryText: String

    var body: some View {
        HStack {
            IconThumbnail(image)

            VStack(alignment: .leading) {
                PrimaryText(primaryText)
                SecondaryText(secondaryText)
            }

            Spacer()

            VStack {
                Spacer()
                TertiaryText(tertiaryText)
            }
        }
    }
}

// MARK: - IconThumbnail

private struct IconThumbnail : View {
    var name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        ZStack {
            Color.accent
                .opacity(opacity)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(cornerRadius)
            Image(name)
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

// MARK: - PrimaryText

private struct PrimaryText : View {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.subheadline)
            .lineLimit(1)
            .foregroundColor(.primary)
    }
}

// MARK: - SecondaryText

private struct SecondaryText : View {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.light)
            .foregroundColor(.secondary)
    }
}

// MARK: - TertiaryText

private struct TertiaryText : View {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(Color(UIColor.tertiaryLabel))
    }
}
