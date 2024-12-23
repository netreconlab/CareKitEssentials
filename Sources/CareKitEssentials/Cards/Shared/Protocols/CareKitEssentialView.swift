//
//  CareKitEssentialView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 6/24/24.
//

import CareKitStore
import SwiftUI

/// A type that represents part of your app's user interface and provides
/// modifiers that you use to configure views.
public protocol CareKitEssentialView: View {

    /// A repository for CareKit information.
    var store: any OCKAnyStoreProtocol { get }

    /// Update an `OCKAnyEvent` with new `OCKOutcomeValue`'s.
    /// - Parameters:
    ///     - event: The event to update.
    ///     - values: A new array `OCKOutcomeValue`'s.
    /// - Throws: An error if the outcome values cannot be updated.
    /// - Note: Appends occur if an`OCKOutcome` currently exists for the event.
    /// Otherwise a new `OCKOutcome` is created with the respective outcome values.
    func updateEvent(
        _ event: OCKAnyEvent,
        with values: [OCKOutcomeValue]?
    ) async throws -> OCKAnyOutcome

    /// Save a new `OCKAnyOutcome`.
    /// - Parameters:
    ///     - outcome: A new `OCKAnyOutcome`.
    /// - Throws: An error if the outcome cannot be updated.
    func saveOutcome(
        _ outcome: OCKAnyOutcome
    ) async throws

    /// Create an `OCKEventQuery` constrained to a set of `taskIDs` on a particular date.
    /// - Parameters:
    ///     - taskIDs: The array of taskIDs to search.
    ///     - date: The date the event occurs on.
    /// - Returns: An `OCKEventQuery` with the predefined constraints.
    static func eventQuery(
        with taskIDs: [String],
        on date: Date
    ) -> OCKEventQuery
}

public extension CareKitEssentialView {

    func deleteEventOutcome(_ event: OCKAnyEvent) async throws -> OCKAnyOutcome {
        guard let outcome = event.outcome else {
            throw CareKitEssentialsError.errorString("The event does not contain an outcome: \(event)")
        }
        return try await store.deleteAnyOutcome(outcome)
    }

    func updateEvent(
        _ event: OCKAnyEvent,
        with values: [OCKOutcomeValue]?
    ) async throws -> OCKAnyOutcome {
        guard let values = values else {
            // Attempts to delete outcome if it already exists.
            return try await deleteEventOutcome(event)
        }
        return try await self.appendOutcomeValues(
            values,
            event: event
        )
    }

    func saveOutcome(
        _ outcome: OCKAnyOutcome
    ) async throws {
        _ = try await store.addAnyOutcome(outcome)
    }

    /// Append an `OCKOutcomeValue` to an event's `OCKOutcome`.
    /// - Parameters:
    ///   - values: An array of `OCKOutcomeValue`'s to append.
    /// - Throws: An error if the outcome values cannot be set.
    /// - Note: Appends occur if an`OCKOutcome` currently exists for the event.
    /// Otherwise a new `OCKOutcome` is created with the respective outcome values.
    func appendOutcomeValues(
        _ values: [OCKOutcomeValue],
        event: OCKAnyEvent
    ) async throws -> OCKAnyOutcome {

        // Update the outcome with the new value
        guard var outcome = event.outcome else {
            let outcome = createOutcomeWithValues(
                values,
                event: event
            )
            return try await store.addAnyOutcome(outcome)
        }
        outcome.values.append(contentsOf: values)
        return try await store.updateAnyOutcome(outcome)
    }

    /// Set/Replace the `OCKOutcomeValue`'s of an event.
    /// - Parameters:
    ///   - values: An array of `OCKOutcomeValue`'s to save.
    /// - Throws: An error if the outcome values cannot be set.
    /// - Note: Setting `values` to an empty array will delete the current `OCKOutcome` if it currently exists.
    func saveOutcomeValues(
        _ values: [OCKOutcomeValue],
        event: OCKAnyEvent
    ) async throws -> OCKAnyOutcome {

        // Check if outcome values need to be updated.
        guard !values.isEmpty else {
            // If the event has already been completed
            return try await deleteEventOutcome(event)
        }

        // If the event has already been completed
        guard var currentOutcome = event.outcome else {
            // Create a new outcome with the new values.
            let outcome = createOutcomeWithValues(
                values,
                event: event
            )
            return try await store.addAnyOutcome(outcome)
        }
        // Update the outcome with the new values.
        currentOutcome.values = values
        return try await store.updateAnyOutcome(currentOutcome)
    }

    /// Create an outcome for an event.
    /// - Parameters:
    ///   - event: The event the outcome is made for.
    func createOutcomeForEvent(
        _ event: OCKAnyEvent
    ) -> OCKAnyOutcome {
        OCKOutcome(
            taskUUID: event.task.uuid,
            taskOccurrenceIndex: event.scheduleEvent.occurrence,
            values: []
        )
    }

    static func eventQuery(
        with taskIDs: [String],
        on date: Date
    ) -> OCKEventQuery {
        var query = OCKEventQuery(for: date)
        query.taskIDs = taskIDs
        return query
    }
}

extension CareKitEssentialView {

    /// Create an outcome for an event with the given outcome values.
    /// - Parameters:
    ///   - values: The outcome values to attach to the outcome.
    ///   - event: The event the outcome is made for.
    func createOutcomeWithValues(
        _ values: [OCKOutcomeValue],
        event: OCKAnyEvent
    ) -> OCKAnyOutcome {
        var outcome = createOutcomeForEvent(event)
        outcome.values = values
        return outcome
    }

}
