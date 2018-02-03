/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.mapping;
import saturn.core.Util;
class SGCSQLite extends SGC{
    public function new() {
        super();
        Util.debug('Loading SQLite');
    }

    override public function buildModels(){
        super.buildModels();

        Util.debug('Adding flag');
        models.get('saturn.app.SaturnClient').get('options').get('flags').set('NO_LOGIN', true);

        models.set('saturn.core.domain.SgcTarget',
            [
                'fields'=>[
                    'targetId' => 'TARGET_ID',
                    'id' => 'PKEY',
                    'gi' => 'GENBANK_ID',
                    'dnaSeq' => 'DNASEQ',
                    'proteinSeq' => 'PROTSEQ'
                ],
                'indexes'=>[
                    'targetId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'TARGET',
                    'human_name' => 'Target',
                    'human_name_plural' => 'Targets'
                ],
                'model' => [
                    'Target ID' => 'targetId',
                    'Genbank ID' => 'gi',
                    'Protein Sequence' => 'proteinSeq',
                    '__HIDDEN__PKEY__' => 'id'
                ],
                'fields.synthetic' =>[
                    'proteinSequenceObj' => ['field' => 'proteinSeq', 'class'=>'saturn.core.Protein', 'fk_field'=> null]
                ],
                //Disabled until we integrate custom code into generic search infrastructure
                'search' => [
                    'targetId' => null
                ],
                'programs' =>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'options' => [
                    'id_pattern' => '.*',
                    'alias' => 'Target',
                    'file.new.label'=>'Target',
                    'icon' => 'dna_conical_16.png',
                    'auto_activate' => '3'
                ]
            ]
        );
    }
}
