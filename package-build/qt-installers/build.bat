::cd 
::yarn licenses generate-disclaimer > ..\..\NODE_LICENSES
::robocopy /E ..\..\..\build packages\SATurn\data\build
C:\Qt\QtIFW-3.0.2\bin\binarycreator.exe -c config\config.xml -p packages SATurn.exe --exclude linux.qt.x86_64,common.git.saturn,windows.haxe.x86_64,windows.developer_tools.x86_64
cd packages\common.git.saturn
rmdir data /s /q
git clone https://github.com/ddamerell53/SATurn.git data
cd ..\..\
C:\Qt\QtIFW-3.0.2\bin\binarycreator.exe -c config\config.xml -p packages SATurnDeveloper.exe --exclude linux.qt.x86_64
