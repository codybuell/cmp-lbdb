local utils = {}

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

utils.parse_meta = function(meta_raw)
  local date = meta_raw:match('%d+-%d+-%d+ %d+:%d+')
  if date then
    return 'Last seen: ' .. meta_raw
  else
    return 'Sourced from: ' .. meta_raw
  end
end

utils.split = function(s, sep)
  local fields = {}

  local lsep = sep or " "
  local pattern = string.format("([^%s]+)", lsep)
  string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

  return fields
end

utils.get_contacts = function(blacklist)
  -- init some variables
  local contacts_email = {}
  local contacts_name  = {}
  local first = true

  -- query lbdbq and loop through lines
  -- TODO: This is blocking and runs at startup. See if it can run async.
  local lbdbq = io.popen("lbdbq . 2>/dev/null")
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
    local mstring = "'" .. name .. "' <" .. email .. ">"

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
  local line = vim.api.nvim_get_current_line()
  for _, header in pairs({ 'Bcc:', 'Cc:', 'From:', 'Reply-To:', 'To:' }) do
    if vim.startswith(line, header) then
      return true
    end
  end
  return false
end

utils.table_concatenate = function(t1, t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

return utils
