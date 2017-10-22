package = "le-tools.list-exports"
version = "scm-1"
source = {
   url = "git://github.com/logiceditor-com/le-tools.git",
   branch = "master"
}
description = {
   summary = "list-exports Tool",
   homepage = "https://github.com/logiceditor-com/le-tools",
   license = "MIT/X11",
   maintainer = "LogicEditor Team <team@logiceditor.com>"
}
supported_platforms = {
   "unix"
}
dependencies = {
   "lua == 5.1",
   "lua-nucleo",
   "lua-aplicado"
}
build = {
   type = "none",
   copy_directories = {
     "src/lua/list-exports"
   }
}
