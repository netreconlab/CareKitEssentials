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
    @State var legendColors = [String: Color]()

    var body: some View {
        Chart(dataSeries) { data in
            ForEach(data.dataPoints) { point in
                data.mark.chartContent(
                    title: data.title,
                    xLabel: "Date",
                    xValue: String(point.x.prefix(3)),
                    yLabel: "Value",
                    yValue: point.y,
                    width: data.width,
                    height: data.height,
                    stacking: data.stackingMethod
                )
                .accessibilityValue(
                    Text(
                        point.accessibilityValue ?? ""
                    )
                )
            }
            .if(data.color != nil) { chartContent in
                chartContent
                    .foregroundStyle(data.color!)
            } /*
            .if(data.gradientStartColor != nil) { chartContent in
                chartContent.foregroundStyle(
                    .linearGradient(
                        Gradient(
                            colors: [
                                data.gradientStartColor!,
                                data.color ?? .accentColor
                           ]
                        ),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            } */
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
        } */
        .onAppear {
            let updatedLegendColors = dataSeries.reduce(into: [String: Color]()) { colors, series in
                colors[series.title] = series.color
            }
            legendColors = updatedLegendColors
        }
    }
}
