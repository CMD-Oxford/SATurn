set NODE_PATH=%CD%\node\node_modules
cd redis
start /B redis-server.exe --port 6379
cd ../
set DEBUG=*,-ioredis:redis
cd ..\
bin\node\node.exe --inspect SaturnServer.js services\ServicePhylo5.json
cd bin
