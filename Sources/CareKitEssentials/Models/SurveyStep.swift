//
//  SurveyStep.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 3/31/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if canImport(ResearchKitSwiftUI)

public struct SurveyStep: Codable, Hashable, Identifiable {
	/// The id of the step.
	public var id: String
	/// The list of questions that represent this step.
	public var questions: [SurveyQuestion]

	/// Creates an instance.
	public init(
		id: String,
		questions: [SurveyQuestion]
	) {
		self.id = id
		self.questions = questions
	}
}

#endif
