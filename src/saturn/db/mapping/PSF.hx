/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.mapping;

class PSF {
    /**
     * fields: instance attribute name to RDBMS column name
     * indexes: instance attributes that should be used to index retrieved objects in the local cache
     *          value indicates if the attribute is the primary key
     * model: Displayed name to instance attribute name
     * fields.synthetic: instance attribute that are represented as foreign keys but should be deconvoluted
     *                   key => attribute name
     *                   value => ' field', instance attribute which contains the FK value
     *                             'fk_field', instance attribute that 'field' corresponds to
     *                             'class', class of the FK
     * table_info:
     *             schema =>
     *             name =>
     */
    public var models : Map<String,Map<String,Map<String,Dynamic>>>;

    public function new(){
        buildModels();
    }

    public function buildModels(){
        models = [
            'saturn.core.domain.SgcConstruct'=>[
                'fields'=>[
                    'constructId' => 'CONSTRUCTID',
                    'id' => 'PKEY',
                    'proteinSeq' => 'CONSTRUCTPROTSEQ',
                    'proteinSeqNoTag' => 'CONSTRUCTPROTSEQNOTAG',
                    'dnaSeq' => 'CONSTRUCTDNASEQ',
                    'docId' => 'ELNEXP',
                    'vectorId' => 'SGCVECTOR',
                    'alleleId' => 'SGCDNAINSERT',
                    'res1Id' => 'SGCRESTRICTIONENZYME1',
                    'res2Id' => 'SGCRESTRICTIONENZYME2',
                    'constructPlateId' => 'SGCPLATE',
                    'wellId' => 'PLATEWELL',
                    'expectedMass' => 'EXPECTEDMASS',
                    'expectedMassNoTag' => 'EXPETCEDMASSNOTAG',
                    'status' => 'STATUS',
                    'location' => 'SGCLOCATION',
                    'elnId' => 'ELNEXP',
                    'constructComments' => 'CONSTRUCTCOMMENTS',
                    'person' => 'PERSON',
                    'constructStart' => 'CONSTRUCTSTART',
                    'constructStop'=> 'CONSTRUCTSTOP'
                ],
                'defaults'=> [
                    'status' => 'In progress'
                ],
                'auto_functions'=>[
                    'PERSON'=>'insert.username'
                ],
                'required'=>[
                    'wellId' => '1',
                    'constructPlateId' => '1',
                    'constructId' => '1',
                    'alleleId' => '1',
                    'vectorId' => '1'
                ],
                'indexes'=>[
                    'constructId'=>false,'id'=>true
                ],
                'model' => [
                    'Construct ID' => 'constructId',
                    'Construct Plate' => 'constructPlate.plateName',
                    'Well ID' => 'wellId',
                    'Vector ID' => 'vector.vectorId',
                    'Allele ID' => 'allele.alleleId',
                    'Status' => 'status',
                    'Protein Sequence' => 'proteinSeq',
                    'Expected Mass' => 'expectedMass',
                    'Restriction Site 1' => 'res1.enzymeName',
                    'Restriction Site 2' => 'res2.enzymeName',
                    'Protein Sequence (No Tag)' => 'proteinSeqNoTag',
                    'Expected Mass (No Tag)' => 'expectedMassNoTag',
                    'Construct DNA Sequence' => 'dnaSeq',
                    'Location' => 'location',
                    'ELN ID' => 'elnId',
                    'Construct Comments' => 'constructComments',
                    'Creator' => 'person',
                    'Construct Start' => 'constructStart',
                    'Construct Stop' => 'constructStop',
                    '__HIDDEN__PKEY__' => 'id'
                ],
                'fields.synthetic' =>[
                    'allele' => [ 'field' => 'alleleId', 'class' => 'saturn.core.domain.SgcAllele', 'fk_field' => 'alleleId' ],
                    'vector' => [ 'field' => 'vectorId', 'class' => 'saturn.core.domain.SgcVector', 'fk_field' => 'vectorId' ],
                    'res1' => [ 'field' => 'res1Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'enzymeName'],
                    'res2' => [ 'field' => 'res2Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'enzymeName'],
                    'constructPlate' => [ 'field' => 'constructPlateId', 'class' => 'saturn.core.domain.SgcConstructPlate', 'fk_field' => 'plateName' ],
                    'proteinSequenceObj' => ['field' => 'proteinSeq', 'class'=>'saturn.core.Protein', 'fk_field'=> null],
                    'proteinSequenceNoTagObj' => ['field' => 'proteinSeqNoTag', 'class'=>'saturn.core.Protein', 'fk_field'=> null]
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'CONSTRUCT'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'search'=>[
                    'constructId' => true
                ],
                'options'=>[
                    'id_pattern' => '-c',
                    'alias' => 'Construct',
                    'file.new.label'=>'Construct',
                    'icon' => 'dna_conical_16.png',
                    'auto_activate' => '3',
                    'actions' => [
                        'search_bar' => [
                            'protein' => [
                                'user_suffix' => 'Protein',
                                'function' => 'saturn.core.domain.SgcConstruct.loadProtein',
                                'icon' => 'structure_16.png'
                            ],
                            'proteinNoTag' => [
                                'user_suffix' => 'Protein No Tag',
                                'function' => 'saturn.core.domain.SgcConstruct.loadProteinNoTag',
                                'icon' => 'structure_16.png'
                            ]
                        ]
                    ]
                ]
            ],
            /*'saturn.core.domain.SgcConstructStatus' => [
                'fields' => [
                    'constructPkey' => 'SGCCONSTRUCT_PKEY',
                    'status' => 'STATUS'
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'CONSTR_STATUS_SNAPSHOT'
                ],
                'indexes'=>[
                    'constructPkey'=>true
                ]
            ],*/
            'saturn.core.domain.SgcAllele'=>[
                'fields'=>[
                    'alleleId'=>'DNAINSERTID',
                    'allelePlateId' => 'SGCPLATE',
                    'id' => 'PKEY',
                    'entryCloneId' => 'SGCENTRYCLONE',
                    'forwardPrimerId' => 'SGCPRIMER',
                    'reversePrimerId' => 'SGCPRIMERREV',
                    'dnaSeq' => 'DNAINSERTSEQUENCERAW',
                    'proteinSeq' => 'DNAINSERTPROTSEQ',
                    'status' => 'DNAINSERTSTATUS',
                    'location' => 'SGCLOCATION',
                    'comments' => 'COMMENTS',
                    'elnId' => 'ELNEXP',
                    'dateStamp' => 'DATESTAMP',
                    'person' => 'PERSON',
                    'plateWell' => 'PLATEWELL',
                    'dnaSeqLen' => 'DNAINSERTSEQLENGTH',
                    'complex' => 'COMPLEX',
                    'domainSummary' => 'DOMAINSUMMARY',
                    'domainStartDelta' => 'DOMAINSTARTDELTA',
                    'domainStopDelta' => 'DOMAINSTOPDELTA',
                    'containsPharmaDomain' => 'CONTAINSPHARMADOMAIN',
                    'domainSummaryLong' => 'DOMAINSUMMARYLONG',
                    'impPI' => 'IMPPI',
                    'alleleStatus' => 'ALLELE_STATUS'
                ],
                'defaults'=> [
                    'status' => 'In process'
                ],
                'model' =>[
                    'DNA Insert ID' => 'alleleId',
                    'Plate' => 'plate.plateName',
                    'Entry Clone ID' => 'entryClone.entryCloneId',
                    'Forward Primer ID' => 'forwardPrimer.primerId',
                    'Reverse Primer ID' => 'reversePrimer.primerId',
                    'DNA Sequence' => 'dnaSeq',
                    'Protein Sequence' => 'proteinSeq',
                    'Status' => 'status',
                    'Location' => 'location',
                    'Comments' => 'comments',
                    'ELN ID' => 'elnId',
                    'Date Record' => 'dateStamp',
                    'Person' => 'person',
                    'Plate Well' => 'plateWell',
                    'DNA Length' => 'dnaSeqLen',
                    'Complex' => 'complex',
                    'Domain Summary' => 'domainSummary',
                    'Domain  Start Delta' => 'domainStartDelta',
                    'Domain Stop Delta' => 'domainStopDelta',
                    'Contains Pharma Domain' => 'containsPharmaDomain',
                    'Domain Summary Long' => 'domainSummaryLong',
                    'IMP PI' => 'impPI',
                    '__HIDDEN__PKEY__' => 'id'
                ],
                'indexes'=>[
                    'alleleId'=>false,
                    'id'=>true
                ],
                'fields.synthetic' =>[
                    'entryClone' => [ 'field' => 'entryCloneId', 'class' => 'saturn.core.domain.SgcEntryClone', 'fk_field' => 'entryCloneId' ],
                    'forwardPrimer' => [ 'field' => 'forwardPrimerId', 'class' => 'saturn.core.domain.SgcForwardPrimer', 'fk_field' => 'primerId' ],
                    'reversePrimer' => [ 'field' => 'reversePrimerId', 'class' => 'saturn.core.domain.SgcReversePrimer', 'fk_field' => 'primerId' ],
                    'plate' => [ 'field' => 'allelePlateId', 'class' => 'saturn.core.domain.SgcAllelePlate', 'fk_field' => 'plateName' ],
                    'proteinSequenceObj' => ['field' => 'proteinSeq', 'class'=>'saturn.core.Protein', 'fk_field'=> null]
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'DNAINSERT'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'search'=>[
                    'alleleId' => true
                ],
                'options'=>[
                    'id_pattern' => '-a',
                    'alias' => 'Allele',
                    'file.new.label'=>'Allele',
                    'icon' => 'dna_conical_16.png',
                    'auto_activate' => '3',
                    'actions' => [
                        'search_bar' => [
                            'protein' => [
                                'user_suffix' => 'Protein',
                                'function' => 'saturn.core.domain.SgcAllele.loadProtein',
                                'icon' => 'structure_16.png'
                            ]
                        ]
                    ]
                ]
            ],
            'saturn.core.domain.SgcEntryClone'=>[
                'fields'=>[
                    'entryCloneId'=>'ENTRYCLONEID',
                    'id' => 'PKEY',
                    'dnaSeq' => 'DNARAWSEQUENCE',
                    'targetId' => 'SGCTARGET_PKEY',
                    'seqSource' => 'SEQSOURCE',
                    'sourceId' => 'SOURCEID',
                    'sequenceConfirmed'=> 'SEQUENCECONFIRMED',
                    'elnId' => 'ELNEXPERIMENTID'
                ],
                'indexes'=>[
                    'entryCloneId'=>false,
                    'id'=>true
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'search'=>[
                    'entryCloneId' => true
                ],
                'options'=>[
                    'id_pattern' => '-s',
                    'canSave'=>[
                        'saturn.client.programs.DNASequenceEditor' => true,
                        'saturn.client.programs.ProteinSequenceEditor' => true
                    ],
                    'alias' => 'Entry Clone',
                    'file.new.label'=>'Entry Clone',
                    'icon' => 'dna_conical_16.png',
                    'auto_activate' => '3',
                    'actions' => [
                        'search_bar' => [
                            'translation' => [
                                'user_suffix' => 'Translation',
                                'function' => 'saturn.core.domain.SgcEntryClone.loadTranslation',
                                'icon' => 'structure_16.png'
                            ]
                        ]
                    ]
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'ENTRYCLONE'
                ],
                'model'=>[
                    'Entry Clone ID' => 'entryCloneId',
                    'Target ID' => 'target.targetId'
                ],
                'fields.synthetic' =>[
                    'target' => [ 'field' => 'targetId', 'class' => 'saturn.core.domain.SgcTarget', 'fk_field' => 'id' ]
                ]
            ],
            'saturn.core.domain.SgcRestrictionSite'=>[
                'fields'=>[
                    'enzymeName' => 'RESTRICTIONENZYMENAME',
                    'cutSequence' => 'RESTRICTIONENZYMESEQUENCERAW',
                    'id' => 'PKEY'
                ],
                'indexes'=>[
                    'enzymeName'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'RESTRICTIONENZYME'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'model'=>[
                    'Enzyme Name'=>'enzymeName'
                ],
                'options'=>[
                    'alias'=>'Restriction site',
                    'file.new.label'=>'Restriction Site',
                ],
                'search' => [
                    'enzymeName'=>null
                ]
            ],
            'saturn.core.domain.SgcVector'=>[
                'fields'=>[
                    'vectorId'=>'VECTORNAME',
                    'id'=>'PKEY',
                    'sequence'=>'VECTORSEQUENCERAW',
                    'vectorComments'=>'VECTORCOMMENTS',
                    'proteaseName'=>'PROTEASENAME',
                    'proteaseCutSequence'=>'PROTEASECUTSEQUENCE',
                    'proteaseProduct'=>'PROTEASEPRODUCT',
                    'antibiotic'=>'ANTIBIOTIC',
                    'organism'=>'ORGANISM',
                    'res1Id'=>'SGCRESTRICTENZ1',
                    'res2Id'=>'SGCRESTRICTENZ2',
                    'addStopCodon'=>'REQUIRES_STOP_CODON',
                    'requiredForwardExtension'=>'REQUIRED_EXTENSION_FORWARD',
                    'requiredReverseExtension'=>'REQUIRED_EXTENSION_REVERSE'
                ],
                'search' => [
                    'vectorId'=>null
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'indexes'=>[
                    'vectorId'=>false,
                    'id'=>true
                ],
                'fields.synthetic' =>[
                    'res1' => [ 'field' => 'res1Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'enzymeName' ],
                    'res2' => [ 'field' => 'res2Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'enzymeName' ]
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'VECTOR'
                ],
                'options'=>[
                    'auto_activate'=> '3',
                    'alias' => 'Vector',
                    'file.new.label'=>'Vector'
                ],
                'model' => [
                    'Name' => 'vectorId',
                    'Comments' => 'vectorComments',
                    'Protease' => 'proteaseName',
                    'Protease cut sequence' => 'proteaseCutSequence',
                    'Protease product' => 'proteaseProduct',
                    'Forward extension' => 'requiredForwardExtension',
                    'Reverse extension' => 'requiredReverseExtension',
                    'Restriction site 1' => 'res1.enzymeName',
                    'Restriction site 2' => 'res2.enzymeName',
		    'Add Stop Codon' => 'addStopCodon'
                ]
            ],
            'saturn.core.domain.SgcForwardPrimer'=>[
                'fields'=>[
                    'primerId' => 'PRIMERID',
                    'id' => 'PKEY',
                    'dnaSequence' => 'PRIMERRAWSEQUENCE'
                ],
                'indexes'=>[
                    'primerId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'PRIMER'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'search'=>[
                    'primerId' => true
                ],
                'options'=>[
                    'alias' => 'Forward Primer',
                    'file.new.label'=>'Forward Primer',
                    'icon' => 'dna_conical_16.png'
                ],
                'model'=>[
                    'Primer ID' => 'primerId'
                ]
            ],
            'saturn.core.domain.SgcReversePrimer'=>[
                'fields'=>[
                    'primerId' => 'PRIMERREVID',
                    'id' => 'PKEY',
                    'dnaSequence' => 'PRIMERRAWSEQUENCE'
                ],
                'indexes'=>[
                    'primerId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'PRIMERREV'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'search'=>[
                    'primerId' => true
                ],
                'options'=>[
                    'alias' => 'Reverse Primer',
                    'file.new.label'=>'Reverse Primer',
                    'icon' => 'dna_conical_16.png'
                ],
                'model'=>[
                    'Primer ID' => 'primerId'
                ]
            ],
            'saturn.core.domain.SgcPurification'=>[
                'fields'=>[
                    'purificationId' => 'PURIFICATIONID',
                    'id' => 'PKEY',
                    'expressionId' => 'EXPRESSION_PKEY',
                    'column' => 'COLUMN1',
                    'elnId' => 'ELNEXP',
                    'comments'=> 'COMMENTS'
                ],
                'indexes'=>[
                    'purificationId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'PURIFICATION'
                ],
                'programs'=>[
                    'saturn.client.programs.EmptyViewer' => true
                ],
                'fields.synthetic' =>[
                    'expression' => [ 'field' => 'expressionId', 'class' => 'saturn.core.domain.SgcExpression', 'fk_field' => 'id' ]
                ],
                'model'=>[
                    'Purification ID' => 'purificationId',
                    'Expression ID' => 'expressionId',
                    'ELN ID'=> 'elnId',
                    'Comments' => 'comments'
                ],
                'options'=>[
                    'alias' => 'Purifications',
                    'file.new.label'=>'Purification',
                    'icon' => 'dna_conical_16.png',
                    'auto_activate'=> '3'
                ],
            ],
            'saturn.core.domain.SgcClone'=>[
                'fields'=>[
                    'cloneId' => 'CLONE_ID',
                    'id' => 'PKEY',
                    'constructId' => 'SGCCONSTRUCT1_PKEY',
                    'elnId' => 'ELNEXP',
                    'comments'=> 'COMMENTS'
                ],
                'indexes'=>[
                    'cloneId'=>false,
                    'id'=>true
                ],
                'options'=>[
                    'alias' => 'Clones',
                    'file.new.label'=>'Clone',
                    'icon' => 'dna_conical_16.png',
                    'auto_activate'=> '3'
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'CLONE'
                ],
                'programs'=>[
                    'saturn.client.programs.EmptyViewer' => true
                ],
                'fields.synthetic' =>[
                    'construct' => [ 'field' => 'constructId', 'class' => 'saturn.core.domain.SgcConstruct', 'fk_field' => 'id' ]
                ],
                'model'=>[
                    'Clone ID' => 'cloneId',
                    'Construct ID' => 'construct.constructId',
                    'ELN ID'=> 'elnId',
                    'Comments' => 'comments'
                ]
            ],
            'saturn.core.domain.SgcExpression'=>[
                'fields'=>[
                    'expressionId' => 'EXPRESSION_ID',
                    'id' => 'PKEY',
                    'cloneId' => 'SGCCLONE_PKEY',
                    'elnId' => 'ELNEXP',
                    'comments'=> 'COMMENTS'
                ],
                'indexes'=>[
                    'expressionId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'EXPRESSIONSCREENING'
                ],
                'programs'=>[
                    'saturn.client.programs.EmptyViewer' => true
                ],
                'fields.synthetic' =>[
                    'clone' => [ 'field' => 'cloneId', 'class' => 'saturn.core.domain.SgcClone', 'fk_field' => 'id' ]
                ],
                'options'=>[
                    'alias' => 'Expressions',
                    'file.new.label'=>'Expression',
                    'icon' => 'dna_conical_16.png',
                    'auto_activate'=> '3'
                ],
                'model'=>[
                    'Expression ID' => 'expressionId',
                    'Clone ID' => 'clone.cloneId',
                    'ELN ID'=>'elnId',
                    'Comments'=>'comments'
                ]
            ],
            'saturn.core.domain.SgcTarget'=>[
                'fields'=>[
                    'targetId' => 'TARGETNAME',
                    'id' => 'PKEY',
                    'gi' => 'GENBANK_ID',
                    'geneId' => 'NCBIGENEID',
                    'proteinSeq' => 'PROTEINSEQUENCE',
                    'dnaSeq' => 'NUCLEOTIDESEQUENCE',
                    'activeStatus' => 'ACTIVESTATUS',
                    'pi' => 'PI',
                    'comments' => 'COMMENTS'
                ],
                'indexes'=>[
                    'targetId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'TARGET',
                    'human_name' => 'Target',
                    'human_name_plural' => 'Targets'
                ],
                'model' => [
                    'Target ID' => 'targetId',
                    'Genbank ID' => 'gi',
                    'DNA Sequence' => 'dnaSeq',
                    'Protein Sequence' => 'proteinSeq',
                    '__HIDDEN__PKEY__' => 'id'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'fields.synthetic' =>[
                    'proteinSequenceObj' => ['field' => 'proteinSeq', 'class'=>'saturn.core.Protein', 'fk_field'=> null]
                ],
                //Disabled until we integrate custom code into generic search infrastructure
                /*'search' => [
                    'targetId' => null
                ],*/
                'options' => [
                    'id_pattern' => '.*',
                    'alias' => 'Targets',
                    'file.new.label'=>'Target',
                    'icon' => 'protein_16.png',
                    'auto_activate' => '3'
                ]
            ],
            /*'saturn.core.domain.SgcTargetDNA'=>[
                'fields'=>[
                    'sequence' => 'SEQ',
                    'id' => 'PKEY',
                    'type' => 'SEQTYPE',
                    'version' => 'TARGETVERSION',
                    'targetId' => 'SGCTARGET_PKEY',
                    'crc' => 'CRC',
                    'target' => 'TARGET_ID'
                ],
                'indexes'=>[
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => '',
                    'name' => 'SEQDATA'
                ],
                'selector' => [
                    'field' => 'type',
                    'value' => 'Nucleotide'
                ]
             ],
            'saturn.core.domain.SgcSeqData'=>[
                'fields'=>[
                    'sequence' => 'SEQ',
                    'id' => 'PKEY',
                    'type' => 'SEQTYPE',
                    'version' => 'TARGETVERSION',
                    'targetId' => 'SGCTARGET_PKEY',
                    'crc' => 'CRC',
                    'target' => 'TARGET_ID'
                ],
                'indexes'=>[
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => '',
                    'name' => 'SEQDATA'
                ]
            ],*/
            'saturn.core.domain.SgcDomain'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'accession' => 'IDENTIFIER',
                    'start' => 'SEQSTART',
                    'stop' => 'SEQSTOP',
                    'targetId' => 'SGCTARGET_PKEY'
                ],
                'indexes'=>[
                    'accession'=>false,
                    'id'=>true
                ]
            ],
            'saturn.core.domain.SgcConstructPlate'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'plateName' => 'PLATENAME',
                    'elnRef' => 'ELNREF',
                ],
                'indexes'=>[
                    'plateName'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'PLATE'
                ],
                'options' => [
                    'icon' => 'dna_conical_16.png',
                    'alias' => 'Construct Plate',
                    'file.new.label'=>'Construct Plate',
                    'id_pattern' => 'cp-',
                    'strip_id_prefix' => true,
                    'actions' => [
                        'search_bar' => [
                            'DEFAULT' => [
                                'user_suffix' => 'A',
                                'function' => 'saturn.core.domain.SgcConstructPlate.loadPlate'
                            ]
                        ]
                    ]
                ],
                'programs'=>[
                    'saturn.client.programs.EmptyViewer' => true
                ],
                'search'=>[
                    'plateName' => true
                ],
                'model' => [
                    'Plate Name' => 'plateName'
                 ]
            ],
            'saturn.core.domain.SgcAllelePlate'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'plateName' => 'PLATENAME',
                    'elnRef' => 'ELNREF'
                ],
                'indexes'=>[
                    'plateName'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'PLATE'
                ],
                'options' => [
                    'icon' => 'dna_conical_16.png',
                    'alias' => 'Allele Plate',
                    'file.new.label' => 'Allele Plate',
                    'id_pattern' => 'ap-',
                    'strip_id_prefix' => true,
                    'actions' => [
                        'search_bar' => [
                            'DEFAULT' => [
                                'user_suffix' => 'A',
                                'function' => 'saturn.core.domain.SgcAllelePlate.loadPlate'
                            ]
                        ]
                    ],
                    'auto_activate' => '3'
                ],

                'search'=>[
                    'plateName' => true
                 ],
                'model' => [
                    'Plate Name' => 'plateName'
                ],
                'programs'=>[
                    'saturn.client.programs.EmptyViewer' => true
                ],
            ],
            /*'saturn.core.domain.SgcDNA'=>[
                'fields'=>[
                    'dnaId' => 'DNA_ID',
                    'id' => 'PKEY',
                    'dnaSeq' => 'DNASEQUENCE'
                ],
                'indexes'=>[
                    'dnaId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'DNA'
                ]
            ],*/
            /*'saturn.core.domain.TiddlyWiki'=>[
                'fields'=>[
                    'pageId' => 'PAGEID',
                    'id' => 'PKEY',
                    'content' => 'CONTENT'
                ],
                'indexes'=>[
                    'pageId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'TIDDLY_WIKI'
                ],
                'options' => [
                    'icon' => 'eln_16.png',
                    'alias' => 'ELN Pages',
                    'file.new.label' => 'ELN Page',
                    'id_pattern' => 'wiki-',
                    'strip_id_prefix' => true
                ],
                'search'=>[
                    'pageId' => true
                ],
                'programs'=>[
                    'saturn.client.programs.TiddlyWikiViewer' => true
                ]
            ],*/
            /*'saturn.core.domain.Entity'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'entityId' => 'ID',
                    'dataSourceId' => 'SOURCE_PKEY',
                    'reactionId' => 'SGCREACTION_PKEY',
                    'entityTypeId' => 'SGCENTITY_TYPE',
                    'altName' => 'ALTNAME',
                    'description' => 'DESCRIPTION'
                ],
                'indexes'=>[
                    'entityId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_ENTITY'
                ],
                'fields.synthetic' =>[
                    'source' => [ 'field' => 'dataSourceId', 'class' => 'saturn.core.domain.DataSource', 'fk_field' => 'id' ],
                    'reaction' => [ 'field' => 'reactionId', 'class' => 'saturn.core.Reaction', 'fk_field' => 'id' ],
                    'entityType' => [ 'field' => 'entityTypeId', 'class' => 'saturn.core.EntityType', 'fk_field' => 'id' ]
                ]
            ],*/
            /*'saturn.core.domain.Molecule'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'ID',
                    'sequence' => 'LINEAR_SEQUENCE',
                    'entityId' => 'SGCENTITY_PKEY'
                ],
                'indexes'=>[
                    'name'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_MOLECULE'
                ],
                'fields.synthetic' =>[
                    'entity' => [ 'field' => 'entityId', 'class' => 'saturn.core.Entity', 'fk_field' => 'id' ],
                ]
            ],
            'saturn.core.ReactionType'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME'
                ],
                'indexes'=>[
                    'name'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_REACTION_TYPE'
                ]
            ],*/
            /*'saturn.core.EntityType'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME'
                ],
                'indexes'=>[
                    'name'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_ENTITY_TYPE'
                ]
            ],
            'saturn.core.ReactionRole'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME'
                ],
                'indexes'=>[
                    'name'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_REACTION_ROLE'
                ]
            ],'saturn.core.Reaction'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME',
                    'reactionTypeId' => 'SGCREACTION_TYPE'
                ],
                'indexes'=>[
                    'name'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_REACTION'
                ],
                'fields.synthetic' =>[
                    'reactionType' => [ 'field' => 'reactionTypeId', 'class' => 'saturn.core.ReactionType', 'fk_field' => 'id' ],
                ]
            ],'saturn.core.ReactionComponent'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'reactionRoleId' => 'SGCROLE_PKEY',
                    'entityId' => 'SGCENTITY_PKEY',
                    'reactionId' => 'SGCREACTION_PKEY',
                    'position' => 'POSITION'
                ],
                'indexes'=>[
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_REACTION_COMPONENT'
                ],
                'fields.synthetic' =>[
                    'reactionRole' => [ 'field' => 'reactionRoleId', 'class' => 'saturn.core.ReactionRole', 'fk_field' => 'id' ],
                    'reaction' => [ 'field' => 'reactionId', 'class' => 'saturn.core.Reaction', 'fk_field' => 'id' ],
                    'entity' => [ 'field' => 'entityId', 'class' => 'saturn.core.Entity', 'fk_field' => 'id' ],
                ]
            ],
            'saturn.core.domain.DataSource'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME',
                ],
                'indexes'=>[
                    'name'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_ENTITY_SOURCE'
                ]
            ],*/
            /*'saturn.core.domain.MoleculeAnnotation'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'entityId' => 'SGCENTITY_PKEY',
                    'labelId' => 'XREF_SGCENTITY_PKEY',
                    'start' => 'STARTPOS',
                    'stop' => 'STOPPOS',
                    'evalue' => 'EVALUE'
                ],
                'indexes'=>[
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'Z_ANNOTATION'
                ],
                'fields.synthetic' =>[
                    'entity' => [ 'field' => 'entityId', 'class' => 'saturn.core.domain.Entity', 'fk_field' => 'id' ],
                    'referent' => [ 'field' => 'labelId', 'class' => 'saturn.core.domain.Entity', 'fk_field' => 'id' ],
                ]
            ],*/
            'saturn.core.domain.XtalPlate'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'barcode' => 'BARCODE',
                    'purificationId' => 'SGCPURIFICATION_PKEY'
                ],
                'indexes'=>[
                    'barcode'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'XTAL_PLATES'
                ],
                'fields.synthetic' => [
                    'purification' => [ 'field' => 'purificationId', 'class' => 'saturn.core.domain.SgcPurification', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Xtal Plates'
                ]
            ],
            'saturn.core.domain.StructureModel'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'modelId' => 'MODELID',
                    'pathToPdb' => 'PATHTOPDB'
                ],
                'indexes'=>[
                    'modelId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'MODEL'
                ],
                'fields.synthetic' => [
                    'pdb' => [ 'field' => 'pathToPdb', 'class' => 'saturn.core.domain.FileProxy', 'fk_field' => 'path']
                ],
                'options' => [
                    'id_pattern' => '\\w+-m',
                    'workspace_wrapper' => 'saturn.client.workspace.StructureModelWO',
                    'icon' => 'structure_16.png',
                    'alias' => 'Models'
                ],
                'search' => [
                    'modelId' => '\\w+-m'
                ],
                'model' => [
                    'Model ID' => 'modelId',
                    'Path to PDB' => 'pathToPdb'
                ]
            ],
            'saturn.core.domain.FileProxy'=>[
                'fields'=>[
                    'path' => 'PATH',
                    'content' => 'CONTENT'
                ],
                'indexes'=>[
                    'path'=>true
                ],
                'options' => [
                    'windows_conversions' => [
                        '/work' => 'W:',
                        '/home/share' => 'S:'
                    ],
                    'windows_allowed_paths_regex' => [
                        'WORK' => '^W',
                        //'SHARE' => '^S:'
                    ],
                    'linux_conversions' => [
                        'W:' => '/work'
                    ],
                    'linux_allowed_paths_regex' => [
                        'WORK' => '^/work'
                    ]
                ]
            ],
            'saturn.core.DNA' =>[
                'fields'=>[
                    'moleculeName' => 'NAME'
                ],
                'indexes'=>[
                    'moleculeName' => true
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => false
                ],
                'options' =>[
                    'alias' => 'DNA',
                    'icon'=>'dna_conical_16.png'
                ]
            ],
            'saturn.core.Protein' =>[
                'fields'=>[
                    'moleculeName' => 'NAME'
                ],
                'indexes'=>[
                    'moleculeName' => true
                ],
                'programs'=>[
                    'saturn.client.programs.ProteinSequenceEditor' => false
                ],
                'options' =>[
                    'alias' => 'Proteins',
                    'icon'=>'structure_16.png'
                ]
            ],
            'saturn.core.domain.TextFile' =>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME',
                    'value'=> 'VALUE'
                ],
                'indexes'=>[
                    'name' => false,
                    'id' => true
                ],
                'programs'=>[
                    'saturn.client.programs.TextEditor' => true
                ],
                'options' =>[
                    'alias' => 'Scripts',
                    'file.new.label'=> 'Script',
                    'icon' => 'dna_conical_16.png'
                ],
                /*'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'SCRIPTS'
                ],
                'search'=>[
                    'name' => true
                ]*/
            ],
            'saturn.core.BasicTable' =>[
                'programs'=>[
                    'saturn.client.programs.BasicTableViewer' => true
                ],
                'options' => [
                    'alias' => 'Results'
                ]
            ],
            'saturn.core.ConstructDesignTable' =>[
                'programs'=>[
                    'saturn.client.programs.ConstructDesigner' => false
                ],
                'options' => [
                    'alias' => 'Construct Plan',
                    'icon'=>'dna_conical_16.png'
                ]
            ],

            'saturn.core.PurificationHelperTable' =>[
                'programs'=>[
                    'saturn.client.programs.PurificationHelper' => false
                ],
                'options' => [
                    'alias' => 'Purifiaction Helper'
                ]
            ],
            'saturn.core.SHRNADesignTable' =>[
                'programs'=>[
                    'saturn.client.programs.SHRNADesigner' => false
                ],
                'options' => [
                    'alias' => 'shRNA Designer',
                    'icon' => 'shrna_16.png'
                ]
            ],
            'saturn.core.Table' =>[
                'programs'=>[
                    'saturn.client.programs.BasicTableViewer' => false
                ],
                'options' => [
                    'alias' => 'Table'
                ]
            ],
            'saturn.core.domain.Compound'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'compoundId' => 'COMPOUNDID',
                    'shortCompoundId' => 'COMPOUND_ID',
                    'supplierId' => 'SUPPLIER_ID',
                    'sdf' => 'SDF',
                    'supplier' => 'SUPPLIER',
                    'description' => 'DESCRIPTION',
                    'concentration' => 'CONCENTRATION',
                    'location' => 'LOCATION',
                    'comments' => 'COMMENTS',
                    'solute' => 'SOLUTE',
                    'mw' => 'MW',
                    'confidential' => 'CONFIDENTIAL',
                    'inchi' => 'INCHI',
                    'smiles' => 'SMILES',
                    'datestamp' => 'DATESTAMP',
                    'person' => 'PERSON',
                    'oldSGCGLobalId' => 'OLD_SGCGLOBAL_ID'
                ],
                'indexes'=>[
                    'compoundId' => false,
                    'id'=>true
                ],
                'search' => [
                    'compoundId'  => null,
                    /*'shortCompoundId' => null,
                    'supplierId' => null,
                    'supplier' => null,
                    'oldSGCGlobalId'=>null*/
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'COMPOUND'
                ],
                'options' => [
                    'workspace_wrapper' => 'saturn.client.workspace.CompoundWO',
                    'icon' => 'compound_16.png',
                    'alias' => 'Compounds',
                    'actions' => [
                        'search_bar' => [
                            'assay_results' => [
                                'user_suffix' => 'Assay Results',
                                'function' => 'saturn.core.domain.Compound.assaySearch'
                            ]
                        ]
                    ]
                ],
                'model' => [
                    'Global ID' => 'compoundId',
                    'Oxford ID' => 'shortCompoundId',
                    'Supplier ID' => 'supplierId',
                    'Supplier' => 'supplier',
                    'Description' => 'description',
                    'Concentration' => 'concentration',
                    'Location' => 'location',
                    'Solute' => 'solute',
                    'Comments' => 'comments',
                    'MW' => 'mw',
                    'Confidential' => 'CONFIDENTIAL',
                    'Date' => 'datestamp',
                    'Person' => 'person',
                    'InChi' => 'inchi',
                    'smiles' => 'smiles'
                ],
                'programs'=>[
                    'saturn.client.programs.CompoundViewer' => true
                ]
            ],
            /*'saturn.core.domain.Glycan'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'glycanId' => 'GLYCANID',
                    'content' => 'CONTENT',
                    'contentType' => 'CONTENT_TYPE',
                    'description' => 'DESCRIPTION'
                ],
                'indexes'=>[
                    'glycanId' => false,
                    'id'=>true
                ],
                'search' => [
                    'glycanId'  => null
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'GLYCAN'
                ],
                'options' => [
                    'workspace_wrapper' => 'saturn.client.workspace.GlycanWO',
                    'icon' => 'glycan_16.png',
                    'alias' => 'Glycans',

                ],
                'model' => [
                    'Glycan ID' => 'glycanId',
                    'Description' => 'description',
                    'content' => 'content',
                    'contentType' => 'contentType'
                ],
                'programs'=>[
                    'saturn.client.programs.GlycanBuilder' => true
                ]
            ],*/
            'saturn.app.SaturnClient'=>[
                'options'=>[
                    'flags' =>[
                        'SGC' => true
                    ]
                ]
            ],
            /*'saturn.core.User' =>[
                'fields' =>[
                    'id' => 'PKEY',
                    'username' => 'USERID',
                    'fullname' => 'FULLNAME'
                ],
                'indexes' =>[
                    'id' => true,
                    'username' => false
                ],
                'table_info' => [
                    'schema' => 'HIVE',
                    'name' => 'USER_DETAILS'
                ]
            ],*/
            /*'saturn.core.Permission' =>[
                'fields' =>[
                    'id' => 'PKEY',
                    'name' => 'NAME'
                ],
                'index' =>[
                    'id' => true,
                    'name' => false
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'SATURNPERMISSION'
                ]
            ],*/
            /*'saturn.core.UserToPermission' =>[
                'fields' => [
                    'id' => 'PKEY',
                    'permissionId' => 'PERMISSIONID',
                    'userId' => 'USERID'
                ],
                'index'=>[
                    'id' => true
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'SATURNUSER_TO_PERMISSION'
                ]
            ],*/
            /*'saturn.core.domain.SaturnSession' =>[
                'fields' => [
                    'id' => 'PKEY',
                    'userName' => 'USERNAME',
                    'isPublic' => 'ISPUBLIC',
                    'sessionContent' => 'SESSIONCONTENTS',
                    'sessionName' => 'SESSIONNAME'
                ],
                'indexes'=>[
                    'sessionName' => false,
                    'id' => true
                ],
                'search' => [
                    'user.fullname' => null
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'SATURNSESSION'
                ],
                'options' => [
                    'alias' => 'Session',
                    'auto_activate'=> '3',
                    'constraints' => [
                        'user_constraint_field' => 'userName',
                        'public_constraint_field' => 'isPublic'
                    ],
                    'actions' => [
                        'search_bar' => [
                            'DEFAULT' => [
                                'user_suffix' => '',
                                'function' => 'saturn.core.domain.SaturnSession.load'
                            ]
                        ]
                    ]
                ],
                'auto_functions'=>[
                    'USERNAME'=>'insert.username'
                ],'fields.synthetic' =>[
                    'user' => [ 'field' => 'userName', 'class' => 'saturn.core.User', 'fk_field' => 'username' ]
                ]
            ],*/
            /*'saturn.core.domain.ABITrace' =>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME',
                    'traceDataJson'=> 'TRACE_JSON'
                ],
                'indexes'=>[
                    'name' => false,
                    'id' => true
                ],
                'programs'=>[
                    'saturn.client.programs.ABITraceViewer' => true
                ],
                'options' =>[
                    'alias' => 'Trace Data',
                    'icon' => 'dna_conical_16.png',
                    'workspace_wrapper' => 'saturn.client.workspace.ABITraceWO'
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'TRACES'
                ],
                'search'=>[
                    'name' => true
                ]
            ],*/
           /* 'saturn.core.domain.Alignment' =>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME',
                    'content'=> 'CONTENT',
                    'url'=> 'URL'
                ],
                'indexes'=>[
                    'name' => false,
                    'id' => true
                ],
                'programs'=>[
                    'saturn.client.programs.AlignmentViewer' => true
                ],
                'options' =>[
                    'alias' => 'Alignments',
                    'icon' => 'dna_conical_16.png',
                    'workspace_wrapper' => 'saturn.client.workspace.AlignmentWorkspaceObject'
                ],
                'table_info' => [
                    'schema' => 'PSF',
                    'name' => 'ALIGNMENTS'
                ],
                'search'=>[
                    'name' => true
                ]
            ]*/
        ];
    }

    public static function getNextAvailableId(clazz : Class<Dynamic>, value : String, db : Provider, cb : Int->Void){

    }
}
