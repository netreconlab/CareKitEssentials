//
//  OCKOutcomeValue+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/11/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKOutcomeValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
        hasher.combine(units)
        hasher.combine(createdDate)
        hasher.combine(dateInterval)
        hasher.combine(sourceRevision)
        hasher.combine(device)
        hasher.combine(metadata)

        switch type {

        case .integer:
            hasher.combine(integerValue)
        case .double:
            hasher.combine(doubleValue)
        case .boolean:
            hasher.combine(booleanValue)
        case .text:
            hasher.combine(stringValue)
        case .binary:
            hasher.combine(dataValue)
        case .date:
            hasher.combine(dateValue)
        }
    }
}
