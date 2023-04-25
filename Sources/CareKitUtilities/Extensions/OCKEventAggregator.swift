//
//  OCKEventAggregator.swift
//  
//
//  Created by Corey Baker on 4/25/23.
//

import CareKitStore
import Foundation

public extension OCKEventAggregator {

    static func aggregatorMean(_ kind: String? = nil) -> OCKEventAggregator {
        guard let kind = kind else {
            return OCKEventAggregator.custom { events -> Double in

                let totalCompleted = Double(events.map { $0.outcome?.values.count ?? 0 }.reduce(0, +))
                let tempSumOfCompleted = events.compactMap {
                    $0.outcome?.values.compactMap { value -> Double in
                        guard let intValue = value.integerValue else {
                            guard let boolValue = value.booleanValue else {
                                return value.doubleValue ?? 0.0
                            }
                            return boolValue ? 1.0 : 0.0
                        }
                        return Double(intValue)
                    }.reduce(0, +)
                }
                let sumOfCompleted = Double(tempSumOfCompleted.compactMap { $0 }.reduce(0, +))

                if totalCompleted == 0 {
                    return 0.0
                } else {
                    return sumOfCompleted / totalCompleted
                }
            }
        }

        return OCKEventAggregator.custom { events -> Double in

            let completed = events.compactMap { event -> [Double]? in
                event.outcome?.answerDouble(kind: kind)
            }.flatMap { $0 }

            let totalCompleted = Double(completed.count)
            let sumOfCompleted = Double(completed.compactMap { $0 }.reduce(0, +))

            if totalCompleted == 0 {
                return 0.0
            } else {
                return sumOfCompleted / totalCompleted
            }
        }
    }

    static func aggregatorMedian(_ kind: String? = nil) -> OCKEventAggregator {
        guard let kind = kind else {
            return OCKEventAggregator.custom { events -> Double in

                let tempAllValues = events.compactMap {
                    $0.outcome?.values.compactMap { value -> Double in
                        guard let intValue = value.integerValue else {
                            guard let boolValue = value.booleanValue else {
                                return value.doubleValue ?? 0.0
                            }
                            return boolValue ? 1.0 : 0.0
                        }
                        return Double(intValue)
                    }
                }
                var sortedAllValues = tempAllValues.flatMap { $0 }
                sortedAllValues.sort()

                if sortedAllValues.isEmpty {
                    return 0.0
                } else if (sortedAllValues.count % 2) == 0 {
                    let index = sortedAllValues.count / 2
                    return (sortedAllValues[index] + sortedAllValues[index - 1]) / 2.0
                } else {
                    return sortedAllValues[sortedAllValues.count / 2]
                }
            }
        }

        return OCKEventAggregator.custom { events -> Double in

            var completed = events.compactMap { event -> [Double]? in
                event.outcome?.answerDouble(kind: kind)
            }.flatMap { $0 }

            completed.sort()

            if completed.isEmpty {
                return 0.0
            } else if (completed.count % 2) == 0 {
                let index = completed.count / 2
                return (completed[index] + completed[index - 1]) / 2.0
            } else {
                return completed[completed.count / 2]
            }
        }
    }

    static func aggregatorStreak(_ kind: String? = nil) -> OCKEventAggregator {
        return OCKEventAggregator.custom { events -> Double in
            Double(events.map { $0.outcome?.values.first != nil ? 1 : 0 }.reduce(0, +))
        }
    }
}
