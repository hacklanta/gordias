# Gordias

Gordias is an operations framework: a set of tools for running a company. It is
meant to integrate platform-agnostic chat, financing, and other tooling into a
complete system for managing teams.

## Running

You can run:

```
$ swift run
```

In the root directory to use default settings and parameters. This will get you a REPL prompt
with the bot's default name.

To interact with the command-line parameters, you can explicitly refer to the `gordias`
executable. Most basically:

```
$ swift run gordias --help
OVERVIEW: run modules in the gordias operations system

USAGE: gordias <options>

OPTIONS:
--adapter, -a   Specify the adapter to use; defaults to repl
--help          Display available options
```

## Building

You can build with Swift Package Manager's built-in build system:

```
$ swift build
```

This will eventually output a line indicating where the executable was dropped:

```
[2/2] Linking ./.build/x86_64-apple-macosx/debug/gordias
```

You can also build a release version:

```
$ swift build -c release
```
