//
//  CareKitEssentialSliderLogView+EventViewable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/5/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if canImport(SwiftUI) && !os(watchOS)

import CareKitStore

extension CareKitEssentialSliderLogView: EventViewable {

	public init?(
		event: OCKAnyEvent,
		store: any OCKAnyStoreProtocol
	) {
		self.init(
			event: event
		)
	}
}

#endif
