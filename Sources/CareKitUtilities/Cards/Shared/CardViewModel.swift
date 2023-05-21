//
//  CardViewModel.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 12/4/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import Foundation
import SwiftUI

/**
 A view model that can be subclassed to build more intricate view models for
 CareKit style cards.
 */
open class CardViewModel: ObservableObject {

    // MARK: Published public read/write properties

    /// The error encountered by the view model.
    @Published public var error: Error?
    /// The store associated with the view model.
    @Environment(\.careStore) public var store
    /// The latest `OCKOutcomeValue` for the event.
    @Published public var value = OCKOutcomeValue(0.0) {
        didSet {
            guard isInitialValue,
                  let double = value.doubleValue else {
                return
            }
            valueAsDouble = double
        }
    }
    /// The latest`OCKOutcomeValue` for the event as a `Double`.
    @Published public var valueAsDouble: Double = 0 {
        didSet {
            guard !isInitialValue else {
                isInitialValue = true
                return
            }
            var updatedValue = value
            updatedValue.value = valueAsDouble
            value = updatedValue
        }
    }

    // MARK: Public read/write properties

    /// Specifies if this is the first time a value is being set.
    public var isInitialValue = true

    // MARK: Public read only properties

    /// The latest`OCKOutcomeValue` for the event as a String.
    public var valueAsString: String {
        value.description
    }
    /// The event associated with the view model.
    private(set) var event: OCKAnyEvent
    /// A custom details title to display for the task of the view model.
    private(set) var detailsTitle: String?
    /// A custom details information string to display for the task of the view model.
    private(set) var detailsInformation: String?

    // MARK: Private properties
    var action: (OCKOutcomeValue?) async -> Void = { _ in }

    /// Create an instance with specified content for an event. The view will update when changes
    /// occur in the store.
    /// - Parameters:
    ///     - event: A event to associate with the view model.
    ///     - initialValue: The default outcome value for the view model. Defaults to 0.0.
    ///     - detailsTitle: An optional title for the event.
    ///     - detailsInformation: An optional detailed information string for the event.
    ///     - action: The action to take when event is completed.
    public init(event: OCKAnyEvent,
                initialValue: OCKOutcomeValue = OCKOutcomeValue(0.0),
                detailsTitle: String? = nil,
                detailsInformation: String? = nil,
                action: ((OCKOutcomeValue?) async -> Void)? = nil) {
        self.value = event.outcomeFirstValue ?? initialValue
        self.detailsTitle = detailsTitle
        self.detailsInformation = detailsInformation
        self.event = event
        guard let action = action else {
            // Use the default action
            self.action = { value in
                do {
                    guard let value = value else {
                        // Attempts to delete outcome if it already exists.
                        _ = try await self.saveOutcomeValues([])
                        return
                    }
                    _ = try await self.appendOutcomeValues([value])
                } catch {
                    self.error = error
                }
            }
            return
        }
        self.action = action
    }

    // MARK: Intentions

    /// Append an `OCKOutcomeValue` to an event's `OCKOutcome`.
    /// - Parameters:
    ///   - values: An array of `OCKOutcomeValue`'s to append.
    /// - Throws: An error if the outcome values cannot be set.
    /// - Note: Appends occur if an`OCKOutcome` currently exists for the event.
    /// Otherwise a new `OCKOutcome` is created with the respective outcome values.
    open func appendOutcomeValues(_ values: [OCKOutcomeValue]) async throws {

        // Update the outcome with the new value
        guard var outcome = event.outcome else {
            let outcome = try createOutcomeWithValues(values)
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
    open func saveOutcomeValues(_ values: [OCKOutcomeValue]) async throws {

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
            let outcome = try createOutcomeWithValues(values)
            _ = try await store.addAnyOutcome(outcome)
            return
        }
        // Update the outcome with the new values.
        currentOutcome.values = values
        _ = try await store.updateAnyOutcome(currentOutcome)
    }

    // MARK: Helpers

    /// Create an outcome for an event with the given outcome values.
    /// - Parameters:
    ///   - values: The outcome values to attach to the outcome.
    open func createOutcomeWithValues(_ values: [OCKOutcomeValue]) throws -> OCKAnyOutcome {
        guard let task = event.task as? OCKAnyVersionableTask else {
            throw CareKitUtilitiesError.errorString("Cannot make outcome for event: \(event)")
        }
        return OCKOutcome(taskUUID: task.uuid,
                          taskOccurrenceIndex: event.scheduleEvent.occurrence,
                          values: values)
    }

}
