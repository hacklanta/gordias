//
//  GordiasChat is the chat module of the Gordias operations framework.
//

import Foundation

public protocol ChatMatcher {
    func doesMatch(message: String) -> Bool
}

public protocol ChatMessageProcessor {
    func response(for _message: String) -> ChatResponse?
}

public protocol ChatResponse {
    func message() -> String
}

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
