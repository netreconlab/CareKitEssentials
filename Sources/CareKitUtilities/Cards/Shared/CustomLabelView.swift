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
    @Environment(\.careKitUtilitiesTintColor) private var tintColor
    @ObservedObject var viewModel: CardViewModel
    var isUsingHeader = true

    public var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                if isUsingHeader {
                    if let informationTitle = viewModel.detailsTitle,
                        let informationDetails = viewModel.detailsInformation {
                        InformationHeaderView(title: Text(viewModel.event.title),
                                              task: viewModel.event.task,
                                              detailsTitle: informationTitle,
                                              details: informationDetails)
                    } else if let informationTitle = viewModel.detailsTitle {
                        InformationHeaderView(title: Text(viewModel.event.title),
                                              task: viewModel.event.task,
                                              detailsTitle: informationTitle)
                    } else if let informationDetails = viewModel.detailsInformation {
                        InformationHeaderView(title: Text(viewModel.event.title),
                                              task: viewModel.event.task,
                                              details: informationDetails)
                    } else {
                        InformationHeaderView(title: Text(viewModel.event.title),
                                              task: viewModel.event.task)
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
                            .foregroundColor(Color(tintColor))
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
                    viewModel.valueText
                        .font(.title)
                        .bold()
                        .foregroundColor(Color(tintColor))
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
