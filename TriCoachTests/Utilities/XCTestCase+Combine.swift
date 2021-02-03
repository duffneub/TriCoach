//
//  XCTestCase+Combine.swift
//  TriCoachTests
//
//  Created by Duff Neubauer on 2/2/21.
//

import Combine
import XCTest

extension XCTestCase {
    func await<P : Publisher>(_ publisher: P, timeout: TimeInterval = 1.0) -> P.Output where P.Failure == Never {
        try! _await(publisher, timeout: timeout)
    }
    
    private func _await<P : Publisher>(_ publisher: P, timeout: TimeInterval = 1.0) throws -> P.Output {
        let expectation = self.expectation(description: "Publisher to either receive value or complete with error")
        var cancellable: AnyCancellable?
        
        var result: Result<P.Output, P.Failure>!
        cancellable = publisher.sink { completion in
            if case let .failure(error) = completion {
                result = .failure(error)
                expectation.fulfill()
                cancellable?.cancel()
            }
        } receiveValue: { value in
            result = .success(value)
            expectation.fulfill()
            cancellable?.cancel()
        }

        waitForExpectations(timeout: timeout)
        return try result.get()
    }
}
