//
//  CareKitEssentialChartable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/26/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import Charts
import Foundation
import os.log
import SwiftUI

protocol CareKitEssentialChartable: CareKitEssentialView {
	var title: String { get }
	var subtitle: String { get }
	var dateInterval: DateInterval { get set }
	var period: PeriodComponent { get set }
	var configurations: [String: CKEDataSeriesConfiguration] { get set }
	var orderedConfigurations: [CKEDataSeriesConfiguration] { get }
}

extension CareKitEssentialChartable {

	func graphDataForEvents(
		_ events: CareStoreFetchedResults<OCKAnyEvent, OCKEventQuery>
	) -> [CKEDataSeries] {

		let eventsGroupedByTaskID = groupEventsByTaskID(events)

		// swiftlint:disable:next line_length
		let progressForAllConfigurations = orderedConfigurations.map { configuration -> TemporalTaskProgress<LinearCareTaskProgress> in

			guard let currentConfiguration = configurations[configuration.id],
				let events = eventsGroupedByTaskID[configuration.taskID] else {
				let progress = TemporalTaskProgress<LinearCareTaskProgress>(
					id: configuration.id,
					progressPerDates: []
				)
				return progress
			}

			let progress = periodicProgressForConfiguration(
				id: currentConfiguration.id,
				events: events,
				per: period,
				dateInterval: dateInterval,
				computeProgress: { event in
					computeProgress(
						for: event,
						configuration: currentConfiguration
					)
				}
			)

			return progress
		}

		do {
			let dataSeries = try orderedConfigurations.map { configuration -> CKEDataSeries in

				// Iterating first through the configurations ensures the final data series order
				// matches the order of the configurations
				guard let currentConfiguration = configurations[configuration.id] else {
					throw CareKitEssentialsError.errorString("Configuration not found")
				}

				let periodicProgress = progressForAllConfigurations
					.first { $0.id == currentConfiguration.id }?
					.progressPerDates ?? []

				let dataSeries = try computeDataSeries(
					forProgress: periodicProgress,
					configuration: currentConfiguration
				)

				return dataSeries
			}

			return dataSeries

		} catch {
			Logger.essentialChartable.error(
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
			// Always use last unit
			let combinedProgressUnit = progress.units?.last

			// Do a unit check and output warning if multiple
			if let units = progress.units {
				let uniqueUnits = Set(units)
				if uniqueUnits.count > 1 {
					Logger.essentialChartable.warning(
						"Multiple units found for progress: \(units), using last one: \(combinedProgressUnit ?? "")"
					)
				}
			}

			switch configuration.dataStrategy {
			case .sum:
				let combinedProgressValue = combinedProgressValues.reduce(0, +)
				let combined = CombinedProgress(
					value: combinedProgressValue,
					originalValues: combinedProgressValues,
					unit: combinedProgressUnit,
					date: progress.date,
					period: progress.period
				)
				return combined
			case .mean:
				let combinedProgressValue = LinearCareTaskProgress.computeProgressByAveraging(for: combinedProgressValues).value

				let combined = CombinedProgress(
					value: combinedProgressValue,
					originalValues: combinedProgressValues,
					unit: combinedProgressUnit,
					date: progress.date,
					period: progress.period
				)
				return combined
			case .median:
				let combinedProgressValue = LinearCareTaskProgress.computeProgressByMedian(for: combinedProgressValues).value

				let combined = CombinedProgress(
					value: combinedProgressValue,
					originalValues: combinedProgressValues,
					unit: combinedProgressUnit,
					date: progress.date,
					period: progress.period
				)
				return combined
			}

		}

		let combinedProgressPoints = combinedProgress.map {
			CKEPoint(
				x: $0.date,
				y: $0.value,
				yUnit: $0.unit,
				period: $0.period,
				originalValues: $0.originalValues,
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
		per periodComponent: PeriodComponent,
		dateInterval: DateInterval,
		computeProgress: @escaping (OCKAnyEvent) -> Progress
	) -> TemporalTaskProgress<Progress> {

		let progressPerPeriod = periodicProgress(
			for: events,
			per: periodComponent,
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
		per periodComponent: PeriodComponent,
		dateInterval: DateInterval,
		computeProgress: @escaping (OCKAnyEvent) -> Progress
	) -> [TemporalProgress<Progress>] {

		let calendar = Calendar.current

		// Create a dictionary that has a key for each component in the provided interval.

		var periodComponentsInInterval: [DateComponentsForProgress] = []
		var currentDate = dateInterval.start

		while currentDate <= dateInterval.end {
			let valueToIncrementBy = 1
			let periodComponent = periodComponent.relevantComponentsForProgress(
				for: currentDate
			)
			periodComponentsInInterval.append(periodComponent)
			currentDate = calendar.date(
				byAdding: periodComponent.componentToIncrement,
				value: valueToIncrementBy,
				to: currentDate
			)!
		}

		// Group the events by the component they started
		let eventsGroupedByPeriodComponent = Dictionary(
			grouping: events,
			by: {
				periodComponent.relevantComponentsForProgress(
					for: $0.sortedOutcome?.values.first?.createdDate ?? $0.scheduleEvent.start
				).componentsForProgress
			}
		)

		// Iterate through the events on each component and calculate progress values.
		let progressPerPeriodComponent = periodComponentsInInterval.map { periodComponent -> TemporalProgress<Progress> in

			let events = eventsGroupedByPeriodComponent[periodComponent.componentsForProgress] ?? []

			let progressForEvents = events.map { event -> Progress in
				computeProgress(event)
			}

			let valueUnits = events.reduce(into: [String]()) { units, event in
				guard let currentUnits = event.outcome?.values.compactMap(\.units) else {
					return
				}
				units.append(contentsOf: currentUnits)
			}
			let dateOfPeriodComponent = calendar.date(from: periodComponent.componentsForProgressWithDay)!

			let temporalProgress = TemporalProgress(
				values: progressForEvents,
				units: valueUnits,
				date: dateOfPeriodComponent,
				period: period
			)

			return temporalProgress
		}

		return progressPerPeriodComponent
	}
}
