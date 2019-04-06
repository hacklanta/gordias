//
//  ChatProcessor classes and related helpers.
//

import Foundation

/**
 * ChatMatcherProcessor is a `ChatMessageProcessor` that decides whether to
 * respond to a given message based on a given `ChatMatcher`, and delegates the
 * production of a response to a `responseFunc`, an anonymous function that
 * takes the message that was identified as matching and returns a
 * `ChatResponse`.
 *
 * Some extensions are provided to the `ChatBot` protocol to allow for directly
 * registering a `ChatMatcherProcessor`, either via `listen(for:responding:)`
 * (to pass a `ChatMatcher` and function directly) or
 * `listen(forPattern:responding:)` (to pass a regular expression pattern and
 * function).
 */
class ChatMatcherProcessor<ProcessorMatchType, MatcherType: ChatMatcher>: ChatMessageProcessor where MatcherType.MatchType == ProcessorMatchType {
    let matcher: MatcherType
    let responseFunc: (String, [MatcherType.MatchType]) -> ChatResponse
    
    init(matcher: MatcherType, responseFunc: @escaping (String, [MatcherType.MatchType]) -> ChatResponse) {
        self.matcher = matcher
        self.responseFunc = responseFunc
    }
    
    func response(for _message: String) -> ChatResponse? {
        let matches = matcher.matches(message: _message)
        if matches.isEmpty {
            return nil
        } else {
            return responseFunc(_message, matches)
        }
    }
}

extension ChatBot {
    public func listen<FuncMatchType, MatcherType: ChatMatcher>(for _matcher: MatcherType,
                                                   responding _responseFunc: @escaping (String, [FuncMatchType]) -> ChatResponse,
                                                   id: String? = nil)
    where MatcherType.MatchType == FuncMatchType {
        listen(for: ChatMatcherProcessor(matcher: _matcher, responseFunc: _responseFunc), id: id)
    }
    
    public func listen(forPattern _pattern: String,
                       responding _responseFunc: @escaping (String, [NSTextCheckingResult]) -> ChatResponse,
                       id: String? = nil) throws {
        listen(for: try NSRegularExpression(pattern: _pattern, options: []), responding: _responseFunc, id: id)
    }
}
