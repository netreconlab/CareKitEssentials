//
//  CareKitEssentialChartHeaderView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 11/29/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct CareKitEssentialChartHeaderView: View {
	@Environment(\.careKitStyle) private var style
    var title: String
    var subtitle: String

	@OSValue<Font>(
		values: [.watchOS: .system(size: 13)],
		defaultValue: .caption
	) private var font

    var body: some View {
		VStack(
			alignment: .leading,
			spacing: style.dimension.directionalInsets1.top / 4.0
		) {
            Text(title)
                .font(.headline)
				.fontWeight(.bold)
            Text(subtitle)
                .font(font)
				.fontWeight(.medium)
        }
		.foregroundColor(Color(style.color.label))
    }
}

struct CareEssentialChartHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CareKitEssentialChartHeaderView(
            title: "Title",
            subtitle: "Subtitle"
        )
    }
}
