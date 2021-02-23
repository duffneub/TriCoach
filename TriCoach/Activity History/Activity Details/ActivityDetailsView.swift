//
//  ActivityDetailsView.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/9/21.
//

import SwiftUI

struct DistanceWidget : View {
    private let numberFormatter = NumberFormatter()
    private let measurementFormatter = MeasurementFormatter()
    private let distance: Measurement<UnitLength>

    init(_ distance: Measurement<UnitLength>) {
        self.distance = distance

        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.unitStyle = .long
    }

    var body: some View {
        MetricWidget(
            image: "location.circle.fill",
            name: "Distance",
            value: numberFormatter.string(from: .init(value: distance.value))!,
            unit: measurementFormatter.string(from: distance.unit))
    }
}

struct ActivityDetailsView: View {
    private let columns = (0..<2).map { _ in GridItem(.flexible(maximum: 200)) }
    private let measurementFormatter = MeasurementFormatter()
    private var activity: Activity.Summary

    @EnvironmentObject private var activityCatalog: ActivityCatalog

    init(_ activity: Activity.Summary) {
        self.activity = activity

        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter.maximumFractionDigits = 0
    }

    var body: some View {
        ScrollView {
            VStack {
                ActivityDetailsHeader(image: image, name: name, date: date, time: time)
                    .padding(.bottom)

                AsyncMap(activityCatalog.route(of: activity), loadRoute: { activityCatalog.loadRoute(of: activity) })
                    .allowsHitTesting(false)
                    .aspectRatio(1.5, contentMode: .fit)
                    .tile(padding: 0)

                LazyVGrid(columns: columns) {
                    MetricWidget(
                        image: "timer",
                        name: "Duration",
                        value: "\(measurementFormatter.hoursAndMinutes(from: activity.duration))",
                        unit: "elapsed")

                    DistanceWidget(activity.distance)

                    MetricWidget(
                        image: "heart.fill",
                        name: "Avg. Heart Rate",
                        value: "\(activityCatalog.heartRate(of: activity).value.map { Int($0.reduce(0, +) / Double(max(1, $0.count))) } ?? 0)",
                        unit: "Beats Per Minute")
                }

                Spacer()
            }
            .padding([.top, .leading, .trailing])
            .onAppear {
                activityCatalog.loadHeartRate(of: activity)
            }
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

// MARK: - AsyncMap

import CoreLocation

private struct AsyncMap : View {
    private let state: AsyncState<[CLLocationCoordinate2D]?>
    private let loadRoute: () -> Void

    init(_ state: AsyncState<[CLLocationCoordinate2D]?>, loadRoute: @escaping () -> Void) {
        self.state = state
        self.loadRoute = loadRoute
    }

    var body: some View {
        Group {
            switch state {
            case .ready:
                Color.clear
                    .onAppear(perform: loadRoute)
            case .loading:
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .success(route):
                if route != nil {
                    LegacyMap(route: route)
                } else {
                    Text("Route Unavailable")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
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
