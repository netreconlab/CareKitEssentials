//
//  CKEDataSeriesConfiguration.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 7/27/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

#if canImport(SwiftUI)

import CareKitStore
import SwiftUI
import Charts

// swiftlint:disable vertical_parameter_alignment

/// A configuration object that specifies which data should be queried and how it should be displayed by the graph.
public struct CKEDataSeriesConfiguration: Identifiable, Hashable {

	/// The type of strategy used to produce each data point in the plot.
	public enum DataStrategy: Hashable {
		/// Take the sum of all `OCKOutcomeValues` to produce each data point.
		case sum
		/// Take the maximum of all `OCKOutcomeValues` to produce each data point.
		case max
		/// Take the mean of all `OCKOutcomeValues` to produce each data point.
		case mean
		/// Take the median of all `OCKOutcomeValues` to produce each data point.
		case median
		/// Take the minimum of all `OCKOutcomeValues` to produce each data point.
		case min
	}

    public var id: String {
        taskID + "_" + legendTitle
    }

    /// The type of mark to display for this configuration.
    public var mark: CKEDataSeries.MarkType

	/// The type of strategy used to produce each data point in the plot.
	public var dataStrategy: DataStrategy

    /// A user-provided unique id for a task.
    public var taskID: String

	/// The kind property of the OCKOutcomeValue to graph.
	public var kind: String?

    /// The title that will be used to represent this data series in the legend.
    public var legendTitle: String

	/// The label to use for the yAxis.
	public var xAxisLabel: String?

	/// The label to use for the yAxis.
	public var yAxisLabel: String?

	public var showMarkWhenHighlighted: Bool = false
	public var showMeanMark: Bool = false
	public var showMedianMark: Bool = false

    /// The color that will be used for data series in the legend.
    /// If `color` is not specified, is not specified, default colors will be assigned.
    public var color: Color

    /// The first of two colors that will be used in the gradient when plotting the data.
    public var gradientStartColor: Color?

    /// The width determines the size of the line, bar, or scatter plot elements.
    /// The precise behavior is different for each type of plot.
    /// - For line plots, it will be the width of the line.
    /// - For scatter plots, it will be the radius of the markers.
    /// - For bar plots, it will be the width of the bar.
    public var width: MarkDimension

    /// The height determines the size of the line, bar, or scatter plot elements.
    /// The precise behavior is different for each type of plot.
    /// - For line plots, it will be the width of the line.
    /// - For scatter plots, it will be the radius of the markers.
    /// - For bar plots, it will be the width of the bar.
    public var height: MarkDimension

    /// The ways in which you can stack marks in a chart.
    public var stackingMethod: MarkStackingMethod

	/// A basic chart symbol shape.
	public var symbol: BasicChartSymbolShape?

	/// The ways in which line or area marks interpolate their data.
	public var interpolation: InterpolationMethod?

    let computeProgress: (OCKAnyEvent) -> LinearCareTaskProgress

    /// Initialize a new `CareKitEssentialsDataSeriesConfiguration`.
    ///
    /// - Parameters:
    ///	  - taskID: A user-provided unique id for a task.
	///   - dataStrategy: The type of strategy used to produce each data point in the plot. Be sure
	///   the `dataStrategy` matches the same strategy used for `computeProgress`.
	///   - kind: The kind property of the OCKOutcomeValue to graph.
    ///   - mark: The type of mark to display for this configuration.
    ///   - legendTitle: The title that will be used to represent this data series in the legend.
    ///   - color: The color that will be used for data series in the legend. If `color`
    ///   is not specified, default colors will be assigned.
    ///   - gradientStartColor: The first of two colors that will be used in the gradient when plotting the data.
    ///   - markerSize: The marker size determines the size of the line, bar, or scatter plot elements.
    ///   - stackingMethod: The ways in which you can stack marks in a chart.
	///   - symbol: A basic chart symbol shape.
	///   - interpolation: The ways in which line or area marks interpolate their data.
    ///   - computeProgress: Used to compute progress for an event.
    public init(
        taskID: String,
		dataStrategy: DataStrategy = .sum,
		kind: String? = nil,
        mark: CKEDataSeries.MarkType,
        legendTitle: String,
		xAxisLabel: String? = nil,
		yAxisLabel: String? = nil,
		showMarkWhenHighlighted: Bool = false,
		showMeanMark: Bool = false,
		showMedianMark: Bool = false,
        color: Color,
        gradientStartColor: Color? = nil,
        width: MarkDimension = .automatic,
        height: MarkDimension = .automatic,
        stackingMethod: MarkStackingMethod = .standard,
		symbol: BasicChartSymbolShape? = nil,
		interpolation: InterpolationMethod? = nil,
        computeProgress: @escaping (OCKAnyEvent) -> LinearCareTaskProgress = { event in
            event.computeProgress(by: .summingOutcomeValues)
        }
    ) {
        self.taskID = taskID
		self.dataStrategy = dataStrategy
		self.kind = kind
        self.mark = mark
        self.legendTitle = legendTitle
		self.yAxisLabel = yAxisLabel
		self.showMarkWhenHighlighted = showMarkWhenHighlighted
		self.showMeanMark = showMeanMark
		self.showMedianMark = showMedianMark
        self.color = color
        self.gradientStartColor = gradientStartColor
        self.width = width
        self.height = height
        self.stackingMethod = stackingMethod
		self.symbol = symbol
		self.interpolation = interpolation
        self.computeProgress = computeProgress
    }
}

extension CKEDataSeriesConfiguration {
	public static func == (lhs: CKEDataSeriesConfiguration, rhs: CKEDataSeriesConfiguration) -> Bool {
		lhs.id == rhs.id
		&& lhs.mark == rhs.mark
		&& lhs.dataStrategy == rhs.dataStrategy
		&& lhs.taskID == rhs.taskID
		&& lhs.kind == rhs.kind
		&& lhs.legendTitle == rhs.legendTitle
		&& lhs.xAxisLabel == rhs.xAxisLabel
		&& lhs.yAxisLabel == rhs.yAxisLabel
		&& lhs.showMarkWhenHighlighted == rhs.showMarkWhenHighlighted
		&& lhs.showMedianMark == rhs.showMedianMark
		&& lhs.showMeanMark == rhs.showMeanMark
		&& lhs.color == rhs.color
		&& lhs.gradientStartColor == rhs.gradientStartColor
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(mark)
		hasher.combine(dataStrategy)
		hasher.combine(taskID)
		hasher.combine(kind)
		hasher.combine(legendTitle)
		hasher.combine(xAxisLabel)
		hasher.combine(yAxisLabel)
		hasher.combine(showMarkWhenHighlighted)
		hasher.combine(showMedianMark)
		hasher.combine(showMeanMark)
		hasher.combine(color)
		hasher.combine(gradientStartColor)
	}
}

#endif
