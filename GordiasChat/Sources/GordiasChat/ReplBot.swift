//
//  ReplBot is a ChatBot that interacts with the user at a
//  REPL prompt.
//

import Foundation
import GordiasBrain

/// ReplBot is a REPL-based implementation of the `ChatBot` protocol.
public class ReplBot: ChatBot {
    public let name: String
    public var brain: Brain
    private let saveTimer: DispatchSourceTimer?

    public var processors: [ChatMessageProcessor] {
        get {
            return rules.map { $0.1 }
        }
    }
    
    // Definitely room for optimization here, since removing is going to be a
    // pain, but that's for the future. For small enough rulesets this should be
    // trivial.
    private var rules: [(String?, ChatMessageProcessor)] = []
    
    public init(named _botName: String, brain: Brain = InMemoryBrain()) {
        self.name = _botName
        self.brain = brain

        if let savingBrain = self.brain as? SavingBrain {
            // FIXME Cleanup of the timer on deinit probably isn't a bad idea.
            let saveTimer = DispatchSource.makeTimerSource()
            saveTimer.schedule(deadline: .now(), repeating: .seconds(1))
            saveTimer.setEventHandler {
                do {
                    try savingBrain.save()
                } catch let e {
                    // TODO Exponential backoff in timer reschedule?
                    print("Error saving brain", e)
                }
            }
            self.saveTimer = saveTimer
            saveTimer.activate()
        } else {
            self.saveTimer = nil
        }
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
    
    public func listen(for _processor: SynchronousResponder, id: String? = nil) {
        rules.append((id, _processor))
    }

    public func listen(for _processor: FutureResponder, id: String? = nil) {
        rules.append((id, _processor))
    }
    
    public func unlisten(id: String) -> Bool {
        let oldRules = rules
        rules = rules.filter { $0.0 == id }

        return rules.count != oldRules.count
    }
    
    public func process(message: String) {
        rules.forEach { _, processor in
            switch processor {
            case let synchronous as SynchronousResponder:
                if let response = synchronous.response(for: message) {
                    print(": " + response.message())
                }
            case let future as FutureResponder:
                if let future = future.response(for: message) {
                    future.whenReady(_handler: { response in
                        guard let response = response else { return }

                        print(": " + response.message())
                    })
                }
            default:
                break
            }
        }
    }
}
