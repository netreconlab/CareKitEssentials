//
//  OCKAnyEventStore.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/11/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import os.log

extension OCKAnyEventStore {

    func toggleBooleanOutcome(for event: OCKAnyEvent) async throws -> OCKAnyOutcome {
        try await withCheckedThrowingContinuation { continuation in
            toggleBooleanOutcome(for: event, completion: continuation.resume)
        }
    }

    func toggleBooleanOutcome(
        for event: OCKAnyEvent,
        completion: @escaping OCKResultClosure<OCKAnyOutcome> = { _ in }
    ) {
        // Retrieve the event from the store so that
        // we modify the outcome for the data at the
        // source of truth.
        fetch(event: event) { result in
            switch result {

            case let .failure(error):
                Logger.careKitAnyEventStore.error("Failed to fetch event while toggling event's boolean outcome")
                completion(.failure(error))

            case let .success(event):
                // Mark the event as incomplete
                if let outcome = event.outcome {
                    self.deleteAnyOutcome(outcome) { result in
                        Logger.careKitAnyEventStore.error(
                            "Failed to delete outcome while toggling event's boolean outcome"
                        )
                        completion(result)
                    }

                    // Else mark the event as completed
                } else {
                    let outcome = OCKOutcome(
                        taskUUID: event.task.uuid,
                        taskOccurrenceIndex: event.scheduleEvent.occurrence,
                        values: [OCKOutcomeValue(true)]
                    )
                    self.addAnyOutcome(outcome) { result in
                        Logger.careKitAnyEventStore.error(
                            "Failed add an outcome while toggling event's boolean outcome"
                        )
                        completion(result)
                    }
                }
            }
        }
    }

    private func fetch(
        event: OCKAnyEvent,
        completion: @escaping OCKResultClosure<OCKAnyEvent> = { _ in }
    ) {
        fetchAnyEvent(
            forTask: event.task,
            occurrence: event.scheduleEvent.occurrence,
            callbackQueue: .main
        ) { result in
            switch result {
            case let .failure(error):
                Logger.careKitAnyEventStore.error("Failed to fetch event")
                completion(.failure(error))
            case let .success(event):
                completion(.success(event))
            }
        }
    }
}
