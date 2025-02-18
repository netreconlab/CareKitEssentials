//
//  OCKOutcomeExtensionsTests.swift
//  CareKitEssentialsTests
//
//  Created by Luis Millan on 7/10/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import XCTest
import CareKitStore
@testable import CareKitEssentials

final class OCKOutcomeExtensionsTests: XCTestCase {

    func testSortedNewestToOldestOptionalKeyPath() async throws {
        let firstDate = Date()
        let secondDate = firstDate + 1
        let taskUUID = UUID()
        var firstOutcome = OCKOutcome(
            taskUUID: taskUUID,
            taskOccurrenceIndex: 0,
            values: []
        )
        firstOutcome.createdDate = firstDate

        var secondOutcome = OCKOutcome(
            taskUUID: taskUUID,
            taskOccurrenceIndex: 1,
            values: []
        )
        secondOutcome.createdDate = secondDate

        let outcomes = [firstOutcome, secondOutcome]

        // Test sorted properly
        XCTAssertNotEqual(firstOutcome, secondOutcome)
        let sortedByCreatedDate = try outcomes.sortedByGreatest(
            \.createdDate
        )
        XCTAssertEqual(sortedByCreatedDate.count, 2)
        XCTAssertEqual(sortedByCreatedDate.first, secondOutcome)
        XCTAssertEqual(sortedByCreatedDate.last, firstOutcome)

        // Test lessThanKeyPath
        let sortedByCreatedDate2 = try outcomes.sortedByGreatest(
            \.createdDate,
             lessThanEqualTo: firstDate
        )
        XCTAssertEqual(sortedByCreatedDate2.count, 1)
        XCTAssertEqual(sortedByCreatedDate2.first, firstOutcome)
        let sortedByCreatedDate3 = try outcomes.sortedByGreatest(
            \.createdDate,
             lessThanEqualTo: secondDate
        )
        XCTAssertEqual(sortedByCreatedDate3.count, 2)
        XCTAssertEqual(sortedByCreatedDate3.first, secondOutcome)
        XCTAssertEqual(sortedByCreatedDate3.last, firstOutcome)

        // Test KeyPath of nil should throw error
        XCTAssertThrowsError(try outcomes.sortedByGreatest(
            \.updatedDate
        ))
    }

    func testSortedNewestToOldestRequiredKeyPath() async throws {
        let firstIndex = 0
        let secondIndex = firstIndex + 1
        let taskUUID = UUID()
        let firstOutcome = OCKOutcome(
            taskUUID: taskUUID,
            taskOccurrenceIndex: firstIndex,
            values: []
        )

        let secondOutcome = OCKOutcome(
            taskUUID: taskUUID,
            taskOccurrenceIndex: secondIndex,
            values: []
        )

        let outcomes = [firstOutcome, secondOutcome]

        // Test sorted properly
        XCTAssertNotEqual(firstOutcome, secondOutcome)
        let sortedByOccurrenceIndex = outcomes.sortedByGreatest(
            \.taskOccurrenceIndex
        )
        XCTAssertEqual(sortedByOccurrenceIndex.count, 2)
        XCTAssertEqual(sortedByOccurrenceIndex.first, secondOutcome)
        XCTAssertEqual(sortedByOccurrenceIndex.last, firstOutcome)

        // Test lessThanKeyPath
        let sortedByOccurrenceIndex2 = outcomes.sortedByGreatest(
            \.taskOccurrenceIndex,
             lessThanEqualTo: firstIndex
        )
        XCTAssertEqual(sortedByOccurrenceIndex2.count, 1)
        XCTAssertEqual(sortedByOccurrenceIndex2.first, firstOutcome)
        let sortedByOccurrenceIndex3 = outcomes.sortedByGreatest(
            \.taskOccurrenceIndex,
             lessThanEqualTo: secondIndex
        )
        XCTAssertEqual(sortedByOccurrenceIndex3.count, 2)
        XCTAssertEqual(sortedByOccurrenceIndex3.first, secondOutcome)
        XCTAssertEqual(sortedByOccurrenceIndex3.last, firstOutcome)
    }

