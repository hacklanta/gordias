//
//  Various chat responses that can be used to respond to
//  matched chat messages.
//

import Foundation

// Make Strings valid responses.
extension String: ChatResponse {
    public func message() -> String {
        return self
    }
}

struct StringConvertingChatResponse: ChatResponse {
    let object: Any
    
    func message() -> String {
        return String(describing: object)
    }
}

func responseFor(_in: String) -> ChatResponse {
    return _in
}

func responseFor<T>(_in: T) -> ChatResponse {
    return StringConvertingChatResponse(object: _in)
}
