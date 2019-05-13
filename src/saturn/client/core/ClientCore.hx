/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.core;

import saturn.client.core.CommonCore;
import saturn.db.NodeProvider;
import haxe.Json;
import saturn.core.User;
import bindings.Ext;

import haxe.Http;
import saturn.core.Util;

@:keep
class ClientCore implements ConversationHelper{
    var theSocket : NodeSocket;
    var cbsAwaitingIds : Array<String->String->Void>;
    public var msgIdToJobInfo : Map<String, Dynamic>;
    public var msgIds : Array<String>;
    var cbsAwaitingResponse : Map<String, Dynamic->String->Void>;
    var listeners : Map<String, Array<Dynamic>>;

    var nextMsgId = 0;

    public var loggedIn = false;
    var theUser : User;
    var keepProgress = true;

    var updateListeners : Array<Void->Void>;
    var refreshListeners : Array<Void->Void>;
    var showMessage : String->String->Void;
    var disabledLogout :Bool = false;
    var loginListeners : Array<Dynamic->Void>;
    var logoutListeners : Array<Void->Void>;
    var debugLogger : Dynamic;
    var providerUpListener : Void->Void;

    static var clientCore : ClientCore;

    public function new() {
        updateListeners = new Array<Void->Void>();
        refreshListeners = new Array<Void->Void>();
        listeners = new Map<String, Array<Dynamic>>();
        loginListeners = new Array<Dynamic->Void>();
        logoutListeners = new Array<Void->Void>();

        untyped __js__('debug.enable("saturn:plugin")');
        debugLogger = untyped __js__('debug("saturn:plugin")');
    }

    public function addUpdateListener(listener : Void->Void){
        updateListeners.push(listener);
    }

    public function addRefreshListener(listener : Void->Void){
        refreshListeners.push(listener);
    }

    public function addLoginListener(listener : Dynamic->Void){
        loginListeners.push(listener);
    }

    public function addLogoutListener(listener : Void->Void){
        logoutListeners.push(listener);
    }

    public function setShowMessage(func: String->String->Void)  {
        showMessage = func;
    }

    public function installNodeSocket(){
        if(theSocket != null){
            theSocket.disconnect();

            theSocket = null;
        }

        var wsProtocol = "ws";
        if(js.Browser.window.location.protocol == 'https:'){
            wsProtocol = 'wss';
        }

        theSocket = new NodeSocket(NodeSocketIO.connect(wsProtocol + '://'+js.Browser.window.location.hostname+':'+js.Browser.window.location.port, {forceNew: true, tryTransportsOnConnectTimeout: false, rememberTransport:false, transports: ['websocket'] })); //{query:'token=test'}

        initialiseSocket(theSocket);
    }

    public function login(username : String, password : String, cb : Dynamic){
        var req = new Http('/login');
        req.setParameter('username', username);
        req.setParameter('password', password);

        req.onData = function(data : String){
            var obj :Dynamic = Json.parse(data);

            if(obj.error){
                showMessage('Login failed', 'Unable to authenticate');

                return;
            }

            var cookies = untyped __js__('Cookies');

            cookies.set('user', {'fullname': obj.full_name,'token': obj.token, 'username': username.toUpperCase()}, {'expires': 14});

            var user = new User();
            user.fullname = obj.full_name;
            user.token = obj.token;
            user.username =  username.toUpperCase();

            refreshSession(cb);
        };

        req.onError = function(err : String){
            cb(err);
        }

        req.request(true);
    }

    public function refreshSession(cb: String->Void){
        var cookies = untyped __js__('Cookies');

        var cookie = cookies.getJSON('user');

        if(cookie != null){
            Util.debug('Installing authenticated node socket');

            var user = new User();
            user.fullname = cookie.fullname;
            user.token = cookie.token;
            user.username = cookie.username;

            authenticateSocket(user, function(err : String, user : User){
                if(err == null){
                    installProviders();

                    // Redundant as authenticateSocket calls login listeners

                    /*for(listener in loginListeners){
                        listener(user);
                    }*/
                }

                if(cb != null){
                    cb(err);
                }
            });

            /*for(listener in refreshListeners){
                listener();
            }*/
        }else{
            Util.debug('Installing unauthenticated node socket');

            installNodeSocket();
            installProviders();

            for(listener in refreshListeners){
                listener();
            }

            if(cb != null){
                cb(null);
            }
        }
    }

    public function installProviders(){
        CommonCore.setDefaultProvider(new NodeProvider(), true);

        BioinformaticsServicesClient.getClient(null, this);

        var dwin : Dynamic = js.Browser.window;
        dwin.DB = CommonCore.getDefaultProvider();
    }

