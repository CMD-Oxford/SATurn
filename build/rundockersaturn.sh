export DEBUG=*
cd /home/saturn/SATurn/build
bin/redis/redis-4.0.12/src/redis-server&
node SaturnServer.js services/DockerConfig.json
