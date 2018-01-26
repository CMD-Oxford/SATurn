/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket.core;

import haxe.Json;
import saturn.core.User;
import saturn.app.SaturnServer;
import bindings.Ext.NodeSocket;
import js.Node;

import saturn.server.plugins.core.BaseServerPlugin;

class BaseServerSocketPlugin extends BaseServerPlugin{
    var queueName : String;
    var queue : Dynamic;
    var messageToCB : Map<String, Dynamic>;
    var pluginName : String;
    var authenticateAll : Bool = false;

    public function new(server : SaturnServer, config : Dynamic){
        pluginName = Type.getClassName(Type.getClass(this));

        messageToCB = new Map<String, Dynamic>();

        debug = Node.require('debug')('saturn:socket-plugin');

        super(server, config);
    }

    override private function processConfig(){
        super.processConfig();

        if(Reflect.hasField(config, 'authentication')){
            if(Reflect.hasField(config.authentication, "*")){
                debug('(AUTH_ALL)');
                authenticateAll = true;
            }
        }
    }

    override private function registerPlugins(){
        if(!Reflect.hasField(config, 'authentication')){
            config.authentication = new Array<Dynamic>();
        }

        if(Reflect.hasField(config, "plugins")){
            var pluginDefs : Array<Dynamic> = Reflect.field(config, "plugins");

            for(pluginDef in pluginDefs){
                if(Reflect.hasField(pluginDef, "authentication")){
                    var fields : Array<String> = Reflect.fields(pluginDef.authentication);
                    for(field in fields){
                        debug('CHILD_PLUGIN_AUTH:' + field);
                        Reflect.setField(config.authentication, field, Reflect.field(pluginDef.authentication, field));
                    }
                }
            }
        }

        super.registerPlugins();
    }

    public function addListeners(socket : NodeSocket){
        for(message in messageToCB.keys()){
            socket.on(message, function(data){
                var handler = messageToCB.get(message);

                data.socketId = socket.id;

                handler(data, socket);
            });
        }
    }

    public function cleanup(data){

    }

    public function registerListener(message : String, cb : Dynamic->NodeSocket->Void){
        var paths = [Type.getClassName(Type.getClass(this))];

        if(Reflect.hasField(config, 'namespaces')){
            var namespace_defs :Array<Dynamic> = config.namespaces;
            for(namespace_def in namespace_defs){
                paths.push(namespace_def.name);
            }
        }

        var wrapperCb = cb;

        var auth = authenticateAll;
        if(!auth){
            if(Reflect.hasField(config, 'authentication')){
                if(Reflect.hasField(config.authentication, message)){
                    auth = true;
                }
            }
        }

        if(auth){
            debug('AUTH_REQUIRED: ' + message);
            wrapperCb = function(obj: Dynamic, socket : NodeSocket){
                if(message == '_data_request_objects_namedquery' ){
                    debug('Checking named query');
                    if(Reflect.hasField(config.authentication, message)){
                        var messageConfig = Reflect.field(config.authentication, message);
                        var namedQueryConfigs = Reflect.field(messageConfig, 'queries');

                        var namedQuery = Reflect.field(obj, 'queryId');
                        debug('Checking configuration for ' + namedQuery);
                        if(Reflect.hasField(namedQueryConfigs, namedQuery)){
                            var namedQueryConfig = Reflect.field(namedQueryConfigs, namedQuery);
                            if(Reflect.field(namedQueryConfig, 'role') == 'PUBLIC'){
                                debug('Named query is publically accessible!');
                                cb(obj, socket); return;
                            }else{
                                debug('Role is not public');
                            }
                        }else{
                            debug('Missing query configuration');
                        }
                    }else{
                        cb(obj, socket);return;
                    }
                }

                saturn.isSocketAuthenticated(socket,function(user: User){
                    if(user != null){
                        debug('User: ' + user.username);

                        cb(obj, socket);
                    }else{
                        handleError(obj, 'Access denied<br/>Login or acquire additional permissions', null);
                    }
                });
            };
        }

        for(path in paths){
            var fqm = path;
            if(message.length > 0){
                fqm = path + '.' + message;
            }

            debug('URL: ' + fqm);

            messageToCB.set(fqm, wrapperCb);
        }
    }

