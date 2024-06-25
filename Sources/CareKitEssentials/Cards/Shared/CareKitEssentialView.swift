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
    var careStore: any OCKAnyStoreProtocol { get }
    func updateOutcomeValue(
        _ value: OCKOutcomeValue?,
        for event: OCKAnyEvent
    ) async throws
}

public extension CareKitEssentialView {

    func updateOutcomeValue(
        _ value: OCKOutcomeValue?,
        for event: OCKAnyEvent
    ) async throws {
        guard let value = value else {
            // Attempts to delete outcome if it already exists.
            _ = try await self.saveOutcomeValues(
                [],
                event: event,
                store: careStore
            )
            return
        }
        _ = try await self.appendOutcomeValues(
            [value],
            event: event,
            store: careStore
        )
    }
}

extension CareKitEssentialView {

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

    /// Set/Replace the `OCKOutcomeValue`'s of an event.
    /// - Parameters:
    ///   - values: An array of `OCKOutcomeValue`'s to save.
    /// - Throws: An error if the outcome values cannot be set.
    /// - Note: Setting `values` to an empty array will delete the current `OCKOutcome` if it currently exists.
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
