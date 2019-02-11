export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export DEBUG=*
cd /home/saturn/SATurn/build
bin/redis/redis-4.0.12/src/redis-server&
node SaturnServer.js services/DockerConfig.json
