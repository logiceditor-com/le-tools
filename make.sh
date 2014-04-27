#! /bin/bash

set -e

echo "----> Removing rocks"
luarocks list | grep le-tools | sudo xargs -L1 luarocks remove --force || true

echo "----> Making rocks"
# Note: order is important here
sudo luarocks make rockspec/le-tools.le-lua-interpreter-scm-1.rockspec
sudo luarocks make rockspec/le-tools.le-call-lua-module-scm-1.rockspec
sudo luarocks make rockspec/le-tools.le-pivot-scm-1.rockspec

echo "----> OK"
