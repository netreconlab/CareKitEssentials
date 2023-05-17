//
//  CustomLabelView.swift
//  CareKitUtilities
//
//  Created by Alyssa Donawa on 9/12/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import SwiftUI

/// A custom label that can display a title, detail, or image.
/// 
/// ```
///    +----------------------------------------+
///    | +----+                                 |
///    | |icon|  Title             +-----+      |
///    | |img |  Detail            |value|      |
///    | +----+                    +-----+      |
///    +----------------------------------------+
/// ```
public struct CustomLabelView<Header: View>: View {
    @Environment(\.careKitStyle) private var style
    @StateObject var viewModel: CardViewModel

    let header: Header

    public var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                if !(header is EmptyView) {
                    VStack {
                        header
                        Divider()
                    }
                }

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

    /// Create a view using a view model.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - parameter viewModel: The view model used to populate the view contents.
    /// - parameter header: Short and descriptive content that identifies the event.
    init(viewModel: CardViewModel,
         @ViewBuilder header: () -> Header) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.header = header()
    }

    /// Create a view using data from an event.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - event: The data that appears in the view.
    ///   - header: Short and descriptive content that identifies the event.
    init(event: CareStoreFetchedResult<OCKAnyEvent>,
         @ViewBuilder header: () -> Header) {
        self.init(viewModel: .init(event: event.result),
                  header: header)
    }

}

public extension CustomLabelView where Header == InformationHeaderView {

    /// Create a view using a view model.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - parameter viewModel: The view model used to populate the view contents.
    init(viewModel: CardViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        if let informationTitle = viewModel.detailsTitle,
            let informationDetails = viewModel.detailsInformation {
            self.header = InformationHeaderView(title: Text(viewModel.event.title),
                                                event: viewModel.event,
                                                detailsTitle: informationTitle,
                                                details: informationDetails)
        } else if let informationTitle = viewModel.detailsTitle {
            self.header = InformationHeaderView(title: Text(viewModel.event.title),
                                                event: viewModel.event,
                                                detailsTitle: informationTitle)
        } else if let informationDetails = viewModel.detailsInformation {
            self.header = InformationHeaderView(title: Text(viewModel.event.title),
                                                event: viewModel.event,
                                                details: informationDetails)
        } else {
            self.header = InformationHeaderView(title: Text(viewModel.event.title),
                                                event: viewModel.event)
        }
    }

    /// Create a view using data from an event.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - event: The data that appears in the view.
    init(event: CareStoreFetchedResult<OCKAnyEvent>) {
        self.init(viewModel: .init(event: event.result))
    }

}

struct CustomLabelView_Previews: PreviewProvider {
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
            VStack {
                CustomLabelView(viewModel: .init(event: event),
                                header: EmptyView())
                    .environment(\.careStore, Utility.createPreviewStore())
                    .padding()
                CustomLabelView(viewModel: .init(event: event))
                    .environment(\.careStore, Utility.createPreviewStore())
                    .padding()
            }
        }
    }
}
