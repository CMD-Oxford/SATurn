/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.app;

import saturn.core.Util;
import saturn.server.plugins.socket.core.SocketIOException;
import bindings.Ext.NodeSocket;
import saturn.core.User;
import saturn.server.plugins.core.BaseServerPlugin;
import saturn.server.plugins.socket.core.BaseServerSocketPlugin;
import js.Node;

import com.dongxiguo.continuation.Continuation;
import bindings.NodeFSExtra;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
class SaturnServer {
    var fsLib : Dynamic = Node.require('fs');
    var fsExtraLib : Dynamic = Node.require('fs-extra');
    public var pathLib : Dynamic = Node.require('path');
    var tempLib : Dynamic = Node.require('temp');
    var cryptoLib : Dynamic = Node.require('crypto');
    var httpLib : Dynamic = Node.require('http');
    var domainLib : Dynamic = Node.require('domain');
    var execLib : Dynamic = Node.require('child_process');
    var osLib : Dynamic = Node.require('os');
    var restify : Dynamic = Node.require('restify');
    static var DEBUG : Dynamic = Node.require('debug')('saturn:server');

    var __dirname : Dynamic = Node.__dirname;

    var server : Dynamic;

    var theServerSocket : Dynamic;

    var serviceConfigs :Map<String,Dynamic>;
    var serviceConfig : Dynamic;
    var servicesFile : String;
    public var localServerConfig : Dynamic;
    var port : Int;
    var redisPort : Int;

    var socketPlugins : Array<BaseServerSocketPlugin>;
    var plugins : Array<BaseServerPlugin>;
    var redisClient : Dynamic;

    static var defaultServer : SaturnServer;

    static var beforeListen : Dynamic;
    static var afterListen : Dynamic;

    public static function main(){
        defaultServer = new SaturnServer();
    }

    public static function getDefaultServer(){
        return defaultServer;
    }

    public static function debuglog(name : String, value : String){
        DEBUG(name, value);
    }

    public function getRedisPort() : Int{
        return redisPort;
    }

    public function getPort() : Int{
        return port;
    }

    public function getHostname() : String{
        return '127.0.0.1';
    }

    public function getServerConfig() : Dynamic {
        return localServerConfig;
    }


    public function new(){
        serviceConfigs = new Map<String, Dynamic>();
        socketPlugins = new Array<BaseServerSocketPlugin>();
        plugins = new Array<BaseServerPlugin>();

        if(Node.process.argv.length == 3){
            servicesFile = Node.process.argv[2];

            loadServiceDefinition(function(){});
        }else{
            debug('Usage\tServices File\n');
            Node.process.exit(-1);
        }
    }

    public function initialiseServer(index_page){
        var http_config = {};

        var serverConfig = getServerConfig();

        if(Reflect.hasField(serverConfig, 'restify_http_options')){
            http_config = Reflect.field(serverConfig, 'restify_http_options');
            Util.debug(Util.string(http_config));
        }

        server = restify.createServer(http_config);

        //below conflicts with GlycanBuilder
        server.use(restify.plugins.bodyParser({mapParams: true}));

        installPlugins();

        installSocketPlugins();

        server.get(untyped __js__('/static\\/.*/'), restify.plugins.serveStatic({
            directory: './public'
        }));

        server.get('/', function(req,res, next){
            res.header('Location', index_page);
            res.send(302);
            return next(false);
        });

        configureRedisClient();

        if(beforeListen != null){
            beforeListen();
        }

        server.listen(port, function () {
            debug('Server listening at ' + server.url);
        });

        if(afterListen != null){
            afterListen();
        }
    }

    private function installSocketPlugins(){
        if(Reflect.hasField(getServerConfig(), 'socket_plugins')){
            var pluginDefs : Array<Dynamic> = getServerConfig().socket_plugins;
            for(pluginDef in pluginDefs){
                debug("PLUGIN: " + pluginDef.clazz);
                var plugin = Type.createInstance(Type.resolveClass(pluginDef.clazz), [this, pluginDef]);

                socketPlugins.push(plugin);
            }
        }

        var Queue = Node.require('bull');

        theServerSocket.sockets.on('connection', function (socket : Dynamic) {
            //socket.handshake.decoded_token
            for(plugin in socketPlugins){
                plugin.addListeners(socket);
            }
        });
    }

