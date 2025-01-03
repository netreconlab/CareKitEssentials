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

Provides essential cards, views, models, protocols, and extensions to expedite building [CareKit](https://github.com/carekit-apple/CareKit) based applications.

## Entensions
A number of public extensions are available to make using CareKit easier. All of the extensions can be found in the [Extensions](https://github.com/netreconlab/CareKitEssentials/tree/main/Sources/CareKitEssentials/Extensions) folder.

## Usage
You can create SwiftUI views that conform to [CareKitEssentialView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/Shared/CareKitEssentialView.swift) to obtain a number of convenience methods for saving and deleting outcomes. The framework adds a number of additional cards that can be found in the [Cards](https://github.com/netreconlab/CareKitEssentials/tree/main/Sources/CareKitEssentials/Cards) folder. The following add views/cards are based on `CareKitEssentialView`:

### Shared
[CareEssentialChartView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/Shared/Chart/CareEssentialChartView.swift) to create charts from CareKit data based on SwiftUI Charts.

<img width="342" alt="image" src="https://github.com/user-attachments/assets/ae54936e-9831-425b-8bdb-ac3421ab883a">

### iOS
[SliderLogTaskView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/iOS/SliderLog/SliderLogTaskView.swift) can be used to quickly create a slider view

<img width="342" alt="image" src="https://github.com/netreconlab/CareKitEssentials/assets/8621344/3efb4226-50e2-41e1-beef-91bc84cc7d63">

### watchOS
[DigitalCrownView](https://github.com/netreconlab/CareKitEssentials/blob/main/Sources/CareKitEssentials/Cards/watchOS/DigitalCrown/DigitalCrownView.swift) can be used to quickly create a view that responds to the crown

<img width="332" alt="image" src="https://github.com/netreconlab/CareKitEssentials/assets/8621344/02023682-75f4-4dff-a575-fa3ffd213cc3">
