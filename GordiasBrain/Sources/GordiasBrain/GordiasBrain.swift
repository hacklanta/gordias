
import Foundation

public protocol Brain {
    mutating func set<T: Codable>(value: T, ofType type: T.Type, forKey key: String)
    func value<T: Codable>(ofType type: T.Type, forKey key: String) -> T?
}

public protocol SavingBrain: Brain {
    func save() throws
}
