//
//  NumericProgressTaskView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/20/23.
//

#if canImport(SwiftUI) && !os(watchOS)

import CareKit
import CareKitStore
import CareKitUI
import Foundation
import SwiftUI

public extension NumericProgressTaskView where Header == InformationHeaderView {

    /// Create a view using data from an event.
    ///
    /// This view displays the numeric progress and goal for the event by summing outcome values.
    ///
    /// - Parameters:
    ///   - event: The data that appears in the view.
    ///   - numberFormatter: An object that formats the progress and target values.
    init(
        event: OCKAnyEvent,
        numberFormatter: NumberFormatter? = nil
    ) {
        let progress = event.computeProgress(by: .summingOutcomeValues)

        self.init(
            progress: Text(progress.valueDescription(formatter: numberFormatter)),
            goal: Text(progress.goalDescription(formatter: numberFormatter)),
            instructions: event.instructionsText,
            isComplete: progress.isCompleted,
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
