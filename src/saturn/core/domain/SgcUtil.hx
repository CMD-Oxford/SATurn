/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;
import saturn.db.query_lang.ToNumber;
import saturn.db.query_lang.Trim;
import saturn.db.query_lang.Or;
import saturn.db.query_lang.Max;
import saturn.db.query_lang.Value;
import saturn.db.query_lang.Field;
import saturn.db.query_lang.Query;
import saturn.db.query_lang.CastAsInt;
import saturn.db.Provider;
class SgcUtil {
    public function new() {

    }

    public static function generateNextIDForClasses(provider : Provider, targets : Array<String>, clazzes : Array<Class<Dynamic>>,cb: Map<String, Map<String, Int>>->String->Void){
        var classToIds = new Map<String, Map<String, Int>>();

        var next = null;
        next = function(){
            var clazz = clazzes.pop();

            SgcUtil.generateNextID(provider, targets, clazz, function(map, error){
                if(error != null){
                    cb(null, error);
                }else{
                    classToIds.set(Type.getClassName(clazz), map);
                    if(clazzes.length == 0){
                        cb(classToIds, null);
                    }else{
                        next();
                    }
                }
            });
        };

        next();
    }

    public static function generateNextID(provider : Provider, targets : Array<String>, clazz : Class<Dynamic>,cb: Map<String, Int>->String->Void){
        //Sub-Query to separate SGC IDs into Target and INT component
        var q = new Query(provider);

        var s = q.getSelect();

        var model = provider.getModel(clazz);

        //Reference to ID field
        var idField = new Field(clazz,model.getFirstKey());

        //Extract target name from ID
        q.getSelect().add(idField.substr(1,idField.instr('-',1).minus(1)).as('target'));
        // was
        //q.getSelect().add(idField.substr(0,idField.instr('-',1)).as('target'));

        //Extract INT component from ID
        q.getSelect().add(idField.substr(idField.instr('-',1).plus(2),idField.length()).as('ID'));

        //Constrain to target
        for(i in 0...targets.length){
            var target = targets[i];

            q.getWhere().add(idField.like(new Value(target).concat('%')));

            if(i < targets.length-1){
                q.getWhere().addToken(new Or());
            }
        }

        //Outter query to perform group by and max
        var q2 = new Query(provider);

        //Don't attempt to map results to a class
        q2.fetchRawResults();

        //Select Target split from ID using inner query
        q2.getSelect().add(new Field(null, 'target','a').as('targetName'));

        //Select Max INT component using inner query
        q2.getSelect().add(new Trim(new Max(new ToNumber(new Field(null,'ID','a')))).as('lastId'));

        //Add inner query and alias as a
        q2.getFrom().add(q.as('a'));

        //Group by Target split from ID using inner query
        q2.getGroup().add(new Field(null, 'target','a'));

        q2.run(function(objs : Array<Dynamic>, err : String){
            if(err != null){
                cb(null, err);
            }else{
                var map = new Map<String,Int>();

                for(obj in objs){
                    var nextId :Dynamic= Std.parseInt(obj.lastId)+1;
                    if(Math.isNaN(nextId) || nextId == null || nextId == 'null'){
                        nextId = 0;
                    }

                    Reflect.setField(obj, 'lastId', nextId);

                    Util.debug(obj.targetName);

                    map.set(obj.targetName, obj.lastId);
                }

                for(target in targets){
                    if(!map.exists(target)){
                        map.set(target, 1);
                    }
                }

                cb(map, null);
            }
        });
    }
}
