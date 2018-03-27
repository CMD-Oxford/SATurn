#!/bin/bash

rsync -avzh --exclude=bin --exclude=qt --exclude=node_modules ../../build/ packages/common.saturn/data/build
rsync -avzh ../../docs/ packages/common.docs.saturn/data/docs
rsync -avzh ../../build/qt/ packages/osx.qt.x86_64/data/build/qt
rsync -avzh ../../build/bin/node/ packages/osx.server.x86_64/data/build/bin/node
rsync -avzh ../../buils/bin/redis/ packages/osx.server.x86_64/data/build/bin/redis
rsync -avzh ../../build/bin/deployed_bin/ packages/osx.tools.x86_64/data/build/bin/deployed_bin
rsync -avzh ../../HaxeToolkit/ packages/osx.haxe.x86_64/data/HaxeToolkit
rsync -avzh ../../developer_tools/ packages/osx.developer_tools.x86_64/data/developer_tools

rm -rf packages/osx.single.app.x86_64/data/SATurn.app
rsync -avzh packages/osx.qt.x86_64/data/build/qt/SATurn.app packages/osx.single.app.x86_64/data/
rsync -avzh packages/common.saturn/data/build packages/osx.single.app.x86_64/data/SATurn.app/Contents/MacOS
rsync -avzh packages/osx.server.x86_64/data/build packages/osx.single.app.x86_64/data/SATurn.app/Contents/MacOS
rsync -avzh packages/osx.tools.x86_64/data/build packages/osx.single.app.x86_64/data/SATurn.app/Contents/MacOS

cp packages/common.saturn/meta/LICENSE packages/osx.single.app.x86_64/meta/LICENSE
cp packages/common.saturn/meta/LICENSE_THIRD_PARTY packages/osx.single.app.x86_64/meta/LICENSE_THIRD_PARTY
cp packages/osx.server.x86_64/meta/LICENSE_NODEJS packages/osx.single.app.x86_64/meta/LICENSE_NODEJS
cp packages/osx.server.x86_64/meta/LICENSE_REDIS packages/osx.single.app.x86_64/meta/LICENSE_REDIS
cp packages/osx.server.x86_64/meta/NODE_LICENSES packages/osx.single.app.x86_64/meta/NODE_LICENSES
cp packages/osx.tools.x86_64/meta/LICENSE packages/osx.single.app.x86_64/meta/TOOLS_LICENSE

cp packages/osx.single.app.x86_64/SATurnLaunch packages/osx.single.app.x86_64/data/SATurn.app/Contents/MacOS
cp packages/osx.single.app.x86_64/Info.plist packages/osx.single.app.x86_64/data/SATurn.app/Contents
cp packages/osx.single.app.x86_64/saturn.icns packages/osx.single.app.x86_64/data/SATurn.app/Contents/Resources

/Users/sgcadmin/Qt/QtIFW-3.0.1/bin/binarycreator -c config/config.xml -p packages SATurnOSX --exclude osx.developer_tools.x86_64,osx.haxe.x86_64,osx.qt.x86_64,osx.tools.x86_64,osx.server.x86_64,common.saturn,windows.developer_tools.x86_64,windows.haxe.x86_64,windows.tools.x86_64,windows.qt.x86_64,windows.server.x86_64,linux.qt.x86_64,common.git.saturn,windows.haxe.x86_64,windows.developer_tools.x86_64,common.docs.saturn

/Users/sgcadmin/Qt/QtIFW-3.0.1/bin/binarycreator -c config/config.xml -p packages SATurnNonStandardOSX --exclude osx.developer_tools.x86_64,osx.haxe.x86_64,windows.developer_tools.x86_64,windows.haxe.x86_64,windows.tools.x86_64,windows.qt.x86_64,windows.server.x86_64,linux.qt.x86_64,common.git.saturn,windows.haxe.x86_64,windows.developer_tools.x86_64,common.docs.saturn,osx.single.app.x86_64
cd packages/common.git.saturn
rm -rf data
git clone https://github.com/ddamerell53/SATurn.git data
cd ../../
/Users/sgcadmin/Qt/QtIFW-3.0.1/bin/binarycreator -c config/config.xml -p packages SATurnOSXDeveloper --exclude linux.qt.x86_64,windows.developer_tools.x86_64,windows.haxe.x86_64,windows.tools.x86_64,windows.qt.x86_64,windows.server.x86_64,osx.single.app.x86_64
