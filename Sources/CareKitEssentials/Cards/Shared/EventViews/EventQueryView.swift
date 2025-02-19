//
//  EventQueryView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/10/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import SwiftUI

#if !os(watchOS)

/// A view that wraps any view that is `EventViewable` and provides
/// the respective view with an up-to-date latest event matching the
/// specified event query.
/// - note: This view is useful to wrap around SwiftUI views that will be shown in
/// UIKit view controllers.
/// - important: This view requires `OCKAnyEvent` to conform to `Hashable`
/// and `Equatable` to update view properly.
public struct EventQueryView<CareView: EventViewable>: View {
    @Environment(\.careStore) private var store
    @CareStoreFetchRequest(query: defaultQuery) var events

    var query: OCKEventQuery

    public var body: some View {
        CareView(
            event: event,
            store: store
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

    private var event: OCKAnyEvent {
        guard let latestEvent = events.latest.last?.result else {
            // Create empty result to be fill space in UIKit
            let taskID = query.taskIDs.first ?? "No taskID supplied in query"
            let emptyEvent = OCKAnyEvent.createDummyEvent(
                withTaskID: "Task id \"\(taskID)\" not found"
            )
            return emptyEvent
        }
        return latestEvent
    }

    /// Create an instance of this view.
    /// - Parameters:
    ///     - query: A query that limits which events will be returned when fetching.
    public init(query: OCKEventQuery) {
        self.query = query
    }
}

struct EventQueryView_Previews: PreviewProvider {
    static var previews: some View {
        var query: OCKEventQuery {
            var query = OCKEventQuery(for: Date())
            query.taskIDs = [TaskID.doxylamine]

            return query
        }

        VStack {
            EventQueryView<SimpleTaskView>(
                query: query
            )
            Divider()
            EventQueryView<InstructionsTaskView>(
                query: query
            )
            Divider()
            EventQueryView<LabeledValueTaskView>(
                query: query
            )
            Divider()
            EventQueryView<NumericProgressTaskView>(
                query: query
            )
        }
        .environment(\.careStore, Utility.createPreviewStore())
        .accentColor(.red)
        .careKitStyle(OCKStyle())
        .padding()
    }
}

#endif
