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
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event)

        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressAveragingSingleOutcomeSingleTarget() async throws {
        let outcomeValues = [OCKOutcomeValue(10.0)]
        let targetValues = [OCKOutcomeValue(20.0)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event)
        let goal = try XCTUnwrap(progress.goal)

        XCTAssertEqual(progress.value, 10.0, accuracy: 0.0001)
        XCTAssertEqual(goal, 20.0, accuracy: 0.0001)
    }

    func testProgressAveragingOutcomesMultipleTargetsDoubles() async throws {
        let outcomeValues = [
            OCKOutcomeValue(10.0),
            OCKOutcomeValue(20.0),
            OCKOutcomeValue(30.0)
        ]
        let targetValues = [
            OCKOutcomeValue(15.0),
            OCKOutcomeValue(25.0),
            OCKOutcomeValue(35.0)
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event)
        let expectedValue = outcomeValues
            .map { $0.doubleValue ?? 0.0 }
            .reduce(0, +) / Double(outcomeValues.count)
        let expectedGoal = targetValues
            .map { $0.doubleValue ?? 0.0 }
            .reduce(0, +)
        let goal = try XCTUnwrap(progress.goal)

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(goal, expectedGoal, accuracy: 0.0001 )
    }

    func testProgressAveragingMultipleIntegerOutcomesMultipleTargetsIntegers() async throws {
        let outcomeValues = [
            OCKOutcomeValue(10),
            OCKOutcomeValue(20),
            OCKOutcomeValue(30)
        ]
        let targetValues = [
            OCKOutcomeValue(15),
            OCKOutcomeValue(25),
            OCKOutcomeValue(35)
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event)
        let expectedValue = outcomeValues
            .map { $0.numberValue?.doubleValue ?? 0.0 }
            .reduce(0, +) / Double(outcomeValues.count)
        let expectedGoal = targetValues
            .map { $0.numberValue?.doubleValue ?? 0.0 }
            .reduce(0, +)
        let goal = try XCTUnwrap(progress.goal)

        XCTAssertEqual(goal, expectedGoal, accuracy: 0.0001)
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)

    }

    func testProgressByAveragingOutcomeValuesNoOutcomeTargetValues() async throws {
        let targetValues = [
            OCKOutcomeValue(15.0),
            OCKOutcomeValue(25.0),
            OCKOutcomeValue(35.0)
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: false,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event)
        let expectedGoal = targetValues
            .map { $0.doubleValue ?? 0.0 }
            .reduce(0, +)
        let goal = try XCTUnwrap(progress.goal)

        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertEqual(goal, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByAveragingOutcomeValuesOutcomeValuesNoTargetValues() async throws {
        let outcomeValues = [
            OCKOutcomeValue(10.0),
            OCKOutcomeValue(20.0),
            OCKOutcomeValue(15.0)
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event)
        let expectedValue = outcomeValues
            .map { $0.doubleValue ?? 0.0 }
            .reduce(0, +) / Double(outcomeValues.count)

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressByAveragingOutcomeValuesWithMatchingKind() async throws {
        let kind = "myKind"
        let kind2 = "otherKind"
        let ten = 10.0
        let twenty = 20.0
        var valueOfTen = OCKOutcomeValue(10.0)
        valueOfTen.kind = kind
        var valueOfTwenty = OCKOutcomeValue(20.0)
        valueOfTwenty.kind = kind
        var valueOfThirty = OCKOutcomeValue(30.0)
        valueOfThirty.kind = kind2
        let outcomeValues = [
            valueOfTen,
            valueOfTwenty,
            valueOfThirty
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(
                for: event,
                kind: kind
            )
        let expectedValue = (ten + twenty) / 2.0

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }

    func testProgressByAveragingOutcomeValuesWithNonMatchingKinds() async throws {
        let kind = "myKind"
        let kind2 = "otherKind"
        let kind3 = "nonMatchingKind"

        var valueOfTen = OCKOutcomeValue(10.0)
        valueOfTen.kind = kind
        var valueOfTwenty = OCKOutcomeValue(20.0)
        valueOfTwenty.kind = kind
        var valueOfThirty = OCKOutcomeValue(30.0)
        valueOfThirty.kind = kind2

        let outcomeValues =  [
            valueOfTen,
            valueOfTwenty,
            valueOfThirty
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event, kind: kind3)

        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressByAveragingOutcomeValueWithNonNilKind() async throws {
        let kind = "myKind"
        let kind2 = "otherKind"

        var valueOfTen = OCKOutcomeValue(10.0)
        valueOfTen.kind = kind
        var valueOfTwenty = OCKOutcomeValue(20.0)
        valueOfTwenty.kind = kind
        var valueOfThirty = OCKOutcomeValue(30.0)
        valueOfThirty.kind = kind2

        let outcomeValues = [
            valueOfTen,
            valueOfTwenty,
            valueOfThirty
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event, kind: nil)
        let expectedValue = 0.0
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }

    func testProgressByAveragingOutcomeValuesWithKind() async throws {
        let kind = "otherKind"
        let ten  = 10.0
        let twenty = 20.0
        let thirty = 30.0
        var valueOfTen = OCKOutcomeValue(ten)
        valueOfTen.kind = nil
        var valueOfTwenty = OCKOutcomeValue(twenty)
        valueOfTwenty.kind = nil
        var valueOfThirty = OCKOutcomeValue(thirty)
        valueOfThirty.kind = kind
        let outcomeValues = [
            valueOfTen,
            valueOfTwenty,
            valueOfThirty
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(
                for: event,
                kind: kind
            )
       let expectedValue = thirty
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }

    func testProgressByMedianOutcomeValuesNoOutcomeNoTarget() async throws {
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: false
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByMedianOutcomeValues(for: event)
        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressByMedianOutcomeValuesSingleOutcomeSingleTarget() async throws {
        let outcomeValues = [OCKOutcomeValue(10.0)]
        let targetValues = [OCKOutcomeValue(15.0)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByMedianOutcomeValues(for: event)
        let expectedValue = outcomeValues
            .compactMap { $0.doubleValue }
            .sorted()[outcomeValues.count / 2]
        let expectedGoal = targetValues
            .compactMap { $0.doubleValue }
            .reduce(0, +)
        let goal = try XCTUnwrap(progress.goal)

        XCTAssertEqual(goal, expectedGoal, accuracy: 0.0001)
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)

    }

    func testProgressByMedianOutcomeValuesMultipleOutcomesMultipleTargets() async throws {
        let outcomeValues = [
            OCKOutcomeValue(20.0),
            OCKOutcomeValue(10.0),
            OCKOutcomeValue(30.0)
        ]
        let targetValues = [
            OCKOutcomeValue(15.0),
            OCKOutcomeValue(25.0),
            OCKOutcomeValue(35.0)
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByMedianOutcomeValues(for: event)
        let expectedValue = outcomeValues
            .compactMap { $0.doubleValue }
            .sorted()[outcomeValues.count / 2]
        let expectedGoal = targetValues
            .compactMap { $0.doubleValue }
            .reduce(0, +)
        let goal = try XCTUnwrap(progress.goal)

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(goal, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByMedianOutcomeValuesEvenOutcomeValues() async throws {
        let outcomeValues = [
            OCKOutcomeValue(20.0),
            OCKOutcomeValue(10.0)
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByMedianOutcomeValues(for: event)
        let sortedValues = outcomeValues
            .compactMap { $0.doubleValue }
            .sorted()
        let index = outcomeValues.count / 2
        let expectedValue = (sortedValues[index] + sortedValues[index - 1]) / 2.0

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }

    func testProgressByMedianOutcomeValuesOddOutcomeValues() async throws {
        let outcomeValues = [
            OCKOutcomeValue(10.0),
            OCKOutcomeValue(30.0),
            OCKOutcomeValue(20.0)
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByMedianOutcomeValues(for: event)
        let sortedValues = outcomeValues
            .compactMap { $0.doubleValue }
            .sorted()
        let index = sortedValues.count / 2
        let expectedvalue = sortedValues[index]

        XCTAssertEqual(progress.value, expectedvalue, accuracy: 0.0001)
    }

    func testProgressByStreakOutcomeValuesNoOutcomeNoTarget() async throws {
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: false
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByStreakOutcomeValues(for: event)

        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressByStreakOutcomeValuesSingleOutcomeSingleTarget() async throws {
        let outcomeValues = [OCKOutcomeValue(10.0)]
        let targetValues = [OCKOutcomeValue(15.0)]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByStreakOutcomeValues(for: event)
        let expectedValue = outcomeValues
            .map { $0.doubleValue ?? 0.0 }
            .reduce(0, +) / Double(outcomeValues.count)
        let expectedGoal = targetValues
            .map { $0.doubleValue ?? 0.0 }
            .reduce(0, +)
        let goal = try XCTUnwrap(progress.goal)

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(goal, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByStreakOutcomeValuesMultipleOutcomesMultipleTargets() async throws {
        let outcomeValues = [
            OCKOutcomeValue(10.0),
            OCKOutcomeValue(20.0),
            OCKOutcomeValue(30.0)
        ]
        let targetValues = [
            OCKOutcomeValue(15.0),
            OCKOutcomeValue(25.0),
            OCKOutcomeValue(35.0)
        ]
        let event = OCKAnyEvent.mock(
            taskUUID: UUID(),
            occurrence: 0,
            hasOutcome: true,
            values: outcomeValues,
            targetValues: targetValues
        )
        let progress = CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByStreakOutcomeValues(for: event)
        let expectedValue = outcomeValues
            .compactMap { $0.doubleValue }
            .reduce(0, +)
        let expectedGoal = targetValues
            .compactMap { $0.doubleValue }
            .reduce(0, +)
        let goal = try XCTUnwrap(progress.goal)

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(goal, expectedGoal, accuracy: 0.0001)
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

        let outcome = hasOutcome ? OCKOutcome(
            taskUUID: task.uuid,
            taskOccurrenceIndex: occurrence,
            values: values
        ) :
            nil
        let event = OCKAnyEvent(
            task: task,
            outcome: outcome,
            scheduleEvent: schedule.event(forOccurrenceIndex: occurrence)!
        )

        return event
    }
}
