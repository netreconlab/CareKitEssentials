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
					xLabel: data.xLabel,
					xValue: String(point.x.prefix(3)),
					yLabel: data.yLabel,
                    yValue: point.y,
                    width: data.width,
                    height: data.height,
                    stacking: data.stackingMethod
                )
				.lineStyle(by: .value(data.title, point.y))
            }
			.if(data.interpolation != nil) { chartContent in
				chartContent.interpolationMethod(data.interpolation!)
			}
			.if(data.symbol != nil) { chartContent in
				chartContent.symbol(data.symbol!)
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
            .foregroundStyle(by: .value("DATA_SERIES", data.title))
            .position(by: .value("DATA_SERIES", data.title))
        }
		.if(dataSeries.isEmpty == false) { chart in
			chart.accessibilityChartDescriptor(dataSeries.first!)
		}
    }
}
