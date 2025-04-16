//
//  OCKOutcomeValue+ResearchKitSwiftUI.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/16/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if canImport(ResearchKitSwiftUI)
import CareKitStore
import os.log
import ResearchKitSwiftUI

extension ResearchKitSwiftUI.Result {

	/// Converts an `ResearchKitSwiftUI.Result` to an array of `OCKOutcomeValue`'s.
	// swiftlint:disable:next cyclomatic_complexity
	public func convertToOCKOutcomeValues() throws -> [OCKOutcomeValue] {

		switch answer {
		case .date(let date):
			guard let date = date else {
				throw CareKitEssentialsError.errorString("Could not unwrap date")
			}

			var outcomeValue = OCKOutcomeValue(
				date
			)
			outcomeValue.kind = identifier
			return [outcomeValue]

		case .text(let text):
			guard let text = text else {
				throw CareKitEssentialsError.errorString("Could not unwrap text")
			}

			var outcomeValue = OCKOutcomeValue(
				text
			)
			outcomeValue.kind = identifier
			return [outcomeValue]

		case .numeric(let numeric):
			guard let numeric = numeric else {
				throw CareKitEssentialsError.errorString("Could not unwrap numeric")
			}

			var outcomeValue = OCKOutcomeValue(
				numeric
			)
			outcomeValue.kind = identifier
			return [outcomeValue]

		case .weight(let weight):
			guard let weight = weight else {
				throw CareKitEssentialsError.errorString("Could not unwrap weight")
			}

			var outcomeValue = OCKOutcomeValue(
				weight
			)
			outcomeValue.kind = identifier
			return [outcomeValue]

		case .height(let height):
			guard let height = height else {
				throw CareKitEssentialsError.errorString("Could not unwrap height")
			}

			var outcomeValue = OCKOutcomeValue(
				height
			)
			outcomeValue.kind = identifier
			return [outcomeValue]

		case .multipleChoice(let choices):
			guard let choices = choices else {
				throw CareKitEssentialsError.errorString("Could not unwrap choices")
			}

			let values = choices.compactMap { choice -> OCKOutcomeValue? in
				switch choice {

				case .int(let valueInteger):
					var outcomeValue = OCKOutcomeValue(
						valueInteger
					)
					outcomeValue.kind = identifier
					return outcomeValue

				case .string(let valueString):
					var outcomeValue = OCKOutcomeValue(
						valueString
					)
					outcomeValue.kind = identifier
					return outcomeValue

				case .date(let valueDate):
					var outcomeValue = OCKOutcomeValue(
						valueDate
					)
					outcomeValue.kind = identifier
					return outcomeValue

				@unknown default:
					Logger.ockOutcomeValueResearchKitResult.error("Unsupported choice type.")
					return nil
				}
			}
			return values

		case .image:
			// let errorMessage = "Image outcomes are not supported yet."
			// Logger.researchCareForm.error("\(errorMessage)")
			throw CareKitEssentialsError.errorString("image is currently not supported")

		case .scale(let scaleValue):
			guard let scaleValue = scaleValue else {
				throw CareKitEssentialsError.errorString("Could not unwrap scaleValue")
			}
			var outcomeValue = OCKOutcomeValue(
				scaleValue
			)
			outcomeValue.kind = identifier
			return [outcomeValue]

		@unknown default:
			throw CareKitEssentialsError.errorString("Reached an unsupported case in convertToOCKOutcomeValue()")
		}
	}
}

extension OCKOutcomeValue {

	/// Converts an `OCKOutcomeValue` to a `ResearchKitSwiftUI.Result`.
	public func convertToResearchKitResult() throws -> ResearchKitSwiftUI.Result {

		guard let identifier = kind else {
			throw CareKitEssentialsError.errorString("Could not get the \"identifier\" from \"kind\"")
		}

		switch type {

		case .integer:
			guard let integerValue else {
				throw CareKitEssentialsError.errorString("Could not unwrap integerValue")
			}
			let answer = AnswerFormat.numeric(Double(integerValue))
			let result = ResearchKitSwiftUI.Result(
				identifier: identifier,
				answer: answer
			)

			return result

		case .double:
			let answer = AnswerFormat.numeric(doubleValue)
			let result = ResearchKitSwiftUI.Result(
				identifier: identifier,
				answer: answer
			)

			return result

		case .boolean:
			guard let booleanValue else {
				throw CareKitEssentialsError.errorString("Could not unwrap booleanValue")
			}
			let doubleBoolean: Double = booleanValue ? 1 : 0
			let answer = AnswerFormat.numeric(doubleBoolean)
			let result = ResearchKitSwiftUI.Result(
				identifier: identifier,
				answer: answer
			)

			return result

		case .text:
			let answer = AnswerFormat.text(stringValue)
			let result = ResearchKitSwiftUI.Result(
				identifier: identifier,
				answer: answer
			)

			return result

		case .binary:
			throw CareKitEssentialsError.errorString("binary is currently not supported")

		case .date:
			let answer = AnswerFormat.date(dateValue)
			let result = ResearchKitSwiftUI.Result(
				identifier: identifier,
				answer: answer
			)

			return result

		}
	}
}

#endif
