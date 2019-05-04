//
//  help.swift
//  Basic
//
//  Created by Antonio Salazar Cardozo on 4/26/19.
//

import Foundation

import GordiasChat

private let helpPattern = "^help *(?<filter>.*)?",
    help =
"""
help:: Lists all available message processors and their help information.
help <filter>:: Lists all message processors matching <filter> and their help information.
"""

private func helpResponse(forBot _bot: ChatBot) -> ([NSTextCheckingResult],String) -> ChatResponse? {
    return { matches, message in
        // More than one match shouldn't happen, nor should 0.
        guard matches.count == 1 else { return nil }

        let availableHelp = _bot.processors.map { $0.help }

        if let filterRange = Range(matches[0].range(withName: "filter"),
                                   in: message), !filterRange.isEmpty {
            return availableHelp
                .filter({ $0.starts(with: message[filterRange]) })
                .joined(separator: "\n")
        } else {
            return availableHelp.joined(separator: "\n")
        }
    }
}

func addHelp(forBot _bot: ChatBot) throws {
    try _bot.listen(forPattern: helpPattern,
                    responding: helpResponse(forBot: _bot),
                    help: help)
}
