#!/bin/bash
# Script to build Haxe SATurn libraries on OSX

export PATH=$PATH:HaxeToolkit
export DYLD_LIBRARY_PATH=HaxeToolkit/neko/
export HAXE_STD_PATH=HaxeToolkit/std
export HAXE_LIBRARY_PATH=HaxeToolkit/std

haxelib setup HaxeToolkit/lib
#haxelib install jQueryExtern
haxelib install compiletime
haxelib install continuation
#haxelib install nodejs

haxe build.hxml
