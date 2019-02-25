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
    func initialize(botName: String)
    func listen()
    
    func listen(for: ChatMessageProcessor, id: String?)
    func unlisten(id: String) -> Bool
    func receive(message: String)
}
