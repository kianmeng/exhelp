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

### Fetching documentation

```
# Fetch documentation for a module
exh GenServer

# Fetch documentation for a module and function
exh String.contains?

# Fetch documentation for a module, function, and arity
exh Enum.map/2
```

## Thanks

Inspired by [exdoc_cli](https://github.com/silbermm/exdoc_cli).
