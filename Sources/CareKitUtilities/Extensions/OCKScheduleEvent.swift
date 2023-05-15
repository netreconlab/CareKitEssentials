//
//  OCKScheduleEvent.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 5/15/23.
//


import CareKitStore

extension OCKScheduleEvent: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.start < rhs.start {
            return true
        } else if lhs.start > rhs.start {
            return false
        } else if lhs.end < rhs.end {
            return true
        } else {
            return false
        }
    }
}
