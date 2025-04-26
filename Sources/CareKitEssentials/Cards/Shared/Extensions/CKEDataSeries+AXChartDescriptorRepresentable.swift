//
//  CKEDataSeries+AXChartDescriptorRepresentable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/25/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

extension CKEDataSeries: AXChartDescriptorRepresentable {
	public func makeChartDescriptor() -> AXChartDescriptor {
		let xAxis = AXCategoricalDataAxisDescriptor(
			title: xLabel,
			categoryOrder: dataPoints.map(\.x)
		)

		let yValues = dataPoints.map(\.y)
		let maxYValue = yValues.max() ?? 0
		let minYValue = yValues.min() ?? 0

		let yAxis = AXNumericDataAxisDescriptor(
			title: yLabel,
			range: minYValue...maxYValue,
			gridlinePositions: []
		) { value in
			"\(value)"
		}

		let series = AXDataSeriesDescriptor(
			name: "DATA_SERIES",
			isContinuous: isContinuous,
			dataPoints: dataPoints.map { .init(x: $0.x, y: $0.y) }
		)

		let chart = AXChartDescriptor(
			title: title,
			summary: summary,
			xAxis: xAxis,
			yAxis: yAxis,
			series: [series]
		)

		return chart
	}

}
