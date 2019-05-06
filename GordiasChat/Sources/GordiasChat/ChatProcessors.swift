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
class ChatMatcherProcessor<ProcessorMatchType, MatcherType: ChatMatcher>: SynchronousResponder where MatcherType.MatchType == ProcessorMatchType {
    public let help: String

    let matcher: MatcherType
    let responseFunc: ([MatcherType.MatchType], String) -> ChatResponse?

    init(matcher: MatcherType,
         responseFunc: @escaping ([MatcherType.MatchType], String) -> ChatResponse?,
         help: String) {
        self.matcher = matcher
        self.responseFunc = responseFunc
        self.help = help
    }
    
    func response(for _message: String) -> ChatResponse? {
        let matches = matcher.matches(message: _message)
        if matches.isEmpty {
            return nil
        } else {
            return responseFunc(matches, _message)
        }
    }
}

/**
 * FutureChatMatcherProcessor is a `ChatMessageProcessor` that decides whether to
 * respond to a given message based on a given `ChatMatcher`, and delegates the
 * production of a response to a `responseFunc`, an anonymous function that
 * takes the message that was identified as matching and returns a
 * `ChatResponse`.
 *
 * Some extensions are provided to the `ChatBot` protocol to allow for directly
 * registering a `FutureChatMatcherProcessor`, either via `listen(for:responding:)`
 * (to pass a `ChatMatcher` and function directly) or
 * `listen(forPattern:responding:)` (to pass a regular expression pattern and
 * function).
 */
class FutureChatMatcherProcessor<ProcessorMatchType, MatcherType: ChatMatcher>: FutureResponder where MatcherType.MatchType == ProcessorMatchType {
    public let help: String

    let matcher: MatcherType
    let responseFunc: ([MatcherType.MatchType], String) -> FutureChatResponse?

    init(matcher: MatcherType,
         responseFunc: @escaping ([MatcherType.MatchType], String) -> FutureChatResponse?,
         help: String) {
        self.matcher = matcher
        self.responseFunc = responseFunc
        self.help = help
    }

    func response(for _message: String) -> FutureChatResponse? {
        let matches = matcher.matches(message: _message)
        if matches.isEmpty {
            return nil
        } else {
            return responseFunc(matches, _message)
        }
    }
}

extension ChatBot {
    public func listen<FuncMatchType, MatcherType: ChatMatcher>(for _matcher: MatcherType,
                                                   responding _responseFunc: @escaping ([FuncMatchType], String) -> ChatResponse?,
                                                   help: String,
                                                   id: String? = nil)
    where MatcherType.MatchType == FuncMatchType {
        listen(for: ChatMatcherProcessor(matcher: _matcher, responseFunc: _responseFunc, help: help), id: id)
    }

    public func listen<FuncMatchType, MatcherType: ChatMatcher>(for _matcher: MatcherType,
                                                                respondingLater _responseFunc: @escaping ([FuncMatchType], String) -> FutureChatResponse?,
                                                                help: String,
                                                                id: String? = nil)
        where MatcherType.MatchType == FuncMatchType {
            listen(for: FutureChatMatcherProcessor(matcher: _matcher, responseFunc: _responseFunc, help: help), id: id)
    }
    
    public func listen(forPattern _pattern: String,
                       responding _responseFunc: @escaping ([NSTextCheckingResult], String) -> ChatResponse?,
                       help: String,
                       id: String? = nil) throws {
        listen(for: try NSRegularExpression(pattern: _pattern, options: []), responding: _responseFunc, help: help, id: id)
    }
}
