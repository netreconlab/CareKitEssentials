//
//  View+Default.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 2/12/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    #if !os(watchOS) && canImport(UIKit)
    func formattedHostingController() -> UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
    #endif

    func `if`<TrueContent: View>(_ condition: Bool, trueContent: (Self) -> TrueContent) -> some View {
        condition ?
            ViewBuilder.buildEither(first: trueContent(self)) :
            ViewBuilder.buildEither(second: self)
    }
}
