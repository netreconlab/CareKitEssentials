//
//  CareKitEssentialChartBodyView+ChartContent.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/28/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import Charts
import SwiftUI

extension CareKitEssentialChartBodyView {

	@ChartContentBuilder
	func makeAllAdditionalMarks(series: CKEDataSeries, at point: CKEPoint) -> some ChartContent {
		makePointMarksForAllDataPoints(series: series, at: point)
		makeAdditionalMarksForBarMarks(series: series, at: point)
	}

	@ChartContentBuilder
	func makeAllAdditionalMarks(series: CKEDataSeries) -> some ChartContent {
		makeSelectedRuleMark(series: series)
		makeMeanRuleMark(series: series)
		makeMedianRuleMark(series: series)
	}

	@ChartContentBuilder
	func makeSelectedRuleMark(series: CKEDataSeries) -> some ChartContent {
		if let selectedDate,
		   selectedDateValue(series: series) != nil,
		   let dateUnit = series.dataPoints.first?.xUnit {
			RuleMark(x: .value("SELECTED_DATE", selectedDate, unit: dateUnit))
				.foregroundStyle(grayColor.opacity(0.2))
				.annotation(
					position: .automatic,
					spacing: 0
				) {
					selectionPopover(series: series)
						.padding(2)
						.background {
							RoundedRectangle(
								cornerRadius: 4
							)
							.shadow(radius: 2)
							.foregroundStyle(markColor(name: series.title).opacity(0.2))
						}
				}
		}
	}

	@ChartContentBuilder
	func makeMeanRuleMark(series: CKEDataSeries) -> some ChartContent {
		if series.showMeanMark {
			let mean = series.meanYValue
			RuleMark(y: .value("AVERAGE", mean))
				.foregroundStyle(grayColor.opacity(0.2))
				.annotation(
					position: .top,
					alignment: .topLeading
				) {
					Text(markerLocalizedString("AVERAGE_VALUE", value: mean))
						.font(.caption)
				}
		}
	}

	@ChartContentBuilder
	func makeMedianRuleMark(series: CKEDataSeries) -> some ChartContent {
		if series.showMedianMark {
			let median = series.medianYValue
			RuleMark(y: .value("MEDIAN", median))
				.foregroundStyle(.gray.opacity(0.2))
				.annotation(
					position: .top,
					alignment: .topLeading
				) {
					Text(markerLocalizedString("MEDIAN_VALUE", value: median))
						.font(.caption)
				}
		}
	}

	@ChartContentBuilder
	func makePointMarksForAllDataPoints(series: CKEDataSeries, at point: CKEPoint) -> some ChartContent {
		ForEach(0..<point.originalValues.count, id: \.self) { index in
			PointMark(
				x: .value(series.xLabel, point.x, unit: point.xUnit),
				y: .value(series.yLabel, point.originalValues[index])
			)
			.opacity(0.3)
		}
	}

	@ChartContentBuilder
	func makeAdditionalMarksForBarMarks(series: CKEDataSeries, at point: CKEPoint) -> some ChartContent {
		if series.mark == .bar {
			if point.y == series.maxYValue {
				RectangleMark(
					x: .value(series.xLabel, point.x, unit: point.xUnit),
					y: .value(series.yLabel, point.y),
					height: 3
				)
			}
		}
	}
}
