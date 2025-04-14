//
//  DetailsView.swift
//  CareKitEssentials
//
//  Created by Julia Stekardis on 12/6/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

import CareKitStore
import SwiftUI

/// A View to show more details. Can be used for CareKit cards.
///
/// # Style
/// The card supports styling using `careKitStyle(_:)`.
///
/// ```
///    +--------------------+
///    |                    |
///    |       <Image>      |
///    |                    |
///    |                    |
///    |  <Title>           |
///    |                    |
///    |  <Detail>          |
///    |                    |
///    +--------------------+
/// ```
public struct DetailsView: View {
    @Environment(\.careKitStyle) private var style

    private let event: OCKAnyEvent
    private let title: String?
    private let details: String?

    public var body: some View {
        VStack {
            Image.asset(event.task.asset)?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()

            Text(title ?? event.title)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            if let detailText = details ?? event.instructions {
                Text(detailText)
                    .font(.headline)
                    .fontWeight(.medium)
                    .padding()
            }
        }
    }

    // MARK: - Init

    /// Create an instance.
    /// - Parameters:
    ///   - event: The event to display details for when the info button is tapped.
    ///   - title: Text to be displayed as the title instead of the task title.
    ///   - details: The text to be displayed as the details instead of the task instructions.
    public init(
        event: OCKAnyEvent,
        title: String? = nil,
        details: String? = nil
    ) {
        self.event = event
        self.title = title
        self.details = details
    }
}

struct DetailsView_Previews: PreviewProvider {
    static let task = Utility.createNauseaTask()
    static var previews: some View {
        if let event = try? Utility.createNauseaEvent() {
            DetailsView(event: event)
				.accentColor(.red)
        }
    }
}
