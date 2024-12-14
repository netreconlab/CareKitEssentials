//
//  OCKNote+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKNote: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(author)
        hasher.combine(title)
        hasher.combine(content)
    }
}
