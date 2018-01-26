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
class DisoPredPlugin extends QueuePlugin {
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);
    }

    override public function processRequest(job, done, cb){
        Node.console.info('Running DisoPred');
        runDisoPred(job, done, cb);
    }

    @:cps public function runDisoPred(job : Dynamic, done) : Void{
        var jobId = getJobId(job);

        var err, info = @await NodeTemp.open('disoPredQuery');
        if(err != null){
            handleError(job,err); return;
        }

        var buffer : NodeBuffer = new NodeBuffer( job.data.fasta );

        var err = @await Node.fs.writeFile(info.path,buffer);
        if(err != null){
            handleError(job,err); return;
        }

        var inputFileName = info.path;
        var outputFileName =  inputFileName+'.horiz_d';

        var cmd = './rundisopred';
        var dir = 'bin/disopred/unix';

        var proc : NodeChildProcess = Node.child_process.spawn(cmd,[inputFileName],{cwd:dir});

        proc.stderr.on('data', function(error){
            Node.console.log(error.toString());
        });

        proc.stdout.on('data', function(error){
            Node.console.log(error.toString());
        });

        var code= @await proc.on('close');

        if(code == "0"){
            var serveFileName : String = saturn.getRelativePublicOuputFolder() + '/' + this.saturn.pathLib.basename(outputFileName);
            var reportServeFileName : String = saturn.getRelativePublicOuputURL() + '/' + this.saturn.pathLib.basename(outputFileName);
            Node.console.log('Copying ' + outputFileName + ' to ' + serveFileName);
            var err = @await NodeFSExtra.copy(outputFileName, serveFileName);

            if(err != null){
                handleError(job,'An error has occurred making the results file available'); return;
            }

            var err_read, data = @await Node.fs.readFile(serveFileName, null);
            if(err_read!= null){
                handleError(job,'An error has occurred opening the results file'); return;
            }

            var err_temp, info = @await NodeTemp.open('psiPredQuery');
            if(err_temp != null){
                handleError(job,'An error has occurred generating a temporary file for results'); return;
            }

            var buffer : NodeBuffer = new NodeBuffer( '<html><body><pre>'+data+'</pre></body></html>' );

            var err_write = @await Node.fs.writeFile(info.path,buffer);
            if(err_write != null){
                handleError(job,'An error has occurred writing the results file'); return;
            }

            var htmlResultsFile : String = saturn.getRelativePublicOuputFolder() + '/' + this.saturn.pathLib.basename(info.path);
            var reportHtmlResultsFile : String = saturn.getRelativePublicOuputURL() + '/' + this.saturn.pathLib.basename(info.path);
            var err = @await NodeFSExtra.copy(info.path, htmlResultsFile);


            var socket = getSocket(job);
            if(socket != null){
                sendJson(job, {htmlDisoPredReport:reportHtmlResultsFile,rawHoriReport:reportServeFileName}, done);
            }else{
                handleError(job, 'Unable to locate socket for job: ' + jobId); return;
            }
        }else{
            handleError(job,'PSIPRED has returned a non-zero exit status: ' + code); return;
        }
    }
}