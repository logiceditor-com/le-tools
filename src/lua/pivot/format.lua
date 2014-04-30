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

local to_lua = function(pivot)
  return tpretty(pivot)
end

local to_json = function(pivot)
  local cat, concat = make_concatter()
  -- NB: can't use tiwalk since it doesn't provide index
  --     to distinguish the last element
  local function serialize(elem, index)
    if index > 1 then
      cat(",")
    end
    cat("{")
    cat('"k":"', elem[1], '","v":"', elem[2], '"')
    if elem[3] then
      cat(',"c":[')
      for i = 1, #elem[3] do
        serialize(elem[3][i], i)
      end
      cat("]")
    end
    cat("}")
  end
  cat("[")
  for i = 1, #pivot do
    serialize(pivot[i], i)
  end
  cat("]")
  return concat()
end

local to_html = function(pivot)
  local cat, concat = make_concatter()
  local function serialize(elem, prefix)
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
      tiwalk(serialize, elem[3], prefix .. "\t\t")
      output("\t" .. '</ul>')
    end
    output('</li>')
  end
  cat('<ul class="tree">')
  tiwalk(serialize, pivot, "\t")
  cat('</ul>')
  return concat("\n")
end

local to_text = function(pivot)
  local cat, concat = make_concatter()
  local function serialize(elem, prefix)
    -- cache
    local key = elem[1]
    local value = elem[2]
    local children = elem[3]
    local rule = elem[4]
    -- format value
    if rule.by_percent or rule.in_percent then
      value = ("%3.4f%%"):format(value)
    end
    -- process children, if any
    if children then
      tiwalk(
          serialize,
          children,
          prefix .. key .. "\t" .. value .. "\t"
        )
    -- or output the leaf node
    else
      cat(prefix .. key .. "\t" .. value .. "\n")
    end
  end
  -- walk the table
  tiwalk(serialize, pivot, "")
  return concat()
end

local to_text_object = function(pivot)
  local cat, concat = make_concatter()
  local function serialize(elem, prefix)
    if elem.children then
      tiwalk(
          serialize,
          elem.children,
          prefix .. elem.key .. "\t" .. elem.value .. "\t"
        )
    else
      cat(prefix .. elem.key .. "\t" .. elem.value .. "\n")
    end
  end
  tiwalk(serialize, pivot, "")
  return concat()
end

local format = function(pivot, format)
  -- output pivot with respect to format
  -- Lua table
  if format == "lua" then
    return to_lua(pivot)
  -- JSON
  elseif format == "json" then
    return to_json(pivot)
  -- HTML tree
  elseif format == "html" then
    return to_html(pivot)
  -- text with node paths expansion
  else
    return to_text(pivot)
  end
end

--------------------------------------------------------------------------------

return
{
  format = format;
  to_json = to_json;
  to_html = to_html;
  to_lua = to_lua;
  to_text = to_text;
}
