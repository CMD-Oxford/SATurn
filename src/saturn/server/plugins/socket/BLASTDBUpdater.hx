/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket;

import saturn.core.domain.SgcVector;
import saturn.core.domain.SgcTarget;
import saturn.core.domain.SgcEntryClone;
import saturn.core.DNA;
import saturn.core.domain.SgcAllele;
import saturn.client.core.CommonCore;
import saturn.core.domain.SgcConstruct;

import com.dongxiguo.continuation.Continuation;
import js.Node.NodePath;
import js.Node;
import saturn.app.SaturnServer;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
class BLASTDBUpdater  extends QueuePlugin{
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);
    }

    override public function processRequest(job, done, cb){
        CommonCore.getDefaultProvider(function(err, provider){
            var database = job.data.database;

            var idField = null;
            var sequenceColumn = null;
            var tableName = null;
            var clazz :Dynamic = null;
            var dbType = null;
            var databasePath = null;
            var model = null;

            var databases :Map<String,Map<String,Dynamic>> = [
                'construct_protein' => [
                    'clazz'=>SgcConstruct,
                    'type'=> 'prot',
                    'sequenceAttribute'=> 'proteinSeq',
                    'databasePath'=>'databases/constructs_protein.fasta'
                ],
                'construct_protein_no_tag' => [
                    'clazz'=>SgcConstruct,
                    'type'=> 'prot',
                    'sequenceAttribute'=> 'proteinSeqNoTag',
                    'databasePath'=>'databases/constructs_protein_no_tag.fasta'
                ],
                'construct_nucleotide' => [
                    'clazz'=>SgcConstruct,
                    'type'=> 'nucl',
                    'sequenceAttribute'=> 'dnaSeq',
                    'databasePath'=>'databases/constructs_nucleotide.fasta'
                ],
                'allele_nucleotide' => [
                    'clazz'=>SgcAllele,
                    'type'=> 'nucl',
                    'sequenceAttribute'=> 'dnaSeq',
                    'databasePath'=>'databases/alleles_nucleotide.fasta'
                ],
                'allele_protein' => [
                    'clazz'=>SgcAllele,
                    'type'=> 'prot',
                    'sequenceAttribute'=> 'proteinSeq',
                    'databasePath'=>'databases/alleles_protein.fasta'
                ],
                'entryclone_protein' => [
                    'clazz'=>SgcEntryClone,
                    'type'=> 'prot',
                    'sequenceAttribute'=> 'proteinSeq',
                    'databasePath'=>'databases/entryclones_protein.fasta'
                ],
                'entryclone_nucleotide' => [
                    'clazz'=>SgcEntryClone,
                    'type'=> 'nucl',
                    'sequenceAttribute'=> 'dnaSeq',
                    'databasePath'=>'databases/entryclones_nucleotide.fasta'
                ],
                'target_nucleotide' => [
                    'clazz'=>SgcTarget,
                    'type'=> 'nucl',
                    'sequenceAttribute'=> 'dnaSeq',
                    'databasePath'=>'databases/targets_nucleotide.fasta'
                ],
                'target_protein' => [
                    'clazz'=>SgcTarget,
                    'type'=> 'prot',
                    'sequenceAttribute'=> 'protSeq',
                    'databasePath'=>'databases/targets_nucleotide.fasta'
                ],
                'vector_nucleotide' => [
                    'clazz'=>SgcVector,
                    'type'=> 'nucl',
                    'sequenceAttribute'=> 'sequence',
                    'databasePath'=>'databases/vectors_nucleotide.fasta'
                ]
            ];

            if(databases.exists(database)){
                var config = databases.get(database);

                clazz = config.get('clazz');

                model = provider.getModel(clazz);

                dbType = config.get('type');

                sequenceColumn = model.modelAtrributeToRDBMS(config.get('sequenceAttribute'));

                databasePath = config.get('databasePath');
            }else{
                handleError(job, 'Database name invalid', done);
                return;
            }

            tableName = model.getTableName();

            idField = model.getFirstKey_rdbms();

            var fs_module = Node.require('fs');

            var stream = fs_module.createWriteStream(databasePath,{flags:'w'});

            provider.getObjects(clazz, function(objects: Array<Dynamic>, err: String){
                if(err != null){
                    handleError(job, err, done);
                    return;
                }

                for(object in objects){
                    var id = Reflect.field(object, idField);
                    var sequence = Reflect.field(object, sequenceColumn);

                    if(database == 'entryclone_protein'){
                        sequence = new DNA(sequence).getFrameTranslation(GeneticCodes.STANDARD, Frame.ONE);
                    }

                    stream.write('>'+id+'\n'+sequence+'\n');
                }

                stream.on('finish', function(){
                    var progName = 'bin/deployed_bin/makeblastdb.exe';
                    var args = [ '-in', databasePath, '-dbtype', dbType];

                    var proc : NodeChildProcess = Node.child_process.spawn(progName,args);

                    proc.stderr.on('data', function(error){
                        Node.console.log(error.toString());
                    });

                    proc.stdout.on('data', function(error){
                        Node.console.log(error.toString());
                    });

                    proc.on('close', function(code, signal){
                        if(code == "0"){
                            Node.console.info('BLASTDB update complete');

                            if(signal != null){
                                handleError(job, signal, done);
                            }else{
                                sendJson(job, {}, done);
                            }
                        }else{
                            handleError(job,'An unexpected exception has occurred (' + this.saturn.getStandardErrorCode() + ')', done);
                        }
                    });
                });

                stream.end();
            });

        });
    }
}