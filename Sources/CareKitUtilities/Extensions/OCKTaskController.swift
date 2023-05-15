//
//  OCKTaskController.swift
//  OCKSample
//
//  Created by Corey Baker on 12/4/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import Foundation

public extension TaskViewModel {

    /// Append an outcome value to an event's outcome.
    /// - Parameters:
    ///   - value: The value for the outcome value that is being created.
    ///   - indexPath: Index path of the event to which the outcome will be added.
    /// - Returns: The saved outcome value.
    /// - Throws: An error if the outcome value can't be saved.
    func appendOutcomeValue(
        value: OCKOutcomeValueUnderlyingType) async throws -> OCKAnyOutcome {
            try await withCheckedThrowingContinuation { continuation in
                self.appendOutcomeValue(value: value,
                                        completion: continuation.resume)
            }
    }

    /// Append an outcome value to an event's outcome.
    /// - Parameters:
    ///   - value: The outcome value.
    ///   - indexPath: Index path of the event to which the outcome will be added.
    /// - Returns: The saved outcome value.
    /// - Throws: An error if the outcome value can't be saved.
    func appendOutcomeValue(value: OCKOutcomeValue) async throws -> OCKAnyOutcome {

        // Update the outcome with the new value
        guard var outcome = event.outcome else {
            let outcome = try makeOutcomeFor(event: event, withValues: [value])
            return try await store.addAnyOutcome(outcome)
        }
        outcome.values.append(value)
        return try await store.updateAnyOutcome(outcome)
    }

    /// Set the completion state for an event.
    /// - Parameters:
    ///   - indexPath: Index path of the event.
    ///   - values: Array of OCKOutcomeValue
    /// - Returns: The updated outcome.
    /// - Throws: An error if the outcome value can't be set.
    func setEvent(values: [OCKOutcomeValue]) async throws -> OCKAnyOutcome {
        try await withCheckedThrowingContinuation { continuation in
            self.setEvent(values: values,
                          completion: continuation.resume)
        }
    }

    /// Save the outcome for a particular event.
    /// - Parameters:
    ///   - indexPath: Index path of the event.
    ///   - values: Array of `OCKOutcomeValue`
    /// - Returns: The saved outcome.
    /// - Throws: An error if the outcome value can't be saved.
    func saveOutcomesForEvent(values: [OCKOutcomeValue]) async throws -> OCKAnyOutcome {
        try await setEvent(event, values: values, store: store)
    }
}

