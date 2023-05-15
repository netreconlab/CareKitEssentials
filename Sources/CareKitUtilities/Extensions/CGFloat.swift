//
//  CGFloat.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 12/4/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import Foundation
import SwiftUI

extension CGFloat {

    /// Scaled value for the current size category.
    func scaled() -> CGFloat {
        UIFontMetrics.default.scaledValue(for: self)
    }
}
