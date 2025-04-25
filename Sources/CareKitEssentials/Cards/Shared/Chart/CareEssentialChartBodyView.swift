//
//  CareEssentialChartBodyView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/1/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import Charts
import SwiftUI

struct CareEssentialChartBodyView: View {

    let dataSeries: [CKEDataSeries]

    var body: some View {
        Chart(dataSeries) { data in
            ForEach(data.dataPoints) { point in
                data.mark.chartContent(
                    title: data.title,
                    xLabel: "Date",
                    xValue: String(point.x),
                    yLabel: "Value",
                    yValue: point.y,
                    width: data.width,
                    height: data.height,
                    stacking: data.stackingMethod
                )
				.lineStyle(by: .value(data.title, point.y))
                .accessibilityValue(
                    Text(
                        point.accessibilityValue ?? ""
                    )
                )
            }
            .if(data.gradientStartColor != nil) { chartContent in
                chartContent.foregroundStyle(
                    .linearGradient(
                        Gradient(
                            colors: [
                                data.gradientStartColor!,
                                data.color
                           ]
                        ),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .foregroundStyle(data.color)
            .foregroundStyle(by: .value("Data Series", data.title))
            .position(by: .value("Data Series", data.title))
        }
        .chartXAxis {
            AxisMarks(stroke: StrokeStyle(lineWidth: 0))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        } /*
        .chartForegroundStyleScale { (name: String) in
            legendColors[name] ?? .clear
        }
        .onAppear {
            let updatedLegendColors = dataSeries.reduce(into: [String: Color]()) { colors, series in
                colors[series.title] = series.color
            }
            legendColors = updatedLegendColors
        } */
    }
}
