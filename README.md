# nvim-fundo

The goal of nvim-fundo is to make Neovim's undo file become stable and useful.

<https://user-images.githubusercontent.com/17562139/202656014-85bc84ca-30b1-4093-9546-a06f17effc73.mp4>

> WIP. If you like this plugin, star it to let me speed up to end WIP state.

## Features

- Restore undo history even if the file's content has been changed outside Neovim

### TODO Features

- Limit the count and size for archives
- Restore undo history even if the file has been moved
- Support useful use cases for undo file

## Quickstart

### Requirements

- [Neovim](https://github.com/neovim/neovim) 0.7.2 or later

### Installation

Install with [Packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    'kevinhwang91/nvim-fundo', requires = 'kevinhwang91/promise-async',
     run = function() require('fundo').install() end
}
```

### Minimal configuration

```lua
use {
    'kevinhwang91/nvim-fundo', requires = 'kevinhwang91/promise-async',
     run = function() require('fundo').install() end
}

vim.o.undofile = true
require('fundo').setup()
```

### Usage

Use undo file as usual.

## Documentation

### How does nvim-undo keep the undo history?

Fundo will keep the latest files as archives, in other words, it takes additional space in your
disk. If the `BufReadPost` event is fired, it will validate the undo file and restore it if
necessary.

### Setup and description

```lua
{
    archives_dir = {
        description = [[The directory to store the archives]],
        default = vim.fn.stdpath('cache') .. path.separator .. 'fundo'
    }
}
```

`:h fundo` may help you to get the all default configuration.

### API

[fundo.lua](./lua/fundo.lua)

## Run tests

`make test`

## Feedback

- If you get an issue or come up with an awesome idea, don't hesitate to open an issue in github.
- If you think this plugin is useful or cool, consider rewarding it a star.

## License

The project is licensed under a BSD-3-clause license. See [LICENSE](./LICENSE) file for details.
