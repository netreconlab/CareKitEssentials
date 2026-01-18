//
//  EventQueryContentView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/10/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

#if canImport(SwiftUI) && !os(watchOS)

import SwiftUI
import CareKit
import CareKitStore
import CareKitUI

/// A view that wraps any view that is `EventWithContentViewable` and provides
/// the respective view with an up-to-date latest event matching the
/// specified event query.
/// - note: This view is useful to wrap around SwiftUI views that will be shown in
/// UIKit view controllers.
/// - important: This view requires `OCKAnyEvent` to conform to `Hashable`
/// and `Equatable` to update view properly.
public struct EventQueryContentView<CareView: EventWithContentViewable>: View {
    @Environment(\.careStore) private var store
    @CareStoreFetchRequest(query: defaultQuery) var events

    var query: OCKEventQuery
    @ViewBuilder let content: () -> CareView.Content

    public var body: some View {
        CareView(
            event: event.result,
            store: store,
            content: content
        )
        .onAppear {
            events.query = query
        }
    }

    private static var defaultQuery: OCKEventQuery {
        var query = OCKEventQuery(for: Date())
        query.taskIDs = [""]
        return query
    }

    private var event: CareStoreFetchedResult<OCKAnyEvent> {
        guard let latestEvent = events.latest.last else {
            // Create empty result to be fill space in UIKit
            let taskID = query.taskIDs.first ?? "No taskID supplied in query"
            let emptyEvent = OCKAnyEvent.createDummyEvent(
                withTaskID: "Task id \"\(taskID)\" not found"
            )
            let emptyResult = CareStoreFetchedResult<OCKAnyEvent>(
                id: UUID().uuidString,
                result: emptyEvent,
                store: store
            )
            return emptyResult
        }
        return latestEvent
    }

    /// Create an instance of this view.
    /// - Parameters:
    ///     - query: A query that limits which events will be returned when fetching.
    ///     - content: Additonal view content to be displayed.
    public init(
        query: OCKEventQuery,
        content: @escaping () -> CareView.Content
    ) {
        self.query = query
        self.content = content
    }
}

#endif
