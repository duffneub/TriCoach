//
//  ActivityCatalogViewModel.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import Foundation

class ActivityCatalogViewModel : ObservableObject {
    private let categoryFormatter = GranularRelativeDateFormatter(granularity: .week)
    private let activityDateFormatter = GranularRelativeDateFormatter(granularity: .day)
    private let measurementFormatter = MeasurementFormatter()

    private var settings: SettingsStore
    private var activityStore: ActivityStore
    private var subscriptions = Set<AnyCancellable>()
    
    init(activity: ActivityStore, settings: SettingsStore) {
        self.settings = settings
        self.activityStore = activity
        
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
                    isSelected: Just<Bool>(false).eraseToAnyPublisher())
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
        
        self.activityStore.$state
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
                        content: item.activities.map { activity in
                            .init(
                                activity: activity,
                                dateFormatter: activityDateFormatter,
                                measurementFormatter: measurementFormatter,
                                isSelected: self.activityStore.$selectedActivity
                                    .map { $0 == activity }
                                    .eraseToAnyPublisher(),
                                select: { self.activityStore.select(activity) },
                                deselect: { self.activityStore.deselect(activity) })
                        }.sorted())
                }
        } ?? placeholder
    }

    // MARK: - Intents

    func loadCatalog() {
        activityStore.loadCatalog()
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
        
        let id = UUID()

        init(
            activity: TriCoach.Activity,
            dateFormatter: DateFormatter,
            measurementFormatter: MeasurementFormatter,
            isSelected: AnyPublisher<Bool, Never>,
            select: @escaping () -> Void = {},
            deselect: @escaping () -> Void = {}
        ) {
            self.activity = activity
            self.dateFormatter = dateFormatter
            self.measurementFormatter = measurementFormatter
            self.select = select
            self.deselect = deselect

            isSelected.assign(to: &self.$isSelected)
        }
        
        // MARK: - Intents

        var select: () -> Void
        var deselect: () -> Void
        
        // MARK: - Access to Model

        @Published var isSelected: Bool = false
        
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

        static func < (lhs: ActivityCatalogViewModel.Activity, rhs: ActivityCatalogViewModel.Activity) -> Bool {
            lhs.activity.date > rhs.activity.date
        }

        // MARK: - Equatable

        static func == (lhs: ActivityCatalogViewModel.Activity, rhs: ActivityCatalogViewModel.Activity) -> Bool {
            lhs.activity == rhs.activity
        }
    }
}
