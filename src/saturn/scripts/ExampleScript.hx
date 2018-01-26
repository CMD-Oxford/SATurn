/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.scripts;

import saturn.core.EntityType;
import saturn.core.domain.Molecule;
import saturn.core.ReactionRole;
import saturn.core.ReactionComponent;
import saturn.core.ReactionType;
import saturn.core.Reaction;
import saturn.core.Protein;
import saturn.core.EUtils;
import saturn.db.DefaultProvider;
import saturn.db.DefaultProvider;
import saturn.db.BatchFetch;
import saturn.db.Model;
import saturn.core.domain.MoleculeAnnotation;
import saturn.core.domain.DataSource;
import saturn.core.domain.Entity;
import saturn.workflow.DBtoFASTA.DBtoFASTAConfig;
import saturn.workflow.DBtoFASTA.SequenceType;

import saturn.workflow.HMMer.HMMerConfig;
import saturn.workflow.HMMer.HMMerProgram;
import saturn.workflow.Chain;

import saturn.db.Model;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class ExampleScript extends BaseScript{
    @:async override function run(){
        print('Starting');

        /*var entity = new Entity();
        entity.entityId = 'BRD4A';

        var referent = new Entity();
        referent.entityId = 'POLD2A';

        var mw = new MoleculeAnnotation();
        mw.entity = entity;
        mw.referent = referent;

        var p : DefaultProvider = cast(provider,DefaultProvider);
        p.attach([mw], false, function(err : String){
            print(mw.entityId);
            print(mw.labelId);
        });

        print(Model.extractField(mw, 'entity.entityId'));*/

        /*Protein.insertTranslation('DNA_TEST11','ATGC', 'TESTDB', 'PROT_TEST11', 'MSSS', 'TESTDB', '7157', 'GENE', function(err : String){
            debug(err);
        });*/
        //eutilsInsertTest();

        /*EUtils.getGeneInfo(7157, function(err : String, info : Dynamic){
            debug(err);
            debug(info);
        });*/

        //chain2();
    }

    public function reactionInsertTest(){
        var dna = new Entity();
        dna.entityId = 'DNA_TEST2';
        dna.source = new DataSource();
        dna.source.name = 'TESTDB';
        dna.entityType = new EntityType();
        dna.entityType.name = 'DNA';

        var dna_mol = new Molecule();
        dna_mol.entity = dna;
        dna_mol.sequence = 'ATGC';

        var prot = new Entity();
        prot.entityId = 'PROT_TEST2';
        prot.source = new DataSource();
        prot.source.name = 'TESTDB';
        prot.entityType = new EntityType();
        prot.entityType.name = 'PROTEIN';

        var prot_mol = new Molecule();
        prot_mol.entity = prot;
        prot_mol.sequence = 'MSSSS';

        var reaction = new Reaction();
        reaction.name = 'TESTA';
        reaction.reactionType = new ReactionType();
        reaction.reactionType.name = 'TRANSLATION';

        var reactionComp = new ReactionComponent();
        reactionComp.entity = dna;
        reactionComp.reactionRole = new ReactionRole();
        reactionComp.reactionRole.name = 'TEMPLATE';
        reactionComp.reaction = reaction;
        reactionComp.position = 1;

        debug('Inserting DNA');
        provider.insertObjects([dna], function(err : String){
            if(err != null){
                debug(err);
            }else{
                provider.insertObjects([dna_mol], function(err : String){
                    if(err != null){
                        debug(err);
                    }else{
                        debug('Inserting reaction');
                        provider.insertObjects([reaction], function(err : String){
                            if(err != null){
                                debug(err);
                            }else{
                                debug('Inserting reaction component');
                                provider.insertObjects([reactionComp], function(err : String){
                                    if(err != null){
                                        debug(err);
                                    }else{
                                        debug('Inserting protein');
                                        provider.insertObjects([prot], function(err : String){
                                            if(err != null){
                                                debug(err);
                                            }else{
                                                provider.insertObjects([prot_mol], function(err : String){
                                                    if(err != null){
                                                        debug(err);
                                                    }else{
                                                        print('Success');
                                                    }
                                                });
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    }

    public function eutilsInsertTest(){
        EUtils.getProteinsForGene(7158, function(err : String, objs : Array<Protein>){
            if(err != null){
                debug(err);
            }else{
                var run = null;
                run = function(){
                    if(objs.length == 0){
                        return;
                    }

                    var protein = objs.pop();

                    debug('Inserting: ' + protein.getMoleculeName());

                    Protein.insertTranslation(
                        protein.getDNA().getMoleculeName(),
                        protein.getDNA().getSequence(),
                        protein.getDNA().getAlternativeName(),
                        'NUCLEOTIDE',
                        protein.getMoleculeName(),
                        protein.getAlternativeName(),
                        protein.getSequence(),
                        'PROTEIN',
                        '7158',
                        'GENE',
                        function(err : String){
                            if(err != null){
                                debug(err);
                            }else{
                                run();
                            }
                        }
                    );
                };

                run();
            }
        });
    }

    public function eutilsTest(){
        EUtils.getProteinsForGene(7157, function(err : String, objs : Array<Protein>){
            debug(objs[0].getMoleculeName());
            debug(objs[0].getDNA().getSequence());
        });
    }

    public function testTranslationInsert(){

    }

    public function testAttach2(){
        var p : DefaultProvider = cast(provider,DefaultProvider);

        var db = new DataSource();
        db.name = 'TESTDB2';

        var entity = new Entity();
        entity.entityId = 'TEST_ENTITY3';
        entity.source = db;

        p.insert(db, function(err : String){
            if(err == null){
                debug(db.id);

                p.insert(entity, function(err : String){
                    if(err == null){
                        debug(entity.dataSourceId);
                    }else{
                        debug(err);
                    }
                });
            }else{
                debug(err);
            }
        });
    }

    public function testAttach(){
        var p : DefaultProvider = cast(provider,DefaultProvider);

        var entity = new Entity();
        entity.entityId = 'BRD4A';

        var db = new DataSource();
        db.name = 'PFAM';

        entity.source = db;

        print('Before attach: ' + entity.id);

        p.attach([entity], false, function(err : String){
            debug(err);
            print('After attach: ' + entity.id);
            print('DB: ' + db.id);
            print('DB.entity: ' + entity.dataSourceId);
        });
    }

    public function testAppendFetch(){
        var bf = new BatchFetch(function(obj, err){
            debug(err);
        });

        bf.append('BRD4A', 'entityId', Entity, function(obj : Entity){
            print('Hello World');
        });

        bf.append('BRD4A', 'entityId', Entity, function(obj : Entity){
            print('Hello World2');
            print(obj.entityId);
            print(obj.id);
        });

        bf.onComplete = function(){
            print('Finished');
        }

        bf.execute();
    }

    public function test(){
        provider.getByValues([Std.string(243)], Entity, 'dataSourceId', function(objs : Array<Entity>, error : String){
            debug('Getting existing entities');
            if(error != null){
                die('An error ocurred retrieving Pfam entities\n'+error);
            }else{
                if(objs != null){
                    for(obj in objs){
                        debug(obj.entityId + '/' + obj.id);
                    }
                }

                //debug('Fetched ' + objs);
                debug(error);
            }
        });
    }

    public function chain2(){
        var chain = new Chain();

        var config = new HMMerConfig(HMMerProgram.HMMSEARCH);
        config.setFastaFilePath('examples/brd4a.fasta');

        config.setHMMPath('database/Pfam-A.hmm');

        chain.add('saturn.workflow.HMMer.query', config);

        var config2 = new HMMerConfig(HMMerProgram.HMMUPLOAD);

        chain.add('saturn.workflow.HMMer.query', config2);

        chain.start(function(error : Dynamic){
            debug(error);
        });
    }

    public function chain1(){
        var chain = new Chain();

        var dbConfig = new DBtoFASTAConfig('SGCTARGET',SequenceType.PROTEIN);
        //dbConfig.setLimit(100);

        chain.add('saturn.workflow.DBtoFASTA.query', dbConfig);

        var config = new HMMerConfig(HMMerProgram.HMMSEARCH);

        config.setHMMPath('database/Pfam-A.hmm');

        chain.add('saturn.workflow.HMMer.query', config);

        var config2 = new HMMerConfig(HMMerProgram.HMMUPLOAD);

        chain.add('saturn.workflow.HMMer.query', config2);

        chain.start(function(error : Dynamic){
            debug(error);
        });
    }
}
