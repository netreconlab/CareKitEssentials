//
//  SliderLogButton.swift
//  CareKitUtilities
//
//  Created by Dylan Li on 6/27/20.
//  Copyright © 2020 NetReconLab. All rights reserved.
//

#if !os(watchOS)

import CareKitUI
import CareKitStore
import SwiftUI

struct SliderLogButton: View {

    @Environment(\.careKitStyle) private var style
    @ObservedObject var viewModel: SliderLogTaskViewModel

    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: style.appearance.cornerRadius2, style: .continuous)
    }

    var background: some View {
        shape
            .fill(Color.accentColor)
    }

    var valueAsString: String {
        // swiftlint:disable:next line_length
        viewModel.valuesArray.count == 0 ? loc("NO_VALUES_LOGGED") : (loc("LATEST_VALUE") + ": " + String(format: "%g", viewModel.valuesArray[0]))
    }

    var body: some View {
        VStack {
            Button(action: {
                Task {
                    await viewModel.action(OCKOutcomeValue(viewModel.valueAsDouble))
                }
                viewModel.isActive = false
            }) {
                HStack {
                    Spacer()

                    Text(loc("LOG"))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding([.top, .bottom])
                .clipShape(shape)
                .background(background)
                .font(Font.subheadline.weight(.medium))
                .foregroundColor(.accentColor)
            }
            .disabled(!viewModel.isActive)
            .padding(.bottom)

            Button(action: {}) {
                Text(valueAsString)
                    .foregroundColor(.accentColor)
                    .font(Font.subheadline.weight(.medium))
            }
            .disabled(viewModel.valuesArray.count == 0)
        }
        .buttonStyle(NoHighlightStyle())
    }
}

struct NoHighlightStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.contentShape(Rectangle())
    }
}

#endif
