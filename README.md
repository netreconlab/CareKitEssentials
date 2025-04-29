# CareKitEssentials

[![Documentation](https://img.shields.io/badge/read_-iOS_docs-2196f3.svg)](https://swiftpackageindex.com/netreconlab/CareKitEssentials/documentation/)
[![Documentation](https://img.shields.io/badge/read_-watchOS_docs-2196f3.svg)](https://netreconlab.github.io/CareKitEssentials/release/documentation/carekitessentials/)
[![Tuturiol](https://img.shields.io/badge/read_-tuturials-2196f3.svg)](https://netreconlab.github.io/CareKitEssentials/release/tutorials/carekitessentials/)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnetreconlab%2FCareKitEssentials%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/netreconlab/CareKitEssentials)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnetreconlab%2FCareKitEssentials%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/netreconlab/CareKitEssentials)
![Xcode 16.1+](https://img.shields.io/badge/xcode-13.2%2B-blue.svg)
[![ci](https://github.com/netreconlab/CareKitEssentials/actions/workflows/ci.yml/badge.svg)](https://github.com/netreconlab/CareKitEssentials/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/netreconlab/CareKitEssentials/branch/main/graph/badge.svg?token=o1iDOdx3Sz)](https://codecov.io/gh/netreconlab/CareKitEssentials)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://github.com/netreconlab/ParseCareKit/#license)

Provides essential cards, views, models, protocols, and extensions to expedite building [CareKit](https://github.com/carekit-apple/CareKit) based applications. If you are using `CareKit` models in SwiftUI views, `CareKitEssentials` adds a number of extensions to `CareKit` models to enable your views to update properly. Simply add `import CareKitEssentials` to each of your SwiftUI view files and your SwiftUI views will start working correctly.

## Entensions
A number of public extensions are available to make using CareKit easier. All of the extensions can be found in the [Extensions](https://github.com/netreconlab/CareKitEssentials/tree/main/Sources/CareKitEssentials/Extensions) and [Cards/Shared/Extensions](https://github.com/netreconlab/CareKitEssentials/tree/main/Sources/CareKitEssentials/Cards/Shared/Extensions) folders.

## Usage
You can create SwiftUI views that conform to [CareKitEssentialView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/Shared/CareKitEssentialView.swift) to obtain a number of convenience methods for saving and deleting outcomes. The framework adds a number of additional cards that can be found in the [Cards](https://github.com/netreconlab/CareKitEssentials/tree/main/Sources/CareKitEssentials/Cards) folder. The following add views/cards are based on `CareKitEssentialView`:

### watchOS
[DigitalCrownView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/watchOS/DigitalCrown/DigitalCrownView.swift) can be used to quickly create a view that responds to the crown

<img width="332" alt="image" src="https://github.com/netreconlab/CareKitEssentials/assets/8621344/02023682-75f4-4dff-a575-fa3ffd213cc3">

### Shared
[SliderLogTaskView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/iOS/SliderLog/SliderLogTaskView.swift) can be used to quickly create a slider view

<img width="342" alt="image" src="https://github.com/netreconlab/CareKitEssentials/assets/8621344/3efb4226-50e2-41e1-beef-91bc84cc7d63">

[CareKitEssentialChartView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/Shared/Chart/CareKitEssentialChartView.swift) to create charts from CareKit data based on SwiftUI Charts. See https://github.com/netreconlab/CareKitEssentials/pull/48 for more details.

<img width="342" alt="image" src="https://github.com/user-attachments/assets/5aca133c-21f7-4a7d-b99d-36e7edab4c9c"><img width="342" alt="image" src="https://github.com/user-attachments/assets/4a4f4e52-91dc-4cba-8215-d01433d190c1">

Easily create surveys with [ResearchKitSwiftUI](https://github.com/ResearchKit/ResearchKit/pull/1585) for all supported platforms. Learn how to create your own surveys [here](https://github.com/netreconlab/CareKitEssentials/pull/41).

<img width="342" alt="image" src="https://github.com/user-attachments/assets/90e3eca8-4cea-4148-834d-2c595577fddd">
<img width="342" alt="image" src="https://github.com/user-attachments/assets/54352f9a-481a-4368-ac1c-c18e46d1d667">

Use [EventQueryView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/Shared/EventViews/EventQueryView.swift) and [EventQueryContentView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/Shared/EventViews/EventQueryContentView.swift) to display SwiftUI views inside of CareKit UIKit views such as `OCKDailyPageViewController`'s. Some examples are below:

```swift
// Displaying the out-of-the-box `NumericProgressTaskView`
let card = EventQueryView<NumericProgressTaskView>(
					query: query
)
.formattedHostingController()

return card

// Displaying a ResearchKitSwiftUI survey card
let surveyViewController = EventQueryContentView<ResearchSurveyView>(
			query: query
		) {
			EventQueryContentView<ResearchCareForm>(
				query: query
			) {
				ForEach(steps) { step in
					ResearchFormStep(
						image: step.image,
						title: step.title,
						subtitle: step.subtitle
					) {
						ForEach(step.questions) { question in
							question.view()
						}
						.tint(tintColor)
					}
				}
			}
			.tint(tintColor)
		}
		.tint(tintColor)
		.formattedHostingController()
return surveyViewController

// Extension to make life easier
private extension View {
    /// Convert SwiftUI view to UIKit view.
    func formattedHostingController() -> UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
}
```
