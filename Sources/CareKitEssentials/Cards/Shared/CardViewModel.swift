//
//  CardViewModel.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/4/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import Foundation
import SwiftUI

/**
 A view model that can be subclassed to build more intricate view models for
 CareKit style cards.
 */
open class CardViewModel: ObservableObject {

    // MARK: Published public read/write properties

    /// The error encountered by the view model.
    @Published public var error: Error?
    /// The latest `OCKOutcomeValue` for the event.
    @Published public var value = OCKOutcomeValue(0.0) {
        didSet {
            guard isInitialValue,
                  let double = value.doubleValue else {
                return
            }
            valueAsDouble = double
        }
    }
    /// The latest`OCKOutcomeValue` for the event as a `Double`.
    @Published public var valueAsDouble: Double = 0 {
        didSet {
            guard !isInitialValue else {
                return
            }
            var updatedValue = value
            updatedValue.value = valueAsDouble
            value = updatedValue
        }
    }

    // MARK: Public read/write properties

    /// Specifies if this is the first time a value is being set.
    public var isInitialValue: Bool {
        valueAsDouble == initialValue.doubleValue
    }

    // MARK: Public read only properties

    /// The latest`OCKOutcomeValue` for the event as a String.
    public var valueAsString: String {
        value.description
    }
    /// The event associated with the view model.
    public private(set) var event: OCKAnyEvent
    /// A custom details title to display for the task of the view model.
    public private(set) var detailsTitle: String?
    /// A custom details information string to display for the task of the view model.
    public private(set) var detailsInformation: String?

    var kind: String?
    var initialValue: OCKOutcomeValue
    var action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)?

    /// Create an instance with specified content for an event. The view will update when changes
    /// occur in the store.
    /// - Parameters:
    ///     - event: A event to associate with the view model.
    ///     - kind: An optional property that can be used to specify what kind of values the
    ///   outcome values are (e.g. blood pressure, qualitative stress, weight).
    ///     - initialValue: The default outcome value for the view model. Defaults to 0.0.
    ///     - detailsTitle: An optional title for the event.
    ///     - detailsInformation: An optional detailed information string for the event.
    ///     - action: The action to take when event is completed.
    public init(
        event: OCKAnyEvent,
        kind: String? = nil,
        initialValue: OCKOutcomeValue = OCKOutcomeValue(0.0),
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil
    ) {
        self.initialValue = initialValue
        if let initialValueAsDouble = initialValue.doubleValue {
            self.valueAsDouble = initialValueAsDouble
        }
        self.kind = kind
        let values = Self.filterAndSortValuesByLatest(event.outcomeValues, by: kind)
        self.value = values?.first ?? initialValue
        self.detailsTitle = detailsTitle
        self.detailsInformation = detailsInformation
        self.event = event
        self.action = action
    }

    // MARK: Intents

    /// Update the the viewModel with the current outcome.
    /// - Parameters:
    ///     - event: The current event.
    @MainActor
    public func updateOutcome(_ outcome: OCKAnyOutcome) {
        let outcomeWithSortedValues = Self.filterAndSortValuesByLatest(event.outcomeValues, by: kind)
        value = outcomeWithSortedValues?.first ?? initialValue
        initialValue = value
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
}
