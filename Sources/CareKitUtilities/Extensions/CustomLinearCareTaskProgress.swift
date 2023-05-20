//
//  OCKEventAggregator.swift
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
public struct CustomLinearCareTaskProgress: CareTaskProgress, Hashable, Sendable {

    /// The progress that's been made towards reaching the goal.
    ///
    /// - Precondition: `value` >= 0
    public var value: Double {
        didSet { Self.validate(progressValue: value) }
    }

    /// A value that indicates whether the task is complete.
    ///
    /// When there is no goal, the value is `nil`.  The task is considered
    /// completed if the progress value is greater than zero.
    ///
    /// - Precondition: `value` >= 0
    public var goal: Double? {
        didSet { Self.validate(goal: goal) }
    }

    public init(
        value: Double,
        goal: Double? = nil
    ) {
        Self.validate(progressValue: value)
        Self.validate(goal: goal)

        self.value = value
        self.goal = goal
    }

    private static func validate(progressValue: Double) {
        precondition(progressValue >= 0)
    }

    private static func validate(goal: Double?) {
        guard let goal else { return }
        precondition(goal >= 0)
    }

    // MARK: - CareTaskProgress

    public var fractionCompleted: Double {

        // If there is no goal, a non-zero progress value indicates that progress
        // is 100% completed
        guard let goal else {

            let isCompleted = value > 0
            let fractionCompleted: Double = isCompleted ? 1 : 0
            return fractionCompleted
        }

        guard goal > 0 else {

            // The progress value is always guaranteed to be greater than or equal to
            // zero, so it's guaranteed to have reached the target value
            return 1
        }

        let fractionCompleted = value / goal
        let clampedFractionCompleted = min(fractionCompleted, 1)
        return clampedFractionCompleted
    }
}

public extension CareTaskProgressStrategy {

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

    static func computeProgressByAveragingOutcomeValues(for event: OCKAnyEvent) -> CustomLinearCareTaskProgress {

        let outcomeValues = event.outcome?.values ?? []

        let completedOutcomesValues = Double(outcomeValues.count)

        let summedOutcomesValue = outcomeValues
            .map(accumulableDoubleValue)
            .reduce(0, +)

        let targetValues = event.scheduleEvent.element.targetValues

        let summedTargetValue = targetValues
            .map(accumulableDoubleValue)
            .reduce(nil) { partialResult, nextTarget -> Double? in
                return sum(partialResult, nextTarget)
            }

        var value = 0.0
        if completedOutcomesValues >= 1.0 {
            value = summedOutcomesValue / completedOutcomesValues
        }

        let progress = CustomLinearCareTaskProgress(
            value: value,
            goal: summedTargetValue
        )

        return progress
    }

    static func computeProgressByMedianOutcomeValues(for event: OCKAnyEvent) -> CustomLinearCareTaskProgress {

        let outcomeValues = event.outcome?.values ?? []

        let allOutcomesValue = outcomeValues
            .map(accumulableDoubleValue)
            .sorted()

        let targetValues = event.scheduleEvent.element.targetValues

        let summedTargetValue = targetValues
            .map(accumulableDoubleValue)
            .reduce(nil) { partialResult, nextTarget -> Double? in
                return sum(partialResult, nextTarget)
            }

        var value = 0.0
        if !allOutcomesValue.isEmpty {
            let count = allOutcomesValue.count
            if (count % 2) == 0 {
                let index = allOutcomesValue.count / 2
                value = (allOutcomesValue[index] + allOutcomesValue[index - 1]) / 2.0
            } else {
                value = allOutcomesValue[count / 2]
            }
        }

        let progress = CustomLinearCareTaskProgress(
            value: value,
            goal: summedTargetValue
        )

        return progress
    }

    static func computeProgressByStreakOutcomeValues(for event: OCKAnyEvent) -> CustomLinearCareTaskProgress {

        let outcomeValues = event.outcome?.values ?? []

        let summedOutcomesValue = outcomeValues
            .map(accumulableDoubleValue)
            .reduce(0, +)

        let targetValues = event.scheduleEvent.element.targetValues

        let summedTargetValue = targetValues
            .map(accumulableDoubleValue)
            .reduce(nil) { partialResult, nextTarget -> Double? in
                return sum(partialResult, nextTarget)
            }

        let progress = CustomLinearCareTaskProgress(
            value: summedOutcomesValue,
            goal: summedTargetValue
        )

        return progress
    }

}
