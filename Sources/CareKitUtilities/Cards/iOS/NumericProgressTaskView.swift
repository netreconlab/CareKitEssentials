//
//  NumericProgressTaskView.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 5/20/23.
//

#if !os(watchOS)

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
        event: CareStoreFetchedResult<OCKAnyEvent>,
        numberFormatter: NumberFormatter? = nil
    ) {

        let currentEvent = event.result

        self.init(event: event,
                  numberFormatter: numberFormatter,
                  header: {
            InformationHeaderView(title: Text(currentEvent.title),
                                  information: currentEvent.detailText,
                                  event: event.result)
        })
    }
}

#endif
