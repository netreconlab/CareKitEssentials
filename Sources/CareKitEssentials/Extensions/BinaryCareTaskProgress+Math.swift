//
//  BinaryCareTaskProgress+Math.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/28/25.
//

import CareKitStore

public extension BinaryCareTaskProgress {

	static func computeProgressByCheckingOutcomeExists(
		for event: OCKAnyEvent,
		kind: String?
	) -> BinaryCareTaskProgress {
		let isCompleted = event.outcome?.values.first(where: { $0.kind == kind }) != nil
		return BinaryCareTaskProgress(isCompleted: isCompleted)
	}
}
