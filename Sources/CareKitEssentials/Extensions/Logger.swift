//
//  Logger.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 6/24/24.
//

import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let essentialView = Logger(subsystem: subsystem, category: "CareKitEssentialView")
    static let essentialChartView = Logger(subsystem: subsystem, category: "CareKitEssentialChartView")
}
