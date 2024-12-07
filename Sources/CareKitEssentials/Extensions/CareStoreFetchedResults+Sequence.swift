//
//  CareStoreFetchedResults+Sequence.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/7/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import Foundation

public extension CareStoreFetchedResults {

    /// Returns the earliest results from the fetched elements.
    /// All elements are guaranteed to be unique.
    var earliest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.id)
        let reducedResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.first
        }
        return reducedResults
    }

    /// Returns the latest results from the fetched elements.
    /// All elements are guaranteed to be unique.
    var latest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.id)
        let reducedResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.last
        }
        return reducedResults
    }
}
