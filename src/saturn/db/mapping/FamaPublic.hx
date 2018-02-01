/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
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
    public static var models : Map<String,Map<String,Map<String,Dynamic>>> = [
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
        'saturn.core.domain.TextFile' =>[
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
        ]
    ];
}