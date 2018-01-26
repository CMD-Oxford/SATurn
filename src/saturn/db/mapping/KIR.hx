/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.mapping;

class KIR {
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
            'saturn.core.scarab.LabPage'=>[
                'fields'=>[
                    'experimentNo'=>'Experiment_No',
                    'id'=>'Id',
                    'dateStarted'=>'Date_Started',
                    'title'=>'Title',
                    'userId'=>'UserId',
                    'elnDocumentId'=>'ELNDOCUMENTID',
                    'minEditableItem'=>'Min_Editable_Item',
                    'lastEdited'=>'Last_Edited',
                    'user'=>'User',
                    'sharingAllowed'=>'SharingAllowed',
                    'personalTemplate'=>'PersonalTemplate',
                    'globalTemplate'=>'GlocalTemplate',
                    'dateExperimentStarted'=>'Date_ExperimentStarted',
                ],
                'defaults' => [
                    'sharingAllowed'    =>  'NO',
                    'personalTemplate'  =>  'NO',
                    'globalTemplate'    =>  'NO'
                ],
                'required'=>[
                    'id' => '1',
                    'experimentNo' => '1'
                ],
                'table_info' => [
                    'schema' => 'icmdb_page_secure',
                    'name' => 'V_LABPAGE'
                ],
                'model' => [
                    'Experiment No' => 'experimentNo',
                    'ID' => 'id',
                    'Date Started' => 'dateStarted',
                    'Title' => 'title',
                    'User ID' => 'userId',
                    'ELN Document ID' => 'elnDocumentId',
                    'Min Editable Item' => 'minEditableItem',
                    'Last Edited' => 'lastEdited',
                    'User' => 'user',
                    'Sharing Allowed' => 'sharingAllowed',
                    'Personal Template' => 'personalTemplate',
                    'Global Template' => 'globalTemplate',
                    'Date Experiment Started' => 'dateExperimentStarted'
                ],
                'indexes'=>[
                    'experimentNo'=>false,
                    'id'=>true
                ],
                'fields.synthetic' =>[
                    'items' => [ 'field' => 'id', 'class' => 'saturn.core.scarab.LabPageItem', 'fk_field' => 'labPage' ],
                    'userObj' => [ 'field' => 'user', 'class' => 'saturn.core.scarab.LabPageUser', 'fk_field' => 'id' ],
                ],
                'options' => [
                    'id_pattern' => 'PAGE.+',
                    'icon' => 'structure_16.png',
                    'workspace_wrapper' => 'saturn.client.workspace.ScarabELNWO',
                    'alias' => 'ELN',
                    'display_field' => 'title',

                ],
                'search' => [
                    'title' => null,
                    'userObj.fullName' => null
                ],
                'programs'=>[
                    'saturn.client.programs.ScarabELNViewer' => true
                ]
            ],
             'saturn.core.scarab.LabPageItem'=> [
                 'fields'=>[
                    'labPage' => 'Labpage',
                    'order' => 'Num',
                    'id' => 'Id',
                    'name' => 'Name',
                    'caption' => 'Caption',
                    'userId' => 'UserId',
                    'elnSectionId' => 'ELN_SECTIONID',
                    'mergePrev' => 'Merge_Prev',
                    'user' => 'User'
                 ],
                'table_info' => [
                    'schema' => 'icmdb_page_secure',
                    'name' => 'V_LABPAGE_ITEM'
                 ],
                'indexes' => [
                    'id' => true
                ],
                'polymorphic' =>[
                    'field' => 'id',
                    'fk_field' => 'id',
                    'selector_field' => 'name',
                    'selector_values' => [
                        'LABPAGE_TEXT' => 'saturn.core.scarab.LabPageText',
                        'LABPAGE_EXCEL' => 'saturn.core.scarab.LabPageExcel',
                        'LABPAGE_IMAGE' => 'saturn.core.scarab.LabPageImage'
                    ]
                ]
             ],
            'saturn.core.scarab.LabPageUser'=>[
                'fields'=>[
                    'id' => 'Id',
                    'fullName' => 'Full_Name'
                ],
                'table_info' => [
                    'schema' => 'icmdb_page_secure',
                    'name' => 'V_USERS2'
                 ],
                'indexes' => [
                    'id' => true
                ]
            ],
             'saturn.core.scarab.LabPageText'=>[
                'fields'=>[
                    'id' => 'Id',
                    'content' => 'Content'
                ],
                'table_info' => [
                    'schema' => 'icmdb_page_secure',
                    'name' => 'V_LABPAGE_TEXT'
                 ],
                'indexes' => [
                    'id' => true
                ]
            ],
            'saturn.core.scarab.LabPageImage' => [
                'fields' => [
                    'id' => 'Id',
                    'imageEdit' => 'Image_Edit',
                    'imageAnnot' => 'Image_Annot',
                    'vectorized' => 'Vectorized',
                    'elnProperties' => 'ELN_PROPERTIES',
                    'annotTexts' => 'AnnotTexts',
                    'wmf' => 'WMF'
                ],
                'table_info' => [
                    'schema' => 'icmdb_page_secure',
                    'name' => 'V_LABPAGE_IMAGE'
                ],
                'indexes' => [
                    'id' => true
                ]
            ],
            'saturn.core.scarab.LabPagePdf'=>[
                'fields' => [
                    'id' => 'Id',
                    'pdf' => 'PDF',
                    'image' => 'Image'
                ],
                'table_info' =>[
                    'schema' => 'icmdb_page_secure',
                    'name' => 'V_LABPAGE_PDF'
                ],
                'indexes' => [
                    'id' => true
                ]
            ],
            'saturn.core.scarab.LabPageExcel' => [
                'fields' => [
                    'id' => 'Id',
                    'excel' => 'Excel',
                    'filename' => 'Filename',
                    'html' => 'Html',
                    'htmlFolder' => 'HtmlFolder'
                ],
                'table_info' => [
                    'schema' => 'icmdb_page_secure',
                    'name' => 'V_LABPAGE_EXCEL'
                ],
                'indexes' => [
                    'id' => true
                ]
            ],
            'saturn.core.scarab.LabPageAttachments' => [
                'fields' => [
                    'id' => 'Id',
                    'displayOrder' => 'num',
                    'filename' => 'Filename',
                    'content' => 'Content',
                    'modifiedInICMdb' => 'ModifiedInICMdb'
                ],
                'table_info' => [
                    'schema' => 'icmdb_page_secure',
                    'name' => 'V_LABPAGE_ATT'
                ],
                'indexes' => [
                    'id' => true,
                    'displayOrder' => true
                ]
            ],'saturn.core.domain.FileProxy'=>[
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
                        'WORK' => '^W:[^\\.]+.pdb$',
                        //'SHARE' => '^S:'
                    ],
                    'linux_conversions' => [
                        'W:' => '/work'
                    ],
                    'linux_allowed_paths_regex' => [
                        'WORK' => '^/work'
                    ]
                ]
            ]
        ];
    }
}