//
//  OCKHealthKitTask+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 2/16/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

extension OCKHealthKitTask: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(uuid)
        hasher.combine(carePlanUUID)
        hasher.combine(healthKitLinkage)
        hasher.combine(title)
        hasher.combine(instructions)
        hasher.combine(impactsAdherence)
        hasher.combine(schedule)
        hasher.combine(groupIdentifier)
        hasher.combine(tags)
        hasher.combine(effectiveDate)
        hasher.combine(deletedDate)
        hasher.combine(nextVersionUUIDs)
        hasher.combine(previousVersionUUIDs)
        hasher.combine(createdDate)
        hasher.combine(updatedDate)
        hasher.combine(schemaVersion)
        hasher.combine(remoteID)
        hasher.combine(source)
        hasher.combine(userInfo)
        hasher.combine(asset)
        hasher.combine(notes)
        hasher.combine(timezone)
    }
}
