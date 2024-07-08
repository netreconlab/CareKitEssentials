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
        let sortedByCreatedDate = try outcomes.sortedNewestToOldest(
            \.createdDate
        )
        XCTAssertEqual(sortedByCreatedDate.count, 2)
        XCTAssertEqual(sortedByCreatedDate.first, secondOutcome)
        XCTAssertEqual(sortedByCreatedDate.last, firstOutcome)

        // Test lessThanKeyPath
        let sortedByCreatedDate2 = try outcomes.sortedNewestToOldest(
            \.createdDate,
             lessThanEqualTo: firstDate
        )
        XCTAssertEqual(sortedByCreatedDate2.count, 1)
        XCTAssertEqual(sortedByCreatedDate2.first, firstOutcome)
        let sortedByCreatedDate3 = try outcomes.sortedNewestToOldest(
            \.createdDate,
             lessThanEqualTo: secondDate
        )
        XCTAssertEqual(sortedByCreatedDate3.count, 2)
        XCTAssertEqual(sortedByCreatedDate3.first, secondOutcome)
        XCTAssertEqual(sortedByCreatedDate3.last, firstOutcome)

        // Test KeyPath of nil should throw error
        XCTAssertThrowsError(try outcomes.sortedNewestToOldest(
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
        let sortedByOccurrenceIndex = outcomes.sortedNewestToOldest(
            \.taskOccurrenceIndex
        )
        XCTAssertEqual(sortedByOccurrenceIndex.count, 2)
        XCTAssertEqual(sortedByOccurrenceIndex.first, secondOutcome)
        XCTAssertEqual(sortedByOccurrenceIndex.last, firstOutcome)

        // Test lessThanKeyPath
        let sortedByOccurrenceIndex2 = outcomes.sortedNewestToOldest(
            \.taskOccurrenceIndex,
             lessThanEqualTo: firstIndex
        )
        XCTAssertEqual(sortedByOccurrenceIndex2.count, 1)
        XCTAssertEqual(sortedByOccurrenceIndex2.first, firstOutcome)
        let sortedByOccurrenceIndex3 = outcomes.sortedNewestToOldest(
            \.taskOccurrenceIndex,
             lessThanEqualTo: secondIndex
        )
        XCTAssertEqual(sortedByOccurrenceIndex3.count, 2)
        XCTAssertEqual(sortedByOccurrenceIndex3.first, secondOutcome)
        XCTAssertEqual(sortedByOccurrenceIndex3.last, firstOutcome)
    }
}
