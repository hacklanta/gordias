//
//  ReplBot is a ChatBot that interacts with the user at a
//  REPL prompt.
//

import Foundation

public class ReplBot: ChatBot {
    public let name: String
    
    // Definitely room for optimization here, since removing is going to be a pain, but that's for the future. For small enough rulesets this should be trivial.
    private var rules: [(String?, ChatMessageProcessor)] = []
    
    public init(named _botName: String) {
        self.name = _botName
    }

    public func listen() {
        var message: String? = nil
        repeat {
            if let message = message {
                process(message: message)
            }
            
            print("\(name)> ", terminator: "")
            message = readLine(strippingNewline: true)
        } while message != nil && message != "exit"

        if message != "exit" {
            print("")
        }
    }
    
    public func listen(for _processor: ChatMessageProcessor, id: String? = nil) {
        rules.append((id, _processor))
    }
    
    public func unlisten(id: String) -> Bool {
        let oldRules = rules
        rules = rules.filter { $0.0 == id }

        return rules.count != oldRules.count
    }
    
    public func process(message: String) {
        for response in responsesFor(message: message) {
            print(response)
        }
    }
    
    func responsesFor(message: String) -> [ChatResponse] {
        return rules.compactMap { $0.1.response(for: message) }
    }
}
