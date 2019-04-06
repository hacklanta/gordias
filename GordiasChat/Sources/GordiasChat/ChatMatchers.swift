//
//  Various chat matchers that can be used to set up chat message
//  handling.
//

import Foundation

extension NSRegularExpression: ChatMatcher {
    public typealias MatchType = NSTextCheckingResult

    public func matches(message: String) -> [NSTextCheckingResult] {
        return self.matches(in: message, options: [], range: NSMakeRange(0, message.count))
    }
}

final class FuncMatcher<FuncMatchType>: ChatMatcher {
    public typealias MatchType = FuncMatchType

    let matcherFunc: (String)->[MatchType]
    
    init(matcher: @escaping (String)->[MatchType]) {
        self.matcherFunc = matcher
    }
    
    func matches(message: String) -> [MatchType] {
        return matcherFunc(message)
    }
}

func matcher<FuncMatchType, MatcherType: ChatMatcher>(_matcherFunc: @escaping (String)->[FuncMatchType]) -> MatcherType where MatcherType.MatchType == FuncMatchType {
    return FuncMatcher<FuncMatchType>(matcher: _matcherFunc) as! MatcherType
}
