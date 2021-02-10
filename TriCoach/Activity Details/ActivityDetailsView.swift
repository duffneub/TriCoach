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

struct TestActivityViewModel : ActivityViewModel {
    let sport: Activity.Sport
    let name: String
    let shortDate: String
    let longDate: String
    let time: String
    let measurements: [TestMeasurementViewModel]
    
    struct TestMeasurementViewModel : MeasurementViewModel {
        let name: String
        let value: String
        let unit: String
        
        var id: String {
            name
        }
    }
}

extension PreviewData {
    static var activityViewModel = TestActivityViewModel(
        sport: .bike,
        name: "Aerobic Endurance",
        shortDate: "Sun, Dec 13",
        longDate: "Sun, Dec 13 2020",
        time: "7:01 - 8:29 AM",
        measurements: [
            TestActivityViewModel.TestMeasurementViewModel(
                name: "Duration",
                value: "01:27:34",
                unit: "elapsed"),
            TestActivityViewModel.TestMeasurementViewModel(
                name: "Distance",
                value: "56.5",
                unit: "kilometers"),
            TestActivityViewModel.TestMeasurementViewModel(
                name: "Normalized Power",
                value: "300",
                unit: "watts/kg"),
            TestActivityViewModel.TestMeasurementViewModel(
                name: "Avg. Heart Rate",
                value: "150",
                unit: "beats per minute"),
        ])
}

struct ActivityDetailsView<ViewModel : ActivityViewModel>: View {
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
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(activity.measurements) { measurement in
                        MetricWidget(name: measurement.name, value: measurement.value, unit: measurement.unit)
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
        .navigationBarItems(trailing: Button(action: {}, label: {
            Image(systemName: "square.and.arrow.up")
        }))
    }
}

struct Tile<Content : View> : View {
    var alignment: Alignment
    var padding: CGFloat?
    var content: () -> Content
    
    init(alignment: Alignment = .center, padding: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: alignment) {
            Color.tileBackground
            content()
                .padding(.all, padding)
        }
        .cornerRadius(12)
        .shadow(color: Color(white: 0, opacity: 0.1), radius: 1, x: 0, y: 2)
    }
}

struct Header : View {
    var image: String
    var name: String
    var date: String
    var time: String
    
    var body: some View {
        HStack {
            Tile(padding: 14) {
                Image(image)
                    .resizable()
                    .foregroundColor(.accent)
            }
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: 50)
            
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
}

struct MetricWidget : View {
    var name: String
    var value: String
    var unit: String
    
    var image: String {
        switch name {
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
    
    var body: some View {
        Tile(alignment: Alignment.topLeading) {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accent)
                .frame(width: 14)
            
            VStack(spacing: 8) {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
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
    }
}

extension Color {
    static var tileBackground: Color {
        .white
    }
}

struct ActivityDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ActivityDetailsView(activity: PreviewData.activityViewModel)
        }
    }
}
