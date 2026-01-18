//
//  CGFloat.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/4/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

#if canImport(SwiftUI)

import Foundation
import SwiftUI

extension CGFloat {

    /// Scaled value for the current size category.
    func scaled() -> CGFloat {

        #if canImport(UIKit)

        return  UIFontMetrics.default.scaledValue(for: self)

        #else

        return 1

        #endif

    }
}

#endif
