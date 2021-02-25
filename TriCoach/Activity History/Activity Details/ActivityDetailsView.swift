//
//  ActivityDetailsView.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/9/21.
//

import CoreLocation
import SwiftUI

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

                Group {
                    if activityCatalog.details(of: activity.id).isLoading {
                        ProgressView("Loading…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        if route.count > 0 {
                            LegacyMap(route: route)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .aspectRatio(1.5, contentMode: .fit)
                .tile(padding: 0)

                LazyVGrid(columns: columns) {
                    ForEach(widgets, id: \.label) { config in
                        MetricWidget(config)
                    }
                }
                .redacted(reason: activityCatalog.details(of: activity.id).isLoading ? .placeholder : [])

                Spacer()
            }
            .padding([.top, .leading, .trailing])
            .onAppear {
                activityCatalog.loadDetails(of: activity.id)
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

    var route: [CLLocationCoordinate2D] {
        activityCatalog.details(of: activity.id).value?.route?
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            ?? []
    }

    var widgets: [WidgetConfiguration] {
        var metrics = [totalDuration, totalDistance, averageHeartRate, maxHeartRate]

        if activityCatalog.details(of: activity.id).isLoading ||
            activityCatalog.details(of: activity.id).value?.elevation != nil
        {
            metrics.append(contentsOf: [averageElevation, minElevation, maxElevation])
        }

        if activityCatalog.details(of: activity.id).isLoading ||
            activityCatalog.details(of: activity.id).value?.speed != nil
        {
            metrics.append(contentsOf: [averageSpeed, maxSpeed])
        }

        return metrics
    }

    var totalDuration: WidgetConfiguration {
        .init(
            image: "timer",
            label: "Duration",
            value: measurementFormatter.hoursAndMinutes(from: activity.duration),
            unit: "elapsed")
    }

    var totalDistance: WidgetConfiguration {
        let numberFormatter = NumberFormatter()
        let measurementFormatter = MeasurementFormatter()

        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.unitStyle = .long

        return .init(
            image: "location.circle.fill",
            label: "Distance",
            value: numberFormatter.string(from: .init(value: activity.distance.value))!,
            unit: measurementFormatter.string(from: activity.distance.unit))
    }

    var averageHeartRate: WidgetConfiguration {
        let heartRate = activityCatalog.details(of: activity.id).value?.heartRate ?? []
        let sum = heartRate.reduce(0, +)
        let denominator = Double(max(1, heartRate.count))
        let average = Int(sum / denominator)

        return .init(
            image: "heart.fill",
            label: "Avg. Heart Rate",
            value: "\(average)",
            unit: "Beats Per Minute")
    }

    var maxHeartRate: WidgetConfiguration {
        return .init(
            image: "heart.fill",
            label: "Max Heart Rate",
            value: "\(activityCatalog.details(of: activity.id).value?.heartRate.max() ?? 0)",
            unit: "Beats Per Minute")
    }

    var averageElevation: WidgetConfiguration {
        let numberFormatter = NumberFormatter()
        let measurementFormatter = MeasurementFormatter()

        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.unitStyle = .long

        let elevation = activityCatalog.details(of: activity.id).value?.elevation ?? []
        let sum = elevation.map { $0.value }.reduce(0, +)
        let denominator = Double(max(1, elevation.count))
        let average = Int(sum / denominator)

        return .init(
            image: "airplane",
            label: "Avg. Elevation",
            value: numberFormatter.string(from: .init(value: average))!,
            unit: "Meters")
    }

    var minElevation: WidgetConfiguration {
        let numberFormatter = NumberFormatter()
        let measurementFormatter = MeasurementFormatter()

        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.unitStyle = .long

        return .init(
            image: "airplane",
            label: "Min Elevation",
            value: numberFormatter.string(from: .init(value: activityCatalog.details(of: activity.id).value?.elevation?.min()?.value ?? 0))!,
            unit: "Meters")
    }

    var maxElevation: WidgetConfiguration {
        let numberFormatter = NumberFormatter()
        let measurementFormatter = MeasurementFormatter()

        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.unitStyle = .long

        return .init(
            image: "airplane",
            label: "Max Elevation",
            value: numberFormatter.string(from: .init(value: activityCatalog.details(of: activity.id).value?.elevation?.max()?.value ?? 0))!,
            unit: "Meters")
    }

    var averageSpeed: WidgetConfiguration {
        let numberFormatter = NumberFormatter()
        let measurementFormatter = MeasurementFormatter()

        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.unitStyle = .long

        let speed = activityCatalog.details(of: activity.id).value?.speed ?? []
        let sum = speed.map { $0.converted(to: .milesPerHour).value }.reduce(0, +)
        let denominator = Double(max(1, speed.count))
        let average = Int(sum / denominator)

        return .init(
            image: "hare.fill",
            label: "Avg. Speed",
            value: numberFormatter.string(from: .init(value: average))!,
            unit: "Miles per Hour")
    }

    var maxSpeed: WidgetConfiguration {
        let numberFormatter = NumberFormatter()
        let measurementFormatter = MeasurementFormatter()

        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.unitStyle = .long

        return .init(
            image: "hare.fill",
            label: "Max Speed",
            value: numberFormatter.string(from: .init(value: activityCatalog.details(of: activity.id).value?.speed?.max()?.converted(to: .milesPerHour).value ?? 0))!,
            unit: "Miles per Hour")
    }
}

struct WidgetConfiguration {
    let image: String
    let label: String
    let value: String
    let unit: String
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
    var label: String
    var value: String
    var unit: String

    init(_ config: WidgetConfiguration) {
        self.image = config.image
        self.label = config.label
        self.value = config.value
        self.unit = config.unit
    }

    var body: some View {
        ZStack(alignment: Alignment.topLeading) {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accent)
                .frame(width: imageWidth)

            VStack(spacing: spacing) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, labelPadding)
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
    private let labelPadding: CGFloat = 20
}

struct ActivityDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityDetailsView(PreviewData.activities.first!)
    }
}
