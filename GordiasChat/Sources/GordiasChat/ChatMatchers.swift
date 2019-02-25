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

// FIXME Move this into ChatProcessors.swift once XCode 10.2 and Swift 5 roll around.
extension ChatBot {
    public func listen(for _matcher: ChatMatcher, responding _responseFunc: @escaping (String) -> ChatResponse, id: String? = nil) {
        listen(for: ChatMatcherResponse(matcher: _matcher, responseFunc: _responseFunc), id: id)
    }
    
    public func listen(forPattern _pattern: String, responding _responseFunc: @escaping (String) -> ChatResponse, id: String? = nil) throws {
        listen(for: try NSRegularExpression(pattern: _pattern, options: []), responding: _responseFunc, id: id)
    }
}
