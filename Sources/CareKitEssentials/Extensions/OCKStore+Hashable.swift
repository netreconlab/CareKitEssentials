//
//  OCKStore+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKStore: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(securityApplicationGroupIdentifier)
    }
}

extension OCKCoreDataStoreType: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {

        case .inMemory:
            hasher.combine(0)
        case .onDisk(let protection):
            hasher.combine(protection)
        }
    }
}
