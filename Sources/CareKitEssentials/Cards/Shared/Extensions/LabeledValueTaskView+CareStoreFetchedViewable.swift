//
//  LabeledValueTaskView+CareStoreFetchedViewable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/10/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

#if !os(watchOS)

import CareKit
import CareKitStore
import CareKitUI

extension LabeledValueTaskView: EventViewable where Header == InformationHeaderView {
    public init?(
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol
    ) {
        self.init(
            event: event,
            numberFormatter: nil
        )
    }
}

#endif
