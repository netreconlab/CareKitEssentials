//
//  CareKitEssentialChartBodyView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/1/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import Charts
import os.log
import SwiftUI

struct CareKitEssentialChartBodyView: View {

	@Environment(\.careKitStyle) private var style
	let dataSeries: [CKEDataSeries]
	let dateInterval: DateInterval
	@State var showGridLines: Bool = false
	@State var isAllowingHorizontalScroll: Bool = false
	@State var legendColors = [String: LinearGradient]()
	@State var selectedDate: Date?

	var body: some View {
		Chart(dataSeries) { data in
			ForEach(data.dataPoints) { point in
				data.mark.chartContent(
					xLabel: data.xLabel,
					xValue: point.x,
					xValueUnit: point.xUnit,
					yLabel: data.yLabel,
					yValue: point.y,
					point: point,
					width: data.width,
					height: data.height,
					stacking: data.stackingMethod
				)
				.lineStyle(by: .value(data.title, point.y))
				.opacity(selectedDate == nil || selectedDateValue(series: data)?.1 == point.y ? 1 : 0.2)

				// Add special marks that rely on the specific point
				// to the method below.
				makeAllAdditionalMarks(series: data, at: point)
			}
			.if(data.interpolation != nil) { chartContent in
				chartContent.interpolationMethod(data.interpolation!)
			}
			.if(data.symbol != nil) { chartContent in
				chartContent.symbol(data.symbol!)
			}
			.foregroundStyle(
				createLinearGradientColor(for: data)
			)
			.foregroundStyle(by: .value("DATA_SERIES", data.title))
			.position(by: .value("DATA_SERIES", data.title))

			// Add all Marks that don't rely on a specific point
			// to the method below.
			makeAllAdditionalMarks(series: data)
		}
		.chartXAxis {
			AxisMarks { _ in
				if showGridLines {
					AxisGridLine()
				}
				if dataSeries.first?.dataPoints.first?.xUnit == .hour {
					AxisValueLabel(
						format: .dateTime.hour(.defaultDigits(amPM: .abbreviated))
					)
				} else if dataSeries.first?.dataPoints.first?.xUnit == .day {
					AxisValueLabel(
						format: .dateTime.weekday(.abbreviated)
					)
				} else {
					AxisValueLabel()
				}
			}
		}
		.chartYAxis {
			AxisMarks(position: .leading) { _ in
				AxisGridLine()
				AxisValueLabel()
			}
		}
		.chartForegroundStyleScale { (name: String) in
			markColor(name: name)
		}
		.if(dataSeries.isEmpty == false) { chart in
			chart.accessibilityChartDescriptor(dataSeries.last!)
		}
		.apply { chart in
			if #available(iOS 17.0, watchOS 10.0, *) {
				if isAllowingHorizontalScroll {
					chart
						.chartScrollableAxes(.horizontal)
						// .chartXVisibleDomain(length: )
						.chartXSelection(value: $selectedDate)
				} else {
					chart.chartXSelection(value: $selectedDate)
				}
			} else {
				chart
			}
		}
		.onAppear {
			updateLegendColors()
		}
	}

	// MARK: Public Helpers
	var grayColor: Color {
#if os(iOS) || os(visionOS)
		Color(style.color.customGray)
#else
		Color.gray
#endif
	}

	@ViewBuilder
	func selectionPopover(series: CKEDataSeries) -> some View {
		if series.showMarkWhenHighlighted {
			if let selectedDate,
				let selected = selectedDateValue(series: series) {
				VStack {
					let point = series.selectedDataPoint(for: selectedDate)
					let yUnit = point?.yUnit ?? ""
					if let yAxisLabel = series.yAxisLabel {
						Text(yAxisLabel.uppercased())
							.font(.caption)
					}
					HStack {
						Text(selected.1.formatted())
							.font(.largeTitle)
						Text(yUnit)
							.font(.caption)
					}
					dateFormatted(date: selected.0, series: series)
						.font(.caption)
				}
			} else if let selectedDate {
				VStack {
					let point = series.selectedDataPoint(for: selectedDate)
					let yUnit = point?.yUnit ?? ""
					if let yAxisLabel = series.yAxisLabel {
						Text(yAxisLabel.uppercased())
							.font(.caption)
					}
					HStack {
						Text("0")
							.font(.largeTitle)
						Text(yUnit)
							.font(.caption)
					}
					dateFormatted(date: selectedDate, series: series)
						.font(.caption)
				}
			}
		}
	}

	func markerLocalizedString(_ key: String, value: Double) -> String {
		String(
			format: NSLocalizedString(
				key,
				comment: ""
			),
			value
		)
	}

	func markColor(name: String) -> LinearGradient {
		legendColors[name] ?? LinearGradient(
			gradient: Gradient(
				colors: [
					Color.accentColor.opacity(0.4),
					Color.accentColor
				]
			),
			startPoint: .bottom,
			endPoint: .top
		)
	}

	func selectedDateValue(series: CKEDataSeries) -> (Date, Double)? {
		guard let selectedDate,
			  let value = series.selectedDataValue(for: selectedDate) else {
			return nil
		}

		return (selectedDate, value)
	}

	// MARK: Private Helpers
	@ViewBuilder
	private func dateFormatted(date: Date, series: CKEDataSeries) -> some View {
		if let period = dataSeries.first?.dataPoints.first?.period {
			Text(period.formattedDateString(date))
		} else {
			Text(date.formatted(.dateTime.month().day().hour()))
		}
	}

	private func updateLegendColors() {
		dataSeries.forEach { data in
			legendColors[data.title] = createLinearGradientColor(for: data)
		}
	}

	private func createLinearGradientColor(for data: CKEDataSeries) -> LinearGradient {
		LinearGradient(
			gradient: Gradient(
				colors: [
					data.gradientStartColor ?? data.color.opacity(0.4),
					data.color
				]
			),
			startPoint: .bottom,
			endPoint: .top
		)
	}
}
