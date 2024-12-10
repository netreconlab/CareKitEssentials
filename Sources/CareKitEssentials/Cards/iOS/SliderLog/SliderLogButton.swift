//
//  SliderLogButton.swift
//  CareKitEssentials
//
//  Created by Dylan Li on 6/27/20.
//  Copyright © 2020 NetReconLab. All rights reserved.
//

#if !os(watchOS)

import CareKitUI
import CareKitStore
import os.log
import SwiftUI

struct SliderLogButton: CareKitEssentialView {

    @Environment(\.careStore) var careStore
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
        viewModel.previousValues.count == 0 ? loc("NO_VALUES_LOGGED") : (loc("LATEST_VALUE") + ": " + String(format: "%g", latestValue))
    }

    var latestValue: Double {
        // Best case is the latest value, middle case is initial value, worst case is 0.
        viewModel.previousValues.first ?? viewModel.initialValue.doubleValue ?? 0
    }

    var body: some View {
        VStack {
            Button(action: {
                updateValue()
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
            .disabled(viewModel.isButtonDisabled)
            .foregroundColor(!viewModel.isButtonDisabled ? .accentColor : Color.gray)
            .padding(.bottom)

            Button(action: {}) {
                Text(valueAsString)
                    .foregroundColor(.accentColor)
                    .font(Font.subheadline.weight(.medium))
            }
            .disabled(viewModel.previousValues.count == 0)
        }
        .buttonStyle(NoHighlightStyle())
    }

    func updateValue() {
        Task {
            // Any additional info that needs to be added to the outcome
            let newOutcomeValue = OCKOutcomeValue(viewModel.valueAsDouble)

            guard let action = viewModel.action else {
                do {
                    let outcome = try await updateEvent(viewModel.event, with: [newOutcomeValue])
                    viewModel.updateOutcome(outcome)
                } catch {
                    Logger.essentialView.error("Cannot update store with outcome value: \(error)")
                }
                return
            }
            do {
                let outcome = try await action(newOutcomeValue)
                viewModel.updateOutcome(outcome)
            } catch {
                Logger.essentialView.error("Cannot update store with outcome value: \(error)")
            }
        }
    }
}

struct NoHighlightStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.contentShape(Rectangle())
    }
}

#endif
