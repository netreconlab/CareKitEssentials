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
     Returns an array of `OCKAnyOutcome`'s filtered by a given `KeyPath`.
     Specify the max value for the respective `KeyPath` to be less than or equal to.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - parameter lessThanEqualTo: The value that the `keyPath` of all `OCKAnyOutcome`'s should
     be less than or equal to. If this value is `nil`, the
     - returns: Returns an array of `OCKAnyOutcome` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKAnyOutcome` values
     in the array.
     */
    func filter<V>(
        _ keyPath: KeyPath<Element, V?>,
        lessThanEqualTo value: V
    ) throws -> [Element] where V: Comparable {
        let outcomes = try filter { outcome -> Bool  in
            guard let outcomeKeyValue = outcome[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            guard outcomeKeyValue <= value else {
                return false
            }
            return true
        }

        return outcomes
    }

    /**
     Returns an array of `OCKAnyOutcome`'s filtered by a given `KeyPath`.
     Specify the max value for the respective `KeyPath` to be less than or equal to.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - parameter lessThanEqualTo: The value that the `keyPath` of all `OCKAnyOutcome`'s should
     be less than or equal to. If this value is `nil`, the
     - returns: Returns an array of `OCKAnyOutcome` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKAnyOutcome` values
     in the array.
     */
    func filter<V>(
        _ keyPath: KeyPath<Element, V>,
        lessThanEqualTo value: V
    ) -> [Element] where V: Comparable {
        let outcomes = filter { outcome -> Bool  in
            let outcomeKeyValue = outcome[keyPath: keyPath]

            guard outcomeKeyValue <= value else {
                return false
            }
            return true
        }

        return outcomes
    }

    /**
     Returns an array of `OCKAnyOutcome`'s filtered by a given `KeyPath`.
     Specify the lowest value for the respective `KeyPath` to be greater than or equal to.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - parameter greaterThanEqualTo: The value that the `keyPath` of all `OCKAnyOutcome`'s should
     be greater than or equal to.
     - returns: Returns an array of `OCKAnyOutcome` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKAnyOutcome` values
     in the array.
     */
    func filter<V>(
        _ keyPath: KeyPath<Element, V?>,
        greaterThanEqualTo value: V
    ) throws -> [Element] where V: Comparable {
        let outcomes = try filter { outcome -> Bool  in
            guard let outcomeKeyValue = outcome[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            guard outcomeKeyValue >= value else {
                return false
            }
            return true
        }

        return outcomes
    }

    /**
     Returns an array of `OCKAnyOutcome`'s filtered by a given `KeyPath`.
     Specify the lowest value for the respective `KeyPath` to be greater than or equal to.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - parameter greaterThanEqualTo: The value that the `keyPath` of all `OCKAnyOutcome`'s should
     be greater than or equal to.
     - returns: Returns an array of `OCKAnyOutcome` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKAnyOutcome` values
     in the array.
     */
    func filter<V>(
        _ keyPath: KeyPath<Element, V>,
        greaterThanEqualTo value: V
    ) -> [Element] where V: Comparable {
        let outcomes = filter { outcome -> Bool  in
            let outcomeKeyValue = outcome[keyPath: keyPath]

            guard outcomeKeyValue >= value else {
                return false
            }
            return true
        }

        return outcomes
    }

    /**
     Returns the `OCKAnyOutcome` sorted in order from highest to lowest with respect to a given `KeyPath`.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - returns: Returns an array of `OCKAnyOutcome` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKAnyOutcome` values
     in the array.
     */
    func sortedByHighest<V>(
        _ keyPath: KeyPath<Element, V?>
    ) throws -> [Element] where V: Comparable {
        let sortedOutcomes = try sorted(by: {
            guard let firstKeyValue = $0[keyPath: keyPath],
                  let secondKeyValue = $1[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            return firstKeyValue > secondKeyValue
        })

        return sortedOutcomes
    }

    /**
     Returns the `OCKAnyOutcome` sorted in order from highest to lowest with respect to a given `KeyPath`.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - returns: Returns an array of `OCKAnyOutcome` sorted from highest to lowest with respect to `keyPath`.
     */
    func sortedByHighest<V>(
        _ keyPath: KeyPath<Element, V>
    ) -> [Element] where V: Comparable {
        let sortedOutcomes = sorted(by: {
            let firstKeyValue = $0[keyPath: keyPath]
            let secondKeyValue = $1[keyPath: keyPath]
            return firstKeyValue > secondKeyValue
        })

        return sortedOutcomes
    }

    /**
     Returns the `OCKAnyOutcome` sorted in order from lowest to highest with respect to a given `KeyPath`.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - returns: Returns an array of `OCKAnyOutcome` sorted from lowest to highest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKAnyOutcome` values
     in the array.
     */
    func sortedByLowest<V>(
        _ keyPath: KeyPath<Element, V?>
    ) throws -> [Element] where V: Comparable {
        let sortedOutcomes = try sorted(by: {
            guard let firstKeyValue = $0[keyPath: keyPath],
                  let secondKeyValue = $1[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            return firstKeyValue < secondKeyValue
        })

        return sortedOutcomes
    }

    /**
     Returns the `OCKAnyOutcome` sorted in order from lowest to highest with respect to a given `KeyPath`.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKAnyOutcome`'s by.
     - returns: Returns an array of `OCKAnyOutcome` sorted from lowest to highest with respect to `keyPath`.
     */
    func sortedByLowest<V>(
        _ keyPath: KeyPath<Element, V>
    ) -> [Element] where V: Comparable {
        let sortedOutcomes = sorted(by: {
            let firstKeyValue = $0[keyPath: keyPath]
            let secondKeyValue = $1[keyPath: keyPath]
            return firstKeyValue < secondKeyValue
        })

        return sortedOutcomes
    }
}
