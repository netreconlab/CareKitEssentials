//
//  NSImage.swift
//
//
//  Created by Corey Baker on 7/5/24.
//

#if canImport(AppKit)
import Foundation
import AppKit

public extension NSImage {
    static func asset(_ name: String?) -> NSImage? {
        // We can't be sure if the image they provide is in the assets folder, in the bundle, or in a directory.
        guard let name = name else { return nil }
        // We can check all 3 possibilities and then choose whichever is non-nil.
        let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil)
        let appAssetsImage = NSImage(named: name)
        let otherUrlImage = NSImage(contentsOfFile: name)
        return otherUrlImage ?? appAssetsImage ?? symbol
    }
}
#endif
