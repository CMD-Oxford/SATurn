/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket;

import bindings.NodeFSExtra;
import bindings.NodeTemp;
import js.Node;
import saturn.app.SaturnServer;
import bindings.Ext.NodeSocket;

import com.dongxiguo.continuation.Continuation;
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
class ClustalPlugin extends QueuePlugin {
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);
    }

    override public function processRequest(job, done, cb){
        Node.console.info('Running clustalw');
        runClustal(job, done, cb);
    }

    @:cps public function runClustal(job : Dynamic, done) : Void{
        var jobId = getJobId(job);

        var err, info = @await NodeTemp.open('clustalQuery');
        if(err != null){
            handleError(job,err, done); return;
        }

        var buffer : NodeBuffer = new NodeBuffer( job.data.fasta );

        var err = @await Node.fs.writeFile(info.path,buffer);
        if(err != null){
            handleError(job,err, done);  return;
        }

        var inputFileName = info.path;
        var outputFileName =  inputFileName+'.aln';

        Node.console.log('Hello David');

        var proc : NodeChildProcess = Node.child_process.spawn('bin/deployed_bin/clustalo',["--infile="+inputFileName, "-o", outputFileName, "--outfmt=clustal"]);

        proc.stderr.on('data', function(error){
            Node.console.log(error.toString());
        });

        proc.stdout.on('data', function(error){
            Node.console.log(error.toString());
        });

        var code = @await proc.on('close');
        if(code == "0"){
            var serveFileName : String = saturn.getRelativePublicOuputFolder() + '/' + this.saturn.pathLib.basename(outputFileName) + '.txt';
            var returnPath : String = saturn.getRelativePublicOuputURL() + '/' + this.saturn.pathLib.basename(outputFileName) + '.txt';
            var err = @await NodeFSExtra.copy(outputFileName, serveFileName);

            if(err != null){
                handleError(job,'An error has occurred making the results file available', done);
            }else{
                var socket = getSocket(job);
                if(socket != null){
                    Node.console.log('FINISHED');
                    sendJson(job,{clustalReport:returnPath}, done);
                }else{
                    handleError(job, 'Unable to locate socket for job: ' + jobId, done);
                }
            }
        }else {
            handleError(job,'Clustal returned a non-zero exit status', done);
        }
    }
}