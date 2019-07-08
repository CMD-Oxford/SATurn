/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.mapping;

class SGC {
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
                    'constructId' => 'CONSTRUCT_ID',
                    'id' => 'PKEY',
                    'proteinSeq' => 'CONSTRUCTPROTSEQ',
                    'proteinSeqNoTag' => 'CONSTRUCTPROTSEQNOTAG',
                    'dnaSeq' => 'CONSTRUCTDNASEQ',
                    'docId' => 'ELNEXP',
                    'vectorId' => 'SGCVECTOR_PKEY',
                    'alleleId' => 'SGCALLELE_PKEY',
                    'res1Id' => 'SGCRESTRICTENZ1_PKEY',
                    'res2Id' => 'SGCRESTRICTENZ2_PKEY',
                    'constructPlateId' => 'SGCCONSTRUCTPLATE_PKEY',
                    'wellId' => 'WELLID',
                    'expectedMass' => 'EXPECTEDMASS',
                    'expectedMassNoTag' => 'EXPETCEDMASSNOTAG',
                    'status' => 'STATUS',
                    'location' => 'SGCLOCATION',
                    'elnId' => 'ELNEXP',
                    'constructComments' => 'CONSTRUCTCOMMENTS',
                    'person' => 'PERSON',
                    'constructStart' => 'CONSTRUCTSTART',
                    'constructStop'=> 'CONSTRUCTSTOP',
                    'complex' => 'COMPLEX'
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
                    'allele' => [ 'field' => 'alleleId', 'class' => 'saturn.core.domain.SgcAllele', 'fk_field' => 'id' ],
                    'vector' => [ 'field' => 'vectorId', 'class' => 'saturn.core.domain.SgcVector', 'fk_field' => 'id' ],
                    'res1' => [ 'field' => 'res1Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'id'],
                    'res2' => [ 'field' => 'res2Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'id'],
                    'constructPlate' => [ 'field' => 'constructPlateId', 'class' => 'saturn.core.domain.SgcConstructPlate', 'fk_field' => 'id' ],
                    'proteinSequenceObj' => ['field' => 'proteinSeq', 'class'=>'saturn.core.Protein', 'fk_field'=> null],
                    'proteinSequenceNoTagObj' => ['field' => 'proteinSeqNoTag', 'class'=>'saturn.core.Protein', 'fk_field'=> null]
                ],
                'table_info' => [
                    'schema' => 'SGC',
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
            'saturn.core.domain.SgcConstructStatus' => [
                'fields' => [
                    'constructPkey' => 'SGCCONSTRUCT_PKEY',
                    'status' => 'STATUS'
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'CONSTR_STATUS_SNAPSHOT'
                ],
                'indexes'=>[
                    'constructPkey'=>true
                ]
            ],
            'saturn.core.domain.SgcAllele'=>[
                'fields'=>[
                    'alleleId'=>'ALLELE_ID',
                    'allelePlateId' => 'SGCPLATE_PKEY',
                    'id' => 'PKEY',
                    'entryCloneId' => 'SGCENTRYCLONE_PKEY',
                    'forwardPrimerId' => 'SGCPRIMER5_PKEY',
                    'reversePrimerId' => 'SGCPRIMER3_PKEY',
                    'dnaSeq' => 'ALLELESEQUENCERAW',
                    'proteinSeq' => 'ALLELEPROTSEQ',
                    'status' => 'ALLELE_STATUS',
                    'location' => 'SGCLOCATION',
                    'comments' => 'ALLELECOMMENTS',
                    'elnId' => 'ELNEXP',
                    'dateStamp' => 'DATESTAMP',
                    'person' => 'PERSON',
                    'plateWell' => 'PLATEWELL',
                    'dnaSeqLen' => 'ALLELESEQLENGTH',
                    'complex' => 'COMPLEX',
                    'domainSummary' => 'DOMAINSUMMARY',
                    'domainStartDelta' => 'DOMAINSTARTDELTA',
                    'domainStopDelta' => 'DOMAINSTOPDELTA',
                    'containsPharmaDomain' => 'CONTAINSPHARMADOMAIN',
                    'domainSummaryLong' => 'DOMAINSUMMARYLONG',
                    'impPI' => 'IMPPI'
                ],
                'defaults'=> [
                    'status' => 'In process'
                ],
                'model' =>[
                    'Allele ID' => 'alleleId',
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
                    'entryClone' => [ 'field' => 'entryCloneId', 'class' => 'saturn.core.domain.SgcEntryClone', 'fk_field' => 'id' ],
                    'forwardPrimer' => [ 'field' => 'forwardPrimerId', 'class' => 'saturn.core.domain.SgcForwardPrimer', 'fk_field' => 'id' ],
                    'reversePrimer' => [ 'field' => 'reversePrimerId', 'class' => 'saturn.core.domain.SgcReversePrimer', 'fk_field' => 'id' ],
                    'plate' => [ 'field' => 'allelePlateId', 'class' => 'saturn.core.domain.SgcAllelePlate', 'fk_field' => 'id' ],
                    'proteinSequenceObj' => ['field' => 'proteinSeq', 'class'=>'saturn.core.Protein', 'fk_field'=> null]
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'ALLELE'
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
                    'entryCloneId'=>'ENTRY_CLONE_ID',
                    'id' => 'PKEY',
                    'dnaSeq' => 'DNARAWSEQUENCE',
                    'targetId' => 'SGCTARGET_PKEY',
                    'seqSource' => 'SEQSOURCE',
                    'sourceId' => 'SOURCEID',
                    'sequenceConfirmed'=> 'SEQUENCECONFIRMED',
                    'elnId' => 'ELNEXPERIMENTID',
                    'complex' => 'COMPLEX'
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
                    'schema' => 'SGC',
                    'name' => 'ENTRY_CLONE'
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
                    'enzymeName' => 'RESTRICTION_ENZYME_NAME',
                    'cutSequence' => 'RESTRICTION_ENZYME_SEQUENCERAW',
                    'id' => 'PKEY'
                ],
                'indexes'=>[
                    'enzymeName'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'RESTRICTION_ENZYME'
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
                    'vectorId'=>'VECTOR_NAME',
                    'id'=>'PKEY',
                    'sequence'=>'VECTORSEQUENCERAW',
                    'vectorComments'=>'VECTORCOMMENTS',
                    'proteaseName'=>'PROTEASE_NAME',
                    'proteaseCutSequence'=>'PROTEASE_CUTSEQUENCE',
                    'proteaseProduct'=>'PROTEASE_PRODUCT',
                    'antibiotic'=>'ANTIBIOTIC',
                    'organism'=>'ORGANISM',
                    'res1Id'=>'SGCRESTRICTENZ1_PKEY',
                    'res2Id'=>'SGCRESTRICTENZ2_PKEY',
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
                    'res1' => [ 'field' => 'res1Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'id' ],
                    'res2' => [ 'field' => 'res2Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'id' ]
                ],
                'table_info' => [
                    'schema' => 'SGC',
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
                    'primerId' => 'PRIMERNAME',
                    'id' => 'PKEY',
                    'dnaSequence' => 'PRIMERRAWSEQUENCE'
                ],
                'indexes'=>[
                    'primerId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
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
                    'primerId' => 'PRIMERNAME',
                    'id' => 'PKEY',
                    'dnaSequence' => 'PRIMERRAWSEQUENCE'
                ],
                'indexes'=>[
                    'primerId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
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
                    'schema' => 'SGC',
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
                    'schema' => 'SGC',
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
                    'schema' => 'SGC',
                    'name' => 'EXPRESSION'
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
                    'targetId' => 'TARGET_ID',
                    'id' => 'PKEY',
                    'gi' => 'GENBANK_ID',
                    'geneId' => 'NCBIGENEID',
                    'proteinSeq' => 'PROTEINSEQUENCE',
                    'dnaSeq' => 'NUCLEOTIDESEQUENCE',
                    'activeStatus' => 'ACTIVESTATUS',
                    'pi' => 'PI',
                    'comments' => 'COMMENTS',
                    'complexComments' => 'COMPLEXCOMPONENTS',
                    'complex' => 'COMPLEX',
                    'complexOverride'=>'COMPLEXOVERRIDE'
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
            'saturn.core.domain.SgcTargetDNA'=>[
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
            ],
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
                    'schema' => 'SGC',
                    'name' => 'CONSTRUCTPLATE'
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
                    'schema' => 'SGC',
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
            'saturn.core.domain.SgcDNA'=>[
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
                    'schema' => 'SGC',
                    'name' => 'DNA'
                ]
            ],
            'saturn.core.domain.TiddlyWiki'=>[
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
                    'schema' => 'SGC',
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
            ],
            'saturn.core.domain.Entity'=>[
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
                    'schema' => 'SGC',
                    'name' => 'Z_ENTITY'
                ],
                'fields.synthetic' =>[
                    'source' => [ 'field' => 'dataSourceId', 'class' => 'saturn.core.domain.DataSource', 'fk_field' => 'id' ],
                    'reaction' => [ 'field' => 'reactionId', 'class' => 'saturn.core.Reaction', 'fk_field' => 'id' ],
                    'entityType' => [ 'field' => 'entityTypeId', 'class' => 'saturn.core.EntityType', 'fk_field' => 'id' ]
                ]
            ],
            'saturn.core.domain.Molecule'=>[
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
                    'schema' => 'SGC',
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
                    'schema' => 'SGC',
                    'name' => 'Z_REACTION_TYPE'
                ]
            ],
            'saturn.core.EntityType'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'name' => 'NAME'
                ],
                'indexes'=>[
                    'name'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
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
                    'schema' => 'SGC',
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
                    'schema' => 'SGC',
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
                    'schema' => 'SGC',
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
                    'schema' => 'SGC',
                    'name' => 'Z_ENTITY_SOURCE'
                ]
            ],
            'saturn.core.domain.MoleculeAnnotation'=>[
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
                    'schema' => 'SGC',
                    'name' => 'Z_ANNOTATION'
                ],
                'fields.synthetic' =>[
                    'entity' => [ 'field' => 'entityId', 'class' => 'saturn.core.domain.Entity', 'fk_field' => 'id' ],
                    'referent' => [ 'field' => 'labelId', 'class' => 'saturn.core.domain.Entity', 'fk_field' => 'id' ],
                ]
            ],
            'saturn.core.domain.SgcXtalPlate'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'barcode' => 'BARCODE',
                    'purificationId' => 'SGCPURIFICATION_PKEY',
                    'location'=> 'LOCATION',
                    'proteinState' =>'PROTEINSTATE',
                    'plateStatus'=>'PLATESTATUS',
                    'concentration'=>'CONCENTRATION',
                    'dateCreated'=>'DATESTAMP',
                    'person' => 'PERSON',
                    'elnId' => 'ELNREF'
                ],
                'indexes'=>[
                    'barcode'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'XTAL_PLATES'
                ],
                'fields.synthetic' => [
                    'purification' => [ 'field' => 'purificationId', 'class' => 'saturn.core.domain.SgcPurification', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Xtal Plates',
                    'auto_activate' => '3',
                ],
                'search' => [
                    'barcode'=>true
                ],
                'model' => [
                    'Barcode' => 'barcode',
                    'Purification ID'=> 'purification.purificationId',
                    'Location'=>'location',
                    'Protein State'=>'proteinState',
                    'Plate Status'=>'plateStatus',
                    'Concentration'=>'concentration',
                    'ELN ID' => 'elnId',
                    'Date Created' => 'dateCreated',
                    'Creator' => 'person'
                ],
                    'programs'=>[
                    'saturn.client.programs.EmptyViewer' => true
                ],
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
                    'schema' => 'SGC',
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
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'SCRIPTS'
                ],
                'search'=>[
                    'name' => true
                ]
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
            'saturn.core.ComplexPlan' =>[
                'programs'=>[
                    'saturn.client.programs.ComplexHelper' => false
                ],
                'options' => [
                    'alias' => 'Complex Helper',
                    'icon'=>'protein_conical_16.png'
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
                    'compoundId' => 'SGCGLOBALID',
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
                    'shortCompoundId' => null,
                    'supplierId' => null,
                    'supplier' => null,
                    'oldSGCGlobalId'=>null
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'SGCCOMPOUND'
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
            'saturn.core.domain.Glycan'=>[
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
                    'schema' => 'SGC',
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
            ],
            'saturn.app.SaturnClient'=>[
                'options'=>[
                    'flags' =>[
                        'SGC' => true
                    ]
                ]
            ],
            'saturn.core.User' =>[
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
            ],
            'saturn.core.Permission' =>[
                'fields' =>[
                    'id' => 'PKEY',
                    'name' => 'NAME'
                ],
                'index' =>[
                    'id' => true,
                    'name' => false
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'SATURNPERMISSION'
                ]
            ],
            'saturn.core.UserToPermission' =>[
                'fields' => [
                    'id' => 'PKEY',
                    'permissionId' => 'PERMISSIONID',
                    'userId' => 'USERID'
                ],
                'index'=>[
                    'id' => true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'SATURNUSER_TO_PERMISSION'
                ]
            ],
            'saturn.core.domain.SaturnSession' =>[
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
                    'schema' => 'SGC',
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
            ],
            'saturn.core.domain.ABITrace' =>[
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
                    'schema' => 'SGC',
                    'name' => 'TRACES'
                ],
                'search'=>[
                    'name' => true
                ]
            ],
            'saturn.core.domain.Alignment' =>[
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
                    'schema' => 'SGC',
                    'name' => 'ALIGNMENTS'
                ],
                'search'=>[
                    'name' => true
                ]
            ],
            'saturn.core.domain.SgcXtbm'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'xtbmId' => 'XTBMID',
                    'plateRow' => 'PLATEROW',
                    'plateColumn' => 'PLATECOLUMN',
                    'subwell' => 'SUBWELL',
                    'xtalPlateId' => 'XTALPLATES_ID',
                    'score' => 'CATEGORYSCORE',
                    'barcode' => 'BARCODE'
                ],
                'indexes'=>[
                    'xtbmId' => false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'CRYSTALSTOBEMOUNTED'
                ],
                'fields.synthetic' => [
                    'xtalPlate' => [ 'field' => 'xtalPlateId', 'class' => 'saturn.core.domain.SgcXtalPlate', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'XTBM'
                ],
                'model' => [
                    'XTBM ID' => 'xtbmId',
                    'Plate ID' => 'xtalPlateId'
                ]
            ],
            'saturn.core.domain.SgcXtalMount'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'xtalMountId' => 'XTAL_MOUNT_ID',
                    'xtbmId' => 'SGCCRYSTALSTOBEMOUNTED_PKEY',
                    'xtalProjectId' => 'SGCPROJECTS_PKEY',
                    'dropStatus' => 'DROPSTATUS',
                    'compoundId' => 'SGCCOMPOUND_PKEY',
                    'pinId' => 'SGCPIN_PKEY',
                    'xtalFormId' => 'SGCXTALFORM_PKEY'
                ],
                'indexes'=>[
                    'xtalMountId' => false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'XTAL_MOUNT'
                ],
                'fields.synthetic' => [
                    'xtbm' => [ 'field' => 'xtbmId', 'class' => 'saturn.core.domain.SgcXtbm', 'fk_field' => 'id'],
                    'xtalProject' => [ 'field' => 'xtalProjectId', 'class' => 'saturn.core.domain.SgcXtalProject', 'fk_field' => 'id'],
                    'compound' => [ 'field' => 'compoundId', 'class' => 'saturn.core.domain.Compound', 'fk_field' => 'id'],
                    'xtalForm' => [ 'field' => 'xtalFormId', 'class' => 'saturn.core.domain.SgcXtalForm', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Mounted Xtal'
                ]
            ],
            'saturn.core.domain.SgcXtalDataSet'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'xtalDataSetId' => 'DATASETID',
                    'xtalMountId' => 'SGCXTALMOUNT_PKEY',
                    'estimatedResolution' => 'ESTRESOLUTION',
                    'scaledResolution' => 'RESOLUTION',
                    'xtalProjectId' => 'SGCPROJECTS_PKEY',
                    'beamline' => 'BEAMLINE',
                    'outcome' => 'OUTCOME',
                    'dsType' => 'DSTYPE',
                    'visit' => 'VISIT',
                    'spaceGroup' => 'SPACEGROUP',
                    'dateRecordCreated' => 'DATESTAMP'
                ],
                'indexes'=>[
                    'xtalDataSetId' => false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'XTAL_DATASET'
                ],
                'fields.synthetic' => [
                    'xtalMount' => [ 'field' => 'xtalMountId', 'class' => 'saturn.core.domain.SgcXtalMount', 'fk_field' => 'id'],
                    'xtalProject' => [ 'field' => 'xtalProjectId', 'class' => 'saturn.core.domain.SgcXtalProject', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Xtal DataSet'
                ]
            ],
            'saturn.core.domain.SgcXtalModel'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'xtalModelId' => 'MODELID',
                    'modelType' => 'MODELTYPE',
                    'compound1Id' => 'SGCCOMPOUND1_PKEY',
                    'compound2Id' => 'SGCCOMPOUND2_PKEY',
                    'xtalDataSetId' => 'SGCXTALDATASET_PKEY',
                    'status' => 'STATUS',
                    'pathToCrystallographicPDB' =>'PATHTOPDB',
                    'pathToChemistsPDB' =>'PATHTOBOUNDPDB',
                    'pathToMTZ' => 'PATHTOMTZ',
                    'pathToXDSLog' =>'PATHTOLOG',
                    'estimatedEffort' =>'ESTEFFORT',
                    'proofingEffort' =>'PROOFEFFORT',
                    'spaceGroup' => 'SPACEGROUP'
                ],
                'indexes'=>[
                    'xtalModelId' => false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'MODEL'
                ],
                'fields.synthetic' => [
                    'xtalDataSet' => [ 'field' => 'xtalDataSetId', 'class' => 'saturn.core.domain.SgcXtalDataSet', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Xtal Model'
                ]
            ],
            'saturn.core.domain.SgcXtalDeposition'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'pdbId' => 'PDBID',
                    'counted' => 'COUNTED',
                    'site' => 'SITE',
                    'followup' => 'FOLLOWUP',
                    'xtalModelId' => 'SGCMODEL_PKEY',
                    'dateDeposited' => 'DATEDEPOSITED',
                    'depType' => 'DEPTYPE'
                ],
                'indexes'=>[
                    'pdbId' => false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'DEPOSITION'
                ],
                'fields.synthetic' => [
                    'xtalModel' => [ 'field' => 'xtalModelId', 'class' => 'saturn.core.domain.SgcXtalModel', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Xtal Model'
                ]
            ],
            'saturn.core.domain.SgcXtalProject'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'xtalProjectId' => 'PROJECTID',
                    'dataPath' => 'DATA_PATH',
                    'targetId' => 'SGCTARGET_PKEY'
                ],
                'indexes'=>[
                    'xtalProjectId' => false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'PROJECTS'
                ],
                'fields.synthetic' => [
                    'target' => [ 'field' => 'targetId', 'class' => 'saturn.core.domain.SgcTarget', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Xtal Model',
                    'auto_activate' => '3'
                ]
            ],
            'saturn.core.domain.SgcXtalForm'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'formId' => 'FORMID',
                    'phasingId' => 'SGCPHASING_PKEY',
                    'a' => 'A',
                    'b' => 'B',
                    'c' => 'C',
                    'alpha' => 'ALPHA',
                    'beta' => 'BETA',
                    'gamma' => 'GAMMA',
                    'lattice' => 'LATTICE',
                    'latticeSymbol' => 'LATTICESYMBOL',
                    'spaceGroup' => 'SPACEGROUP'
                ],
                'indexes'=>[
                    'formId' => false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'XTAL_FORM'
                ],
                'fields.synthetic' => [
                    'xtalPhasing' => [ 'field' => 'phasingId', 'class' => 'saturn.core.domain.SgcXtalPhasing', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Xtal Form'
                ]
            ],
            'saturn.core.domain.SgcXtalPhasing'=>[
                'fields'=>[
                    'id' => 'PKEY',
                    'phasingId' => 'PHASINGID',
                    'xtalDataSetId' => 'SGCXTALDATASET_PKEY1',
                    'phasingMethod' => 'PHASINGMETHOD',
                    'phasingConfidence' => 'CONFIDENCE',
                    'spaceGroup' => 'SPACEGROUP'
                ],
                'indexes'=>[
                    'phasingId' => false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'XTAL_PHASING'
                ],
                'fields.synthetic' => [
                    'xtalDataSet' => [ 'field' => 'xtalDataSetId', 'class' => 'saturn.core.domain.SgcXtalDataSet', 'fk_field' => 'id']
                ],
                'options' => [
                    'alias' => 'Xtal Phasing'
                ]
            ]
        ];
    }

    public static function getNextAvailableId(clazz : Class<Dynamic>, value : String, db : Provider, cb : Int->Void){

    }
}
