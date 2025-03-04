//
//  OCKOutcomeValue+Sequence.swift
//  CareKitEssentials
//
//  Created by Rodrigo Aguilar Barrios on 2/17/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import Foundation

public extension Sequence where Element == OCKOutcomeValue {

    /**
     Returns an array of `OCKOutcomeValue`'s filtered by a given `KeyPath`.
     Specify the lowest value for the respective `KeyPath` to be less than or equal to.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKOutcomeValue`'s by.
     - parameter lessThanEqualTo: The value that the `keyPath` of all `OCKOutcomeValue`'s should
     be less than or equal to.
     - returns: Returns an array of `OCKOutcomeValue` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKOutcomeValue` values
     in the array.
     */
    func filter<V>(
        _ keyPath: KeyPath<Element, V?>,
        lessThanEqualTo value: V
    ) throws -> [Element] where V: Comparable {
        let outcomeValues = try filter { outcome -> Bool  in
            guard let outcomeKeyValue = outcome[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            // Check that the element is less than
            // or equal to this value.
            guard outcomeKeyValue <= value else {
                return false
            }
            return true
        }

        return outcomeValues
    }

    /**
     Returns an array of `OCKOutcomeValue`'s filtered by a given `KeyPath`.
     Specify the lowest value for the respective `KeyPath` to be less than or equal to.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKOutcomeValue`'s by.
     - parameter lessThanEqualTo: The value that the `keyPath` of all `OCKOutcomeValue`'s should
     be less than or equal to.
     - returns: Returns an array of `OCKOutcomeValue` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKOutcomeValue` values
     in the array.
     */
    func filter<V>(
        _ keyPath: KeyPath<Element, V>,
        lessThanEqualTo value: V
    ) -> [Element] where V: Comparable {
        let outcomeValues = filter { outcome -> Bool  in
            let outcomeKeyValue = outcome[keyPath: keyPath]

            // Check that the element is less than
            // or equal to this value.
            guard outcomeKeyValue <= value else {
                return false
            }
            return true
        }

        return outcomeValues
    }

    /**
     Returns an array of `OCKOutcomeValue`'s filtered by a given `KeyPath`.
     Specify the lowest value for the respective `KeyPath` to be less than or equal to.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKOutcomeValue`'s by.
     - parameter greaterThanEqualTo: The value that the `keyPath` of all `OCKOutcomeValue`'s should
     be less than or equal to.
     - returns: Returns an array of `OCKOutcomeValue` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKOutcomeValue` values
     in the array.
     */
    func filter<V>(
        _ keyPath: KeyPath<Element, V?>,
        greaterThanEqualTo value: V
    ) throws -> [Element] where V: Comparable {
        let outcomeValues = try filter { outcome -> Bool  in
            guard let outcomeKeyValue = outcome[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            // Check that the element is less than
            // or equal to this value.
            guard outcomeKeyValue >= value else {
                return false
            }
            return true
        }

        return outcomeValues
    }

    /**
     Returns an array of `OCKOutcomeValue`'s filtered by a given `KeyPath`.
     Specify the lowest value for the respective `KeyPath` to be less than or equal to.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKOutcomeValue`'s by.
     - parameter greaterThanEqualTo: The value that the `keyPath` of all `OCKOutcomeValue`'s should
     be less than or equal to.
     - returns: Returns an array of `OCKOutcomeValue` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKOutcomeValue` values
     in the array.
     */
    func filter<V>(
        _ keyPath: KeyPath<Element, V>,
        greaterThanEqualTo value: V
    ) -> [Element] where V: Comparable {
        let outcomeValues = filter { outcome -> Bool  in
            let outcomeKeyValue = outcome[keyPath: keyPath]

            // Check that the element is less than
            // or equal to this value.
            guard outcomeKeyValue >= value else {
                return false
            }
            return true
        }

        return outcomeValues
    }

    /**
     Returns the `OCKOutcomeValue` sorted in order from highest to lowest with respect to a given `KeyPath`.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKOutcomeValue`'s by.
     - returns: Returns an array of `OCKOutcomeValue` sorted from highest to lowest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKOutcomeValue` values
     in the array.
     */
    func sortedByHighest<V>(
        _ keyPath: KeyPath<Element, V?>
    ) throws -> [Element] where V: Comparable {
        let sortedOutcomeValues = try sorted(by: {
            guard let firstKeyValue = $0[keyPath: keyPath],
                  let secondKeyValue = $1[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            return firstKeyValue > secondKeyValue
        })

        return sortedOutcomeValues
    }

    /**
     Returns the `OCKOutcomeValue` sorted in order from highest to lowest with respect to a given `KeyPath`.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKOutcomeValue`'s by.
     - returns: Returns an array of `OCKOutcomeValue` sorted from highest to lowest with respect to `keyPath`.
     */
    func sortedByHighest<V>(
        _ keyPath: KeyPath<Element, V>
    ) -> [Element] where V: Comparable {
        let sortedOutcomeValues = sorted(by: {
            let firstKeyValue = $0[keyPath: keyPath]
            let secondKeyValue = $1[keyPath: keyPath]
            return firstKeyValue > secondKeyValue
        })

        return sortedOutcomeValues
    }

    /**
     Returns the `OCKOutcomeValue` sorted in order from lowest to highest with respect to a given `KeyPath`.

     - parameter keyPath: An optional `Comparable` `KeyPath` to sort the `OCKOutcomeValue`'s by.
     - returns: Returns an array of `OCKOutcomeValue` sorted from lowest to highest with respect to `keyPath`.
     - throws: An error when the `keyPath` cannot be unwrapped for any of the `OCKOutcomeValue` values
     in the array.
     */
    func sortedByLowest<V>(
        _ keyPath: KeyPath<Element, V?>
    ) throws -> [Element] where V: Comparable {
        let sortedOutcomeValues = try sorted(by: {
            guard let firstKeyValue = $0[keyPath: keyPath],
                  let secondKeyValue = $1[keyPath: keyPath] else {
                throw CareKitEssentialsError.couldntUnwrapRequiredField
            }
            return firstKeyValue < secondKeyValue
        })

        return sortedOutcomeValues
    }

    /**
     Returns the `OCKOutcomeValue` sorted in order from lowest to highest with respect to a given `KeyPath`.

     - parameter keyPath: A `Comparable` `KeyPath` to sort the `OCKOutcomeValue`'s by.
     - returns: Returns an array of `OCKOutcomeValue` sorted from lowest to highest with respect to `keyPath`.
     */
    func sortedByLowest<V>(
        _ keyPath: KeyPath<Element, V>
    ) -> [Element] where V: Comparable {
        let sortedOutcomeValues = sorted(by: {
            let firstKeyValue = $0[keyPath: keyPath]
            let secondKeyValue = $1[keyPath: keyPath]
            return firstKeyValue < secondKeyValue
        })

        return sortedOutcomeValues
    }
}
