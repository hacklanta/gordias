//
//  GordiasChat is the chat module of the Gordias operations framework.
//

import Foundation

public protocol ChatMatcher {
    func doesMatch(message: String) -> Bool
}

public protocol ChatMessageProcessor {
    func response(for _message: String) -> ChatResponse?
}

public protocol ChatResponse {
    func message() -> String
}

public protocol ChatBot {
    var name: String { get }

    func listen()
    /**
     * Processes a single received message. Exposed publicly so that it
     * can be accessed programmatically if needed. Should be used internally
     * for handling messages as well for conformance.
     */
    func process(message: String)
    
    func listen(for: ChatMessageProcessor, id: String?)
    func unlisten(id: String) -> Bool
}
