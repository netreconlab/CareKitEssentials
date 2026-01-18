//
//  SliderLogTaskView.swift
//  CareKitEssentials
//
//  Created by Dylan Li on 6/2/20.
//  Copyright © 2020 NetReconLab. All rights reserved.
//

#if canImport(SwiftUI) && !os(watchOS)

import Foundation
import CareKit
import CareKitUI
import CareKitStore
import SwiftUI

/// A card that displays a header view, multi-line label, a slider, and a completion button.
///
/// In CareKit, this view is intended to display a particular event for a task.
/// The state of the button indicates the completion state of the event.
///
/// # Style
/// The card supports styling using `careKitStyle(_:)`.
///
/// ```
///     +-------------------------------------------------------+
///     |                                                       |
///     |  <Image> <Title>                       <Info Image>   |
///     |  <Information>                                        |
///     |                                                       |
///     |  --------------------------------------------------   |
///     |                                                       |
///     |  <Instructions>                                       |
///     |                                                       |
///     |  <Min Image> –––––––––––––O–––––––––––– <Max Image>   |
///     |             <Min Desc>        <Max Desc>              |
///     |                                                       |
///     |  +-------------------------------------------------+  |
///     |  |                      <Log>                      |  |
///     |  +-------------------------------------------------+  |
///     |                                                       |
///     |                   <Latest Value: >                    |
///     |                                                       |
///     +-------------------------------------------------------+
/// ```
/// - Note: You should use `SliderLogView` to take advantage of a working
/// implementation of this view.
public struct SliderLogTaskView<Header: View, Slider: View>: View {

    // MARK: - Properties
    @Environment(\.careKitStyle) private var style
    @Environment(\.isCardEnabled) private var isCardEnabled

    @StateObject private var viewModel: SliderLogTaskViewModel
    private let isHeaderPadded: Bool
    private let isSliderPadded: Bool
    private let header: Header
    private let slider: Slider
    private let instructions: Text?

    public var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: style.dimension.directionalInsets1.top) {
                header
                    .if(isCardEnabled && isHeaderPadded) {
                        $0.padding([.horizontal, .top])
                    }

                instructions?
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(nil)
                    .if(isCardEnabled) { $0.padding([.horizontal]) }

                VStack { slider }
                    .if(isCardEnabled && isSliderPadded) {
                        $0.padding([.horizontal, .bottom])
                    }
            }
        }
    }

    init(
        isHeaderPadded: Bool,
        isSliderPadded: Bool,
        instructions: Text?,
        viewModel: SliderLogTaskViewModel,
        @ViewBuilder header: () -> Header,
        @ViewBuilder slider: () -> Slider
    ) {
        self.isHeaderPadded = isHeaderPadded
        self.isSliderPadded = isSliderPadded
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.instructions = instructions
        self.header = header()
        self.slider = slider()
    }
}

// MARK: - Public Init

public extension SliderLogTaskView {

    /// Create an instance.
    /// - parameter instructions: Instructions text to display under the header.
    /// - parameter viewModel: The view model used to populate the view contents.
    /// - parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    /// - parameter slider: View to inject under the header. Specified content will be stacked vertically.
    init(
        instructions: Text? = nil,
        viewModel: SliderLogTaskViewModel,
        @ViewBuilder header: () -> Header,
        @ViewBuilder slider: () -> Slider
    ) {
        self.init(
            isHeaderPadded: false,
            isSliderPadded: false,
            instructions: instructions,
            viewModel: viewModel,
            header: header,
            slider: slider
        )
    }

    /// Create a view using a view model.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - parameter instructions: Instructions text to display under the header.
    /// - parameter event: The data that appears in the view.
    /// - parameter kind: An optional property that can be used to specify what kind of value this
    /// is (e.g. blood pressure, qualitative stress, weight).
    /// - parameter detailsTitle: An optional title for the event.
    /// - parameter detailsInformation: An optional detailed information string for the event.
    /// - parameter range: The range that includes all possible values.
    /// - parameter step: Value of the increment that the slider takes. Default value is 1.
    /// - parameter action: The action to perform when the button is tapped. Defaults to saving the outcome directly.
    /// - parameter header: Short and descriptive content that identifies the event.
    /// - parameter slider: View to inject under the header. Specified content will be stacked vertically.
    init(
        instructions: Text? = nil,
        event: OCKAnyEvent,
        kind: String? = nil,
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        range: ClosedRange<Double>,
        step: Double = 1,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil,
        @ViewBuilder header: () -> Header,
        @ViewBuilder slider: () -> Slider
    ) {
        self.init(
            isHeaderPadded: false,
            isSliderPadded: false,
            instructions: instructions,
            viewModel: .init(
                event: event,
                kind: kind,
                detailsTitle: detailsTitle,
                detailsInformation: detailsInformation,
                range: range,
                step: step,
                action: action
            ),
            header: header,
            slider: slider
        )
    }

}

