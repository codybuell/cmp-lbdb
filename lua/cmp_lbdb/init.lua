local source = {}
local utils = require'cmp_lbdb.utils'

------------------
--  query lbdb  --
------------------

local cmp_contacts = nil
local full_set     = nil

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

function source.is_available()
    return vim.bo.filetype == 'mail' or vim.bo.filetype == 'markdown'
end

function source.complete(_, _, callback)
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

return source
