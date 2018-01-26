/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket;

import saturn.core.FastaEntity;
import bindings.NodeFSExtra;
import bindings.NodeTemp;
import js.Node;
import saturn.app.SaturnServer;
import bindings.Ext.NodeSocket;

import com.dongxiguo.continuation.Continuation;
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
class BLASTPlugin extends QueuePlugin {
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        registerListener('database_list', sendDatabaseList);
    }

    public function sendDatabaseList(data, socket){
        var dbList = {'DNA':{},'PROT':{}};

        var dbDefs = saturn.getServerConfig().commands.sendBlastReport.arguments.BLAST_DB.allowedValues;
        var dbs = Reflect.fields(dbDefs);
        for(db in dbs){
            var dbObj = Reflect.field(dbDefs,db);
            var type = dbObj.dbtype;
            if(type == 'nucl'){
                Reflect.setField(dbList.DNA,db,'1');
            }else{
                Reflect.setField(dbList.PROT,db,'1');
            }
        }

        sendJson(data, {dbList:dbList}, null);
    }

    override public function processRequest(job, done, cb){
        runBLAST(job, done, cb);
    }

    @:cps public function runBLAST(job : Dynamic, done) : Void{
        var socket :Dynamic = getSocket(job);

        if(socket != null){
            var ip = socket.handshake.address.address;

            broadcast('global.event', {'trigger': ip, 'event': 'BLAST'});
        }

        var jobId = job.data.bioinfJobId;

        var err, info = @await NodeTemp.open('blastQuery');
        if(err != null){
            handleError(job,err, done); return;
        }

        var buffer : NodeBuffer = new NodeBuffer( job.data.fasta );

        var err = @await Node.fs.writeFile(info.path,buffer);
        if(err != null){
            handleError(job,err, done); return;
        }

        var inputFileName = info.path;
        var outputFileName =  inputFileName+'.html';

        var blastDatabase = job.data.blastDatabase;
        var fasta = job.data.fasta;

        var blastSettings :Dynamic = Reflect.field(this.saturn.localServerConfig.commands.sendBlastReport.arguments.BLAST_DB.allowedValues,blastDatabase);

        var args = ["-db", blastSettings.dbpath, "-query", inputFileName, "-out", outputFileName, '-html' ]; //'-outfmt', '5'

        var entities = FastaEntity.parseFasta(fasta);

        if(entities.length > 0){
            if(entities[0].getSequence().length < 20){
                args.push('-evalue');
                args.push('100000');

                args.push('-word_size');
                args.push('7');

                if(blastSettings.prog == 'blastn'){
                    args.push('-dust');
                    args.push('no');
                }

                Node.console.log('Applying short sequence mode');
            }
        }

        var proc : NodeChildProcess = Node.child_process.spawn('bin/'+blastSettings.prog,args);

        proc.stderr.on('data', function(error){

        });

        proc.stdout.on('data', function(error){
            
        });

        var code= @await proc.on('close');

        if(code == "0"){
            var serveFileName : String = saturn.getRelativePublicOuputFolder() + '/' + Node.require('path').basename(outputFileName) + '.html';
            var responseFile : String = saturn.getRelativePublicOuputURL() + '/' + Node.require('path').basename(outputFileName) + '.html';

            var err = @await NodeFSExtra.copy(outputFileName, serveFileName);

            if(err != null){
                handleError(job,'An error has occurred making the results file available', done); return;
            }else{

                var socket = getSocket(job);
                if(socket != null){
                    sendJson(job, {reportFile:responseFile}, done);
                }else{
                    handleError(job, 'Unable to locate socket for job: ' + jobId, done); return;
                }
            }
        }else{
            handleError(job,'BLAST failed', done); return;
        }
    }
}