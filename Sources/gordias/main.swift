import Foundation
import Utility

import GordiasChat

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parser = ArgumentParser(usage: "<options>", overview: "run modules in the gordias operations system")
let adapterArgument = parser.add(option: "--adapter", shortName: "-a", kind: AdapterArgument.self, usage: "Specify the adapter to use; defaults to repl", completion: AdapterArgument.completion)

do {
    let parsed = try parser.parse(arguments)
    let adapter = parsed.get(adapterArgument) ?? AdapterArgument.repl
    let bot = adapter.bot(named: "Heimdall")

    try bot.listen(forPattern: "^help *(?<filter>.*)?", responding: { matches, message in
        // More than one match shouldn't happen, nor should 0.
        guard matches.count == 1 else { return nil }

        if let filterRange = Range(matches[0].range(withName: "filter"),
                                   in: message), !filterRange.isEmpty {
            return "Help filtered by [\(message[filterRange])]"
        } else {
            return "Full help!"
        }
    })

    bot.listen()
} catch let ape as ArgumentParserError {
    FileHandle.standardError.write(String(describing: ape).data(using: .utf8)!)
}
