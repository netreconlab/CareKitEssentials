//
//  Calendar+Dates.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 10/16/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

public extension Calendar {
    /**
        Returns a tuple containing the start and end dates for the week that the
        specified date falls in.
     */
    func weekDatesForDate(_ date: Date) -> (start: Date, end: Date) {
        var interval: TimeInterval = 0
        var start: Date = Date()
        _ = dateInterval(of: .weekOfYear, start: &start, interval: &interval, for: date)
        let end = start.addingTimeInterval(interval)

        return (start as Date, end as Date)
    }

    /// Returns a date interval that spans the entire week of the given date. The difference between this method and the
    /// Foundation `Calendar.dateInterval(of:for:)` method is that this method produces non-overlapping
    /// intervals.
    func dateIntervalOfWeek(for date: Date) -> DateInterval {
        var interval = Calendar.current.dateInterval(of: .weekOfYear, for: date)!
        // The default interval contains 1 second of the next day after the interval.
        // Subtract that off.
        interval.duration -= 1
        return interval
    }

	/// Returns a date interval that spans the entire month of the given date. The difference between this method and the
	/// Foundation `Calendar.dateInterval(of:for:)` method is that this method produces non-overlapping
	/// intervals.
	func dateIntervalOfMonth(for date: Date) -> DateInterval {
		var interval = Calendar.current.dateInterval(of: .month, for: date)!
		// The default interval contains 1 second of the next day after the interval.
		// Subtract that off.
		interval.duration -= 1
		return interval
	}

	/// Returns a date interval that spans the entire year of the given date. The difference between this method and the
	/// Foundation `Calendar.dateInterval(of:for:)` method is that this method produces non-overlapping
	/// intervals.
	func dateIntervalOfYear(for date: Date) -> DateInterval {
		var interval = Calendar.current.dateInterval(of: .year, for: date)!
		// The default interval contains 1 second of the next day after the interval.
		// Subtract that off.
		interval.duration -= 1
		return interval
	}
}

public extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow: Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    // Reference: https://stackoverflow.com/a/20158940/4639041
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
