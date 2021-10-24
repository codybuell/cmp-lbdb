local source = {}
local utils = require'cmp_lbdb.utils'
local blacklist = require'cmp_lbdb.blacklist'

------------------
--  query lbdb  --
------------------

local lbdb_email, lbdb_name = utils.get_contacts(blacklist)
local compe_names    = utils.build_cmp_table(lbdb_name, 'name')
local compe_emails   = utils.build_cmp_table(lbdb_email, 'email')
local compe_contacts = utils.build_cmp_table(lbdb_email, 'mstring')
local full_set       = utils.table_concatenate(compe_names, compe_emails)

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
  if utils.in_header() then
    callback({
      items = compe_contacts
    })
  else
    callback({
      items = full_set
    })
  end
end

return source
