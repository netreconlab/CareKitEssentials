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
	var useFullAspectRating: Bool = false
	@State var showGridLines: Bool = false
	@State var isAllowingHorizontalScroll: Bool = false
	@State var isShowingMeanMarker: Bool = false
	@State var isShowingMedianMarker: Bool = false
	@State var legendColors = [String: LinearGradient]()
	@State var selectedDate: Date? = nil

    var body: some View {
        Chart(dataSeries) { data in
            ForEach(data.dataPoints) { point in
                data.mark.chartContent(
                    title: data.title,
					xLabel: data.xLabel,
					xValue: point.x,
					xValueUnit: point.xUnit,
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
			.foregroundStyle(
				createLinearGradientColor(for: data)
			)
            .foregroundStyle(by: .value("DATA_SERIES", data.title))
            .position(by: .value("DATA_SERIES", data.title))

			// Add all Marks here.
			if data == dataSeries.last {
				if let selectedDate,
				   let dateUnit = data.dataPoints.first?.xUnit {
					RuleMark(x: .value("SELECTED_DATE", selectedDate, unit: dateUnit))
						.foregroundStyle(grayColor.opacity(0.3))
						.annotation(
							position: .top,
							spacing: 0
						) {
							selectionPopover
						}
				}
				if isShowingMeanMarker {
					let mean = data.meanYValue
					RuleMark(y: .value("AVERAGE", mean))
						.foregroundStyle(grayColor)
						.annotation(
							position: .top,
							alignment: .topLeading
						) {
							Text(markerLocalizedString("AVERAGE_VALUE", value: mean))
								.font(.caption)
						}
				}
				if isShowingMedianMarker {
					let median = data.medianYValue
					RuleMark(y: .value("MEDIAN", median))
						.foregroundStyle(.gray)
						.annotation(
							position: .top,
							alignment: .topLeading
						) {
							Text(markerLocalizedString("MEDIAN_VALUE", value: median))
								.font(.caption)
						}
				}
			}
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
		.if(useFullAspectRating) { chart in
			chart.aspectRatio(1, contentMode: .fit)
		}
		.if(dataSeries.isEmpty == false) { chart in
			chart.accessibilityChartDescriptor(dataSeries.last!)
		}
		.apply { chart in
			if #available(iOS 17.0, watchOS 10.0, *) {
				if isAllowingHorizontalScroll {
					chart
						.chartScrollableAxes(.horizontal)
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

	private var grayColor: Color {
		#if os(iOS) || os(visionOS)
		Color(style.color.customGray)
		#else
		Color.gray
		#endif
	}

	@ViewBuilder
	private var selectionPopover: some View {
		if let selectedDateValue {
			VStack {
				Text(selectedDateValue.0.formatted(.dateTime.month().day().hour()))
				Text(selectedDateValue.1.formatted())
			}
			.font(.caption)
		} else if let selectedDate {
			VStack {
				Text(selectedDate.formatted(.dateTime.month().day().hour()))
			}
			.font(.caption)
		}
	}

	private var selectedDateValue: (Date, Double)? {
		guard let selectedDate,
			  let value = dataSeries.first?.selectedDataValue(for: selectedDate) else {
			return nil
		}

		return (selectedDate, value)
	}

	private func markerLocalizedString(_ key: String, value: Double) -> String {
		String(
			format: NSLocalizedString(
				key,
				comment: ""
			),
			value
		)
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
