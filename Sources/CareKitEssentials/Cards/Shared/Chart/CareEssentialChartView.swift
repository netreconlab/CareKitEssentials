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

public struct CareEssentialChartView: CareKitEssentialView {
    @Environment(\.careStore) public var store
    @Environment(\.isCardEnabled) private var isCardEnabled
    @CareStoreFetchRequest(query: query()) private var events

    let title: String
    let subtitle: String
    let dateInterval: DateInterval
    let period: Calendar.Component
    let configurations: [CKEDataSeriesConfiguration]

	@State var legendColors = [String: Color]()

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
				.chartXAxis {
					AxisMarks(stroke: StrokeStyle(lineWidth: 0))
				}
				.chartYAxis {
					AxisMarks(position: .leading)
				}
				.chartForegroundStyleScale { (name: String) in
					legendColors[name] ?? .clear
				}

            }
            .padding(isCardEnabled ? [.all] : [])
        }
		.onAppear {
            updateQuery()
		}
		.onReceive(events.publisher) { _ in
			updateLegendColors(dataSeries: dataSeries)
		}
    }

    static func query(taskIDs: [String]? = nil) -> OCKEventQuery {
		let interval = Calendar.current.dateInterval(
			of: .weekOfYear,
			for: Date()
		)!

		var query = OCKEventQuery(dateInterval: interval)
		query.taskIDs = taskIDs ?? []

		return query
    }

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
		events.query.dateInterval = dateInterval
		if currentTaskIDs != updatedTaskIDs {
			events.query.taskIDs = Array(updatedTaskIDs)
		}

    }

	private func updateLegendColors(dataSeries: [CKEDataSeries]) {
		let updatedLegendColors = dataSeries.reduce(into: [String: Color]()) { colors, series in
			colors[series.title] = series.color
		}
		let updatedUniqueLegendColors = Set(updatedLegendColors.keys)
		let currentUniqueLegendColors = Set(legendColors.keys)
		guard updatedUniqueLegendColors != currentUniqueLegendColors else {
			return
		}
		legendColors = updatedLegendColors
	}

    private func computeProgress(
        for event: OCKAnyEvent,
        configuration: CKEDataSeriesConfiguration
    ) -> LinearCareTaskProgress {
        configuration
            .computeProgress(event)
    }

    private func computeDataSeries(
        forProgress allProgress: [TemporalProgress<LinearCareTaskProgress>],
        progressLabels: [String],
        configuration: CKEDataSeriesConfiguration
    ) throws -> CKEDataSeries {

        let combinedProgressValues = allProgress.map { progress -> Double in

            let combinedProgressValues = progress.values
                .map { $0.value }

			switch configuration.dataStrategy {
			case .sum:
				let combinedProgressValue = combinedProgressValues.reduce(0, +)

				return combinedProgressValue
			case .average:
				let combinedProgressValue = LinearCareTaskProgress.computeProgressByAveraging(for: combinedProgressValues).value

				return combinedProgressValue
			case .median:
				let combinedProgressValue = LinearCareTaskProgress.computeProgressByMedian(for: combinedProgressValues).value

				return combinedProgressValue
			}

        }

        let combinedProgressPoints = zip(
            progressLabels,
			combinedProgressValues
        ).map {
            CKEPoint(
                x: $0,
                y: $1,
                accessibilityValue: "\(configuration.legendTitle), \($0), \($1)"
            )
        }

        let series = CKEDataSeries(
            dataPoints: combinedProgressPoints,
			configuration: configuration
        )

        return series
    }

    // BAKER: Build symbols for rest of calendar periods.
    private func calendarSymbols() -> [String] {
		switch period {

		case .day, .dayOfYear:
			return ChartParameters.day.xAxisLabels

		case .weekday, .weekOfMonth, .weekOfYear:
#if watchOS
			return Calendar.current.orderedWeekdaySymbolsShort()
#else
			return Calendar.current.orderedWeekdaySymbols()
#endif

		case .month:
			return ChartParameters.month.xAxisLabels

		case .year:
#if watchOS
			return Calendar.current.veryShortMonthSymbols()
#else
			return Calendar.current.standaloneMonthSymbols
#endif
		default:
#if watchOS
			return Calendar.current.orderedWeekdaySymbolsShort()
#else
			return Calendar.current.orderedWeekdaySymbols()
#endif
		}
    }

    private func graphDataForEvents(
        _ events: CareStoreFetchedResults<OCKAnyEvent, OCKEventQuery>
    ) -> [CKEDataSeries] {

        let progressLabels = calendarSymbols()
        let eventsGroupedByTaskID = groupEventsByTaskID(events)

        // swiftlint:disable:next line_length
        let progressForAllConfigurations = configurations.map { configuration -> TemporalTaskProgress<LinearCareTaskProgress> in

            guard let events = eventsGroupedByTaskID[configuration.taskID] else {
                let progress = TemporalTaskProgress<LinearCareTaskProgress>(
                    id: configuration.id,
                    progressPerDates: []
                )
                return progress
            }

            let progress = periodicProgressForConfiguration(
                id: configuration.id,
                events: events,
                per: period,
                dateInterval: dateInterval,
                computeProgress: { event in
                    computeProgress(
                        for: event,
                        configuration: configuration
                    )
                }
            )

            return progress
        }

        do {
            let dataSeries = try configurations.map { configuration -> CKEDataSeries in

                // Iterating first through the configurations ensures the final data series order
                // matches the order of the configurations
                let periodicProgress = progressForAllConfigurations
                    .first { $0.id == configuration.id }?
                    .progressPerDates ?? []

                let dataSeries = try computeDataSeries(
                    forProgress: periodicProgress,
                    progressLabels: progressLabels,
                    configuration: configuration
                )

                return dataSeries
            }

            return dataSeries

        } catch {
            Logger.essentialChartView.error(
                "Cannot generate data series: \(error)"
            )
            return []
        }
    }
}

