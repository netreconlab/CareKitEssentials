//
//  File.swift
//  
//
//  Created by Corey Baker on 5/14/23.
//

import SwiftUI

private struct CareKitUtilitiesTintColorKey: EnvironmentKey {

    static var defaultValue: UIColor {
        #if os(iOS) || os(macOS)
            return UIColor { $0.userInterfaceStyle == .light ? #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
        #else
            return #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1)
        #endif
    }

}

public extension EnvironmentValues {

    var careKitUtilitiesTintColor: UIColor {
        get { self[CareKitUtilitiesTintColorKey.self] }
        set { self[CareKitUtilitiesTintColorKey.self] = newValue }
    }

}

public extension View {

    /// Provide tint color that can be used by a view.
    /// - Parameter tintColor: Tint color that can be used by a view.
    func careKitUtilitiesTintColor(_ tintColor: UIColor) -> some View {
        return self.environment(\.careKitUtilitiesTintColor, tintColor)
    }
}
