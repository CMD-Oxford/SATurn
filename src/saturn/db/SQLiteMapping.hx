/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

class SQLiteMapping {
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
    public static var models : Map<String,Map<String,Map<String,Dynamic>>> = [
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
                'constructComments' => 'CONSTRUCTCOMMENTS'
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
                '__HIDDEN__PKEY__' => 'id'
            ],
            'fields.synthetic' =>[
                'allele' => [ 'field' => 'alleleId', 'class' => 'saturn.core.domain.SgcAllele', 'fk_field' => 'id' ],
                'vector' => [ 'field' => 'vectorId', 'class' => 'saturn.core.domain.SgcVector', 'fk_field' => 'Id' ],
                'res1' => [ 'field' => 'res1Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'id'],
                'res2' => [ 'field' => 'res2Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'id'],
                'constructPlate' => [ 'field' => 'constructPlateId', 'class' => 'saturn.core.domain.SgcConstructPlate', 'fk_field' => 'id' ],
            ],
            'table_info' => [
                'schema' => 'SGC',
                'name' => 'CONSTRUCT'
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
            ],
            'table_info' => [
                'schema' => 'SGC',
                'name' => 'ALLELE'
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
            ]
        ],
        'saturn.core.domain.SgcVector'=>[
            'fields'=>[
                'vectorId'=>'VECTOR_NAME',
                'Id'=>'PKEY',
                'vectorSequence'=>'VECTORSEQUENCERAW',
                'vectorComments'=>'VECTORCOMMENTS',
                'proteaseName'=>'PROTEASE_NAME',
                'proteaseCutSequence'=>'PROTEASE_CUTSEQUENCE',
                'proteaseProduct'=>'PROTEASE_PRODUCT',
                'antibiotic'=>'ANTIBIOTIC',
                'organism'=>'ORGANISM',
                'res1Id'=>'SGCRESTRICTENZ1_PKEY',
                'res2Id'=>'SGCRESTRICTENZ2_PKEY'
            ],
            'indexes'=>[
                'vectorId'=>false,
                'Id'=>true
            ],
            'fields.synthetic' =>[
                'res1' => [ 'field' => 'res1Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'id' ],
                'res2' => [ 'field' => 'res2Id', 'class' => 'saturn.core.domain.SgcRestrictionSite', 'fk_field' => 'id' ]
            ],
            'table_info' => [
                'schema' => 'SGC',
                'name' => 'VECTOR'
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
            ]
        ],

        //Standard definitions

        'saturn.core.domain.SgcTarget'=>[
            'fields'=>[
                'targetId' => 'SEQUENCE_ID',
                'id' => 'PKEY',
                'dnaSeq' => 'DNA_SEQ',
                'proteinSeq' => 'PROTEIN_SEQ'
            ],
            'indexes'=>[
                'targetId'=>false,
                'id'=>true
            ],
            'table_info' => [
                'schema' => '',
                'name' => 'DNA',
            ],
            'model' => [
                'ID' => 'targetId',
                'DNA Sequence' => 'dnaSeq',
                'Protein Sequence' => 'proteinSeq',
                '__HIDDEN__PKEY__' => 'id'
            ],
            'selector' => [
                'polymorph_key' => 'POLYMORPH_TYPE',
                'value' => 'TARGET'
            ]
        ],
        'saturn.core.domain.SgcEntryClone'=>[
            'fields'=>[
                'entryCloneId'=>'SEQUENCE_ID',
                'id' => 'PKEY',
                'dnaSeq' => 'DNA_SEQ'
            ],
            'indexes'=>[
                'entryCloneId'=>false,
                'id'=>true
            ],
            'table_info' => [
                'schema' => '',
                'name' => 'DNA',
            ],
            'model' => [
                'ID' => 'entryCloneId',
                'DNA Sequence' => 'dnaSeq',
                '__HIDDEN__PKEY__' => 'id'
            ],
            'selector' => [
                'polymorph_key' => 'POLYMORPH_TYPE',
                'value' => 'ENTRY_CLONE'
            ]
    ]
    ];
}