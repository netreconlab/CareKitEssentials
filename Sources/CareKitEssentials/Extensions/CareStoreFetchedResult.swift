//
//  CareStoreFetchedResult.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/11/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import Foundation

extension CareStoreFetchedResult where Result == OCKAnyEvent {

    func toggleBooleanOutcome() async throws -> OCKAnyOutcome {
        try await store.toggleBooleanOutcome(for: result)
    }

    func toggleBooleanOutcome(
        completion: @escaping OCKResultClosure<OCKAnyOutcome> = { _ in }
    ) {
        store.toggleBooleanOutcome(for: result, completion: completion)
    }
}
