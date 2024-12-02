//
//  TemporalProgress.swift
//  Assuage
//
//  Created by Corey Baker on 7/31/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import Foundation

struct TemporalProgress<Progress> {
    var values: [Progress]
    var date: Date
}

extension TemporalProgress: Hashable, Equatable where Progress: Hashable {}
