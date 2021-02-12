//
//  RecentActivityViewModel.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import Foundation

class RecentActivityViewModel : ObservableObject {
    private let store: ActivityStore
    
    private let activityRepo: ActivityRepository
    private let categoryFormatter = GranularRelativeDateFormatter(granularity: .week)
    private let activityDateFormatter = GranularRelativeDateFormatter(granularity: .day)
    private let measurementFormatter = MeasurementFormatter()
    
    var calendar: Calendar = .current {
        didSet {
            categoryFormatter.calendar = calendar
            activityDateFormatter.calendar = calendar
            measurementFormatter.locale = calendar.locale
        }
    }
    
    var currentDate: () -> Date = Date.init {
        didSet {
            categoryFormatter.currentDate = currentDate()
            activityDateFormatter.currentDate = currentDate()
        }
    }
    
    init(store: ActivityStore = ActivityStore(), activityRepo: ActivityRepository) {
        self.store = store
        self.activityRepo = activityRepo
        
        self.store.$catalog
            .map(makeActivityGroups(_:))
            .receive(on: DispatchQueue.main)
            .assign(to: &$catalog)
    }
    
    private func makeActivityGroups(_ groups: [ActivityStore.Group]) -> [Group<Activity>]{
        groups
            .enumerated()
            .compactMap { offset, item in
                Group(
                    title: categoryFormatter.string(from: item.date),
                    position: offset,
                    content: item.activities.map {
                        .init(
                            activity: $0,
                            dateFormatter: activityDateFormatter,
                            measurementFormatter: measurementFormatter)
                    }.sorted())
            }
    }
    
    // MARK: - Access to Model
    
    @Published var catalog: [Group<Activity>] = []
    @Published var isLoading = false
    
    var placeholder: [Group<Activity>] = [
        .init(title: "This Week",
              position: 1,
              content: [
                .init(
                    activity: .init(
                        sport: .swim,
                        workout: "Pool Swim",
                        duration: .init(value: 1, unit: .hours),
                        distance: .init(value: 1, unit: .miles),
                        date: Date()),
                    dateFormatter: DateFormatter(),
                    measurementFormatter: MeasurementFormatter()),
                .init(
                    activity: .init(
                        sport: .swim,
                        workout: "Another Pool Swim",
                        duration: .init(value: 1, unit: .hours),
                        distance: .init(value: 1, unit: .miles),
                        date: Date()),
                    dateFormatter: DateFormatter(),
                    measurementFormatter: MeasurementFormatter()),
                .init(
                    activity: .init(
                        sport: .swim,
                        workout: "Ocean Swim",
                        duration: .init(value: 1, unit: .hours),
                        distance: .init(value: 1, unit: .miles),
                        date: Date()),
                    dateFormatter: DateFormatter(),
                    measurementFormatter: MeasurementFormatter())
                ])
    ]
    
    // MARK: - Intents
    
    private var subscriptions = Set<AnyCancellable>()
    
    func loadRecentActivity() {
        guard !isLoading else {
            return
        }

        isLoading = true
        activityRepo.getAll()
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            })
            .sink(receiveValue: store.update(_:))
            .store(in: &subscriptions)
    }
    
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

    struct Activity : Identifiable, Comparable {
        let activity: TriCoach.Activity
        private let dateFormatter: DateFormatter
        private let measurementFormatter: MeasurementFormatter
        
        let id = UUID()
        
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

        init(activity: TriCoach.Activity, dateFormatter: DateFormatter, measurementFormatter: MeasurementFormatter) {
            self.activity = activity
            self.dateFormatter = dateFormatter
            self.measurementFormatter = measurementFormatter
        }
        
        // MARK: - Comparable

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.activity.date > rhs.activity.date
        }
    }
}
