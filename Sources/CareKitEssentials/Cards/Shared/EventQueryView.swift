//
//  EventQueryView.swift
//  Assuage
//
//  Created by Corey Baker on 12/10/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import SwiftUI

/// A view that wraps any view that is `CareStoreFetchedViewable` and provides
/// it with an update-to-date latest event matching an event query.
/// - note: This view is useful to wrap around SwiftUI views that will be shown in
/// UIKit view controllers.
public struct EventQueryView<CareView: CareStoreFetchedViewable>: View {
    @Environment(\.careStore) private var store
    @CareStoreFetchRequest(query: defaultQuery) var events

    var query: OCKEventQuery

    public var body: some View {
        CareView.init(event: event)
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

    public init(query: OCKEventQuery) {
        self.query = query
    }
}

/*
#Preview {
    EventQueryView()
}
*/
