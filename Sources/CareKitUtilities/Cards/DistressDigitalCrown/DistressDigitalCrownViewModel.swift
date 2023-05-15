//
//  DistressDigitalCrownViewModel.swift
//  AssuageWatch
//
//  Created by Julia Stekardis on 10/10/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

#if os(watchOS)
import CareKit
import CareKitStore
import Foundation
import os.log

class DistressDigitalCrownViewModel: DigitalCrownViewModel {

    convenience init() {
        self.init(taskID: DistressAssessment().taskType.rawValue,
                  eventQuery: .init(for: Date()))
    }
}
#endif
