//
//  DigitalCrownViewHeader.swift
//  CareKitEssentials
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
    let event: OCKAnyEvent?

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: style.dimension.directionalInsets1.top
        ) {
            if let event = event {
                InformationHeaderView(
                    title: title,
                    information: detail,
                    event: event
                )
            } else {
                HeaderView(
                    title: title,
                    detail: detail
                )
            }
        }
    }
}

struct DigitalCrownViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
            DigitalCrownViewHeader(
                title: Text(event.task.title ?? ""),
                detail: Text(event.task.instructions ?? ""),
                event: event
            )
            .environment(\.careStore, Utility.createPreviewStore())
        }
    }
}

#endif
