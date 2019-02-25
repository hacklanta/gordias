import Foundation
import Utility

import GordiasChat

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

enum Adapter: ArgumentKind {
    init(argument: String) throws {
        switch argument {
        case "repl":
            self = .repl
        default:
            self = .repl
        }
    }
    
    static var completion: ShellCompletion = .values([("repl", "Interact with chat via the console.")])
    
    case repl
    
    var bot: ChatBot {
        get {
            switch self {
            case .repl: return ReplBot()
            }
        }
    }
}

let parser = ArgumentParser(usage: "<options>", overview: "run modules in the gordias operations system")
let adapterArgument = parser.add(option: "--adapter", shortName: "-a", kind: Adapter.self, usage: "Specify the adapter to use; defaults to repl", completion: Adapter.completion)

do {
    let parsed = try parser.parse(arguments)
    let adapter = parsed.get(adapterArgument) ?? Adapter.repl
    let bot = adapter.bot

    bot.initialize(botName: "Heimdall")
    try bot.listen(forPattern: "^Hello", responding: { (message) in "Ohai!" })

    bot.listen()
} catch let ape as ArgumentParserError {
    FileHandle.standardError.write(String(describing: ape).data(using: .utf8)!)
}
