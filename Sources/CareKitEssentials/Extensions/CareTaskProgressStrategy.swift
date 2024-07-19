//
//  CareTaskProgressStrategyExtension.swift
//
//
//  Created by Luis Millan on 7/18/24.
//

import CareKitStore
import Foundation

public extension CareTaskProgressStrategy {

    /// A strategy that computes progress for a task.
    ///
    /// The strategy sums the ``OCKScheduleElement/targetValues`` for the event and compares
    /// the two results. The task is considered completed if the summed value reaches the summed target.
    ///
    /// > Note:
    /// If any of the outcome ``OCKAnyOutcome/values`` or ``OCKScheduleElement/targetValues``
    /// aren't numeric and can't be summed properly, they're assigned a value of one during the summation
    /// process.
     static func averagingOutcomeValues(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
        CareTaskProgressStrategy<LinearCareTaskProgress> { event in
            LinearCareTaskProgress.computeProgressByAveragingOutcomeValues(for: event, kind: kind)
        }
    }

    /// A strategy that computes progress for a task.
    ///
    /// The strategy sums the ``OCKScheduleElement/targetValues`` for the event and compares
    /// the two results. The task is considered completed if the summed value reaches the summed target.
    ///
    /// > Note:
    /// If any of the outcome ``OCKAnyOutcome/values`` or ``OCKScheduleElement/targetValues``
    /// aren't numeric and can't be summed properly, they're assigned a value of one during the summation
    /// process.
     static func medianOutcomeValues(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
        CareTaskProgressStrategy<LinearCareTaskProgress> { event in
            LinearCareTaskProgress.computeProgressByMedianOutcomeValues(for: event, kind: kind)
        }
    }

    /// A strategy that computes progress for a task.
    ///
    /// The strategy sums the ``OCKScheduleElement/targetValues`` for the event and compares
    /// the two results. The task is considered completed if the summed value reaches the summed target.
    ///
    /// > Note:
    /// If any of the outcome ``OCKAnyOutcome/values`` or ``OCKScheduleElement/targetValues``
    /// aren't numeric and can't be summed properly, they're assigned a value of one during the summation
    /// process.
    static func streak(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
        CareTaskProgressStrategy<LinearCareTaskProgress> { event in
            LinearCareTaskProgress.computeProgressByStreakOutcomeValues(for: event, kind: kind)
        }
    }
}
