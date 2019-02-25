//
//  ReplBot is a ChatBot that interacts with the user at a
//  REPL prompt.
//

import Foundation

public class ReplBot: ChatBot {
    private var botName: String = ""
    // Definitely room for optimization here, since removing is going to be a pain, but that's for the future. For small enough rulesets this should be trivial.
    private var rules: [(String?, ChatMessageProcessor)] = []
    
    public init() {}
    
    public func initialize(botName: String) {
        print("Hello, my name is \(botName)!")
        self.botName = botName
    }
    
    public func listen() {
        var message: String? = nil
        repeat {
            if let message = message {
                receive(message: message)
            }
            
            print("\(botName)> ", terminator: "")
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
    
    public func receive(message: String) {
        for response in process(message: message) {
            print(response)
        }
    }
    
    func process(message: String) -> [ChatResponse] {
        return rules.compactMap { $0.1.response(for: message) }
    }
}
