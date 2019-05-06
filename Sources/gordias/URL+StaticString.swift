import Foundation

extension URL {
    //  Lifted from https://www.swiftbysundell.com/posts/constructing-urls-in-swift .
    public init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}
