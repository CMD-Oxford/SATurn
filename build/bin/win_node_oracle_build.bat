cd node
set PATH=%PATH%;%CD%\node
set OCI_LIB_DIR=%CD%\instantclient\sdk\lib\msvc
set OCI_INC_DIR=%CD%\instantclient\sdk\include
npm install --production windows-build-tools
npm install oracledb
cd ../
