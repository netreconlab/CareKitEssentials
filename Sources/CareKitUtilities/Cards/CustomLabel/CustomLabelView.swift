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
    @ObservedObject var viewModel: CustomLabelViewModel
    var isUsingHeader = true

    public var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                if isUsingHeader {
                    if let task = viewModel.taskEvents.firstEventTask {

                        if let informationTitle = viewModel.detailsTitle,
                            let informationDetails = viewModel.detailsInformation {
                            InformationHeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                                                  task: task,
                                                  detailsTitle: informationTitle,
                                                  details: informationDetails)
                        } else if let informationTitle = viewModel.detailsTitle {
                            InformationHeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                                                  task: task,
                                                  detailsTitle: informationTitle)
                        } else if let informationDetails = viewModel.detailsInformation {
                            InformationHeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                                                  task: task,
                                                  details: informationDetails)
                        } else {
                            InformationHeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                                                  task: task)
                        }
                    } else {
                        HeaderView(title: Text(viewModel.taskEvents.firstEventTitle))
                    }
                } else {
                    Text(viewModel.taskEvents.firstEventTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                }

                Divider()
                HStack(spacing: style.dimension.directionalInsets2.trailing) {
                    if let asset = viewModel.taskEvents.firstTaskAsset {
                        Image(uiImage: asset)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 25, height: 30)
                            .foregroundColor(Color(tintColor))
                    }
                    VStack(alignment: .leading,
                           spacing: style.dimension.directionalInsets2.bottom) {
                        if let detail = viewModel.taskEvents.firstTaskInstructions {
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
    /// Create an instance.
    /// - Parameter viewModel: The view model used to populate the view contents.
    /// - Parameter usingHeader: Should inject the header at the top of the card.
    init(viewModel: CustomLabelViewModel,
         usingHeader: Bool = true) {
        self.viewModel = viewModel
        self.isUsingHeader = usingHeader
    }
}
