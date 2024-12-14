//
//  OCKAnyEvent+Comparable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKAnyEvent: @retroactive Comparable {

    public static func < (lhs: OCKAnyEvent, rhs: OCKAnyEvent) -> Bool {
        lhs.scheduleEvent.start <= rhs.scheduleEvent.start &&
        lhs.scheduleEvent.end < rhs.scheduleEvent.end
    }

}
