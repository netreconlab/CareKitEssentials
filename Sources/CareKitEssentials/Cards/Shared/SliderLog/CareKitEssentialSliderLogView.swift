//
//  CareKitEssentialSliderLogView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/4/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if !os(watchOS)

import CareKit
import CareKitStore
import CareKitUI
import os.log
import SwiftUI

public typealias SliderLogView = CareKitEssentialSliderLogView

/// A card that displays a header view, multi-line label, a slider, and a completion button.
///
/// In CareKit, this view is intended to display a particular event for a task.
/// The state of the button indicates the completion state of the event.
///
/// # Style
/// The card supports styling using `careKitStyle(_:)`.
///
/// ```
///     +-------------------------------------------------------+
///     |                                                       |
///     |  <Image> <Title>                       <Info Image>   |
///     |  <Information>                                        |
///     |                                                       |
///     |  --------------------------------------------------   |
///     |                                                       |
///     |  <Instructions>                                       |
///     |                                                       |
///     |  <Min Image> –––––––––––––O–––––––––––– <Max Image>   |
///     |             <Min Desc>        <Max Desc>              |
///     |                                                       |
///     |  +-------------------------------------------------+  |
///     |  |                      <Log>                      |  |
///     |  +-------------------------------------------------+  |
///     |                                                       |
///     |                   <Latest Value: >                    |
///     |                                                       |
///     +-------------------------------------------------------+
/// ```
public struct CareKitEssentialSliderLogView: CareKitEssentialView {
	@Environment(\.careStore) public var store

	var event: OCKAnyEvent
	var sliderStyle: SliderStyle
	var range: ClosedRange<Double>
	var kind: String?
	var initialValue: Double?
	var step: Double
	var minimumImage: Image?
	var maximumImage: Image?
	var minimumDescription: String?
	var maximumDescription: String?
	var gradientColors: [Color]?
	var action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)?

	public var body: some View {
		SliderLogTaskView(
			title: Text(event.title),
			detail: event.detailText,
			instructions: event.instructionsText,
			viewModel: .init(
				event: event,
				kind: kind,
				detailsTitle: event.detail,
				detailsInformation: event.instructions,
				initialValue: initialValue,
				range: range,
				step: step,
				action: action ?? defaultAction
			),
			style: sliderStyle,
			gradientColors: gradientColors
		)
	}

	/**
	 Create an instance with specified content for an event.
	 - parameter event: A event to associate with the view model.
	 - parameter kind: The kind of outcome value for the slider. Defaults to nil.
	 - parameter initialValue: The initial value shown on the slider.
	 - parameter range: The range that includes all possible values.
	 - parameter step: Value to increment the slider by. Default value is 1.
	 - parameter style: The style of the slider, either the SwiftUI system slider or
	 the custom bar slider.
	 - parameter minimumImage: Image to display to the left of the slider. Default
	 value is nil.
	 - parameter maximumImage: Image to display to the right of the slider. Default
	 value is nil.
	 - parameter minimumDescription: Description to display next to lower bound
	 value. Default value is nil.
	 - parameter maximumDescription: Description to display next to upper
	 bound value. Default value is nil.
	 - parameter gradientColors: The colors to use when drawing a color
	 gradient inside the slider. Colors are drawn such that lower indexes correspond to the
	 minimum side of the scale, while colors at higher indexes in the array correspond to
	 the maximum side of the scale. Setting this value to nil results in no gradient being
	 drawn. Defaults to nil. An example usage would set an array of red and green to
	 visually indicate a scale from bad to good.
	 - parameter action: The action to perform when the button is tapped. Defaults to saving the outcome directly.
	 */
	public init(
		event: OCKAnyEvent,
		kind: String? = nil,
		range: ClosedRange<Double> = 0...10,
		initialValue: Double? = nil,
		step: Double = 1,
		style: SliderStyle = .system,
		minimumImage: Image? = nil,
		maximumImage: Image? = nil,
		minimumDescription: String? = nil,
		maximumDescription: String? = nil,
		gradientColors: [Color]? = nil,
		action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil
	) {
		self.event = event
		self.sliderStyle = style
		self.range = range
		self.kind = kind
		self.initialValue = initialValue
		self.step = step
		self.minimumImage = minimumImage
		self.maximumImage = maximumImage
		self.minimumDescription = minimumDescription
		self.maximumDescription = maximumDescription
		self.gradientColors = gradientColors
		self.action = action
	}

	func defaultAction(
		_ value: OCKOutcomeValue?
	) async throws -> OCKAnyOutcome {
		guard let value else {
			// Delete outcome values
			let updatedOutcome = try await updateEvent(
				event,
				with: nil
			)
			return updatedOutcome
		}

		let updatedOutcome = try await updateEvent(
			event,
			with: [value]
		)
		return updatedOutcome
	}
}

struct CareKitEssentialSliderLogView_Previews: PreviewProvider {
	static var store = Utility.createPreviewStore()
	static var query: OCKEventQuery {
		var query = OCKEventQuery(for: Date())
		query.taskIDs = [TaskID.nausea]
		return query
	}

	static var previews: some View {
		ScrollView {
			VStack {
				if let event = try? Utility.createNauseaEvent() {
					SliderLogView(
						event: event,
						initialValue: 1,
						style: .ticked,
						gradientColors: [.green, .yellow, .red]
					)
					Divider()
					SliderLogView(
						event: event,
						style: .system,
						gradientColors: [.green, .yellow, .red]
					)
				}
			}
			.padding()
		}
		.environment(\.careStore, store)
		.accentColor(.pink)
		.padding()
	}
}

#endif
