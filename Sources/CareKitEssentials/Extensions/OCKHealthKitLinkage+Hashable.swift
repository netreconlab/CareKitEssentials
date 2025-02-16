//
//  OCKHealthKitLinkage+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 2/16/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKHealthKitLinkage: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(quantityIdentifier)
        hasher.combine(quantityType)
        hasher.combine(unit)
    }
}
