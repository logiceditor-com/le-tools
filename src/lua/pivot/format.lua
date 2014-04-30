--------------------------------------------------------------------------------
-- format.lua: pivot table serializers
-- This file is a part of le-tools library
-- Copyright (c) le-tools authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

require "lua-nucleo"

local make_concatter
      = import "lua-nucleo/string.lua"
      {
        "make_concatter"
      }

local tiwalk
      = import "lua-nucleo/table-utils.lua"
      {
        "tiwalk"
      }

local tpretty
      = import "lua-nucleo/tpretty.lua"
      {
        "tpretty"
      }

--------------------------------------------------------------------------------

local format = function(pivot, format)
  -- output pivot with respect to format
  -- Lua table
  if format == "lua" then
    return tpretty(pivot)
  -- JSON
  elseif format == "json" then
    local cat, concat = make_concatter()
    -- NB: can't use tiwalk since it doesn't provide index
    --     to distinguish the last element
    local function to_json(elem, index)
      if index > 1 then
        cat(",")
      end
      cat("{")
      cat('"k":"', elem[1], '","v":"', elem[2], '"')
      if elem[3] then
        cat(',"c":[')
        for i = 1, #elem[3] do
          to_json(elem[3][i], i)
        end
        cat("]")
      end
      cat("}")
    end
    cat("[")
    for i = 1, #pivot do
      to_json(pivot[i], i)
    end
    cat("]")
    return concat()
  -- tree
  elseif format == "html" then
    local cat, concat = make_concatter()
    local function to_tree(elem, prefix)
      local output = function(...)
        local args = {...}
        for i = 1, #args do
          cat(prefix .. args[i])
        end
      end
      output(
          '<li class="tree">',
          "\t" .. '<span class="tree-item">' .. elem[1] .. " " .. elem[2] .. '</span>'
        )
      if elem[3] and #elem[3] > 0 then
        output("\t" .. '<ul class="tree">')
        tiwalk(to_tree, elem[3], prefix .. "\t\t")
        output("\t" .. '</ul>')
      end
      output('</li>')
    end
    cat('<ul class="tree">')
    tiwalk(to_tree, pivot, "\t")
    cat('</ul>')
    return concat("\n")
  -- text with node paths expansion
  else
    local cat, concat = make_concatter()
    local function to_text(elem, prefix)
      if elem[3] then
        tiwalk(
            to_text,
            elem[3],
            prefix .. elem[1] .. "\t" .. elem[2] .. "\t"
          )
      else
        cat(prefix .. elem[1] .. "\t" .. elem[2] .. "\n")
      end
    end
    tiwalk(to_text, pivot, "")
    return concat()
  end
end

--------------------------------------------------------------------------------

return
{
  format = format;
}
