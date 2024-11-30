//
//  TemporalTaskProgress.swift
//  Assuage
//
//  Created by Corey Baker on 7/31/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import Foundation

struct TemporalTaskProgress<Progress> {

    var taskID: String
    var progressPerDates: [TemporalProgress<Progress>]
}

extension TemporalTaskProgress: Hashable, Equatable where Progress: Hashable {}
