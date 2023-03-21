//
//  OCKTaskEvents.swift
//  OCKSample
//
//  Created by Corey Baker on 12/3/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitUI
import CareKitStore
import Foundation

/// Helper properties and methods for using OCKTaskEvents.
public extension OCKTaskEvents {

    /// The event for this view model.
    var firstEvent: OCKAnyEvent? {
        first?.first
    }

    /// The first event task.
    /// - note: If you need `OCKTask` or `OCKHealthKitTask`, you need to cast
    /// this to the respective type.
    var firstEventTask: OCKAnyTask? {
        firstEvent?.task
    }

    /// The first event task title.
    var firstEventTitle: String {
        firstEventTask?.title ?? ""
    }

    /// The first event task instructions.
    var firstTaskInstructions: String? {
        firstEventTask?.instructions
    }

    /// The first event detail.
    var firstEventDetail: String? {
        ScheduleUtility.scheduleLabel(for: firstEvent)
    }

    /// The first event outcome.
    /// - note: If you need `OCKOutcome` or `OCKHealthKitOutcome`, you need to cast
    /// this to the respective type.
    var firstEventOutcome: OCKAnyOutcome? {
        firstEvent?.outcome?.sortedOutcomeValuesByRecency()
    }

    /// Returns **true** if the first event is complete.
    var isFirstEventComplete: Bool {
        firstEventOutcome != nil
    }

    /// The first event outcome values.
    var firstEventOutcomeValues: [OCKOutcomeValue]? {
        firstEventOutcome?.values
    }

    /// The first event first outcome value.
    var firstEventOutcomeFirstValue: OCKOutcomeValue? {
        firstEventOutcomeValues?.first
    }

    /// The first event first outcome value as a **Int**.
    /// - note: Returns **0** if the first outcome is **nil**.
    var firstEventOutcomeValueInt: Int {
        firstEventOutcomeFirstValue?.integerValue ?? 0
    }

    /// The first event first outcome value as a **Double**.
    /// - note: Returns **0.0** if the first outcome is **nil**.
    var firstEventOutcomeValueDouble: Double? {
        firstEventOutcomeFirstValue?.doubleValue
    }

    /// The first event first outcome value as a **String**.
    /// - note: Returns an empty **String** if the first outcome is **nil**.
    var firstEventOutcomeValueString: String? {
        firstEventOutcomeFirstValue?.stringValue
    }

    /// The first event first outcome value as a **Date**.
    var firstEventOutcomeValueDate: Date? {
        firstEventOutcomeFirstValue?.dateValue
    }

    /// The first event first outcome value as **Data**.
    var firstEventOutcomeValueData: Data? {
        firstEventOutcomeFirstValue?.dataValue
    }
}
