# PowerLevel.nvim

# NOT FUNCTIONAL YET

A Neovim plugin for Markdown todo lists in which you may go super saiyan.

## Installation

### Using `packer.nvim`:
```lua
use {
    'NeoManslayer/powerlevel.nvim',
    config = function()
        require("powerlevel").setup({
            option1 = true,
            option2 = "custom value",
        })
    end
}

### Using vim-plug

Plug 'NeoManslayer/powerlevel.nvim'

### Using lazy

{ 'NeoManslayer/powerlevel.nvim' }
