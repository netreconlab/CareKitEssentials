//
//  CareStoreFetchedViewable.swift
//  Assuage
//
//  Created by Corey Baker on 12/10/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import SwiftUI

public protocol CareStoreFetchedViewable: View {
    init?(event: CareStoreFetchedResult<OCKAnyEvent>)
}
