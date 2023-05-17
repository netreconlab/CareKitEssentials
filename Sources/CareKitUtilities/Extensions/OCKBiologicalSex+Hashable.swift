//
//  OCKBiologicalSex+Hashable.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 11/7/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore

 // Needed to use OCKBiologicalSex in a Picker.
 // Simple conformance to hashable protocol.
extension OCKBiologicalSex: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}
