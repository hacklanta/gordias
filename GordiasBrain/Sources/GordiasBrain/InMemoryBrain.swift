import Foundation

extension Dictionary: Brain where Key == String, Value == Any {
    public mutating func set<T>(value: T, ofType type: T.Type, forKey key: String) {
        self[key] = value
    }

    public func value<T: Codable>(ofType type: T.Type, forKey key: String) -> T? {
        return self[key].flatMap { $0 as? T }
    }

}

public typealias InMemoryBrain = Dictionary<String,Any>
