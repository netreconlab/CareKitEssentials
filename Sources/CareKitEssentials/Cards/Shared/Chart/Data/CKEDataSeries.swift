//
//  CKEDataSeries.swift
//  CareKitEssentials
//
//  Created by Alyssa Donawa on 6/11/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKitStore
import Charts
import Foundation
import SwiftUI

// swiftlint:disable vertical_parameter_alignment

/// Represents a single group of data to be plotted. In most cases, CareKitEssentials plots accept multiple data
/// series, allowing for for several data series to be plotted on a single axis for easy comparison.
public struct CKEDataSeries: Identifiable, Hashable {

	/// An enumerator specifying the types of plots that can be used to display data series.
	@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
	public enum PlotType: String, CaseIterable, Hashable {
		case area
		case line

		@ChartContentBuilder
		func chartContent( // swiftlint:disable:this function_parameter_count
			title: String,
			xLabel: String,
			yLabel: String,
			yEndLabel: String? = nil,
			tLabel: String? = nil,
			domain: ClosedRange<Double>? = nil,
			function: (@Sendable (Double) -> Double)?,
			parametricFunction: (@Sendable (Double) -> (x: Double, y: Double))?,
			areaParametricFunction: (@Sendable (Double) -> (yStart: Double, yEnd: Double))?
		) throws -> some ChartContent {
			switch self {
			case .area:
				if let yEndLabel = yEndLabel,
				   let areaParametricFunction = areaParametricFunction {
					AreaPlot(
						x: xLabel,
						yStart: yLabel,
						yEnd: yEndLabel,
						domain: domain,
						function: areaParametricFunction
					)
				} else if let function {
					AreaPlot(
						x: xLabel,
						y: yLabel,
						domain: domain,
						function: function
					)
				} else {
					throw CareKitEssentialsError.couldntUnwrapRequiredField
				}
			case .line:
				if let tLabel = tLabel,
				   let domain,
				   let parametricFunction {
					LinePlot(
						x: xLabel,
						y: yLabel,
						t: tLabel,
						domain: domain,
						function: parametricFunction
					)
				} else if let function {
					LinePlot(
						x: xLabel,
						y: yLabel,
						domain: domain,
						function: function
					)
				} else {
					throw CareKitEssentialsError.couldntUnwrapRequiredField
				}
			}
		}

	}

    /// An enumerator specifying the types of marks that can be used to display data series.
    public enum MarkType: String, CaseIterable, Hashable {
        case area
        case bar
        case line
        case point
        case rectangle
		case scatter

        @ChartContentBuilder
        func chartContent<ValueY>( // swiftlint:disable:this function_parameter_count
            xLabel: String,
            xValue: Date,
			xValueUnit: Calendar.Component,
            yLabel: String,
            yValue: ValueY,
			point: CKEPoint,
            width: MarkDimension,
            height: MarkDimension,
            stacking: MarkStackingMethod
        ) -> some ChartContent where ValueY: Plottable {
            switch self {
            case .area:
                AreaMark(
					x: .value(xLabel, xValue, unit: xValueUnit),
                    y: .value(yLabel, yValue),
                    stacking: stacking
                )
            case .bar:
                BarMark(
                    x: .value(xLabel, xValue, unit: xValueUnit),
                    y: .value(yLabel, yValue),
                    width: width,
                    height: height,
                    stacking: stacking
                )
            case .line:
                LineMark(
                    x: .value(xLabel, xValue, unit: xValueUnit),
                    y: .value(yLabel, yValue)
                )
            case .point:
                PointMark(
                    x: .value(xLabel, xValue, unit: xValueUnit),
                    y: .value(yLabel, yValue)
				)
            case .rectangle:
                RectangleMark(
                    x: .value(xLabel, xValue, unit: xValueUnit),
                    y: .value(yLabel, yValue),
                    width: width,
                    height: height
                )
			case .scatter:
				ForEach(0..<point.originalValues.count, id: \.self) { index in
					PointMark(
						x: .value(xLabel, point.x, unit: point.xUnit),
						y: .value(yLabel, point.originalValues[index])
					)
					.opacity(0.3)
				}
            }
        }
    }

    public let id = UUID().uuidString

    /// The type of mark to display for this configuration.
    public var mark: MarkType

    /// A title for this data series that will be displayed in the plot legend.
    public var title: String

