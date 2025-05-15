//
//  OCKAnyEvent+Comparable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKAnyEvent: Comparable {

	func isOrderedBefore(other: OCKAnyEvent) -> Bool {

		if scheduleEvent.start != other.scheduleEvent.start {
			return scheduleEvent.start < other.scheduleEvent.start
		}

		if task.uuid != other.task.uuid {
			return task.uuid.uuidString < other.task.uuid.uuidString
		}

		// At this point, the two events belong to the same task version and occur at the same time. Sort by occurrence
		// which should be guaranteed to be increasing between two events for the same task version.

		if scheduleEvent.occurrence == other.scheduleEvent.occurrence {
			assertionFailure("Unexpectedly found two events for the same task version with equal occurrences")
		}

		return scheduleEvent.occurrence < other.scheduleEvent.occurrence
	}

	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.isOrderedBefore(other: rhs)
	}
}
