//
//  OCKStore.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/15/23.
//

import Foundation
import CareKitStore
import os.log

public extension OCKStore {

    func addTasksIfNotPresent(_ tasks: [OCKTask]) async throws -> [OCKTask] {

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = tasks.compactMap { $0.id }

        let foundTasks = try await fetchTasks(query: query)

        // Find all missing tasks.
        let tasksNotInStore = tasks.filter { potentialTask -> Bool in
            guard foundTasks.first(where: { $0.id == potentialTask.id }) == nil else {
                return false
            }
            return true
        }

        // Only add if there's a new task
        guard tasksNotInStore.count > 0 else {
            return []
        }

        let addedTasks = try await addTasks(tasksNotInStore)
        return addedTasks
    }
}

extension OCKStore {
    func populateDefaultCarePlansTasks(
		startDate: Date,
	) async throws {

        let thisMorning = Calendar.current.startOfDay(for: startDate)
        let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: thisMorning)!
        let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)!
        let afterLunch = Calendar.current.date(byAdding: .hour, value: 14, to: aFewDaysAgo)!

        let schedule = OCKSchedule(
			composing: [
				Utility.createMorningScheduleElement(),
				OCKScheduleElement(
					start: afterLunch,
					end: nil,
					interval: DateComponents(day: 2)
				)
			]
		)

        var doxylamine = OCKTask(
			id: TaskID.doxylamine,
			title: "Take Doxylamine",
			carePlanUUID: nil,
			schedule: schedule
		)
        doxylamine.instructions = "Take 25mg of doxylamine when you experience nausea."
        doxylamine.asset = "pills.fill"

        let nausea = Utility.createNauseaTask()

        let kegelElement = OCKScheduleElement(start: beforeBreakfast,
                                              end: nil,
                                              interval: DateComponents(day: 2))
        let kegelSchedule = OCKSchedule(composing: [kegelElement])
        var kegels = OCKTask(id: TaskID.kegels,
                             title: "Kegel Exercises",
                             carePlanUUID: nil,
                             schedule: kegelSchedule)
        kegels.impactsAdherence = true
        kegels.instructions = "Perform kegel exercies"

        let stretchElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1))
        let stretchSchedule = OCKSchedule(composing: [stretchElement])
        var stretch = OCKTask(id: TaskID.stretch,
                              title: "Stretch",
                              carePlanUUID: nil,
                              schedule: stretchSchedule)
        stretch.impactsAdherence = true
        stretch.asset = "figure.walk"

        _ = try await addTasksIfNotPresent([nausea, doxylamine, kegels, stretch])
    }

	func populateSampleOutcomes(
		startDate: Date
	) async throws {

		// Prepare previous samples.
		let yesterDay = Calendar.current.date(
			byAdding: .day,
			value: -1,
			to: Date()
		)!.endOfDay
		guard yesterDay > startDate else {
			throw CareKitEssentialsError.errorString("Start date must be before last night")
		}
		let dateInterval = DateInterval(
			start: startDate,
			end: yesterDay
		)
		let eventQuery = OCKEventQuery(
			dateInterval: dateInterval
		)
		let pastEvents = try await fetchEvents(query: eventQuery)
		let pastOutcomes = pastEvents.compactMap { event -> OCKOutcome? in

			let initialRandomDate = randomDate(
				event.scheduleEvent.start,
				end: event.scheduleEvent.end
			)

			switch event.task.id {
			case TaskID.doxylamine, TaskID.kegels, TaskID.stretch:
				let randomBool: Bool = .random()
				guard randomBool else { return nil }
				let outcomeValue = createOutcomeValue(
					randomBool,
					createdDate: initialRandomDate
				)

				let outcome = addValueToOutcome(
					[outcomeValue],
					for: event
				)
				return outcome
			case TaskID.nausea:
				// multiple random bools
				let outcomeValues = (0...3).compactMap { _ -> OCKOutcomeValue? in
					let randomBool: Bool = .random()
					guard randomBool else { return nil }
					let randomDate = randomDate(
						event.scheduleEvent.start,
						end: event.scheduleEvent.end
					)
					let outcomeValue = createOutcomeValue(
						randomBool,
						createdDate: randomDate
					)

					return outcomeValue
				}

				let outcome = addValueToOutcome(
					outcomeValues,
					for: event
				)
				return outcome

			default:
				return nil
			}
		}

		do {
			let savedOutcomes = try await addOutcomes(pastOutcomes)
			Logger.careKitAnyEventStore.info("Added sample \(savedOutcomes.count) outcomes to OCKStore!")
		} catch {
			Logger.careKitAnyEventStore.error("Error adding sample outcomes: \(error)")
		}
	}

	private func createOutcomeValue(
		_ value: OCKOutcomeValueUnderlyingType,
		createdDate: Date
	) -> OCKOutcomeValue {
		var outcomeValue = OCKOutcomeValue(
			value
		)
		outcomeValue.createdDate = createdDate
		return outcomeValue
	}

	private func addValueToOutcome(
		_ values: [OCKOutcomeValue],
		for event: OCKEvent<OCKTask, OCKOutcome>
	) -> OCKOutcome? {

		guard !values.isEmpty else {
			// Act like nothing was submitted.
			return nil
		}

		guard var outcome = event.outcome else {
			// Event doesn't have an outcome, need to
			// create a new one that exists in the past.
			var newOutcome = OCKOutcome(
				taskUUID: event.task.uuid,
				taskOccurrenceIndex: event.scheduleEvent.occurrence,
				values: values
			)

			let effectiveDate = newOutcome
				.sortedOutcomeValuesByRecency()
				.values
				.last?.createdDate ?? event.scheduleEvent.start

			newOutcome.effectiveDate = effectiveDate
			return newOutcome
		}

		outcome.values.append(contentsOf: values)
		let effectiveDate = outcome
			.sortedOutcomeValuesByRecency()
			.values
			.last?.createdDate ?? event.scheduleEvent.start
		outcome.effectiveDate = effectiveDate
		return outcome
	}

	private func randomDate(_ startDate: Date, end endDate: Date) -> Date {
		let timeIntervalRange = startDate.timeIntervalSince1970..<endDate.timeIntervalSince1970
		let randomTimeInterval = TimeInterval.random(in: timeIntervalRange)
		let randomDate = Date(timeIntervalSince1970: randomTimeInterval)
		return randomDate
	}
}
