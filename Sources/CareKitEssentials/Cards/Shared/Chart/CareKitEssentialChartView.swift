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
	@Binding var period: PeriodComponent
	var configurations: [String: CKEDataSeriesConfiguration]
	let orderedConfigurations: [CKEDataSeriesConfiguration]

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
			}
			.padding(isCardEnabled ? [.all] : [])
		}
		.sheet(isPresented: $isShowingDetail) {
			NavigationStack {
				CareKitEssentialChartDetailView(
					title: title,
					subtitle: subtitle,
					dateInterval: dateInterval,
					period: period,
					configurations: configurations,
					orderedConfigurations: orderedConfigurations
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
		period: Binding<PeriodComponent>,
		configurations: [CKEDataSeriesConfiguration]
	) {
		self.title = title
		self.subtitle = subtitle
		self.orderedConfigurations = configurations
		self.configurations = configurations.reduce(into: [String: CKEDataSeriesConfiguration]()) { currentConfigurations, configuration in
			currentConfigurations[configuration.id] = configuration
		}
		_dateInterval = dateInterval
		_period = period
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

struct CareKitEssentialChartView_Previews: PreviewProvider {

	static var weekDateInterval: DateInterval {
		let interval = Calendar.current.dateIntervalOfWeek(
			for: Date()
		)
		return interval

	}
	static var previews: some View {
		let task = Utility.createNauseaTask()
		let previewStore = Utility.createPreviewStore()
		@State var intervalSelected = 1
		@State var dateInterval: DateInterval = weekDateInterval
		@State var period: PeriodComponent = .week
		let configurations: [CKEDataSeriesConfiguration] = [
			CKEDataSeriesConfiguration(
				taskID: task.id,
				mark: .bar,
				legendTitle: "Bar",
				color: .red,
				gradientStartColor: .gray
			)
		]

		ScrollView {
			CareKitEssentialChartView(
				title: task.title ?? "",
				subtitle: "Chart",
				dateInterval: $dateInterval,
				period: $period,
				configurations: configurations
			)
		}
		.padding()
		.environment(\.careStore, previewStore)
	}
}
