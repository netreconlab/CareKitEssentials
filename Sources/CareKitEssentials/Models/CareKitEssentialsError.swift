//
//  CareKitEssentialsError.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 12/12/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

enum CareKitEssentialsError: Error {
    case userNotLoggedIn
    case requiredValueCantBeUnwrapped
    case couldntUnwrapRequiredField
    case couldntUnwrapSelf
    case cantCastToNeededType
    case error(_ error: Error)
    case errorString(_ string: String)
}

extension CareKitEssentialsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return NSLocalizedString("CareKitEssentialsError: User is not logged in.", comment: "Login error")
        case .requiredValueCantBeUnwrapped:
            return NSLocalizedString("CareKitEssentialsError: Required value can't be unwrapped.",
                                     comment: "Unwrapping error")
        case .cantCastToNeededType:
            return NSLocalizedString("CareKitEssentialsError: Cannot cast to needed type.",
                                     comment: "Cannot cast to needed type")
        case .couldntUnwrapRequiredField:
            return NSLocalizedString("CareKitEssentialsError: Could not unwrap required field.",
                                     comment: "Could not unwrap required field")
        case .couldntUnwrapSelf:
            return NSLocalizedString("Cannot unwrap self. This class has already been deallocated",
                                     comment: "Cannot unwrap self, class deallocated")
        case .error(let error): return "\(error)"
        case .errorString(let string): return string
        }
    }
}
