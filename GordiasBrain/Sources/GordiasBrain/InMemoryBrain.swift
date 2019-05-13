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

public struct JSONFileBrain: SavingBrain, Codable {
    internal struct RawEntry {
        let typeName: String
        let encodeJSON: (JSONEncoder) throws -> Data
        let value: Codable
    }
    internal typealias SerializedData = [SerializedEntry]
    internal struct SerializedEntry: Codable {
        let name: String
        let typeName: String
        let value: Data
    }

    private var reifiedData: [String: RawEntry] = [:]
    private var serializedData: SerializedData = []

    public init() {}

    public mutating func set<T: Codable>(value: T, ofType type: T.Type, forKey key: String) {
        reifiedData[key] = RawEntry(typeName: String(describing: type),
                                    encodeJSON: { try $0.encode(value) },
                                    value: value)
    }

    public func value<T: Codable>(ofType type: T.Type, forKey key: String) -> T? {
        let knownValue = reifiedData[key]
        if let value = knownValue,
            let typedValue = value as? T {
            return typedValue
        } else {
            return (try? extractValueFromUnknownData(ofType: type, forKey: key)) ?? nil
        }
    }

    internal func extractValueFromUnknownData<T: Decodable>(ofType type: T.Type, forKey key: String) throws -> T? {
        let typeName = String(describing: type)
        if let lastMatch = serializedData.last(where: { $0.typeName == typeName }) {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: lastMatch.value)
        } else {
            return nil
        }
    }

    public func save() throws -> String {
        let encoded = try JSONEncoder().encode(self)
        return String(data: encoded, encoding: .utf8) ?? "<no data>"
    }

    enum CodingKeys: String, CodingKey {
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.serializedData = try container.decode(SerializedData.self, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        let valueEncoder = JSONEncoder()

        var data = try! reifiedData.map({ (key, entry) -> SerializedEntry in
            SerializedEntry(name: key,
                            typeName: entry.typeName,
                            value: try entry.encodeJSON(valueEncoder))
        })

        data.append(contentsOf: serializedData.filter {
            !reifiedData.keys.contains($0.name)
        })

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
}
