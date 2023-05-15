//
//  DigitalCrownViewHeader.swift
//  CareKitUtilities
//
//  Created by Julia Stekardis on 12/1/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

#if os(watchOS)

import CareKitStore
import CareKitUI
import SwiftUI

/// The default header used by a `DigitalCrownView`.
public struct DigitalCrownViewHeader: View {

    @Environment(\.careKitStyle) private var style

    let title: Text
    let detail: Text?
    let task: OCKAnyTask?

    public var body: some View {
        VStack(alignment: .leading,
               spacing: style.dimension.directionalInsets1.top) {
            if let task = task {
                InformationHeaderView(title: title,
                                      information: detail,
                                      task: task)
            } else {
                HeaderView(title: title, detail: detail)
            }
            Divider()
        }
    }
}

struct DigitalCrownViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        DigitalCrownViewHeader(title: Text("Title"),
                               detail: Text("Detail"),
                               task: OCKTask(id: "",
                                             title: "Hello",
                                             carePlanUUID: nil,
                                             schedule: .dailyAtTime(hour: 0,
                                                                    minutes: 0,
                                                                    start: Date(),
                                                                    end: nil,
                                                                    text: "")))
    }
}

#endif
