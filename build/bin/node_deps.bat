cd node
set PATH=%PATH%;%CD%
copy ..\package.json .
call yarn add  fs-extra
call yarn add  pg
call yarn add  temp
call yarn add  bull
call yarn add  sqlite3
call yarn add  ncbi-eutils
call yarn add  split
call yarn add  restify@4.3.1
call yarn add  restify-json-body-parser
call yarn add  socket.io
call yarn add  jsonwebtoken@7.4.1
call yarn add  socketio-jwt
call yarn add  http-proxy
call yarn add  agentkeepalive
call yarn add  nodemailer
call yarn add  redis
call yarn add  debug
call yarn add  node-uuid
call yarn add  needle
copy ..\.yarnclean .
call yarn autoclean --force
