export DEBUG=*
export NODE_PATH=bin/node_modules
cd /home/saturn/SATurn/build
bin/redis/redis-4.0.6/src/redis-server&
bin/node/bin/node SaturnServer.js services/ServicesLocalLiteLinux.json
