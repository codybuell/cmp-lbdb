local utils = {}

utils.get_blacklist = function()
  -- define a reasonable default blacklist
  local default_blacklist = {
    '.*not?.?reply.*'             -- variations of noreply, no-reply do-not-reply...
  }

  -- grab user defined blacklist
  local c = require'cmp.config'.get_source_config('lbdb')
  local user_bl

  -- fail gracefully if plugin is sourced but not configured as a source in users cmp.setup
  if c ~= nil then
    user_bl = utils.get_paths(c, {'option', 'blacklist'})
    if user_bl == nil then
      user_bl = utils.get_paths(c, {'blacklist'})
    end
  end


  -- return user blacklist if set, else default
  if user_bl ~= nil then
    return user_bl
  else
    return default_blacklist
  end
end

utils.get_paths = function(root, paths)
  local c = root
  for _, path in ipairs(paths) do
    c = c[path]
    if not c then
      return nil
    end
  end
  return c
end

utils.has_value = function(table, value)
  for _, val in ipairs(table) do
    if val == value then
      return true
    end
  end

  return false
end

utils.parse_meta = function(meta_raw)
  if meta_raw then
    local date = meta_raw:match('%d+-%d+-%d+ %d+:%d+')
    if date then
      return 'Last seen: ' .. meta_raw
    else
      return 'Sourced from: ' .. meta_raw
    end
  end
end

utils.split = function(s, sep)
  local fields = {}

  local lsep = sep or " "
  local pattern = string.format("([^%s]+)", lsep)
  local _ = string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

  return fields
end

utils.get_contacts = function(blacklist, use_quotes)
  -- init some variables
  local contacts_email = {}
  local contacts_name  = {}
  local first = true

  -- query lbdbq and loop through lines
  local lbdbq = io.popen("lbdbq . 2>/dev/null")
  if lbdbq then
    for contact in lbdbq:lines() do
      -- skip the header
      if first then
        first = false
        goto continue
      end

      -- split lbdbq line output by tab
      local fields = utils.split(contact, '\t')

      -- lowercase email to handle duplicates
      local email   = string.lower(fields[1])
      local name    = fields[2]
      local mstring
      if use_quotes then
        mstring = '"'.. name .. '" <' .. email .. '>'
      else
        mstring =  name .. " <" .. email .. ">"
      end

      -- check if email is in our blacklist
      for _,val in ipairs(blacklist) do
        if email:match(val) then
          goto continue
        end
      end

      -- append to table indexed by email to handle duplicates
      contacts_email[email] = {
        email = email;
        name  = name;
        meta  = utils.parse_meta(fields[3]);
        mstring = mstring;
      }

      -- append to table indexed by name to handle duplicates
      contacts_name[name] = {
        email = email;
        name  = name;
        meta  = utils.parse_meta(fields[3]);
        mstring = mstring;
      }

      ::continue::
    end

    -- close lbdbq call
    lbdbq:close()
  end

  return contacts_email, contacts_name
end

utils.build_cmp_table = function(source, completion)
  local cmp_table = {}
  for _,v in pairs(source) do
    table.insert(cmp_table, {
      label = v[completion],       -- what to spit out on completion
      detail = v['meta'],          -- side popout to show additional info no selected item
      -- kind = cmp.lsp.CompletionItemKind.Snippet,
    })
  end
  return cmp_table
end

utils.in_header = function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line_num   = cursor_pos[1]
  local lines      = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local header_line_num = nil

  for i, line in ipairs(lines) do
    if line:match('^%s*$') == nil and
       not vim.startswith(line, 'Bcc:') and
       not vim.startswith(line, 'Cc:') and
       not vim.startswith(line, 'From:') and
       not vim.startswith(line, 'Reply-To:') and
       not vim.startswith(line, 'To:') then
      header_line_num = i
      break
    end
  end

  if header_line_num and line_num >= header_line_num then
    return false
  else
    return true
  end
end

utils.table_concatenate = function(t1, t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

utils.build_tables = function(opts)
    local lbdb_email, lbdb_name = utils.get_contacts(utils.get_blacklist(), opts.use_quotes)
    local cmp_names    = utils.build_cmp_table(lbdb_name, 'name')
    local cmp_emails   = utils.build_cmp_table(lbdb_email, 'email')
    local cmp_contacts = utils.build_cmp_table(lbdb_email, 'mstring')
    local full_set     = utils.table_concatenate(cmp_names, cmp_emails)
    return cmp_contacts, full_set
end

return utils
