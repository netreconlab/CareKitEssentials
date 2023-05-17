//
//  SliderLogTaskViewModel.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 5/16/23.
//

import CareKitStore
import Foundation
import SwiftUI

public class SliderLogTaskViewModel: CardViewModel {

    /// The binded array of all outcome values.
    @Published public var valuesArray: [Double]

    @Published public var isActive = true

    private(set) var range: ClosedRange<Double>
    private(set) var step: Double

    /**
     - parameter range: The range that includes all possible values.
     - parameter step: Value of the increment that the slider takes. Default value is 1.
     - parameter action: The action to perform when the button is tapped. Defaults to saving the outcome directly.
     */
    init(event: OCKAnyEvent,
         valuesArray: [Double] = [],
         range: ClosedRange<Double>,
         step: Double = 1,
         isActive: Bool = true,
         detailsTitle: String? = nil,
         detailsInformation: String? = nil,
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
