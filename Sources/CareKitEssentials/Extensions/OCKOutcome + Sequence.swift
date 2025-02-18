//
//  OCKOutcome + Sequence.swift
//  CareKitEssentials
//
//  Created by Rodrigo Aguilar Barrios on 2/17/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import Foundation

public extension Sequence where Element == OCKOutcome {

    /**
     Returns the `OCKOutcome` with `OCKOutcomeValue`s being greater than or equal to a given `KeyPath`.

     - parameter keyPath: An optional `Comparable` `KeyPath` to filtred out the `OCKOutcome`'s `OCKOutcomeValue`s by.
     - parameter beingGreaterThanTo: The value that the `keyPath` of all `OCKOutcome`'s`OCKOutcomeValue`s should
     satisfy. If this value is `nil`, the
     - returns: Returns an array of `OCKOutcome`'s`OCKOutcomeValue`s
     filtered with respect to `keyPath` being greater than or equal to `beingGreaterThanTo`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKOutcome`'s`OCKOutcomeValues`
     in the array.
     */
    func filterOutcomeValuesBy<V>(
        _ keyPath: KeyPath<OCKOutcomeValue, V?>,
        beingGreaterThanTo value: V? = nil
    ) throws -> [Element] where V: Comparable {
        let outcomes =  try compactMap { outcome -> Element? in
            let outcomeValues = outcome.values
            let filteredValues = try outcomeValues.filter { outcomeValue in
                guard let outcomeValueKeyValue = outcomeValue[keyPath: keyPath] else {
                    throw CareKitEssentialsError.couldntUnwrapRequiredField
                }
                // Value must be present to satisfy condition of
                // only allowing values greater than or equal to this value
                if let value = value {
                    return outcomeValueKeyValue >= value
                }
                return false
            }
            return OCKOutcome(
                taskUUID: outcome.taskUUID,
                taskOccurrenceIndex: outcome.taskOccurrenceIndex,
                values: filteredValues
            )
        }
        return outcomes
    }

    /**
     Returns the `OCKOutcome` with `OCKOutcomeValue`s being greater than or equal to a given `KeyPath`.

     - parameter keyPath: An optional `Comparable` `KeyPath` to filtred out the `OCKOutcome`'s `OCKOutcomeValue`s by.
     - parameter beingGreaterThanTo: The value that the `keyPath` of all `OCKOutcome`'s`OCKOutcomeValue`s should
     satisfy. If this value is `nil`, the
     - returns: Returns an array of `OCKOutcome`'s`OCKOutcomeValue`s
     filtered with respect to `keyPath` being greater than or equal to `beingGreaterThanTo`.
     */
    func filterOutcomeValuesBy<V>(
        _ keyPath: KeyPath<OCKOutcomeValue, V>,
        beingGreaterThanTo value: V? = nil
    ) -> [Element] where V: Comparable {
        let outcomes = compactMap { outcome -> Element? in
            let outcomeValues = outcome.values
            let filteredValues =  outcomeValues.filter { outcomeValue in
                let outcomeValueKeyValue = outcomeValue[keyPath: keyPath]
                // Value must be present to satisfy condition of
                // only allowing values greater than or equal to this value
                if let value = value {
                    return outcomeValueKeyValue >= value
                }
                return false
            }
            return OCKOutcome(
                taskUUID: outcome.taskUUID,
                taskOccurrenceIndex: outcome.taskOccurrenceIndex,
                values: filteredValues
            )
        }
        return outcomes
    }

}
