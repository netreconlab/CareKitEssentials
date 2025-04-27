//
//  Slider.swift
//  CareKitEssentials
//
//  Created by Dylan Li on 6/22/20.
//  Copyright © 2020 NetReconLab. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

struct Slider: View {

    @Environment(\.careKitStyle) private var style
    @ObservedObject private var viewModel: SliderLogTaskViewModel

    private let range: (Double, Double)
    private let minimumImage: Image?
    private let maximumImage: Image?
    fileprivate let minimumDescription: String?
    fileprivate let maximumDescription: String?
    private let sliderHeight: CGFloat?
    private let frameHeight: CGFloat
    private let cornerRadius: CGFloat?
    private let gradientColors: [Color]?
    private let borderWidth: CGFloat = 1
    private let valueFontSize: CGFloat = 25
    private let boundsFontSize: CGFloat = 10
    private let usesSystemSlider: Bool
    private var containsImages: Bool { (minimumImage == nil && maximumImage == nil) ? false : true }

    init(viewModel: SliderLogTaskViewModel,
         minimumImage: Image?,
         maximumImage: Image?,
         minimumDescription: String?,
         maximumDescription: String?,
         style: SliderStyle,
         gradientColors: [Color]? = nil) {
        self.viewModel = viewModel
        self.range = (viewModel.range.lowerBound, viewModel.range.upperBound)
        self.minimumImage = minimumImage
        self.maximumImage = maximumImage
        self.minimumDescription = minimumDescription
        self.maximumDescription = maximumDescription
        self.gradientColors = gradientColors
        switch style {
        case .ticked:
            self.sliderHeight = 40
            self.frameHeight = 100
            self.cornerRadius = 15
            self.usesSystemSlider = false
        case .system:
            self.sliderHeight = nil
            self.frameHeight = 90
            self.cornerRadius = nil
            self.usesSystemSlider = true
        }
    }

    var minString: String {
        // swiftlint:disable:next line_length
        minimumDescription == nil ? String(format: "%g", range.0) : String(format: "%g", range.0) + ": " + minimumDescription!
    }

    var maxString: String {
        // swiftlint:disable:next line_length
        maximumDescription == nil ? String(format: "%g", range.1) : String(format: "%g", range.1) + ": " + maximumDescription!
    }

	var grayColor: Color {
		Color(style.color.customGray)
	}

    public var body: some View {
        GeometryReader { geometry in
            view(geometry: geometry)
        }
        .frame(height: frameHeight)
    }

    private func view(geometry: GeometryProxy) -> some View {
        let frameWidth = geometry.size.width
        let imageWidth = (frameWidth / 10).rounded()
        let view = VStack(spacing: 0) {
                Text(String(format: "%g", viewModel.valueAsDouble))
                    .font(.system(size: valueFontSize))
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                    .disabled(viewModel.isButtonDisabled)

                HStack(spacing: 0) {
                    minimumImage?
                        .sliderImageModifier(width: imageWidth,
                                             height: usesSystemSlider ? imageWidth : sliderHeight!)

                    Spacer(minLength: 0)

                    slider(frameWidth: frameWidth, imageWidth: imageWidth)

                    Spacer(minLength: 0)

                    maximumImage?
                        .sliderImageModifier(width: imageWidth,
                                             height: usesSystemSlider ? imageWidth : sliderHeight!)
                }
                .padding(.bottom, 5)

                HStack {
                    if containsImages {
                        Spacer()
                            .frame(width: imageWidth + 8)
                    }

                    Text(minString)
                        .font(.system(size: boundsFontSize))

                    Spacer()

                    Text(maxString)
                        .font(.system(size: boundsFontSize))

                    if containsImages {
                        Spacer()
                            .frame(width: imageWidth + 8)
                    }
                }
            }
        return view
    }

    private func slider(frameWidth: CGFloat, imageWidth: CGFloat) -> some View {
        let sliderWidth = containsImages ? frameWidth - imageWidth * 2 - imageWidth / 2 : frameWidth
        let drag = DragGesture(minimumDistance: 0)
        return
            usesSystemSlider ?
            ViewBuilder.buildEither(
                first: systemSliderView()
                    .gesture(
                        drag.onChanged({ drag in
                            onDragChange(drag, sliderWidth: sliderWidth)
                        })
                    )
                    .frame(width: sliderWidth, height: imageWidth)) :
            ViewBuilder.buildEither(
                second: ZStack {
                    fillerBarView(width: sliderWidth, height: sliderHeight!)
                        .gesture(
                            drag.onChanged({ drag in
                                onDragChange(drag, sliderWidth: sliderWidth)
                            })
                        )
                    addTicks(sliderWidth: sliderWidth)
                        .if(viewModel.isButtonDisabled) {
                            $0.accentColor(grayColor)
                        }
                }
                .frame(width: sliderWidth, height: sliderHeight)
            )
    }

