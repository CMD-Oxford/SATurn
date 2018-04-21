export DEBUG=*
export NODE_PATH=bin/node_modules
bin/redis/redis-4.0.6/src/redis-server&
bin/node/bin/node SaturnServer.js services/ServicesLocalLiteLinux.json
