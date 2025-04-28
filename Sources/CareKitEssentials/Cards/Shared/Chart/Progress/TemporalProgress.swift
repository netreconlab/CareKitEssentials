//
//  TemporalProgress.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 7/31/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import Foundation

struct CombinedProgress<Progress> {
	var value: Progress
	var unit: String?
	var date: Date
	var period: PeriodComponent
}

struct TemporalProgress<Progress> {
    var values: [Progress]
	var units: [String]?
    var date: Date
	var period: PeriodComponent
}

extension TemporalProgress: Hashable, Equatable where Progress: Hashable {}
