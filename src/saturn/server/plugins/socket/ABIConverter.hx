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
import js.Node.NodePath;
import js.Node;
import bindings.NodeTemp;

import com.dongxiguo.continuation.Continuation;
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
class ABIConverter  extends QueuePlugin{
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);
    }

    override public function processRequest(job, done, cb){
        runConverter(job, done, cb);
    }

    @:cps public function runConverter(job : Dynamic, done) : Void{
        var binaryData = new NodeBuffer(job.data.abiFile, 'base64');

        var err, binary_info = @await NodeTemp.open('abi_conversion_');
        if(err != null){
            handleError(job,err, done); return;
        }

        var err = @await Node.fs.writeFile(binary_info.path, binaryData);
        if(err != null){
            handleError(job,err, done); return;
        }

        var err, json_info = @await NodeTemp.open('abi_conversion_json_');
        if(err != null){
            handleError(job,err, done); return;
        }

        var nodePath = js.Node.path.dirname(Node.__filename);

        var progName = 'bin/deployed_bin/ABIConverter';
        var args = [binary_info.path, json_info.path];
        if(Node.os.platform() == 'win32'){
            progName = 'bin/deployed_bin/ABIConverter.exe';
            args = [binary_info.path, json_info.path];
        }

        var proc : NodeChildProcess = Node.child_process.spawn(progName,args);

        proc.stderr.on('data', function(error){
            //Node.console.log(error.toString());
        });

        proc.stdout.on('data', function(error){
            //Node.console.log(error.toString());
        });

        var code = @await proc.on('close');
        if(code == "0"){
            Node.console.info('ABI parse complete');

            var err, data = @await Node.fs.readFile(json_info.path + '_pruned_data.json', {'encoding':'utf8'});

            if(err != null){
                handleError(job,err, done);
            }else{
                Node.console.info('Sending ABI JSON');
                sendJson(job, data, done);
            }
        }else{
            handleError(job,'An unexpected exception has occurred (' + this.saturn.getStandardErrorCode() + ')', done);
        }
    }
}
