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
    
    /// Current value displayed on the Slider.
    @Published public var valueAsDouble: Double = 0 {
        didSet {
            value = OCKOutcomeValue(valueAsDouble)
        }
    }
    
    /// Data used to create a `CareKitUI.SliderTaskTaskView`
    @Published public var valuesArray: [Double]
    
    @Published public var isActive = true
    
    public var range: ClosedRange<Double>
    
    init(event: OCKAnyEvent,
         value: OCKOutcomeValue = OCKOutcomeValue(0.0),
         valuesArray: [Double] = [],
         range: ClosedRange<Double>,
         isActive: Bool,
         detailsTitle: String? = nil,
         detailsInformation: String? = nil,
         action: ((OCKOutcomeValue?) async -> Void)?) {
        super.init(event: event)
        self.value = value
        self.detailsTitle = detailsTitle
        self.detailsInformation = detailsInformation
        if let action = action {
            self.action = action
        }
        self.valuesArray = valuesArray
        self.range = range
        self.isActive = isActive
    }
}
