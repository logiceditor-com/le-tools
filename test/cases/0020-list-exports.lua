--------------------------------------------------------------------------------
-- 0020-list-exports.lua: tests for list-exports
-- This file is a part of le-tools library
-- Copyright (c) le-tools authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local log, dbg, spam, log_error
      = import 'lua-aplicado/log.lua' { 'make_loggers' } (
          "le-tools-list-exports", "T002"
      )

--------------------------------------------------------------------------------

local join_path
      = import 'lua-aplicado/filesystem.lua'
      {
        'join_path'
      }

local is_function
      = import 'lua-nucleo/type.lua'
      {
        'is_function'
      }

local tdeepequals
      = import 'lua-nucleo/tdeepequals.lua'
      {
        'tdeepequals'
      }

local load_data_schema
      = import 'lua-nucleo/dsl/walk_data_with_schema.lua'
      {
        'load_data_schema'
      }

local arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments'
      }

local get_schema_data_walkers
      = import 'lua-aplicado/dsl/config_dsl.lua'
      {
        'get_data_walkers'
      }

local list_exports_run
      = import "list-exports/run"
      {
        'run'
      }

local temporary_directory
      = import 'lua-aplicado/testing/decorators.lua'
      {
        'temporary_directory'
      }

--------------------------------------------------------------------------------

local test = (...)("list-exports")

--------------------------------------------------------------------------------

test:group "list-exports"

--------------------------------------------------------------------------------

local SOURCES_PATH = "test/data/0020-list-exports/test-exports-lib"

local validate_format = function(data_schema, data)
  if is_function(data_schema) then
    data_schema = load_data_schema(data_schema, { }, { "cfg" })
  end

  arguments(
      "table", data_schema,
      "table", data
    )

  local checker = get_schema_data_walkers()
    :walk_data_with_schema(
        data_schema,
        data
      )
    :get_checker()

  if not checker:good() then
    return checker:result()
  end

  return data
end

local tmp_dir_decorator = temporary_directory("tmpdir", "le-tools-0020_")

--------------------------------------------------------------------------------

local run = function(output_dir, config_path, expected_result_path)
  list_exports_run(
    "--root=" .. output_dir,
    "--base-config=" .. config_path,
    "list_all"
  )

  assert(
      tdeepequals(
          assert(loadfile(join_path(output_dir, "exports.lua")))(),
          assert(loadfile(expected_result_path))()
        ),
      "exports result must match etalon"
    )
end

--------------------------------------------------------------------------------

test:case "simple" :with(tmp_dir_decorator) (function(env)
  run(
      env.tmpdir,
      "test/data/0020-list-exports/list-exports_config_simple.lua",
      join_path(SOURCES_PATH, "code/exports-simple.lua")
    )
end)

test:case "config-weights" :with(tmp_dir_decorator) (function(env)
  run(
      env.tmpdir,
      "test/data/0020-list-exports/list-exports_config_with_weigths.lua",
      join_path(SOURCES_PATH, "code/exports-config-weights.lua")
    )
end)

test:TODO "add all nesessary tests" -- https://redmine-tmp.iphonestudio.ru/issues/1200
