//
//  SettingsStore.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/12/21.
//

import Foundation

class SettingsStore {
    @Published var currentDate: () -> Date = Date.init
    @Published var calendar: Calendar = .current
}
