# Exhelp

Use Elixir's IEx helpers from the command line.

## Installation

Use `mix`:

```
mix escript.install github rowlandcodes/exhelp
```

If you use `asdf` as a version manager, make sure to run:

```
asdf reshim
```

## Features

* Fetch documentation for module or function
* Open module or function in an editor
* Fetch types defined in a module
* Fetch behaviors defined in a module
* List exported functions and macros from a module
* Search for modules or functions
* Mix integration: Use Exhelp with projects and dependencies

## Usage

### Fetch documentation

Without a flag, `exh` display documentation for a query.
This mimics `IEx.Helpers.h/1`.

```
# Fetch documentation for a module
exh GenServer

# Fetch documentation for a module and function
exh String.contains?

# Fetch documentation for a module, function, and arity
exh Enum.map/2

# Fetch documentation and pipe into pager
exh :lists.map/2 | less -R
```

**Note**: Exhelp will work with Erlang modules and functions,
but you will need to have Erlang documentation installed.

### Open source code in an editor

The flag `-o` or `--open` will open your query in editor.
This mimics `IEx.Helpers.open/1`.

```
# Open a module
iex Enum -o

# Open a module at a function defintion
iex :lists.map --open

# Open a module at a specific function arity
iex Stream.map/2 -o

# Works with Kernel functions too
iex is_function -o
```

**Note**: Open works by using the `ELIXIR_EDITOR` environmental variable,
falling back to `EDITOR`. But if you use a terminal editor, 
Elixir doesn't want to hand over control of the tty,
so you'll need to set `ELIXIR_EDITOR` to open in a new terminal:

```
# For the terminal editor kakoune and terminal xterm
# __LINE__ and __FILE__ are replaced with the appropriate value by exh
# Set them appropriately for your editor to understand them
export ELIXIR_EDITOR="xterm -e kak +__LINE__ __FILE__"

# Now it should work
exh -o Enum.map/2
```

### Display types from a module

The flag `-t` or `--type` will list the types that were defined in a module.
This mimics `IEx.Helpers.t/1`.

```
# -t only works with a Module as the query
exh -t Enum

# It also works with Erlang modules
exh :erlang --type
```

### Display behaviors from a module

The flag `-b` or `--behavior` will list the behaviors that were defined in a module.
This mimics `IEx.Helpers.b/1`.

```
# -b only works with a Module as the query
exh -b GenServer

# It also works with Erlang modules
exh -b :gen_server
```

## Thanks

Inspired by [exdoc_cli](https://github.com/silbermm/exdoc_cli).
