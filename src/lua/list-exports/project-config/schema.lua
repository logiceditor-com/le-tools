--------------------------------------------------------------------------------
-- schema.lua: list-exports configuration file format
-- This file is a part of le-tools library
-- Copyright (c) le-tools authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local load_tools_cli_data_schema
      = import 'lua-aplicado/dsl/tools_cli_config.lua'
      {
        'load_tools_cli_data_schema'
      }
local create_config_schema

do
  local schema_chunk = function()
    cfg:root
    {
--      common_tool_config_schema_chunk();

-- TODO: remove common part, make it to include externally
--------------------------------------------------------------------------------
-- Temporarily added common part

      cfg:node "common"
      {
        cfg:existing_path "PROJECT_PATH";

        cfg:node "exports"
        {
          cfg:existing_path "exports_dir";
          cfg:existing_path "profiles_dir";

          cfg:non_empty_ilist "sources"
          {
            cfg:path "sources_dir";
            cfg:optional_string "root_dir_only";
            cfg:string "lib_name";
            cfg:optional_string "module_name"; -- for LDoc documentation only
            cfg:path "profile_filename";
            cfg:path "out_filename";
            cfg:string "file_header";
          };
        };
      };

--------------------------------------------------------------------------------

      cfg:node "list_exports"
      {
        cfg:variant "action"
        {
          variants =
          {
            ["help"] =
            {
              -- No parameters
            };

            ["list_all"] =
            {
              -- No parameters
            };
          };
        };
      };
    }
  end

  create_config_schema = function()
    return load_tools_cli_data_schema(
        schema_chunk
      )
  end
end

return
{
  create_config_schema = create_config_schema;
}
