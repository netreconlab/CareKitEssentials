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
    var title: Text
    var instructions: Text?
    var asset: Image?
    var detailsTitle: Text?
    var detailsInformation: Text?
    var isUsingHeader = true

    public var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                if isUsingHeader {
                    if let informationTitle = detailsTitle,
                        let informationDetails = detailsInformation {
                        InformationHeaderView(title: title,
                                              task: task,
                                              detailsTitle: informationTitle,
                                              details: informationDetails)
                    } else if let informationTitle = detailsTitle {
                        InformationHeaderView(title: title,
                                              task: task,
                                              detailsTitle: informationTitle)
                    } else if let informationDetails = detailsInformation {
                        InformationHeaderView(title: title,
                                              task: task,
                                              details: informationDetails)
                    } else {
                        InformationHeaderView(title: title,
                                              task: task)
                    }
                } else {
                    title
                        .font(.headline)
                        .fontWeight(.bold)
                }

                Divider()
                HStack(spacing: style.dimension.directionalInsets2.trailing) {
                    if let asset = asset {
                        asset
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 25, height: 30)
                            .foregroundColor(Color(tintColor))
                    }
                    VStack(alignment: .leading,
                           spacing: style.dimension.directionalInsets2.bottom) {
                        if let detail = instructions {
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
        .onReceive(viewModel.$taskEvents) { _ in
            /*
             Need help from view to update value since taskEvents
             can't be overriden in viewModel.
             */
            Task {
                await viewModel.extractValue()
            }
        }
        .onReceive(viewModel.$error) { error in
            /*
             Need help from view to update value since error
             can't be overriden in viewModel.
             */
            viewModel.setError(error)
        }
    }
}

public extension CustomLabelView {
    /**
     Create an instance.
     - parameter viewModel: The view model used to populate the view contents.
     - parameter detailsTitle: Optional title to be shown on CareKit Cards.
     - parameter usingHeader: Should inject the header at the top of the card.
     */
    init(detailsTitle: String,
         usingHeader: Bool = true) {
        self.viewModel = viewModel
        self.isUsingHeader = usingHeader
    }
}
