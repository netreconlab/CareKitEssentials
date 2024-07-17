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
        XCTAssertEqual(progress.value, 10.0, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, 20.0, accuracy: 0.0001)
    }

    func testProgressAveragingMultipleIntegerOutcomesMultipleTargetsDoubles() async throws {
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
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
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
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByAveragingOutcomeValuesMoreOutcomeLessTargetValues() async throws {
        let outcomeValues = [
         OCKOutcomeValue(10),
         OCKOutcomeValue(15),
         OCKOutcomeValue(20),
         OCKOutcomeValue(30),
         OCKOutcomeValue(40)
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
            XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
            XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByAveragingOutcomeValuesZeroOutcomeTargetValues() async throws {
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
        let progress =
        CareTaskProgressStrategy<LinearCareTaskProgress>
            .computeProgressByAveragingOutcomeValues(for: event)
            XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
            let expectedGoal = targetValues
            .map { $0.doubleValue ?? 0.0 }
            .reduce(0, +)
            XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
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
        var valueOfTen = OCKOutcomeValue(10.0)
        valueOfTen.kind = "myKind"
        var valueOfTwenty = OCKOutcomeValue(20.0)
        valueOfTwenty.kind = "myKind"
        var valueOfThirty = OCKOutcomeValue(30.0)
        valueOfThirty.kind = "otherKind"
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
            .computeProgressByAveragingOutcomeValues(for: event, kind: "myKind")
        let filteredOutcomeValues = outcomeValues
            .filter { $0.kind == "myKind" }
        let completedOutcomesValues = Double(filteredOutcomeValues.count)
        let summedOutcomesValue = filteredOutcomeValues
            .map { $0.value as? Double ?? 0.0 }
            .reduce(0, +)
        let expectedValue = completedOutcomesValues >= 1.0 ? summedOutcomesValue / completedOutcomesValues : 0.0

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }

    func testProgressByAveragingOutcomeValuesWithNonMatchingKinds() async throws {
        var valueOfTen = OCKOutcomeValue(10.0)
        valueOfTen.kind = "myKind"
        var valueOfTwenty = OCKOutcomeValue(20.0)
        valueOfTwenty.kind = "myKind"
        var valueOfThirty = OCKOutcomeValue(30.0)
        valueOfThirty.kind = "otherKind"

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
            .computeProgressByAveragingOutcomeValues(for: event, kind: "nonMatchingKind")
        let filteredOutcomeValues = outcomeValues
            .filter { $0.kind == "nonMatchingKind" }
        let completedOutcomesValues = Double(filteredOutcomeValues.count)
        let summedOutcomesValue = filteredOutcomeValues
            .map { $0.value as? Double ?? 0.0 }
            .reduce(0, +)
        XCTAssertEqual(progress.value, 0.0, accuracy: 0.0001)
        XCTAssertNil(progress.goal)
    }

    func testProgressByAveragingOutcomeValueWithNoNilKind() async throws {
        var valueOfTen = OCKOutcomeValue(10.0)
        valueOfTen.kind = "myKind"
        var valueOfTwenty = OCKOutcomeValue(20.0)
        valueOfTwenty.kind = "myKind"
        var valueOfThirty = OCKOutcomeValue(30.0)
        valueOfThirty.kind = "otherKind"

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
        let filteredOutcomeValues = outcomeValues
            .filter { $0.kind == nil }
        let completedOutcomesValues = Double(filteredOutcomeValues.count)
        let summedOutcomesValue = filteredOutcomeValues
            .map { $0.value as? Double ?? 0.0 }
            .reduce(0, +)
        let expectedValue = completedOutcomesValues >= 1.0 ? summedOutcomesValue / completedOutcomesValues : 0.0

        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
    }

    func testProgressByAveragingOutcomeValuesWithKind() async throws {
        var valueOfTen = OCKOutcomeValue(10.0)
        valueOfTen.kind = nil
        var valueOfTwenty = OCKOutcomeValue(20.0)
        valueOfTwenty.kind = nil
        var valueOfThirty = OCKOutcomeValue(30.0)
        valueOfThirty.kind = "otherKind"
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
        let filteredOutcomeValues = outcomeValues
            .filter { $0.kind == nil }
        let completedOutcomesValues = Double(filteredOutcomeValues.count)
        let summedOutcomesValue = filteredOutcomeValues
            .map { $0.value as? Double ?? 0.0 }
            .reduce(0, +)
        let expectedValue = completedOutcomesValues >= 1.0 ? summedOutcomesValue / completedOutcomesValues : 0.0
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
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)

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
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
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
            .compactMap {$0.doubleValue}
            .sorted()
        let expectedValue = (sortedValues[sortedValues.count / 2] + sortedValues[sortedValues.count / 2 - 1]) / 2
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
            .compactMap {$0.doubleValue}
            .sorted()
        let expectedvalue = sortedValues[sortedValues.count / 2]
        XCTAssertEqual(progress.value, expectedvalue, accuracy: 0.0001)
    }

    func testProgressByMedianOutcomeValuesEvenDuplicateOutcomeValues() async throws {
        let outcomeValues = [
            OCKOutcomeValue(10.0),
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
            .compactMap {$0.doubleValue}
            .sorted()
        let expectedValue = (sortedValues[sortedValues.count / 2] + sortedValues[sortedValues.count / 2 - 1]) / 2
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
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
        XCTAssertEqual(progress.value, expectedValue, accuracy: 0.0001)
        XCTAssertEqual(progress.goal!, expectedGoal, accuracy: 0.0001)
    }

    func testProgressByStreakOutcomeValuesMultipleOutcomesMultipleTargets() async throws {
        let outcomeValues = [
            OCKOutcomeValue(10.0),
            OCKOutcomeValue(20.0),
            OCKOutcomeValue(30.0)]
        let targetValues = [
            OCKOutcomeValue(15.0),
            OCKOutcomeValue(25.0),
            OCKOutcomeValue(35.0)]
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
        let event =
        OCKAnyEvent(
            task: task,
            outcome: outcome,
            scheduleEvent: schedule.event(forOccurrenceIndex: occurrence)!
            )

        return event
    }
}