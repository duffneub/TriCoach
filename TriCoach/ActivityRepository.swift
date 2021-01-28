//
//  ActivityRepository.swift
//  TriCoach
//
//  Created by Duff Neubauer on 1/27/21.
//

import Combine
import Foundation

protocol ActivityRepository {
    func getAll() -> AnyPublisher<[Activity], Error>
}
