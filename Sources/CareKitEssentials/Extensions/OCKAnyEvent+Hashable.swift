//
//  OCKAnyEvent+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/11/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import Foundation

extension OCKAnyEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(scheduleEvent)
        if let task = task as? OCKTask {
            hasher.combine(task)
        } else {
            hasher.combine(task.id)
            // OCKAnyTask
            hasher.combine(task.id)
            hasher.combine(task.title)
            hasher.combine(task.instructions)
            hasher.combine(task.impactsAdherence)
            hasher.combine(task.schedule)
            hasher.combine(task.groupIdentifier)
            hasher.combine(task.uuid)
            hasher.combine(task.asset)
            hasher.combine(task.remoteID)
            hasher.combine(task.notes)
            hasher.combine(task.effectiveDate)
        }
        if let outcome = outcome as? OCKOutcome {
            hasher.combine(outcome)
        } else if let outcome {
            // OCKAnyOutcome
            hasher.combine(outcome.id)
            hasher.combine(outcome.taskUUID)
            hasher.combine(outcome.taskOccurrenceIndex)
            hasher.combine(outcome.values)
            hasher.combine(outcome.remoteID)
            hasher.combine(outcome.groupIdentifier)
            hasher.combine(outcome.notes)
        }
    }
}
