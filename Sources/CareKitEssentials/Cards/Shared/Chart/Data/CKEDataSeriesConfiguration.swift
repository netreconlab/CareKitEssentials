//
//  CKEDataSeriesConfiguration.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 7/27/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKitStore
import SwiftUI
import Charts

// swiftlint:disable vertical_parameter_alignment

/// A configuration object that specifies which data should be queried and how it should be displayed by the graph.
public struct CKEDataSeriesConfiguration: Identifiable {

    public var id: String {
        taskID + "_" + legendTitle
    }

    /// The type of mark to display for this configuration.
    public var mark: CKEDataSeries.MarkType

    /// A user-provided unique id for a task.
    public var taskID: String

    /// The title that will be used to represent this data series in the legend.
    public var legendTitle: String

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
    ///   - taskID: A user-provided unique id for a task.
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
        mark: CKEDataSeries.MarkType,
        legendTitle: String,
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
        self.mark = mark
        self.legendTitle = legendTitle
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
