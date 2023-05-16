//
//  CustomLabelView.swift
//  CareKitUtilities
//
//  Created by Alyssa Donawa on 9/12/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKitUI
import SwiftUI

/// A custom label that can display a title, detail, or image.
/// Configured to display a value extracted from the viewmodel.
/// 
/// ```
///    +----------------------------------------+
///    | +----+                                 |
///    | |icon|  Title             +-----+      |
///    | |img |  Detail            |value|      |
///    | +----+                    +-----+      |
///    +----------------------------------------+
/// ```
public struct CustomLabelView: View {
    @Environment(\.careKitStyle) private var style
    @ObservedObject var viewModel: CardViewModel

    var isUsingHeader: Bool

    public var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                if isUsingHeader {
                    if let informationTitle = viewModel.detailsTitle,
                        let informationDetails = viewModel.detailsInformation {
                        InformationHeaderView(title: Text(viewModel.event.title),
                                              event: viewModel.event,
                                              detailsTitle: informationTitle,
                                              details: informationDetails)
                    } else if let informationTitle = viewModel.detailsTitle {
                        InformationHeaderView(title: Text(viewModel.event.title),
                                              event: viewModel.event,
                                              detailsTitle: informationTitle)
                    } else if let informationDetails = viewModel.detailsInformation {
                        InformationHeaderView(title: Text(viewModel.event.title),
                                              event: viewModel.event,
                                              details: informationDetails)
                    } else {
                        InformationHeaderView(title: Text(viewModel.event.title),
                                              event: viewModel.event)
                    }
                } else {
                    Text(viewModel.event.title)
                        .font(.headline)
                        .fontWeight(.bold)
                }

                Divider()
                HStack(spacing: style.dimension.directionalInsets2.trailing) {
                    if let asset = viewModel.event.asset {
                        Image(uiImage: asset)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 25, height: 30)
                            .foregroundColor(Color.accentColor)
                    }
                    VStack(alignment: .leading,
                           spacing: style.dimension.directionalInsets2.bottom) {
                        if let detail = viewModel.event.instructions {
                            Text(detail)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .foregroundColor(Color.primary)
                    Spacer()
                    viewModel.valueAsText
                        .font(.title)
                        .bold()
                        .foregroundColor(Color.accentColor)
                }
            }
            .padding()
        }
        .padding(.vertical)
    }
}

public extension CustomLabelView {
    /// Create an instance.
    /// - Parameter viewModel: The view model used to populate the view contents.
    /// - Parameter usingHeader: Should inject the header at the top of the card.
    init(viewModel: CardViewModel,
         usingHeader: Bool = true) {
        self.viewModel = viewModel
        self.isUsingHeader = usingHeader
    }
}

struct CustomLabelView_Previews: PreviewProvider {
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
            CustomLabelView(viewModel: .init(event: event))
                .environment(\.careStore, Utility.createPreviewStore())
        }
    }
}
