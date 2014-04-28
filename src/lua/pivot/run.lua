#!/usr/bin/env le-lua-interpreter

--------------------------------------------------------------------------------
-- run.lua: tool for making pivot tables from tab-separated data
-- This file is a part of le-tools library
-- Copyright (c) le-tools authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

require 'lua-nucleo'

local create_pivot_processor
      = import 'le-tools/pivot/pivot.lua'
      {
        'create_pivot_processor'
      }

local tpretty
      = import 'lua-nucleo/tpretty.lua'
      {
        'tpretty'
      }

--------------------------------------------------------------------------------

local run = function(...)
  local pivot = create_pivot_processor({...})()
  io.write(tpretty(pivot), "\n")
end

--------------------------------------------------------------------------------

return
{
  run = run;
}
