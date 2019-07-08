export DEBUG=*
export NODE_PATH=bin/node_modules
cd /home/saturn/SATurn/build
bin/redis/src/redis-server&
node SaturnServer.js services/ServicesLocalLiteLinux.json
