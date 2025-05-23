//
//  CustomLabelView.swift
//  CareKitEssentials
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
    @Environment(\.isCardEnabled) private var isCardEnabled
    @StateObject var viewModel: CardViewModel
	@OSValue<Font>(
		values: [.watchOS: .system(size: 13)],
		defaultValue: .headline
	) private var font

	@OSValue<Font>(
		values: [.watchOS: .system(size: 25)],
		defaultValue: .largeTitle
	) private var labelFont

    let header: Header?

    public var body: some View {
        CardView {
            VStack(
                alignment: .leading,
                spacing: style.dimension.directionalInsets1.top
            ) {
                header
                HStack(spacing: style.dimension.directionalInsets2.trailing) {

                    viewModel.event.image()?
						.imageScale(.large)
						.foregroundColor(Color.accentColor)
						.padding()

                    VStack(alignment: .leading,
                           spacing: style.dimension.directionalInsets2.bottom) {
                        if let detail = viewModel.event.instructions {
                            Text(detail)
                                .font(font)
                                .fontWeight(.medium)
                        }
                    }
					#if os(iOS) || os(visionOS)
					.foregroundColor(Color(style.color.label))
					#endif
                    Spacer()
                    Text(viewModel.valueAsString)
                        .font(labelFont)
                        .bold()
                        .foregroundColor(Color.accentColor)
                }
            }
            .padding(isCardEnabled ? [.all] : [])
        }
    }
}

public extension CustomLabelView {

    /// Create a view using a view model.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - viewModel: The view model used to populate the view contents.
    init(
        viewModel: CardViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.header = nil
    }

    /// Create a view using a view model.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - viewModel: The view model used to populate the view contents.
    ///   -  header: Short and descriptive content that identifies the event.
    init(
        viewModel: CardViewModel,
        @ViewBuilder header: () -> Header
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.header = header()
    }

    /// Create a view using data from an event.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - event: The data that appears in the view.
    ///   - initialValue: The default outcome value for the view model. Defaults to 0.0.
    ///   - detailsTitle: An optional title for the event.
    ///   - detailsInformation: An optional detailed information string for the event.
    ///   - action: The action to take when event is completed.
    ///   - header: Short and descriptive content that identifies the event.

    init(
        event: CareStoreFetchedResult<OCKAnyEvent>,
        initialValue: OCKOutcomeValue = OCKOutcomeValue(0.0),
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil,
        @ViewBuilder header: () -> Header) {
            self.init(
                viewModel: .init(
                    event: event.result,
                    initialValue: initialValue,
                    detailsTitle: detailsTitle,
                    detailsInformation: detailsInformation,
                    action: action
                ),
                header: header
            )
        }
}

public extension CustomLabelView where Header == InformationHeaderView {

    /// Create a view using data from a view model.
    ///
    /// This view displays custom label card with title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - viewModel: The view model used to populate the view contents.
    init(viewModel: CardViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        if let informationTitle = viewModel.detailsTitle,
            let informationDetails = viewModel.detailsInformation {
            self.header = InformationHeaderView(
                title: Text(viewModel.event.title),
                event: viewModel.event,
                detailsTitle: informationTitle,
                details: informationDetails
            )
        } else if let informationTitle = viewModel.detailsTitle {
            self.header = InformationHeaderView(
                title: Text(viewModel.event.title),
                event: viewModel.event,
                detailsTitle: informationTitle
            )
        } else if let informationDetails = viewModel.detailsInformation {
            self.header = InformationHeaderView(
                title: Text(viewModel.event.title),
                event: viewModel.event,
                details: informationDetails
            )
        } else {
            self.header = InformationHeaderView(
                title: Text(viewModel.event.title),
                event: viewModel.event
            )
        }
    }

    /// Create a view using data from an event.
    ///
    /// This view displays custom label card with title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - event: The data that appears in the view.
    ///   - initialValue: The default outcome value for the view model. Defaults to 0.0.
    ///   - detailsTitle: An optional title for the event.
    ///   - detailsInformation: An optional detailed information string for the event.
    ///   - action: The action to take when event is completed.
    init(
        event: OCKAnyEvent,
        initialValue: OCKOutcomeValue = OCKOutcomeValue(0.0),
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil
    ) {
        self.init(
            viewModel: .init(
                event: event,
                initialValue: initialValue,
                detailsTitle: detailsTitle,
                detailsInformation: detailsInformation,
                action: action
            )
        )
    }
}

struct CustomLabelView_Previews: PreviewProvider {
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
            ScrollView {
                CustomLabelView(
                    viewModel: .init(
                        event: event
                    )
                )
                .padding()
                CustomLabelView(
                    viewModel: .init(
                        event: event
                    )
                )
                .padding()
            }
            .environment(\.careStore, Utility.createPreviewStore())
            .careKitStyle(OCKStyle())
        }
    }
}
