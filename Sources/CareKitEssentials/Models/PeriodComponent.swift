//
//  PeriodComponent.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/27/25.
//

import Foundation
import SwiftUI

public enum PeriodComponent: String, CaseIterable, Hashable, Codable, Identifiable, CustomStringConvertible {

	case day
	case week
	case month
	case year

	public var id: String {
		self.rawValue
	}

	public var description: String {
		id
	}

	var localizedString: String {
		switch self {
		case .day:
			return String(localized: "DAY")
		case .week:
			return String(localized: "WEEK")
		case .month:
			return String(localized: "MONTH")
		case .year:
			return String(localized: "YEAR")
		}
	}

	var lowestCommonComponent: Calendar.Component {
		switch self {
		case .day:
			return .hour
		case .week:
			return .day
		case .month:
			return .weekOfMonth
		case .year:
			return .month
		}
	}

	func relevantComponentsForProgress(
		for date: Date
	) -> DateComponentsForProgress {
		switch self {
		case .day:
			let component = self.lowestCommonComponent
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
		case .week:
			let component = self.lowestCommonComponent
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
			let component = self.lowestCommonComponent
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
			let component = self.lowestCommonComponent
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
		}
	}

	func formattedDateString(_ date: Date) -> String {
		switch self {
		case .day:
			return date.formatted(.dateTime.month().day().hour())
		case .week:
			return date.formatted(.dateTime.month().day())
		case .month:
			return date.formatted(.dateTime.month().week(.weekOfMonth))
		case .year:
			return date.formatted(.dateTime.month())
		}
	}
}

extension PeriodComponent {
	public init(component: Calendar.Component) throws {
		switch component {
		case .day, .dayOfYear:
			self = .day
		case .weekday, .weekOfMonth, .weekOfYear:
			self = .week
		case .month:
			self = .month
		case .year:
			self = .year
		default:
			throw CareKitEssentialsError.errorString("Unsupported component \"\(component)\"")
		}
	}
}
