/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

import saturn.core.Util.*;

using saturn.core.Util;

class Entity {
    public var id : Int;
    public var entityId : String;
    public var dataSourceId : Int;
    public var reactionId : Int;
    public var entityTypeId : Int;
    public var altName : String;
    public var description : String;

    public var source : DataSource;
    public var reaction : Reaction;
    public var entityType : EntityType;

    public function new() {

    }

    public static function insertList(ids : Array<String>, source : String, cb : String->Array<Entity>->Void){
        // Make list unique
        var uqx = new Map<String, String>();
        for(id in ids){
            uqx.set(id, id);
        }

        ids = new Array<String>();
        for(id in uqx.keys()){
            ids.push(id);
        }

        DataSource.getSource(source, false, function(err : String, sourceObj : DataSource){
            if(err != null){
                cb(err, null);
            }else if(sourceObj == null){
                cb('Unable to find source ' + source, null);
            }else{
                var objs = new Array<Entity>();
                for(id in ids){
                    var entity = new Entity();
                    entity.entityId = id;
                    entity.dataSourceId = sourceObj.id;

                    objs.push(entity);
                }

                var p = getProvider();
                p.insertObjects(objs, function(err : String){
                    if(err != null){
                        cb('An error occurred inserting entities\n'+err,null);
                    }else{
                        p.getByIds(ids, Entity, function(objs : Array<Entity>, err : String){
                            if(err != null){
                                cb('An error occurred looking for inserted objects\n'+err, null);
                            }else{
                                cb(null, objs);
                            }
                        });
                    }
                });
            }
        });
    }

    public static function getObjects(ids : Array<String>, cb : String->Array<Entity>->Void){
        var p = getProvider();

        p.getByIds(ids, Entity, function(objs: Array<Entity>, err : String){
            if(err != null){
                cb(err, null);
            }else{
                cb(null, objs);
            }
        });
    }
}
