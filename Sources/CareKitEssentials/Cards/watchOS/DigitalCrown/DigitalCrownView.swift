//
//  DigitalCrownView.swift
//  CareKitEssentials
//
//  Created by Julia Stekardis on 12/1/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

// swiftlint:disable vertical_parameter_alignment
#if os(watchOS)

import CareKit
import CareKitStore
import CareKitUI
import Foundation
import SwiftUI

public struct DigitalCrownView<Header: View, Footer: View>: View {

    // MARK: - Properties

    @Environment(\.careKitStyle) private var style
    @Environment(\.isCardEnabled) private var isCardEnabled

    private let isHeaderPadded: Bool
    private let isFooterPadded: Bool
    private let header: Header
    private let footer: Footer

    public var body: some View {
        CardView {
            VStack(
                alignment: .leading,
                spacing: style.dimension.directionalInsets1.top
            ) {
                header
                    .if(isHeaderPadded) {
                        $0.padding([.horizontal, .top])
                    }

                footer
                    .if(isHeaderPadded) {
                        $0.padding([.horizontal, .bottom])
                    }
            }
            .padding(isCardEnabled ? [.all] : [])
        }
    }

    init(
        isHeaderPadded: Bool,
        isFooterPadded: Bool,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.isHeaderPadded = isHeaderPadded
        self.isFooterPadded = isFooterPadded
        self.header = header()
        self.footer = footer()
    }
}

// MARK: - Public Init

public extension DigitalCrownView {

    /// Create an instance.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    init(
        instructions: Text? = nil,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            isHeaderPadded: false,
            isFooterPadded: false,
            header: header,
            footer: footer
        )
    }
}

public extension DigitalCrownView where Header == DigitalCrownViewHeader {

    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter event: The event to display details for when the info button is tapped.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    init(
        title: Text,
        detail: Text? = nil,
        event: OCKAnyEvent? = nil,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            isHeaderPadded: true,
            isFooterPadded: false,
            header: {
                DigitalCrownViewHeader(
                    title: title,
                    detail: detail,
                    event: event
                )
            },
            footer: footer
        )
    }
}

public extension DigitalCrownView where Footer == DigitalCrownViewFooter {

    /// Create an instance.
    /// - Parameter viewModel: The view model used to populate the view contents.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    init(
        viewModel: DigitalCrownViewModel,
        @ViewBuilder header: () -> Header
    ) {
        self.init(
            isHeaderPadded: false,
            isFooterPadded: true,
            header: header,
            footer: {
                DigitalCrownViewFooter(viewModel: viewModel)
            }
        )
    }

    /// Create a view using data from an event.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - event: The data that appears in the view.
    ///   - kind: An optional property that can be used to specify what kind of values the
    ///   outcome values are (e.g. blood pressure, qualitative stress, weight).
    ///   - detailsTitle: An optional title for the event.
    ///   - detailsInformation: An optional detailed information string for the event.
    ///   - initialValue: The initial value shown for the digital crown.
    ///   - startValue: The minimum possible value.
    ///   - endValue: The maximum possible value.
    ///   - incrementValue: The step amount.
    ///   - emojis: An array of emoji's to show on the screen.
    ///   - colorRatio: The ratio effect on the color gradient.
    ///   - action: The action to perform when the log button is tapped.
    ///   - header: Short and descriptive content that identifies the event.
    init(
        event: OCKAnyEvent,
        kind: String? = nil,
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        initialValue: Double? = nil,
        startValue: Double = 0,
        endValue: Double? = nil,
        incrementValue: Double = 1,
        emojis: [String] = [],
        colorRatio: Double = 0.2,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil,
        @ViewBuilder header: () -> Header
    ) {
        let viewModel = DigitalCrownViewModel(
            event: event,
            kind: kind,
            detailsTitle: detailsTitle,
            detailsInformation: detailsInformation,
            initialValue: initialValue,
            startValue: startValue,
            endValue: endValue,
            incrementValue: incrementValue,
            emojis: emojis,
            colorRatio: colorRatio,
            action: action
        )
        self.init(
            viewModel: viewModel,
            header: header
        )
    }

}

public extension DigitalCrownView where Header == DigitalCrownViewHeader, Footer == DigitalCrownViewFooter {
    init(
        title: Text,
        detail: Text? = nil,
        viewModel: DigitalCrownViewModel
    ) {
        self.init(
            isHeaderPadded: true,
            isFooterPadded: true,
            header: {
                DigitalCrownViewHeader(
                    title: title,
                    detail: detail,
                    event: viewModel.event
                )
            },
            footer: {
                DigitalCrownViewFooter(viewModel: viewModel)
            }
        )
    }

    /// Create a view using data from an event.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - event: The data that appears in the view.
    ///   - detailsTitle: An optional title for the event.
    ///   - detailsInformation: An optional detailed information string for the event.
    ///   - initialValue: The initial value shown for the digital crown.
    ///   - startValue: The minimum possible value.
    ///   - endValue: The maximum possible value.
    ///   - incrementValue: The step amount.
    ///   - emojis: An array of emoji's to show on the screen.
    ///   - colorRatio: The ratio effect on the color gradient.
    ///   - action: The action to perform when the log button is tapped.
    init(
        event: OCKAnyEvent,
		kind: String? = nil,
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        initialValue: Double? = nil,
        startValue: Double = 0,
        endValue: Double? = nil,
        incrementValue: Double = 1,
        emojis: [String] = [],
        colorRatio: Double = 0.2,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil
    ) {
        let event = event
        let viewModel = DigitalCrownViewModel(
            event: event,
			kind: kind,
            detailsTitle: detailsTitle,
            detailsInformation: detailsInformation,
            initialValue: initialValue,
            startValue: startValue,
            endValue: endValue,
            incrementValue: incrementValue,
            emojis: emojis,
            colorRatio: colorRatio,
            action: action
        )
        let title = detailsTitle != nil ?
            Text(detailsTitle!) : Text(event.title)
        let detail = detailsInformation != nil ?
            Text(detailsInformation!) : Text(event.detail ?? "")
        self.init(
            isHeaderPadded: true,
            isFooterPadded: true,
            header: {
                DigitalCrownViewHeader(
                    title: title,
                    detail: detail,
                    event: event
                )
            },
            footer: {
                DigitalCrownViewFooter(
                    viewModel: viewModel
                )
            }
        )
    }
}

struct DigitalCrownView_Previews: PreviewProvider {
    static let emojis = ["😄", "🙂", "😐", "😕", "😟", "☹️", "😞", "😓", "😥", "😰", "🤯"]
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
			VStack {
				DigitalCrownView(
					title: Text(event.task.title ?? ""),
					detail: Text(event.task.instructions ?? ""),
					viewModel: .init(
						event: event,
						emojis: emojis
					)
				)
				.padding()
			}
            .environment(\.careStore, Utility.createPreviewStore())
            .careKitStyle(OCKStyle())
        }
    }
}

#endif
