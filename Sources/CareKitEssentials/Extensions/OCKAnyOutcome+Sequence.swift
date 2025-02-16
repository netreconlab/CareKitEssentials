//
//  OCKAnyOutcome+Sequence.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 7/7/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import Foundation

public extension Sequence where Element: OCKAnyOutcome {

    /**
     Returns the `OCKAnyOutcome` sorted in order from greatest to lowest with respect to a given `KeyPath`.
     When necessary, can specify a max value for the respective `KeyPath` to be less than or equal to.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - parameter lessThanEqualTo: The value that the `keyPath` of all `OCKAnyOutcome`'s should
     be less than or equal to. If this value is `nil`, the
     - returns: Returns an array of `OCKAnyOutcome` sorted from newest to oldest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKAnyOutcome` values
     in the array.
     */
    func sortedByGreatest<V>(
        _ keyPath: KeyPath<Element, V?>,
        lessThanEqualTo value: V? = nil
    ) throws -> [Element] where V: Comparable {
        let outcomes = try filter { outcome -> Bool  in
            guard let outcomeKeyValue = outcome[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            // If there's a value to compare to, check that the element
            // is less than or equal to this value.
            guard let value = value else {
                return true
            }
            guard outcomeKeyValue <= value else {
                return false
            }
            return true
        }
        let sortedOutcomes = try outcomes.sorted(by: {
            guard let firstKeyValue = $0[keyPath: keyPath],
                  let secondKeyValue = $1[keyPath: keyPath] else {
                // Should never occur due to filter above
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            return firstKeyValue > secondKeyValue
        })

        return sortedOutcomes
    }

    /**
     Returns the `OCKAnyOutcome` sorted in order from greatest to lowest with respect to a given `KeyPath`.
     When necessary, can specify a max value for the respective `KeyPath` to be less than or equal to.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - parameter lessThanEqualTo: The value that the `keyPath` of all `OCKAnyOutcome`'s should
     be less than or equal to. If this value is `nil`, the
     - returns: Returns an array of `OCKAnyOutcome` sorted from newest to oldest with respect to `keyPath`.
     */
    func sortedByGreatest<V>(
        _ keyPath: KeyPath<Element, V>,
        lessThanEqualTo value: V? = nil
    ) -> [Element] where V: Comparable {
        let outcomes = filter { outcome -> Bool  in
            let outcomeKeyValue = outcome[keyPath: keyPath]

            // If there's a value to compare to, check that the element
            // is less than or equal to this value.
            guard let value = value else {
                return true
            }
            guard outcomeKeyValue <= value else {
                return false
            }
            return true
        }
        let sortedOutcomes = outcomes.sorted(by: {
            let firstKeyValue = $0[keyPath: keyPath]
            let secondKeyValue = $1[keyPath: keyPath]
            return firstKeyValue > secondKeyValue
        })

        return sortedOutcomes
    }
}
