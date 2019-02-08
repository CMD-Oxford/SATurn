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

import js.Node;

import saturn.core.Util;

class MySQLAuthPlugin implements AuthenticationManager{
    var config : Dynamic;

    public function new(config){
        this.config = config;
    }

    public function authenticate(username : String, password : String, onSuccess : User->Void, onFailure : String->Void, src :Dynamic) : Void{
        var mysql = Node.require('mysql2');

        Util.debug('Connecting as ' + username + ' to ' + username + ' with password ' + password + ' on ' + config.hostname);

        var connection = mysql.createConnection({
            host: config.hostname,
            user: username,
            password: password,
            database: username
        });

        connection.on('connect',function(connect) {
            if (connect) {
                connection.query('
                    SELECT
                     *
                    FROM
                        icmdb_page_secure.V_USERS
                    WHERE
                        Name=?
                ',[username], function(err, res : Dynamic){
                    if(err){
                        Node.console.log('Error connecting');
                        onFailure('Unable to connect');
                    }else{
                        Node.console.log('Success');

                        if(res.length == 0){
                            Node.console.log('Unable to connect');
                            onFailure('Unable to connect');
                        }else{
                            var userRow = res[0];

                            var user = new User();

                            user.firstname = userRow.First_Name;
                            user.lastname = userRow.Last_Name;
                            user.email = userRow.EMail;

                            Node.console.log('Login succeded!');

                            onSuccess(user);
                        }
                    }

                    connection.end();
                });
            }else{
                Node.console.log('Unable to connect');
                onFailure('Unable to connect');
            }
        });

        connection.on('error', function(err){
            Node.console.log('Error: ' + err);
            onFailure('Unable to connect');
            //connection.end();
        });
    }
}