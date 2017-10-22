--------------------------------------------------------------------------------
-- config.lua: list-exports test configuration
-- This file is a part of le-tools library
-- Copyright (c) le-tools authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------
-- Note that PROJECT_PATH is defined in the environment
--------------------------------------------------------------------------------

local join_path
      = import 'lua-aplicado/filesystem.lua'
      {
        'join_path'
      }

local SOURCES_PATH = "test/data/0020-list-exports/test-exports-lib";

common =
{
  PROJECT_PATH = PROJECT_PATH;

  exports =
  {
    ALIAS_SYMBOL_WEIGHT = 123;
    DEFAULT_SYMBOL_WEIGHT = 500;

    exports_dir = PROJECT_PATH;
    profiles_dir = join_path(SOURCES_PATH, "code");

    sources =
    {
      {
        sources_dir = SOURCES_PATH;
        root_dir_only = "./";
        lib_name = "test-exports-lib";
        profile_filename = "profile.lua";
        out_filename = "exports.lua";
        file_header = [[
-- This file is a part of le-tools library
-- Copyright (c) Alexander Gladysh <ag@logiceditor.com>
-- Copyright (c) Dmitry Potapov <dp@logiceditor.com>
-- See file `COPYRIGHT` for the license
]]
      };
    };
  };
}

--------------------------------------------------------------------------------

list_exports =
{
  action =
  {
    name = "help";
    param =
    {
      -- No parameters
    };
  };
}
