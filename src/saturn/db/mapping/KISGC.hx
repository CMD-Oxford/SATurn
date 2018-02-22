/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Copyright (C) 2015  Structural Genomics Consortium
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package saturn.db.mapping;

class KISGC {
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
                    'expectedMassNoTag' => 'EXPECTEDMASSNOTAG',
                    'status' => 'STATUS',
                    'location' => 'SGCLOCATION',
                    'elnId' => 'ELNEXP',
                    'constructComments' => 'COMMENTS',
                    'person' => 'PERSON'
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
                    'vectorId' => '1',
                    'elnId' => '1'
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
                    'alias' => 'Construct',
                    'icon' => 'dna_conical_16.png',
                    'auto_activate' => '3'
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
                    'alleleId'=>'DNAINSERTID',
                    'allelePlateId' => 'SGCPLATE',
                    'id' => 'PKEY',
                    'entryCloneId' => 'SGCENTRYCLONE',
                    'forwardPrimerId' => 'SGCPRIMER',
                    'reversePrimerId' => 'SGCPRIMERREV',
                    'dnaSeq' => 'DNAINSERTSEQUENCE',
                    'proteinSeq' => 'DNAINSERTPROTSEQ',
                    'status' => 'DNAINSERTSTATUS',
                    'comments' => 'COMMENTS',
                    'elnId' => 'ELNEXP',
                    'dateStamp' => 'DATESTAMP',
                    'person' => 'PERSON',
                    'plateWell' => 'PLATEWELL',
                    'dnaSeqLen' => 'DNAINSERTSEQLENGTH',
                    'domainSummary' => 'DOMAINSUMMARY',
                    'domainStartDelta' => 'DOMAINSTARTDELTA',
                    'domainStopDelta' => 'DOMAINSTOPDELTA',
                    'containsPharmaDomain' => 'CONTAINSPHARMADOMAIN',
                    'domainSummaryLong' => 'DOMAINSUMMARYLONG'
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
                    'entryClone' => [ 'field' => 'entryCloneId', 'class' => 'saturn.core.domain.SgcEntryClone', 'fk_field' => 'entryCloneId' ],
                    'forwardPrimer' => [ 'field' => 'forwardPrimerId', 'class' => 'saturn.core.domain.SgcForwardPrimer', 'fk_field' => 'primerId' ],
                    'reversePrimer' => [ 'field' => 'reversePrimerId', 'class' => 'saturn.core.domain.SgcReversePrimer', 'fk_field' => 'primerId' ],
                    'plate' => [ 'field' => 'allelePlateId', 'class' => 'saturn.core.domain.SgcAllelePlate', 'fk_field' => 'plateName' ],
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'DNAINSERT'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'search'=>[
                    'alleleId' => true
                ],
                'options'=>[
                    'alias' => 'Allele',
                    'icon' => 'dna_conical_16.png'
                ]
            ],
            'saturn.core.domain.SgcEntryClone'=>[
                'fields'=>[
                    'entryCloneId'=>'ENTRYCLONEID',
                    'id' => 'PKEY',
                    'dnaSeq' => 'DNARAWSEQUENCE',
                    'targetId' => 'SGCTARGET',
                    'seqSource' => 'SEQSOURCE',
                    'sourceId' => 'SUPPLIERID',
                    'sequenceConfirmed'=> 'SEQUENCECONFIRMED'
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
                    'canSave'=>[
                        'saturn.client.programs.DNASequenceEditor' => true,
                        'saturn.client.programs.ProteinSequenceEditor' => true
                    ],
                    'alias' => 'Entry Clone',
                    'icon' => 'dna_conical_16.png',
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
                    'name' => 'ENTRYCLONE'
                ],
                'model'=>[
                    'Entry Clone ID' => 'entryCloneId'
                ],
                'fields.synthetic' =>[
                    'target' => [ 'field' => 'targetId', 'class' => 'saturn.core.domain.SgcTarget', 'fk_field' => 'targetId' ]
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
                    'schema' => 'SGC',
                    'name' => 'RESTRICTIONENZYME'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'model'=>[
                    'Enzyme Name'=>'enzymeName'
                ],
                'options'=>[
                    'alias'=>'Restriction site'
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
                    'antibiotic'=>'SGCANTIBIOTIC',
                    'organism'=>'SGCORGANISM',
                    'res1Id'=>'SGCRESTRICTENZ1',
                    'res2Id'=>'SGCRESTRICTENZ2',
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
                    'schema' => 'SGC',
                    'name' => 'VECTOR'
                ],
                'options'=>[
                    'auto_activate'=> '3',
                    'alias' => 'Vector',
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
                    'Restriction site 2' => 'res2.enzymeName'
                ]
            ],
            'saturn.core.domain.SgcForwardPrimer'=>[
                'fields'=>[
                    'primerId' => 'PRIMERID',
                    'id' => 'PKEY',
                    'dnaSequence' => 'PRIMERRAWSEQUENCE',
                    'targetId' => 'SGCTARGET'
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
                    'dnaSequence' => 'PRIMERRAWSEQUENCE',
                    'targetId' => 'SGCTARGET'
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
                    'expressionId' => 'SGCSCALEUPEXPRESSION',
                    'column' => 'COLUMN1',
                    'elnId' => 'ELNEXPERIMENT'
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
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'fields.synthetic' =>[
                    'expression' => [ 'field' => 'expressionId', 'class' => 'saturn.core.domain.SgcExpression', 'fk_field' => 'expressionId' ]
                ],
                'model'=>[
                    'Purification ID' => 'purificationId'
                ]
            ],
            'saturn.core.domain.SgcClone'=>[
                'fields'=>[
                    'cloneId' => 'CLONEID',
                    'id' => 'PKEY',
                    'constructId' => 'SGCCONSTRUCT1',
                    'elnId' => 'ELNEXP'

                ],
                'indexes'=>[
                    'cloneId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'CLONE'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'fields.synthetic' =>[
                    'construct' => [ 'field' => 'constructId', 'class' => 'saturn.core.domain.SgcConstruct', 'fk_field' => 'constructId' ]
                ],
                'model'=>[
                    'Clone ID' => 'cloneId'
                ]
            ],
            'saturn.core.domain.SgcExpression'=>[
                'fields'=>[
                    'expressionId' => 'SCALEUPEXPRESSIONID',
                    'id' => 'PKEY',
                    'cloneId' => 'SGCCLONE',
                    'elnId' => 'ELNEXPERIMENT'
                ],
                'indexes'=>[
                    'expressionId'=>false,
                    'id'=>true
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'SCALEUPEXPRESSION'
                ],
                'programs'=>[
                    'saturn.client.programs.DNASequenceEditor' => true
                ],
                'fields.synthetic' =>[
                    'clone' => [ 'field' => 'cloneId', 'class' => 'saturn.core.domain.SgcClone', 'fk_field' => 'cloneId' ]
                ],
                'model'=>[
                    'Expression ID' => 'expressionId'
                ]
            ],
            'saturn.core.domain.SgcTarget'=>[
                'fields'=>[
                    'targetId' => 'TARGETNAME',
                    'id' => 'PKEY',
                    'gi' => 'GENBANKID',
                    'geneId' => 'NCBIGENEID',
                    'proteinSeq' => 'PROTSEQ',
                    'dnaSeq' => 'DNASEQ',
                    'activeStatus' => 'ACTIVESTATUS'
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
                    'DNA Sequence' => 'dnaSequence.sequence',
                    '__HIDDEN__PKEY__' => 'id'
                ],
                    //Disabled until we integrate custom code into generic search infrastructure
                    /*'search' => [
                    'targetId' => null
                ],*/
                'options' => [
                    'id_pattern' => '.*',
                    'alias' => 'Targets',
                    'icon' => 'protein_16.png'
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
                    'name' => 'PLATE'
                ],
                'options' => [
                    'workspace_wrapper' => 'saturn.client.workspace.MultiConstructHelperWO',
                    'icon' => 'dna_conical_16.png',
                    'alias' => 'Construct Plate'
                ],
                'fts' => [
                    'plateName' => true
                ]
            ],
            'saturn.core.domain.SgcAllelePlate'=>[
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
                    'name' => 'PLATE'
                ],
                'options' => [
                    'workspace_wrapper' => 'saturn.client.workspace.MultiAlleleHelperWO',
                    'icon' => 'dna_conical_16.png',
                    'alias' => 'Allele Plate'
                ],
                'fts' => [
                    'plateName' => true
                ]
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
            'saturn.core.TextFile' =>[
                'fields'=>[
                    'name' => 'NAME'
                ],
                'indexes'=>[
                    'name' => true
                ],
                'programs'=>[
                    'saturn.client.programs.TextEditor' => true
                ],
                'options' =>[
                    'alias' => 'File'
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
                    'alias' => 'Construct Design'
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
                    'compoundId' => 'COMPOUNDNAME',
                    'shortCompoundId' => 'COMPOUNDID',
                    'supplierId' => 'EXTERNALID',
                    'sdf' => 'MOLFILE',
                    'supplier' => 'SUPPLIER',
                    'description' => 'DESCRIPTION',
                    'comments' => 'COMMENTS',
                    'mw' => 'MOLECULARWEIGHT',
                    'smiles' => 'SMILES',
                    'datestamp' => 'DATESTAMP',
                    'person' => 'PERSON'
                ],
                'indexes'=>[
                    'compoundId' => false,
                    'id'=>true
                ],
                'search' => [
                    'compoundId'  => null,
                    'shortCompoundId' => null,
                    'supplierId' => null,
                    'supplier' => null
                ],
                'table_info' => [
                    'schema' => 'SGC',
                    'name' => 'SGCCOMPOUND'
                ],
                'options' => [
                    'id_pattern' => '^\\w{5}\\d{4}',
                    'workspace_wrapper' => 'saturn.client.workspace.CompoundWO',
                    'icon' => 'compound_16.png',
                    'alias' => 'Compounds'
                ],
                'model' => [
                    'Global ID' => 'compoundId',
                    'Oxford ID' => 'shortCompoundId',
                    'Supplier ID' => 'supplierId',
                    'Supplier' => 'supplier',
                    'Description' => 'description',
                    'Comments' => 'comments',
                    'MW' => 'mw',
                    'Date' => 'datestamp',
                    'Person' => 'person',
                    'smiles' => 'smiles'
                ],
                'programs'=>[
                    'saturn.client.programs.CompoundViewer' => true
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
            ]
        ];
    }

    public static function getNextAvailableId(clazz : Class<Dynamic>, value : String, db : Provider, cb : Int->Void){

    }
}