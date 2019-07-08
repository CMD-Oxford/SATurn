export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export DEBUG=*
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/saturn/lib
cd /home/saturn/SATurn/build
bin/redis/src/redis-server --port 6380&
node SaturnServer.js services/DockerConfig.json
