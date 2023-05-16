//
//  DigitalCrownView.swift
//  CareKitUtilities
//
//  Created by Julia Stekardis on 12/1/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

#if os(watchOS)

import CareKitStore
import CareKitUI
import Foundation
import SwiftUI

public struct DigitalCrownView<Header: View, Footer: View>: View {

    // MARK: - Properties

    @Environment(\.careKitStyle) private var style

    private let isHeaderPadded: Bool
    private let isFooterPadded: Bool
    private let header: Header
    private let footer: Footer

    public var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: style.dimension.directionalInsets1.top) {
                VStack { header }
                    .if(isHeaderPadded) { $0.padding([.horizontal, .top]) }
                VStack { footer }
                    .if(isHeaderPadded) { $0.padding([.horizontal, .bottom]) }
            }
        }
    }

    // MARK: - Init

    /// Create an instance.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    public init(instructions: Text? = nil,
                @ViewBuilder header: () -> Header,
                @ViewBuilder footer: () -> Footer) {
        self.init(isHeaderPadded: false,
                  isFooterPadded: false,
                  header: header,
                  footer: footer)
    }

    public init(isHeaderPadded: Bool,
                isFooterPadded: Bool,
                @ViewBuilder header: () -> Header,
                @ViewBuilder footer: () -> Footer) {
        self.isHeaderPadded = isHeaderPadded
        self.isFooterPadded = isFooterPadded
        self.header = header()
        self.footer = footer()
    }
}

public extension DigitalCrownView where Header == DigitalCrownViewHeader {

    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter event: The event to display details for when the info button is tapped.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    init(title: Text,
         detail: Text? = nil,
         event: OCKAnyEvent? = nil,
         @ViewBuilder footer: () -> Footer) {
        self.init(
            isHeaderPadded: true,
            isFooterPadded: false,
            header: { DigitalCrownViewHeader(title: title,
                                             detail: detail,
                                             event: event)
            },
            footer: footer)
    }
}

public extension DigitalCrownView where Footer == DigitalCrownViewFooter {

    /// Create an instance.
    /// - Parameter viewModel: The view model used to populate the view contents.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    init(viewModel: DigitalCrownViewModel,
         @ViewBuilder header: () -> Header) {
        self.init(isHeaderPadded: false,
                  isFooterPadded: true,
                  header: header,
                  footer: {
            DigitalCrownViewFooter(viewModel: viewModel)
        })
    }
}

public extension DigitalCrownView where Header == DigitalCrownViewHeader, Footer == DigitalCrownViewFooter {
    init(title: Text,
         detail: Text? = nil,
         viewModel: DigitalCrownViewModel) {
        self.init(isHeaderPadded: true,
                  isFooterPadded: true,
                  header: { DigitalCrownViewHeader(title: title,
                                                   detail: detail,
                                                   event: viewModel.event) },
                  footer: { DigitalCrownViewFooter(viewModel: viewModel) })
    }
}

struct DigitalCrownView_Previews: PreviewProvider {
    static let task = Utility.createNauseaTask()
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
            DigitalCrownView(title: Text(task.title!),
                             detail: Text(task.instructions!),
                             viewModel: .init(event: event))
                .environment(\.careStore, Utility.createPreviewStore())
        }
    }
}

#endif
