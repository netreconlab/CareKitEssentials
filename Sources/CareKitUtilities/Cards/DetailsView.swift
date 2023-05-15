//
//  DetailsView.swift
//  CareKitUtilities
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
    @Environment(\.careKitUtilitiesTintColor) private var tintColor

    private let task: OCKAnyTask
    private let title: String?
    private let details: String?

    public var body: some View {
        VStack {
            Image.asset(task.asset)?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color(tintColor))
                .padding()

            if let title = title ?? task.title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }

            if let detailText = details ?? task.instructions {
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
    ///   - task: The task to display details for when the info button is tapped.
    ///   - title: Text to be displayed as the title instead of the task title.
    ///   - details: The text to be displayed as the details instead of the task instructions.
    public init(task: OCKAnyTask,
                title: String? = nil,
                details: String? = nil) {
        self.task = task
        self.title = title
        self.details = details
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(task: OCKTask(id: "",
                                  title: "Hello",
                                  carePlanUUID: nil,
                                  schedule: .dailyAtTime(hour: 0,
                                                         minutes: 0,
                                                         start: Date(),
                                                         end: nil,
                                                         text: "")))
    }
}
