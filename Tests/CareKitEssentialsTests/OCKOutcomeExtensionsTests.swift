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

    func testFilteredSortedNewestToOldestOptionalKeyPath() async throws {
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
        let sortedByCreatedDate = try outcomes.sortedByHighest(
            \.createdDate
        )
        XCTAssertEqual(sortedByCreatedDate.count, 2)
        XCTAssertEqual(sortedByCreatedDate.first, secondOutcome)
        XCTAssertEqual(sortedByCreatedDate.last, firstOutcome)

        // Test lessThanKeyPath
        let sortedByCreatedDate2 = try outcomes.filter(
            \.createdDate,
             lessThanEqualTo: firstDate
        ).sortedByHighest(\.createdDate)
        XCTAssertEqual(sortedByCreatedDate2.count, 1)
        XCTAssertEqual(sortedByCreatedDate2.first, firstOutcome)
        let sortedByCreatedDate3 = try outcomes.filter(
            \.createdDate,
             lessThanEqualTo: secondDate
        ).sortedByHighest(\.createdDate)

        XCTAssertEqual(sortedByCreatedDate3.count, 2)
        XCTAssertEqual(sortedByCreatedDate3.first, secondOutcome)
        XCTAssertEqual(sortedByCreatedDate3.last, firstOutcome)

        // Test KeyPath of nil should throw error
        XCTAssertThrowsError(try outcomes.sortedByHighest(
            \.updatedDate
        ))
    }

    func testFilteredSortedNewestToOldestRequiredKeyPath() async throws {
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
        let sortedByOccurrenceIndex = outcomes.sortedByHighest(
            \.taskOccurrenceIndex
        )
        XCTAssertEqual(sortedByOccurrenceIndex.count, 2)
        XCTAssertEqual(sortedByOccurrenceIndex.first, secondOutcome)
        XCTAssertEqual(sortedByOccurrenceIndex.last, firstOutcome)

        // Test lessThanKeyPath
        let sortedByOccurrenceIndex2 = outcomes.filter(
            \.taskOccurrenceIndex,
             lessThanEqualTo: firstIndex
        ).sortedByHighest(\.taskOccurrenceIndex)

        XCTAssertEqual(sortedByOccurrenceIndex2.count, 1)
        XCTAssertEqual(sortedByOccurrenceIndex2.first, firstOutcome)
        let sortedByOccurrenceIndex3 = outcomes.filter(
            \.taskOccurrenceIndex,
             lessThanEqualTo: secondIndex
        ).sortedByHighest(\.taskOccurrenceIndex)
        XCTAssertEqual(sortedByOccurrenceIndex3.count, 2)
        XCTAssertEqual(sortedByOccurrenceIndex3.first, secondOutcome)
        XCTAssertEqual(sortedByOccurrenceIndex3.last, firstOutcome)
    }

    func testFilteredSortedOldestToNewestOptionalKeyPath() async throws {
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
        let sortedByCreatedDate = try outcomes.sortedByLowest(
            \.createdDate
        )
        XCTAssertEqual(sortedByCreatedDate.count, 2)
        XCTAssertEqual(sortedByCreatedDate.last, secondOutcome)
        XCTAssertEqual(sortedByCreatedDate.first, firstOutcome)

        // Test lessThanKeyPath
        let sortedByCreatedDate2 = try outcomes.filter(
            \.createdDate,
             greaterThanEqualTo: secondDate
        ).sortedByLowest(\.createdDate)
        XCTAssertEqual(sortedByCreatedDate2.count, 1)
        XCTAssertEqual(sortedByCreatedDate2.first, secondOutcome)
        let sortedByCreatedDate3 = try outcomes.filter(
            \.createdDate,
             greaterThanEqualTo: firstDate
        ).sortedByLowest(\.createdDate)

        XCTAssertEqual(sortedByCreatedDate3.count, 2)
        XCTAssertEqual(sortedByCreatedDate3.last, secondOutcome)
        XCTAssertEqual(sortedByCreatedDate3.first, firstOutcome)

        // Test KeyPath of nil should throw error
        XCTAssertThrowsError(try outcomes.sortedByLowest(
            \.updatedDate
        ))
    }

    func testFilteredSortedOldestToNewestRequiredKeyPath() async throws {
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
        let sortedByOccurrenceIndex = outcomes.sortedByLowest(
            \.taskOccurrenceIndex
        )
        XCTAssertEqual(sortedByOccurrenceIndex.count, 2)
        XCTAssertEqual(sortedByOccurrenceIndex.last, secondOutcome)
        XCTAssertEqual(sortedByOccurrenceIndex.first, firstOutcome)

        // Test lessThanKeyPath
        let sortedByOccurrenceIndex2 = outcomes.filter(
            \.taskOccurrenceIndex,
             greaterThanEqualTo: secondIndex
        ).sortedByLowest(\.taskOccurrenceIndex)

        XCTAssertEqual(sortedByOccurrenceIndex2.count, 1)
        XCTAssertEqual(sortedByOccurrenceIndex2.first, secondOutcome)
        let sortedByOccurrenceIndex3 = outcomes.filter(
            \.taskOccurrenceIndex,
             greaterThanEqualTo: firstIndex
        ).sortedByLowest(\.taskOccurrenceIndex)
        XCTAssertEqual(sortedByOccurrenceIndex3.count, 2)
        XCTAssertEqual(sortedByOccurrenceIndex3.last, secondOutcome)
        XCTAssertEqual(sortedByOccurrenceIndex3.first, firstOutcome)
    }
}
