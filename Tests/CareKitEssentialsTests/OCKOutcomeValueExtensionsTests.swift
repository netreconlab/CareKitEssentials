//
//  OCKOutcomeValueExtensionsTests.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 2/18/25.
//

import XCTest
import CareKitStore
@testable import CareKitEssentials

final class OCKOutcomeValueExtensionsTests: XCTestCase {

    func testFilteredOutcomeValuesGreaterThanEqualToOptionalKeyPath() async throws {
        // A date that represents 00h 00m 00s today or midnight.
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // A date that represents 08h 00m 00s today or 8am.
        let breakfastTime = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

        // A date that represents 13h 00m 00s or 1pm.
        let lunchTime = Calendar.current.date(byAdding: .hour, value: 5, to: breakfastTime)!

        // A date that represents 19h 30m 00s or 7.30pm.
        let dinnerTime = Calendar.current.date(byAdding: .minute, value: 270, to: lunchTime)!

        var stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        stepsAtBreakfast.kind = String("\(breakfastTime)")
        var stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        stepsAtLunch.kind = String("\(lunchTime)")
        var stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        stepsAtDinner.kind = String("\(dinnerTime)")

        let outcomeValues = [stepsAtBreakfast, stepsAtLunch, stepsAtDinner]

        XCTAssertEqual(outcomeValues.count, 3)

        let outcomeValuesAfterLunchInclusive = try outcomeValues.filter(
            \.kind,
             greaterThanEqualTo: String("\(lunchTime)")
        )
        XCTAssertEqual(outcomeValuesAfterLunchInclusive.count, 2)

        let afterLunch = lunchTime + 1
        let outcomesAfterLunch = try outcomeValues.filter(
            \.kind,
             greaterThanEqualTo: String("\(afterLunch)")
        )
        XCTAssertEqual(outcomesAfterLunch.count, 1)

        // Test KeyPath of nil should throw error
        let stepsWithNilStartDate = OCKOutcomeValue(4000, units: "steps")
        let updatedOutcomeValues = outcomeValues + [stepsWithNilStartDate]
        XCTAssertThrowsError(try updatedOutcomeValues.filter(
            \.dateInterval?.start,
             greaterThanEqualTo: lunchTime
        ))
    }

    func testFilteredOutcomeValuesGreaterThanEqualToRequiredKeyPath() {
        // A date that represents 00h 00m 00s today or midnight.
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // A date that represents 08h 00m 00s today or 8am.
        let breakfastTime = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

        // A date that represents 13h 00m 00s or 1pm.
        let lunchTime = Calendar.current.date(byAdding: .hour, value: 5, to: breakfastTime)!

        // A date that represents 19h 30m 00s or 7.30pm.
        let dinnerTime = Calendar.current.date(byAdding: .minute, value: 270, to: lunchTime)!

        var stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        stepsAtBreakfast.createdDate = breakfastTime
        var stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        stepsAtLunch.createdDate = lunchTime
        var stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        stepsAtDinner.createdDate = dinnerTime
        let outcomeValues = [stepsAtBreakfast, stepsAtLunch, stepsAtDinner]

        let outcomeValuesAfterLunchInclusive = outcomeValues.filter(
            \.createdDate,
            greaterThanEqualTo: lunchTime
        )
        XCTAssertEqual(outcomeValuesAfterLunchInclusive.count, 2)

        let afterLunch = lunchTime + 1
        let outcomesAfterLunch = outcomeValues.filter(
            \.createdDate,
             greaterThanEqualTo: afterLunch
        )
        XCTAssertEqual(outcomesAfterLunch.count, 1)
    }

    func testFilteredOutcomeValuesLessThanEqualToOptionalKeyPath() async throws {
        // A date that represents 00h 00m 00s today or midnight.
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // A date that represents 08h 00m 00s today or 8am.
        let breakfastTime = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

        // A date that represents 13h 00m 00s or 1pm.
        let lunchTime = Calendar.current.date(byAdding: .hour, value: 5, to: breakfastTime)!

        // A date that represents 19h 30m 00s or 7.30pm.
        let dinnerTime = Calendar.current.date(byAdding: .minute, value: 270, to: lunchTime)!

        var stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        stepsAtBreakfast.kind = String("\(breakfastTime)")
        var stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        stepsAtLunch.kind = String("\(lunchTime)")
        var stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        stepsAtDinner.kind = String("\(dinnerTime)")
        let outcomeValues = [stepsAtBreakfast, stepsAtLunch, stepsAtDinner]

        let outcomeValuesBeforeLunchInclusive = try outcomeValues.filter(
            \.kind,
             lessThanEqualTo: String("\(lunchTime)")
        )
        XCTAssertEqual(outcomeValuesBeforeLunchInclusive.count, 2)

        let beforeLunch = lunchTime - 1
        let outcomesBeforeLunch = try outcomeValues.filter(
            \.kind,
             lessThanEqualTo: String("\(beforeLunch)")
        )

        XCTAssertEqual(outcomesBeforeLunch.count, 1)

        // Test KeyPath of nil should throw error
        let stepsWithNilStartDate = OCKOutcomeValue(4000, units: "steps")
        let updatedOutcomeValues = outcomeValues + [stepsWithNilStartDate]
        XCTAssertThrowsError(try updatedOutcomeValues.filter(
            \.dateInterval?.start,
             lessThanEqualTo: lunchTime
        ))
    }

