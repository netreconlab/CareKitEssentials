//
//  SimpleLabelView.swift
//  CareKitEssentials
//
//  Created by Alyssa Donawa on 9/20/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKitUI
import os.log
import SwiftUI

/// A title and detail label. The view can also be configured to show an
/// icon image, and a "value" or text. All params optional, for example
/// can have an image and value with no title or detail.
/// 
/// ```
///    +----------------------------------------+
///    | +----+                                 |
///    | |icon|  Title             +-----+      |
///    | |img |  Detail            |value|      |
///    | +----+                    +-----+      |
///    +----------------------------------------+
/// ```
/// ```
/// // Example Usage Below:
/// SimpleLabelView(title: Text("Title"),
///                 detail: Text("Some details."),
///                 image: Image(systemName: "heart.fill"),
///                 value: Text("#"))
/// ```
public struct SimpleLabelView<Header: View>: View {
    @Environment(\.careKitStyle) private var style
    @Environment(\.isCardEnabled) private var isCardEnabled

    let header: Header?
    let title: Text?
    let detail: Text?
    let image: Image?
    let value: Text?

    public var body: some View {
        CardView {
            VStack(
                alignment: .leading,
                spacing: style.dimension.directionalInsets1.top
            ) {
                header
                HStack(
                    spacing: style.dimension.directionalInsets2.trailing
                ) {
                    image?
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 25, height: 30)
                        .foregroundColor(Color.accentColor)
                    VStack(
                        alignment: .leading,
                        spacing: style.dimension.directionalInsets2.bottom
                    ) {
                        title?
                            .font(.headline)
                            .fontWeight(.bold)
                        detail?
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(Color.primary)
                    Spacer()
                    value?
                        .font(.title)
                        .bold()
                        .foregroundColor(.accentColor)
                }
            }
            .padding(isCardEnabled ? [.all] : [])
        }
    }

    public init(
        header: Header?,
        title: Text? = nil,
        detail: Text? = nil,
        image: Image? = nil,
        value: Text? = nil
    ) {
        self.header = header
        self.title = title
        self.detail = detail
        self.image = image
        self.value = value
    }
}

public extension SimpleLabelView where Header == InformationHeaderView {

    init(
        title: Text? = nil,
        detail: Text? = nil,
        image: Image? = nil,
        value: Text? = nil
    ) {
        self.init(
            header: nil,
            title: title,
            detail: detail,
            image: image,
            value: value
        )
    }
}

struct SimpleLabelView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SimpleLabelView(
                title: Text("Title"),
                detail: Text("Some details."),
                image: Image(
                    systemName: "heart.fill"
                ),
                value: Text("100")
            )
            Divider()
            if let event = try? Utility.createNauseaEvent() {
                SimpleLabelView(
                    header: InformationHeaderView(
                        title: Text(event.title),
                        information: event.instructionsText,
                        event: event
                    ),
                    title: Text(event.title),
                    detail: event.detailText,
                    image: Image(
                        systemName: "heart.fill"
                    ),
                    value: Text("100")
                )
            }
        }
        .padding()
        .accentColor(.red)
        .careKitStyle(OCKStyle())
    }
}
