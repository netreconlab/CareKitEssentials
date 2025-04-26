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
	var date: Date
	var dateComponent: Calendar.Component
}

struct TemporalProgress<Progress> {
    var values: [Progress]
    var date: Date
	var dateComponent: Calendar.Component
}

extension TemporalProgress: Hashable, Equatable where Progress: Hashable {}
