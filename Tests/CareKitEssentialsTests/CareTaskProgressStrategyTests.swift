//
//  CareTaskProgressStrategyTests.swift
//  CareKitEssentialsTests
//
//  Created by Luis Millan on 7/18/24.
//

import XCTest
import CareKitStore
@testable import CareKitEssentials

final class CareTaskProgressStrategyTests: XCTestCase {
    func testAveragingOutcomeValues() async throws {
        let ten = 10.0
        let twenty = 20.0

        let outcomeValues = [
            OCKOutcomeValue(ten),
            OCKOutcomeValue(twenty)
        ]

        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )

        let progress = event.computeProgress(by: .averagingOutcomeValues())
        let expectedValue = (ten + twenty) / 2

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }

    func testmedianOutcomeValues() async throws {
        let ten = 10.0
        let twenty = 20.0

        let outcomeValues = [
            OCKOutcomeValue(ten),
            OCKOutcomeValue(twenty)
        ]

        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )

        let progress = event.computeProgress(by: .medianOutcomeValues())
        let expectedValue = (ten + twenty) / 2

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }

    func teststreakOutcomeValues() async throws {
        let ten = 10.0
        let twenty = 20.0
        let thirty = 30.0

        let outcomeValues = [
            OCKOutcomeValue(ten),
            OCKOutcomeValue(twenty)
        ]

        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )

        let progress = event.computeProgress(by: .summingOutcomeValues)
        let expectedValue = thirty

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }
}
