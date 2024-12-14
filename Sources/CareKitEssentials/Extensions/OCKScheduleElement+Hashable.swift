//
//  OCKScheduleElement+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

extension OCKScheduleElement: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(duration)
        hasher.combine(start)
        hasher.combine(end)
        hasher.combine(interval)
        hasher.combine(targetValues)
    }
}

extension OCKScheduleElement.Duration: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .seconds(let seconds):
            hasher.combine(seconds)
        case .allDay:
            hasher.combine(0)
        }
    }
}
