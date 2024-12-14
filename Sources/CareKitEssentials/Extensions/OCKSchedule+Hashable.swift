//
//  OCKSchedule+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKSchedule: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }
}
