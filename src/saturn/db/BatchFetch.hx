/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

import saturn.client.core.CommonCore;

class BatchFetch {
    private var fetchList :Array<Map<String,Dynamic>>;
    private var userOnError : Dynamic;
    private var userOnComplete : Dynamic;
    private var position : Int;
    private var retrieved : Map<String,Dynamic>;
    public var onComplete : Dynamic;
    public var onError : Dynamic;
    public var provider : Provider;

    private var items : Map<String, Array<FetchItem>>;

    public function new(onError :Dynamic->String->Void){
        items = new Map<String, Array<FetchItem>>();

        fetchList = new Array<Map<String,Dynamic>>();
        retrieved = new Map<String, Dynamic>();
        position = 0;

        this.onError = onError;

        /*onError = function(obj,exception){
            if(exception != null){
                WorkspaceApplication.getApplication().showMessage('Data retrieval failure',exception);
            }else{
                WorkspaceApplication.getApplication().showMessage('Data retrieval failure','Unexpected exception has occurred');
            }
        }*/
    }

    public function onFinish(cb : Void->Void){
        onComplete = cb;
    }

    public function getById(objectId : String, clazz : Class<Dynamic>, key : String, callBack : Dynamic){
        var list = new Array<String>();
        list.push(objectId);

        return getByIds(list, clazz, key, callBack);
    }

    public function getByIds(objectIds :Array<String>, clazz : Class<Dynamic>, key : String, callBack : Dynamic){
        var work = new Map<String,Dynamic>();
        work.set('IDS', objectIds);
        work.set('CLASS',clazz);
        work.set('TYPE','getByIds');
        work.set('KEY',key);
        work.set('CALLBACK',callBack);

        fetchList.push(work);

        return this;
    }

    public function getByValue(value : String, clazz : Class<Dynamic>, field : String, key : String, callBack : Dynamic){
        var list = new Array<String>();
        list.push(value);

        return getByValues(list, clazz, field, key, callBack);
    }

    public function getByValues(values :Array<String>, clazz : Class<Dynamic>, field : String, key : String, callBack : Dynamic){
        var work = new Map<String,Dynamic>();
        work.set('VALUES', values);
        work.set('CLASS', clazz);
        work.set('FIELD', field);
        work.set('TYPE','getByValues');
        work.set('KEY',key);
        work.set('CALLBACK',callBack);

        fetchList.push(work);

        return this;
    }

    public function getByPkey(objectId : Dynamic, clazz : Class<Dynamic>, key : String, callBack : Dynamic){
        var list = new Array<String>();
        list.push(objectId);

        return getByPkeys(list, clazz, key, callBack);
    }

    public function getByPkeys(objectIds :Array<String>, clazz : Class<Dynamic>, key : String, callBack : Dynamic){
        var work = new Map<String,Dynamic>();
        work.set('IDS',objectIds);
        work.set('CLASS',clazz);
        work.set('TYPE','getByPkeys');
        work.set('KEY',key);
        work.set('CALLBACK',callBack);

        fetchList.push(work);

        return this;
    }



    public function append(val : String, field : String, clazz : Class<Dynamic>, cb : Dynamic->Void){
        var key = Type.getClassName(clazz) + '.' + field;

        if(!items.exists(key)){
            items.set(key, new Array<FetchItem>());
        }

        items.get(key).push({val:val, field:field, clazz:clazz, cb:cb});
    }

    public function next(){
        execute();
    }

    public function setProvider(provider : Provider){
        this.provider = provider;
    }

    public function execute(?cb : Void->Void){
        var provider = this.provider;

        if (provider == null){
            provider = CommonCore.getDefaultProvider();
        }

        if(cb != null){
            onFinish(cb);
        }

        for(key in items.keys()){
            var units = items.get(key);

            var work = new Map<String,Dynamic>();
            work.set('TYPE','FETCHITEM');
            work.set('FIELD', units[0].field);
            work.set('CLASS', units[0].clazz);
            work.set('ITEMS', units);

            items.remove(key);

            fetchList.push(work);
        }

        if(position == fetchList.length){
            onComplete();
            return;
        }



        var work = fetchList[position];
        var type = work.get('TYPE');

        position++;

        if(type == 'getByIds'){
            provider.getByIds(work.get('IDS'),work.get('CLASS'), function(objs, exception){
                if(exception!= null || objs == null){
                    onError(objs, exception);
                }else{
                    retrieved.set(work.get('KEY'),objs);
                    var userCallBack = work.get('CALLBACK');
                    if(userCallBack != null){
                        userCallBack(objs, exception);
                    }else{

                        if(position == fetchList.length){
                            onComplete();
                        }else{
                            execute();
                        }
                    }
                }
            });
        }else if(type == 'getByValues'){
            provider.getByValues(work.get('VALUES'),work.get('CLASS'), work.get('FIELD'), function(objs, exception){
                if(exception!= null || objs == null){
                    onError(objs, exception);
                }else{
                    retrieved.set(work.get('KEY'),objs);
                    var userCallBack = work.get('CALLBACK');
                    if(userCallBack != null){
                        userCallBack(objs, exception);
                    }else{

                        if(position == fetchList.length){
                            onComplete();
                        }else{
                            execute();
                        }
                    }
                }
            });
        }else if(type == 'getByPkeys'){
            provider.getByPkeys(work.get('IDS'),work.get('CLASS'), function(obj, exception){
                if(exception!= null || obj == null){
                    onError(obj, exception);
                }else{
                    retrieved.set(work.get('KEY'),obj);
                    var userCallBack = work.get('CALLBACK');
                    if(userCallBack != null){
                        userCallBack(obj, exception);
                    }else{

                        if(position == fetchList.length){
                            onComplete();
                        }else{
                            execute();
                        }
                    }
                }
            });
        }else if(type == 'FETCHITEM'){
            var items :Array<FetchItem> = work.get('ITEMS');

            var itemMap = new Map<String, Array<Dynamic->Void>>();
            for(item in items){
                if(!itemMap.exists(item.val)){
                    itemMap.set(item.val, new Array<Dynamic->Void>());
                }
                itemMap.get(item.val).push(item.cb);
            }

            var values = new Array<String>();
            for(key in itemMap.keys()){
                values.push(key);
            }

            var field = work.get('FIELD');
            provider.getByValues(values, work.get('CLASS'), field, function(objs : Array<Dynamic>, exception){
                if(exception!= null || objs == null){
                    onError(objs, exception);
                }else{
                    for(obj in objs){
                        var fieldValue = Reflect.field(obj, field);

                        if(itemMap.exists(fieldValue)){
                            for(cb in itemMap.get(fieldValue)){
                                cb(obj);
                            }
                        }
                    }

                    if(position == fetchList.length){
                        onComplete();
                    }else{
                        execute();
                    }
                }
            });
        }
    }

    public function getObject(key : String){
        return retrieved.get(key);
    }
}


typedef FetchItem = {
    var val : String;
    var field : String;
    var clazz : Class<Dynamic>;
    var cb : Dynamic->Void;
};