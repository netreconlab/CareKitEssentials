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

struct CareEssentialChartView: CareKitEssentialView {

    @Environment(\.careStore) var careStore
    @CareStoreFetchRequest(query: query()) private var events

    let title: String
    let subtitle: String
    let dateInterval: DateInterval
    let period: Calendar.Component
    let configurations: [CKEDataSeriesConfiguration]
    let paddingSize = 15.0

    var body: some View {

        let dataSeries = graphDataForEvents(events)
        CardView {
            VStack(alignment: .leading) {
                CareEssentialChartViewHeader(
                    title: title,
                    subtitle: subtitle
                )

                Chart(dataSeries) { data in
                    let gradient = Gradient(
                        colors: [
                            data.gradientStartColor ?? .accentColor,
                            data.gradientEndColor ?? .accentColor
                        ]
                    )
                    ForEach(data.dataPoints) { point in
                        data.mark.chartContent(
                            xLabel: "Date",
                            xValue: String(point.x.prefix(3)),
                            yLabel: "Value",
                            yValue: point.y
                        )
                        .accessibilityValue(Text(point.accessibilityValue ?? ""))
                    }
                    .foregroundStyle(
                        .linearGradient(
                            gradient,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .foregroundStyle(by: .value("Task", data.title))
                }
                .chartXAxis {
                    AxisMarks(stroke: StrokeStyle(lineWidth: 0))
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .padding()
            }
        }.onAppear {
            updateQuery()
        }
    }

    func updateQuery() {
        var query = OCKEventQuery(dateInterval: dateInterval)
        query.taskIDs = configurations.map(\.taskID)
        events.query = query
    }

    static func query(taskIDs: [String]? = nil) -> OCKEventQuery {
        eventQuery(
            with: [""],
            on: .init()
        )
    }

    private static func computeProgress(
        for event: OCKAnyEvent,
        configurations: [CKEDataSeriesConfiguration]
    ) -> LinearCareTaskProgress {

        let computeProgress = configurations
            .first { $0.taskID == event.task.id }?
            .computeProgress

        guard let computeProgress else {
            return event.computeProgress(by: .summingOutcomeValues)
        }

        return computeProgress(event)
    }

    private static func dataSeries(
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
            size: configuration.markerSize
        )

        return series
    }

    // BAKER: Build symbols for rest of calendar periods.
    func calendarSymbols() -> [String] {
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

        let progressSplitByTask = periodicProgressSplitByTask(
            events: events,
            per: period,
            dateInterval: dateInterval,
            computeProgress: { event in
                Self.computeProgress(for: event, configurations: configurations)
            }
        )

        do {
            let dataSeries = try configurations.map { configuration -> CKEDataSeries in
                // Iterating first through the configurations ensures the final data series order
                // matches the order of the configurations
                let periodicProgress = progressSplitByTask
                    .first { $0.taskID == configuration.taskID }?
                    .progressPerDates

                let dataSeries = try Self.dataSeries(
                    forProgress: periodicProgress ?? [],
                    progressLabels: progressLabels,
                    configuration: configuration
                )

                return dataSeries
            }

            return dataSeries
        } catch {
            print("Cannot generate data series: \(error)")
            return []
        }
    }
}

// MARK: Periodic Progress
extension CareEssentialChartView {

    /// Computes ordered daily progress for each day in the provided interval.
    /// The progress for each day will be split by task.
    /// Days with no events will have a nil progress value.
    /// - Parameters:
    ///   - events: Used to fetch the event data.
    ///   - dateInterval: Progress will be computed for each day in the interval.
    ///   - computeProgress: Used to compute progress for an event.
    func periodicProgressSplitByTask<Progress>(
        events: CareStoreFetchedResults<OCKAnyEvent, OCKEventQuery>,
        per component: Calendar.Component,
        dateInterval: DateInterval,
        computeProgress: @escaping (OCKAnyEvent) -> Progress
    ) -> [TemporalTaskProgress<Progress>] {

        // Group the events by task
        let eventsGroupedByTask = events.reduce(into: [String: [OCKAnyEvent]]()) {
            let events = $0[$1.result.task.id] ?? [OCKAnyEvent]()
            $0[$1.result.task.id] = events + [$1.result]
        }

        // Compute the progress for each task
        let progress = eventsGroupedByTask.map { taskID, events -> TemporalTaskProgress<Progress> in

            let progressPerDays = Self.periodicProgress(
                for: events,
                per: component,
                dateInterval: dateInterval,
                computeProgress: computeProgress
            )

            return TemporalTaskProgress(taskID: taskID, progressPerDates: progressPerDays)
        }

        return progress
    }

    private static func periodicProgress<Progress>(
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

    private static func uniqueDayComponents(for date: Date) -> DateComponents {
        return Calendar.current.dateComponents(
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
        gradientStartColor: .gray,
        gradientEndColor: .red,
        markerSize: 2
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
