//
//  CareEssentialChartView.swift
//  CareKitEssentials
//
//  Created by Zion Glover on 6/26/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import Foundation
import os.log
import SwiftUI

/// Displays a SwiftUI Chart above an axis. The initializer takes an an array of
/// `CKEDataSeriesConfiguration`'s which each support
/// `CKEDataSeries.MarkType` that allows you to overlay from several
/// graph types that conform to `ChartContent`.
///
///     +-------------------------------------------------------+
///     |                                                       |
///     | [title]                                               |
///     | [detail]                                              |
///     |                                                       |
///     | [graph]                                               |
///     |                                                       |
///     +-------------------------------------------------------+
///
@available(*, deprecated, message: "Renamed to `CareKitEssentialChartView` and `dateInterval`, `period`, and `configurations` are now @Binding") // swiftlint:disable:this line_length
public struct CareEssentialChartView: View {
	let title: String
	let subtitle: String
	var dateInterval: DateInterval
	var period: Calendar.Component
	var configurations: [CKEDataSeriesConfiguration]

	@Binding var bindedDateInterval: DateInterval
	@Binding var periodComponent: PeriodComponent

	public var body: some View {
		CareKitEssentialChartView(
			title: title,
			subtitle: subtitle,
			dateInterval: $bindedDateInterval,
			period: $periodComponent,
			configurations: configurations
		)
		.onChange(of: dateInterval) { newDateInterval in
			bindedDateInterval = newDateInterval
		}
		.onChange(of: period) { newPeriod in
			do {
				let newPeriodComponent = try PeriodComponent(
					component: newPeriod
				)
				periodComponent = newPeriodComponent
			} catch {
				Logger.essentialChartView.error(
					"Unable to initialize PeriodComponent. Defaulting to weekly period"
				)
				periodComponent = .week
			}
		}
	}

	/// Create an instance of chart for displaying CareKit data.
	/// - title: The title for the chart.
	/// - subtitle: The subtitle for the chart.
	/// - dateInterval: The date interval of data to display
	/// - period: The frequency at which data should be combined.
	/// - configurations: A configuration object that specifies
	/// which data should be queried and how it should be
	/// displayed by the graph.
	public init(
		title: String,
		subtitle: String,
		dateInterval: DateInterval,
		period: Calendar.Component,
		configurations: [CKEDataSeriesConfiguration]
	) {
		self.title = title
		self.subtitle = subtitle
		self.dateInterval = dateInterval
		self.period = period
		self.configurations = configurations
		@State var stateDateInterval = dateInterval
		_bindedDateInterval = $stateDateInterval
		do {
			let newPeriodComponent = try PeriodComponent(
				component: period
			)
			@State var statePeriodComponent: PeriodComponent = newPeriodComponent
			_periodComponent = $statePeriodComponent
		} catch {
			Logger.essentialChartView.error(
				"Unable to initialize PeriodComponent. Defaulting to weekly period"
			)
			@State var statePeriodComponent: PeriodComponent = .week
			_periodComponent = $statePeriodComponent
		}
	}
}

struct CareEssentialChartView_Previews: PreviewProvider {
	static var previews: some View {
		let task = Utility.createNauseaTask()
		let configurationBar = CKEDataSeriesConfiguration(
			taskID: task.id,
			mark: .bar,
			legendTitle: "Bar",
			showMarkWhenHighlighted: true,
			showMeanMark: true,
			color: .red,
			gradientStartColor: .gray
		)
		let previewStore = Utility.createPreviewStore()
		var dayDateInterval: DateInterval {
			let now = Date()
			let startOfDay = Calendar.current.startOfDay(
				for: now
			)
			let dateInterval = DateInterval(
				start: startOfDay,
				end: now
			)
			return dateInterval
		}
		var weekDateInterval: DateInterval {
			let interval = Calendar.current.dateIntervalOfWeek(
				for: Date()
			)
			return interval
		}
		var monthDateInterval: DateInterval {
			let interval = Calendar.current.dateIntervalOfMonth(
				for: Date()
			)
			return interval
		}
		var yearDateInterval: DateInterval {
			let interval = Calendar.current.dateIntervalOfYear(
				for: Date()
			)
			return interval
		}

		ScrollView {
			VStack {
				CareEssentialChartView(
					title: task.title ?? "",
					subtitle: "Day",
					dateInterval: dayDateInterval,
					period: .day,
					configurations: [configurationBar]
				)
				CareEssentialChartView(
					title: task.title ?? "",
					subtitle: "Week",
					dateInterval: weekDateInterval,
					period: .weekday,
					configurations: [configurationBar]
				)
				CareEssentialChartView(
					title: task.title ?? "",
					subtitle: "Month",
					dateInterval: monthDateInterval,
					period: .month,
					configurations: [configurationBar]
				)
				CareEssentialChartView(
					title: task.title ?? "",
					subtitle: "Year",
					dateInterval: yearDateInterval,
					period: .year,
					configurations: [configurationBar]
				)
			}
			.padding()
		}
		.environment(\.careStore, previewStore)
	}
}
