//
//  DigitalCrownViewFooter.swift
//  CareKitEssentials
//
//  Created by Julia Stekardis on 12/1/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

#if os(watchOS)

import CareKitStore
import CareKitUI
import os.log
import SwiftUI

public struct DigitalCrownViewFooter: CareKitEssentialView {

    @Environment(\.careStore) public var store
    @StateObject var viewModel: DigitalCrownViewModel

    @OSValue<Font>(
        values: [.watchOS: .system(size: 14)],
        defaultValue: .title
    ) private var font

    private var buttonContent: some View {
        Group {
            if viewModel.isButtonDisabled {
                HStack {
                    Text("\(loc("COMPLETED")): \(viewModel.valueForButton)")
                        .font(font)
                    Image(systemName: "checkmark")
                }
            } else {
                Text(loc("MARK_COMPLETE"))
            }
        }
        .multilineTextAlignment(.center)
    }

    public var body: some View {
        VStack {
            HStack {
                if viewModel.emojis.count > 0 {
                    Text("\(viewModel.emojis[Int(round(viewModel.valueAsDouble))])")
                        .font(.largeTitle)
                }
                Text("\(String(format: "%g", round(viewModel.valueAsDouble)))")
                    .focusable(true)
                    .digitalCrownRotation(
                        $viewModel.valueAsDouble,
                        from: viewModel.startValue,
                        through: viewModel.endValue,
                        by: viewModel.incrementValue
                    )
                    .font(.largeTitle)
                    .foregroundColor(
                        viewModel.getStoplightColor(for: viewModel.valueAsDouble)
                    )
            }
            Button(action: {
                updateValue()
            }) {
                RectangularCompletionView(isComplete: viewModel.isButtonDisabled) {
                    HStack {
                        Spacer()
						buttonContent
							.font(font)
                        Spacer()
                    }
                    .padding()
                }
            }
            .buttonStyle(NoHighlightStyle())
            .disabled(viewModel.isButtonDisabled)
        }
    }

    func updateValue() {
        Task {
            let originalOutcomeValue = viewModel.value
            // Any additional info that needs to be added to the outcome
            let newOutcomeValue = OCKOutcomeValue(originalOutcomeValue.value)

            guard let action = viewModel.action else {
                do {
                    let outcome = try await updateEvent(
                        viewModel.event,
                        with: [newOutcomeValue]
                    )
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

/// Turns off the highlighted (AKA pressed) state.
struct NoHighlightStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.contentShape(Rectangle())
    }
}

struct DigitalCrownViewFooter_Previews: PreviewProvider {
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
            DigitalCrownViewFooter(viewModel: .init(event: event))
                .environment(\.careStore, Utility.createPreviewStore())
        }
    }
}

#endif
