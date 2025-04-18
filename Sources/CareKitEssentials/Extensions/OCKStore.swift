//
//  OCKStore.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/15/23.
//

import Foundation
import CareKitStore

public extension OCKStore {

    func addTasksIfNotPresent(_ tasks: [OCKTask]) async throws -> [OCKTask] {

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = tasks.compactMap { $0.id }

        let foundTasks = try await fetchTasks(query: query)

        // Find all missing tasks.
        let tasksNotInStore = tasks.filter { potentialTask -> Bool in
            guard foundTasks.first(where: { $0.id == potentialTask.id }) == nil else {
                return false
            }
            return true
        }

        // Only add if there's a new task
        guard tasksNotInStore.count > 0 else {
            return []
        }

        let addedTasks = try await addTasks(tasksNotInStore)
        return addedTasks
    }
}

extension OCKStore {
    func populateSampleData() async throws {

        let thisMorning = Calendar.current.startOfDay(for: Date())
        let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: thisMorning)!
        let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)!
        let afterLunch = Calendar.current.date(byAdding: .hour, value: 14, to: aFewDaysAgo)!

        let schedule = OCKSchedule(composing: [
            Utility.createMorningScheduleElement(),
            OCKScheduleElement(start: afterLunch,
                               end: nil,
                               interval: DateComponents(day: 2))
        ])

        var doxylamine = OCKTask(id: TaskID.doxylamine,
                                 title: "Take Doxylamine",
                                 carePlanUUID: nil,
                                 schedule: schedule)
        doxylamine.instructions = "Take 25mg of doxylamine when you experience nausea."
        doxylamine.asset = "pills.fill"

        let nausea = Utility.createNauseaTask()

        let kegelElement = OCKScheduleElement(start: beforeBreakfast,
                                              end: nil,
                                              interval: DateComponents(day: 2))
        let kegelSchedule = OCKSchedule(composing: [kegelElement])
        var kegels = OCKTask(id: TaskID.kegels,
                             title: "Kegel Exercises",
                             carePlanUUID: nil,
                             schedule: kegelSchedule)
        kegels.impactsAdherence = true
        kegels.instructions = "Perform kegel exercies"

        let stretchElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1))
        let stretchSchedule = OCKSchedule(composing: [stretchElement])
        var stretch = OCKTask(id: TaskID.stretch,
                              title: "Stretch",
                              carePlanUUID: nil,
                              schedule: stretchSchedule)
        stretch.impactsAdherence = true
        stretch.asset = "figure.walk"

        try await addTasksIfNotPresent([nausea, doxylamine, kegels, stretch])
    }
}
