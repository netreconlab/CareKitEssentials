//
//  CKEPoint.swift
//  Assuage
//
//  Created by Corey Baker on 7/31/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import Foundation

struct CKEPoint: Hashable, Identifiable {
    let id = UUID()
    var x: String // swiftlint:disable:this identifier_name
    var y: Double // swiftlint:disable:this identifier_name
    var accessibilityValue: String?
}
