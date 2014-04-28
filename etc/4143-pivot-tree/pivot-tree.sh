#!/bin/bash

set -e

le-pivot lua 1=1+ 2=1+ 4=1+ <chains.tsv >chains.tpretty
le-pivot json 1=1+ 2=1+ 4=1+ <chains.tsv >chains.json
le-pivot text 1=1+ 2=1+ 4=1+ <chains.tsv >chains.txt
