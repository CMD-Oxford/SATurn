/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

import saturn.core.parsers.BaseParser;
import saturn.db.Model;
import saturn.db.Provider;

import saturn.core.Util.*;

using saturn.core.Util;

class MoleculeAnnotation {
    public var id : Int;
    public var entityId : Int;
    public var labelId : Int;
    public var start : Int;
    public var stop : Int;
    public var evalue : Float;
    public var altevalue : Float;

    public var entity : Entity;
    public var referent : Entity;

    public function new() {

    }
}

class Uploader {
    var referentMap : Map<String, Dynamic>;

    var provider : Provider;

    var generator : Generator<MoleculeAnnotation>;

    var initialised = false;

    var source : String;
    var cutoff : Float;

    public function new(source : String, evalue : Float){
        this.source = source;
        this.cutoff  = evalue;
    }

    public function next(items : Array<MoleculeAnnotation>, generator : Generator<MoleculeAnnotation>){
        this.generator = generator;

        if(initialised == false){
            provider = getProvider();

            setupReferentMap(function(err : String){
                if(err != null){
                    generator.die(err);
                }else{
                    initialised = true;

                    next(items, generator);
                }
            });
        }else{
            if(items.length == 0){
                return;
            }

            // Generate unique list of entities
            var ids = Model.generateUniqueListWithField(items, 'entity.entityId');
            // Generate unique list of referents
            var acList = Model.generateUniqueListWithField(items, 'referent.entityId');

            var newReferents = new Array<String>();
            for(id in acList){
                if(!referentMap.exists(id)){
                    newReferents.push(id);
                }
            }

            for(item in items){
                if(item.evalue > cutoff){
                    items.remove(item);
                }
            }

            // Insert referents into the database if they don't already exist
            insertReferents(newReferents, function(err : String){
                if(err != null){
                    generator.die(err);
                }else{
                    provider.insertObjects(items, function(err : String){
                        if(err != null){
                            generator.die(err);
                        }else{
                            generator.next();
                        }
                    });
                }
            });
        }
    }

    public function setupReferentMap(cb : String->Void){
        DataSource.getEntities(source, function(err : String, objs : Array<Entity>){
            if(err != null){
                cb(err);
            }else{
                referentMap = Model.generateIDMap(objs);

                cb(null);
            }
        });
    }

    private function insertReferents(accessions : Array<String>, cb : Dynamic){
        if(accessions.length ==0){
            cb(null);
        }else{
            Entity.insertList(accessions, source, function(err : String, objs : Array<Entity>){
                if(err == null){
                    for(obj in objs){
                        referentMap.set(obj.entityId, obj.id);
                    }
                }

                cb(err);
            });
        }
    }
}
