//
//  OCKHealthKitOutcome+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/1/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import Foundation

extension OCKHealthKitOutcome: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(taskUUID)
		hasher.combine(isOwnedByApp)
		hasher.combine(taskOccurrenceIndex)
		hasher.combine(values)
		hasher.combine(remoteID)
		hasher.combine(groupIdentifier)
		hasher.combine(notes)
	}
}
