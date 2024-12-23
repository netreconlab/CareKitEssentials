//
//  TemporalTaskProgress.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 7/31/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import Foundation

struct TemporalTaskProgress<Progress> {

    var id: String
    var progressPerDates: [TemporalProgress<Progress>]
}

extension TemporalTaskProgress: Hashable, Equatable where Progress: Hashable {}
