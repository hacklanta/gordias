//
//  RegExUtils.swift
//  Basic
//
//  Created by Antonio Salazar Cardozo on 5/5/19.
//

import Foundation

extension NSTextCheckingResult {
    /// Returns the range for the given index as a Substring of the given String,
    /// unless the range is not valid for that `String`.
    ///
    /// - Precondition: This result must be of `resultType` `.regularExpression`.
    func range(inString string: String, at index: Int) -> Substring? {
        guard self.resultType == .regularExpression else {
            preconditionFailure("Called range(inString:at:) on non-regular expression NSTextCheckingResult: \(self)")
        }

        return Range(self.range(at: index), in: string).flatMap { string[$0] }
    }

    /// Returns an Array of the ranges this result contains as Substrings of the
    /// given String.
    ///
    /// - Precondition: This result must be of `resultType` `.regularExpression`.
    func ranges(inString string: String) -> [Substring] {
        guard self.resultType == .regularExpression else {
            preconditionFailure("Called range(inString:at:) on non-regular expression NSTextCheckingResult: \(self)")
        }

        return (1..<self.numberOfRanges).compactMap {
            self.range(inString: string, at: $0)
        }
    }
}
