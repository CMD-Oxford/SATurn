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

class DataSource {
    public var id : Int;
    public var name : String;

    public function new() {

    }

    public static function getEntities(source : String, cb : String->Array<Entity>->Void){
        var p = getProvider();

        p.getById(source, DataSource, function(obj : DataSource, err : String){
            if(err != null){
                cb(err, null);
            }else if(obj == null){
                cb('Data source not found ' + source, null);
            }else{
                debug('Retreiving records for source ' + source);
                p.getByValues([Util.string(obj.id)], Entity, 'dataSourceId', function(objs : Array<Entity>, error : String){
                    debug('Entities retrieved for source ' + source);

                    if(error != null){
                        cb('An error occurred retrieving data source ' + source + ' entities\n'+error, null);
                    }else{
                        cb(null, objs);
                    }
                });
            }
        });
    }

    /**
    * @param source: Data source to insert
    * @param insert: Set to true to insert source if it doesn't already exist
    * @returns[0]: Error message if an error occurred
    * @returns[1]: DataSource obj or null if it doesn't exist and @param insert is False
    **/
    public static function getSource(source : String, insert : Bool, cb : String->DataSource->Void){
        var p = getProvider();

        p.getById(source, DataSource, function(obj : DataSource, err : String){
            if(err != null){
                cb('An error occurred looking for source: ' + source + '\n' + err, null);
            }else if(obj == null){
                if(insert){
                    var obj = new DataSource();
                    obj.name = source;

                    p.insert(source, function(err : String){
                        if(err != null){
                            cb('An error occurred inserting source: ' + source + '\n' + err, null);
                        }else{
                            p.getById(source, DataSource, function(obj : DataSource, err : String){
                                if(err != null){
                                    cb('An error occurred looking for source: ' + source + '\n' + err, null);
                                }else if(obj == null){
                                    cb('Inserted source ' + source + ' could not be found', null);
                                }else{
                                    cb(null, obj);
                                }
                            });
                        }
                    });
                }else{
                    cb(null, null);
                }
            }else{
                cb(null, obj);
            }
        });
    }




}
