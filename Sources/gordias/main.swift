import Foundation
import Utility

import GordiasChat

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parser = ArgumentParser(usage: "<options>", overview: "run modules in the gordias operations system")
let adapterArgument = parser.add(option: "--adapter", shortName: "-a", kind: AdapterArgument.self, usage: "Specify the adapter to use; defaults to repl", completion: AdapterArgument.completion)

do {
    let parsed = try parser.parse(arguments)
    let adapter = parsed.get(adapterArgument) ?? AdapterArgument.repl
    let bot = adapter.bot(named: "Gordias")

    try addHelp(forBot: bot)

    bot.listen()
} catch let ape as ArgumentParserError {
    FileHandle.standardError.write(String(describing: ape).data(using: .utf8)!)
}
