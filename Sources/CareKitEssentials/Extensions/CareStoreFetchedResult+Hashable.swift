//
//  CareStoreFetchedResult+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import Foundation

extension CareStoreFetchedResult: @retroactive Hashable where Result: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(result)
        if let store = store as? OCKStore {
            hasher.combine(store)
        }
        // For most cases, store changes won't be captured
        // because the Store protocols in CareKit aren't
        // Hashable. The above relies on id and result
        // changes.
    }
}
