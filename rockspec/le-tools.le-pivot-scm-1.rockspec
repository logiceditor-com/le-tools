package = "le-tools.le-pivot"
version = "scm-1"
source = {
   url = "git://github.com/logiceditor-com/le-tools.git",
   branch = "master"
}
description = {
   summary = "Pivot table generator",
   homepage = "https://github.com/logiceditor-com/le-tools",
   license = "MIT/X11",
   maintainer = "LogicEditor Team <team@logiceditor.com>"
}
supported_platforms = {
   "unix"
}
dependencies = {
   "lua-nucleo >= 0.1.0"
}
build = {
  type = "none",
  install = {
    bin = {
      "bin/le-pivot"
    },
    lua = {
      ["le-tools.pivot.format"] = "src/lua/pivot/format.lua";
      ["le-tools.pivot.pivot"] = "src/lua/pivot/pivot.lua";
      ["le-tools.pivot.run"] = "src/lua/pivot/run.lua";
    }
  }
}
