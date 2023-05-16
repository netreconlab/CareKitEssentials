//
//  OSValue.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 12/4/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import Foundation

// swiftlint:disable:next type_name
enum OS: String {
    case iOS, watchOS, macOS
}

@propertyWrapper
struct OSValue<Value> {

    private let values: [OS: Value]
    private let defaultValue: Value

    var wrappedValue: Value {
        #if os(iOS)
        return values[.iOS] ?? defaultValue
        #elseif os(watchOS)
        return values[.watchOS] ?? defaultValue
        #elseif os(macOS)
        return values[.macOS] ?? defaultValue
        #else
        return defaultValue
        #endif
    }

    init(values: [OS: Value], defaultValue: Value) {
        self.values = values
        self.defaultValue = defaultValue
    }
}
