//
//  InstructionsTaskView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/20/23.
//

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
    ///   - store: The Care Store changes to this event should be made to.
    ///   - onError: A closure that the struct calls if an error occurs while toggling completion for the event.
    init(
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol,
        onError: @escaping (OCKStoreError) -> Void = { _ in }
    ) {

        let progress = event.computeProgress(by: .checkingOutcomeExists)

        self.init(
            instructions: event.instructionsText,
            isComplete: progress.isCompleted,
            action: {
                Task {
                    do {
                        _ = try await event.toggleBooleanOutcome(store: store)
                    } catch let error as OCKStoreError {
                        onError(error)
                    }
                }
            },
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
