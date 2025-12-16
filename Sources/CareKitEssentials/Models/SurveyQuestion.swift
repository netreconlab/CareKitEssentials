//
//  SurveyQuestion.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 3/31/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if canImport(ResearchKitSwiftUI)
import ResearchKitSwiftUI

import SwiftUI

/// A ResearchKitSwiftUI survey question.
public struct SurveyQuestion: Codable, Hashable, Identifiable {
	/// The unique identifier for this
	public var id: String
	/// The survey type for this
	public var type: QuestionType
	/// Specify if the question is required to be completed.
	public var required: Bool = false
	/// The title for this
	public var title: String
	/// The details for this
	public var detail: String?
	/// Max characters that can be entered.
	public var characterLimit: Int?
	/// A set of ResearchKitSwiftUI text choices.
	public var textChoices: [TextChoice]?
	// public var imageChoices: [ImageChoice]?
	/// Whether or not the images should be displayed horizontally or vertically in a `ImageChoiceQuestion`.
	public var vertical: Bool?
	/// A ResearchKitSwiftUI number of of choices that can be selected.
	public var choiceSelectionLimit: ChoiceSelectionLimit?
	/// A ResearchKitSwiftUI placeholder for a survey
	public var prompt: String?
	/// A ResearchKitSwiftUI `SliderQuestion` integer range.
	public var integerRange: ClosedRange<Int>?
	/// A ResearchKitSwiftUI `SliderQuestion` double range.
	public var doubleRange: ClosedRange<Double>?
	/// A ResearchKitSwiftUI `SliderQuestion` step value.
	public var sliderStepValue: Double?
	/// A ResearchKitSwiftUI `DateTimeQuestion` date range.
	public var dateRange: ClosedRange<Date>?
	/// A ResearchKitSwiftUI `DateTimeQuestion` default date.
	public var defaultDate: Date?
	/// The measurement system for this
	public var measurementSystem: MeasurementSystem?
	/// The selected value for `SliderQuestion`.
	public var selection: Int?
	/// The default value for a `WeightQuestion`.
	public var defaultValue: Double?
	/// The minimum value for a `WeightQuestion`.
	public var minimumValue: Double?
	/// The maximum value for a `WeightQuestion`.
	public var maximumValue: Double?

	/// The specific question type.
	public enum QuestionType: String, Codable, CaseIterable {
		case multipleChoice = "Multiple Choice"

		case height = "Height"

		case weight = "Weight"

		case slider = "Slider"

		case text = "Text"

		case dateTime = "Date Time"

		case numericQuestion = "Numeric"

		case imageChoice = "Image Choice"
	}

	/// Creates an instance of a survey question.
	public init(
		id: String,
		type: QuestionType,
		required: Bool = false,
		title: String,
		detail: String? = nil,
		characterLimit: Int? = nil,
		textChoices: [TextChoice]? = nil,
		vertical: Bool? = nil,
		choiceSelectionLimit: ChoiceSelectionLimit? = nil,
		prompt: String? = nil,
		integerRange: ClosedRange<Int>? = nil,
		doubleRange: ClosedRange<Double>? = nil,
		sliderStepValue: Double? = nil,
		dateRange: ClosedRange<Date>? = nil,
		defaultDate: Date? = nil,
		measurementSystem: MeasurementSystem? = nil,
		selection: Int? = nil,
		defaultValue: Double? = nil,
		minimumValue: Double? = nil,
		maximumValue: Double? = nil
	) {
		self.id = id
		self.type = type
		self.required = required
		self.title = title
		self.detail = detail
		self.characterLimit = characterLimit
		self.textChoices = textChoices
		self.vertical = vertical
		self.choiceSelectionLimit = choiceSelectionLimit
		self.prompt = prompt
		self.integerRange = integerRange
		self.doubleRange = doubleRange
		self.sliderStepValue = sliderStepValue
		self.dateRange = dateRange
		self.defaultDate = defaultDate
		self.measurementSystem = measurementSystem
		self.selection = selection
		self.defaultValue = defaultValue
		self.minimumValue = minimumValue
		self.maximumValue = maximumValue
	}

	// MARK: ResearchKit (Swift UI)

	/// Builds the respective SwiftUI ResearchKitSwiftUI question view.
	@MainActor @ViewBuilder public func view() -> some View {
		switch type {
		case .multipleChoice:
			MultipleChoiceQuestion(
				id: id,
				title: title,
				detail: detail,
				choices: textChoices ?? [],
				choiceSelectionLimit: choiceSelectionLimit ?? .single
			)
			.questionRequired(required)
		case .height:
			HeightQuestion(
				id: id,
				title: title,
				detail: detail,
				measurementSystem: measurementSystem ?? .USC
			)
			.questionRequired(required)
		case .weight:
			WeightQuestion(
				id: id,
				title: title,
				measurementSystem: measurementSystem ?? .USC,
				defaultValue: defaultValue,
				minimumValue: minimumValue,
				maximumValue: maximumValue
			)
			.questionRequired(required)
		case .slider:
			SliderQuestion(
				id: id,
				title: title,
				detail: detail,
				range: integerRange ?? .init(uncheckedBounds: (lower: 0, upper: 1)),
				step: sliderStepValue ?? 1,
				selection: selection
			)
			.questionRequired(required)
		case .text:
			TextQuestion(
				id: id,
				header: {
					Text(title)
						.padding()
					if let detail = detail {
						Text(detail)
							.padding()
					}
				},
				prompt: prompt,
				lineLimit: .multiline,
				characterLimit: characterLimit ?? 2_000
			)
			.questionRequired(required)
		case .dateTime:
			DateTimeQuestion(
				id: id,
				title: title,
				detail: detail,
				date: defaultDate ?? Date(),
				pickerPrompt: prompt ?? String(localized: "CHOOSE_DATE_TIME"),
				displayedComponents: [.date, .hourAndMinute],
				range: dateRange ?? .init(uncheckedBounds: (lower: Date()-1, upper: Date()))
			)
			.questionRequired(required)
		case .numericQuestion:
			#if !os(watchOS)
			NumericQuestion(
				id: id,
				title: title,
				prompt: prompt
			)
			.questionRequired(required)
			#else
			// Currently not supported by ResearchKitSwiftUI on the watch.
			EmptyView()
			#endif
		case .imageChoice:
			ImageChoiceQuestion(
				id: id,
				title: title,
				detail: detail,
				choices: [],
				choiceSelectionLimit: choiceSelectionLimit ?? .single,
				vertical: vertical ?? true
			)
			.questionRequired(required)
		}
	}
}

#endif