    public function sendJson(job : Dynamic, json : Dynamic, done : Dynamic){
        try{
            var jobId = getJobId(job);

            var response :Dynamic = {};

            debug('JSON Error: '+json.error);

            if(json.error != null){
                json.error = StringTools.replace(Std.string(json.error), '\n', '');

                response.error = json.error;
            }

            response.bioinfJobId = jobId;
            response.json = json;
            response.msgId = jobId;

            var socket = getSocket(job);
            if(socket != null){
                socket.emit('__response__', response);

                cleanup(job);
            }else{
                debug('Unknown destination for ' + jobId);
            }

        }catch(e : SocketIOException){
            trace(e.toString());
        }

        if(done != null){
            done();
        }
    }

    public function sendError(job : Dynamic, error : String, done : Dynamic){
        try{
            var jobId = getJobId(job);

            debug('Error: ' + error);

            var socket = getSocket(job);
            if(socket != null){
                socket.emit(pluginName + ':response',{bioinfJobId: jobId, error:error, msgId: jobId});
                socket.emit('__response__',{bioinfJobId: jobId, error:error, msgId: jobId});
            }else{
                debug('Unknown destination for ' + jobId);
            }
        }catch(e : SocketIOException){
            trace(e.toString());
        }

        if(done != null){
            done();
        }

        cleanup(job);
    }

    public function broadcast(msg : String, json : Dynamic){
        debug('Broadcasting message:' + msg);
        this.saturn.getServerSocket().sockets.emit(msg, json);
    }

    public function registerCommand(command : String, handler : Dynamic){
        registerListener(command, handler);
    }

    public function handleError(job, error : Dynamic, cb=null){
        debug(error);

        if(cb != null){
            cb();
        }

        try{
            var socket = getSocket(job);
            var jobId = getJobId(job);
            if(socket != null){
                var errorObj = error;

                if(Reflect.hasField(error, 'message')){
                    socket.emit('receiveError', {msgId: jobId, bioinfJobId: jobId, error: error, JOB_DONE:1});
                }else{
                    socket.emit('receiveError', {msgId: jobId, bioinfJobId: jobId, error:Json.stringify(error), JOB_DONE:1});
                }


            }else{
                debug('Unable to identify socket associated with job ' + jobId + '\nError: ' + error);
            }
        }catch(e : SocketIOException){
            trace(e.toString());
        }
    }

    public function getJobId(data : Dynamic) : String{
        var jobId ;
        if(Reflect.hasField(data, 'data')){
            if(Reflect.hasField(data.data, 'bioinfJobId')){
                jobId = data.data.bioinfJobId;
            }else if(Reflect.hasField(data.data, 'msgId')){
                jobId = data.data.msgId;
            }else{
                return '-1';
            }
        }else{
            if(Reflect.hasField(data, 'bioinfJobId')){
                jobId = data.bioinfJobId;
            }else if(Reflect.hasField(data, 'msgId')){
                jobId = data.msgId;
            }else{
                return '-1';
            }
        }

        return jobId;
    }

    public function getSocket(data : Dynamic) : NodeSocket{
        if(Reflect.hasField(data, 'data')){
            if(Reflect.hasField(data.data, 'socketId')){
                return saturn.getServerSocket().sockets.connected[data.data.socketId];
            }else{
                throw new SocketIOException('Socket ID field missing from job');
            }
        }else{
            if(Reflect.hasField(data, 'socketId')){
                return saturn.getServerSocket().sockets.connected[data.socketId];
            }else{
                throw new SocketIOException('Socket ID field missing from job');
            }
        }
    }

    public function getSocketUserNoAuthCheck(socket : NodeSocket) : User{
        return saturn.getSocketUserNoAuthCheck(socket);
    }
}