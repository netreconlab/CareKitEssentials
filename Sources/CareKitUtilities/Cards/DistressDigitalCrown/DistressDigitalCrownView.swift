//
//  DistressDigitalCrownView.swift
//  Assuage
//
//  Created by Julia Stekardis on 9/26/22.
//  Copyright © 2022 NetReconLab. All rights reserved.
//

#if os(watchOS)
import CareKit
import CareKitStore
import CareKitUI
import SwiftUI

struct DistressDigitalCrownView: View {
    @StateObject var viewModel = DistressDigitalCrownViewModel()

    var body: some View {
        VStack {
            if let details = viewModel.taskEvents.firstEventDetail {
                DigitalCrownView(title: Text(viewModel.taskEvents.firstEventTitle),
                                 detail: Text(details),
                                 viewModel: viewModel)
            } else {
                DigitalCrownView(title: Text(viewModel.taskEvents.firstEventTitle),
                                 viewModel: viewModel)
            }
        }
    }
}

struct DistressDigitalCrownView_Previews: PreviewProvider {
    static var previews: some View {
        DistressDigitalCrownView()
    }
}
#endif
