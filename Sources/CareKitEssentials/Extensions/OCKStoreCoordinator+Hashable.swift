//
//  OCKStoreCoordinator+Hashable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/22/25.
//  Copyright © 2025 NetReconLab. All rights reserved.
//

import CareKitStore

extension OCKStoreCoordinator: @retroactive Equatable {
	public static func == (lhs: CareKitStore.OCKStoreCoordinator, rhs: CareKitStore.OCKStoreCoordinator) -> Bool {
		lhs === rhs
	}
}

extension OCKStoreCoordinator: @retroactive Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(Unmanaged.passUnretained(self).toOpaque())
	}
}
