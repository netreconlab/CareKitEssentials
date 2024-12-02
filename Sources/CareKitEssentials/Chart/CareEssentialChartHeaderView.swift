//
//  Header.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 11/29/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct CareEssentialChartHeaderView: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
        }
    }
}

#Preview {
    CareEssentialChartHeaderView(
        title: "Title",
        subtitle: "Subtitle"
    )
}
