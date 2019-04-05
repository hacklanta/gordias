# GordiasChat

GordiasChat is the chat component of the Gordias operations framework. It
provides functionality for integrating with team chat systems and attaching
functionality to chat interactions. It also provides an adapter that exposes
this functionality via a REPL (read-eval-print loop), allowing for interactive
testing of functionality from the terminal.

## Abstractions

GordiasChat provides three core abstractions:
- **`ChatBot`s**: These are adapters that connect to a given chat system
  and expose the functionality of the other abstractions via that system.
- **`ChatMessageProcessor`s**: These provide the ability to optionally
  respond to a message via a `ChatResponse`, and are installed on a `ChatBot`
  instance using `listen(for: ChatMessageProcessor)`.
- **`ChatResponse`s**: These are objects that can be represented as
  message strings so they can be sent to a chat system. An extension for
  `String` is provided to make these immediately function as `ChatResponse`s.

## `ReplBot`

The built-in `ReplBot` is a simple implementation of a `ChatBot` that
can be executed (by calling `listen()`) to run an interactive back-and-forth
with the bot in the terminal.
