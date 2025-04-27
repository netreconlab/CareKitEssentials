//
//  CareKitEssentialChartable.swift
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

protocol CareKitEssentialChartable: CareKitEssentialView {
	var title: String { get }
	var subtitle: String { get }
	var dateInterval: DateInterval { get set }
	var period: Calendar.Component { get set }
	var configurations: [CKEDataSeriesConfiguration] { get set }
}

extension CareKitEssentialChartable {

	func graphDataForEvents(
		_ events: CareStoreFetchedResults<OCKAnyEvent, OCKEventQuery>
	) -> [CKEDataSeries] {

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

			do {
				let progress = try periodicProgressForConfiguration(
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
			} catch {
				Logger.essentialChartView.error(
					"Cannot compute progress for configuration \(configuration.id) because of error: \(error)"
				)
				let progress = TemporalTaskProgress<LinearCareTaskProgress>(
					id: configuration.id,
					progressPerDates: []
				)
				return progress
			}
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

	private func computeProgress(
		for event: OCKAnyEvent,
		configuration: CKEDataSeriesConfiguration
	) -> LinearCareTaskProgress {
		configuration
			.computeProgress(event)
	}

	private func computeDataSeries(
		forProgress allProgress: [TemporalProgress<LinearCareTaskProgress>],
		configuration: CKEDataSeriesConfiguration
	) throws -> CKEDataSeries {

		let combinedProgress = allProgress.map { progress -> CombinedProgress in

			let combinedProgressValues = progress.values
				.map { $0.value }

			switch configuration.dataStrategy {
			case .sum:
				let combinedProgressValue = combinedProgressValues.reduce(0, +)

				let combined = CombinedProgress(
					value: combinedProgressValue,
					date: progress.date,
					dateComponent: progress.dateComponent
				)
				return combined
			case .average:
				let combinedProgressValue = LinearCareTaskProgress.computeProgressByAveraging(for: combinedProgressValues).value

				let combined = CombinedProgress(
					value: combinedProgressValue,
					date: progress.date,
					dateComponent: progress.dateComponent
				)
				return combined
			case .median:
				let combinedProgressValue = LinearCareTaskProgress.computeProgressByMedian(for: combinedProgressValues).value

				let combined = CombinedProgress(
					value: combinedProgressValue,
					date: progress.date,
					dateComponent: progress.dateComponent
				)
				return combined
			}

		}

		let combinedProgressPoints = combinedProgress.map {
			CKEPoint(
				x: $0.date,
				xUnit: $0.dateComponent,
				y: $0.value,
				accessibilityValue: "\(configuration.legendTitle), \($0.date), \($0.value)"
			)
		}

		let series = CKEDataSeries(
			dataPoints: combinedProgressPoints,
			configuration: configuration
		)

		return series
	}

	// MARK: Periodic Progress
	private func groupEventsByTaskID(
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
	private func periodicProgressForConfiguration<Progress>(
		id: String,
		events: [OCKAnyEvent],
		per component: Calendar.Component,
		dateInterval: DateInterval,
		computeProgress: @escaping (OCKAnyEvent) -> Progress
	) throws -> TemporalTaskProgress<Progress> {

		let progressPerPeriod = try periodicProgress(
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
	) throws -> [TemporalProgress<Progress>] {

		let calendar = Calendar.current

		// Create a dictionary that has a key for each component in the provided interval.

		var periodComponentsInInterval: [DateComponentsForProgress] = []
		var currentDate = dateInterval.start.startOfDay

		while currentDate < dateInterval.end.endOfDay {
			let valueToIncrementBy = 1
			let periodComponent = try uniqueComponents(
				for: currentDate,
				during: component
			)
			periodComponentsInInterval.append(periodComponent)
			currentDate = calendar.date(
				byAdding: periodComponent.componentToIncrement,
				value: valueToIncrementBy,
				to: currentDate
			)!
		}

		// Group the events by the component they started
		let eventsGroupedByPeriodComponent = try Dictionary(
			grouping: events,
			by: {
				try uniqueComponents(
					for: $0.sortedOutcome?.values.first?.createdDate ?? $0.scheduleEvent.start,
					during: component
				).componentsForProgress
			}
		)

		// Iterate through the events on each component and update the stored progress values
		let progressPerPeriodComponent = periodComponentsInInterval.map { periodComponent -> TemporalProgress<Progress> in

			let events = eventsGroupedByPeriodComponent[periodComponent.componentsForProgress] ?? []

			let progressForEvents = events.map { event in
				computeProgress(event)
			}

			let dateOfPeriodComponent = calendar.date(from: periodComponent.componentsForProgressWithDay)!

			let temporalProgress = TemporalProgress(
				values: progressForEvents,
				date: dateOfPeriodComponent,
				dateComponent: periodComponent.componentToIncrement
			)

			return temporalProgress
		}

		return progressPerPeriodComponent
	}

	private func uniqueComponents(
		for date: Date,
		during period: Calendar.Component
	) throws -> DateComponentsForProgress {
		switch period {
		case .day, .dayOfYear:
			let component = Calendar.Component.hour
			let dateComponents = Calendar.current.dateComponents(
				[.year, .month, .day, component],
				from: date
			)
			let progressComponents = DateComponentsForProgress(
				componentsForProgress: dateComponents,
				componentsForProgressWithDay: dateComponents,
				componentToIncrement: component
			)
			return progressComponents
		case .weekday, .weekOfMonth, .weekOfYear:
			let component = Calendar.Component.day
			let dateComponents = Calendar.current.dateComponents(
				[.year, .month, component],
				from: date
			)
			let progressComponents = DateComponentsForProgress(
				componentsForProgress: dateComponents,
				componentsForProgressWithDay: dateComponents,
				componentToIncrement: component
			)
			return progressComponents
		case .month:
			let component = Calendar.Component.weekOfMonth
			let dateComponents = Calendar.current.dateComponents(
				[.year, .month, component],
				from: date
			)
			let dateComponentsWithDay = Calendar.current.dateComponents(
				[.year, .month, .day, component],
				from: date
			)
			let progressComponents = DateComponentsForProgress(
				componentsForProgress: dateComponents,
				componentsForProgressWithDay: dateComponentsWithDay,
				componentToIncrement: component
			)
			return progressComponents
		case .year:
			let component = Calendar.Component.month
			let dateComponents = Calendar.current.dateComponents(
				[.year, component],
				from: date
			)
			let dateComponentsWithDay = Calendar.current.dateComponents(
				[.year, .day, component],
				from: date
			)
			let progressComponents = DateComponentsForProgress(
				componentsForProgress: dateComponents,
				componentsForProgressWithDay: dateComponentsWithDay,
				componentToIncrement: component
			)
			return progressComponents
		default:
			throw CareKitEssentialsError.errorString("Unsupported type of period")
		}
	}
}
