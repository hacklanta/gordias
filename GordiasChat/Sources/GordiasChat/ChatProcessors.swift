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