    private function installPlugins(){
        if(Reflect.hasField(getServerConfig(), 'plugins')){
            var pluginDefs : Array<Dynamic> = getServerConfig().plugins;
            for(pluginDef in pluginDefs){
                debug("PLUGIN: " + pluginDef.clazz);
                var plugin = Type.createInstance(Type.resolveClass(pluginDef.clazz), [this, pluginDef]);

                plugins.push(plugin);
            }
        }
    }

    @:cps public function loadServiceDefinition(){
        var err : NodeErr, content : String = @await Node.fs.readFile(servicesFile,'utf8');
        if(err == null){
            serviceConfig = Node.json.parse(content);

            if(Reflect.hasField(serviceConfig,'port')){
                port = serviceConfig.port;

                if(Reflect.hasField(serviceConfig,'redis_port')){
                    redisPort = serviceConfig.redis_port;

                    serviceConfigs.set('localhost: ' + port, serviceConfig);

                    localServerConfig = serviceConfig;

                    initialiseServer(serviceConfig.index_page);
                }else{
                    debug('Service config is missing redis_port property');
                    Node.process.exit(-1);
                }
            }else{
                debug('Service config is missing port property');
                Node.process.exit(-1);
            }
        }else{
            debug(err);
            Node.process.exit(-1);
        }
    }

    public function debug(msg : String){
        DEBUG(msg);
    }

    public function getStandardErrorCode() : String{
        return 'H2IK';
    }

    public static function getStandardUserInputError() : String{
        return 'Invalid User Input';
    }

    public function getRelativePublicStorageFolder(){
        return 'public/static';
    }

    public function getRelativePublicStorageURL(){
        return 'static';
    }

    public function getRelativePublicOuputFolder(){
        return getRelativePublicStorageFolder() + '/out';
    }

    public function getRelativePublicOuputURL(){
        return getRelativePublicStorageURL() + '/out';
    }

    public function getPythonPath(){
        return Node.os.platform() == 'win32' ? 'C:/python27/Python.exe' : '/opt/python/python_builds/python-2.7.7/bin/python';
    }

    public function getServer() : Dynamic {
        return server;
    }

    public function getServerSocket() : Dynamic{
        return theServerSocket;
    }

    public function setServerSocket(socket){
        theServerSocket = socket;
    }

    public function installLogin(){

    }

    public function getSocketUser(socket : Dynamic, cb : User->Void){
        isSocketAuthenticated(socket, cb);
    }

    public function setUser(socket : Dynamic, user : User){
        socket.decoded_token = user;
    }

    public function isSocketAuthenticated(socket : Dynamic,cb : User->Void){
        if(socket.decoded_token){
            var user : User = getSocketUserNoAuthCheck(socket);

            isUserAuthenticated(user,cb);
        }else{
            cb(null);
        }
    }

    public function getSocketUserNoAuthCheck(socket : Dynamic){
        return socket.decoded_token;
    }

    public function isUserAuthenticated(user : User, cb : User->Void){
        if(user == null){
            cb(null);
        }else{
            redisClient.get(user.uuid, function(err, reply){
                if(err || reply == null){
                    cb(null);
                }else{
                    cb(user);
                }
            });
        }
    }

    public function configureRedisClient(){
        var redis = Node.require("redis");

        redisClient = redis.createClient(getRedisPort(), getHostname());

        redisClient.on("error", function (err) {
            debug("Redis Error " + err);
            Node.process.exit(-1);
        });
    }

    public function getRedisClient() : Dynamic{
        return redisClient;
    }

    public static function makeStaticAvailable(filePath, cb: String->String->Void){
        var outputPath : String = getDefaultServer().getRelativePublicOuputFolder() + '/' + getDefaultServer().pathLib.basename(filePath) + '.txt';
        var remotePath : String = getDefaultServer().getRelativePublicOuputURL() + '/' + getDefaultServer().pathLib.basename(filePath) + '.txt';

        NodeFSExtra.copy(filePath, outputPath, function(err : String){
            cb(err, remotePath);
        });
    }
}
