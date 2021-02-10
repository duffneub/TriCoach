//
//  ActivityDetailsView.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/9/21.
//

import MapKit
import SwiftUI

protocol ActivityViewModel {
    associatedtype Measurement : MeasurementViewModel
    
    var sport: Activity.Sport { get }
    var name: String { get }
    var shortDate: String { get }
    var longDate: String { get }
    var time: String { get }
    var measurements: [Measurement] { get }
}

protocol MeasurementViewModel : Identifiable {
    var name: String { get }
    var value: String { get }
    var unit: String  { get }
}

struct ActivityDetailsView<ViewModel : ActivityViewModel>: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var activity: ViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Header(
                    image: activity.sport.imageName,
                    name: activity.name,
                    date: activity.longDate,
                    time: activity.time
                )
                .padding(.bottom)
                
                LazyVGrid(columns: columns) {
                    ForEach(activity.measurements) { measurement in
                        MetricWidget(
                            image: image(for: measurement.name),
                            name: measurement.name,
                            value: measurement.value,
                            unit: measurement.unit)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .navigationBarTitle(activity.shortDate, displayMode: .inline)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func image(for measurement: String) -> String {
        switch measurement {
        case "Duration":
            return "timer"
        case "Distance":
            return "location.circle.fill"
        case "Normalized Power":
            return "bolt.fill"
        case "Avg. Heart Rate":
            return "heart.fill"
        default:
            return ""
        }
    }
}

struct Header : View {
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
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(time)
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

struct MetricWidget : View {
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
        NavigationView {
            ActivityDetailsView(activity: PreviewData.activityViewModel)
        }
    }
}
