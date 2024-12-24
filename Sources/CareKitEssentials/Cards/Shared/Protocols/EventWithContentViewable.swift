//
//  EventWithContentViewable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import SwiftUI

#if !os(watchOS)

/// Conforming to this protocol ensures your view
/// consists of the proper initializers to view events.
public protocol EventWithContentViewable: View {
    associatedtype Content: View

    /// Create an instance of this view.
    /// - Parameters:
    ///     - event: An individual event that contains properties to should be shown in a view.
    ///     - store: The store in which updates to the respective event should persist.
    ///     - content: Additional content to be shown in the view.
    init?(
        event: OCKAnyEvent,
        store: any OCKAnyStoreProtocol,
        content: @escaping () -> Content
    )
}

#endif
