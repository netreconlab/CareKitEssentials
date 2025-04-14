//
//  SurveyStep.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 3/31/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if canImport(ResearchKitSwiftUI)
import Foundation
import SwiftUI

public struct SurveyStep: Codable, Hashable, Identifiable {
	/// The id of the step.
	public var id: String
	/// The list of questions that represent this step.
	public var questions: [SurveyQuestion]
	/// The asset displayed in the header.
	public var asset: String?
	/// The title displayed in the header.
	public var title: String?
	/// The subtitle displayed in the header.
	public var subtitle: String?
	/// The image displayed in the header.
	public var image: Image? {
		Image.asset(asset)
	}

	/// Creates an instance.
	public init(
		id: String,
		questions: [SurveyQuestion],
		asset: String? = nil,
		title: String? = nil,
		subtitle: String? = nil
	) {
		self.id = id
		self.questions = questions
		self.asset = asset
		self.title = title
		self.subtitle = subtitle
	}
}

#endif
