//
//  RegExUtils.swift
//  Basic
//
//  Created by Antonio Salazar Cardozo on 5/5/19.
//

import Foundation

extension NSTextCheckingResult {
    /// Iterates over each indexed range in this `NSTextCheckingResult`, calling
    /// the passed `body` for each one. The result of `body` is discarded.
    ///
    /// - Precondition: This result must be of `resultType` `regularExpression`.
    func forEachRange(body: (NSRange) throws -> Void) throws {
        guard self.resultType == .regularExpression else {
            preconditionFailure("Called forEachRange on non-regular expression NSTextCheckingResult: \(self)")
        }

        for rangeIndex in 1..<self.numberOfRanges {
            try body(self.range(at: rangeIndex))
        }
    }

    /// Iterates over each indexed range in this `NSTextCheckingResult` and
    /// resolves that range in the passed `string`, calling the passed `body`
    /// for each matched substring. The result of `body` is discarded.
    ///
    /// - Precondition: This result must be of `resultType` `regularExpression`.
    /// - Precondition: This `NSTextCheckingResult` must come from matching
    ///     against `string`.
    func forEachRange(in string: String, body: (Substring) throws -> Void) throws {
        let resolvedRanges = try mapRange { Range($0, in: string) }
        precondition(resolvedRanges.firstIndex(of: nil) == nil,
                     "Called forEachRange(inString:) on [\(self)] even though not all matched ranges are valid in the passed string: \(string)")

        try resolvedRanges.forEach { range in
            // Force-unwrap range since we've preconditioned that all are
            // non-nil.
            try body(string[range!])
        }
    }

    /// Iterates over each indexed range in this NSTextCheckingResult, calling
    /// the passed `transform` for each one. The result of calling `transform`
    /// is accumulated, and a sequence of the gathered results is returned.
    ///
    /// - Precondition: This result must be of `resultType` `regularExpression`.
    func mapRange<T>(transform: (NSRange) throws -> T) throws -> [T] {
        guard self.resultType == .regularExpression else {
            preconditionFailure("Called mapRange on non-regular expression NSTextCheckingResult: \(self)")
        }

        var accumulator: [T] = []
        for rangeIndex in 1..<self.numberOfRanges {
            accumulator.append(try transform(self.range(at: rangeIndex)))
        }

        return accumulator
    }

    /// Iterates over each indexed range in this NSTextCheckingResult and
    /// resolves that range in the passed `string`, calling the passed
    /// `transform` for each one. The result of calling `transform` is
    /// accumulated, and a sequence of the gathered results is returned.
    ///
    /// - Precondition: This result must be of `resultType` `regularExpression`.
    /// - Precondition: This `NSTextCheckingResult` must come from matching
    ///     against `string`.
    func mapRange<T>(in string: String, transform: (Substring) throws -> T) throws -> [T] {
        var accumulator: [T] = []

        try self.forEachRange(in: string) { substring in
            accumulator.append(try transform(substring))
        }

        return accumulator
    }
}
