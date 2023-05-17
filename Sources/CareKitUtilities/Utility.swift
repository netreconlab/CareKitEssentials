//
//  Utility.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 10/16/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

// MARK: Used for testing and previews

enum TaskID {
    static let doxylamine = "doxylamine"
    static let nausea = "nausea"
    static let stretch = "stretch"
    static let kegels = "kegels"
    static let steps = "steps"

    static var ordered: [String] {
        [Self.steps, Self.doxylamine, Self.kegels, Self.stretch, Self.nausea]
    }
}

class Utility {

    class func createEmptyStore() -> OCKStore {
        OCKStore(name: "noStore", type: .inMemory)
    }

    class func createMorningScheduleElement() -> OCKScheduleElement {
        let thisMorning = Calendar.current.startOfDay(for: Date())
        let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: thisMorning)!
        let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)!

        return OCKScheduleElement(start: beforeBreakfast,
                                  end: nil,
                                  interval: DateComponents(day: 1))

    }

    class func createNauseaTask() -> OCKTask {
        let nauseaSchedule = OCKSchedule(composing: [createMorningScheduleElement()])

        var nausea = OCKTask(id: TaskID.nausea,
                             title: "Track nausea",
                             carePlanUUID: nil,
                             schedule: nauseaSchedule)
        nausea.impactsAdherence = false
        nausea.instructions = "Tap button below."
        nausea.asset = "bed.double"
        return nausea
    }

    class func createNauseaEvent() throws -> OCKAnyEvent {
        guard let schedule = createNauseaTask().schedule.event(forOccurrenceIndex: 0) else {
            throw CareKitUtilitiesError.requiredValueCantBeUnwrapped
        }
        return OCKAnyEvent(task: createNauseaTask(),
                           outcome: OCKOutcome(taskUUID: UUID(),
                                               taskOccurrenceIndex: 0,
                                               values: []),
                           scheduleEvent: schedule)
    }

    class func createPreviewStore() -> OCKStore {
        let store = OCKStore(name: "noStore", type: .inMemory)
        let patientId = "preview"
        Task {
            do {
                // If patient exists, assume store is already populated
                _ = try await store.fetchPatient(withID: patientId)
            } catch {
                var patient = OCKPatient(id: patientId,
                                         givenName: "Preview",
                                         familyName: "Patient")
                patient.birthday = Calendar.current.date(byAdding: .year,
                                                         value: -20,
                                                         to: Date())
                _ = try? await store.addPatient(patient)
                try? await store.populateSampleData()
            }
        }
        return store
    }
}