    private function authenticateSocket(user : User, cb: String->User->Void){
        Util.debug('Authenticating: ' + user.token + '/' + user.fullname);
        if(theSocket != null){
            theSocket.disconnect();

            theSocket = null;
        }

        var wsProtocol = "ws";
        if(js.Browser.window.location.protocol == 'https:'){
            wsProtocol = 'wss';
        }

        var sock :Dynamic= NodeSocketIO.connect(
            wsProtocol + '://'+js.Browser.window.location.hostname+':'+js.Browser.window.location.port, {forceNew: true, tryTransportsOnConnectTimeout: false, rememberTransport:false, transports: ['websocket']}
        );

        sock.on("error", function(error) {
            if (error.type == "UnauthorizedError" || error.code == "invalid_token") {
                Ext.Msg.info('Login failed', 'Unable to authenticate');
            }else if(error.type == "TransportError"){
                showMessage('Server unavailable', 'Unable to contact server<br/>Not all functionaility will be available.<br/>Attempting reconnection in the background');
            }else{
                theSocket  = null;
                showMessage('Unexpected server error', 'An unexpected server error has occurred\nPlease contact your saturn administrator');
            }
        });

        sock.on('connect', function (socket : Dynamic) {
            sock.reconnecting = true;

            sock.emit('authenticate', {token: user.token}); //send the jwt
        });

        sock.on('authenticated', function () {
            Util.debug('Authenticated');

            setLoggedIn(user);

            cb(null, user);
        });

        sock.on('unauthorized', function(){
            logout(true);
            cb('rejected', null);
        });



        theSocket = new NodeSocket(sock);

        initialiseSocket(theSocket);
    }

    private function initialiseSocket(socket : NodeSocket){
        cbsAwaitingIds = new Array<String->String->Void>();
        cbsAwaitingResponse = new Map<String, String->String->Void>();
        msgIdToJobInfo = new Map<String, Dynamic>();
        msgIds = new Array<String>();

        theSocket.on('receiveMsgId',function(data){
            var cb : String->String->Void = cbsAwaitingIds.shift();

            if(Reflect.hasField(data,'msgId')){
                cb(data.msgId,null);
            }else{
                cb(null,'Node has failed to return a valid message ID response');
            }
        });

        theSocket.on('receiveError',function(data : Dynamic){
            var cb = getCb(data);
            if(cb != null){
                var err :Dynamic = data.error;
                if(err != null){
                    if(Std.is(err, String)){
                        if(StringTools.startsWith(err, '\"')){
                            err = Json.parse(err);
                        }
                    }

                }

                cb(data,err);
            }
        });

        theSocket.on('__response__', function(data : Dynamic){
            var cb = getCb(data); // Get the callback associated with data.msgId
            if(cb != null){
// We get here if we have a callback associated with data.msgId
                if(data == null){
// We get if if the server didn't respond with any data
                    cb(null, 'Invalid, empty response from server');
                }else{
// We get here if we have a callback and some data
                    var err :Dynamic = data.error;
                    if(err != null){
                        if(Std.is(err, String)){
                            if(StringTools.startsWith(err, '\"')){
                                err = Json.parse(err);
                            }
                        }
                    }

                    cb(data,data.error);
                }
            }else{
// TODO: Log this failure to resolve callback someplace
                js.Browser.window.console.log('Untracked message recieved ');

            }
        });
    }

    public function setLoggedIn(user : User){
        setUser(user);

        loggedIn = true;

        for(listener in loginListeners){
            listener(user);
        }
    }

    public function disableLogout(){
        disabledLogout = true;
    }

    public function isLogoutDisabled(){
        return disabledLogout;
    }

    public function setUser(user : User){
        theUser = user;
    }

    public function getUser(): User{
        return theUser;
    }

    public function isLoggedIn() : Bool{
        return loggedIn;
    }

    public function logout(skipLogoutEmit = false){
        if(isLogoutDisabled()){
            return;
        }

        var cookies = untyped __js__('Cookies');

        cookies.remove('user');

        if(!skipLogoutEmit){
            getNodeSocket().emit('logout',{});
        }

        setLoggedOut();

        for(listener in logoutListeners){
            listener();
        }

        refreshSession(function(err: String){

        });
    }

