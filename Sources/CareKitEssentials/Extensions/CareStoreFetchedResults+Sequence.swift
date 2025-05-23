//
//  CareStoreFetchedResults+Sequence.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/7/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import Foundation

public extension CareStoreFetchedResults where Result == any CareKitEssentialVersionable {

	/// Returns the earliest results from the fetched elements.
	/// All elements are guaranteed to be unique by their respective `id`.
	var earliest: [CareStoreFetchedResult<Result>] {
		let resultDictionary = Dictionary(grouping: self, by: \.result.id)
		let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
			results.first
		}
		return compactResults
	}

	/// Returns the latest results from the fetched elements.
	/// All elements are guaranteed to be unique by their respective `id`.
	var latest: [CareStoreFetchedResult<Result>] {
		let resultDictionary = Dictionary(grouping: self, by: \.result.id)
		let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
			results.last
		}
		return compactResults
	}
}

public extension CareStoreFetchedResults where Result == OCKAnyPatient {

    /// Returns the earliest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var earliest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.first
        }
        return compactResults
    }

    /// Returns the latest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var latest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.last
        }
        return compactResults
    }
}

public extension CareStoreFetchedResults where Result == OCKAnyCarePlan {

    /// Returns the earliest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var earliest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.first
        }
        return compactResults
    }

    /// Returns the latest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var latest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.last
        }
        return compactResults
    }
}

public extension CareStoreFetchedResults where Result == OCKAnyTask {

    /// Returns the earliest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var earliest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.first
        }
        return compactResults
    }

    /// Returns the latest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var latest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.last
        }
        return compactResults
    }
}

public extension CareStoreFetchedResults where Result == OCKAnyEvent {

    /// Returns the earliest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `task.id`.
    var earliest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.task.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.first
        }
        return compactResults
    }

    /// Returns the latest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `task.id`.
    var latest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.task.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.last
        }
        return compactResults
    }
}

public extension CareStoreFetchedResults where Result == OCKAnyContact {

    /// Returns the earliest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var earliest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.first
        }
        return compactResults
    }

    /// Returns the latest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var latest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.last
        }
        return compactResults
    }
}

public extension CareStoreFetchedResults where Result == OCKAnyOutcome {

    /// Returns the earliest results from the fetched elements.
    /// All elements are guaranteed to be unique by their respective `id`.
    var earliest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.first
        }
        return compactResults
    }

    /// Returns the latest results from the fetched elements.
    /// All elements are guaranteed to be unique.
    var latest: [CareStoreFetchedResult<Result>] {
        let resultDictionary = Dictionary(grouping: self, by: \.result.id)
        let compactResults = resultDictionary.compactMap { _, results -> CareStoreFetchedResult<Result>? in
            results.last
        }
        return compactResults
    }
}
