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
    // Instance which will authenticate user
    var authManager : AuthenticationManager;


    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        // Initialise this.authManager
        configureAuthenticationManager();

        // Install authentication listeners on restify and socketio
        installAuth();

        // Output warning in logs about storing passwords in tokens
        if(config.password_in_token){
            debug('Warning passwords will be stored in JSON web tokens using AES encryption.  ' +
                    'To disable set password_in_token to false in your confirguation file');
        }
    }

    /**
    * installAuth adds authentication listeners to restify and socketio
    **/
    public function installAuth(){
        // Import required third-party libraries
        var jwt = Node.require('jsonwebtoken');
        var uuid = Node.require('node-uuid');
        var crypto = Node.require('crypto');

        // Register POST login listener on restify
        saturn.getServer().post('/login', function (req : Dynamic, res : Dynamic, next) {
            // User provided username & password
            var username : String = req.params.username;
            var password : String = req.params.password;

            // Authenticate user using AuthenticaionManager specified in plugin configuration
            authManager.authenticate(username, password, function(user: User){
                // Get Redis client connection
                var db = saturn.getRedisClient();

                // Generate random user session ID
                user.uuid = uuid.v4();
                user.username = username;

                // In the SGC each user accesses our LIMS database with their own account.  Every request the user makes
                // to perform database actions requires that SATurn connects as that user to the LIMS database.
                // We therefore need access to the users' LIMS password upon each database request.  So we store their
                // passwords in the JSON webtoken as an AES encrypted string.
                if(config.password_in_token){
                    // Generate random IV
                    var iv = crypto.randomBytes(config.encrypt_iv_length);

                    // Create Cipher
                    var cipher = crypto.createCipheriv(config.algorithm, new js.Node.NodeBuffer(config.encrypt_password), iv);

                    // Encrypt password
                    var crypted : String = cipher.update(password, 'utf8', 'hex');

                    crypted += cipher.final('hex');

                    password = crypted;

                    // Store IV with password
                    user.password = iv.toString('hex') + ':' + password;
                }

                // Store user UUID
                db.set('USER_UUID: ' + user.uuid, user.username);

                // Generate JWT token.
                // !!!! IMPORTANT - ALL THE PAYLOAD BELOW WON'T BE ENCRYPTED !!!!
                var token = jwt.sign({
                        firstname: user.firstname,
                        lastname: user.lastname,
                        email: user.email,
                        uuid:  user.uuid,
                        username: user.username,
                        password: user.password
                    },
                    config.jwt_secret,
                    {expiresIn: config.jwt_timeout + 'm'}
                );

                // Send the JSON token to the client
                // TODO: Why are we sending detials like the full_name twice.  The client should be able to extract
                // TODO: these from the signed payload.
                res.send(200,{token: token, full_name: user.firstname + ' ' + user.lastname, email: user.email, 'projects': user.projects});

                // Signal up to restify
                next();
            }, function(err : String){
                // Send authentication error
                res.send(200,{error: 'Unable to authenticate'});
                next();
            }, req.connection.remoteAddress);
        });

        // Install socketio.jwt to handle JSON web tokens
        var socketioJwt = Node.require('socketio-jwt');

        // Add socketio connection listener
        // !!!! IMPORTANT additional_auth provides an extension point to verify that the token is still valid !!!!
        saturn.getServerSocket().on('connection', socketioJwt.authorize({
            required: false,
            secret: config.jwt_secret,
            timeout: 15000, // 15 seconds to send the authentication message
            additional_auth: additionalAuth
        })).on('authenticated', function(socket) {
            // Install logout listener
            socket.on('logout', function(data){
                saturn.getSocketUser(socket, function(authUser){
                    if(authUser != null){
                        var db = saturn.getRedisClient();

                        db.del('USER_UUID: ' + authUser.uuid);

                        // Clear the user from the socket
                        saturn.setUser(socket,null);
                    }
                });
            });
        });

        // Set this plugin as the authentication plugin for SATurn
        saturn.setAuthenticationPlugin(this);
    }

    /**
    * configureAuthenticationManager installs the AuthenticationManager specified in the plugin service configuration
    **/
    public function configureAuthenticationManager(){
        var clazzStr = config.authentication_manager.clazz;

        var clazz = Type.resolveClass(clazzStr);

        authManager = Type.createInstance(clazz, [config.authentication_manager, this]);

        if(!Std.is(authManager, AuthenticationManager)){
            throw 'Unable to setup authentication manager\n' + clazzStr + ' should implement ' + AuthenticationManager;
        }
    }

    /**
    * additionalAuth provides an extra check to make sure that the user provided UUID is still valid
    **/
    public function additionalAuth(user: User, onSuccess: Void->Void, onFailure: String->String->Void){
        var db = saturn.getRedisClient();

        // Bit circular this will end up calling this.isUserAuthenticated if you follow the call in SaturnServer.hx
        saturn.isUserAuthenticated(user, function(authUser : User){
            if(authUser != null){
                onSuccess();
            }else{
                onFailure('On Error', 'invalid_token');
            }
        });
    }

    /**
    *  decryptUserPassword returns a new User object with the password decrypted
    **/
    public function decryptUserPassword(user : Dynamic, cb: String->Dynamic->Void){
        var crypto = Node.require('crypto');

        var dBuffer :Dynamic = js.Node.NodeBuffer;

        var parts = user.password.split(':');

        var decipher = crypto.createDecipheriv(config.algorithm, new js.Node.NodeBuffer(config.encrypt_password), dBuffer.from(parts[0],'hex'));
        var dec :String = decipher.update(parts[1],'hex','utf8');
        dec += decipher.final('utf8');

        var userClone = new User();

        userClone.firstname = user.firstname;
        userClone.lastname = user.lastname;
        userClone.password = dec;
        userClone.username = user.username;

        cb(null, userClone);
    }

    /**
    * isUserAuthenticated checks that user.uuid is present in the Redis database
    *
    * Removing user UUID tokens from the redis database is how we invalidate tokens outside of expiry times.
    **/
    public function isUserAuthenticated(user : User, cb : User->Void){
        if(user == null){
            cb(null);
        }else{
            var db = saturn.getRedisClient();

            db.get('USER_UUID: ' + user.uuid, function(err, reply){
                if(err || reply == null){
                    cb(null);
                }else{
                    cb(user);
                }
            });
        }
    }
}