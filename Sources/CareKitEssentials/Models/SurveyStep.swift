//
//  SurveyStep.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 3/31/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

public struct SurveyStep: Codable, Hashable, Identifiable {
	public var id: String
	public var questions: [SurveyQuestion]
}
