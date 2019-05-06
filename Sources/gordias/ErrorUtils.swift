// Utilities for error handling across Gordias.

import Foundation

enum HTTPError: Error {
    case unknown(Error?)
}

func unexpectedClosureParametersError(method: String, parameterPairs: Any?...) {
    let pairString = parameterPairs.map { String(describing: $0) }.joined(separator: ", ")

    preconditionFailure(
        String(format: "Unexpected closure parameters for [%s]: %s", method, pairString)
    )
}

func wrappedThrow<T>(throwingFn: () throws -> T) -> T? {
    do {
        return try throwingFn()
    } catch let error {
        FileHandle.standardError.write(String(describing: error).data(using: .utf8)!)
    }

    return nil
}

func wrappedThrow<T>(withDefault defaultT: T, throwingFn: () throws -> T) -> T {
    return wrappedThrow(throwingFn: throwingFn) ?? defaultT
}
