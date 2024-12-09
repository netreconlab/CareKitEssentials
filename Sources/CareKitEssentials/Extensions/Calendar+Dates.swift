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

    /// Returns string representations of the weekdays, in the order the weekdays occur on the local calendar.
    /// This differs with the Foundation `Calendar.veryShortWeekdaySymbols` in that the ordering is changed such
    /// that the first element of the array corresponds to the first weekday in the current locale, instead of Sunday.
    ///
    /// This method is required for handling certain regions in which the first day of the week is Monday.
    func orderedWeekdaySymbolsVeryShort() -> [String] {
        var symbols = veryShortWeekdaySymbols
        Array(1..<firstWeekday).forEach { _ in
            let symbol = symbols.removeFirst()
            symbols.append(symbol)
        }
        return symbols
    }

    /// Returns string representations of the weekdays, in the order the weekdays occur on the local calendar.
    /// This differs with the Foundation `Calendar.weekdaySymbols` in that the ordering is changed such
    /// that the first element of the array corresponds to the first weekday in the current locale, instead of Sunday.
    ///
    /// This method is required for handling certain regions in which the first day of the week is Monday.
    func orderedWeekdaySymbols() -> [String] {
        var symbols = weekdaySymbols
        Array(1..<firstWeekday).forEach { _ in
            let symbol = symbols.removeFirst()
            symbols.append(symbol)
        }
        return symbols
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
