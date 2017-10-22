--------------------------------------------------------------------------------
-- run.lua: list import()-compliant exports
-- This file is a part of le-tools library
-- Copyright (c) le-tools authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local pairs = pairs

local arguments,
      optional_arguments,
      method_arguments,
      eat_true
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments',
        'method_arguments',
        'eat_true'
      }

local is_table,
      is_number
      = import 'lua-nucleo/type.lua'
      {
        'is_table',
        'is_number'
      }

local escape_lua_pattern
      = import 'lua-nucleo/string.lua'
      {
        'escape_lua_pattern'
      }

local starts_with
      = import 'lua-nucleo/string.lua'
      {
        'starts_with'
      }

local empty_table,
      timap,
      tkeys,
      tclone
      = import 'lua-nucleo/table.lua'
      {
        'empty_table',
        'timap',
        'tkeys',
        'tclone'
      }

local tpretty,
      tpretty_ordered
      = import 'lua-nucleo/tpretty.lua'
      {
        'tpretty',
        'tpretty_ordered'
      }

local find_all_files,
      does_file_exist,
      get_filename_from_path,
      join_path
      = import 'lua-aplicado/filesystem.lua'
      {
        'find_all_files',
        'does_file_exist',
        'get_filename_from_path',
        'join_path'
      }

local make_loggers
      = import 'lua-aplicado/log.lua'
      {
        'make_loggers'
      }

local load_tools_cli_data_schema,
      load_tools_cli_config,
      print_tools_cli_config_usage,
      freeform_table_value
      = import 'lua-aplicado/dsl/tools_cli_config.lua'
      {
        'load_tools_cli_data_schema',
        'load_tools_cli_config',
        'print_tools_cli_config_usage',
        'freeform_table_value'
      }

local create_config_schema
      = import 'list-exports/project-config/schema.lua'
      {
        'create_config_schema'
      }

local validate_format
      = import 'lua-aplicado/dsl/config_dsl.lua'
      {
        'validate_format'
      }

--------------------------------------------------------------------------------

local log, dbg, spam, log_error = make_loggers("list-exports", "LEX")

--------------------------------------------------------------------------------

local Q = function(v) return ("%q"):format(tostring(v)) end

--------------------------------------------------------------------------------

local guess_module_name = function(lib_name)
  local module_name = join_path(lib_name, "code/exports.lua")
  module_name =  module_name:gsub("%.lua$", "")
    :gsub("/", ".")
    :gsub("\\", ".")
  return module_name
end

