//
//  SimpleTaskView+CareStoreFetchedViewable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/23/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import Foundation
import SwiftUI
import os.log

#if !os(watchOS)

extension SimpleTaskView: EventViewable where Header == InformationHeaderView {
    public init?(
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol
    ) {
        self.init(
            event: event,
            store: store,
            onError: { error in
                Logger.simpleTaskView.error("\(error)")
            }
        )
    }
}

#endif
