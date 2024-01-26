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
  filetypes = { 'mail', 'markdown' }
}

--------------------
--  source funcs  --
--------------------

source.new = function()
  local self = setmetatable({}, { __index = source })
  -- self.your_awesome_variable = 1
  return self
end

function source.get_debug_name()
    return 'lbdb'
end

function source._validate_option(_, params)
  local opts = vim.tbl_deep_extend('keep', { filetypes = params.filetypes }, defaults)
  vim.validate({
    filetypes = { opts.filetypes, 'table' },
  })
  return opts
end

function source.complete(self, params, callback)
  local opts = self:_validate_option(params)
  if utils.has_value(opts.filetypes, vim.bo.filetype) then
    if not cmp_contacts then
      cmp_contacts, full_set = utils.build_tables()
    end
    if utils.in_header() then
      callback({
        items = cmp_contacts
      })
    else
      callback({
        items = full_set
      })
    end
  end
end

return source
