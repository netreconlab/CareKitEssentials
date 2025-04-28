//
//  CareKitEssentialChartView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/27/25.
//

import CareKit
import CareKitStore
import CareKitUI
import Charts
import Foundation
import os.log
import SwiftUI

public struct CareKitEssentialChartView: CareKitEssentialChartable {
	@Environment(\.careStore) public var store
	@Environment(\.isCardEnabled) private var isCardEnabled
	@Environment(\.careKitStyle) private var style
	@CareStoreFetchRequest(query: query()) private var events
	@State var isShowingDetail: Bool = false

	let title: String
	let subtitle: String
	@Binding var dateInterval: DateInterval
	@Binding var periodComponent: PeriodComponent
	@Binding var configurations: [CKEDataSeriesConfiguration]

	public var body: some View {
		CardView {
			VStack(alignment: .leading) {
				HStack {
					CareKitEssentialChartHeaderView(
						title: title,
						subtitle: subtitle
					)
					Spacer()
					Image(systemName: "chevron.right")
						.imageScale(.small)
					#if os(iOS) || os(visionOS)
						.foregroundColor(Color(style.color.secondaryLabel))
					#else
						.foregroundColor(Color.secondary)
					#endif
				}
				.padding(.bottom)
				.onTapGesture {
					isShowingDetail.toggle()
				}
				Divider()

				let dataSeries = graphDataForEvents(events)
				CareKitEssentialChartBodyView(
					dataSeries: dataSeries
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
			.padding(isCardEnabled ? [.all] : [])
		}
		.sheet(isPresented: $isShowingDetail) {
			NavigationStack {
				CareKitEssentialChartDetailView(
					title: title,
					subtitle: subtitle,
					dateInterval: dateInterval,
					periodComponent: periodComponent,
					configurations: configurations
				)
				.padding()
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
		dateInterval: Binding<DateInterval>,
		periodComponent: Binding<PeriodComponent>,
		configurations: Binding<[CKEDataSeriesConfiguration]>
	) {
		self.title = title
		self.subtitle = subtitle
		_dateInterval = dateInterval
		_periodComponent = periodComponent
		_configurations = configurations
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

struct CareKitEssentialChartView_Previews: PreviewProvider {

	static var dayDateInterval: DateInterval {
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
	static var weekDateInterval: DateInterval {
		let interval = Calendar.current.dateIntervalOfWeek(
			for: Date()
		)
		return interval

	}
	static var monthDateInterval: DateInterval {
		let interval = Calendar.current.dateIntervalOfMonth(
			for: Date()
		)
		return interval

	}
	static var yearDateInterval: DateInterval {
		let interval = Calendar.current.dateIntervalOfYear(
			for: Date()
		)
		return interval

	}
	static var previews: some View {
		let task = Utility.createNauseaTask()
		let previewStore = Utility.createPreviewStore()
		@State var intervalSelected = 0
		@State var dateInterval: DateInterval = dayDateInterval
		@State var periodComponent: PeriodComponent = .day
		@State var configurations: [CKEDataSeriesConfiguration] = [
			CKEDataSeriesConfiguration(
				taskID: task.id,
				mark: .bar,
				legendTitle: "Bar",
				color: .red,
				gradientStartColor: .gray
			)
		]
		var subtitle: String {
			switch intervalSelected {
			case 0:
				return String(localized: "TODAY")
			case 1:
				return String(localized: "WEEK")
			case 2:
				return String(localized: "MONTH")
			case 3:
				return String(localized: "YEAR")
			default:
				return String(localized: "WEEK")
			}
		}

		VStack {

			Picker(
				"CHOOSE_DATE_INTERVAL",
				selection: $intervalSelected
			) {
				Text("TODAY")
					.tag(0)
				Text("WEEK")
					.tag(1)
				Text("MONTH")
					.tag(2)
				Text("YEAR")
					.tag(3)
			}
			.pickerStyle(.segmented)
			.padding(.vertical)

			Spacer()
			CareKitEssentialChartView(
				title: task.title ?? "",
				subtitle: subtitle,
				dateInterval: $dateInterval,
				periodComponent: $periodComponent,
				configurations: $configurations
			)
			Spacer()
		}
		.padding()
		.environment(\.careStore, previewStore)
	}
}
