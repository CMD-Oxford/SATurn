/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

import saturn.db.mapping.SGC;
import saturn.db.DefaultProvider;

import saturn.client.ICMClient;

class ScarabProvider extends DefaultProvider{
    public function new(){
        super(new SGC().models,null, false);
    }

    override public function _getByIds(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic) : Void{
        if(ids.length > 0){
            var className = Type.getClassName(clazz);

            ICMClient.getClient().callFunction(
                'sgc.Provider.getByIds',

                [className,ids],

                function(data : Dynamic){
                    var list = parseObjectList(data);

                    callBack(list,null);
                },

                function(exception : Dynamic){
                    callBack(null, exception);
                }
            );
        }else{
            callBack(null,null);
        }
    }

    override public function _getByValues(values : Array<String>, clazz : Class<Dynamic>, field : String, callBack : Dynamic) : Void{
        if(values.length > 0){
            var className = Type.getClassName(clazz);

            ICMClient.getClient().callFunction(
                'sgc.Provider.getByValues',

                [className,values, field],

                function(data : Dynamic){
                    var list = parseObjectList(data);

                    callBack(list,null);
                },

                function(exception : Dynamic){
                    callBack(null, exception);
                }
            );
        }else{
            callBack(null,null);
        }
    }

    override private function _getByPkeys(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic){
        if(ids.length > 0){
            var className = Type.getClassName(clazz);

            ICMClient.getClient().callFunction(
                'sgc.Provider.getByPkeys',

                [className,ids],

                function(data : Dynamic){
                    var list = parseObjectList(data);

                    callBack(list,null);
                },

                function(exception : Dynamic){
                    callBack(null, exception);
                }
            );
        }else{
            callBack(null,null);
        }
    }

    override private function _getByIdStartsWith(id : String, field : String, clazz : Class<Dynamic>, limit : Int, callBack : Dynamic) : Void{
        var className = Type.getClassName(clazz);

        ICMClient.getClient().callFunction(
            'sgc.Provider.getByIdStartsWith',

            [className,id],

            function(data : Dynamic){
                var list = parseObjectList(data);

                callBack(list,null);
            },

            function(exception : Dynamic){
                callBack(null, exception);
            }
        );
    }

    override public function _getByNamedQuery(queryId : String, parameters : Array<Dynamic>, clazz : Class<Dynamic>, callBack : Dynamic) : Void{
        var className = Type.getClassName(clazz);

        ICMClient.getClient().callFunction(
            'sgc.Provider.getByNamedQuery',

            [queryId,parameters],

            function(data : Dynamic){
                var list = parseObjectList(data);

                callBack(list,null);
            },

            function(exception : Dynamic){
                callBack(null, exception);
            }
        );
    }

    /**
    * We submit in blocks as the Scarab terminal has a limit on the number of
    * lexed words it can cope with from a single command.
    *
    * The limit below is bound to fail at some point
    **/
    override public function _update(attributeMaps : Array<Map<String, Dynamic>>,className : String,  callBack : Dynamic) : Void{
        var limit = 20;
        var n = attributeMaps.length;
        var i = 0;

        var next = null;

        var jobFunc = function(){
            var part = attributeMaps.splice(0, limit);

            i += limit;

            ICMClient.getClient().callFunction(
                'sgc.Provider.update',

                [className,part],

                function(data : Dynamic){
                    var err = ICMClient.getError(data);
                    if(err != null){
                        callBack(err);return;
                    }else{
                        if(i >= n){
                            callBack(null);
                        }else{
                            next();
                        }
                    }
                },

                function(exception : Dynamic){
                    callBack(exception);
                }
            );
        };

        next = jobFunc;

        next();
    }

    /**
    * We submit in blocks as the Scarab terminal has a limit on the number of
    * lexed words it can cope with from a single command.
    *
    * The limit below is bound to fail at some point
    **/
    override public function _insert(attributeMaps : Array<Map<String, Dynamic>>,className : String,  callBack : Dynamic) : Void{
        var limit = 20;
        var n = attributeMaps.length;
        var i = 0;

        var next = null;

        var jobFunc = function(){
            var part = attributeMaps.splice(0, limit);

            i += limit;

            ICMClient.getClient().callFunction(
                'sgc.Provider.insert',

                [className,part],

                function(data : Dynamic){
                    var err = ICMClient.getError(data);
                    if(err != null){
                        callBack(err);
                    }else{
                        if(i >= n){
                            callBack(null);
                        }else{
                            next();
                        }
                    }
                },

                function(exception : Dynamic){
                    callBack(exception);
                }
            );
        };

        next = jobFunc;

        next();
    }

    override public function _delete(attributeMaps : Array<Map<String, Dynamic>>,className : String,  callBack : Dynamic) : Void{
        ICMClient.getClient().callFunction(
            'sgc.Provider.delete',

            [className,attributeMaps],

            function(data : Dynamic){
                var err = ICMClient.getError(data);
                if(err != null){
                    callBack(err);
                }else{
                    callBack(null);
                }
            },

            function(exception : Dynamic){
                callBack(exception);
            }
        );
    }

    override public function _rollback(callBack : Dynamic) : Void{
        ICMClient.getClient().callFunction(
            'sgc.Provider.rollback',

            [],

            function(data : Dynamic){
                var err = ICMClient.getError(data);
                if(err != null){
                    callBack(err);
                }else{
                    callBack(null);
                }
            },

            function(exception : Dynamic){
                callBack(exception);
            }
        );
    }

    override public function _commit(callBack : Dynamic) : Void{
        ICMClient.getClient().callFunction(
            'sgc.Provider.commit',

            [],

            function(data : Dynamic){
                var err = ICMClient.getError(data);
                if(err != null){
                    callBack(err);
                }else{
                    callBack(null);
                }
            },

            function(exception : Dynamic){
                callBack(exception);
            }
        );
    }

    private function parseObjectList(data) : Array<Dynamic>{
        if(data != null && ICMClient.instanceOf(data,'ObjectList')){
            if(Reflect.hasField(data,'POS')){
                var size = Reflect.field(data,'POS');
                if(size > 0){
                    var items = Reflect.field(data,'ITEMS');

                    var list = new Array<Dynamic>();
                    for(i in 1...size+1){
                        list.push(Reflect.field(items,Std.string(i)));
                    }
                    return list;
                }else{
                    return null;
                }
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
}