//
//  CardEnabledEnvironmentKey.swift
//  CareKitUtilities
//
//  Created by Corey Baker on 5/15/23.
//

import SwiftUI

private struct CardEnabledEnvironmentKey: EnvironmentKey {
    static var defaultValue = true
}

extension EnvironmentValues {
    var isCardEnabled: Bool {
        get { self[CardEnabledEnvironmentKey.self] }
        set { self[CardEnabledEnvironmentKey.self] = newValue }
    }
}

extension View {
    func cardEnabled(_ enabled: Bool) -> some View {
        return self.environment(\.isCardEnabled, enabled)
    }
}
