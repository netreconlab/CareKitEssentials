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
    var careStore: any OCKAnyStoreProtocol { get }

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
    ) async throws

    /// Update an `OCKAnyEvent` with new a `OCKOutcome`.
    /// - Parameters:
    ///     - event: The event to update.
    ///     - outcome: A new `OCKOutcome`.
    /// - Throws: An error if the outcome values cannot be updated.
    func updateEvent(
        _ event: OCKAnyEvent,
        with outcome: OCKOutcome?
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

    /// Append an `OCKOutcomeValue` to an event's `OCKOutcome`.
    /// - Parameters:
    ///   - values: An array of `OCKOutcomeValue`'s to append.
    /// - Throws: An error if the outcome values cannot be set.
    /// - Note: Appends occur if an`OCKOutcome` currently exists for the event.
    /// Otherwise a new `OCKOutcome` is created with the respective outcome values.
    func appendOutcomeValues(
        _ values: [OCKOutcomeValue],
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol
    ) async throws

    /// Set/Replace the `OCKOutcomeValue`'s of an event.
    /// - Parameters:
    ///   - values: An array of `OCKOutcomeValue`'s to save.
    /// - Throws: An error if the outcome values cannot be set.
    /// - Note: Setting `values` to an empty array will delete the current `OCKOutcome` if it currently exists.
    func saveOutcomeValues(
        _ values: [OCKOutcomeValue],
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol
    ) async throws
}

public extension CareKitEssentialView {

    func updateEvent(
        _ event: OCKAnyEvent,
        with values: [OCKOutcomeValue]?
    ) async throws {
        guard let values = values else {
            // Attempts to delete outcome if it already exists.
            _ = try await self.saveOutcomeValues(
                [],
                event: event,
                store: careStore
            )
            return
        }
        _ = try await self.appendOutcomeValues(
            values,
            event: event,
            store: careStore
        )
    }

    func updateEvent(
        _ event: OCKAnyEvent,
        with outcome: OCKOutcome?
    ) async throws {
        guard let outcome = outcome else {
            guard let task = event.task as? OCKAnyVersionableTask else {
                throw CareKitEssentialsError.errorString("Cannot make outcome for event: \(event)")
            }
            let outcome = OCKOutcome(
                taskUUID: task.uuid,
                taskOccurrenceIndex: event.scheduleEvent.occurrence,
                values: []
            )
            // Attempts to set the latest outcome values to an empty array.
            _ = try await careStore.deleteAnyOutcome(outcome)
            return
        }
        _ = try await careStore.addAnyOutcome(outcome)
    }

    func appendOutcomeValues(
        _ values: [OCKOutcomeValue],
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol
    ) async throws {

        // Update the outcome with the new value
        guard var outcome = event.outcome else {
            let outcome = try createOutcomeWithValues(
                values,
                event: event,
                store: store
            )
            _ = try await store.addAnyOutcome(outcome)
            return
        }
        outcome.values.append(contentsOf: values)
        _ = try await store.updateAnyOutcome(outcome)
        return
    }

    func saveOutcomeValues(
        _ values: [OCKOutcomeValue],
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol
    ) async throws {

        // Check if outcome values need to be updated.
        guard !values.isEmpty else {
            // If the event has already been completed
            guard let oldOutcome = event.outcome else {
                return
            }
            // Delete the outcome, and create a new one.
            _ = try await store.deleteAnyOutcome(oldOutcome)
            return
        }

        // If the event has already been completed
        guard var currentOutcome = event.outcome else {
            // Create a new outcome with the new values.
            let outcome = try createOutcomeWithValues(
                values,
                event: event,
                store: store
            )
            _ = try await store.addAnyOutcome(outcome)
            return
        }
        // Update the outcome with the new values.
        currentOutcome.values = values
        _ = try await store.updateAnyOutcome(currentOutcome)
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
    func createOutcomeWithValues(
        _ values: [OCKOutcomeValue],
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol
    ) throws -> OCKAnyOutcome {
        guard let task = event.task as? OCKAnyVersionableTask else {
            throw CareKitEssentialsError.errorString("Cannot make outcome for event: \(event)")
        }
        let outcome = OCKOutcome(
            taskUUID: task.uuid,
            taskOccurrenceIndex: event.scheduleEvent.occurrence,
            values: values
        )
        return outcome
    }

}
