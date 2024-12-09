//
//  SliderLogTaskViewModel.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/16/23.
//

import CareKitStore
import Foundation
import SwiftUI

/**
 A view model for Sliders that can be subclassed to build more intricate view models
 for CarseKit style cards.
 */
open class SliderLogTaskViewModel: CardViewModel {

    /// The binded array of previous outcome values.
    @Published public var previousValues = [Double]()

    /// Specifies if the slider is allowed to be changed.
    @Published open var isActive = true

    /// The range that includes all possible values.
    public private(set) var range: ClosedRange<Double>

    /// Value of the increment that the slider takes. Default value is 1.
    public private(set) var step: Double

    var kind: String?

    /**
     Create an instance with specified content for an event. The view will update when changes
     occur in the store.

     - parameter event: A event to associate with the view model.
     - parameter kind: The kind of outcome value for the slider. Defaults to nil.
     - parameter value: The default outcome value for the view model. Defaults to 0.0.
     - parameter detailsTitle: An optional title for the event.
     - parameter detailsInformation: An optional detailed information string for the event.
     - parameter initialValue: The initial value shown on the slider.
     - parameter range: The range that includes all possible values.
     - parameter step: Value of the increment that the slider takes. Default value is 1.
     - parameter action: The action to perform when the button is tapped. Defaults to saving the outcome directly.
     */
    public init(
        event: OCKAnyEvent,
        kind: String? = nil,
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        initialValue: Double? = nil,
        range: ClosedRange<Double>,
        step: Double = 1,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil
    ) {
        self.kind = kind
        let outcomeValues = Self.filterAndSortValuesByLatest(event.outcomeValues, by: kind)
        if let values = outcomeValues {
            self.previousValues = values.compactMap { $0.doubleValue }
        }
        self.range = range
        self.step = step
        var currentInitialDoubleValue = range.lowerBound
            + round((range.upperBound - range.lowerBound) / (step * 2)) * step
        if let initialValue = initialValue {
            currentInitialDoubleValue = initialValue
        }
        var currentInitialOutcome = OCKOutcomeValue(currentInitialDoubleValue)
        if let latestOutcomeValue = outcomeValues?.first,
           let initialOutcomeDouble = latestOutcomeValue.doubleValue {
            if initialOutcomeDouble != currentInitialDoubleValue {
                isActive = false
                currentInitialOutcome = latestOutcomeValue
            }
        }
        super.init(
            event: event,
            initialValue: currentInitialOutcome,
            detailsTitle: detailsTitle,
            detailsInformation: detailsInformation,
            action: action
        )
    }

    static func filterAndSortValuesByLatest(
        _ values: [OCKOutcomeValue]?,
        by kind: String?
    ) -> [OCKOutcomeValue]? {
        values?.filter { outcomeValue in
            guard let kind else { return true }
            return outcomeValue.kind == kind
        }.sorted { $0.createdDate > $1.createdDate }
    }

    public override func updateOutcome(_ outcome: OCKAnyOutcome) {
        super.updateOutcome(outcome)
        let values = outcome.sortedOutcomeValuesByRecency().values
        if let previousValues = Self.filterAndSortValuesByLatest(values, by: kind) {
            self.previousValues = previousValues.compactMap(\.doubleValue)
        }
        self.isActive = false
    }
}
