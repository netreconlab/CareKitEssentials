//
//  CKEConfigurationView.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 4/28/25.
//

import SwiftUI

struct CKEConfigurationView: View {

	var configurationId: String
	@Binding var configurations: [String: CKEDataSeriesConfiguration]

	@State var markSelected: CKEDataSeries.MarkType = .bar
	@State var dataStrategySelected: CKEDataSeriesConfiguration.DataStrategy = .sum
	@State var isShowingMarkHighlighted: Bool = false
	@State var isShowingMeanMark: Bool = false
	@State var isShowingMedianMark: Bool = false

    var body: some View {
		VStack {
			Section(
				header: Text(String(localized: "CHART_TYPE"))
					.font(.subheadline)
			) {
				markSegmentView
			}

			Section(
				header: Text(String(localized: "DATA_STRATEGY"))
					.font(.subheadline)
			) {
				dataStrategySegmentView
			}

			Section(
				header: Text(String(localized: "META_DATA"))
					.font(.subheadline)
			) {
				Toggle("SHOW_HIGHLIGHTED", isOn: $isShowingMarkHighlighted)
				Toggle("SHOW_MEAN", isOn: $isShowingMeanMark)
				Toggle("SHOW_MEDIAN", isOn: $isShowingMedianMark)
			}
		}
		.onChange(of: markSelected) { newValue in
			configurations[configurationId]?.mark = newValue
		}
		.onChange(of: dataStrategySelected) { newValue in
			configurations[configurationId]?.dataStrategy = newValue
		}
		.onChange(of: isShowingMarkHighlighted) { newValue in
			configurations[configurationId]?.showMarkWhenHighlighted = newValue
		}
		.onChange(of: isShowingMeanMark) { newValue in
			configurations[configurationId]?.showMeanMark = newValue
		}
		.onChange(of: isShowingMedianMark) { newValue in
			configurations[configurationId]?.showMedianMark = newValue
		}
    }

	var markSegmentView: some View {
		Picker(
			"CHOOSE_CHART_TYPE",
			selection: $markSelected.animation()
		) {
			Text("AREA")
				.tag(CKEDataSeries.MarkType.area)
			Text("BAR")
				.tag(CKEDataSeries.MarkType.bar)
			Text("LINE")
				.tag(CKEDataSeries.MarkType.line)
			Text("POINT")
				.tag(CKEDataSeries.MarkType.point)
		}
		#if !os(watchOS)
		.pickerStyle(.segmented)
		#else
		.pickerStyle(.automatic)
		#endif
	}

	var dataStrategySegmentView: some View {
		Picker(
			"CHOOSE_CHART_TYPE",
			selection: $dataStrategySelected.animation()
		) {
			Text("MEAN")
				.tag(CKEDataSeriesConfiguration.DataStrategy.mean)
			Text("MEDIAN")
				.tag(CKEDataSeriesConfiguration.DataStrategy.median)
			Text("SUM")
				.tag(CKEDataSeriesConfiguration.DataStrategy.sum)
		}
		#if !os(watchOS)
		.pickerStyle(.segmented)
		#else
		.pickerStyle(.automatic)
		#endif
	}
}

struct CKEConfigurationView_Previews: PreviewProvider {

	static var previews: some View {
		@State var configurations: [String: CKEDataSeriesConfiguration] = [:]
		List {
			CKEConfigurationView(
				configurationId: "",
				configurations: $configurations
			)
			.padding()
			CKEConfigurationView(
				configurationId: "",
				configurations: $configurations
			)
		}
		.listStyle(.automatic)
	}
}
