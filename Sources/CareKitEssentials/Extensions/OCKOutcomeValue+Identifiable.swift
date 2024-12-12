//
//  OCKOutcomeValue+Identifiable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

extension OCKOutcomeValue: Identifiable {
    public var id: String {
        if let kind = kind {
            return "\(kind)_\(value)_\(createdDate)"
        } else {
            return "\(value)_\(createdDate)"
        }
    }
}

/*
extension OCKScheduleEvent: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(end)
        hasher.combine(element)
        hasher.combine(occurrence)
    }
}
*/
