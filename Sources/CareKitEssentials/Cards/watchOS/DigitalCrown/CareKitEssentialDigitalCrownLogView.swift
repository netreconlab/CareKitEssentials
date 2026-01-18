//
//  CareKitEssentialDigitalCrownLogView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/4/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if canImport(SwiftUI) && os(watchOS)

import CareKit
import CareKitStore
import CareKitUI
import os.log
import SwiftUI

public typealias DigitalCrownLogView = CareKitEssentialDigitalCrownLogView

/// A card that displays a header view, multi-line label, a digital crown modifier, and a
/// completion button.
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
public struct CareKitEssentialDigitalCrownLogView: CareKitEssentialView {
	@Environment(\.careStore) public var store

	var event: OCKAnyEvent
	var kind: String?
	var initialValue: Double?
	var startValue: Double
	var endValue: Double?
	var step: Double
	var emojis: [String]
	var colorRatio: Double
	var action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)?

	public var body: some View {
		DigitalCrownView(
			event: event,
			kind: kind,
			detailsTitle: event.title,
			detailsInformation: event.detail,
			initialValue: initialValue,
			startValue: startValue,
			endValue: endValue,
			incrementValue: step,
			emojis: emojis,
			colorRatio: colorRatio,
			action: action ?? defaultAction
		)
	}

	/**
	 Create an instance with specified content for an event.
	 - parameter event: A event to associate with the view model.
	 - parameter kind: The kind of outcome value for the slider. Defaults to nil.
	 - parameter initialValue: The initial value shown for the digital crown.
	 - parameter startValue: The minimum possible value.
	 - parameter endValue: The maximum possible value.
	 - parameter step: Value to increment by when moving the digital crown. Default value is 1.
	 - parameter emojis: An array of emoji's to show on the screen.
	 - parameter colorRatio: The ratio effect on the color gradient.
	 - parameter action: The action to perform when the button is tapped. Defaults to saving the outcome directly.
	 */
	public init(
		event: OCKAnyEvent,
		kind: String? = nil,
		initialValue: Double? = nil,
		startValue: Double = 0,
		endValue: Double? = nil,
		step: Double = 1,
		emojis: [String] = [],
		colorRatio: Double = 0.2,
		gradientColors: [Color]? = nil,
		action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil
	) {
		self.event = event
		self.kind = kind
		self.initialValue = initialValue
		self.startValue = startValue
		self.endValue = endValue
		self.step = step
		self.emojis = emojis
		self.colorRatio = colorRatio
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

struct CareKitEssentialDigitalCrownView_Previews: PreviewProvider {
	static var store = Utility.createPreviewStore()
	static let emojis = ["😄", "🙂", "😐", "😕", "😟", "☹️", "😞", "😓", "😥", "😰", "🤯"]

	static var previews: some View {
		VStack {
			if let event = try? Utility.createNauseaEvent() {
				DigitalCrownLogView(
					event: event,
					emojis: emojis,
					gradientColors: [.green, .yellow, .red]
				)
			}
		}
		.environment(\.careStore, store)
		.accentColor(.pink)
		.padding()
	}
}

#endif
