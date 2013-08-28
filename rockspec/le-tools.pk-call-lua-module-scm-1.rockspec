package = "le-tools.pk-call-lua-module"
version = "scm-1"
source = {
   url = "git://github.com/logiceditor-com/le-tools.git",
   branch = "master"
}
description = {
   summary = "pk-call-lua-module Tool",
   homepage = "https://github.com/logiceditor-com/le-tools",
   license = "MIT/X11",
   maintainer = "LogicEditor Team <team@logiceditor.com>"
}
supported_platforms = {
   "unix"
}
dependencies = {
  "lua >= 5.1",
  "lua-nucleo",
  "lua-aplicado",
  "le-tools.pk-lua-interpreter >= 0.0.1",
}
build = {
  type = "none",
  install = {
    bin = {
      "bin/pk-call-lua-module"
    }
  }
}
