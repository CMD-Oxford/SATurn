/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.core;

import saturn.app.SaturnServer;
import js.Node;
import bindings.Ext.NodeSocket;
import saturn.server.plugins.socket.core.BaseServerSocketPlugin;

class SocketPlugin extends BaseServerPlugin{

    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        startSocketServer();
    }

    public function startSocketServer(){
        var socket :Dynamic = Node.require('socket.io').listen(saturn.getServer().server, {log: true}); // log : true debug
        //socket.set('log level', 2);

        socket.set('origins', saturn.getServerConfig().origins);
        socket.set('transports',['websocket', 'polling']);

        saturn.setServerSocket(socket);
    }

}
