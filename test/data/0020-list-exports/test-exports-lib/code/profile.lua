--------------------------------------------------------------------------------
-- profile.lua: exports profile for list-exports test
-- This file is a part of le-tools library
-- Copyright (c) le-tools authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local tset = import 'lua-nucleo/table-utils.lua' { 'tset' }

--------------------------------------------------------------------------------

local PROFILE = { }

--------------------------------------------------------------------------------

PROFILE.skip = setmetatable(tset
{
}, {
  __index = function(t, k)
    local v = (not k:match("^%./"))
                or k:match("^%./code/")

    t[k] = v
    return v
  end;
})

--------------------------------------------------------------------------------

return PROFILE
