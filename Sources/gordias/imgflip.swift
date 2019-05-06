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

func addImgflip(toBot bot: ChatBot) {
    memeTemplates.forEach { (template) in
        bot.listen(for: template.pattern, respondingLater: { (matches, message) in
            do {
                return try urlForTemplate(templateID: template.templateID,
                                          matches: matches[0].mapRange(in: message) { String($0) })
            } catch {
                return nil
            }
        }, help: String(describing: template.pattern))
    }
}