	/// A summary describing the data.
	public var summary: String?
	public var showMarkWhenHighlighted: Bool = false
	public var showMeanMark: Bool = false
	public var showMedianMark: Bool = false
	public var xAxisLabel: String?
	public var yAxisLabel: String?
	public var xLabel: String = String(localized: "DATE")
	public var yLabel: String = String(localized: "VALUE")
	public var yEndLabel: String?
	public var tLabel: String?
	public var domain: ClosedRange<Double>?
	public var function: (@Sendable (Double) -> Double)?
	public var parametricFunction: (@Sendable (Double) -> (x: Double, y: Double))?
	public var areaParametricFunction: (@Sendable (Double) -> (yStart: Double, yEnd: Double))?

    /// The color that will be used for data series in the legend.
    /// If `gradientStartColor` is not specified, it will also be used as the color
    /// of the data.
    public var color: Color

    /// The start color of the gradient this data series will be plotted in.
    public var gradientStartColor: Color?

    /// The dimention specifying the width at which this data series should
    /// appear on the plot.
    public var width: MarkDimension

    /// The dimention specifying the height at which this data series should
    /// appear on the plot.
    public var height: MarkDimension

    /// The ways in which you can stack marks in a chart.
    public var stackingMethod: MarkStackingMethod

	/// A basic chart symbol shape.
	public var symbol: BasicChartSymbolShape?

	/// The ways in which line or area marks interpolate their data.
	public var interpolation: InterpolationMethod?

    var dataPoints: [CKEPoint]
	var xValues: [Date] {
		dataPoints.map(\.x)
	}
	var maxXValue: Date {
		xValues.max() ?? Date()
	}
	var minXValue: Date {
		xValues.min() ?? Date()
	}
	var yValues: [Double] {
		dataPoints.map(\.y)
	}
	var maxYValue: Double {
		yValues.max() ?? 0
	}
	var maxYValueDays: [Date] {
		let maxValue = maxYValue
		let matchingDates = dataPoints.compactMap({ point -> Date? in
			guard point.y == maxValue else {
				return nil
			}
			return point.x
		})
		return matchingDates
	}
	var minYValue: Double {
		yValues.min() ?? 0
	}
	var minYValueDays: [Date] {
		let minValue = minYValue
		let matchingDates = dataPoints.compactMap({ point -> Date? in
			guard point.y == minValue else {
				return nil
			}
			return point.x
		})
		return matchingDates
	}
	var meanYValue: Double {
		LinearCareTaskProgress.computeProgressByAveraging(for: yValues).value
	}
	var medianYValue: Double {
		LinearCareTaskProgress.computeProgressByMedian(for: yValues).value
	}
	var isContinuous: Bool {
		switch mark {
		case .point, .bar:
			return false
		default:
			return true
		}
	}

	func selectedDataPoint(for date: Date) -> CKEPoint? {
		guard let component = dataPoints.first?.xUnit else {
			return nil
		}

		let calendar = Calendar.current
		let startOfDate = date.startOfDay
		let endDate = calendar.date(
			byAdding: component,
			value: 1,
			to: startOfDate
		)!.endOfDay
		let range = startOfDate...endDate

		let foundDataPoint = dataPoints.first(where: { range.contains($0.x) })

		return foundDataPoint
	}

	func selectedDataValue(for date: Date) -> Double? {
		guard let foundDataPoint = selectedDataPoint(for: date) else {
			return nil
		}
		let valueAtPoint = foundDataPoint.y
		let realValue = valueAtPoint > 0 ? valueAtPoint : nil
		return realValue
	}

    /// Creates a new data series that can be passed to a chart to be plotted. The series will be plotted in a single
    /// solid color. Use this initialize if you wish to plot data at precise or irregular intervals.
    ///
    /// - Parameters:
    ///   - mark: The type of mark to display for this configuration.
    ///   - dataPoints: An array of points in graph space Cartesian coordinates. The origin is in bottom left corner.
    ///   - title: A title that will be used to represent this data series in the plot legend.
	///   - summary: A summary describing the data.
    ///   - color: A solid color to be used when plotting the data series.
    ///   - width: The width determines the size of the line, bar, or scatter plot elements.
    ///   - height: The height determines the size of the line, bar, or scatter plot elements.
    ///   - stackingMethod: The ways in which you can stack marks in a chart.
    init(
        mark: MarkType,
        dataPoints: [CKEPoint],
        title: String,
		summary: String? = nil,
		showMarkWhenHighlighted: Bool = false,
		showMeanMark: Bool = false,
		showMedianMark: Bool = false,
        color: Color,
        width: MarkDimension = .automatic,
        height: MarkDimension = .automatic,
        stackingMethod: MarkStackingMethod = .standard,
		symbol: BasicChartSymbolShape? = nil,
		interpolation: InterpolationMethod? = nil
    ) {
        self.mark = mark
        self.dataPoints = dataPoints
        self.title = title
		self.summary = summary
		self.showMarkWhenHighlighted = showMarkWhenHighlighted
		self.showMeanMark = showMeanMark
		self.showMedianMark = showMedianMark
        self.color = color
        self.stackingMethod = stackingMethod
        self.width = width
        self.height = height
		self.symbol = symbol
		self.interpolation = interpolation
    }

