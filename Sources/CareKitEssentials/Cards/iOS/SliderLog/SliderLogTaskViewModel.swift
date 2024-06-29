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

    /**
     Create an instance with specified content for an event. The view will update when changes
     occur in the store.

     - parameter event: A event to associate with the view model.
     - parameter value: The default outcome value for the view model. Defaults to 0.0.
     - parameter detailsTitle: An optional title for the event.
     - parameter detailsInformation: An optional detailed information string for the event.
     - parameter initialValue: The initial value shown on the slider.
     - parameter range: The range that includes all possible values.
     - parameter step: Value of the increment that the slider takes. Default value is 1.
     - parameter action: The action to perform when the button is tapped. Defaults to saving the outcome directly.
     */
    public init(event: OCKAnyEvent,
                detailsTitle: String? = nil,
                detailsInformation: String? = nil,
                initialValue: Double? = 0,
                range: ClosedRange<Double>,
                step: Double = 1,
                action: ((OCKOutcomeValue?) async -> Void)? = nil) {
        if let values = event.outcomeValues {
            self.previousValues = values.compactMap { $0.doubleValue }
        }
        self.range = range
        self.step = step
        var currentInitialValue = range.lowerBound + round((range.upperBound - range.lowerBound) / (step * 2)) * step
        if let initialValue = initialValue {
            currentInitialValue = initialValue
        }
        super.init(event: event,
                   initialValue: OCKOutcomeValue(currentInitialValue),
                   detailsTitle: detailsTitle,
                   detailsInformation: detailsInformation,
                   action: action
        )
    }

}
