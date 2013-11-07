#! /bin/bash

set -e

echo "----> Removing rocks"
luarocks list | grep le-tools | sudo xargs -l1 luarocks remove --force || true

echo "----> Making rocks"
find rockspec -name *scm-1*.rockspec | xargs -l1 sudo luarocks make

echo "----> OK"
