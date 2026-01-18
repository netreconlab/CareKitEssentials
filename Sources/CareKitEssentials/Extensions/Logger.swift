//
//  Logger.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 6/24/24.
//

#if canImport(os.log)

import Foundation
import os.log

extension Logger {
	private static let subsystem = Bundle.main.bundleIdentifier!

    static let essentialView = Logger(
		subsystem: subsystem,
		category: "CareKitEssentialView"
	)
    static let essentialChartView = Logger(
		subsystem: subsystem,
		category: "CareKitEssentialChartView"
	)
	static let essentialChartable = Logger(
		subsystem: subsystem,
		category: "CareKitEssentialChartable"
	)
    static let careKitAnyEventStore = Logger(
		subsystem: subsystem,
		category: "CareKitAnyEventStore"
	)
    static let instructionsTaskView = Logger(
		subsystem: subsystem,
		category: "InstructionsTaskView"
	)
    static let simpleTaskView = Logger(
		subsystem: subsystem,
		category: "SimpleTaskView"
	)
	static let researchCareForm = Logger(
		subsystem: subsystem,
		category: "ResearchCareForm"
	)
	static let ockTaskResearchKitSwiftUI = Logger(
		subsystem: subsystem,
		category: "OCKTaskResearchKitSwiftUI"
	)
	static let ockOutcomeValueResearchKitResult = Logger(
		subsystem: subsystem,
		category: "OCKOutcomeValueResearchKitResult"
	)
}

#endif