local list = function(
    sources_dir,
    root_dir_only,
    profile_filename,
    out_filename,
    lib_name,
    file_header,
    module_name,
    alias_symbol_weight,
    default_symbol_weight
  )

  alias_symbol_weight = alias_symbol_weight or (-1 / 0)
  default_symbol_weight = default_symbol_weight or 0

  arguments(
      "number", alias_symbol_weight,
      "number", default_symbol_weight
    )

  -- Remove trailing slashes
  sources_dir = sources_dir:gsub("/+$", "")
  root_dir_only = root_dir_only and root_dir_only:gsub("/+$", "")
  file_header = file_header
    or [[
-- This file is a part of ]], (lib_name or root_dir_only or sources_dir), [[ library
-- See file `COPYRIGHT` for the license and copyright information
]]
  log(
      "listing all exports in ", sources_dir .. "/",
      "using profile", profile_filename,
      "dumping to", out_filename
    )

  if root_dir_only then
    log("only in root directory", root_dir_only) -- TODO: bad name
  end

  local PROFILE = import(profile_filename) ()

  local export_map = setmetatable(
      -- TODO: Check format of PROFILE.raw
      PROFILE.raw and tclone(PROFILE.raw) or { },
      {
        __index = function(t, k)
          local v = { }
          t[k] = v
          return v
        end;
      }
    )

  local PK_META_FORMAT = function()
    cfg:root
    {
      cfg:optional_string "alias_of_module";
      cfg:optional_number "default_export_weight";
      cfg:optional_dictionary "export_weights"
      {
        key = cfg:string();
        value = cfg:number();
      };
    }
  end

  local files
  local dir = root_dir_only and (sources_dir .. "/" .. root_dir_only) or sources_dir
  if not does_file_exist(dir) then
    -- TODO: Shouldn't we crash here?
    --              sources_dir is cfg:path, not cfg:existing_path though
    log("warning: sources dir does not exist", dir)
    files = { }
  else
    files = find_all_files(
        root_dir_only and (sources_dir .. "/" .. root_dir_only) or sources_dir,
        "%.lua$"
      )

    table.sort(files)
  end

  for i = 1, #files do
    local filename = files[i]
    local listed_filename = filename

    if root_dir_only then
      listed_filename = filename:gsub(
          escape_lua_pattern(sources_dir) .. "/",
          ""
        )
    end

    if PROFILE.skip[listed_filename] then
      log("skipping file", listed_filename)
    else
      log("loading exports from file", filename)
      if root_dir_only then
        log("file would be mentioned as", listed_filename)
      end

      local exports = import (filename) ()

      local pk_meta = exports.PK_META
      if pk_meta ~= nil then
        assert(
            validate_format(
                PK_META_FORMAT,
                pk_meta
              )
          )
      end

      for name, _ in pairs(exports) do
        if name ~= "PK_META" then
          local map = export_map[name]
          local weight
                = pk_meta and
                (
                  (pk_meta.export_weights and pk_meta.export_weights[name]) or
                  pk_meta.default_export_weight or
                  (pk_meta.alias_of_module and alias_symbol_weight)
                ) or default_symbol_weight

          map[#map + 1] =
          {
            listed_filename;
            w = weight;
          }
        end
      end
    end
  end

  local sorted_map = { }
  for export, filenames in pairs(export_map) do
    if #filenames > 1 then
      log("found duplicates for", export, "in", filenames)
    end

    sorted_map[#sorted_map + 1] =
    {
      export = export;
      filenames = filenames;
    }
  end

  table.sort(
      sorted_map,
      function(lhs, rhs)
        return tostring(lhs.export) < tostring(rhs.export)
      end
    )

  local exports = { }
  for i = 1, #sorted_map do
    exports[sorted_map[i].export] = sorted_map[i].filenames
  end

  do
    local file = assert(io.open(out_filename, "w"))

    file:write([[
--------------------------------------------------------------------------------
--- Generated exports map for ]], (root_dir_only or sources_dir), "/", [[

-- @module ]], module_name, [[

]] .. file_header .. [[
--------------------------------------------------------------------------------
-- WARNING! Do not change manually!
--          Generated by list-exports.
--------------------------------------------------------------------------------

return
]] .. tpretty_ordered(exports) .. [[

]])

    file:close()
    file = nil
  end

  log("OK")
end

--------------------------------------------------------------------------------

local SCHEMA = create_config_schema()

local EXTRA_HELP, CONFIG, ARGS

--------------------------------------------------------------------------------

local ACTIONS = { }

ACTIONS.help = function()
  print_tools_cli_config_usage(EXTRA_HELP, SCHEMA)
end

ACTIONS.check_config = function()
  io.stdout:write("config OK\n")
  io.stdout:flush()
end

ACTIONS.dump_config = function()
  io.stdout:write(tpretty(freeform_table_value(CONFIG), " ", 80), "\n")
  io.stdout:flush()
end

ACTIONS.list_all = function()
  local exports = CONFIG.common.exports

  local freeform_exports = freeform_table_value(exports)
  local alias_symbol_weight = freeform_exports.ALIAS_SYMBOL_WEIGHT or nil
  local default_symbol_weight = freeform_exports.DEFAULT_SYMBOL_WEIGHT or nil

  local sources = freeform_table_value(exports.sources) -- Hack. Use iterator
  for i = 1, #sources do
    local source = sources[i]
    local lib_name = source.lib_name
    local module_name = source.module_name or guess_module_name(
        lib_name,
        source.out_filename
      )

    list(
        source.sources_dir,
        source.root_dir_only, -- May be nil
        join_path(exports.profiles_dir, source.profile_filename),
        join_path(exports.exports_dir, source.out_filename),
        lib_name, -- May be nil
        source.file_header, -- May be nil
        module_name,
        alias_symbol_weight,
        default_symbol_weight
      )
  end
end

--------------------------------------------------------------------------------

EXTRA_HELP = [[

Usage:

  ]] .. arg[0] .. [[ --root=<PROJECT_PATH> <action> [options]

Actions:

  * ]] .. table.concat(tkeys(ACTIONS), "\n  * ") .. [[

]]

--------------------------------------------------------------------------------

local run = function(...)
  CONFIG, ARGS = assert(load_tools_cli_config(
      function(args)
        return
        {
          PROJECT_PATH = args["--root"];
          list_exports = { action = { name = args[1] or args["--action"]; }; };
        }
      end,
      EXTRA_HELP,
      SCHEMA,
      nil,
      nil,
      ...
    ))
  ACTIONS[CONFIG.list_exports.action.name]()
end

--------------------------------------------------------------------------------

return
{
  run = run;
}
