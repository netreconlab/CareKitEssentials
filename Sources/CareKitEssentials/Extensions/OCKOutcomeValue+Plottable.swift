//
//  OCKOutcomeValue+Plottable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/1/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import Charts

extension OCKOutcomeValue: @retroactive Plottable {
	public var primitivePlottable: Double {
		LinearCareTaskProgress.accumulableDoubleValue(for: self)
	}

	public init?(primitivePlottable: Double) {
		self.init(primitivePlottable)
	}
}
