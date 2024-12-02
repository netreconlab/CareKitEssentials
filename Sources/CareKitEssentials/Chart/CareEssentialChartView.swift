//
//  CareEssentialChartView.swift
//  Assuage
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

    @Environment(\.careStore) public var careStore
    @CareStoreFetchRequest(query: query()) private var events

    let title: String
    let subtitle: String
    let dateInterval: DateInterval
    let period: Calendar.Component
    let configurations: [CKEDataSeriesConfiguration]
    let paddingSize = 15.0

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
            .padding()
        }.onAppear {
            updateQuery()
        }
    }

    static func query(taskIDs: [String]? = nil) -> OCKEventQuery {
        eventQuery(
            with: taskIDs ?? [],
            on: .init()
        )
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
        var query = OCKEventQuery(dateInterval: dateInterval)
        query.taskIDs = configurations.map(\.taskID)
        events.query = query
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

        let summedProgressValues = allProgress.map { progress -> Double in

            let summedProgressValue = progress.values
                .map { $0.value }
                .reduce(0, +)

            return summedProgressValue
        }

        let summedProgressPoints = zip(
            progressLabels,
            summedProgressValues
        ).map {
            CKEPoint(
                x: $0,
                y: $1,
                accessibilityValue: "\(configuration.legendTitle), \($0), \($1)"
            )
        }

        let series = CKEDataSeries(
            mark: configuration.mark,
            dataPoints: summedProgressPoints,
            title: configuration.legendTitle,
            gradientStartColor: configuration.gradientStartColor,
            gradientEndColor: configuration.gradientEndColor,
            width: configuration.width,
            height: configuration.height,
            stackingMethod: configuration.stackingMethod
        )

        return series
    }

    // BAKER: Build symbols for rest of calendar periods.
    private func calendarSymbols() -> [String] {
        switch period {
        case .day:
            return Calendar.current.orderedWeekdaySymbols()
        default:
            return Calendar.current.orderedWeekdaySymbols()
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

        let progressPerDays = periodicProgress(
            for: events,
            per: component,
            dateInterval: dateInterval,
            computeProgress: computeProgress
        )

        let temporalProgress = TemporalTaskProgress(
            id: id,
            progressPerDates: progressPerDays
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

        // Create a dictionary that has a key for each day in the provided interval.

        var daysInInterval: [DateComponents] = []
        var currentDate = dateInterval.start

        while currentDate < dateInterval.end {
            let day = uniqueDayComponents(for: currentDate)
            daysInInterval.append(day)
            currentDate = calendar.date(
                byAdding: component,
                value: 1,
                to: currentDate
            )!
        }

        // Group the events by the day they started

        let eventsGroupedByDay = Dictionary(
            grouping: events,
            by: { uniqueDayComponents(for: $0.scheduleEvent.start) }
        )

        // Iterate through the events on each day and update the stored progress values
        let progressPerDay = daysInInterval.map { day -> TemporalProgress<Progress> in

            let events = eventsGroupedByDay[day] ?? []

            let progressForEvents = events.map { event in
                computeProgress(event)
            }

            let dateOfDay = calendar.date(from: day)!

            let temporalProgress = TemporalProgress(
                values: progressForEvents,
                date: dateOfDay
            )

            return temporalProgress
        }

        return progressPerDay
    }

    private func uniqueDayComponents(for date: Date) -> DateComponents {
        Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )
    }
}

#Preview {
    let task = Utility.createNauseaTask()
    let configurationBar = CKEDataSeriesConfiguration(
        taskID: task.id,
        mark: .bar,
        legendTitle: "Bar",
        color: .red,
        gradientStartColor: .gray,
        gradientEndColor: .red
    )
    let previewStore = Utility.createPreviewStore()

    VStack {
        CareEssentialChartView(
            title: task.title ?? "",
            subtitle: "Week",
            dateInterval: Calendar.current.dateIntervalOfWeek(for: Date()),
            period: .day,
            configurations: [configurationBar]
        )
    }
    .environment(\.careStore, previewStore)
}
