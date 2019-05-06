//
//  imgflip.swift
//  Basic
//
//  Created by Antonio Salazar Cardozo on 5/4/19.
//

import Foundation
import GordiasChat

private let imgflipBaseURL = URL(staticString: "https://api.imgflip.com/caption_image")

private struct MemeTemplate {
    let pattern: NSRegularExpression
    let templateID: Int
}

private let memeTemplates = wrappedThrow(withDefault: []) {
    [
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(one does not simply) (.*)"),
                     templateID: 61579),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(i don'?t always .*) (but when i do,? .*)"),
                     templateID: 61532),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "aliens ()(.*)"),
                     templateID: 101470),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "grumpy cat ()(.*)"),
                     templateID: 405658),
        MemeTemplate(pattern: try NSRegularExpression(pattern: #"(.*),? (\1 everywhere)"#),
                     templateID: 347390),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(not sure if .*) (or .*)"),
                     templateID: 61520),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(y u no) (.+)"),
                     templateID: 61527),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(brace yoursel[^\\s]+) (.*)"),
                     templateID: 61546),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(.*) (all the .*)"),
                     templateID: 61533),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(.*) (that would be great|that'?d be great)"),
                     templateID: 563423),
        MemeTemplate(pattern: try NSRegularExpression(pattern: #"(.*) (\w+\stoo damn .*)"#),
                     templateID: 61580),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(yo dawg .*) (so .*)"),
                     templateID: 101716),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(.*) (.* gonna have a bad time)"),
                     templateID: 100951),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(am i the only one around here) (.*)"),
                     templateID: 259680),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(what if i told you) (.*)"),
                     templateID: 100947),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(.*) (ain'?t nobody got time for? that)"),
                     templateID: 442575),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(.*) (i guarantee it)"),
                     templateID: 10672255),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(.*) (a+n+d+ it'?s gone)"),
                     templateID: 766986),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(.* bats an eye) (.* loses their minds?)"),
                     templateID: 1790995),
        MemeTemplate(pattern: try NSRegularExpression(pattern: "(back in my day) (.*)"),
                     templateID: 718432)
    ]
}

private let imgflipPatterns = "^help *(?<filter>.*)?"
private let imgflipHelp =
"""
help:: Lists all available message processors and their help information.
help <filter>:: Lists all message processors matching <filter> and their help information.
"""

private func imgflipURLRequest(forTemplateID templateID: Int, boxes: [String]) -> URLRequest {
    var component = URLComponents(url: imgflipBaseURL, resolvingAgainstBaseURL: false)!

    let boxItems = boxes.enumerated().map { URLQueryItem(name: "boxes[\($0.offset)][text]", value: $0.element) }

    component.queryItems = [
        URLQueryItem(name: "template_id", value: String(templateID)),
        URLQueryItem(name: "username", value: "imgflip_hubot"),
        URLQueryItem(name: "password", value: "imgflip_hubot")
    ] + boxItems

    guard let finalURL = component.url else {
        preconditionFailure("Malformed final imgflip URL: \(component)")
    }

    let request = URLRequest(url: finalURL)

    return request
}

private func urlForTemplate(templateID: Int, matches: [String]) {
    URLSession.shared
        .dataTask(with: imgflipURLRequest(forTemplateID: templateID, boxes: matches)) { (data, response, error) in
            guard error == nil else {
                wrappedThrow { throw HTTPError.unknown(error) }
                return
            }
            guard let imageData = data, let _ = response else {
                unexpectedClosureParametersError(method: "dataTask(with:)",
                                                 parameterPairs: "data:", data, "response:", response)
                return
            }

            print("-------\n", String(data: imageData, encoding: .utf8)!, "\n-------")
        }.resume()
}

func addImgflip(toBot bot: ChatBot) {
    memeTemplates.forEach { (template) in
        bot.listen(for: template.pattern, responding: { (matches, message) in
            print("Here I am! \(message)")
            do {
                try matches.forEach({ match in
                    try urlForTemplate(templateID: template.templateID,
                                       matches: match.mapRange(in: message) { String($0) })
                })

                return ""
            } catch {
                return "💩"
            }
        }, help: String(describing: template.pattern))
    }
}
