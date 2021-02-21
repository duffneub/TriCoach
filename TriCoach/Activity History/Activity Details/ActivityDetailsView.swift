//
//  ActivityDetailsView.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/9/21.
//

import SwiftUI

struct ActivityDetailsView: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    private let measurementFormatter = MeasurementFormatter()
    private var activity: Activity

    @EnvironmentObject private var store: ActivityStore

    init(_ activity: Activity) {
        self.activity = activity
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ActivityDetailsHeader(image: image, name: name, date: date, time: time)
                    .padding(.bottom)

                LegacyMap(route: store.route(of: activity))
                    .aspectRatio(1.5, contentMode: .fit)
                    .tile(padding: 0)
                    .onAppear {
                        store.loadRoute(of: activity)
                    }

                LazyVGrid(columns: columns) {
                    MetricWidget(
                        image: "timer",
                        name: "Duration",
                        value: "\(activity.duration.converted(to: .minutes).value.rounded())",
                        unit: "minutes")

                    MetricWidget(
                        image: "location.circle.fill",
                        name: "Distance",
                        value: "\(activity.distance.converted(to: .miles).value.rounded())",
                        unit: "Miles")
                }

                Spacer()
            }
            .padding([.top, .leading, .trailing])
        }
        .navigationBarTitleDisplayMode(.inline)
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

    var name: String {
        activity.workout
    }

    var date: String {
        DateFormatter.localizedString(from: activity.date, dateStyle: .long, timeStyle: .none)
    }

    var time: String {
        DateFormatter.localizedString(from: activity.date, dateStyle: .none, timeStyle: .long)
    }
}

// MARK: - ActivityDetailsHeader

private struct ActivityDetailsHeader : View {
    var image: String
    var name: String
    var date: String
    var time: String

    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .foregroundColor(.accent)
                .tile(padding: imagePadding)
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: imageHeight)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Group {
                    Text(date)
                    Text(time)
                }
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .layoutPriority(1)

            Spacer()
        }
    }

    // MARK: - View Constants

    private let imagePadding: CGFloat = 14
    private let imageHeight: CGFloat = 50
}

// MARK: - MetricWidget

private struct MetricWidget : View {
    var image: String
    var name: String
    var value: String
    var unit: String

    var body: some View {
        ZStack(alignment: Alignment.topLeading) {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accent)
                .frame(width: imageWidth)

            VStack(spacing: spacing) {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, namePadding)
                    .multilineTextAlignment(.center)

                Text(value)
                    .font(.title)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .tile()
    }

    // MARK: - View Constants

    private let imageWidth: CGFloat = 14
    private let spacing: CGFloat = 8
    private let namePadding: CGFloat = 20
}

struct ActivityDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityDetailsView(PreviewData.activities.first!)
    }
}
