//
//  OCKTask+ResearchKitSwiftUI.swift
//  OCKSample
//
//  Created by Corey Baker on 3/27/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

#if canImport(ResearchKitSwiftUI)

import CareKitStore
import Foundation
import os.log

extension OCKTask {

	/// A set of ResearchKitSwiftUI survey steps.
	public var surveySteps: [SurveyStep]? {
        get {
			guard let surveyStepsInfo = userInfo?[CareKitEssentialsUserInfoKey.surveySteps.rawValue] else {
                return nil
            }
			let surveyStepsData = Data(surveyStepsInfo.utf8)
			do {
				let steps = try JSONDecoder().decode(
					[SurveyStep].self,
					from: surveyStepsData
				)
				return steps
			} catch {
				Logger.ockTaskResearchKitSwiftUI.error(
					"Could not decode survey steps: \(error)"
				)
				return nil
			}
        }
        set {
            if userInfo == nil {
                // Initialize userInfo with empty dictionary
                userInfo = .init()
            }
			do {
				let encodedData = try JSONEncoder().encode(newValue)
				let encodedString = String(data: encodedData, encoding: .utf8)
				userInfo?[CareKitEssentialsUserInfoKey.surveySteps.rawValue] = encodedString
			} catch {
				Logger.ockTaskResearchKitSwiftUI.error(
					"Could not encode survey steps: \(error)"
				)
			}
        }
    }
}

#endif
