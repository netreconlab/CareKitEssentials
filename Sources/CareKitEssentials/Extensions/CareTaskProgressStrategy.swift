//
//  CareTaskProgressStrategy.swift
//
//
//  Created by Luis Millan on 7/18/24.
//

import CareKitStore
import Foundation

public extension CareTaskProgressStrategy {

	/// A strategy that computes progress for a task by checking for the existence of an outcome.
	///
	/// - Parameters:
	/// 	- kind: An optional ``String`` that specifies the kind of the `OCKOutcomeValue` to use
	/// when computing the progress for the event. Defaults to ``nil``.
	///
	/// The task is considered completed if an ``OCKAnyEvent/outcome`` exists that contains an
	/// `OCKOutcomeValue` with the specified `kind`.
	static func checkingOutcomeExists(kind: String? = nil) -> CareTaskProgressStrategy<BinaryCareTaskProgress> {
		CareTaskProgressStrategy<BinaryCareTaskProgress> { event in
			BinaryCareTaskProgress.computeProgressByCheckingOutcomeExists(for: event, kind: kind)
		}
	}

	/// A strategy that computes progress for a task.
	///
	/// The strategy sums the ``OCKScheduleElement/targetValues`` for the event and compares
	/// the two results. The task is considered completed if the summed value reaches the summed target.
	///
	/// - Parameters:
	/// 	- kind: An optional ``String`` that specifies the kind of the `OCKOutcomeValue` to use
	/// when computing the progress for the event. Defaults to ``nil``.
	///
	/// - Note:
	/// If any of the outcome ``OCKAnyOutcome/values`` or ``OCKScheduleElement/targetValues``
	/// aren't numeric and can't be summed properly, they're assigned a value of one during the summation
	/// process.
	static func summingOutcomeValues(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
		CareTaskProgressStrategy<LinearCareTaskProgress> { event in
			LinearCareTaskProgress.computeProgressBySummingOutcomeValues(for: event, kind: kind)
		}
	}

	/// A strategy that computes progress for a task.
	///
	/// The strategy finds the max of the ``OCKScheduleElement/targetValues`` for the event and compares
	/// the two results. The task is considered completed if the max value reaches the max target.
	///
	/// - Parameters:
	/// 	- kind: An optional ``String`` that specifies the kind of the `OCKOutcomeValue` to use
	/// when computing the progress for the event. Defaults to ``nil``.
	///
	/// - Note:
	/// If any of the outcome ``OCKAnyOutcome/values`` or ``OCKScheduleElement/targetValues``
	/// aren't numeric and can't be maxed properly, they're assigned a value of one during the max
	/// process.
	static func maxOutcomeValue(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
		CareTaskProgressStrategy<LinearCareTaskProgress> { event in
			LinearCareTaskProgress.computeProgressByFindingMaxOutcomeValue(for: event, kind: kind)
		}
	}

	/// A strategy that computes progress for a task.
	///
	/// The strategy finds the min of the ``OCKScheduleElement/targetValues`` for the event and compares
	/// the two results. The task is considered completed if the min value reaches the min target.
	///
	/// - Parameters:
	/// 	- kind: An optional ``String`` that specifies the kind of the `OCKOutcomeValue` to use
	/// when computing the progress for the event. Defaults to ``nil``.
	///
	/// - Note:
	/// If any of the outcome ``OCKAnyOutcome/values`` or ``OCKScheduleElement/targetValues``
	/// aren't numeric and can't be minimixed properly, they're assigned a value of one during the min
	/// process.
	static func minOutcomeValue(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
		CareTaskProgressStrategy<LinearCareTaskProgress> { event in
			LinearCareTaskProgress.computeProgressByFindingMinOutcomeValue(for: event, kind: kind)
		}
	}

    /// Computes the average outcome values for a given event
    ///
    /// This function uses the ``LinearCareTaskProgress.computeProgressByAveragingOutcomeValues`` 
    /// to compute the average outcome values for a given event.
    /// Event is passed to ``computeProgressByAveragingOutcomeValues`` method as the argument
    ///
    ///
	/// - Parameters:
	/// 	- kind: An optional ``String`` that specifies the kind of the `OCKOutcomeValue` to use
	/// when computing the progress for the event. Defaults to ``nil``.
    ///
    /// - Returns: A ``CareTaskProgressStrategy<LinearCareTaskProgress>`` 
    /// object that's the strategy for computing the progress of a care task.
    ///
    ///
    static func averagingOutcomeValues(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
        CareTaskProgressStrategy<LinearCareTaskProgress> { event in
            LinearCareTaskProgress.computeProgressByAveragingOutcomeValues(for: event, kind: kind)
        }
    }

    /// Computes the median outcome values for a given event
    ///
    /// This function use the ``LinearCareTaskProgress.computeProgressByMedianOutcomeValues``
    /// to compute the median outcome values for a given envet.
    /// Event is pased to the ``computeProgressByMedianOutcomeValues`` method as an argument
    ///
	/// - Parameters:
	/// 	- kind: An optional ``String`` that specifies the kind of the `OCKOutcomeValue` to use
	/// when computing the progress for the event. Defaults to ``nil``.
    ///
    /// - Returns: A ``CareTaskProgressStrategy<LinearCareTaskProgress>``
    ///  that's the strategy for compting the progress of a care task.
    ///
    static func medianOutcomeValues(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
        CareTaskProgressStrategy<LinearCareTaskProgress> { event in
            LinearCareTaskProgress.computeProgressByMedianOutcomeValues(for: event, kind: kind)
        }
    }
}
