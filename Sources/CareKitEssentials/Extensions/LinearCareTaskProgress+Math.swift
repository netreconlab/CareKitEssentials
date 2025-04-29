//
//  LinearCareTaskProgress+Math.swift
//
//
//  Created by Corey Baker on 4/25/23.
//

import CareKitStore
import Foundation

/// A structure that defines user progress for a task that can be completed over time.
///
/// A progress value updates as a user progresses through the task. When the progress value
/// reaches its goal, the task is considered completed. If there's no goal, the task is considered completed if
/// the progress value is greater than zero.
///
/// This type of progress is useful for tasks such as "Walk 500 steps" or "Exercise for 30 minutes."
///
/// You can easily apply this progress to a user interface element such as a chart or a progress view.
///
/// ```swift
/// var body: some View {
///     ProgressView(value: progress.fractionCompleted)
/// }
/// ```
public extension LinearCareTaskProgress {

    /// Convert an outcome value to a double that can be accumulated. If the underlying type is not a numeric,
    /// a default value of `1` will be used to indicate the existence of some outcome value.
    static func accumulableDoubleValue(for outcomeValue: OCKOutcomeValue) -> Double {

        switch outcomeValue.type {

        // These types can be converted to a double value
        case .double, .integer:
            return outcomeValue.numberValue!.doubleValue

        // These types cannot be converted to a double value
        case .binary, .text, .date, .boolean:
            return 1
        }
    }

    static func sum<T: AdditiveArithmetic>(
        _ lhs: T?,
        _ rhs: T?
    ) -> T? {

        // Note: The computation here assumes `nil` is a passthrough
        // value and acts the same as "0" in addition

        // If at least one side of the equation is nil
        if lhs == nil { return rhs }
        if rhs == nil { return lhs }

        // If both sides of the equation are non-nil
        let sum = lhs! + rhs!
        return sum
    }

	static func computeProgressBySummingOutcomeValues(
		for event: OCKAnyEvent,
		kind: String?
	) -> LinearCareTaskProgress {

		let outcomeValues = event.outcome?.values ?? []
		let filteredOutcomeValues = outcomeValues.filter { $0.kind == kind }

		let summedOutcomesValue = filteredOutcomeValues
			.map(accumulableDoubleValue)
			.reduce(0, +)

		let targetValues = event.scheduleEvent.element.targetValues

		let summedTargetValue = targetValues
			.map(accumulableDoubleValue)
			.reduce(nil) { partialResult, nextTarget -> Double? in
				return sum(partialResult, nextTarget)
			}

		let progress = LinearCareTaskProgress(
			value: summedOutcomesValue,
			goal: summedTargetValue
		)

		return progress
	}

	static func computeProgressByFindingMaxOutcomeValue(
		for event: OCKAnyEvent,
		kind: String?
	) -> LinearCareTaskProgress {

		let outcomeValues = event.outcome?.values ?? []
		let filteredOutcomeValues = outcomeValues.filter { $0.kind == kind }

		let maxOutcomesValue = filteredOutcomeValues
			.map(accumulableDoubleValue)
			.max() ?? 0

		let targetValues = event.scheduleEvent.element.targetValues

		let maxTargetValue = targetValues.isEmpty ? nil : targetValues
			.map(accumulableDoubleValue)
			.max()

		let progress = LinearCareTaskProgress(
			value: maxOutcomesValue,
			goal: maxTargetValue
		)

		return progress
	}

	static func computeProgressByFindingMinOutcomeValue(
		for event: OCKAnyEvent,
		kind: String?
	) -> LinearCareTaskProgress {

		let outcomeValues = event.outcome?.values ?? []
		let filteredOutcomeValues = outcomeValues.filter { $0.kind == kind }

		let minOutcomesValue = filteredOutcomeValues
			.map(accumulableDoubleValue)
			.min() ?? 0

		let targetValues = event.scheduleEvent.element.targetValues

		let minTargetValue = targetValues.isEmpty ? nil : targetValues
			.map(accumulableDoubleValue)
			.min()

		let progress = LinearCareTaskProgress(
			value: minOutcomesValue,
			goal: minTargetValue
		)

		return progress
	}

