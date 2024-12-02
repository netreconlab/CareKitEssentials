//
//  ChartEssentialChartBodyView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/1/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import Charts
import SwiftUI

struct ChartEssentialChartBodyView: View {

    let dataSeries: [CKEDataSeries]
    @State var colors = [String: Color]()

    var body: some View {
        Chart(dataSeries) { data in
            let gradient = Gradient(
                colors: [
                    data.gradientStartColor ?? .accentColor,
                    data.gradientEndColor ?? .accentColor
                ]
            )
            ForEach(data.dataPoints) { point in
                data.mark.chartContent(
                    xLabel: "Date",
                    xValue: String(point.x.prefix(3)),
                    yLabel: "Value",
                    yValue: point.y
                )
                .accessibilityValue(
                    Text(
                        point.accessibilityValue ?? ""
                    )
                )
            }
            .foregroundStyle(
                .linearGradient(
                    gradient,
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .foregroundStyle(by: .value("Task", data.title))
        }
        .chartXAxis {
            AxisMarks(stroke: StrokeStyle(lineWidth: 0))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartForegroundStyleScale { (name: String) in
            colors[name] ?? .clear
        }
        .onAppear {
            let newColors = dataSeries.reduce(into: [String: Color]()) { legendColors, series in
                legendColors[series.title] = series.gradientEndColor ?? series.gradientStartColor ?? .accentColor
            }
            colors = newColors
        }
    }

    func getColor(_ name: String) -> Color {
        print(name)
        return .clear
    }
}
