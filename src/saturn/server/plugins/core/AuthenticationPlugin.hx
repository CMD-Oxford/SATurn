/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.core;

import saturn.core.User;
import saturn.app.SaturnServer;
import js.Node;
import saturn.core.Util;

class AuthenticationPlugin extends BaseServerPlugin{
    var authManager :AuthenticationManager;


    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        configureAuthenticationManager();

        installAuth();

        if(config.password_in_token){
            debug('Warning storing user passwords in tokens is probably a very bad idea!!!!!!!!!!!');
        }
    }

    public function installAuth(){
        var jwt = Node.require('jsonwebtoken');
        var uuid = Node.require('node-uuid');

        saturn.getServer().post('/login', function (req : Dynamic, res : Dynamic, next) {
            var username : String = req.params.username;
            var password : String = req.params.password;

            authManager.authenticate(username, password, function(user: User){
                user.uuid = uuid.v4();
                user.username = username;

                if(config.password_in_token){
                    Util.debug('Storing password in token!!!!');
                    user.password = password;
                }

                var db = saturn.getRedisClient();

                db.set(user.uuid, user.username);

                Util.debug('a');
                // we are sending the profile in the token

                #if NODE_LATEST
                var token = jwt.sign(user, config.jwt_secret, { expiresIn: config.jwt_timeout + 'm'});
                #else
                var token = jwt.sign(user, config.jwt_secret, { expiresInMinutes: config.jwt_timeout });
                #end

                //res.setHeader('Content-Type', 'application/json');
                res.send(200,{token: token, full_name: user.firstname + ' ' + user.lastname, email: user.email, 'projects': user.projects});

                next();
            }, function(err : String){
                //res.setHeader('Content-Type', 'application/json');
                res.send(200,{error: 'Unable to authenticate'});
                next();
            }, req.connection.remoteAddress);
        });

        var socketioJwt = Node.require('socketio-jwt');

        saturn.getServerSocket().on('connection', socketioJwt.authorize({
            required: false,
            secret: config.jwt_secret,
            timeout: 15000, // 15 seconds to send the authentication message
            additional_auth: additionalAuth
        })).on('authenticated', function(socket) {
            socket.on('logout', function(data){
                saturn.getSocketUser(socket, function(authUser){
                    if(authUser != null){
                        Node.console.log('Logging ' + authUser.username + ' out');

                        var db = saturn.getRedisClient();

                        db.del(authUser.uuid);

                        saturn.setUser(socket,null);
                    }
                });
            });
        });

        //TODO: Missing unauthenticated action
    }

    public function configureAuthenticationManager(){
        var clazzStr = config.authentication_manager.clazz;

        var clazz = Type.resolveClass(clazzStr);

        authManager = Type.createInstance(clazz, [config.authentication_manager]);

        if(!Std.is(authManager, AuthenticationManager)){
            throw 'Unable to setup authentication manager\n' + clazzStr + ' should implement ' + AuthenticationManager;
        }
    }

    public function additionalAuth(user: User, onSuccess: Void->Void, onFailure: String->String->Void){
        Node.console.log('Validating jwt token is current');

        var db = saturn.getRedisClient();

        debug('Got redis');

        saturn.isUserAuthenticated(user, function(authUser : User){
            debug('here');
            if(authUser != null){
                onSuccess();
            }else{
                debug('Returning failure');
                onFailure('On Error', 'invalid_token');
            }
        });
    }
}