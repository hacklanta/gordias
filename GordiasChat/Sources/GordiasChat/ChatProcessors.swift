//
//  ChatProcessor classes and related helpers.
//

import Foundation

class ChatMatcherResponse: ChatMessageProcessor {
    let matcher: ChatMatcher
    let responseFunc: (String) -> ChatResponse
    
    init(matcher: ChatMatcher, responseFunc: @escaping (String) -> ChatResponse) {
        self.matcher = matcher
        self.responseFunc = responseFunc
    }
    
    func response(for _message: String) -> ChatResponse? {
        if matcher.doesMatch(message: _message) {
            return responseFunc(_message)
        } else {
            return nil
        }
    }
}

extension ChatBot {
    public func listen(for _matcher: ChatMatcher, responding _responseFunc: @escaping (String) -> ChatResponse, id: String? = nil) {
        listen(for: ChatMatcherResponse(matcher: _matcher, responseFunc: _responseFunc), id: id)
    }
    
    public func listen(forPattern _pattern: String, responding _responseFunc: @escaping (String) -> ChatResponse, id: String? = nil) throws {
        listen(for: try NSRegularExpression(pattern: _pattern, options: []), responding: _responseFunc, id: id)
    }
}
