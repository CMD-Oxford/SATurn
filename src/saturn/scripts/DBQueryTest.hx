/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.scripts;

import saturn.db.query_lang.Value;
import saturn.db.query_lang.Equals;
import saturn.db.query_lang.Field;
import saturn.core.domain.SgcTarget;
import saturn.db.query_lang.Query;
import saturn.client.core.CommonCore;
import js.Node;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class DBQueryTest extends BaseScript{
    @:async override function usage(){
        /*if(getArgCount() != 1){
            die('Usage\tParam 1\n');
        }else{
            var param = getArg(1);
        }*/
    }

    @:async override function run(){
        var query = new Query(provider);

        var target = new SgcTarget();
        target.targetId = 'BRD1A';

        //query.addExample(target);

        query.getSelect().add(new Field(saturn.core.domain.SgcTarget, 'targetId').add(new Equals(new Value('BRD1A'))));

        Node.console.log(nutil.inspect(query.getTokens(), {depth:null}));

        query.run(function(objs : Array<Dynamic>, err : String){
            print(objs);
            print(err);
        });
    }
}
