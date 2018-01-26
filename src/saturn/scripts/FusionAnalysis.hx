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
import saturn.core.DNA;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class FusionAnalysis extends BaseScript{
    @:async override function run(){
        print('Starting');

        var fs = js.Node.require('fs');
        var json :Array<Dynamic> = js.Node.json.parse(fs.readFileSync('H:\\Cosmic\\fusions.json', 'utf8'));
        for(obj in json){
         //   if(obj.fusion_transcript != null && obj.fusion_transcript != ''){
                //var dna = new DNA(obj.fusion_transcript);
                //var pos = dna.getFirstStartCodonPosition(GeneticCodes.STANDARD);

                //var translation = dna.getTranslation(GeneticCodes.STANDARD, pos, true);

                //print(translation);
          //  }
        }
    }
}