    /// Creates a new data series that can be passed to a chart to be plotted.
    /// The series will be plotted with a gradient
    /// color scheme. Use this initialize if you wish to plot data at precise or irregular intervals.
    ///
    /// - Parameters:
    ///   - mark: The type of mark to display for this configuration.
    ///   - dataPoints: An array of points in graph space Cartesian coordinates. The origin is in bottom left corner.
    ///   - title: A title that will be used to represent this data series in the plot legend.
    ///   - color: The color that this data series will be plotted in.
    ///   - gradientStartColor: The start color for the gradient.
    ///   - width: The width determines the size of the line, bar, or scatter plot elements.
    ///   - height: The height determines the size of the line, bar, or scatter plot elements.
    ///   - stackingMethod: The ways in which you can stack marks in a chart.
    init(
        mark: MarkType,
        dataPoints: [CKEPoint],
        title: String,
		summary: String? = nil,
		showMarkWhenHighlighted: Bool = false,
		showMeanMark: Bool = false,
		showMedianMark: Bool = false,
		xAxisLabel: String? = nil,
		yAxisLabel: String? = nil,
        color: Color,
        gradientStartColor: Color? = nil,
        width: MarkDimension = .automatic,
        height: MarkDimension = .automatic,
        stackingMethod: MarkStackingMethod = .standard,
		symbol: BasicChartSymbolShape? = nil,
		interpolation: InterpolationMethod? = nil
    ) {
        self.mark = mark
        self.dataPoints = dataPoints
        self.title = title
		self.summary = summary
		self.showMarkWhenHighlighted = showMarkWhenHighlighted
		self.showMeanMark = showMeanMark
		self.showMedianMark = showMedianMark
		self.xAxisLabel = xAxisLabel
		self.yAxisLabel = yAxisLabel
        self.color = color
        self.gradientStartColor = gradientStartColor
        self.stackingMethod = stackingMethod
        self.width = width
        self.height = height
		self.symbol = symbol
		self.interpolation = interpolation
    }

	init(
		dataPoints: [CKEPoint],
		configuration: CKEDataSeriesConfiguration
	) {
		self.init(
			mark: configuration.mark,
			dataPoints: dataPoints,
			title: configuration.legendTitle,
			showMarkWhenHighlighted: configuration.showMarkWhenHighlighted,
			showMeanMark: configuration.showMeanMark,
			showMedianMark: configuration.showMedianMark,
			xAxisLabel: configuration.xAxisLabel,
			yAxisLabel: configuration.yAxisLabel,
			color: configuration.color,
			gradientStartColor: configuration.gradientStartColor,
			width: configuration.width,
			height: configuration.height,
			stackingMethod: configuration.stackingMethod,
			symbol: configuration.symbol,
			interpolation: configuration.interpolation
		)
	}

    /// Creates a new data series that can be passed to a chart to be plotted.
    /// The series will be plotted in a single solid color.
    /// Values will be evenly spaced when displayed on a chart.
    /// Use this option when the x coordinate is not particularly
    /// meaningful, such as when creating bar charts.
    ///
    /// - Parameters:
    ///   - mark: The type of mark to display for this configuration.
    ///   - values: An array of values in graph space Cartesian coordinates.
    ///   - accessibilityValues: Used to set the accessibility labels of each of the data points. This array should
    ///   either be empty or contain the same number of elements as the data series array.
    ///   - title: A title that will be used to represent this data series in the plot legend.
	///   - summary: A summary describing the data.
    ///   - color: The color that this data series will be plotted in.
    ///   - width: The width determines the size of the line, bar, or scatter plot elements.
    ///   - height: The height determines the size of the line, bar, or scatter plot elements.
    ///   - stackingMethod: The ways in which you can stack marks in a chart.
	///   - symbol: A basic chart symbol shape.
	///   - interpolation: The ways in which line or area marks interpolate their data.
    public init(
        mark: MarkType,
		dates: [Date],
		dateComponent: Calendar.Component,
        values: [Double],
        accessibilityValues: [String]? = nil,
        title: String,
		summary: String? = nil,
		xAxisLabel: String? = nil,
		yAxisLabel: String? = nil,
        color: Color,
        width: MarkDimension = .automatic,
        height: MarkDimension = .automatic,
        stackingMethod: MarkStackingMethod = .standard,
		symbol: BasicChartSymbolShape? = nil,
		interpolation: InterpolationMethod? = nil
    ) throws {
        if let accessibilityValues = accessibilityValues {
            guard accessibilityValues.count == values.count else {
                throw CareKitEssentialsError.errorString(
                    "The amount accessibility values should match the amount of \"values\""
                )
            }
        }
        self.mark = mark
        self.dataPoints = zip(
			dates,
			values
		).map { date, value in
			if let period = try? PeriodComponent(component: dateComponent) {
				return CKEPoint(
					x: date,
					y: value,
					period: period,
					originalValues: values
				)
			} else {
				return CKEPoint(
					x: date,
					y: value,
					period: .week,
					originalValues: values
				)
			}
        }
        self.title = title
		self.summary = summary
		self.xAxisLabel = xAxisLabel
		self.yAxisLabel = yAxisLabel
        self.color = color
        self.stackingMethod = stackingMethod
        self.width = width
        self.height = height
		self.symbol = symbol
		self.interpolation = interpolation
    }