    func testFilteredOutcomeValuesLessThanEqualToRequiredKeyPath() {
        // A date that represents 00h 00m 00s today or midnight.
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // A date that represents 08h 00m 00s today or 8am.
        let breakfastTime = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

        // A date that represents 13h 00m 00s or 1pm.
        let lunchTime = Calendar.current.date(byAdding: .hour, value: 5, to: breakfastTime)!

        // A date that represents 19h 30m 00s or 7.30pm.
        let dinnerTime = Calendar.current.date(byAdding: .minute, value: 270, to: lunchTime)!

        var stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        stepsAtBreakfast.createdDate = breakfastTime
        var stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        stepsAtLunch.createdDate = lunchTime
        var stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        stepsAtDinner.createdDate = dinnerTime
        let outcomeValues = [stepsAtBreakfast, stepsAtLunch, stepsAtDinner]

        let outcomeValuesBeforeLunchInclusive = outcomeValues.filter(
            \.createdDate,
             lessThanEqualTo: lunchTime
        )
        XCTAssertEqual(outcomeValuesBeforeLunchInclusive.count, 2)

        let beforeLunch = lunchTime - 1
        let outcomesBeforeLunch = outcomeValues.filter(
            \.createdDate,
             lessThanEqualTo: beforeLunch
        )
        XCTAssertEqual(outcomesBeforeLunch.count, 1)
    }

    func testSortedOutcomeValuesLowestRequiredKeyPath() {
        // A date that represents 00h 00m 00s today or midnight.
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // A date that represents 08h 00m 00s today or 8am.
        let breakfastTime = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

        // A date that represents 13h 00m 00s or 1pm.
        let lunchTime = Calendar.current.date(byAdding: .hour, value: 5, to: breakfastTime)!

        // A date that represents 19h 30m 00s or 7.30pm.
        let dinnerTime = Calendar.current.date(byAdding: .minute, value: 270, to: lunchTime)!

        var stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        stepsAtBreakfast.createdDate = breakfastTime
        var stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        stepsAtLunch.createdDate = lunchTime
        var stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        stepsAtDinner.createdDate = dinnerTime
        let outcomeValues = [stepsAtLunch, stepsAtBreakfast, stepsAtDinner]
        let expectedOutcomeValues = [stepsAtBreakfast, stepsAtLunch, stepsAtDinner]

        let sortedOutcomeValues = outcomeValues.sortedByLowest(\.createdDate)
        XCTAssertEqual(sortedOutcomeValues, expectedOutcomeValues)
    }

    func testSortedOutcomeValuesLowestOptionalKeyPath() throws {

        let stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        let stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        let stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        let outcomeValues = [stepsAtLunch, stepsAtBreakfast, stepsAtDinner]
        let expectedOutcomeValues = [stepsAtBreakfast, stepsAtLunch, stepsAtDinner]

        let sortedOutcomeValues = try outcomeValues.sortedByLowest(\.integerValue)
        XCTAssertEqual(sortedOutcomeValues, expectedOutcomeValues)
    }

    func testSortedOutcomeValuesHighestRequiredKeyPath() {
        // A date that represents 00h 00m 00s today or midnight.
        let startOfDay = Calendar.current.startOfDay(for: Date())

        // A date that represents 08h 00m 00s today or 8am.
        let breakfastTime = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

        // A date that represents 13h 00m 00s or 1pm.
        let lunchTime = Calendar.current.date(byAdding: .hour, value: 5, to: breakfastTime)!

        // A date that represents 19h 30m 00s or 7.30pm.
        let dinnerTime = Calendar.current.date(byAdding: .minute, value: 270, to: lunchTime)!

        var stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        stepsAtBreakfast.createdDate = breakfastTime
        var stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        stepsAtLunch.createdDate = lunchTime
        var stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        stepsAtDinner.createdDate = dinnerTime
        let outcomeValues = [stepsAtLunch, stepsAtBreakfast, stepsAtDinner]
        let expectedOutcomeValues = [stepsAtDinner, stepsAtLunch, stepsAtBreakfast]

        let sortedOutcomeValues = outcomeValues.sortedByHighest(\.createdDate)
        XCTAssertEqual(sortedOutcomeValues, expectedOutcomeValues)
    }

    func testSortedOutcomeValuesHighestOptionalKeyPath() throws {

        let stepsAtBreakfast = OCKOutcomeValue(1000, units: "steps")
        let stepsAtLunch = OCKOutcomeValue(2000, units: "steps")
        let stepsAtDinner = OCKOutcomeValue(3000, units: "steps")
        let outcomeValues = [stepsAtLunch, stepsAtBreakfast, stepsAtDinner]
        let expectedOutcomeValues = [stepsAtDinner, stepsAtLunch, stepsAtBreakfast]

        let sortedOutcomeValues = try outcomeValues.sortedByHighest(\.integerValue)
        XCTAssertEqual(sortedOutcomeValues, expectedOutcomeValues)
    }
}
