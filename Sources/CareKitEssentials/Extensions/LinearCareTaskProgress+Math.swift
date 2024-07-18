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
        let summedTargetValue = targetValues
            .map(accumulableDoubleValue)
            .reduce(nil) { partialResult, nextTarget -> Double? in
                sum(partialResult, nextTarget)
            }
        var value = 0.0
        if completedOutcomesValues >= 1.0 {
            value = summedOutcomesValue / completedOutcomesValues
        }
        let progress = LinearCareTaskProgress(
            value: value,
            goal: summedTargetValue
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
        let summedTargetValue = targetValues
            .map(accumulableDoubleValue)
            .reduce(nil) { partialResult, nextTarget -> Double? in
                sum(partialResult, nextTarget)
            }

        var value = 0.0
        if !allOutcomesValue.isEmpty {
            let valueCount = allOutcomesValue.count
            if (valueCount % 2) == 0 {
                let index = valueCount / 2
                value = (allOutcomesValue[index] + allOutcomesValue[index - 1]) / 2.0
            } else {
                value = allOutcomesValue[valueCount / 2]
            }
        }

        let progress = LinearCareTaskProgress(
            value: value,
            goal: summedTargetValue
        )

        return progress
    }
    static func computeProgressByStreakOutcomeValues(
        for event: OCKAnyEvent,
        kind: String? = nil
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
                sum(partialResult, nextTarget)
            }

        let progress = LinearCareTaskProgress(
            value: summedOutcomesValue,
            goal: summedTargetValue
        )

        return progress
    }
}
