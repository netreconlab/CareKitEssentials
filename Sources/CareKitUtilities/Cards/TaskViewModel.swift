//
//  TaskViewModel.swift
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
 A basic view model that can be subclassed to make more intricate view models for custom
 CareKit cards.
 */
public class TaskViewModel: ObservableObject {

    /// The error encountered by the view model.
    @Published public var currentError: Error?
    @Published var value = OCKOutcomeValue(0.0)
    @Environment(\.careStore) public var store

    public var valueText: Text {
        Text(value.description)
    }

    var action: (OCKOutcomeValue?) async -> Void = { _ in }
    private(set) var event: OCKAnyEvent
    // private(set) var query: SynchronizedTaskQuery?
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
                self.currentError = error
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
    public convenience init(taskID: String,
                            eventQuery: OCKEventQuery,
                            value: OCKOutcomeValue = OCKOutcomeValue(0.0),
                            detailsTitle: String? = nil,
                            detailsInformation: String? = nil) {
        self.value = value
        // setQuery(.taskIDs([taskID], eventQuery))
        // self.query?.perform(using: self)
        self.detailsTitle = detailsTitle
        self.detailsInformation = detailsInformation
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - task: The task associated with the event to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    ///     - value: The default outcome value for the view model. Defaults to
    ///     0.0.
    ///     - detailsTitle: Optional title to be shown on custom CareKit Cards.
    ///     - detailsInformation: Optional detailed information to be shown on custom CareKit Cards.
    public convenience init(task: OCKAnyTask,
                            eventQuery: OCKEventQuery,
                            value: OCKOutcomeValue = OCKOutcomeValue(0.0),
                            detailsTitle: String? = nil,
                            detailsInformation: String? = nil) {
        self.value = value
        // setQuery(.tasks([task], eventQuery))
        // self.query?.perform(using: self)
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
    public convenience init(taskID: String,
                            eventQuery: OCKEventQuery,
                            value: OCKOutcomeValue = OCKOutcomeValue(0.0),
                            detailsTitle: String? = nil,
                            detailsInformation: String? = nil,
                            action: ((OCKOutcomeValue?) async -> Void)?) {
        self.value = value
        // setQuery(.taskIDs([taskID], eventQuery))
        self.detailsTitle = detailsTitle
        self.detailsInformation = detailsInformation
        if let action = action {
            self.action = action
        }
        // self.query?.perform(using: self)
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - task: The task associated with the event to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    ///     - value: The default outcome value for the view model. Defaults to
    ///     0.0.
    ///     - detailsTitle: Optional title to be shown on custom CareKit Cards.
    ///     - detailsInformation: Optional detailed information to be shown on custom CareKit Cards.
    ///     - action: The action to take when a task is completed.
    public convenience init(task: OCKAnyTask,
                            eventQuery: OCKEventQuery,
                            value: OCKOutcomeValue = OCKOutcomeValue(0.0),
                            detailsTitle: String? = nil,
                            detailsInformation: String? = nil,
                            action: ((OCKOutcomeValue?) async -> Void)?) {
        self.value = value
      //  setQuery(.tasks([task], eventQuery))
        self.detailsTitle = detailsTitle
        self.detailsInformation = detailsInformation
        if let action = action {
            self.action = action
        }
        // self.query?.perform(using: self)
    }

    /*
    func setQuery(_ query: SynchronizedTaskQuery) {
        self.query = query
    } */

    @MainActor
    public func checkIfValueShouldUpdate(_ updatedEvents: OCKAnyEvent) {
        if let changedValue = updatedEvents.outcomeValues?.first,
            self.value != changedValue {
            self.value = changedValue
        }
    }

    @MainActor
    public func setError(_ updatedError: Error?) {
        self.currentError = updatedError
    }
    
    /// Make an outcome for an event with the given outcome values.
    /// - Parameters:
    ///   - event: The event for which to create the outcome.
    ///   - values: The outcome values to attach to the outcome.
    open func makeOutcomeFor(event: OCKAnyEvent, withValues values: [OCKOutcomeValue]) throws -> OCKAnyOutcome {
        guard let task = event.task as? OCKAnyVersionableTask else {
            throw OCKTaskControllerError.cannotMakeOutcomeFor(event)
        }
        return OCKOutcome(taskUUID: task.uuid, taskOccurrenceIndex: event.scheduleEvent.occurrence, values: values)
    }
}

/*
extension TaskViewModel {
    enum SynchronizedTaskQuery {

        case taskQuery(_ taskQuery: OCKTaskQuery, _ eventQuery: OCKEventQuery)
        case taskIDs(_ taskIDs: [String], _ eventQuery: OCKEventQuery)

        static func tasks(_ tasks: [OCKAnyTask], _ eventQuery: OCKEventQuery) -> Self {
            let taskIDs = Array(Set(tasks.map { $0.id }))
            return .taskIDs(taskIDs, eventQuery)
        }

        func perform(using viewModel: TaskViewModel) {
            switch self {
            case let .taskQuery(taskQuery, eventQuery):
                viewModel.fetchAndObserveEvents(forTaskQuery: taskQuery, eventQuery: eventQuery)
            case let .taskIDs(taskIDs, eventQuery):
                viewModel.fetchAndObserveEvents(forTaskIDs: taskIDs, eventQuery: eventQuery)
            }
        }
    }
}
*/
