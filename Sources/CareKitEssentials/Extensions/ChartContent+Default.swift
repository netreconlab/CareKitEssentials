//
//  ChartContent+Default.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/2/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import Charts
import Foundation

extension ChartContent {
    func `if`<TrueContent: ChartContent>(_ condition: Bool, trueContent: (Self) -> TrueContent) -> some ChartContent {
        condition ? ChartContentBuilder.buildEither(first: trueContent(self)) :
            ChartContentBuilder.buildEither(second: self)
    }
}