    public function setLoggedOut(){
        loggedIn = false;
    }

/**
    * getNodeSocket returns the NodeSocket/WebSocket instance connected to the hosting Node instance
    **/
    public function getNodeSocket(){
        return theSocket;
    }

/**
    * registerResponse needs to be called for each NodeSocket/WebSocket response that can be sent
    * in response to a message sent by the client using sendRequest().  For example the request
    * sendRequest('sendUserCount',[], function(){}) expects the included callback to be called
    * for every possible message the server might send in response.  The callback will only be
    * called if the response sent by the server has previously been registered via the method
    * registerResponse().
    *
    * TODO: Create a simple framework which autoconfigures the serve and client to know about valid requests/responses
    * @param msg is the name of the response to listen for (i.e. receiveError)
    **/
    public function registerResponse(msg : String){
        theSocket.on(msg, function(data : Dynamic){
            Util.debug('Message!!!!!');
            var cb = getCb(data); // Get the callback associated with data.msgId
            if(cb != null){
// We get here if we have a callback associated with data.msgId
                if(data == null){
// We get if if the server didn't respond with any data
                    cb(null, 'Invalid, empty response from server');
                }else{
// We get here if we have a callback and some data
                    cb(data,data.error);
                }
            }else{
// TODO: Log this failure to resolve callback someplace
                js.Browser.window.console.log('Untracked message recieved ' + msg);

            }
        });
    }

    public function registerListener(msg: String, cb : Dynamic){
        if(!listeners.exists(msg)){
            theSocket.on(msg, function(data : Dynamic){
                if(listenersRegistered(msg)){
                    notifyListeners(msg, data);
                }
            });

            listeners.set(msg, new Array<Dynamic>());
        }

        listeners.get(msg).push(cb);
    }

    public function removeListener(msg, cb : Dynamic){
        if(listeners.exists(msg)){
            listeners.get(msg).remove(cb);
        }
    }

    public function listenersRegistered(msg : String){
        return listeners.exists(msg);

    }

    public function notifyListeners(msg : String, data : Dynamic){
        if(listeners.exists(msg)){
            for(cb in listeners.get(msg)){
                cb(data);
            }
        }
    }

/**
    * sendRequest sends the message and data via the NodeSocket/WebSocket
    *
    * @param msg - Message to send to server (i.e. sendBlastReport)
    * @param data - Key/Value pairs of data to send to server
    * @param cb - Callback that will be called with the server's response (param1) or error (param2)
    **/
    public function sendRequest(msg: String, json : Dynamic, cb: Dynamic->String->Void) : String{
        var msgId = Std.string(nextMsgId++);

        json.msgId = msgId;

        cbsAwaitingResponse.set(msgId, cb);
        msgIdToJobInfo.set(msgId, {'MSG':msg, 'JSON': json, 'START_TIME': untyped __js__('Date.now()')});
        msgIds.unshift(msgId);

        theSocket.emit(msg, json);

        for(listener in updateListeners){
            listener();
        }

        return msgId;
    }

    public function printQueryTimes(){
        for(msgId in msgIdToJobInfo.keys()){
            if(Reflect.hasField(msgIdToJobInfo.get(msgId), 'END_TIME')){
                Util.debug('>' + msgId + '\t\t' + msgIdToJobInfo.get(msgId).msg + '\t\t' + ((msgIdToJobInfo.get(msgId).END_TIME - msgIdToJobInfo.get(msgId).START_TIME) / 1000));
                Util.debug(msgIdToJobInfo.get(msgId).JSON);
            }
        }
    }

/**
    * getCb returns the callback associated with the message ID found at data.msgId (param1)
    *
    * @param data - The data response received from the server (requirest the field data.msgId to find the callback).
    **/
    function getCb(data) : Dynamic->String->Void{
        var msgId = data.msgId;
        if(cbsAwaitingResponse.exists(msgId)){
            var cb = cbsAwaitingResponse.get(msgId);

            cbsAwaitingResponse.remove(msgId);

            if(!keepProgress){
                msgIdToJobInfo.remove(msgId);
                msgIds.remove(msgId);
            }else{
                Reflect.setField(msgIdToJobInfo.get(msgId),'END_TIME', untyped __js__('Date.now()'));
            }


            for(listener in updateListeners){
                listener();
            }

            return cb;
        }else{
// TODO: We should probably log this somewhere
            return null;
        }
    }

/**
    * requestNodeMsgId requests a new message ID which is passed to the callback (param1)
    *
    * @param cb - Callback called with the message ID (param1) or error message (param2)
    **/
    function requestNodeMsgId(cb:String->String->Void) {
        cbsAwaitingIds.push(cb);

        theSocket.emit('sendMsgId',{});
    }

    public static function startClientCore() : ClientCore{
        clientCore = new ClientCore();
        return clientCore;
    }

    public static function getClientCore() : ClientCore{
        return clientCore;
    }

    public function debug(message : String) : Void{
        debugLogger(message);
    }

    public static function main(){
        startClientCore();
    }

    public function onProviderUp(cb : Void->Void) : Void {
        providerUpListener = cb;
    }

    public function providerUp(){
        if(providerUpListener != null){
            var a = providerUpListener;

            providerUpListener = null;

            a();
        }
    }
}
