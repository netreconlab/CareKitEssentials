//
//  DigitalCrownViewFooter.swift
//  AssuageWatch
//
//  Created by Julia Stekardis on 12/1/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

#if os(watchOS)

import CareKitUI
import SwiftUI

public struct DigitalCrownViewFooter: View {

    @Environment(\.sizeCategory) private var sizeCategory
    @ObservedObject var viewModel: DigitalCrownViewModel

    @OSValue<CGFloat>(values: [.watchOS: 8],
                      defaultValue: 14) private var padding
    @OSValue<Font>(values: [.watchOS: .system(size: 13)],
                   defaultValue: .caption) private var font

    private var content: some View {
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
                Text("\(viewModel.emojis[Int(round(viewModel.valueAsDouble))])")
                    .font(.largeTitle)
                Text("\(String(format: "%g", round(viewModel.valueAsDouble)))")
                    .focusable(true)
                    .digitalCrownRotation($viewModel.valueAsDouble,
                                          from: viewModel.startValue,
                                          through: viewModel.endValue,
                                          by: viewModel.incrementValue)
                    .font(.largeTitle)
                    .foregroundColor(viewModel.getStoplightColor(for: viewModel.valueAsDouble))
            }
            Button(action: {
                Task {
                    await viewModel.updateValue(viewModel.value)
                }
            }) {
                RectangularCompletionView(isComplete: viewModel.isButtonDisabled) {
                    HStack {
                        Spacer()
                        content
                        Spacer()
                    }
                    .padding(padding.scaled())
                }
            }
            .buttonStyle(NoHighlightStyle())
            .disabled(viewModel.isButtonDisabled)
        }
        .onReceive(viewModel.$taskEvents) { taskEvents in
            /*
             Need help from view to update value since taskEvents
             can't be overriden in viewModel.
             */
            viewModel.checkIfValueShouldUpdate(taskEvents)
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

/// Turns off the highlighted (AKA pressed) state.
struct NoHighlightStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.contentShape(Rectangle())
    }
}

/*
struct DigitalCrownViewFooter: View {
    @ObservedObject var viewModel: DigitalCrownViewModel

    var body: some View {
        VStack {
            HStack {
                Text("\(viewModel.emojis[Int(round(viewModel.value))])")
                    .font(.largeTitle)
                Text("\(String(format: "%g", round(viewModel.value)))")
                    .focusable(true)
                    .digitalCrownRotation($viewModel.value,
                                          from: viewModel.startValue,
                                          through: viewModel.endValue,
                                          by: viewModel.incrementValue)
                    .font(.largeTitle)
            }
            Button("Log") {
                Task {
                    await viewModel.action(viewModel.value)
                }
            }
        }
    }
} */

struct DigitalCrownViewFooter_Previews: PreviewProvider {
    static var previews: some View {
        DigitalCrownViewFooter(viewModel: .init(taskID: "",
                                                eventQuery: .init(for: Date())))
    }
}

#endif
