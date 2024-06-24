//
//  OCKAnyEvent+CustomStringConvertable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

extension OCKAnyEvent: CustomStringConvertible {

    public var description: String {
        guard let task = self.task as? OCKTask,
            let encodedTask = try? JSONEncoder().encode(task),
            let outcome = self.outcome as? OCKOutcome,
            let encodedOutcome = try? JSONEncoder().encode(outcome) else {
            return ""
        }
        let stringTask = String(decoding: encodedTask, as: UTF8.self)
        let stringOutcome = String(decoding: encodedOutcome, as: UTF8.self)
        return stringTask + stringOutcome
    }
}

extension OCKAnyEvent: Comparable {
    public static func == (lhs: OCKAnyEvent, rhs: OCKAnyEvent) -> Bool {
        lhs.id == rhs.id
    }

    public static func < (lhs: OCKAnyEvent, rhs: OCKAnyEvent) -> Bool {
        lhs.scheduleEvent.start <= rhs.scheduleEvent.start &&
        lhs.scheduleEvent.end < rhs.scheduleEvent.end
    }
}
