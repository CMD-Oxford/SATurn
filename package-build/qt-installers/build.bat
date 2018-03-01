::cd 
::yarn licenses generate-disclaimer > ..\..\NODE_LICENSES
::robocopy /E ..\..\..\build packages\SATurn\data\build
robocopy /E ..\..\build packages\common.saturn\data\build /xd "bin" "qt" "node_modules"
robocopy /E ..\..\build\qt packages\windows.qt.x86_64\data\build\qt
robocopy /E ..\..\build\bin\node packages\windows.server.x86_64\data\build\bin\node
robocopy /E ..\..\build\bin\redis packages\windows.server.x86_64\data\build\bin\redis
robocopy /E ..\..\build\bin\deployed_bin packages\windows.tools.x86_64\data\build\bin\deployed_bin
robocopy /E ..\..\HaxeToolkit packages\windows.haxe.x86_64\data\HaxeToolkit
robocopy /E ..\..\developer_tools packages\windows.developer_tools.x86_64\data\developer_tools

C:\Qt\QtIFW-3.0.2\bin\binarycreator.exe -c config\config.xml -p packages SATurn.exe --exclude linux.qt.x86_64,common.git.saturn,windows.haxe.x86_64
cd packages\common.git.saturn
rmdir data /s /q
git clone https://github.com/ddamerell53/SATurn.git data
cd ..\..\
C:\Qt\QtIFW-3.0.2\bin\binarycreator.exe -c config\config.xml -p packages SATurnDeveloper.exe --exclude linux.qt.x86_64
