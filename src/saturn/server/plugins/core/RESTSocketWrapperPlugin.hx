package saturn.server.plugins.core;

import saturn.app.SaturnServer;

/**
* *
**/

class RESTSocketWrapperPlugin extends BaseServerPlugin {
    // Import UUID module
    var uuidModule = js.Node.require('node-uuid');

    /**
    * Dictionary to map from work UUID to authentication token, used as an extra layer of protection to prevent people
    * accessing results using a work UUID which was generated for another authentication token (i.e. User)
    **/
    var uuidToToken = new Map<String,String>();
    // Dictionary to map from work UUID to response
    var uuidToResponse = new Map<String, Dynamic>();
    // Dictionary to map from work UUID to the work request object
    var uuidToJobInfo = new Map<String, Dynamic>();

    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        registerListeners();
    }

    /**
    * extractAuthenticationToken extracts the authentication token either from a cookie or requst parameter
    **/
    public function extractAuthenticationToken(req : Dynamic) : String{
        var cookies = req.cookies;

        if(cookies.saturn_token != null){
            return cookies.saturn_token;
        }else{
            return req.params.token;
        }
    }

    public function invalidAuthentication(req, res, next){
        // respond with bad uuid
        res.status(403);
        res.send('Bad uuid');
        next();
    }

    public function registerListeners(){
        // Register the /api/queue/:uuid route with RESTify which is used to retrieve the results of a work request
        saturn.getServer().post('/api/queue/:uuid', function (req : Dynamic, res : Dynamic, next) {
            // Extract authentication token from message
            var token : String = extractAuthenticationToken(req);

            if(token == null){
                invalidAuthentication(req,req,next);
                return;
            }

            var uuid : String = req.params.uuid;

            if(uuidToToken.exists(uuid)){
                if(uuidToToken.get(uuid) == token){
                    if(uuidToResponse.exists(uuid)){
                        var response = uuidToResponse.get(uuid);

                        res.status(200);

                        res.send(response);

                        next();
                    }else{
                        res.status(102);

                        next();
                    }
                }else{
                    // respond with bad match
                    res.status(403);
                    res.send('Token/uuid missmatch expected ' + uuidToToken.get(uuid) + ' and you passed ' + token);
                    next();
                }
            }else{
                // respond with bad uuid
                res.status(403);
                res.send('Bad uuid');
                next();
            }
        });

        var handle_function = function (path : String, req : Dynamic, res : Dynamic, next) {
            debug('In Function');
            // User provided username & password
            var token : String = extractAuthenticationToken(req);

            if(token == null){
                invalidAuthentication(req,req,next);
                return;
            }

            var command : String = req.params.command;
            var json : Dynamic = js.Node.parse(req.params.json);

            if(path == '/api/command/'){
                if(command == '_remote_provider_._data_request_objects_namedquery'){
                    var d :Dynamic = {};

                    d.queryId = json.queryId;
                    d.parameters = haxe.Serializer.run(json.parameters);

                    json = d;
                }
            }else if(path == '/api/provider/command/'){
                var d :Dynamic = {};

                d.queryId = command;

                command = '_remote_provider_._data_request_objects_namedquery';

                d.parameters = haxe.Serializer.run(json.parameters);

                json = d;
            }

            var wait = 'no';

            if(Reflect.hasField(req.params, 'wait')){
                wait = req.params.wait;

                debug('Going to wait');

                if(wait != 'no' && wait != 'yes'){
                    // respond with bad match
                    res.status(403);
                    res.send('Wait setting must be yes or no');
                    next();
                    return;
                }
            }

            var uuid = uuidModule.v4();

            uuidToToken.set(uuid, token);

            res.header('Location', '/api/queue/' + uuid);

            if(wait == 'no'){
                res.status(202);

                res.send();

                next();
            }else{
                next();
            }

            var io = js.Node.require('socket.io-client');
            // TODO: Obtain port from configuration

            var protocol = 'ws';

            if(saturn.isEncrypted()){
                protocol = 'wss';
            }

            var conStr = protocol + '://' + saturn.getInternalConnectionHostName() + ':' + saturn.getServerConfig().port;
            debug('Connecting to ' + conStr);

            var socket :Dynamic = io.connect(conStr,{
                port:8091
            });

            var openTime =  Date.now().getTime();

            var status = new Map<String, Bool>();
            status.set('connected', false);
            status.set('disconnected', false);

            socket.on('error', function(data : Dynamic){
                respond(uuid, 500, socket, wait, 'Unknown error', status, res);
            });

            socket.on('authenticated', function (data : Dynamic) {
                runCommand(socket, command, json, uuid);
            });

            socket.on('unauthorized', function(data : Dynamic){
                respond(uuid, 403, socket, wait, 'Unauthorised', status, res);
            });

            socket.on('receiveError',function(data : Dynamic){
                respond(uuid, 200, socket, wait, data, status, res);
            });

            socket.on('__response__', function(data : Dynamic){
                respond(uuid, 200, socket, wait, data,status, res);
            });

            socket.on('connect', function(data : Dynamic){
                status.set('connected', true);

                socket.emit('authenticate', {token: token});
            });

            var cleanUp = null;

            cleanUp = function(){
                var currentTime = Date.now().getTime();

                // If the socket has already been disconnected do nothing
                if(status.get('disconnected')){

                }else{
                    // Check if the socket has been open for longer than 5 minutes and close if it has
                    if( (currentTime - openTime) / 1000 > 60*5 ){
                        socket.disconnect();

                        status.set('disconnected', true);

                        if(wait == 'yes'){
                            debug('Sending response');
                            res.status(200);

                            res.send('Connection time-out');
                        }
                    }else{
                        haxe.Timer.delay(cleanUp,1000*10);
                    }
                }

            };

            cleanUp();
        };

        // Register POST login listener on restify
        saturn.getServer().post('/api', function (req : Dynamic, res : Dynamic, next){
            handle_function('/api/', req, res, next);
        });

        // Register POST login listener on restify
        saturn.getServer().post('/api/command/:command', function (req : Dynamic, res : Dynamic, next){
            handle_function('/api/command/', req, res, next);
        });

        saturn.getServer().post('/api/provider/command/:command', function (req : Dynamic, res : Dynamic, next){
            handle_function('/api/provider/command/', req, res, next);
        });
    }

    function respond(uuid, statusCode, socket, wait, data, status, res){
        if(wait == 'yes'){
            debug('Sending response');
            res.status(statusCode);

            res.send(data);
        }else{
            debug('Not sending response');
        }

        uuidToResponse.set(uuid, data);

        socket.disconnect();

        status.set('disconnected', true);
    }

    public function runCommand(socket, command : String, json :Dynamic, uuid : String){
        json.msgId = uuid;
        json.bioinfJobId = uuid;

        uuidToJobInfo.set(uuid, {'MSG':command, 'JSON': json});

        debug('Sending command ' + command);

        socket.emit(command, json);
    }
}