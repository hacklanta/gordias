//
//  AdapterArgument.swift
//  Basic
//
//  Created by Antonio Salazar Cardozo on 4/5/19.
//

import Utility

import GordiasChat

/*!
 AdapterArgument is an enum that represents the adapters that are
 supported as command-line switches for interacting with gordias.
 */
enum AdapterArgument: ArgumentKind {
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

    func bot(named _botName: String) -> ChatBot {
        switch self {
        case .repl: return ReplBot(named: _botName)
        }
    }
}

