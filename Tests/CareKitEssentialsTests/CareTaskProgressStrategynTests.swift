//
//  CareTaskProgressStrategyTests.swift
//  CareTaskProgressStrategyTests
//
//  Created by Luis Millan on 7/10/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import XCTest
import CareKitStore
@testable import CareKitEssentials

final class CareTaskProgressStrategyTests: XCTestCase {

    func testProgressByAveragingOutcomeValuesNoOutcomeNoTarget() async throws {
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: false
        )
        // swiftlint:disable:next line_length
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByAveragingOutcomeValues(for: event)

        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressAveragingSingleOutcomeSingleTarget() async throws {
        let outcomeValues = [OCKOutcomeValue(10)]
        let targetValues = [OCKOutcomeValue(20)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        // swiftlint:disable:next line_length
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByAveragingOutcomeValues(for: event)
        XCTAssertEqual(progress.value, 10.0, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, 20.0, accuracy: 0.0001)
    }

    func testProgressAveragingMultipleOutcomesMultipleTargets() async throws {
        let outcomeValues = [OCKOutcomeValue(10),
                             OCKOutcomeValue(20),
                             OCKOutcomeValue(30)]
        let targetValues = [OCKOutcomeValue(15),
                            OCKOutcomeValue(25),
                            OCKOutcomeValue(35)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        // swiftlint:disable:next line_length
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByAveragingOutcomeValues(for: event)
        // swiftlint:disable:next line_length
        let expectedValue = outcomeValues.map { $0.numberValue?.doubleValue ?? 0.0 }.reduce(0, +) / Double(outcomeValues.count)
        let expectedGoal = targetValues.map { $0.numberValue?.doubleValue ?? 0.0 }.reduce(0, +)
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByAveragingOutcomeValuesMoreOutcomeLessTargetValues() async throws {
        let outcomeValues = [OCKOutcomeValue(10),
                             OCKOutcomeValue(15),
                             OCKOutcomeValue(20),
                             OCKOutcomeValue(30),
                             OCKOutcomeValue(40)]
        let targetValues = [OCKOutcomeValue(15),
                           OCKOutcomeValue(25),
                           OCKOutcomeValue(35)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        // swiftlint:disable:next line_length
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByAveragingOutcomeValues(for: event)
        // swiftlint:disable:next line_length
        let expectedValue = outcomeValues.map { $0.numberValue?.doubleValue ?? 0.0 }.reduce(0, +) / Double(outcomeValues.count)
        let expectedGoal = targetValues.map { $0.numberValue?.doubleValue ?? 0.0 }.reduce(0, +)
            XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
            XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByMedianOutcomeValuesNoOutcomeNoTarget() async throws {
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: false
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByMedianOutcomeValues(for: event)
        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressByMedianOutcomeValuesSingleOutcomeSingleTarget() async throws {
        let outcomeValues = [OCKOutcomeValue(10)]
        let targetValues = [OCKOutcomeValue(15)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByMedianOutcomeValues(for: event)
        let expectedValue = outcomeValues.compactMap { $0.numberValue?.doubleValue }.sorted()[outcomeValues.count / 2]
        let expectedGoal = targetValues.compactMap { $0.numberValue?.doubleValue }.reduce(0, +)
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)

    }

    func testProgressByMedianOutcomeValuesMultipleOutcomesMultipleTargets() async throws {
        let outcomeValues = [OCKOutcomeValue(20),
                             OCKOutcomeValue(10),
                             OCKOutcomeValue(30)]
        let targetValues = [OCKOutcomeValue(15),
                            OCKOutcomeValue(25),
                            OCKOutcomeValue(35)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByMedianOutcomeValues(for: event)
        let expectedValue = outcomeValues.compactMap { $0.numberValue?.doubleValue }.sorted()[outcomeValues.count / 2]
        let expectedGoal = targetValues.compactMap { $0.numberValue?.doubleValue }.reduce(0, +)
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByStreakOutcomeValuesNoOutcomeNoTarget() async throws {
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: false
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByStreakOutcomeValues(for: event)
        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressByStreakOutcomeValuesSingleOutcomeSingleTarget() async throws {
        let outcomeValues = [OCKOutcomeValue(10)]
        let targetValues = [OCKOutcomeValue(15)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByStreakOutcomeValues(for: event)
        // swiftlint:disable:next line_length
        let expectedValue = outcomeValues.map { $0.numberValue?.doubleValue ?? 0.0 }.reduce(0, +) / Double(outcomeValues.count)
        let expectedGoal = targetValues.map { $0.numberValue?.doubleValue ?? 0.0 }.reduce(0, +)
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByStreakOutcomeValuesMultipleOutcomesMultipleTargets() async throws {
        let outcomeValues = [OCKOutcomeValue(10),
                             OCKOutcomeValue(20),
                             OCKOutcomeValue(30)]
        let targetValues = [OCKOutcomeValue(15),
                            OCKOutcomeValue(25),
                            OCKOutcomeValue(35)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>.computeProgressByStreakOutcomeValues(for: event)
        let expectedValue = outcomeValues.compactMap { $0.numberValue?.doubleValue }.reduce(0, +)
        let expectedGoal = targetValues.compactMap { $0.numberValue?.doubleValue }.reduce(0, +)
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
    }

}

private extension OCKAnyEvent {

    static func mock(
        taskUUID: UUID,
        occurrence: Int,
        taskTitle: String? = nil,
        hasOutcome: Bool = false,
        values: [OCKOutcomeValue] = [],
        targetValues: [OCKOutcomeValue] = []
    ) -> Self {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let schedule = OCKSchedule.dailyAtTime(
            hour: 1,
            minutes: 0,
            start: startOfDay,
            end: nil,
            text: nil,
            targetValues: targetValues
        )
        var task = OCKTask(
            id: taskUUID.uuidString,
            title: taskTitle,
            carePlanUUID: nil,
            schedule: schedule
        )
        task.uuid = taskUUID

        let outcome = hasOutcome ?
            OCKOutcome(
                taskUUID: task.uuid,
                taskOccurrenceIndex: occurrence,
                values: values
            ) :
            nil
        // swiftlint:disable:next line_length
        let event = OCKAnyEvent(task: task, outcome: outcome, scheduleEvent: schedule.event(forOccurrenceIndex: occurrence)!)

        return event
    }
}
