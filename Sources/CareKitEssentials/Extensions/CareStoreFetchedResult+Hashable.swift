//
//  CareStoreFetchedResult+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/13/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import Foundation

extension CareStoreFetchedResult: Hashable where Result: CareKitEssentialVersionable {}
