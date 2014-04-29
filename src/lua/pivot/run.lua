--------------------------------------------------------------------------------
-- run.lua: tool for making pivot tables from tab-separated data
-- This file is a part of le-tools library
-- Copyright (c) le-tools authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

require "lua-nucleo"

local create_pivot_processor
      = import "le-tools/pivot/pivot.lua"
      {
        "create_pivot_processor"
      }

local format
      = import "le-tools/pivot/format.lua"
      {
        "format"
      }

--------------------------------------------------------------------------------

local run = function(fmt, ...)
  -- make pivot table
  local pivot = create_pivot_processor({...})()
  -- output with respect to format
  io.write(format(pivot, fmt), "\n")
end

--------------------------------------------------------------------------------

return
{
  run = run;
}
