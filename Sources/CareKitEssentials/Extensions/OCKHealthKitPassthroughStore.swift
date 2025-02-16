//
//  OCKHealthKitPassthroughStore.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 2/16/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

public extension OCKHealthKitPassthroughStore {

    func addTasksIfNotPresent(_ tasks: [OCKHealthKitTask]) async throws {

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
            return
        }

        _ = try await addTasks(tasksNotInStore)
    }
}