    private func systemSliderView() -> some View {
        ZStack {
            if gradientColors != nil {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(!viewModel.isButtonDisabled ?
                                    LinearGradient(gradient: Gradient(colors: gradientColors ?? []),
                                                   startPoint: .leading,
                                                   endPoint: .trailing) :
                                    LinearGradient(gradient: Gradient(colors: [grayColor]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                    .mask(SwiftUI.Slider(value: $viewModel.valueAsDouble, in: range.0...range.1))
            }

            SwiftUI.Slider(value: $viewModel.valueAsDouble, in: range.0...range.1, step: viewModel.step)
                .if(gradientColors == nil) {
                    $0.accentColor(!viewModel.isButtonDisabled ? .accentColor : grayColor)
                }
                .if(gradientColors != nil) {
                    $0.accentColor(.clear)
                }
        }
    }

    private func fillerBarView(width: CGFloat, height: CGFloat) -> some View {
        let offsetX = getOffsetX(sliderWidth: width)
        let barLeftSize = CGSize(width: width, height: height)
        let barRightSize = CGSize(width: CGFloat(offsetX), height: height)
        let barLeft = Rectangle()
            .if(gradientColors == nil) {
                $0.foregroundColor(
                    !viewModel.isButtonDisabled ? .accentColor : grayColor
                )
            }
            .if(gradientColors != nil) {
                $0
                    .foregroundColor(.clear)
                    .background(
                        !viewModel.isButtonDisabled ?
                        LinearGradient(
                            gradient: Gradient(
                                colors: gradientColors ?? []
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(
                                colors: [grayColor]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
		let barRight = Color(style.color.white)
        return
            ZStack {
                barLeft.modifier(
                    SliderModifier(
                        sliderWidth: width,
                        size: barLeftSize,
                        radius: cornerRadius!
                    )
                )
                barRight
                    .modifier(
                        SliderModifier(
                            sliderWidth: width,
                            size: barRightSize,
                            radius: cornerRadius!
                        )
                    )
                RoundedRectangle(
                    cornerRadius: cornerRadius!
                )
                .stroke(
					grayColor,
                    lineWidth: borderWidth
                )
            }
    }

    private func addTicks(sliderWidth: CGFloat) -> some View {
        var values = [Double]()
        var possibleValue = range.0 + viewModel.step
        while possibleValue < range.1 {
            values.append(possibleValue)
            possibleValue += viewModel.step
        }
        let spacing = (sliderWidth * 0.8) / CGFloat(values.count - 1) - borderWidth
        return
            HStack(spacing: spacing) {
                ForEach(values, id: \.self) { value in
                    SliderTickMark(sliderValue: $viewModel.valueAsDouble,
                                   value: value,
                                   values: values,
                                   sliderHeight: sliderHeight!,
                                   width: borderWidth)
                }
            }
            .frame(height: sliderHeight!)
    }

    private func onDragChange(_ drag: DragGesture.Value, sliderWidth: CGFloat) {
        let xrange = (min: Double(0), max: Double(sliderWidth))
        var dragValue = Double(drag.startLocation.x + drag.translation.width)
        dragValue = dragValue > xrange.max ? xrange.max : dragValue
        dragValue = dragValue < xrange.min ? xrange.min : dragValue
        dragValue = dragValue.convert(fromRange: (xrange.min, xrange.max), toRange: (range.0, range.1))
        dragValue = round(dragValue / viewModel.step) * viewModel.step
        self.viewModel.valueAsDouble = dragValue
    }

    private func getOffsetX(sliderWidth: CGFloat) -> CGFloat {
        let xrange = (Double(0), Double(sliderWidth))
        var result = self.viewModel.valueAsDouble.convert(fromRange: (range.0, range.1),
                                                          toRange: xrange)
        result = Double(sliderWidth) - result
        return CGFloat(result)
    }
}

private struct SliderTickMark: View {

    @Environment(\.careKitStyle) private var style
    @Binding var sliderValue: Double
    private let value: Double
    private let sliderHeight: CGFloat
    private let width: CGFloat
    private var color: Color {
        value > sliderValue ? grayColor : value == sliderValue ? .clear : Color(style.color.white)
    }

    public init(sliderValue: Binding<Double>,
                value: Double,
                values: [Double],
                sliderHeight: CGFloat,
                width: CGFloat) {
        _sliderValue = sliderValue
        self.value = value
        self.sliderHeight = sliderHeight
        self.width = width
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: sliderHeight)
    }

	var grayColor: Color {
		Color(style.color.customGray)
	}
}

private struct SliderModifier: ViewModifier {
    let sliderWidth: CGFloat
    let size: CGSize
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: size.width)
            .position(x: sliderWidth - size.width * 0.5, y: size.height * 0.5)
            .cornerRadius(radius)
    }
}

private extension Image {
    func sliderImageModifier(width: CGFloat, height: CGFloat) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
}

#endif
