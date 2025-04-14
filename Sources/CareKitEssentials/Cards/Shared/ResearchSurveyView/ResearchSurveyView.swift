//
//  ResearchSurveyView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 3/27/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import os.log
import SwiftUI

/// A card that displays a header view and a button that displays a ResearchKitSwiftUI view. The whole view is tappable.
public struct ResearchSurveyView<Content: View>: View {
    @Environment(\.careKitStyle) var style
    @Environment(\.isCardEnabled) private var isCardEnabled
    @State private var isPresented = false

    let event: OCKAnyEvent
    @ViewBuilder let form: () -> Content

    public var body: some View {
        CardView {
            VStack(alignment: .leading) {
                InformationHeaderView(
                    title: Text(event.title),
                    information: event.detailText,
                    event: event
                )
                event.instructionsText

                VStack(alignment: .center) {
                    HStack(alignment: .center) {
                        Button( action: {
                            isPresented.toggle()
                        }) {
                            RectangularCompletionView(isComplete: isComplete) {
                                Spacer()
                                Text(buttonText)
                                    .foregroundColor(foregroundColor)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                Spacer()
                            }
                        }
                        .buttonStyle(NoHighlightStyle())
                    }
					.frame(
						idealHeight: 30,
						maxHeight: 70
					)
                }
                .padding(.vertical)
            }
            .padding(isCardEnabled ? [.all] : [])
        }
        .careKitStyle(style)
        .frame(maxWidth: .infinity)
        .sheet(
            isPresented: $isPresented,
            content: form
        )
    }
    private var isComplete: Bool {
        event.isComplete
    }
    private var buttonText: LocalizedStringKey {
        isComplete ? "COMPLETED" : "START_SURVEY"
    }
    private var foregroundColor: Color {
        isComplete ? .accentColor : .white
    }
}

public extension ResearchSurveyView {

	/// Create an instance of `ResearchSurveyView`.
	///
	/// This view displays a card that can present a ResearchKitSwiftUI survey.
	///
	/// - Parameters:
	///   - event: The CareKit event related to the survey.
	///   - form: The form that will be presented when the button is tapped.
	///   This is usually a `ResearchCareForm`.
	init(
		event: OCKAnyEvent,
		form: @escaping () -> Content
	) {
		self.event = event
		self.form = form
	}
}

#if !os(watchOS)

extension ResearchSurveyView: EventWithContentViewable {

    public init?(
        event: OCKAnyEvent,
        store: any OCKAnyStoreProtocol,
        content: @escaping () -> Content
    ) {
        self.init(
            event: event,
            form: content
        )
    }
}

#endif

struct ResearchSurveyView_Previews: PreviewProvider {
	static var previews: some View {
		let previewStore = Utility.createPreviewStore()
		VStack {
			if let event = try? Utility.createNauseaEvent() {
				Spacer()
				ResearchSurveyView(
					event: event,
					form: {
						Text("A survey can show here")
					}
				)
				Spacer()
			}
		}
		.environment(\.careStore, previewStore)
		.careKitStyle(OCKStyle())
	}
}