    func testFilteredOutcomeValuesOptionalKeyPath() async throws {
        // A date that represents 00h 00m 00s today or midnight.
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // A date that represents 08h 00m 00s today or 8am.
        let breakfastTime = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

        // A date that represents 13h 00m 00s or 1pm.
        let lunchTime = Calendar.current.date(byAdding: .hour, value: 5, to: breakfastTime)!

        // A date that represents 19h 30m 00s or 7.30pm.
        let dinnerTime = Calendar.current.date(byAdding: .minute, value: 270, to: lunchTime)!

        let heartRateTaskUUID = UUID()
        let stepTaskUUID = UUID()

        var heartRateAtBreakfast = OCKOutcomeValue( 90, units: "bpm")
        heartRateAtBreakfast.startDate = breakfastTime
        var heartRateAtLunch = OCKOutcomeValue( 100, units: "bpm")
        heartRateAtLunch.startDate = lunchTime
        var heartRateAtDinner = OCKOutcomeValue( 80, units: "bpm")
        heartRateAtDinner.startDate = dinnerTime

        let heartRateOutcomes = OCKOutcome(
            taskUUID: heartRateTaskUUID,
            taskOccurrenceIndex: 0,
            values: [heartRateAtBreakfast, heartRateAtLunch, heartRateAtDinner]
        )

        var stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        stepsAtBreakfast.startDate = breakfastTime
        var stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        stepsAtLunch.startDate = lunchTime
        var stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        stepsAtDinner.startDate = dinnerTime

        let stepsOutcomes = OCKOutcome(
            taskUUID: stepTaskUUID,
            taskOccurrenceIndex: 1,
            values: [stepsAtBreakfast, stepsAtLunch, stepsAtDinner]
        )

        XCTAssertNotEqual(heartRateOutcomes, stepsOutcomes)
        let outcomes = [heartRateOutcomes, stepsOutcomes]
        let allOutcomeValues = outcomes.flatMap(\.values)
        XCTAssertEqual(allOutcomeValues.count, 6)

        let outcomesAfterLunchInclusive = try outcomes.filterOutcomeValuesBy(
            \.startDate,
             beingGreaterThanTo: lunchTime
        )
        XCTAssertEqual(outcomesAfterLunchInclusive.count, 2)
        let valuesAfterLunchInclusive = outcomesAfterLunchInclusive.flatMap(\.values)
        XCTAssertEqual(valuesAfterLunchInclusive.count, 4)

        let afterLunch = lunchTime + 1
        let outcomesAfterLunch = try outcomes.filterOutcomeValuesBy(
            \.startDate,
             beingGreaterThanTo: afterLunch
        )
        XCTAssertEqual(outcomesAfterLunchInclusive.count, 2)
        let outcomeValuesAfterLunch = outcomesAfterLunch.flatMap(\.values)
        XCTAssertEqual(outcomeValuesAfterLunch.count, 2)

        XCTAssertThrowsError(try outcomes.filterOutcomeValuesBy(
            \.endDate
        ))
        let noValues = try outcomes.filterOutcomeValuesBy(
            \.startDate
        )
        XCTAssertEqual(noValues.flatMap(\.values)
            .count, 0)
    }

    func testFilteredOutcomeValuesRequiredKeyPath() {
        // A date that represents 00h 00m 00s today or midnight.
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // A date that represents 08h 00m 00s today or 8am.
        let breakfastTime = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

        // A date that represents 13h 00m 00s or 1pm.
        let lunchTime = Calendar.current.date(byAdding: .hour, value: 5, to: breakfastTime)!

        // A date that represents 19h 30m 00s or 7.30pm.
        let dinnerTime = Calendar.current.date(byAdding: .minute, value: 270, to: lunchTime)!

        let heartRateTaskUUID = UUID()
        let stepTaskUUID = UUID()

        var heartRateAtBreakfast = OCKOutcomeValue( 90, units: "bpm")
        heartRateAtBreakfast.createdDate = breakfastTime
        var heartRateAtLunch = OCKOutcomeValue( 100, units: "bpm")
        heartRateAtLunch.createdDate = lunchTime
        var heartRateAtDinner = OCKOutcomeValue( 80, units: "bpm")
        heartRateAtDinner.createdDate = dinnerTime
        let heartRateOutcomes = OCKOutcome(
            taskUUID: heartRateTaskUUID,
            taskOccurrenceIndex: 0,
            values: [heartRateAtBreakfast, heartRateAtLunch, heartRateAtDinner]
        )

        var stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        stepsAtBreakfast.createdDate = breakfastTime
        var stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        stepsAtLunch.createdDate = lunchTime
        var stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        stepsAtDinner.createdDate = dinnerTime
        let stepsOutcomes = OCKOutcome(
            taskUUID: stepTaskUUID,
            taskOccurrenceIndex: 1,
            values: [stepsAtBreakfast, stepsAtLunch, stepsAtDinner]
        )

        let outcomes = [heartRateOutcomes, stepsOutcomes]
        let outcomesAfterLunchInclusive = outcomes.filterOutcomeValuesBy(
            \.createdDate,
             beingGreaterThanTo: lunchTime
        )
        XCTAssertEqual(outcomesAfterLunchInclusive.count, 2)
        let valuesAfterLunchInclusive = outcomesAfterLunchInclusive.flatMap(\.values)
        XCTAssertEqual(valuesAfterLunchInclusive.count, 4)

        let afterLunch = lunchTime + 1
        let outcomesAfterLunch = outcomes.filterOutcomeValuesBy(
            \.createdDate,
             beingGreaterThanTo: afterLunch
        )
        XCTAssertEqual(outcomesAfterLunchInclusive.count, 2)
        let outcomeValuesAfterLunch = outcomesAfterLunch.flatMap(\.values)
        XCTAssertEqual(outcomeValuesAfterLunch.count, 2)

        let noValues =  outcomes.filterOutcomeValuesBy(
            \.createdDate
        )
        XCTAssertEqual(noValues.flatMap(\.values)
            .count, 0)

    }
}
