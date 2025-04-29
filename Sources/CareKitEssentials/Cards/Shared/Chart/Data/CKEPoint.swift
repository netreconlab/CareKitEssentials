//
//  CKEPoint.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 7/31/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKitStore
import Foundation

struct CKEPoint: Hashable, Identifiable {
    let id = UUID()
    var x: Date // swiftlint:disable:this identifier_name
	var xUnit: Calendar.Component {
		period.lowestCommonComponent
	}
    var y: Double // swiftlint:disable:this identifier_name
	var yUnit: String?
	var period: PeriodComponent
	var originalValues: [Double]
    var accessibilityValue: String?
}