public extension SliderLogTaskView where Header == InformationHeaderView {

    /// Create an instance.
    /// - parameter title: Title text to display in the header.
    /// - parameter detail: Detail text to display in the header.
    /// - parameter instructions: Instructions text to display under the header.
    /// - parameter viewModel: The view model used to populate the view contents.
    /// - parameter slider: View to inject under the header. Specified content will be stacked vertically.
    init(
        title: Text,
        detail: Text? = nil,
        instructions: Text? = nil,
        viewModel: SliderLogTaskViewModel,
        @ViewBuilder slider: () -> Slider
    ) {
        self.init(
            isHeaderPadded: true,
            isSliderPadded: false,
            instructions: instructions,
            viewModel: viewModel,
            header: {
                InformationHeaderView(
                    title: title,
                    information: detail,
                    event: viewModel.event
                )
            },
            slider: slider
        )
    }
}

public extension SliderLogTaskView where Slider == _SliderLogTaskViewSlider {

    /// Create an instance.
    /// - parameter instructions: Instructions text to display under the header.
    /// - parameter viewModel: The view model used to populate the view contents.
    /// - parameter minimumImage: Image to display to the left of the slider. Default value is nil.
    /// - parameter maximumImage: Image to display to the right of the slider. Default value is nil.
    /// - parameter minimumDescription: Description to display next to lower bound value. Default value is nil.
    /// - parameter maximumDescription: Description to display next to upper bound value. Default value is nil.
    /// - parameter style: The style of the slider, either the SwiftUI system slider or the custom bar slider.
    /// - parameter gradientColors: The colors to use when drawing a color gradient inside the slider. Colors
    /// are drawn such that lower indexes correspond to the minimum side of the scale, while colors at higher indexes in
    /// the array correspond to the maximum side of the scale. Setting this value to nil results in no gradient
    /// being drawn. Defaults to nil. An example usage would set an array of red and green to visually indicate a
    /// scale from bad to good.
    /// - parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    init(
        instructions: Text? = nil,
        viewModel: SliderLogTaskViewModel,
        minimumImage: Image? = nil,
        maximumImage: Image? = nil,
        minimumDescription: String? = nil,
        maximumDescription: String? = nil,
        style: SliderStyle = .ticked,
        gradientColors: [Color]? = nil,
        @ViewBuilder header: () -> Header
    ) {
        self.init(
            isHeaderPadded: false,
            isSliderPadded: true,
            instructions: instructions,
            viewModel: viewModel,
            header: header,
            slider: {
                _SliderLogTaskViewSlider(
                    viewModel: viewModel,
                    minimumImage: minimumImage,
                    maximumImage: maximumImage,
                    minimumDescription: minimumDescription,
                    maximumDescription: maximumDescription,
                    style: style,
                    gradientColors: gradientColors
                )
            }
        )
    }
}

public extension SliderLogTaskView where Header == InformationHeaderView, Slider == _SliderLogTaskViewSlider {

    /// Create an instance.
    /// - parameter title: Title text to display in the header.
    /// - parameter detail: Detail text to display in the header.
    /// - parameter instructions: Instructions text to display under the header.
    /// - parameter viewModel: The view model used to populate the view contents.
    /// - parameter minimumImage: Image to display to the left of the slider. Default value is nil.
    /// - parameter maximumImage: Image to display to the right of the slider. Default value is nil.
    /// - parameter minimumDescription: Description to display next to lower bound value. Default value is nil.
    /// - parameter maximumDescription: Description to display next to upper bound value. Default value is nil.
    /// - parameter style: The style of the slider, either the SwiftUI system slider or the custom bar slider.
    /// - parameter gradientColors: The colors to use when drawing a color gradient inside the slider.
    /// Colors are drawn such that lower indexes correspond to the minimum side of the scale, while colors at higher
    /// indexes in the array correspond to the maximum side of the scale. Setting this value to nil results in no
    /// gradient being drawn. Defaults to nil. An example usage would set an array of red and green to visually
    /// indicate a scale from bad to good.
    init(
        title: Text,
        detail: Text? = nil,
        instructions: Text? = nil,
        viewModel: SliderLogTaskViewModel,
        minimumImage: Image? = nil,
        maximumImage: Image? = nil,
        minimumDescription: String? = nil,
        maximumDescription: String? = nil,
        style: SliderStyle = .ticked,
        gradientColors: [Color]? = nil
    ) {
        self.init(
            isHeaderPadded: true,
            isSliderPadded: true,
            instructions: instructions,
            viewModel: viewModel,
            header: {
                InformationHeaderView(
                    title: title,
                    information: detail,
                    event: viewModel.event
                )
            },
            slider: {
                _SliderLogTaskViewSlider(
                    viewModel: viewModel,
                    minimumImage: minimumImage,
                    maximumImage: maximumImage,
                    minimumDescription: minimumDescription,
                    maximumDescription: maximumDescription,
                    style: style,
                    gradientColors: gradientColors
                )
            }
        )
    }

