//
//  GordiasChat is the chat module of the Gordias operations framework.
//

import Foundation

/**
 * ChatBot specifies the protocol that providers of bot functionality
 * are expected to conform to in order to integrate with the rest of
 * the Gordias system.
 *
 * ChatBots have a name they should respond to, typically taken in via
 * an initializer and accessible as the `name` property, and they are
 * started synchronously by calling `listen()`.
 *
 * Bots should be set to respond to particular messages by creating a
 * `ChatMessageProcessor` and asking the `ChatBot` to watch for it by
 * calling the `listen(for:id:)` method. If a non-nil id is specified,
 * the processor can be uninstalled by calling `unlisten(id:)` with
 * the id that was originally passed.
 *
 * Lastly, the `process(message:)` method is exposed though it is also
 * meant for internal use: all message reception should pass through
 * this method, and it can be used to trigger a message reception from
 * an external caller as well.
 */
public protocol ChatBot {
    var name: String { get }
    var processors: [ChatMessageProcessor] { get }

    /**
     * Starts synchronously listening to the bot's underlying chat transport.
     * The call should block until either the source becomes unavailable or the
     * bot itself disconnects for a normal or abnormal reason.
     */
    func listen()
    /**
     * Processes a single received message. Exposed publicly so that it
     * can be accessed programmatically if needed. Should be used internally
     * for processing messages as well for conformance.
     */
    func process(message: String)

    // MARK: Message processor management
    /**
     * Registers a `ChatMessageProcessor` that will be checked against
     * incoming messages. The processor should choose to provide a response
     * for any given message or not based on internal logic.
     *
     * The optional `id` can be used to later remove the processor using
     * the `unlisten(id:)` method.
     *
     * If called while a message is being processed, this method should
     * succeed, but it is undefined if the current message's processing
     * should include the new processor or not.
     */
    func listen(for: ChatMessageProcessor, id: String?)
    /**
     * Given an `id` that was previously passed to `listen(for:id:)`, removes
     * the listener added with that id so that it will no longer process
     * future messages.
     *
     * If called while a message is being processed, this method should
     * succeed, but it is undefined if the current message's processing
     * should include the processor with the given `id` or not.
     */
    func unlisten(id: String) -> Bool
}

/// ChatMessageProcessor is the base protocol for any component that wishes to
/// decide whether it should provide a chat response for any given message
/// received by the system.
///
/// ChatMessageProcessors have one method, `response(for:)`, which receives the
/// chat message as a `String` and optionally returns a `ChatResponse` if the
/// processor chooses to respond to the message in question.
///
/// ChatMessageProcessors also have one read-only property, a `help` string.
///
/// Conforming to this protocol qualifies a type to be added to a `ReplBot` as a
/// listener using `listen(for:id:)`.
public protocol ChatMessageProcessor {
    var help: String { get }

    func response(for _message: String) -> ChatResponse?
}

/// ChatMatcher is the base protocol for any component that decides whether a
/// chat message is matched. It is typically used alongside a
/// `ChatMessageProcessor`, whose associated matcher determines whether the
/// processor should be consulted for a response.
public protocol ChatMatcher {
    associatedtype MatchType

    func matches(message: String) -> [MatchType]
}

/// ChatResponse is the base protocol for responses in a chat. A ChatResponse
/// simply needs to be able to represent itself as a `message()` `String`.
public protocol ChatResponse {
    func message() -> String
}
