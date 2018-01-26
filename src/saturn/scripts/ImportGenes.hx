/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.scripts;

import js.Node.NodeErr;
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
class ImportGenes extends BaseScript{
    var gene_path : String;

    var geneList : Array<String>;

    override function run(cb){
        print('Starting');

        var skipped = new Array<String>();

        var genesToProcess = 0;
        var genes = new Array<String>();
        var fileRead = false;

        var retries = 0;
        var retrylimit = 5;

        var runner = null;

        runner = function(){
            if(genes.length == 0 && fileRead){
                print('Skipped: ' + skipped.toString());

                if(skipped.length > 0 && retries != retrylimit){
                    retries++;

                    genes = skipped;

                    skipped = new Array<String>();

                    runner();
                }else{
                    cb();
                    return;
                }
            }else if(genes.length > 0){
                var gene = genes.pop();

                print('Fetching proteins for : ' + gene);

                EUtils.getProteinsForGene(Std.parseInt(gene), function(err : String, objs : Array<Protein>){
                    if(err != null){
                        skipped.push(gene);

                        debug('Retrieval error - ' + err);
                        runner();
                    }else{
                        print('Fetched ' + objs.length + ' proteins for  ' + gene);

                        var run = null;

                        var protsToInsert = 0;

                        run = function(){
                            if(objs.length == 0){

                                return;
                            }

                            protsToInsert++;

                            var protein = objs.pop();

                            print('Inserting ' + protein.getMoleculeName() + ' for ' + gene);

                            Protein.insertTranslation(
                                protein.getDNA().getMoleculeName(),
                                protein.getDNA().getAlternativeName(),
                                protein.getDNA().getSequence(),
                                'NUCLEOTIDE',
                                protein.getMoleculeName(),
                                protein.getAlternativeName(),
                                protein.getSequence(),
                                'PROTEIN',
                                gene,
                                'GENE',
                                function(err : String){
                                    protsToInsert--;

                                    if(objs.length == 0 && protsToInsert == 0){
                                        runner();
                                    }else{
                                        run();
                                    }
                                }
                            );
                        };

                        run();
                    }
                });
            }else{
                haxe.Timer.delay(runner, 1000);
            }
        }

        runner();

        open(gene_path, function(err : NodeErr, line : String){
            if(err != null){
                debug('Error: ' + err); cb(); return;
            }else if(line != null){
                if(line != ''){
                    var gene = line;

                    genes.push(gene);
                }
            }else{
                     print('Input file read (please wait....)');

                fileRead = true;
            }
        });
    }

    @:async override public function usage(){
        if(getArgCount() != 1){
            die('File containing NCBI GENE IDs (new line separated)');
        }else{
            gene_path = getArg(1);

            print(gene_path);
        }
    }
}
