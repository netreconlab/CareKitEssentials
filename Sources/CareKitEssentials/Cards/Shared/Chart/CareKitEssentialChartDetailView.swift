//
//  CareKitEssentialChartDetailView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/26/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import Charts
import Foundation
import os.log
import SwiftUI

struct CareKitEssentialChartDetailView: CareKitEssentialChartable {
	@Environment(\.careStore) public var store
	@Environment(\.dismiss) var dismiss
	@CareStoreFetchRequest(query: query()) private var events

	let title: String
	let subtitle: String
	var dateInterval: DateInterval
	var period: Calendar.Component
	var configurations: [CKEDataSeriesConfiguration]

	var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				CareKitEssentialChartHeaderView(
					title: title,
					subtitle: subtitle
				)
				.padding(.bottom)

				let dataSeries = graphDataForEvents(events)
				CareKitEssentialChartBodyView(
					dataSeries: dataSeries,
					useFullAspectRating: true
				)
				.onAppear {
					updateQuery()
				}
				.onChange(of: dateInterval) { _ in
					updateQuery()
				}
				.onChange(of: configurations) { _ in
					updateQuery()
				}
				.onReceive(events.publisher) { _ in
					updateQuery()
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Text(title)
					.font(.title)
					.bold()
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: {
					dismiss()
				}) {
					Image(systemName: "x.circle.fill")
						.foregroundStyle(.gray)
						.opacity(0.5)
				}
			}
		}
	}

	static func query(taskIDs: [String]? = nil) -> OCKEventQuery {
		eventQuery(
			with: taskIDs ?? [],
			on: Date()
		)
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
	}

	private func updateQuery() {
		let currentTaskIDs = Set(events.query.taskIDs)
		let updatedTaskIDs = Set(configurations.map(\.taskID))
		if currentTaskIDs != updatedTaskIDs {
			events.query.taskIDs = Array(updatedTaskIDs)
		}
		if events.query.dateInterval != dateInterval {
			events.query.dateInterval = dateInterval
		}
	}
}

struct CareKitEssentialChartDetailView_Previews: PreviewProvider {
	static var previews: some View {
		let task = Utility.createNauseaTask()
		let configurationBar = CKEDataSeriesConfiguration(
			taskID: task.id,
			mark: .bar,
			legendTitle: "Bar",
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

		NavigationStack {
			VStack { /*
				CareKitEssentialChartView(
					title: task.title ?? "",
					subtitle: "Day",
					dateInterval: dayDateInterval,
					period: .day,
					configurations: [configurationBar]
				) */
				CareKitEssentialChartDetailView(
					title: task.title ?? "",
					subtitle: "Week",
					dateInterval: weekDateInterval,
					period: .weekday,
					configurations: [configurationBar]
				) /*
				CareKitEssentialChartView(
					title: task.title ?? "",
					subtitle: "Month",
					dateInterval: monthDateInterval,
					period: .month,
					configurations: [configurationBar]
				)
				CareKitEssentialChartView(
					title: task.title ?? "",
					subtitle: "Year",
					dateInterval: yearDateInterval,
					period: .year,
					configurations: [configurationBar]
				) */
			}
			.padding()
		}
		.environment(\.careStore, previewStore)
	}
}
