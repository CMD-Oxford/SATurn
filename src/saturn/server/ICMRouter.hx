/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server;

import js.Node;

class ICMRouter {
	
	//var theSocket : Dynamic;
	
	var nodeConsole : Dynamic;
	
	var lastCommandId : Int;
	
	var theServerSocket : Dynamic;

    var icmNodes : Array<Dynamic>;
    var jobToSocket : Map<String,Dynamic>;
	
	public function new( serverSocket ) {
        icmNodes = new Array<Dynamic>();

		nodeConsole = untyped __js__('console');
		
		lastCommandId = 0;
		
		theServerSocket = serverSocket;

        jobToSocket = new Map<String,Dynamic>();

        theServerSocket.sockets.on('connection', function (socket) {
            socket.emit('HELO socket',{});

            Node.console.log('Hello World 1');
            socket.on('registerAsICMNode', function(data){
                icmNodes.unshift(socket);

                socket.on('icmForwardResponse', function (data) {
                    var reciepent = jobToSocket.get(data.ID);
                    reciepent.emit('icmForward', data);
                });
            });

            socket.on('icmForwardCommandRequest',function(data){
                Node.console.log('===================================================================================');
                Node.console.log('===================================================================================');
                jobToSocket.set(data.ID,socket);

                if(icmNodes.length > 0 && icmNodes[0] != null){
                    icmNodes[0].emit('icmForwardCommmand', data);
                }else{
                    socket.emit('icmForward',{ID: data.ID, error: 'In Scarab click: Wizards->Advanced->MolBioLocalConnect'});
                }
            });

            socket.on('sendCommandID',function(data){
                socket.emit('recieveCommandID',{ID: 'ICMCommandID: '+nextCommandId()});
            });
        });
	}
	
	public function registerSocket( ) {
		//theSocket = socket;
		
		//var self = this;
	}
	
	public function onForwardICMResponse(data : Dynamic) {
		//nodeConsole.log('Emitting event, forward');
		//nodeConsole.log('Final forward: ' + data);
		//nodeConsole.log('Final forward ID: ' + data.ID);
		//theServerSocket.sockets.emit('icmForward', data);
	}
	
	public function onForwardICMCommand(data) {
		//nodeConsole.log('Emitting event, command forward');
		theServerSocket.sockets.emit('icmForwardCommmand', data);
	}
	
	public function testFunction(data) {
		//nodeConsole.log(data);
	}
	
	public function nextCommandId() {
		nodeConsole.log('Next command ID');
		
		lastCommandId++;
		
		var nextCommandId : Int = lastCommandId;
		
		return nextCommandId;
	}
}