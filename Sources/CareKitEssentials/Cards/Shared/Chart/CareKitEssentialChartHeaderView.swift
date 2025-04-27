//
//  CareKitEssentialChartHeaderView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 11/29/24.
//  Copyright © 2024 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct CareKitEssentialChartHeaderView: View {
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

struct CareEssentialChartHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CareKitEssentialChartHeaderView(
            title: "Title",
            subtitle: "Subtitle"
        )
    }
}
