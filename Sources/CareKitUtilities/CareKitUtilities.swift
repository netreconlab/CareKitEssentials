import Foundation

enum CareKitUtilitiesError: Error {
    case error(_ error: Error)
    case errorString(_ string: String)
}

extension CareKitUtilitiesError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(let error): return "\(error)"
        case .errorString(let string): return string
        }
    }
}
