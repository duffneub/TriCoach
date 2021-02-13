//
//  RecentActivityViewModel.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import Foundation

class RecentActivityViewModel : ObservableObject {
    private let categoryFormatter = GranularRelativeDateFormatter(granularity: .week)
    private let activityDateFormatter = GranularRelativeDateFormatter(granularity: .day)
    private let measurementFormatter = MeasurementFormatter()

    private var settings: SettingsStore
    private var activity: ActivityStore
    private var subscriptions = Set<AnyCancellable>()
    
    init(activity: ActivityStore, settings: SettingsStore) {
        self.settings = settings
        self.activity = activity
        
        self.placeholder = [
            .init(title: "This Week",
                 position: 1,
                 content: ["Pool Swim", "Another Pool Swim", "Ocean Swim"].map { title in
                   .init(
                       activity: .init(
                           sport: .swim,
                           workout: title,
                           duration: .init(value: 1, unit: .hours),
                           distance: .init(value: 1, unit: .miles),
                           date: Date()),
                       dateFormatter: DateFormatter(),
                       measurementFormatter: MeasurementFormatter(),
                    activityStore: activity)
                 })
        ]

        // Create Dependencies

        self.settings.$calendar
            .receive(on: DispatchQueue.main)
            .sink { calendar in
                self.categoryFormatter.calendar = calendar
                self.activityDateFormatter.calendar = calendar
                self.measurementFormatter.locale = calendar.locale
            }
            .store(in: &subscriptions)

        self.settings.$currentDate
            .receive(on: DispatchQueue.main)
            .sink { currentDate in
                self.categoryFormatter.currentDate = currentDate()
                self.activityDateFormatter.currentDate = currentDate()
            }
            .store(in: &subscriptions)
        
        self.activity.$state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: refresh)
            .store(in: &subscriptions)
    }
    
    private func refresh(_ state: ActivityStore.State) {
        isLoading = state.isLoading

        catalog = state.catalog.map {
            $0.enumerated()
                .compactMap { offset, item in
                    Group(
                        title: categoryFormatter.string(from: item.date),
                        position: offset,
                        content: item.activities.map {
                            .init(
                                activity: $0,
                                dateFormatter: activityDateFormatter,
                                measurementFormatter: measurementFormatter,
                                activityStore: activity)
                        }.sorted())
                }
        } ?? placeholder
    }

    // MARK: - Intents

    func loadCatalog() {
        activity.loadCatalog()
    }
    
    // MARK: - Access to Model

    @Published var catalog: [Group<Activity>] = []
    @Published var isLoading: Bool = false
    
    var placeholder: [Group<Activity>]
    
    // MARK: - Group

    struct Group<Content : Identifiable & Comparable> : Identifiable, Comparable {
        let id = UUID()
        let title: String
        let position: Int
        let content: [Content]
        
        // MARK: - Comparable

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.position < rhs.position
        }
    }
    
    // MARK: - Activity

    class Activity : Identifiable, Comparable, ObservableObject {
        let activity: TriCoach.Activity
        private let dateFormatter: DateFormatter
        private let measurementFormatter: MeasurementFormatter
        private var activityStore: ActivityStore

        @Published private var _isSelected: Bool = false
        
        let id = UUID()

        init(
            activity: TriCoach.Activity,
            dateFormatter: DateFormatter,
            measurementFormatter: MeasurementFormatter,
            activityStore: ActivityStore
        ) {
            self.activity = activity
            self.dateFormatter = dateFormatter
            self.measurementFormatter = measurementFormatter
            self.activityStore = activityStore
            
            self.activityStore.$selectedActivity
                .map { $0 == activity }
                .assign(to: &$_isSelected)
        }
        
        // MARK: - Intents
        
        var isSelected: Bool {
            get {
                _isSelected
            } set {
                if newValue {
                    activityStore.select(activity)
                } else {
                    activityStore.deselect(activity)
                }
            }
        }
        
        // MARK: - Access to Model
        
        var sport: TriCoach.Activity.Sport {
            activity.sport
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
        
        // MARK: - Comparable

        static func < (lhs: RecentActivityViewModel.Activity, rhs: RecentActivityViewModel.Activity) -> Bool {
            lhs.activity.date > rhs.activity.date
        }

        // MARK: - Equatable

        static func == (lhs: RecentActivityViewModel.Activity, rhs: RecentActivityViewModel.Activity) -> Bool {
            lhs.activity == rhs.activity
        }
    }
}
