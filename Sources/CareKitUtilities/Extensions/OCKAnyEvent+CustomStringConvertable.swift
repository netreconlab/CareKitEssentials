//
//  OCKAnyEvent+CustomStringConvertable.swift
//  OCKSample
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
            let stringTask = String(data: encodedTask, encoding: .utf8),
            let outcome = self.outcome as? OCKOutcome,
            let encodedOutcome = try? JSONEncoder().encode(outcome),
            let stringOutcome = String(data: encodedOutcome, encoding: .utf8) else {
            return ""
        }
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
