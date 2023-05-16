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
 A view model that can be subclassed to build more intricate view models for custom
 CareKit cards.
 */
public class CardViewModel: ObservableObject {

    /// The error encountered by the view model.
    @Published public var error: Error?
    /// The store associated with the view model.
    @Environment(\.careStore) public var store
    @Published var value = OCKOutcomeValue(0.0)

    /// The latest value as a Text view.
    public var valueText: Text {
        Text(value.description)
    }
    
    /// The event associated with the view model.
    private(set) var event: OCKAnyEvent
    /// A custom details title to display for the task of the view model.
    private(set) var detailsTitle: String?
    /// A custom details information string to display for the task of the view model.
    private(set) var detailsInformation: String?

    var action: (OCKOutcomeValue?) async -> Void = { _ in }

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
                    _ = try await self.saveOutcome(values: [value])
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
    ///     - event: The respective event.
    ///     - value: The default outcome value for the view model. Defaults to 0.0.
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
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - value: The default outcome value for the view model. Defaults to 0.0.
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

    /// Append an outcome value to an event's outcome.
    /// - Parameters:
    ///   - value: The outcome value.
    /// - Returns: The saved outcome value.
    /// - Throws: An error if the outcome value can't be saved.
    open func appendOutcomeValue(value: OCKOutcomeValue) async throws -> OCKAnyOutcome {

        // Update the outcome with the new value
        guard var outcome = event.outcome else {
            let outcome = try makeOutcomeWith([value])
            return try await store.addAnyOutcome(outcome)
        }
        outcome.values.append(value)
        return try await store.updateAnyOutcome(outcome)
    }

    /// Set the completion state for an event.
    /// - Parameters:
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
    ///   - values: Array of OCKOutcomeValue
    ///   - completion: Result after setting the completion for the event.
    open func setEvent(values: [OCKOutcomeValue],
                       completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {

        // If the event is complete, create an outcome with the specified values.
        if !values.isEmpty {
            do {
                let outcome = try makeOutcomeWith(values)
                store.addAnyOutcome(outcome) { result in
                    switch result {
                    case .failure(let error): completion?(.failure(error))
                    case .success(let outcome): completion?(.success(outcome))
                    }
                }
            } catch {
                completion?(.failure(error))
            }
        } else {
            // if the event is incomplete, delete the outcome
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
    ///   - values: Array of `OCKOutcomeValue`
    /// - Returns: The saved outcome.
    /// - Throws: An error if the outcome value can't be saved.
    open func saveOutcome(values: [OCKOutcomeValue]) async throws -> OCKAnyOutcome {
        try await setEvent(values: values)
    }

    /// Make an outcome for an event with the given outcome values.
    /// - Parameters:
    ///   - values: The outcome values to attach to the outcome.
    open func makeOutcomeWith(_ values: [OCKOutcomeValue]) throws -> OCKAnyOutcome {
        guard let task = event.task as? OCKAnyVersionableTask else {
            throw CareKitUtilitiesError.errorString("Cannot make outcome for event: \(event)")
        }
        return OCKOutcome(taskUUID: task.uuid, taskOccurrenceIndex: event.scheduleEvent.occurrence, values: values)
    }
}
