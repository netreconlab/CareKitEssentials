//
//  DismissableView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/29/25.
//

import SwiftUI

struct DismissableView<Content: View>: View {
	@Environment(\.dismiss) var dismiss
	var title: String?
	@ViewBuilder var content: Content

	var body: some View {
		NavigationStack {
			content
				#if !os(watchOS) && !os(macOS)
				.toolbar {
					if let title {
						ToolbarItem(placement: .topBarLeading) {
							Text(title)
								.font(.title3)
								.bold()
						}
					}
					ToolbarItem(placement: .topBarTrailing) {
						Button(action: {
							dismiss()
						}) {
							Image(systemName: "x.circle.fill")
								.foregroundStyle(.gray)
								.opacity(0.5)
						}
					}
				}
				#endif
		}
	}
}

struct DismissableView_Previews: PreviewProvider {
	static var previews: some View {
		DismissableView(
			title: "Hello"
		) {
			Text("World")
		}
	}
}
