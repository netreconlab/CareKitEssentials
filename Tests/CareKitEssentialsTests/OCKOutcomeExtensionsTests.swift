import XCTest
import CareKitStore
@testable import CareKitEssentials

// add an argument that takes values: [OCKOutcomeValue] and pass it to the OCKOutcome instance

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
    // swiftlint:disable:next line_length
    // functions to test: computeProgressByAveragingOutcomeValues, computeProgressByMedianOutcomeValues, computeProgressByStreakOutcomeValues

}

/*
 
 gets the outcomeValues of the event, if there is no outcome values then we return an empty array
  let outcomeValues = event.outcome?.values ?? []

  counts the number of outcomeValues
  let completedOutcomesValues = Double(outcomeValues.count)
 
 sums up the outcome values after converting them into a double
 let summedOutcomesValue = outcomeValues
     .map(accumulableDoubleValue)
     .reduce(0, +)
 
 
 gets target values of an event and sums them up
 let targetValues = event.scheduleEvent.element.targetValues

 let summedTargetValue = targetValues
     .map(accumulableDoubleValue)
     .reduce(nil) { partialResult, nextTarget -> Double? in
         return sum(partialResult, nextTarget)
 
 if there is at least one outcome value, get the average
 var value = 0.0
 if completedOutcomesValues >= 1.0 {
     value = summedOutcomesValue / completedOutcomesValues
 
 creates a LinearCareTaskProgress with the calculated average value and summed target value
 let progress = LinearCareTaskProgress(
     value: value,
     goal: summedTargetValue
 */
