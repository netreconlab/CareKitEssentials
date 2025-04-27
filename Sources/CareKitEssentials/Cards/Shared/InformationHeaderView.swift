//
//  InformationHeaderView.swift
//  CareKitEssentials
//
//  Created by Julia Stekardis on 12/6/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKitUI
import CareKitStore
import SwiftUI

/// Header used for most CareKit cards.
///
/// # Style
/// The card supports styling using `careKitStyle(_:)`.
///
/// ```
///    +----------------------------------------+
///    |                                        |
///    |  <Image> <Title>        <Info Image>   |
///    |  <Information>                         |
///    |                                        |
///    +----------------------------------------+
/// ```
public struct InformationHeaderView: View {

    // MARK: - Properties

    @Environment(\.careKitStyle) private var style
    @State var isShowingDetails = false

    private let title: Text
    private let information: Text?
    private let image: Image?
    private let event: OCKAnyEvent
    private let detailsTitle: String?
    private let details: String?
    private let includeDivider: Bool
	private let includeChevron: Bool

    @OSValue<Font>(
        values: [.watchOS: .system(size: 13)],
        defaultValue: .caption
    ) private var font

	var grayColor: Color {
		#if os(iOS) || os(visionOS)
		Color(style.color.customGray)
		#else
		Color.gray
		#endif
	}

    public var body: some View {
        VStack {
            HStack(
                spacing: style.dimension.directionalInsets2.trailing
            ) {
                image?
                    .font(.largeTitle)
                    .foregroundColor(grayColor)
                VStack(
                    alignment: .leading,
                    spacing: style.dimension.directionalInsets1.top / 4.0
                ) {
                    title
                        .font(.headline)
                        .fontWeight(.bold)

                    information?
                        .font(font)
                        .fontWeight(.medium)
                }
				#if os(iOS) || os(visionOS)
				.foregroundColor(Color(style.color.label))
				#endif
                Spacer()
				if includeChevron {
					Image(systemName: "chevron.right")
						.imageScale(.small)
						#if os(iOS) || os(visionOS)
						.foregroundColor(Color(style.color.secondaryLabel))
						#else
						.foregroundColor(Color.secondary)
						#endif
				}
            }
			if event.task.impactsAdherence {
				HStack {
					Text("Required")
						.font(font)
						.bold()
						.foregroundStyle(grayColor)
						.padding(.all, 3)
						.background(
							RoundedRectangle(cornerRadius: 4)
								.stroke()
								.foregroundStyle(grayColor)
								.shadow(
									color: grayColor,
									radius: 3
								)
						)
					Spacer()
				}
			}
            if includeDivider {
                Divider()
            }
        }
		.onTapGesture {
			isShowingDetails.toggle()
		}
        .sheet(isPresented: $isShowingDetails) {
            DetailsView(
				event: event,
				title: detailsTitle,
				details: details
			)
        }

    }

    // MARK: - Init

    /// Create an instance.
    /// - Parameters:
    ///   - title: The title text to display above the detail.
    ///   - information: The text to display below the title.
    ///   - image: Detail image to display beside the text.
    ///   - event: The event to display details for when the info button is tapped.
    ///   - detailsTitle: The title text to be displayed when the info button is tapped.
    ///   - details: The text to be displayed when the info button is tapped.
    ///   - includeDivider: Show the divider on the bottom of the header view.
	///   - includeChevron: Show the chevron on the right of the header view.
    public init(
        title: Text,
        information: Text? = nil,
        image: Image? = nil,
        event: OCKAnyEvent,
        detailsTitle: String? = nil,
        details: String? = nil,
        includeDivider: Bool = true,
		includeChevron: Bool = true
    ) {
        self.title = title
        self.information = information
        self.image = image
        self.event = event
        self.detailsTitle = detailsTitle
        self.details = details
        self.includeDivider = includeDivider
		self.includeChevron = includeChevron
    }
}

struct InformationHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
			VStack {
				InformationHeaderView(
					title: Text(event.title),
					information: Text(event.detail ?? ""),
					image: event.image(),
					event: event
				)

				InformationHeaderView(
					title: Text(event.title),
					information: Text(event.detail ?? ""),
					image: event.image(),
					event: event,
					includeDivider: false,
					includeChevron: false
				)
			}
			.careKitStyle(OCKStyle())
			.tint(.red)
			.padding()
        }
    }
}
