//
//  Various chat matchers that can be used to set up chat message
//  handling.
//

import Foundation

extension NSRegularExpression: ChatMatcher {
    public func doesMatch(message: String) -> Bool {
        return self.firstMatch(in: message, options: [], range: NSMakeRange(0, message.count)) != nil
    }
}

final class FuncMatcher: ChatMatcher {
    let matcherFunc: (String)->Bool
    
    init(matcher: @escaping (String)->Bool) {
        self.matcherFunc = matcher
    }
    
    func doesMatch(message: String) -> Bool {
        return matcherFunc(message)
    }
}

func matcher(_matcherFunc: @escaping (String)->Bool) -> ChatMatcher {
    return FuncMatcher(matcher: _matcherFunc)
}
