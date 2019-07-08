/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket;

import saturn.server.plugins.socket.QueuePlugin;
import bindings.NodeFSExtra;
import bindings.NodeTemp;
import js.Node;
import saturn.app.SaturnServer;
import bindings.Ext.NodeSocket;
import saturn.server.plugins.socket.core.BaseServerSocketPlugin;

import com.dongxiguo.continuation.Continuation;
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
class THMMPlugin extends QueuePlugin {
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);
    }

    override public function processRequest(job, done, cb){
        Node.console.info('Running THMM');
        runTHMM(job, done, cb);
    }

    @:cps public function runTHMM(job : Dynamic, done) : Void{
        var jobId = getJobId(job);

        var err, info = @await NodeTemp.open('tmhmmQuery');
        if(err != null){
            handleError(job,err); return;
        }

        var buffer : NodeBuffer = new NodeBuffer( job.data.fasta );

        var err = @await Node.fs.writeFile(info.path,buffer);
        if(err != null){
            handleError(job,err); return;
        }

        var inputFileName = info.path;
        var outputFileName =  inputFileName+'.formatted';

        var cmd = './runsingle_tmhmm.sh';
        var dir = 'bin/deployed_bin/tmhmm/unix';

        if(Node.os.platform() == 'win32'){
            handleError(job,'TMHMM is not supported on Windows platform', done); return;
        }

        Node.console.log('H3: ' + cmd);

        var proc : NodeChildProcess = Node.child_process.spawn(cmd,[info.path,outputFileName],{cwd:dir});

        proc.stderr.on('data', function(error){
            Node.console.log(error.toString());
        });

        proc.stdout.on('data', function(error){
            Node.console.log(error.toString());
        });

        Node.console.log('H4');

        var code= @await proc.on('close');

        if(code == "0"){
            Node.console.log('H5');

            var serveFileName : String = saturn.getRelativePublicOuputFolder() + '/' + this.saturn.pathLib.basename(outputFileName);
            var reportServeFileName : String = saturn.getRelativePublicOuputURL() + '/' + this.saturn.pathLib.basename(outputFileName);
            var err = @await NodeFSExtra.copy(outputFileName, serveFileName);

            if(err != null){
                handleError(job,'An error has occurred making the results file available', done); return;
            }

            var err_read, data = @await  Node.fs.readFile(serveFileName, null);
            if(err_read!= null){
                handleError(job,'An error has occurred opening the results file', done); return;
            }

            var err_temp, info = @await NodeTemp.open('tmhmmQuery');
            if(err_temp != null){
                handleError(job,'An error has occurred generating a temporary file for results', done); return;
            }

            var buffer : NodeBuffer = new NodeBuffer( '<html><body><pre>'+data+'</pre></body></html>' );

            var err_write = @await Node.fs.writeFile(info.path,buffer);
            if(err_write != null){
                handleError(job,'An error has occurred writing the results file');
            }else{
                var htmlResultsFile : String = saturn.getRelativePublicOuputFolder() + '/' + this.saturn.pathLib.basename(info.path) + '.html';
                var reportHtmlResultsFile : String = saturn.getRelativePublicOuputURL() + '/' + this.saturn.pathLib.basename(info.path) + '.html';

                var err = @await NodeFSExtra.copy(info.path, htmlResultsFile);

                var socket = getSocket(job);
                if(socket != null){
                    sendJson(job, {htmlTMHMMReport:reportHtmlResultsFile,rawReport:reportServeFileName}, done);
                }else{
                    handleError(job, 'Unable to locate socket for job: ' + jobId, done);
                }
            }
        }else{
            handleError(job,'PSIPRED has returned a non-zero exit status: ' + code, done);
        }
    }
}