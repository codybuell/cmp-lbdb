local source = {}
local utils = require'cmp_lbdb.utils'

------------------
--  query lbdb  --
------------------

local cmp_contacts = nil
local full_set     = nil

----------------
--  defaults  --
----------------

local defaults = {
  filetypes = { 'mail', 'markdown' },
  mail_header_only = false,
  use_quotes = true,
}

--------------------
--  source funcs  --
--------------------

source.new = function()
  local self = setmetatable({}, { __index = source })
  return self
end

function source.get_debug_name()
    return 'lbdb'
end

function source._validate_option(_, params)
  local opts = vim.tbl_deep_extend('keep', params.option, defaults)
  vim.validate({
    filetypes = { opts.filetypes, 'table' },
    mail_header_only = { opts.mail_header_only, 'boolean' },
    use_quotes = {opts.use_quotes, 'boolean'},
  })
  return opts
end

function source.complete(self, params, callback)
  local opts = self:_validate_option(params)
  if utils.has_value(opts.filetypes, vim.bo.filetype) then
    if not cmp_contacts then
      cmp_contacts, full_set = utils.build_tables(opts)
    end
    if utils.in_header() then
      callback({
        items = cmp_contacts
      })
    else
      if not (vim.bo.filetype == 'mail' and opts.mail_header_only) then
        callback({
          items = full_set
        })
      end
    end
  end
end

return source
