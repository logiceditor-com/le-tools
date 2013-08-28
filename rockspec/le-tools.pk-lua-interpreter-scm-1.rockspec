package = "le-tools.pk-lua-interpreter"
version = "scm-1"
source = {
   url = "git://github.com/logiceditor-com/le-tools.git",
   branch = "master"
}
description = {
   summary = "pk-lua-interpreter Tool",
   homepage = "https://github.com/logiceditor-com/le-tools",
   license = "MIT/X11",
   maintainer = "LogicEditor Team <team@logiceditor.com>"
}
supported_platforms = {
   "unix"
}
dependencies = {
}
build = {
  type = "none",
  install = {
    bin = {
      "bin/pk-lua-interpreter"
    }
  }
}
