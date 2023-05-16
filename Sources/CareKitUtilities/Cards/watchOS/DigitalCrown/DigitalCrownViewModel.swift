//
//  DigitalCrownViewModel.swift
//  CareKitUtilities
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

public class DigitalCrownViewModel: CardViewModel {

    public func getStoplightColor(for value: Double) -> Color {
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

    public var isButtonDisabled: Bool {
        value == event.outcomeFirstValue
    }

    public var valueAsDouble: Double {
        get {
            return value.doubleValue ?? 0.0
        }
        set {
            var updatedValue = value
            updatedValue.value = newValue
            value = updatedValue
        }
    }

    public var valueForButton: String {
        "\(Int(valueAsDouble))"
    }

    private(set) var emojis = ["😄", "🙂", "😐", "😕", "😟", "☹️", "😞", "😓", "😥", "😰", "🤯"]
    private(set) var startValue: Double = 0
    private(set) var endValue: Double = 10
    private(set) var incrementValue: Double = 1
    private(set) var colorRatio: Double = 0.2

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - emojis: An array of emoji's to show on the screen.
    ///     - startValue: The minimum possible value.
    ///     - endValue: The maximum possible value.
    ///     - incrementValue: The step amount.
    ///     - action: The action to perform when the log button is tapped.
    public convenience init(event: OCKAnyEvent,
                            startValue: Double,
                            initialValue: Double,
                            endValue: Double,
                            incrementValue: Double,
                            colorRatio: Double,
                            action: @escaping ((OCKOutcomeValue?) async -> Void)) {
        self.init(event: event,
                  action: action)
        self.value = OCKOutcomeValue(initialValue)
        self.startValue = startValue
        self.endValue = endValue
        self.incrementValue = incrementValue
        self.colorRatio = colorRatio
    }

    /**
     Update new value with new information
     */
    public func updateValue(_ value: OCKOutcomeValue?) async {
        guard let value = value else { return }
        // Any additional info that needs to be added to the outcome
        let newOutcomeValue = OCKOutcomeValue(value.value)
        await action(newOutcomeValue)
    }
}