// MARK: Periodic Progress
extension CareEssentialChartView {

    func groupEventsByTaskID(
        _ events: CareStoreFetchedResults<OCKAnyEvent, OCKEventQuery>
    ) -> [String: [OCKAnyEvent]] {
        events.reduce(into: [String: [OCKAnyEvent]]()) {
            let events = $0[$1.result.task.id] ?? [OCKAnyEvent]()
            $0[$1.result.task.id] = events + [$1.result]
        }
    }

    /// Computes ordered daily progress for each day in the provided interval.
    /// The progress for each day will be split by task.
    /// Days with no events will have a nil progress value.
    /// - Parameters:
    ///   - events: Used to fetch the event data.
    ///   - dateInterval: Progress will be computed for each day in the interval.
    ///   - computeProgress: Used to compute progress for an event.
    func periodicProgressForConfiguration<Progress>(
        id: String,
        events: [OCKAnyEvent],
        per component: Calendar.Component,
        dateInterval: DateInterval,
        computeProgress: @escaping (OCKAnyEvent) -> Progress
    ) -> TemporalTaskProgress<Progress> {

        let progressPerPeriod = periodicProgress(
            for: events,
            per: component,
            dateInterval: dateInterval,
            computeProgress: computeProgress
        )

        let temporalProgress = TemporalTaskProgress(
            id: id,
            progressPerDates: progressPerPeriod
        )

        return temporalProgress
    }

    private func periodicProgress<Progress>(
        for events: [OCKAnyEvent],
        per component: Calendar.Component,
        dateInterval: DateInterval,
        computeProgress: @escaping (OCKAnyEvent) -> Progress
    ) -> [TemporalProgress<Progress>] {

        let calendar = Calendar.current

        // Create a dictionary that has a key for each component in the provided interval.

		var periodComponentsInInterval: [(DateComponents, Calendar.Component)] = []
		var currentDate = dateInterval.start.startOfDay

		while currentDate < dateInterval.end.endOfDay {
			let valueToIncrementBy = 1
            let periodComponent = uniqueComponents(
				for: currentDate,
				during: component
			)
            periodComponentsInInterval.append(periodComponent)
            currentDate = calendar.date(
				byAdding: periodComponent.1,
                value: valueToIncrementBy,
                to: currentDate
            )!
        }

        // Group the events by the component they started
        let eventsGroupedByPeriodComponent = Dictionary(
            grouping: events,
			by: {
				uniqueComponents(
					for: $0.sortedOutcome?.values.first?.createdDate ?? $0.scheduleEvent.start,
					during: component
				).0
			}
        )

        // Iterate through the events on each component and update the stored progress values
		// swiftlint:disable:next line_length
        let progressPerPeriodComponent = periodComponentsInInterval.map { periodComponent -> TemporalProgress<Progress> in

			let events = eventsGroupedByPeriodComponent[periodComponent.0] ?? []

            let progressForEvents = events.map { event in
                computeProgress(event)
            }

			let dateOfPeriodComponent = calendar.date(from: periodComponent.0)!

            let temporalProgress = TemporalProgress(
                values: progressForEvents,
                date: dateOfPeriodComponent
            )

            return temporalProgress
        }

        return progressPerPeriodComponent
    }

	private func uniqueComponents(
		for date: Date,
		during period: Calendar.Component
	) -> (DateComponents, Calendar.Component) {
		switch period {
		case .day, .dayOfYear:
			let component = Calendar.Component.hour
			let dateComponents = Calendar.current.dateComponents(
				[.year, .month, .day, component],
				from: date
			)
			return (dateComponents, component)
		case .weekday, .weekOfMonth, .weekOfYear:
			let component = Calendar.Component.day
			let dateComponents = Calendar.current.dateComponents(
				[.year, .month, component],
				from: date
			)
			return (dateComponents, component)
		case .month:
			let component = Calendar.Component.weekOfMonth
			let dateComponents = Calendar.current.dateComponents(
				[.year, component],
				from: date
			)
			return (dateComponents, component)
		case .year:
			let component = Calendar.Component.month
			let dateComponents = Calendar.current.dateComponents(
				[.year, component],
				from: date
			)
			return (dateComponents, component)
		default:
			let component = Calendar.Component.day
			let dateComponents = Calendar.current.dateComponents(
				[.year, .month, component],
				from: date
			)
			return (dateComponents, component)
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

        ScrollView {
			VStack {
				CareEssentialChartView(
					title: task.title ?? "",
					subtitle: "Day",
					dateInterval: Calendar.current.dateIntervalOfWeek(for: Date()),
					period: .day,
					configurations: [configurationBar]
				)
				CareEssentialChartView(
					title: task.title ?? "",
					subtitle: "Week",
					dateInterval: Calendar.current.dateIntervalOfWeek(for: Date()),
					period: .weekday,
					configurations: [configurationBar]
				)
				CareEssentialChartView(
					title: task.title ?? "",
					subtitle: "Month",
					dateInterval: Calendar.current.dateIntervalOfWeek(for: Date()),
					period: .month,
					configurations: [configurationBar]
				)
				CareEssentialChartView(
					title: task.title ?? "",
					subtitle: "Year",
					dateInterval: Calendar.current.dateIntervalOfWeek(for: Date()),
					period: .year,
					configurations: [configurationBar]
				)
			}
			.padding()
        }
        .environment(\.careStore, previewStore)
    }
}
