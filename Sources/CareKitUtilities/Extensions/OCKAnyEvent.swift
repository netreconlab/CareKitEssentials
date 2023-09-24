//
//  OCKAnyEvent.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import SwiftUI

public extension OCKAnyEvent {

    /// The title for the event's task.
    var title: String {
        task.title ?? ""
    }

    /// Denotes the time and date of the event.
    var detail: String? {
        ScheduleUtility.scheduleLabel(for: self)
    }

    /// Instructions for the event's task.
    var instructions: String? {
        task.instructions
    }

    var detailText: Text? {
        guard let detail else { return nil }
        return Text(detail)
    }

    var instructionsText: Text? {
        guard let instructions else { return nil }
        return Text(instructions)
    }

    #if canImport(UIKit)
    /// The first event task asset.
    var asset: UIImage? {
        guard let asset = self.task.asset else {
            return nil
        }
        return UIImage.asset(asset)
    }
    #endif

    /// The first event outcome.
    /// - note: If you need `OCKOutcome` or `OCKHealthKitOutcome`, you need to cast
    /// this to the respective type.
    var sortedOutcome: OCKAnyOutcome? {
        self.outcome?.sortedOutcomeValuesByRecency()
    }

    /// Returns **true** if the first event is complete.
    var isComplete: Bool {
        self.outcome != nil
    }

    /// The first event outcome values.
    var outcomeValues: [OCKOutcomeValue]? {
        sortedOutcome?.values
    }

    /// The first event first outcome value.
    var outcomeFirstValue: OCKOutcomeValue? {
        outcomeValues?.first
    }

    /// The first event first outcome value as a **Int**.
    /// - note: Returns **0** if the first outcome is **nil**.
    var outcomeValueInt: Int {
        outcomeFirstValue?.integerValue ?? 0
    }

    /// The first event first outcome value as a **Double**.
    /// - note: Returns **0.0** if the first outcome is **nil**.
    var outcomeValueDouble: Double? {
        outcomeFirstValue?.doubleValue
    }

    /// The first event first outcome value as a **String**.
    /// - note: Returns an empty **String** if the first outcome is **nil**.
    var outcomeValueString: String? {
        outcomeFirstValue?.stringValue
    }

    /// The first event first outcome value as a **Date**.
    var outcomeValueDate: Date? {
        outcomeFirstValue?.dateValue
    }

    /// The first event first outcome value as **Data**.
    var outcomeValueData: Data? {
        outcomeFirstValue?.dataValue
    }

    /**
     Get the answer for a specific kind of `OCKOutcomeValue`.
     - parameter kind: The kind of value.
     - returns: A double value of the kind. Defaults to 0.0.
     */
    func answer(kind: String) -> Double {
        let values = outcome?.values ?? []
        let match = values.first(where: { $0.kind == kind })
        return match?.doubleValue ?? 0
    }

    /// Sort outcome values by descending updated/created date
    func sortedOutcomeValuesByRecency() -> OCKAnyEvent {
        guard
            var newOutcome = outcome,
            !newOutcome.values.isEmpty else { return self }

        let sortedValues = newOutcome.values.sorted {
            $0.createdDate > $1.createdDate
        }

        newOutcome.values = sortedValues
        return OCKAnyEvent(task: task, outcome: newOutcome, scheduleEvent: scheduleEvent)
    }

    /// Prepends the kind to event outcome.
    func prependKindToValue() -> OCKAnyEvent {
        guard
            var newOutcome = outcome,
            !newOutcome.values.isEmpty else { return self }

        let prependedValues = newOutcome.values.map { originalValue -> OCKOutcomeValue in
            if let kind = originalValue.kind,
               let type = kind.split(separator: ".").last {
                var newValue = originalValue
                newValue.value = "\(type): \(newValue.value)"
                return newValue
            } else {
                return originalValue
            }
        }

        newOutcome.values = prependedValues
        return OCKAnyEvent(task: task, outcome: newOutcome, scheduleEvent: scheduleEvent)
    }
}