    static func computeProgressByAveragingOutcomeValues(
        for event: OCKAnyEvent,
        kind: String? = nil
    ) -> LinearCareTaskProgress {

        let outcomeValues = event.outcome?.values ?? []
        let filteredOutcomeValues = outcomeValues.filter { $0.kind == kind }
        let completedOutcomesValues = Double(filteredOutcomeValues.count)
        let summedOutcomesValue = filteredOutcomeValues
            .map(accumulableDoubleValue)
            .reduce(0, +)
        let targetValues = event.scheduleEvent.element.targetValues
        let mappedTargetValue = targetValues
            .map(accumulableDoubleValue)

		let meanTargetValue = targetValues.isEmpty ? nil : Self.computeProgressByAveraging(for: mappedTargetValue)
			.value

        guard completedOutcomesValues >= 1.0 else {
			return LinearCareTaskProgress(
				value: 0.0,
				goal: meanTargetValue
			)
        }

		let value = summedOutcomesValue / completedOutcomesValues
        let progress = LinearCareTaskProgress(
            value: value,
            goal: meanTargetValue
        )

        return progress

    }

    static func computeProgressByMedianOutcomeValues(
        for event: OCKAnyEvent,
        kind: String? = nil
    ) -> LinearCareTaskProgress {

        let outcomeValues = event.outcome?.values ?? []
        let filteredOutcomeValues = outcomeValues.filter { $0.kind == kind }
        let allOutcomesValue = filteredOutcomeValues
            .map(accumulableDoubleValue)
            .sorted()

        let targetValues = event.scheduleEvent.element.targetValues
		let mappedTargetValue = targetValues
			.map(accumulableDoubleValue)

		let medianTargetValue = targetValues.isEmpty ? nil : Self.computeProgressByMedian(for: mappedTargetValue)
			.value

        guard !allOutcomesValue.isEmpty else {
			return LinearCareTaskProgress(
				value: 0.0,
				goal: medianTargetValue
			)
        }

		let valueCount = allOutcomesValue.count
		if (valueCount % 2) == 0 {
			let index = valueCount / 2
			let value = (allOutcomesValue[index] + allOutcomesValue[index - 1]) / 2.0
			let progress = LinearCareTaskProgress(
				value: value,
				goal: medianTargetValue
			)
			return progress
		} else {
			let value = allOutcomesValue[valueCount / 2]
			let progress = LinearCareTaskProgress(
				value: value,
				goal: medianTargetValue
			)
			return progress
		}
    }

	static func computeProgressByAveraging(
		for points: [Double]
	) -> LinearCareTaskProgress {

		let summedPoints = points
			.reduce(0, +)

		let totalPointsCount = Double(points.count)

		guard totalPointsCount >= 1.0 else {
			return LinearCareTaskProgress(value: 0.0)
		}
		let value = summedPoints / totalPointsCount
		let progress = LinearCareTaskProgress(
			value: value
		)

		return progress

	}

	static func computeProgressByMedian(
		for points: [Double]
	) -> LinearCareTaskProgress {

		let sortedPoints = points.sorted()

		guard !sortedPoints.isEmpty else {
			return LinearCareTaskProgress(value: 0.0)
		}

		let valueCount = sortedPoints.count
		if (valueCount % 2) == 0 {
			let index = valueCount / 2
			let value = (sortedPoints[index] + sortedPoints[index - 1]) / 2.0
			let progress = LinearCareTaskProgress(
				value: value
			)
			return progress
		} else {
			let value = sortedPoints[valueCount / 2]
			let progress = LinearCareTaskProgress(
				value: value
			)
			return progress
		}
	}
}

extension LinearCareTaskProgress {
    /// Format the `value` for display.
    func valueDescription(formatter: NumberFormatter?) -> String {
        let progressDescription = formatter.map { $0.string(from: NSNumber(value: value)) }
            ?? value.removingExtraneousDecimal()
        return progressDescription ?? "\(value)"
    }

    /// Format the `goal` for display.
    func goalDescription(formatter: NumberFormatter?) -> String {

        guard let goal else {

            return ""
        }

        let targetDescription = formatter.map { $0.string(from: NSNumber(value: goal)) }
            ?? goal.removingExtraneousDecimal()

        return targetDescription ?? "\(goal)"
    }
}
