//
//  DigitalCrownViewModel.swift
//  CareKitEssentials
//
//  Created by Julia Stekardis on 10/17/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import Combine
import Foundation
import os.log
import SwiftUI

open class DigitalCrownViewModel: CardViewModel {

    open func getStoplightColor(for value: Double) -> Color {
        var red: Double
        var green: Double
        var blue: Double

        switch value {
        case 0...(self.endValue / 2):
            red = value * self.colorRatio
            green = 1
            blue = 0
        default:
            red = 1
            green = abs(value - self.endValue) * self.colorRatio
            blue = 0
        }
        return Color(red: red, green: green, blue: blue)
    }

    /// Determines when the slider is disabled.
    open var isButtonDisabled: Bool {
        guard let currentDouble = value.doubleValue,
              let originalDouble = event.outcomeValueDouble else {
            return false
        }
        return Int(currentDouble) == Int(originalDouble)
    }

    open var valueForButton: String {
        "\(Int(valueAsDouble))"
    }

    public private(set) var emojis = [String]()
    public private(set) var startValue: Double
    public private(set) var endValue: Double
    public private(set) var incrementValue: Double
    public private(set) var colorRatio: Double

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - event: A event to associate with the view model.
    ///     - kind: An optional property that can be used to specify what kind of values the
    ///   outcome values are (e.g. blood pressure, qualitative stress, weight).
    ///     - detailsTitle: An optional title for the event.
    ///     - detailsInformation: An optional detailed information string for the event.
    ///     - initialValue: The initial value shown for the digital crown.
    ///     - startValue: The minimum possible value.
    ///     - endValue: The maximum possible value.
    ///     - incrementValue: The step amount.
    ///     - emojis: An array of emoji's to show on the screen.
    ///     - colorRatio: The ratio effect on the color gradient.
    ///     - action: The action to perform when the log button is tapped.
    public init(
        event: OCKAnyEvent,
        kind: String? = nil,
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        initialValue: Double? = nil,
        startValue: Double = 0,
        endValue: Double? = nil,
        incrementValue: Double = 1,
        emojis: [String] = [],
        colorRatio: Double = 0.2,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil
    ) {
        self.startValue = startValue
        self.incrementValue = incrementValue
        self.colorRatio = colorRatio
        self.emojis = emojis
        if let endValue = endValue {
            self.endValue = endValue
        } else if emojis.count > 0 {
            self.endValue = Double(emojis.count) - 1
        } else {
            self.endValue = 0
        }
        if let initialValue = initialValue {

            var currentInitialOutcome = OCKOutcomeValue(initialValue)
            let values = Self.filterAndSortValuesByLatest(event.outcomeValues, by: kind)
            if let latestOutcomeValue = values?.first,
               let initialOutcomeDouble = latestOutcomeValue.doubleValue {
                if initialOutcomeDouble == initialValue {
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
        } else {
            super.init(
                event: event,
                initialValue: OCKOutcomeValue(startValue),
                detailsTitle: detailsTitle,
                detailsInformation: detailsInformation,
                action: action
            )
        }
    }

}
