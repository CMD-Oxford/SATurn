/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket;

import saturn.app.SaturnServer;
import js.Node;
import bindings.Ext.NodeSocket;

import saturn.server.plugins.socket.core.BaseServerSocketPlugin;

class QueuePlugin extends BaseServerSocketPlugin{
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        this.queueName = pluginName;

        var Queue = Node.require('bull');

        this.queue = Queue(this.queueName, 'redis://' + this.saturn.getHostname() + ':' + this.saturn.getRedisPort() );

        debug('QUEUE: ' + this.queueName);

        registerListener('', onRequest);

        this.queue.process(function(job, done){
            processRequest(job, done, function(){});
        });

        this.queue.on('failed', function(job, error){
            handleError(job, error);
        });
    }

    public function onRequest(data : Dynamic, socket : NodeSocket){
        if(Reflect.hasField(data,'bioinfJobId') || Reflect.hasField(data,'msgId')){
            data.socketId = socket.id;

            this.queue.add(data);
        }else{
            socket.emit('receiveError',{error:'Invalid request, missing bioinfJobId field'});
        }
    }

    public function processRequest(job, done, cb){

    }

    override public function handleError(job, error : Dynamic, done=null){
        super.handleError(job, error, done);
    }
}
