//
//  OCKAnyEvent+Equatable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKAnyEvent: Equatable {
    public static func == (
        lhs: OCKAnyEvent,
        rhs: OCKAnyEvent
    ) -> Bool {
        let idAndSchedule = lhs.id == rhs.id &&
            lhs.scheduleEvent == rhs.scheduleEvent
        let task = isTasksEqual(
            lhs: lhs.task,
            rhs: rhs.task
        )
        let outcome = isOutcomesEqual(
            lhs: lhs.outcome,
            rhs: rhs.outcome
        )
        return idAndSchedule &&
            task &&
            outcome
    }

    static func isTasksEqual(
        lhs: any OCKAnyTask,
        rhs: any OCKAnyTask
    ) -> Bool {

        guard let lhsTask = lhs as? OCKTask,
              let rhsTask = rhs as? OCKTask else {
            let id = lhs.id == rhs.id
            let title = lhs.title == rhs.title
            let instructions = lhs.instructions == rhs.instructions
            let impactsAdherence = lhs.impactsAdherence == rhs.impactsAdherence
            let schedule = lhs.schedule == rhs.schedule
            let groupIdentifier = lhs.groupIdentifier == rhs.groupIdentifier
            let uuid = lhs.uuid == rhs.uuid
            let asset = lhs.asset == rhs.asset
            let remoteID = lhs.remoteID == rhs.remoteID
            let notes = lhs.notes == rhs.notes
            let effectiveDate = lhs.effectiveDate == rhs.effectiveDate
            return id &&
                title &&
                instructions &&
                impactsAdherence &&
                schedule &&
                groupIdentifier &&
                uuid &&
                asset &&
                remoteID &&
                notes &&
                effectiveDate
        }
        return lhsTask == rhsTask
    }

    static func isOutcomesEqual(
        lhs: OCKAnyOutcome?,
        rhs: OCKAnyOutcome?
    ) -> Bool {

        guard let lhsOutcome = lhs as? OCKOutcome,
              let rhsOutcome = rhs as? OCKOutcome else {
            let id = lhs?.id == rhs?.id
            let taskUUID = lhs?.taskUUID == rhs?.taskUUID
            let taskOccurrenceIndex = lhs?.taskOccurrenceIndex == rhs?.taskOccurrenceIndex
            let values = lhs?.values == rhs?.values
            let remoteID = lhs?.remoteID == rhs?.remoteID
            let groupIdentifier = lhs?.groupIdentifier == rhs?.groupIdentifier
            let notes = lhs?.notes == rhs?.notes
            return id &&
                taskUUID &&
                taskOccurrenceIndex &&
                values &&
                remoteID &&
                groupIdentifier &&
                notes
        }
        return lhsOutcome == rhsOutcome
    }
}
