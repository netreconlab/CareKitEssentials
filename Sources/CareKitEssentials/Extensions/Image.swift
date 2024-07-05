//
//  Image.swift
//  CareKitEssentials
//
//  Created by Alyssa Donawa on 2/27/23.
//  Copyright © 2023 NetReconLab. All rights reserved.
//

import Foundation
import SwiftUI

public extension Image {
    static func asset(_ name: String?) -> Image? {
        // We can't be sure if the image they provide is in the assets folder, in the bundle, or in a directory.
        guard let name = name else { return nil }
        // We can check all 3 possibilities and then choose whichever is non-nil.
        #if canImport(UIKit)
        guard UIImage(systemName: name) != nil else {
            guard UIImage(named: name) != nil else {
                guard let otherUrlUIImage = UIImage(contentsOfFile: name) else {
                    return nil
                }
                return Image(uiImage: otherUrlUIImage)
            }
            return Image(name)
        }
        #elseif canImport(AppKit)
        guard NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil else {
            guard NSImage(named: name) != nil else {
                guard let otherUrlUIImage = NSImage(contentsOfFile: name) else {
                    return nil
                }
                return Image(nsImage: otherUrlUIImage)
            }
            return Image(name)
        }
        #endif
        return Image(systemName: name)
    }
}
