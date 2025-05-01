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
	@State var dateInterval: DateInterval
	@State var period: PeriodComponent
	@State var configurations: [String: CKEDataSeriesConfiguration]
	let orderedConfigurations: [CKEDataSeriesConfiguration]

	var body: some View {
		ViewThatFits {
			#if !os(watchOS)
			splitView
			#endif
			verticalView
		}
		.toolbar {
			#if !os(watchOS)
			ToolbarItem(placement: .automatic) {
				fullScreenView
			}
			#else
			ToolbarItem(placement: .topBarTrailing) {
				fullScreenView
			}
			#endif
		}

	}

	static func query(taskIDs: [String]? = nil) -> OCKEventQuery {
		eventQuery(
			with: taskIDs ?? [],
			on: Date()
		)
	}

	var splitView: some View {
		NavigationSplitView(
			sidebar: {
				configurationView
			}
		) {
			chartView
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

	var verticalView: some View {
		VStack {
			chartView
			configurationView
		}
	}

	var configurationView: some View {
		List {
			Section(
				header: Text("PERIOD")
			) {
				periodPickerView
			}
			Section(
				header: Text("DATE_RANGE")
			) {
				startDatePickerView
				endDatePickerView
			}
			ForEach(orderedConfigurations) { configuration in
				let configurationId = configuration.id
				let currentConfiguration = configurations[configurationId] ?? configuration

				Section(
					header: Text(currentConfiguration.legendTitle)
				) {
					CKEConfigurationView(
						configurationId: configurationId,
						configurations: $configurations,
						markSelected: currentConfiguration.mark,
						dataStrategySelected: currentConfiguration.dataStrategy,
						isShowingMarkHighlighted: currentConfiguration.showMarkWhenHighlighted,
						isShowingMeanMark: currentConfiguration.showMeanMark,
						isShowingMedianMark: currentConfiguration.showMedianMark
					)
				}

			}
		}
		.listStyle(.automatic)
	}

	var chartView: some View {
		let dataSeries = graphDataForEvents(events)

		return CareKitEssentialChartBodyView(
			dataSeries: dataSeries,
			dateInterval: dateInterval,
			showGridLines: true
		)
	}

	var startDatePickerView: some View {
		DatePicker(
			"START_DATE",
			selection: $dateInterval.start,
			displayedComponents: [.date, .hourAndMinute]
		)
		.datePickerStyle(.automatic)
	}

	var endDatePickerView: some View {
		DatePicker(
			"END_DATE",
			selection: $dateInterval.end,
			displayedComponents: [.date, .hourAndMinute]
		)
		.datePickerStyle(.automatic)
	}

	var periodPickerView: some View {
		Picker(
			"CHOOSE_PERIOD",
			selection: $period.animation()
		) {
			Text("DAY")
				.tag(PeriodComponent.day)
			Text("WEEK")
				.tag(PeriodComponent.week)
			Text("MONTH")
				.tag(PeriodComponent.month)
			Text("YEAR")
				.tag(PeriodComponent.year)
		}
		#if !os(watchOS)
		.pickerStyle(.segmented)
		#else
		.pickerStyle(.automatic)
		#endif
	}

	var fullScreenView: some View {
		NavigationLink(
			destination: {
				let dataSeries = graphDataForEvents(events)
				CareKitEssentialChartBodyView(
					dataSeries: dataSeries,
					dateInterval: dateInterval,
					showGridLines: true
				)
				#if !os(watchOS)
				.aspectRatio(
					CGSize(width: 16, height: 9),
					contentMode: .fit
				)
				#endif
				.padding()
			}
		) {
			Image(systemName: "inset.filled.rectangle.and.person.filled")
		}
	}

	private func updateQuery() {
		let currentTaskIDs = Set(events.query.taskIDs)
		let updatedTaskIDs = Set(configurations.values.map(\.taskID))
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
		let configurationLine = CKEDataSeriesConfiguration(
			taskID: task.id,
			mark: .line,
			legendTitle: "Line",
			color: .red,
			gradientStartColor: .gray
		)
		let previewStore = Utility.createPreviewStore()

		var weekDateInterval: DateInterval {
			let interval = Calendar.current.dateIntervalOfWeek(
				for: Date()
			)
			return interval
		}

		NavigationStack {
			CareKitEssentialChartDetailView(
				title: task.title ?? "",
				subtitle: "Week",
				dateInterval: weekDateInterval,
				period: .week,
				configurations: [
					configurationBar.id: configurationBar,
					configurationLine.id: configurationLine
				],
				orderedConfigurations: [
					configurationBar,
					configurationLine
				]
			)
			.padding()
		}
		.environment(\.careStore, previewStore)
	}
}
