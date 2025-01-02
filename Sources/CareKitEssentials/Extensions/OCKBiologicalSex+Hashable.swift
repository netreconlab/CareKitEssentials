//
//  OCKBiologicalSex+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 11/7/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKBiologicalSex: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {

        case .male:
            hasher.combine(0)
        case .female:
            hasher.combine(1)
        case .other(let other):
            hasher.combine(other)
        }
    }
}
