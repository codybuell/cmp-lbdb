cmp-lbdb
========

lbdb completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). Names, emails, and email header recipient formatted completions are provided for contacts found in lbdb.

![screenshot](images/screenshot.png)

Installation
------------

Use your favorite plugin manager:

- [vim-plug](https://github.com/junegunn/vim-plug)

  ```vim
  Plug 'codybuell/cmp-lbdb'
  ```
- [pathogen](https://github.com/tpope/vim-pathogen)

  ```bash
  git clone https://github.com/codybuell/cmp-lbdb.git ~/.config/nvim/bundle/cmp-lbdb
  ```
- native package manager

  ```bash
  git clone https://github.com/codybuell/cmp-lbdb.git ~/.config/nvim/pack/bundle/opt/cmp-lbdb
  ```
  ```vim
  packadd! cmp-lbdb
  ```

Usage
-----

```lua
-- setup with defaults (markdown and mail file types)
require('cmp').setup({
  -- snip...
  sources = {
    -- snip...
    { name = lbdb },
    -- snip...
  }
})

-- or alternatively, enable with overrides
require('cmp').setup({
  -- snip...
  sources = {
    -- snip...
    {
      name = 'lbdb',
      option = {
        filetypes = {
          'mail',
          'markdown',
          'gitcommit'
        },
        blacklist = {
          'user@host.com',
          '.*noreply.*',
        },
        mail_header_only = true,
        use_quotes = false,
      },
    },
    -- snip...
  }
})
```

Options
-------

### filetypes (type: table)

_Default:_ `{ 'mail', 'markdown' }`

Sets what filetypes the completion source will be made available.

### blacklist (type: table)

_Default:_ `{ '.*not?.?reply.*' }`

The blacklist sets what emails to exclude from the completion list. The default value will catch variations of `noreply`, `no-reply`, `do-not-reply`, and so on. [Lua pattern matching](https://www.lua.org/pil/20.2.html) can be used.

### mail_header_only (type: boolean)

_Default:_ `false`

If set to `true` completions will only be provided when in the email header (any line stating with To:, From:, Cc:, etc) of a buffer of `mail` filetype. All other enabled filetypes will source completions as normal.

### use_quotes (type: boolean)

_Default:_ `true`

If set to `true`, will surround the name with double quotes such that elements are generated as `"FirstName LastName" <email>`. If set to false, it will not include quotes such that elements are generated as `FirstName LastName <email>`. Please see the [RFC 5322](https://tools.ietf.org/html/rfc5322) standard for mail header specifications. 
