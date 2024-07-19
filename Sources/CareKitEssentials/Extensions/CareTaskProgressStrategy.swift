//
//  CareTaskProgressStrategy.swift
//
//
//  Created by Luis Millan on 7/18/24.
//

import CareKitStore
import Foundation

public extension CareTaskProgressStrategy {

    /// Computes the average outcome values for a given event
    ///
    /// This function uses the ``LinearCareTaskProgress.computeProgressByAveragingOutcomeValues`` 
    /// to compute the average outcome values for a given event.
    /// Event is passed to ``computeProgressByAveragingOutcomeValues`` method as the argument
    ///
    ///
    /// Paremter:  kind: An optional ``String`` that specifies the kind of the event. Defaults to ``nil``
    ///
    /// Returns:: A ``CareTaskProgressStrategy<LinearCareTaskProgress>`` 
    /// object that's the strategy for computing the progress of a care task
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
    /// Parameter kind: An optional ``String`` that specifies the kind of an event. Defaults to ``nil``
    ///
    /// Returns: A ``CareTaskProgressStrategy<LinearCareTaskProgress>``
    ///  that's the strategy for compting the progress of a care task
    ///
    static func medianOutcomeValues(kind: String? = nil) -> CareTaskProgressStrategy<LinearCareTaskProgress> {
        CareTaskProgressStrategy<LinearCareTaskProgress> { event in
            LinearCareTaskProgress.computeProgressByMedianOutcomeValues(for: event, kind: kind)
        }
    }
}
