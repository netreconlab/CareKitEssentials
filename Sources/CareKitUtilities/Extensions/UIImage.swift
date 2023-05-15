//
//  UIImage.swift
//  Assuage
//
//  Created by Corey Baker on 12/6/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    static func asset(_ name: String?) -> UIImage? {
        // We can't be sure if the image they provide is in the assets folder, in the bundle, or in a directory.
        guard let name = name else { return nil }
        // We can check all 3 possibilities and then choose whichever is non-nil.
        let symbol = UIImage(systemName: name)
        let appAssetsImage = UIImage(named: name)
        let otherUrlImage = UIImage(contentsOfFile: name)
        return otherUrlImage ?? appAssetsImage ?? symbol
    }
}
