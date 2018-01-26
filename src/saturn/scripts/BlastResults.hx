/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.scripts;

import saturn.core.Util;
import saturn.client.core.CommonCore;
import js.Node;

using com.dongxiguo.continuation.utils.Generator;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class BlastResults extends BaseScript{
    var inputFile : String = null;
    var c1 : Dynamic;

    @:async override function usage(){
        if(getArgCount() != 1){
            die('Usage\tGene List\n');
        }else{
            inputFile = getArg(1);
        }
    }

    function getXRefs(geneid : String, cb : String->Array<Dynamic>->Void){
        conn.execute(
            "SELECT
                a.EXTERNAL_ID,
                a.DESCRIPTION
            FROM
                SGC.DATASOURCE_ENTITIES a,
                SGC.DATASOURCE b,
                SGC.GENE_XREF c
            WHERE
                c.NCBIGENEID = :0 AND
                a.PKEY = c.DATASOURCE_TERM_PKEY AND
                a.DATASOURCE_PKEY = b.PKEY AND
                b.NAME = 'REFSEQ_PROTEIN'",
            [geneid],
            cb
        );
    }

    override function run(cb : Void->Void){
        var c1 = channel(function(codes : Array<String>){


        }, cb);

        parseFile(function(){});
    }

    @:async function parseFile(){
        var err : NodeErr, line : String = @await open(inputFile);

        if(line == null){
            c1.finished();
        }else{
            c1.push(line);
        }
    }
}
