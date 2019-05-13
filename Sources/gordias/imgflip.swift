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
    let regexp: NSRegularExpression
    let help: String
    let templateID: Int
}

private struct ImgflipFailure: Decodable {
    let success: Bool
    let errorMessage: String

    enum CodingKeys: String, CodingKey {
        case success
        case errorMessage = "error_message"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decode(Bool.self, forKey: .success)
        guard !self.success else {
            throw DecodingError.dataCorruptedError(forKey: .success, in: values, debugDescription: "Imgflip failure responses should have their success property set to false, but it was set to true: \(decoder).")
        }

        errorMessage = try values.decode(String.self, forKey: .errorMessage)
    }
}

private struct ImgflipResponseData: Decodable {
    let url: String
    let pageUrl: String

    enum CodingKeys: String, CodingKey {
        case url
        case pageUrl = "page_url"
    }
}

private struct ImgflipSuccess: Decodable {
    let success: Bool
    let data: ImgflipResponseData

    enum CodingKeys: String, CodingKey {
        case success
        case data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decode(Bool.self, forKey: .success)
        guard self.success else {
            throw DecodingError.dataCorruptedError(forKey: .success, in: values, debugDescription: "Imgflip success responses should have their success property set to true, but it was set to false: \(decoder).")
        }

        data = try values.decode(ImgflipResponseData.self, forKey: .data)
    }
}

private let memeTemplates = wrappedThrow(withDefault: []) {
    [
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(one does not simply) (.*)"),
                     help: "One does not simply <text>:: Lord of the Rings Boromir",
                     templateID: 61579),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(i don'?t always .*) (but when i do,? .*)"),
                     help: "I don't always <text> but when i do <text>:: The Most Interesting man in the World",
                     templateID: 61532),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "aliens ()(.*)"),
                     help: "aliens <text>:: Ancient Aliens History Channel Guy",
                     templateID: 101470),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "grumpy cat ()(.*)"),
                     help: "grumpy cat <text>:: Grumpy Cat with text on the bottom",
                     templateID: 405658),
        MemeTemplate(regexp: try NSRegularExpression(pattern: #"(.*),? (\1 everywhere)"#),
                     help: "<text>, <text> everywhere:: X, X Everywhere (Buzz and Woody from Toy Story)",
                     templateID: 347390),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(not sure if .*) (or .*)"),
                     help: "Not sure if <text> or <text>:: Futurama Fry",
                     templateID: 61520),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(y u no) (.+)"),
                     help: "Y U NO <text>:: Y U NO Guy",
                     templateID: 61527),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(brace yoursel[^\\s]+) (.*)"),
                     help: "Brace yourselves <text>:: Brace Yourselves X is Coming (Imminent Ned, Game of Thrones)",
                     templateID: 61546),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(.*) (all the .*)"),
                     help: "<text> all the <text>:: X all the Y",
                     templateID: 61533),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(.*) (that would be great|that'?d be great)"),
                     help: "<text> that would be great:: Bill Lumbergh from Office Space",
                     templateID: 563423),
        MemeTemplate(regexp: try NSRegularExpression(pattern: #"(.*) (\w+\stoo damn .*)"#),
                     help: "<text> too damn <text>:: The rent is too damn high",
                     templateID: 61580),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(yo dawg .*) (so .*)"),
                     help: "Yo dawg <text> so <text>:: Yo Dawg Heard You (Xzibit)",
                     templateID: 101716),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(.*) (.* gonna have a bad time)"),
                     help: "<text> you're gonna have a bad time:: Super Cool Ski Instructor from South Park",
                     templateID: 100951),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(am i the only one around here) (.*)"),
                     help: "Am I the only one around here <text>:: The Big Lebowski",
                     templateID: 259680),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(what if i told you) (.*)"),
                     help: "What if I told you <text>:: Matrix Morpheus",
                     templateID: 100947),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(.*) (ain'?t nobody got time for? that)"),
                     help: "<text> ain't nobody got time for that",
                     templateID: 442575),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(.*) (i guarantee it)"),
                     help: "<text> I guarantee it:: George Zimmer",
                     templateID: 10672255),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(.*) (a+n+d+ it'?s gone)"),
                     help: "<text> and it's gone:: South Park Banker Guy",
                     templateID: 766986),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(.* bats an eye) (.* loses their minds?)"),
                     help: "<text> nobody bats an eye <text> everyone loses their minds:: Heath Ledger Joker",
                     templateID: 1790995),
        MemeTemplate(regexp: try NSRegularExpression(pattern: "(back in my day) (.*)"),
                     help: "back in my day <text>:: Grumpy old man",
                     templateID: 718432)
    ]
}

private func imgflipURLRequest(forTemplateID templateID: Int, boxes: [String]) -> URL {
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

    return finalURL
}

private func urlForTemplate(templateID: Int, matches: [String]) -> FutureChatResponse {
    let chatResponse = FutureChatResponse()
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

            if let failure = try? JSONDecoder().decode(ImgflipFailure.self, from: imageData) {
                chatResponse.resolved(response: "Imgflip returned an error: \(failure.errorMessage)")
            } else if let success = try? JSONDecoder().decode(ImgflipSuccess.self, from: imageData) {
                chatResponse.resolved(response: success.data.url)
            } else {
                // Log an unknown error with the data.
                chatResponse.resolved(response: "Couldn't talk to imgflip for some reason :(")
            }
        }.resume()

    return chatResponse
}

private extension ChatBot {
    func listenFor(memeTemplate: MemeTemplate) {
        self.listen(for: memeTemplate.regexp, respondingLater: { (matches, message) in
            let allMatches = matches[0].ranges(inString: message).map { String($0) }

            return urlForTemplate(templateID: memeTemplate.templateID,
                                  matches: allMatches)
        }, help: memeTemplate.help)
    }
}

func addImgflip(toBot bot: inout ChatBot) throws {
    var knownTemplates = bot.brain["imgflipMemeTemplates"] as? [MemeTemplate] ?? memeTemplates

    // Listen for known templates.
    knownTemplates.forEach { bot.listenFor(memeTemplate: $0) }

    // Listen for new templates.
    try bot.listen(forPattern: "meme add (.*) with id ([0-9]+)", responding: { (matches, message) in
        let memeRegexp =
            matches[0]
                .range(inString: message, at: 1)
                .map { String($0) }
                .flatMap { try? NSRegularExpression(pattern: $0) }
        let memeTemplateID = matches[0].range(inString: message, at: 2).flatMap { Int($0) }

        guard let regexp = memeRegexp, let templateID = memeTemplateID else {
                return "Failed to extract pattern and id from \(message)."
        }

        let template = MemeTemplate(regexp: regexp,
                                    help: String(describing: regexp),
                                    templateID: templateID)

        wrappedThrow {
            bot.listenFor(memeTemplate: template)
            knownTemplates.append(template)
            bot.brain["imgflipMemeTemplates"] = knownTemplates
        }

        return "Meme pattern \(regexp) registered for template https://imgur.com/gallery/\(templateID) ."
    }, help: "meme add <regex> with id <imgflip template id>")
}
