//
//  CKEDataSeries.swift
//  Assuage
//
//  Created by Alyssa Donawa on 6/11/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKitStore
import Charts
import Foundation
import SwiftUI

/// Represents a single group of data to be plotted. In most cases, CareKit plots accept multiple data
/// series, allowing for for several data series to be plotted on a single axis for easy comparison.
public struct CKEDataSeries: Equatable, Identifiable {

    /// An enumerator specifying the types of marks this chart can display.
    public enum MarkType: String, CaseIterable {
        case area
        case bar
        case line
        case point
        case rectangle

        @ChartContentBuilder
        func chartContent<ValueX, ValueY>(
            title: String,
            xLabel: LocalizedStringKey,
            xValue: ValueX,
            yLabel: LocalizedStringKey,
            yValue: ValueY
        ) -> some ChartContent where ValueX: Plottable, ValueY: Plottable {
            switch self {
            case .area:
                AreaMark(
                    x: .value(xLabel, xValue),
                    y: .value(yLabel, yValue)
                )
                .lineStyle(by: .value(title, yValue))
            case .bar:
                BarMark(
                    x: .value(xLabel, xValue),
                    y: .value(yLabel, yValue)
                )
                .lineStyle(by: .value(title, yValue))
            case .line:
                LineMark(
                    x: .value(xLabel, xValue),
                    y: .value(yLabel, yValue)
                )
                .lineStyle(by: .value(title, yValue))
            case .point:
                PointMark(
                    x: .value(xLabel, xValue),
                    y: .value(yLabel, yValue)
                )
                .lineStyle(by: .value(title, yValue))
            case .rectangle:
                RectangleMark(
                    x: .value(xLabel, xValue),
                    y: .value(yLabel, yValue)
                )
                .lineStyle(by: .value(title, yValue))
            }
        }
    }

    public let id = UUID().uuidString

    /// The type of mark to display for this configuration.
    public var mark: MarkType

    /// A title for this data series that will be displayed in the plot legend.
    public var title: String

    /// The start color of the gradient this data series will be plotted in.
    public var gradientStartColor: Color?

    /// The end color of the gradient this data series will be plotted in.
    public var gradientEndColor: Color?

    /// A size specifying how large this data series should appear on the plot.
    /// Its precise interpretation may vary depending on plot type used.
    public var size: CGFloat

    var dataPoints: [CKEPoint]

    /// Creates a new data series that can be passed to a chart to be plotted. The series will be plotted in a single
    /// solid color. Use this initialize if you wish to plot data at precise or irregular intervals.
    ///
    /// - Parameters:
    ///   - mark: The type of mark to display for this configuration.
    ///   - dataPoints: An array of points in graph space Cartesian coordinates. The origin is in bottom left corner.
    ///   - title: A title that will be used to represent this data series in the plot legend.
    ///   - size: A size specifying how large this data series should appear on the plot.
    ///   - color: A solid color to be used when plotting the data series.
    init(
        mark: MarkType,
        dataPoints: [CKEPoint],
        title: String,
        size: CGFloat = 10,
        color: Color? = nil
    ) {
        self.mark = mark
        self.dataPoints = dataPoints
        self.title = title
        self.gradientStartColor = color
        self.gradientEndColor = color
        self.size = size
    }

    /// Creates a new data series that can be passed to a chart to be plotted.
    /// The series will be plotted with a gradient
    /// color scheme. Use this initialize if you wish to plot data at precise or irregular intervals.
    ///
    /// - Parameters:
    ///   - mark: The type of mark to display for this configuration.
    ///   - dataPoints: An array of points in graph space Cartesian coordinates. The origin is in bottom left corner.
    ///   - title: A title that will be used to represent this data series in the plot legend.
    ///   - gradientStartColor: The start color for the gradient.
    ///   - gradientEndColor: The end color for the gradient.
    ///   - size: A size specifying how large this data series should appear on the plot.
    init(
        mark: MarkType,
        dataPoints: [CKEPoint],
        title: String,
        gradientStartColor: Color,
        gradientEndColor: Color,
        size: CGFloat = 10
    ) {
        self.mark = mark
        self.dataPoints = dataPoints
        self.title = title
        self.size = size
        self.gradientStartColor = gradientStartColor
        self.gradientEndColor = gradientEndColor
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
    ///   - size: A size specifying how large this data series should appear on the plot.
    ///   - color: The color that this data series will be plotted in.
    public init(
        mark: MarkType,
        values: [Double],
        accessibilityValues: [String]? = nil,
        title: String,
        size: CGFloat = 10,
        color: Color? = nil
    ) throws {
        if let accessibilityValues = accessibilityValues {
            guard accessibilityValues.count == values.count else {
                throw CareKitEssentialsError.errorString(
                    "The amount accessibility values should match the amount of \"values\""
                )
            }
        }
        self.mark = mark
        self.dataPoints = values.enumerated().map { index, value in
            CKEPoint(
                x: "A",
                y: value,
                accessibilityValue: accessibilityValues?[index]
            )
        }
        self.title = title
        self.size = size
        self.gradientStartColor = color
        self.gradientEndColor = color
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
    ///   - gradientStartColor: The start color for the gradient.
    ///   - gradientEndColor: The end color for the gradient.
    ///   - size: A size specifying how large this data series should appear on the plot.
    public init(
        mark: MarkType,
        values: [Double],
        accessibilityValues: [String]? = nil,
        title: String,
        gradientStartColor: Color,
        gradientEndColor: Color,
        size: CGFloat = 10
    ) throws {
        if let accessibilityValues = accessibilityValues {
            guard accessibilityValues.count == values.count else {
                throw CareKitEssentialsError.errorString(
                    "The amount accessibility values should match the amount of \"values\""
                )
            }
        }
        self.mark = mark
        self.dataPoints = values.enumerated().map { index, value in
            CKEPoint(
                x: "A",
                y: value,
                accessibilityValue: accessibilityValues?[index]
            )
        }
        self.title = title
        self.size = size
        self.gradientStartColor = gradientStartColor
        self.gradientEndColor = gradientEndColor
    }

    static func weekDayCalculation(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date)
    }
}

enum ChartParameters {
    case day
    case week
    case month
    case year

    var xAxisLabels: [String] {
        switch self {

        case .day:
            return [
                CKEDataSeries.weekDayCalculation(from: Date())
            ]
        case .week:
            return [
            "Sun",
            "Mon",
            "Tue",
            "Wed",
            "Thu",
            "Fri",
            "Sat"
            ]
        case .month:
            return [
            ]
        case .year:
            return [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec"
            ]
        }
    }
}
