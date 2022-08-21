# Exhelp

Use Elixir's IEx helpers from the command line.

## Installation

Use `mix`:

```sh
mix escript.install github rowlandcodes/exhelp tag v0.3.0
```

If you use `asdf` as a version manager, make sure to run:

```sh
asdf reshim
```

## Features

- Fetch documentation for a module or function
- Open a module or function in an editor
- Fetch types defined in a module
- Fetch behaviours defined in a module
- List exported functions and macros from a module
- Search for modules or functions
- Mix integration: Use Exhelp with projects and dependencies

## Usage

```sh
Usage:
  exh QUERY [OPTIONS]

Examples:
  exh Enum.map/2
  exh String -o
  exh Ecto -S mix --exports

Options:
  QUERY                  Module, function, and/or arity
  -o, --open             Open QUERY in an editor
  -t, --type             Displays the types defined in queried Module
  -b, --behaviour        Displays the behaviours defined in queried Module
  -s, --search           Searches for QUERY in loaded modules and exports
      --all-modules      Used with --search instead of a query.
                         Lists all modules used by loaded applications.
                         Exclusive with QUERY or --all-functions
      --all-functions    Used with --search instead of a query.
                         Lists all functions exported by modules in loaded
                         applications.
                         Exclusive with QUERY or --all-modules
      --exports          Displays the exports from queried Module
      --version          Print Exhelp version
  -S mix                 Enables mix integration allowing exh to work on
                         project and dependency queries.
```

### Fetch documentation

Without a flag, `exh` display documentation for a query.
This mimics `IEx.Helpers.h/1`.

```sh
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

```sh
# Open a module
iex Enum -o

# Open a module at a function definition
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

```sh
# For the terminal editor kakoune and terminal xterm
# __LINE__ and __FILE__ are replaced with the appropriate value by exh
# Set them appropriately for your editor to understand them
export ELIXIR_EDITOR="xterm -e kak +__LINE__ __FILE__"

# Now it should work
exh -o Enum.map/2
```

### Display types defined in a module

The flag `-t` or `--type` will list the types that were defined in a module.
This mimics `IEx.Helpers.t/1`.

```sh
# -t only works with a Module as the query
exh -t Enum

# It also works with Erlang modules
exh :erlang --type
```

### Display behaviours defined in a module

The flag `-b` or `--behaviour` will list the behaviours that were defined in a module.
This mimics `IEx.Helpers.b/1`.

```sh
# -b only works with a Module as the query
exh -b GenServer

# It also works with Erlang modules
exh -b :gen_server
```

### List function and macro exports from a module

The flag `--exports` will list all public functions and macros exported by a module.
This mimics `IEx.Helpers.exports/1`.

```sh
# --exports only works with a Module as the query
exh --exports Enum
```

### Search for modules or functions

The flag `-s` or `--search` allows you to search for modules or functions.
It will list all Modules or functions that begin with your query.

```sh
# Search for modules that start with Enu
exh -s Enu

# Search for functions in Enum that start with ma
exh --search Enum.ma

# Search for functions in any loaded module that start with ma
exh --search ma
```

The `--search` flag also supports two special option flags,
which are used in place of a query:

- `--all-modules`: Which lists all loaded modules
- `--all-functions`: Which lists every exported function from every loaded module.

These flags are designed to be used with other unix tools:

```sh
# Enable fine-grained search with grep
exh -s --all-modules | grep Enum

# Are there any arity 9 functions?
exh -s --all-functions | grep 9$
```

### Mix Integration

All of the previous modes can be combined with the special flag `-S mix`,
which will enable Exhelp to access project files and dependencies in a mix project.
Mix integration will only work if there is an `mix.exs` file in the current directory.

Calling `exh` with Mix will compile your project.

```sh
# Read dependency documentation
exh Witchcraft -S mix | less -R

# Open a downloaded library module
exh -S mix --open Phoenix.Router

# List types from a library module
exh -S mix --type Phoenix.HTML

# List behaviours from a library module
exh -S mix --behaviour Plug

# Print exports from a project module
exh -S mix --exports Tco

# Search for modules included in a dependency
exh -S mix --search Zig
```

If you set `EXHELP_ENABLE_MIX=true`, Exhelp will automatically connect to Mix
when it detects a `mix.exs` in the directory.

## Configuration

Exhelp uses IEx's `.iex.exs` file for configuration.
Global settings can be set using `IEx.configure/1` in `~/.iex.exs`,
This is overridden if there is a local `.iex.exs` file in the project directory.

If you would like to ignore `.iex.exs` configuration and use default colors,
set `EXHELP_ENABLE_DOT_IEX=false`.

```sh
# Further reading: IEx's section on .iex.exs
exh IEx

# And
exh IEx.configure/1
```

## Thanks

Inspired by [exdoc_cli](https://github.com/silbermm/exdoc_cli).
