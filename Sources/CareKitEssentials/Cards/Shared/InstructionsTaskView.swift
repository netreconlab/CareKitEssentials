//
//  InstructionsTaskView.swift
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

public extension InstructionsTaskView where Header == InformationHeaderView {

    /// Create a view using data from an event.
    ///
    /// This view displays task instructions and a button to toggle completion for
    /// the event.
    ///
    /// - Parameters:
    ///   - event: The data displayed in the view.
    ///   - onError: A closure that the struct calls if an error occurs while toggling completion for the event.
    init(
        event: CareStoreFetchedResult<OCKAnyEvent>,
        onError: @escaping (OCKStoreError) -> Void = { _ in }
    ) {

        let currentEvent = event.result

        self.init(event: event,
                  header: {
            InformationHeaderView(title: Text(currentEvent.title),
                                  information: currentEvent.detailText,
                                  event: event.result)
        },
                  onError: onError)
    }
}

#endif
