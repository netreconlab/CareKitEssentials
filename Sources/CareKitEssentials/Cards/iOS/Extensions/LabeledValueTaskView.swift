//
//  LabeledValueTaskView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/20/23.
//

#if !os(watchOS)

import CareKit
import CareKitStore
import CareKitUI
import Foundation
import SwiftUI

public extension LabeledValueTaskView where Header == InformationHeaderView {

    /// Create a view using data from an event.
    ///
    /// This view displays the numeric progress for the event by summing outcome values.
    ///
    /// - Parameters:
    ///   - event: The data that appears in the view.
    ///   - numberFormatter: An object that formats the progress and target values.
    init(
        event: OCKAnyEvent,
        numberFormatter: NumberFormatter? = nil
    ) {
        let units = event.outcome?.values.first?.units

        let progress = event.computeProgress(by: .summingOutcomeValues)

        let status: LabeledValueTaskViewStatus = progress.isCompleted ?
            .complete(
                Text(progress.valueDescription(formatter: numberFormatter)),
                units.map(Text.init)
            ) :
            .incomplete(Text(loc("INCOMPLETE")))
        self.init(
            status: status,
            header: {
                InformationHeaderView(
                    title: Text(event.title),
                    information: event.detailText,
                    event: event
                )
            }
        )
    }
}

#endif
