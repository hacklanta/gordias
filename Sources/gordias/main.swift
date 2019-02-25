import Foundation
import Utility

import GordiasChat

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parser = ArgumentParser(usage: "<options>", overview: "run modules in the gordias operations system")

let parsed = try parser.parse(arguments)

let replBot = ReplBot()
replBot.initialize(botName: "Heimdall")
try replBot.listen(forPattern: "^Hello", responding: { (message) in "Ohai!" })

replBot.listen()
