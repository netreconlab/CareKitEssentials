//
//  ResearchCareForm.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 3/27/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if canImport(ResearchKitSwiftUI)
import CareKit
import CareKitStore
import CareKitUI
import os.log
import ResearchKitSwiftUI
import SwiftUI

/// A form that displays a `ResearchForm` view. This form will automatically
/// convert and save the `ResearchFormResult` and convert it to CareKit.
public struct ResearchCareForm<Content: View>: CareKitEssentialView {
    @Environment(\.careStore) public var store
    @Environment(\.dismiss) var dismiss

    let event: OCKAnyEvent
    @ViewBuilder let steps: () -> Content

    public var body: some View {
        ResearchForm(
            id: event.id,
            steps: steps,
            onResearchFormCompletion: { completion in
				switch completion {
				case .completed(let results):
					do {
						try save(results)
					} catch {
						Logger.researchCareForm.error("Cannot save results: \(error)")
						dismiss()
					}
				case .saved(let results):
					do {
						try save(results)
					} catch {
						Logger.researchCareForm.error("Cannot save results: \(error)")
						dismiss()
					}
				case .discarded:
					cancel()
				default:
					Logger.researchCareForm.error("Reached an unsupported case: \"\(completion)\"")
					cancel()
				}
            }
        )
    }

    func save(_ results: ResearchFormResult) throws {
        // Ensure we never save an empty event to the DB.
        let outcomeValues = createOutcomeValuesFromResearchKitResults(results)

        Task {
            do {
                _ = try await saveOutcomeValues(
                    outcomeValues,
                    event: event
                )
                dismiss()
            } catch {
                Logger.researchCareForm.error("Could not save results: \(error)")
                dismiss()
            }
        }
    }

    func cancel() {
        Logger.researchCareForm.log("Cancelled saving result")
        dismiss()
    }

    func createOutcomeValuesFromResearchKitResults(
        _ results: ResearchFormResult
    ) -> [OCKOutcomeValue] {

        let multipleOutcomeValues = results.compactMap { result -> [OCKOutcomeValue]? in
			do {
				let convertedResult = try result.convertToOCKOutcomeValues()
				return convertedResult
			} catch {
				Logger.researchCareForm.error("Cannot convert result to OCKOutcomeValue's: \(error)")
				return nil
			}
        }

        // Flatten results as they are currently multi-dimentional arrays
        let outcomesValues = multipleOutcomeValues.flatMap { $0 }
        return outcomesValues
    }
}

public extension ResearchCareForm {

	/// Create an instance of `ResearchCareForm`.
	///
	/// This view displays a `ResearchForm`.
	///
	/// - Parameters:
	///   - event: The CareKit event related to the survey. The results from the
	///   survey will be saved to the respective event.
	///   - steps: The steps that make up the survey.
	init(
		event: OCKAnyEvent,
		steps: @escaping () -> Content
	) {
		self.event = event
		self.steps = steps
	}
}

#if !os(watchOS)

extension ResearchCareForm: EventWithContentViewable {

    public init?(
        event: OCKAnyEvent,
        store: OCKAnyStoreProtocol,
        content: @escaping () -> Content
    ) {
        self.init(
            event: event,
            steps: content
        )
    }
}

#endif

struct ResearchCareForm_Previews: PreviewProvider {
    static var store = Utility.createPreviewStore()
    static var query: OCKEventQuery {
        var query = OCKEventQuery(for: Date())
        query.taskIDs = [TaskID.doxylamine]
        return query
    }
    static var previews: some View {
        VStack {
            @CareStoreFetchRequest(query: query) var events
            ForEach(events.latest) { event in
                ResearchCareForm(
                    event: event.result
                ) {
                    let event = event.result

                    ResearchFormStep(
                        title: event.title,
                        subtitle: event.instructions
                    ) {
                        TextQuestion(
                            id: event.id,
                            title: event.title,
                            prompt: event.instructions,
                            lineLimit: .singleLine,
                            characterLimit: 0
                        )
                        .questionRequired(true)
                    }
                }
            }
        }
        .environment(\.careStore, store)
    }
}

#endif