    /// Creates a new data series that can be passed to a chart to be plotted.
    /// The series will be plotted with a gradient
    /// color scheme. Values will be evenly spaced when displayed on a chart.
    /// Use this option when the x coordinate is not
    /// particularly meaningful, such as when creating bar charts.
    ///
    /// - Parameters:
    ///   - mark: The type of mark to display for this configuration.
    ///   - values: An array of values in graph space Cartesian coordinates.
    ///   - accessibilityValues: Used to set the accessibility labels of each of the data points. This array should
    ///   either be empty or contain the same number of elements as the data series array.
    ///   - title: A title that will be used to represent this data series in the plot legend.
    ///   - color: The color that this data series will be plotted in.
    ///   - gradientStartColor: The start color for the gradient.
    ///   - width: The width determines the size of the line, bar, or scatter plot elements.
    ///   - height: The height determines the size of the line, bar, or scatter plot elements.
    ///   - stackingMethod: The ways in which you can stack marks in a chart.
	///   - symbol: A basic chart symbol shape.
	///   - interpolation: The ways in which line or area marks interpolate their data.
    public init(
        mark: MarkType,
		dates: [Date],
		dateComponent: Calendar.Component,
        values: [Double],
        accessibilityValues: [String]? = nil,
        title: String,
        color: Color,
        gradientStartColor: Color? = nil,
        width: MarkDimension = .automatic,
        height: MarkDimension = .automatic,
        stackingMethod: MarkStackingMethod = .standard,
		symbol: BasicChartSymbolShape? = nil,
		interpolation: InterpolationMethod? = nil
    ) throws {
        if let accessibilityValues = accessibilityValues {
            guard accessibilityValues.count == values.count else {
                throw CareKitEssentialsError.errorString(
                    "The amount accessibility values should match the amount of \"values\""
                )
            }
        }
        self.mark = mark
        self.dataPoints = zip(
			dates,
			values
		).map { date, value in
			if let period = try? PeriodComponent(component: dateComponent) {
				return CKEPoint(
					x: date,
					y: value,
					period: period,
					originalValues: values
				)
			} else {
				return CKEPoint(
					x: date,
					y: value,
					period: .week,
					originalValues: values
				)
			}
		}
        self.title = title
        self.color = color
        self.gradientStartColor = gradientStartColor
        self.stackingMethod = stackingMethod
        self.width = width
        self.height = height
		self.symbol = symbol
		self.interpolation = interpolation
    }

    static func weekDayCalculation(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date)
    }
}

extension CKEDataSeries {
	public static func == (lhs: CKEDataSeries, rhs: CKEDataSeries) -> Bool {
		lhs.id == rhs.id
		&& lhs.mark == rhs.mark
		&& lhs.dataPoints == rhs.dataPoints
		&& lhs.title == rhs.title
		&& lhs.summary == rhs.summary
		&& lhs.xLabel == rhs.xLabel
		&& lhs.yLabel == rhs.yLabel
		&& lhs.yEndLabel == rhs.yEndLabel
		&& lhs.tLabel == rhs.tLabel
		&& lhs.domain == rhs.domain
		&& lhs.color == rhs.color
		&& lhs.gradientStartColor == rhs.gradientStartColor
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(mark)
		hasher.combine(dataPoints)
		hasher.combine(title)
		hasher.combine(summary)
		hasher.combine(xLabel)
		hasher.combine(yLabel)
		hasher.combine(yEndLabel)
		hasher.combine(tLabel)
		hasher.combine(domain)
		hasher.combine(color)
		hasher.combine(gradientStartColor)
	}
}
