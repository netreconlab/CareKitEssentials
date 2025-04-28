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

	var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				/*
				CareKitEssentialChartHeaderView(
					title: title,
					subtitle: subtitle
				)
				.padding(.bottom)
				 */
				let dataSeries = graphDataForEvents(events)
				CareKitEssentialChartBodyView(
					dataSeries: dataSeries,
					useFullAspectRating: true,
					showGridLines: true
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
		#if !os(watchOS) && !os(macOS)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Text(title)
					.font(.title3)
					.bold()
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button(action: {
					dismiss()
				}) {
					Image(systemName: "x.circle.fill")
						.foregroundStyle(.gray)
						.opacity(0.5)
				}
			}
		}
		#endif
	}

	static func query(taskIDs: [String]? = nil) -> OCKEventQuery {
		eventQuery(
			with: taskIDs ?? [],
			on: Date()
		)
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
		let previewStore = Utility.createPreviewStore()

		var weekDateInterval: DateInterval {
			let interval = Calendar.current.dateIntervalOfWeek(
				for: Date()
			)
			return interval
		}

		NavigationStack {
			VStack {
				CareKitEssentialChartDetailView(
					title: task.title ?? "",
					subtitle: "Week",
					dateInterval: weekDateInterval,
					period: .week,
					configurations: [task.id: configurationBar]
				)
			}
			.padding()
		}
		.environment(\.careStore, previewStore)
	}
}
