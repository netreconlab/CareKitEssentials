//
//  OCKEvent.swift
//  
//
//  Created by Luis Millan on 7/19/24.
//

import CareKitStore
import Foundation

extension OCKAnyEvent {

    static func mock(
        taskUUID: UUID,
        occurrence: Int,
        taskTitle: String? = nil,
        hasOutcome: Bool = false,
        values: [OCKOutcomeValue] = [],
        targetValues: [OCKOutcomeValue] = []
    ) -> Self {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let schedule = OCKSchedule.dailyAtTime(
            hour: 1,
            minutes: 0,
            start: startOfDay,
            end: nil,
            text: nil,
            targetValues: targetValues
        )
        var task = OCKTask(
            id: taskUUID.uuidString,
            title: taskTitle,
            carePlanUUID: nil,
            schedule: schedule
        )
        task.uuid = taskUUID

        let outcome = hasOutcome ? OCKOutcome(
            taskUUID: task.uuid,
            taskOccurrenceIndex: occurrence,
            values: values
        ) :
            nil
        let event = OCKAnyEvent(
            task: task,
            outcome: outcome,
            scheduleEvent: schedule.event(forOccurrenceIndex: occurrence)!
        )

        return event
    }
}
