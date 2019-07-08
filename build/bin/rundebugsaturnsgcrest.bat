set NODE_PATH=%CD%\node\node_modules
cd redis
start /B redis-server.exe --port 6379
cd ../
set DEBUG=*,-ioredis:redis
cd ..\
bin\node\node.exe SaturnServer.js services\ServicesLocalOracleREST.json
cd bin
