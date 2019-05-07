
import Foundation

public protocol Brain {
    subscript (key: String) -> Any? { get set }
}
