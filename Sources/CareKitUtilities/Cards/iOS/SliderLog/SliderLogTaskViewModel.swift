//
//  SliderLogTaskViewModel.swift
//  CareKitUtilities
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
public class SliderLogTaskViewModel: CardViewModel {

    /// The binded array of all outcome values.
    @Published public var valuesArray: [Double]

    /// Specifies if the slider is allowed to be changed.
    @Published public var isActive = true

    /// The range that includes all possible values.
    private(set) var range: ClosedRange<Double>

    /// Value of the increment that the slider takes. Default value is 1.
    private(set) var step: Double

    /**
     Create an instance with specified content for an event. The view will update when changes
     occur in the store.

     - parameter event: A event to associate with the view model.
     - parameter value: The default outcome value for the view model. Defaults to 0.0.
     - parameter detailsTitle: An optional title for the event.
     - parameter detailsInformation: An optional detailed information string for the event.
     - parameter range: The range that includes all possible values.
     - parameter step: Value of the increment that the slider takes. Default value is 1.
     - parameter isActive: Specifies if the slider is allowed to be changed.
     - parameter action: The action to perform when the button is tapped. Defaults to saving the outcome directly.
     */
    init(event: OCKAnyEvent,
         detailsTitle: String? = nil,
         detailsInformation: String? = nil,
         range: ClosedRange<Double>,
         valuesArray: [Double] = [],
         step: Double = 1,
         isActive: Bool = true,
         action: ((OCKOutcomeValue?) async -> Void)? = nil) {
        let initialValue = range.lowerBound + round((range.upperBound - range.lowerBound) / (step * 2)) * step
        self.valuesArray = valuesArray
        self.range = range
        self.step = step
        self.isActive = isActive
        super.init(event: event,
                   value: OCKOutcomeValue(initialValue),
                   detailsTitle: detailsTitle,
                   detailsInformation: detailsInformation,
                   action: action)
    }

}
