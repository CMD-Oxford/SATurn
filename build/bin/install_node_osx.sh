#!/bin/bash

# Get directory for this script

cd $(dirname $0)
script_path=$PWD
echo "Script path: $script_path"
cd -

# Set environment variables

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$script_path/node/bin:$PATH:$script_path/node/node_modules/.bin"
export NODE_PATH="$script_path/node/node_modules"

echo "NODE_PATH = $NODE_PATH"
echo "PATH = $PATH"

# Remove NodeJS and download known version

rm -rf node
curl -O https://nodejs.org/dist/v8.10.0/node-v8.10.0-darwin-x64.tar.gz
tar zxvf node-v8.10.0-darwin-x64.tar.gz
mv node-v8.10.0-darwin-x64 node

# Remove Yarn and download latest version

rm -rf $HOME/.yarn*
curl -o- -L https://yarnpkg.com/install.sh | bash
cd node

# Use NPM to install node-pre-gyp

npm install --prefix . node-pre-gyp

# Install all other dependencies with yarn

yarn add  fs-extra 
yarn add  pg
yarn add  temp
yarn add  bull
yarn add sqlite3 --build-from-source --sqlite=/usr/local/opt/sqlite
yarn add  ncbi-eutils
yarn add  split
yarn add  restify@4.3.1
yarn add  socket.io
yarn add  jsonwebtoken@7.4.1
yarn add  socketio-jwt
yarn add  http-proxy
yarn add  agentkeepalive
yarn add  nodemailer
yarn add  redis
yarn add  debug
yarn add  node-uuid
yarn add  needle

# Auto-clean to reduce the number of files we need to package

cp ..\.yarnclean .
yarn autoclean --force
