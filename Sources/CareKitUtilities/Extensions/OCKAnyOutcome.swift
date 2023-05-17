//
//  OCKAnyOutcome.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 12/3/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

public extension OCKAnyOutcome {

    func answerDouble(kind: String) -> [Double] {
        let doubleValues = values.compactMap({ value -> Double? in
            guard value.kind == kind else {
                return nil
            }
            guard let intValue = value.integerValue else {
                return value.doubleValue
            }
            return Double(intValue)
        })
        return doubleValues
    }

    func answerString(kind: String) -> [String] {
        let stringValues = values.compactMap { value -> String? in
            guard value.kind == kind else {
                return nil
            }
            return value.stringValue
        }
        return stringValues
    }

    func sortedOutcomeValuesByRecency() -> Self {
        guard !self.values.isEmpty else { return self }
        var newOutcome = self
        let sortedValues = newOutcome.values.sorted {
            $0.createdDate > $1.createdDate
        }

        newOutcome.values = sortedValues
        return newOutcome
    }

    func sortedOutcomeValues() -> Self {
        guard !self.values.isEmpty else { return self }
        var newOutcome = self
        let sortedValues = newOutcome.values.sorted {
            if let value0 = $0.dateValue,
               let value1 = $1.dateValue {
                return value0 > value1
            } else if let value0 = $0.integerValue,
                      let value1 = $1.integerValue {
                return value0 > value1
            } else if let value0 = $0.doubleValue,
                      let value1 = $1.doubleValue {
                return value0 > value1
            } else {
                return false
            }
        }

        newOutcome.values = sortedValues
        return newOutcome
    }
}
