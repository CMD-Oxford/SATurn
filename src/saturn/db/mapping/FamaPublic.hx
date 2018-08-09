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

class FamaPublic {
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
        models =  [
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
                'saturn.client.programs.DNASequenceEditor' => true
            ],
            'options' =>[
                'alias' => 'DNA'
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
                'saturn.client.programs.ProteinSequenceEditor' => true
            ],
            'options' =>[
                'alias' => 'Proteins'
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
        'saturn.app.SaturnClient'=>[
            'options'=>[
                'flags' =>[
                    'SGC' => true
                ]
            ]
        ],
        'saturn.core.domain.chromohub.Target'=>[
            'fields'=>[
                'id' => 'pkey',
                'targetId' => 'id',
                'symbol' => 'symbol',
                'geneId' => 'geneid',
                'uniprot' => 'uniprot'
            ],
            'indexes'=>[
                'targetId' => false,
                'id'=>true
            ],
            'search' => [
                'targetId'  => null,
                'symbol' => null,
                'geneId' => null,
                'uniprot' => null
            ],
            'table_info' => [
                'schema' => 'probes_tree2',
                'name' => 'target'
            ],
            'options'=>[
                'alias'=>'Genes'
            ]
        ],
        'saturn.app.ChromoHubClient'=>[
            'options'=>[
                'flags' =>[
                    'NO_LOGIN' => true
                ]
            ]
        ],
    ];
    }
}