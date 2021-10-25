local utils  = require'cmp_lbdb.utils'
local config = require'cmp.config'

-- define a reasonable default blacklist
local default_blacklist = {
  '.*not?.?reply.*'             -- variations of noreply, no-reply do-not-reply...
}

-- grab user defined blacklist
local c = config.get_source_config('lbdb')

-- fail gracefully if plugin is sourced but not configured as a source in users cmp.setup
if c ~= nil then
  user_bl = utils.get_paths(c, {'blacklist'})
end

-- return user blacklist if set, else default
if user_bl ~= nil then
  return user_bl
else
  return default_blacklist
end
