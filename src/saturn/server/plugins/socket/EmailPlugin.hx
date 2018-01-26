/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket;

import bindings.Ext.NodeSocket;
import saturn.app.SaturnServer;

import saturn.server.plugins.socket.core.BaseServerSocketPlugin;

class EmailPlugin extends BaseServerSocketPlugin{
    var transporter : Dynamic;

    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        registerCommands();

        configureTransporter();
    }

    public function getConfig() : Dynamic{
        return config;
    }

    public function getTransporter() : Dynamic{
        return transporter;
    }

    private function configureTransporter(){
        var nodemailer = js.Node.require('nodemailer');

        transporter = nodemailer.createTransport({
            port: config.port,
            host: config.host,
            auth: {
                user: config.auth.user,
                pass: config.auth.password
            }
        });
    }

    public function registerCommands(){
        registerListener('test', function(data : Dynamic, socket : NodeSocket){
            var user = getSocketUserNoAuthCheck(socket);

            var email = user.email;

            transporter.sendMail({
                "sender": config.from,
                "from": config.from,
                "replyTo": email,
                "to": email,
                "subject": "Node H2IK",
                "text": "Evening!"
            }, function(err){
                debug('Email Error ' + err);
            });
        });
    }
}