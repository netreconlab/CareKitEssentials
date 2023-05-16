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
 A basic view model that can be subclassed to build more intricate view models for custom
 CareKit cards.
 */
public class CardViewModel: ObservableObject {

    /// The error encountered by the view model.
    @Published public var error: Error?
    @Published var value = OCKOutcomeValue(0.0)
    @Environment(\.careStore) public var store

    public var valueText: Text {
        Text(value.description)
    }

    var action: (OCKOutcomeValue?) async -> Void = { _ in }
    private(set) var event: OCKAnyEvent
    private(set) var detailsTitle: String?
    private(set) var detailsInformation: String?

    init(event: OCKAnyEvent) {
        self.event = event
        self.action = { value in
            do {
                guard let value = value else {
                    // No outcome to set
                    return
                }
                if self.event.outcomeValues != nil {
                    _ = try await self.appendOutcomeValue(value: value)
                } else {
                    _ = try await self.saveOutcomesForEvent(values: [value])
                }
            } catch {
                self.error = error
            }
        }
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    ///     - value: The default outcome value for the view model. Defaults to
    ///     0.0.
    ///     - detailsTitle: Optional title to be shown on custom CareKit Cards.
    ///     - detailsInformation: Optional detailed information to be shown on custom CareKit Cards.
    public convenience init(event: OCKAnyEvent,
                            value: OCKOutcomeValue = OCKOutcomeValue(0.0),
                            detailsTitle: String? = nil,
                            detailsInformation: String? = nil) {
        self.init(event: event)
        self.value = value
        self.detailsTitle = detailsTitle
        self.detailsInformation = detailsInformation
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    ///     - value: The default outcome value for the view model. Defaults to
    ///     0.0.
    ///     - detailsTitle: Optional title to be shown on custom CareKit Cards.
    ///     - detailsInformation: Optional detailed information to be shown on custom CareKit Cards.
    ///     - action: The action to take when a task is completed.
    public convenience init(event: OCKAnyEvent,
                            value: OCKOutcomeValue = OCKOutcomeValue(0.0),
                            detailsTitle: String? = nil,
                            detailsInformation: String? = nil,
                            action: ((OCKOutcomeValue?) async -> Void)?) {
        self.init(event: event)
        self.value = value
        self.detailsTitle = detailsTitle
        self.detailsInformation = detailsInformation
        if let action = action {
            self.action = action
        }
    }

    @MainActor
    public func checkIfValueShouldUpdate(_ updatedEvents: OCKAnyEvent) {
        if let changedValue = updatedEvents.outcomeValues?.first,
            self.value != changedValue {
            self.value = changedValue
        }
    }

    /// Append an outcome value to an event's outcome.
    /// - Parameters:
    ///   - value: The outcome value.
    ///   - indexPath: Index path of the event to which the outcome will be added.
    /// - Returns: The saved outcome value.
    /// - Throws: An error if the outcome value can't be saved.
    open func appendOutcomeValue(value: OCKOutcomeValue) async throws -> OCKAnyOutcome {

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
    open func setEvent(values: [OCKOutcomeValue]) async throws -> OCKAnyOutcome {
        try await withCheckedThrowingContinuation { continuation in
            self.setEvent(values: values,
                          completion: continuation.resume)
        }
    }

    /// Set the completion state for an event.
    /// - Parameters:
    ///   - indexPath: Index path of the event.
    ///   - values: Array of OCKOutcomeValue
    ///   - completion: Result after setting the completion for the event.
    open func setEvent(values: [OCKOutcomeValue],
                       completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {

        // If the event is complete, create an outcome with a `true` value
        if !values.isEmpty {
            do {
                let outcome = try makeOutcomeFor(event: event, withValues: values)
                store.addAnyOutcome(outcome) { result in
                    switch result {
                    case .failure(let error): completion?(.failure(error))
                    case .success(let outcome): completion?(.success(outcome))
                    }
                }
            } catch {
                completion?(.failure(error))
            }

        // if the event is incomplete, delete the outcome
        } else {
            guard let outcome = event.outcome else { return }
            store.deleteAnyOutcome(outcome) { result in
                switch result {
                case .failure(let error): completion?(.failure(error))
                case .success(let outcome): completion?(.success(outcome))
                }
            }
        }
    }

    /// Save the outcome for a particular event.
    /// - Parameters:
    ///   - indexPath: Index path of the event.
    ///   - values: Array of `OCKOutcomeValue`
    /// - Returns: The saved outcome.
    /// - Throws: An error if the outcome value can't be saved.
    open func saveOutcomesForEvent(values: [OCKOutcomeValue]) async throws -> OCKAnyOutcome {
        try await setEvent(values: values)
    }

    /// Make an outcome for an event with the given outcome values.
    /// - Parameters:
    ///   - event: The event for which to create the outcome.
    ///   - values: The outcome values to attach to the outcome.
    open func makeOutcomeFor(event: OCKAnyEvent, withValues values: [OCKOutcomeValue]) throws -> OCKAnyOutcome {
        guard let task = event.task as? OCKAnyVersionableTask else {
            throw CareKitUtilitiesError.errorString("Cannot make outcome for event: \(event)")
        }
        return OCKOutcome(taskUUID: task.uuid, taskOccurrenceIndex: event.scheduleEvent.occurrence, values: values)
    }
}
