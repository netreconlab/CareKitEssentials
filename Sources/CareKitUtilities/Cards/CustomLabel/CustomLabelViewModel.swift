//
//  CustomLabelViewModel.swift
//  Assuage
//
//  Created by Alyssa Donawa on 9/12/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import Foundation
import os.log

@MainActor
public class CustomLabelViewModel: TaskViewModel {

    @MainActor
    public func extractValue() async {
        self.value = OCKOutcomeValue(0)
    }
}
