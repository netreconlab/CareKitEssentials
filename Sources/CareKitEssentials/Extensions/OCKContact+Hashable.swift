//
//  OCKContact+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/1/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

extension OCKLabeledValue: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(label)
		hasher.combine(value)
	}
}

extension OCKContact: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(name)
		hasher.combine(address)
		hasher.combine(emailAddresses)
		hasher.combine(messagingNumbers)
		hasher.combine(phoneNumbers)
		hasher.combine(otherContactInfo)
		hasher.combine(organization)
		hasher.combine(title)
		hasher.combine(role)
		hasher.combine(category)
		hasher.combine(effectiveDate)
		hasher.combine(deletedDate)
		hasher.combine(uuid)
		hasher.combine(nextVersionUUIDs)
		hasher.combine(previousVersionUUIDs)
		hasher.combine(createdDate)
		hasher.combine(updatedDate)
		hasher.combine(schemaVersion)
		hasher.combine(groupIdentifier)
		hasher.combine(tags)
		hasher.combine(remoteID)
		hasher.combine(source)
		hasher.combine(userInfo)
		hasher.combine(asset)
		hasher.combine(notes)
		hasher.combine(timezone)
	}
}
