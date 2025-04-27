//
//  CareEssentialChartView.swift
//  CareKitEssentials
//
//  Created by Zion Glover on 6/26/24.
//  Copyright © 2024 NetReconLab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import Charts
import Foundation
import os.log
import SwiftUI

public struct CareEssentialChartView: CareKitEssentialChartable {
    @Environment(\.careStore) public var store
    @Environment(\.isCardEnabled) private var isCardEnabled
    @CareStoreFetchRequest(query: query()) private var events

    let title: String
    let subtitle: String
    var dateInterval: DateInterval
    var period: Calendar.Component
    var configurations: [CKEDataSeriesConfiguration]

    public var body: some View {

        let dataSeries = graphDataForEvents(events)

        CardView {
            VStack(alignment: .leading) {
                CareEssentialChartHeaderView(
                    title: title,
                    subtitle: subtitle
                )
                .padding(.bottom)

                CareEssentialChartBodyView(
                    dataSeries: dataSeries
                )
            }
            .padding(isCardEnabled ? [.all] : [])
        }
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

struct CareEssentialChartView_Previews: PreviewProvider {
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
			let interval = Calendar.current.dateInterval(
				of: .weekOfYear,
				for: Date()
			)!
			return interval
		}
		var monthDateInterval: DateInterval {
			let interval = Calendar.current.dateInterval(
				of: .month,
				for: Date()
			)!
			return interval
		}
		var yearDateInterval: DateInterval {
			let interval = Calendar.current.dateInterval(
				of: .year,
				for: Date()
			)!
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