    /// Create a view using data from an event.
    ///
    /// This view displays custom label card with  title, detail, and/or image.
    ///
    /// - Parameters:
    ///   - title: Title text to display in the header.
    ///   - detail: Detail text to display in the header.
    ///   - instructions: Instructions text to display under the header.
    ///   - event: The data that appears in the view.
    ///   - detailsTitle: An optional title for the event.
    ///   - detailsInformation: An optional detailed information string for the event.
    ///   - initialValue: The initial value shown on the slider.
    ///   - range: The range that includes all possible values.
    ///   - step: Value of the increment that the slider takes. Default value is 1.
    ///   - action: The action to perform when the button is tapped. Defaults to saving the outcome directly.
    ///   - minimumImage: Image to display to the left of the slider. Default value is nil.
    ///   - maximumImage: Image to display to the right of the slider. Default value is nil.
    ///   - minimumDescription: Description to display next to lower bound value. Default value is nil.
    ///   - maximumDescription: Description to display next to upper bound value. Default value is nil.
    ///   - style: The style of the slider, either the SwiftUI system slider or the custom bar slider.
    ///   - gradientColors: The colors to use when drawing a color gradient inside the slider.
    /// Colors are drawn such that lower indexes correspond to the minimum side of the scale, while colors at higher
    /// indexes in the array correspond to the maximum side of the scale. Setting this value to nil results in no
    /// gradient being drawn. Defaults to nil. An example usage would set an array of red and green to visually
    /// indicate a scale from bad to good.
    init(
        title: Text,
        detail: Text? = nil,
        instructions: Text? = nil,
        event: OCKAnyEvent,
        detailsTitle: String? = nil,
        detailsInformation: String? = nil,
        initialValue: Double? = 0,
        range: ClosedRange<Double>,
        step: Double = 1,
        action: ((OCKOutcomeValue?) async throws -> OCKAnyOutcome)? = nil,
        minimumImage: Image? = nil,
        maximumImage: Image? = nil,
        minimumDescription: String? = nil,
        maximumDescription: String? = nil,
        style: SliderStyle = .ticked,
        gradientColors: [Color]? = nil
    ) {
        let viewModel = SliderLogTaskViewModel(
            event: event,
            detailsTitle: detailsTitle,
            detailsInformation: detailsInformation,
            initialValue: initialValue,
            range: range,
            step: step,
            action: action
        )
        self.init(
            title: title,
            detail: detail,
            instructions: instructions,
            viewModel: viewModel,
            minimumImage: minimumImage,
            maximumImage: maximumImage,
            minimumDescription: minimumDescription,
            maximumDescription: maximumDescription,
            style: style,
            gradientColors: gradientColors
        )
    }
}

/// The default slider view used by an `SliderTaskView`.
public struct _SliderLogTaskViewSlider: View { // swiftlint:disable:this type_name

    @ObservedObject fileprivate var viewModel: SliderLogTaskViewModel
    fileprivate let minimumImage: Image?
    fileprivate let maximumImage: Image?
    fileprivate let minimumDescription: String?
    fileprivate let maximumDescription: String?
    fileprivate let style: SliderStyle
    fileprivate let gradientColors: [Color]?

    init(
        viewModel: SliderLogTaskViewModel,
        minimumImage: Image?,
        maximumImage: Image?,
        minimumDescription: String?,
        maximumDescription: String?,
        style: SliderStyle,
        gradientColors: [Color]?
    ) {
        self.viewModel = viewModel
        self.minimumImage = minimumImage
        self.maximumImage = maximumImage
        self.minimumDescription = minimumDescription
        self.maximumDescription = maximumDescription
        self.style = style
        self.gradientColors = gradientColors
    }

    public var body: some View {
        VStack {
            Slider(
                viewModel: viewModel,
                minimumImage: minimumImage,
                maximumImage: maximumImage,
                minimumDescription: minimumDescription,
                maximumDescription: maximumDescription,
                style: style,
                gradientColors: gradientColors
            )
            SliderLogButton(
                viewModel: viewModel
            )
        }
    }
}

struct SliderLogTaskView_Previews: PreviewProvider {
    static let store = Utility.createPreviewStore()

    static var previews: some View {
        VStack {
            if let event = try? Utility.createNauseaEvent() {
                let viewModel = SliderLogTaskViewModel(
                    event: event,
                    range: 0...10
                )
                SliderLogTaskView(
                    title: Text(event.title),
                    detail: Text(event.detail ?? ""),
                    viewModel: viewModel,
                    gradientColors: [.green, .yellow, .red]
                )
                Divider()
                SliderLogTaskView(
                    title: Text(event.title),
                    detail: Text(event.detail ?? ""),
                    viewModel: viewModel,
                    style: .system,
                    gradientColors: [.green, .yellow, .red]
                )
            }
        }
        .environment(\.careStore, store)
        .careKitStyle(OCKStyle())
        .padding()
    }
}

#endif
