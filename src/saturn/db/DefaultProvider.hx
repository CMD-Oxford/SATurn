/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

import saturn.db.provider.GenericRDBMSProvider;
import saturn.db.query_lang.Query;

import saturn.core.User;
import saturn.db.Model;
import saturn.db.Provider;

import saturn.core.Util.*;

import haxe.Serializer;
import haxe.Unserializer;

#if SERVER_SIDE
import bindings.NodeTemp;
import js.Node;
import saturn.app.SaturnServer;
import js.html.ArrayBuffer;
#elseif CLIENT_SIDE
import js.html.ArrayBuffer;
#end

import haxe.crypto.Md5;
import saturn.core.Util.*;
import saturn.core.Util;

@:keep
class DefaultProvider implements Provider{
    public var theBindingMap : Map<String,Map<String,Map<String,Dynamic>>>;

    var fieldIndexMap : Map<String, Map<String,String>>; // Map<Class,Map<Field,NULL>
    var objectCache : Map<String,Map<String,Map<String,Dynamic>>>; //Map<Class,Map<Field,Map<Value,Object>

    var namedQueryCache : Map<String, NamedQueryCache>;

    var useCache = true;
    var enableBinding = true;
    var connectWithUserCreds = false;

    var namedQueryHooks : Map<String, Dynamic> = new Map<String, Dynamic>();
    var namedQueryHookConfigs: Map<String, Dynamic> = new Map<String, Dynamic>();

    var modelClasses : Array<Model>;

    var user : User = null;

    var autoClose : Bool;

    var name : String;

    var config : Dynamic;

    var winConversions : Map<String, String>;
    var linConversions : Map<String, String>;
    var conversions : Map<String, String>;
    var regexs : Map<String, EReg>;

    var platform : String;

    static var r_date =~/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.000Z/;

    public function new(binding_map : Map<String,Map<String,Map<String,Dynamic>>>, config : Dynamic, autoClose : Bool){
        setPlatform();

        if(binding_map != null){
            setModels(binding_map);
        }

        this.config = config;
        this.autoClose = autoClose;

        namedQueryHooks = new Map<String, Dynamic>();

        if(config != null && Reflect.hasField(config, 'named_query_hooks')){
            addHooks(Reflect.field(config, 'named_query_hooks'));
        }

        for(hook in namedQueryHooks.keys()){
            debug('Installed hook: ' + hook + '/' + namedQueryHooks.get(hook));
        }

    }

    public function setPlatform(){
        return null;
    }

    public function generateQualifiedName(schemaName : String, tableName : String) : String{
        return null;
    }

    public function getConfig() : Dynamic{
        return config;
    }

    public function setConfig(config : Dynamic){
        this.config = config;
    }

    public function setName(name : String) : Void{
        this.name = name;
    }

    public function getName() : String {
        return this.name;
    }

    public function setUser(user : User) : Void {

        this.user = user;

        _closeConnection();
    }

    public function getUser() : User {
        return this.user;
    }

    public  function closeConnection(connection : Dynamic){
        if(autoClose){
            _closeConnection();
        }
    }

    public function _closeConnection(){

    }

    public function generatedLinkedClone() : Provider{
        var clazz = Type.getClass(this);

        var provider : DefaultProvider = Type.createEmptyInstance(clazz);

        provider.theBindingMap = theBindingMap;
        provider.fieldIndexMap = fieldIndexMap;
        provider.namedQueryCache = namedQueryCache;
        provider.useCache = useCache;
        provider.enableBinding = enableBinding;
        provider.connectWithUserCreds = connectWithUserCreds;
        provider.namedQueryHooks = namedQueryHooks;
        provider.modelClasses = modelClasses;
        provider.platform = platform;
        provider.linConversions = linConversions;
        provider.winConversions = winConversions;
        provider.conversions = conversions;
        provider.regexs = regexs;
        provider.namedQueryHookConfigs = namedQueryHookConfigs;
        provider.config = config;
        provider.objectCache = new Map<String,Map<String,Map<String,Dynamic>>>();

        return provider;
    }

    public function enableCache(cached : Bool) : Void{
        this.useCache = cached;
    }

    public function connectAsUser() : Bool{
        return connectWithUserCreds;
    }

    public function setConnectAsUser(asUser : Bool){
        connectWithUserCreds = asUser;
    }

    public function setModels(binding_map : Map<String,Map<String,Map<String,Dynamic>>>){
        theBindingMap = binding_map;

        for(clazz in binding_map.keys()){
            //Internally the same code that handles synthetic fields deals with polymorphic classes so merge here
            if(binding_map.get(clazz).exists('polymorphic')){
                if(!binding_map.get(clazz).exists('fields.synthetic')){
                    binding_map.get(clazz).set('fields.synthetic', new Map<String,Dynamic>());
                }

                var d:Dynamic = binding_map.get(clazz).get('fields.synthetic');
                d.set('polymorphic',binding_map.get(clazz).get('polymorphic') );
            }
        }

        initModelClasses();

        resetCache();
    }

    public function readModels(cb : String->Void) : Void{

    }

    public function postConfigureModels(){
        for(class_name in theBindingMap.keys()){
            var d:  Map<String, Dynamic> = theBindingMap.get(class_name);
            d.set('provider_name', getName());

            Util.debug(class_name + ' on ' + getName());
        }

        if(isModel(saturn.core.domain.FileProxy)){
            winConversions = getModel(saturn.core.domain.FileProxy).getOptions().get('windows_conversions');
            linConversions = getModel(saturn.core.domain.FileProxy).getOptions().get('linux_conversions');

            if(platform == 'windows'){
                conversions = winConversions;

                regexs = getModel(saturn.core.domain.FileProxy).getOptions().get('windows_allowed_paths_regex');
            }else if(platform == 'linux'){
                conversions = linConversions;
                regexs = getModel(saturn.core.domain.FileProxy).getOptions().get('linux_allowed_paths_regex');
            }

            if(regexs != null){
                for(key in regexs.keys()){
                    var s : String = cast(regexs.get(key), String);
                    regexs.set(key, new EReg(s, ''));
                }
            }
        }
    }

    public function getModels() : Dynamic{
        return theBindingMap;
    }

    public function resetCache(){
        objectCache = new Map<String,Map<String,Map<String,Dynamic>>>();

        if(theBindingMap != null){
            for(className in theBindingMap.keys()){
                theBindingMap.get(className).set('statements', new Map<String,Dynamic>());

                objectCache.set(className,new Map<String,Map<String,Dynamic>>());
                if(theBindingMap.get(className).exists('indexes')){
                    for(field in theBindingMap.get(className).get('indexes').keys()){
                        objectCache.get(className).set(field, new Map<String,Dynamic>());
                    }
                }
            }
        }

        namedQueryCache = new Map<String,NamedQueryCache>();
    }

    public function getObjectFromCache<T>(clazz : Class<Dynamic>, field : String, val : Dynamic) : T{
        var className = Type.getClassName(clazz);
        if(objectCache.exists(className)){
            if(objectCache.get(className).exists(field)){
                if(objectCache.get(className).get(field).exists(val)){
                    return objectCache.get(className).get(field).get(val);
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

    private function initialiseObjects(idsToFetch : Array<String>, toBind : Array<Dynamic>, prefetched : Array<Dynamic>, exception :String, callBack : Dynamic, clazz :Class<Dynamic>, bindField : String, cache : Bool, allowAutoBind = true){
        if(
            (idsToFetch.length > 0 && toBind == null)
                || clazz == null
                    || (toBind != null && toBind.length > 0 && clazz != null && Std.is(toBind[0], clazz))
        ){
            callBack(toBind, exception);
        }else{
            var model = getModel(clazz);

            if(model == null){
                var boundObjs = new Array<Dynamic>();

                for(item in toBind){
                    var obj = Type.createInstance(clazz, []);

                    for(field in Type.getInstanceFields(clazz)){
                        if(Reflect.hasField(item, field)){
                            Reflect.setField(obj, field, Reflect.field(item, field));
                        }
                    }

                    boundObjs.push(obj);
                }

                callBack(boundObjs, exception);

                return;
            }

            var autoActivate = model.getAutoActivateLevel();

            var surpressSetup = false;

            if(autoActivate != -1 && enableBinding && allowAutoBind){
                surpressSetup = true;
            }

            var boundObjs = new Array<Dynamic>();

            if(toBind != null){
                for(obj in toBind){
                    boundObjs.push(bindObject(obj, clazz, cache, bindField, surpressSetup));
                }
            }

            if(autoActivate != -1 && enableBinding && allowAutoBind){
                activate(boundObjs, autoActivate, function(err){
                    if(err == null){
                        for(boundObj in boundObjs){
                            if(Reflect.isFunction(boundObj.setup)){
                                boundObj.setup();
                            }
                        }

                        if(prefetched != null){
                            for(obj in prefetched){
                                boundObjs.push(obj);
                            }
                        }

                        callBack(boundObjs,exception);
                    }else{
                        callBack(null, err);
                    }
                });
            }else{
                if(prefetched != null){
                    for(obj in prefetched){
                        boundObjs.push(obj);
                    }
                }

                callBack(boundObjs,exception);
            }
        }
    }

    public function getById(id : String, clazz : Class<Dynamic>, callBack : Dynamic) : Void{
        getByIds([id],clazz,function(objs, exception){
            if(objs != null){
                callBack(objs[0],exception);
            }else{
                callBack(null,exception);
            }
        });
    }

    public function getByIds(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic) : Void{
        var prefetched = null;
        var idsToFetch = null;

        if(useCache){
            var model = getModel(clazz);
            if(model != null){
                var firstKey = model.getFirstKey();
                prefetched = new Array<Dynamic>();
                idsToFetch = new Array<String>();

                for(id in ids){
                    var cacheObject = getObjectFromCache(clazz, firstKey, id);
                    if(cacheObject != null){
                        prefetched.push(cacheObject);
                    }else{
                        idsToFetch.push(id);
                    }
                }
            }else{
                idsToFetch = ids;
            }
        }else{
            idsToFetch = ids;
        }

        if(idsToFetch.length > 0){
            _getByIds(idsToFetch, clazz, function(toBind : Array<Dynamic>, exception){
                initialiseObjects(idsToFetch, toBind, prefetched, exception, callBack, clazz, null, true);
            });
        }else{
            callBack(prefetched, null);
        }
    }

    private function _getByIds(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic){

    }

    public function getByExample(obj : Dynamic, cb : Dynamic = null) : Query{
        var q = getQuery();

        q.addExample(obj);

        //query(q, cb);

        q.run(cb);

        return q;
    }

    public function query(query : Query, cb : Array<Dynamic>->Dynamic->Void){
        _query(query, function(objs :Array<Dynamic>, err){
            if(isDataBinding()){
                if(err == null){
                    var clazzList : Array<String> = query.getSelectClassList();
                    if(query.bindResults() && clazzList != null){
                        if(clazzList.length == 1){
                            initialiseObjects([], objs, [], err, cb,Type.resolveClass(clazzList[0]), null, true);
                        }
                    }else{
                        cb(objs, err);
                    }
                }else{
                    cb(null, err);
                }
            }else{
                cb(objs, err);
            }
        });
    }

    private function _query(query : Query, cb : Array<Dynamic>->Dynamic->Void){

    }

    public function getByValue(value : String, clazz : Class<Dynamic>, field : String, callBack : Dynamic) : Void{
        getByValues([value],clazz, field, function(objs, exception){
            if(objs != null){
                callBack(objs[0],exception);
            }else{
                callBack(null,exception);
            }
        });
    }

    public function getByValues(ids : Array<String>, clazz : Class<Dynamic>, field : String, callBack : Dynamic) : Void{
        var prefetched = null;
        var idsToFetch = null;

        debug('Using cache ' + useCache);

        if(useCache){
            debug('Using cache ' + useCache);

            var model = getModel(clazz);
            if(model != null){
                prefetched = new Array<Dynamic>();
                idsToFetch = new Array<String>();

                for(id in ids){
                    var cacheObject = getObjectFromCache(clazz, field, id);

                    if(cacheObject != null){
                        if(Std.is(cacheObject, Array)){
                            var objArray : Array<Dynamic> = cacheObject;
                            for(obj in objArray){
                                prefetched.push(obj);
                            }
                        }else{
                            prefetched.push(cacheObject);
                        }
                    }else{
                        idsToFetch.push(id);
                    }
                }
            }else{
                idsToFetch = ids;
            }
        }else{
            idsToFetch = ids;
        }

        if(idsToFetch.length > 0){
            _getByValues(idsToFetch, clazz, field, function(toBind : Array<Dynamic>, exception){
                initialiseObjects(idsToFetch, toBind, prefetched, exception, callBack, clazz, field, true);
            });
        }else{
            callBack(prefetched, null);
        }
    }

    private function _getByValues(values : Array<String>, clazz : Class<Dynamic>, field : String, callBack : Dynamic){

    }

    public function getObjects(clazz : Class<Dynamic>, callBack : Dynamic) : Void{
        _getObjects(clazz,function(toBind : Array<Dynamic>, exception){
            if(exception != null){
                callBack(null, exception);
            }else{
                initialiseObjects([], toBind, [], exception, callBack, clazz, null, true);
            }
        });
    }

    private function _getObjects(clazz : Class<Dynamic>, callBack : Dynamic){

    }

    public function getByPkey(id : String, clazz : Class<Dynamic>, callBack : Dynamic) : Void{
        getByPkeys([id],clazz,function(objs, exception){
            if(objs != null){
                callBack(objs[0],exception);
            }else{
                callBack(null, exception);
            }
        });
    }

    public function getByPkeys(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic) : Void{
        var prefetched = null;
        var idsToFetch = null;

        if(useCache){
            var model = getModel(clazz);
            if(model != null){
                var priField = model.getPrimaryKey();
                prefetched = new Array<Dynamic>();
                idsToFetch = new Array<String>();

                for(id in ids){
                    var cacheObject = getObjectFromCache(clazz, priField, id);
                    if(cacheObject != null){
                        prefetched.push(cacheObject);
                    }else{
                        idsToFetch.push(id);
                    }
                }
            }else{
                idsToFetch = ids;
            }
        }else{
            idsToFetch = ids;
        }

        if(idsToFetch.length > 0){
            _getByPkeys(idsToFetch, clazz, function(toBind : Array<Dynamic>, exception){
                initialiseObjects(idsToFetch, toBind, prefetched, exception, callBack, clazz, null, true);
            });
        }else{
            callBack(prefetched, null);
        }
    }

    private function _getByPkeys(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic){

    }

    public function getConnection(config : Dynamic, cb : String->Connection->Void) : Void{

    }

    public function sql(sql, parameters, cb : String->Dynamic->Void){
        getByNamedQuery('saturn.db.provider.hooks.RawSQLHook:SQL', [sql, parameters], null, false, cb);
    }

    public function getByNamedQuery(queryId : String, parameters : Dynamic, clazz : Class<Dynamic>, cache : Bool,callBack : Dynamic){
        debug('In getByNamedQuery ' + cache);
        try{
            if(cache){
                debug('Looking for cached result');
                var queries = namedQueryCache.get(queryId);

                var serialParamString = Serializer.run(parameters);

                var crc = Md5.encode(queryId + '/' +  serialParamString);

                if(namedQueryCache.exists(crc)){
                    var qResults = namedQueryCache.get(crc).queryResults;

                    debug('Use cached result');

                    callBack(qResults, null);

                    return ;
                }
            }

            var privateCB =  function(toBind : Array<Dynamic>, exception){
                if(toBind == null){
                    callBack(toBind, exception);
                }else{

                    initialiseObjects([], toBind, [], exception, function(objs, err){
                        if(useCache){ //09/01/15 useCache
                            Util.debug('Caching result');
                            var namedQuery = new NamedQueryCache();
                            namedQuery.queryName = queryId;
                            namedQuery.queryParams = parameters;
                            namedQuery.queryParamSerial = Serializer.run(parameters);
                            namedQuery.queryResults = objs;

                            var crc = Md5.encode(queryId + '/' + namedQuery.queryParamSerial);

                            namedQueryCache.set(crc, namedQuery);
                        }

                        callBack(objs, err);

                    }, clazz, null, cache);
                }
            };

            if(queryId == 'saturn.workflow'){

                var jobName = parameters[0];
                var config = parameters[1];

                debug('Got workflow query ' + jobName);
                debug(Type.getClassName(Type.getClass(config)));

                if(namedQueryHooks.exists(jobName)){

                    namedQueryHooks.get(jobName)(config, function(object : saturn.workflow.Object, error){

                        privateCB([object], object.getError());
                    });
                }else{
                    debug('Unknown workflow query');
                    _getByNamedQuery(queryId, parameters, clazz, privateCB);
                }
            }else{
                if(namedQueryHooks.exists(queryId)){
                    debug('Hook is known');
                    var config = null;

                    if(namedQueryHookConfigs.exists(queryId)){
                        config = namedQueryHookConfigs.get(queryId);
                    }

                    debug('Calling hook');
                    namedQueryHooks.get(queryId)(queryId, parameters, clazz, privateCB, config);
                }else{
                    debug('Hook is not known');
                    _getByNamedQuery(queryId, parameters, clazz, privateCB);
                }
            }
        }catch(ex : Dynamic){
            debug(ex);
            callBack(null, 'An unexpected exception has occurred');
        }
    }

    public function addHooks(hooks : Array<Dynamic>){
        for(hookdef in hooks){
            var name :String = Reflect.field(hookdef, 'name');
            var hook;

            if(Reflect.hasField(hookdef, 'func')){
                hook = Reflect.field(hookdef, 'func');
            }else{
                var clazz = Reflect.field(hookdef, 'class');
                var method = Reflect.field(hookdef, 'method');

                hook = Reflect.field(Type.resolveClass(clazz), method);
            }

            namedQueryHooks.set(name, hook);
            namedQueryHookConfigs.set(name, hookdef);
        }
    }

    public function addHook(hook : Dynamic, name : String){
        namedQueryHooks.set(name, hook);
    }

    private function _getByNamedQuery(queryId : String, parameters :Dynamic, clazz : Class<Dynamic>, callBack : Dynamic){

    }


    public function getByIdStartsWith(id : String, field :String, clazz : Class<Dynamic>, limit : Int, callBack : Dynamic) : Void{
        debug('Starts with using cache ' + useCache);

        var queryId = '__STARTSWITH_' + Type.getClassName(clazz);
        var parameters = new Array<Dynamic>();
        parameters.push(field);
        parameters.push(id);

        var crc = null;

        if(useCache){
            var crc = Md5.encode(queryId + '/' + Serializer.run(parameters));

            if(namedQueryCache.exists(crc)){
                callBack(namedQueryCache.get(crc).queryResults, null);
                return;
            }
        }
        _getByIdStartsWith(id, field, clazz, limit, function(toBind : Array<Dynamic>, exception){
            if(toBind == null){
                callBack(toBind, exception);
            }else{
                initialiseObjects([], toBind, [], exception, function(objs, err){
                    if(useCache){ //09/01/15 useCache
                        var namedQuery = new NamedQueryCache();
                        namedQuery.queryName = queryId;
                        namedQuery.queryParams = parameters;
                        namedQuery.queryResults = objs;

                        namedQueryCache.set(crc, namedQuery);
                    }

                    callBack(objs, err);
                }, clazz, null, false, false);
            }
        });
    }

    private function _getByIdStartsWith(id : String, field :String, clazz : Class<Dynamic>, limit : Int, callBack : Dynamic) : Void{

    }

    public function update(object : Dynamic, callBack : Dynamic) : Void{
        synchronizeInternalLinks([object]); // Possibly a breaking change

        var className = Type.getClassName(Type.getClass(object));

        evictObject(object);

        var attributeMaps = new Array<Map<String,Dynamic>>();
        attributeMaps.push(unbindObject(object));

        _update(attributeMaps,className,callBack);
    }

    public function insert(obj : Dynamic, cb : Dynamic) : Void{
        synchronizeInternalLinks([obj]); // Possibly a breaking change

        var className = Type.getClassName(Type.getClass(obj));

        evictObject(obj);

        var attributeMaps = new Array<Map<String,Dynamic>>();
        attributeMaps.push(unbindObject(obj));

        _insert(attributeMaps,className,function(err : String){
            if(err == null){
                attach([obj], true, function(err : String){
                    cb(err);
                });
            }else{
                cb(err);
            }
        });
    }

    public function delete(obj : Dynamic, cb : Dynamic) : Void{
        var className = Type.getClassName(Type.getClass(obj));

        var attributeMaps = new Array<Map<String,Dynamic>>();
        attributeMaps.push(unbindObject(obj));

        evictObject(obj);

        _delete(attributeMaps,className, function(err : String){
            //Make sure object appears deatteched.
            var model = getModel(Type.getClass(obj));
            var field = model.getPrimaryKey();

            Reflect.setField(obj, field, null);

            cb(err);
        });
    }

    public function evictObject(object : Dynamic){
        var clazz = Type.getClass(object);
        var className = Type.getClassName(clazz);

        if(objectCache.exists(className)){
            for(indexField in objectCache.get(className).keys()){
                var val = Reflect.field(object, indexField);

                if(val != null && val != ''){
                    if(objectCache.get(className).get(indexField).exists(val)){
                        objectCache.get(className).get(indexField).remove(val);
                    }
                }
            }
        }
    }

    public function evictNamedQuery(queryId : String, parameters : Array<Dynamic>) {
        var crc = Md5.encode(queryId + '/' + Serializer.run(parameters));

        if(namedQueryCache.exists(crc)){
            namedQueryCache.remove(crc);
        }
    }

    public function updateObjects(objs : Array<Dynamic>, callBack : Dynamic) : Void{
        synchronizeInternalLinks(objs); // Possibly a breaking change

        var className = Type.getClassName(Type.getClass(objs[0]));

        var attributeMaps = new Array<Map<String,Dynamic>>();
        for(object in objs){
            evictObject(object);

            attributeMaps.push(unbindObject(object));
        }

        _update(attributeMaps,className,callBack);
    }

    public function insertObjects(objs : Array<Dynamic>, cb : Dynamic) : Void{
        if(objs.length == 0){
            cb(null); return;
        }

        synchronizeInternalLinks(objs); // Possibly a breaking change 13/04/17

        attach(objs, false, function(err : String){
            if(err != null){
                cb(err);
            }else{
                var className = Type.getClassName(Type.getClass(objs[0]));

                var attributeMaps = new Array<Map<String,Dynamic>>();
                for(object in objs){
                    evictObject(object);

		    var a = unbindObject(object);

                    attributeMaps.push(a);
                }

                _insert(attributeMaps,className,function(err : String){
                    cb(err);
                });
            }
        }); // Possibly a breaking change
    }

    public function rollback(callBack : Dynamic) : Void{
        _rollback(callBack);
    }

    public function commit(callBack : Dynamic) : Void{
        _commit(callBack);
    }

    public function _update(attributeMaps : Array<Map<String, Dynamic>>, className : String, callBack : Dynamic) : Void{

    }

    public function _insert(attributeMaps : Array<Map<String, Dynamic>>, className : String, callBack : Dynamic) : Void{

    }

    public function _delete(attributeMaps : Array<Map<String, Dynamic>>, className : String, callBack : Dynamic) : Void{

    }

    private function _rollback(callBack : Dynamic) : Void{

    }

    private function _commit(cb : Dynamic) : Void{
        cb('Commit not supported');
    }

    /**
    *   bindObject
    *
    *   attributeMap : Dynamic
    *   clazz : Class<Dynamic>
    *   cache : Bool
    *   indexField : String
    *   suspendSetup : Bool  Suppress call to setup method (useful where you wish to perform a bulk operation on all objects first)
    **/
    public function bindObject(attributeMap : Dynamic, clazz : Class<Dynamic>, cache : Bool, indexField : String = null, suspendSetup = false){
        if(clazz == null){
            for(key in Reflect.fields(attributeMap)){
                var val = Reflect.field(attributeMap,key);
                if(r_date.match(val)){
                    #if (CLIENT_SIDE || SERVER_SIDE)
                    Reflect.setField(attributeMap,key,untyped __js__('new Date(Date.parse(val))'));
                    #end
                }
            }

            return attributeMap;
        }
//
        if(enableBinding){
            var className = Type.getClassName(clazz);
            var parts = className.split('.');
            var shortName = parts.pop();
            var packageName = parts.join('.');

            var obj = Type.createInstance(clazz,[]);

            if(theBindingMap.exists(className)){
                var map = theBindingMap.get(className).get('fields');
                var indexes = theBindingMap.get(className).get('indexes');

                //Work out which attribute is the primary key
                var atPriIndex = null;
                for(atIndexField in indexes.keys()){
                    if(indexes.get(atIndexField) == 1){
                        atPriIndex = atIndexField;
                        break;
                    }
                }

                //Work out what column the primary key attribute corresponds to
                var colPriIndex = null;
                if(atPriIndex != null){
                    colPriIndex = map.get(atPriIndex);
                }

                //determine the primary key value
                var priKeyValue = null;
                if(Reflect.hasField(attributeMap, colPriIndex)){
                    priKeyValue = Reflect.field(attributeMap, colPriIndex);
                }else if(Reflect.hasField(attributeMap, colPriIndex.toLowerCase())){
                    priKeyValue = Reflect.field(attributeMap, colPriIndex.toLowerCase());
                }

                var keys = [];
                for(key in map.keys()){
                    keys.push(key);
                }

                if(indexField != null && !map.exists(indexField)){
                    keys.push(indexField);
                }

                for(key in keys){
                    if(!objectCache.get(className).exists(key)){
                        objectCache.get(className).set(key, new Map<String, Dynamic>());
                    }

                    var atKey = map.get(key);

                    var val = null;
                    if(Reflect.hasField(attributeMap, atKey)){
                        val = Reflect.field(attributeMap,atKey);
                    }else if(Reflect.hasField(attributeMap,atKey.toLowerCase())){
                        val = Reflect.field(attributeMap,atKey.toLowerCase());
                    }

                    //TODO: Verify this doesn't break anything
                    #if (CLIENT_SIDE || SERVER_SIDE)
                    if(r_date.match(val)){
                        Reflect.setField(obj,key,untyped __js__('new Date(Date.parse(val))'));
                    }else{
                        Reflect.setField(obj,key,val);
                    }
                    #else
                    Reflect.setField(obj,key,val);
                    #end

                    if(cache && indexes != null && (indexes.exists(key) || key == indexField) && useCache){
                        //do we have a primary key
                        if(priKeyValue != null){
                            //have we cached an object with the same className/Field/Value
                            if(objectCache.get(className).get(key).exists(val)){
                                //Get the previously cached object
                                var mappedObj = objectCache.get(className).get(key).get(val);
                                //Assume array
                                var toCheck :Array<Dynamic> = mappedObj;
                                //Get type
                                var isArray = Std.is(mappedObj,Array);
                                //If not array place the mapped object into an array
                                if(!isArray){
                                    toCheck = [mappedObj];
                                }

                                var match = false;
                                //Loop through previously mapped objects
                                for(i in 0...toCheck.length){
                                    //Get exiisting object
                                    var eObj = toCheck[i];

                                    //Get primary key value
                                    var priValue = Reflect.field(eObj, atPriIndex);

                                    //Test if object is the same
                                    if(priValue == priKeyValue){
                                        //If so update with newly fetched object
                                        toCheck[i] = obj;
                                        //Set match to true
                                        match = true;
                                        //Break
                                        break;
                                    }
                                }

                                //If not match append new object to array
                                if(match == false){
                                    toCheck.push(obj);
                                }

                                //Bug fix: 06/01/15 (this minor change might cause major bugs to appear elsewhere)
                                //Description: Previously when the object to bind matched a single cached object the value stored in
                                //objectCache=>className=>key=>val=>object got switched from a singleton to an array because the value
                                //stored was toCheck (an array) rather than obj.
                                //TODO: Investigate if we can safely always store cached objects in an array with only minor modifications to code
                                //which makes use of the objectCache.
                                if(toCheck.length == 1){
                                    //Cache array of objects
                                    objectCache.get(className).get(key).set(val,toCheck[0]);
                                }else{
                                    //Cache array of objects
                                    objectCache.get(className).get(key).set(val,toCheck);
                                }

                                //Go to next field
                                continue;
                            }
                        }

                        objectCache.get(className).get(key).set(val,obj);
                    }
                }
            }

            /* Validation to guard against those model objects that do not make use of setup i.e. saturn.core.scarab.LabePage */
            if(!suspendSetup && Reflect.isFunction(obj.setup)) {
                obj.setup();
            }

            return obj;
        }else{
            return attributeMap;
        }
    }

    public function unbindObject(object : Dynamic) : Map<String, Dynamic>{
        if(enableBinding){
            var className = Type.getClassName(Type.getClass(object));
            var attributeMap = new Map<String, Dynamic>();

            if(theBindingMap.exists(className)){
                var map = theBindingMap.get(className).get('fields');
                for(key in map.keys()){
                    var val = Reflect.field(object,key);

                    attributeMap.set(map.get(key),val);
                }

                return attributeMap;
            }else{
                return null;
            }
        }else{
            return object;
        }
    }

    public function activate(objects : Array<Dynamic>, depthLimit : Int, callBack :String->Void) :Void {
        _activate(objects, 1, depthLimit, function(error : String){
            if(error == null){
                merge(objects);
            }

            callBack(error);
        });
    }

    public function _activate(objects : Array<Dynamic>, depth : Int, depthLimit : Int, callBack :String->Void) :Void {
        var objectsToFetch = 0;

        var batchQuery =  new BatchFetch(function(obj, err){
            #if PYTHON
            print(err);
            #end
            //WorkspaceApplication.get().showMessage('Batch fetch failure', err);
        });

        batchQuery.setProvider(this);

        //class to field to values
        var classToFetch = new Map<String,Map<String,Map<String,String>>>();

        for(object in objects){
            #if (SERVER_SIDE || CLIENT_SIDE)
            if(object == null || Std.is(object, ArrayBuffer) || Std.is(object, haxe.ds.StringMap)){
                continue;
            }
            #else
            if(object == null || Std.is(object, haxe.ds.StringMap)){
                continue;
            }
            #end
            var clazz = Type.getClass(object);

            if(clazz == null){
                //ignore objects which aren't dervived from a class
                continue;
            }

            var clazzName = Type.getClassName(clazz);
            if(theBindingMap.exists(clazzName)){
                if(theBindingMap.get(clazzName).exists('fields.synthetic')){
                    var synthFields = theBindingMap.get(clazzName).get('fields.synthetic');
                    for(synthFieldName in synthFields.keys()){
                        var synthInfo = synthFields.get(synthFieldName);
                        var fkField = synthInfo.get('fk_field');

                        if(fkField == null){
                            Reflect.setField(object, synthFieldName, Type.createInstance(Type.resolveClass(synthInfo.get('class')),[Reflect.field(object,synthInfo.get('field'))]));
                            continue;
                        }

                        var synthVal = Reflect.field(object,synthFieldName);
                        if(synthVal != null){
                            continue;
                        }

                        var isPolymorphic = synthInfo.exists('selector_field');

                        var synthClass;
                        if(isPolymorphic){
                            var selectorField = synthInfo.get('selector_field');

                            var objValue = Reflect.field(object, selectorField);

                            if(synthInfo.get('selector_values').exists(objValue)){
                                synthClass = synthInfo.get('selector_values').get(objValue);
                            }else{
                                continue;
                            }

                            var selectorValue = synthInfo.get('selector_value');

                            synthFieldName = '_MERGE';
                        }else{
                            synthClass = synthInfo.get('class');
                        }

                        var field = synthInfo.get('field');

                        var val = Reflect.field(object,field);
                        if(val == null || (val=='' && !Std.is(val, Int))){
                            Reflect.setField(object,synthFieldName,null);
                        }else{
                            var cacheObj = getObjectFromCache(Type.resolveClass(synthClass),fkField,val);
                            if(cacheObj == null){
                                objectsToFetch++;

                                if(!classToFetch.exists(synthClass)){
                                    classToFetch.set(synthClass,new Map<String,Map<String,String>>());
                                }

                                if(!classToFetch.get(synthClass).exists(fkField)){
                                    classToFetch.get(synthClass).set(fkField, new Map<String, String>());
                                }

                                classToFetch.get(synthClass).get(fkField).set(val,'');
                            }else{
                                Reflect.setField(object,synthFieldName,cacheObj);
                            }
                        }
                    }
                }
            }
        }

        for(synthClass in classToFetch.keys()){
            for(fkField in classToFetch.get(synthClass).keys()){
                var objList = new Array<String>();
                for(objId in classToFetch.get(synthClass).get(fkField).keys()){
                    objList.push(objId);
                }

                batchQuery.getByValues(objList,Type.resolveClass(synthClass), fkField, '__IGNORED__',null);
            }
        }

        batchQuery.onComplete = function(){
            for(object in objects){
                var clazz = Type.getClass(object);
                #if (CLIENT_SIDE || SERVER_SIDE)
                if(object == null || Std.is(object, ArrayBuffer) || clazz == null){
                    continue;
                }
                #else
                if(object == null || clazz == null){
                    continue;
                }
                #end

                var clazzName = Type.getClassName(clazz);
                if(theBindingMap.exists(clazzName)){
                    if(theBindingMap.get(clazzName).exists('fields.synthetic')){
                        var synthFields = theBindingMap.get(clazzName).get('fields.synthetic');
                        for(synthFieldName in synthFields.keys()){
                            var synthVal = Reflect.field(object,synthFieldName);
                            if(synthVal != null){
                                continue;
                            }

                            var synthInfo = synthFields.get(synthFieldName);

                            var isPolymorphic = synthInfo.exists('selector_field');

                            var synthClass;
                            if(isPolymorphic){
                                var selectorField = synthInfo.get('selector_field');

                                var objValue = Reflect.field(object, selectorField);

                                if(synthInfo.get('selector_values').exists(objValue)){
                                    synthClass = synthInfo.get('selector_values').get(objValue);
                                }else{
                                    continue;
                                }

                                var selectorValue = synthInfo.get('selector_value');

                                synthFieldName = '_MERGE';
                            }else{
                                synthClass = synthInfo.get('class');
                            }

                            var field = synthInfo.get('field');

                            var val = Reflect.field(object,field);
                            if(val != null && val != ''){
                                var fkField = synthInfo.get('fk_field');

                                if(synthInfo.exists('selector_field')){
                                    synthFieldName = '_MERGE';
                                }

                                var cacheObj = getObjectFromCache(Type.resolveClass(synthClass),fkField,val);
                                if(cacheObj != null){
                                    Reflect.setField(object,synthFieldName,cacheObj);
                                }
                            }
                        }
                    }
                }
            }

            var newObjList = new Array<Dynamic>();
            for(object in objects){
                var clazz = Type.getClass(object);
                #if (CLIENT_SIDE || SERVER_SIDE)
                if(object == null || Std.is(object, ArrayBuffer) || clazz == null){
                    continue;
                }
                #else
                if(object == null || clazz == null){
                    continue;
                }
                #end

                var model = getModel(clazz);
                if(model != null){
                    for(field in Reflect.fields(object)){
                        var val = Reflect.field(object,field);
                        if(!model.isSyntheticallyBound(field) || val == null){
                            continue;
                        }

                        // This is wrong it must only work on fields which require a synth field
                        //if( val!= null && !Std.is(val,String) && !Std.is(val,Int)){
                       // if(val != null && val != '' && !Std.is(val,Int) && !Std.is(val,Float) && !Std.is(val, String) && !Std.is(val, Bool)){
                            var objs :Array<Dynamic> = Reflect.field(object,field);

                            if(!Std.is(objs, Array)){
                                objs = [objs];
                            }

                            for(newObject in objs){
                                newObjList.push(newObject);
                            }
                       // }
                    }
                }
            }

            if(newObjList.length > 0 && depthLimit > depth){
                _activate(newObjList, depth+1, depthLimit,callBack);
            }else{
                callBack(null);
            }
        }

        batchQuery.execute();
    }

    public function merge(objects : Array<Dynamic>){
        var toVisit = [];
        for(i in 0...objects.length){
            toVisit.push({'parent': objects, 'pos': i, 'value': objects[i]});
        }

        _merge(toVisit);
    }

    private function _merge(toVisit : Array<Dynamic>){
        while(true){
            if(toVisit.length == 0){
                break;
            }

            var item = toVisit.pop();
            var original = Reflect.field(item, 'value');
            if(Reflect.hasField(original, '_MERGE')){
                var obj = Reflect.field(original, '_MERGE');

                for(field in Reflect.fields(original)){
                    if(field != '_MERGE'){
                        Reflect.setField(obj, field, Reflect.field(original, field));
                    }
                }

                var parent = Reflect.field(item, 'parent');
                if(Reflect.hasField(item, 'pos')){
                    parent[Reflect.field(item, 'pos')] = obj;
                }else{
                    Reflect.setField(parent, Reflect.field(item, 'field'), obj);
                }

                original = obj;
            }
            var model = getModel(original);
            if(model == null){
                continue;
            }

	    #if SATURN_PATCH
            for(field in model.getFields()){
	    #else
            for(field in model.getAttributes()){
            #end
                var value : Dynamic = Reflect.field(original, field);

                var isObject = false;
                #if (CLIENT_SIDE || SERVER_SIDE)
                isObject = Std.is(value, untyped __js__('Object'));
                #elseif PYTHON
                isObject = Reflect.hasField(value, '__class__');
                #end

                if(isObject){
                    if(Std.is(value, Array)){
                        for(i in 0...value.length){
                            toVisit.push({'parent': value, 'pos': i, 'value': value[i]});
                        }
                    }else{
                        toVisit.push({'parent': original, 'value': value, 'field': field});
                    }
                }
            }
        }
    }

    /**
    * TODO: Check if there is a reason we can't use the classes now generated by initModelClasses
    * (Faint memory of the Table Widget doing something with the returned class)
    **/
    public function getModel(clazz : Dynamic) : Model{
        if(clazz == null){
            return null;
        }else{
            var t = Type.getClass(clazz);
            var className = Type.getClassName(clazz);
            return getModelByStringName(className);
        }
    }

    public function getObjectModel(object : Dynamic) : Model{
        if(object == null){
            return null;
        }else{
            var clazz = Type.getClass(object);

            return getModel(clazz);
        }
    }

    public function save(object : Dynamic, cb : String->Void, autoAttach : Bool = false) : Void {
        insertOrUpdate([object], cb, autoAttach);
    }

    public function initModelClasses() : Void{
        modelClasses = new Array<Model>();

        for(classStr in theBindingMap.keys()){
            debug(classStr);
            var clazz = Type.resolveClass(classStr);

            if(clazz != null){
                modelClasses.push(getModel(clazz));
            }
        }
    }

    public function getModelClasses() : Array<Model>{
        return modelClasses;
    }

    /**
    * TODO: Check if there is a reason we can't use the classes now generated by initModelClasses
    * (Faint memory of the Table Widget doing something with the returned class)
    **/
    public function getModelByStringName(className : String) : Model{
        if(theBindingMap.exists(className)){
            if(theBindingMap.get(className).exists('model')){
                return new Model(theBindingMap.get(className), className);
            }else{
                return new Model(theBindingMap.get(className), className); // possible issues here with above
            }
        }else{
            return null;
        }
    }

    public function isModel(clazz : Class<Dynamic>) : Bool {
        if(theBindingMap != null){
            return theBindingMap.exists(Type.getClassName(clazz));
        }else{
            return false;
        }
    }

    public function setSelectClause(className : String, selClause : String) : Void {
        if(theBindingMap.exists(className)){
            theBindingMap.get(className).get('statements').set('SELECT', selClause);
        }
    }

    public function modelToReal(modelDef : Model, models : Array<Dynamic>, cb : String->Array<Dynamic>->Void)  {
        var priKey = modelDef.getPrimaryKey();

        var fields = modelDef.getFields();
        var clazz = modelDef.getClass();

        var syntheticInstanceAttributes = modelDef.getSynthenticFields();
        var syntheticSet :Map<String,Map<String,Dynamic>> = null;

        if(syntheticInstanceAttributes != null){
            syntheticSet = new Map<String,Map<String,Dynamic>>();
            for(instanceName in syntheticInstanceAttributes.keys()){
                var  fkRel = syntheticInstanceAttributes.get(instanceName);
                var parentIdColumn = fkRel.get('fk_field');
                var childIdColumn =  fkRel.get('field');

                syntheticSet.set(instanceName,[
                'childIdColumn'=>childIdColumn,
                'parentIdColumn' => fkRel.get('fk_field'),
                'class'=>fkRel.get('class')
                ]);
            }
        }

        var clazzToFieldToIds = new Map<String,Map<String,Map<String,String>>>();

        // Iterate across ExtJS model
        for(model in models){
            // Iterate list of ExtJS model fields
            #if SATURN_PATCH
            for(field in modelDef.getFields()){
            #else
            for(field in modelDef.getAttributes()){
            #end
                // Fields with a period are synthetic and need to be deconvoluted
                if(field.indexOf('.') > -1){
                    var parts = field.split('.');

                    // Synthetic field name
                    var instanceName = parts[0];

                    // Only deconvolute synethtic fields we know about for this class
                    if(syntheticSet != null && syntheticSet.exists(instanceName)){
                        // Field that value originated from (i.e. alleleId in allele.alleleId)
                        var lookupField = parts[parts.length-1];

                        // Class of synthetic field
                        var lookupClazz = syntheticSet.get(instanceName).get('class');

                        // Value ExtJS model has with synthetic field (i.e. allele.alleleId)
                        var val = Reflect.field(model,field);

                        if(val == null || (val == '' && !Std.is(val, Int))) continue;

                        // Lookup real classs
                        var clazz = Type.resolveClass(lookupClazz);

                        // Lookup cached object
                        var cachedObject = getObjectFromCache(clazz,lookupField,val);

                        // When cached object is null we need to get it
                        if(cachedObject == null){
                            // Following containers are used to make sure we fetch an object once
                            if(!clazzToFieldToIds.exists(lookupClazz)){
                                clazzToFieldToIds.set(lookupClazz,new Map<String,Map<String,String>>());
                            }

                            if(!clazzToFieldToIds.get(lookupClazz).exists(lookupField)){
                                clazzToFieldToIds.get(lookupClazz).set(lookupField,new Map<String,String>());
                            }

                            // Make object as needing to be fetched
                            clazzToFieldToIds.get(lookupClazz).get(lookupField).set(val,'');
                        }
                    }
                }
            }
        }

        // Configure batch fetch
        var batchFetch = new BatchFetch(function(obj, err){
            cb(err, obj);
            //getApplication().showMessage('Batch fetch failure', err);
        });

        for(clazzStr in clazzToFieldToIds.keys()){
            for(fieldStr in clazzToFieldToIds.get(clazzStr).keys()){
                var valList = new Array<String>();
                for(val in clazzToFieldToIds.get(clazzStr).get(fieldStr).keys()){
                    valList.push(val);
                }

                // Note how field is ignored we assume the buskey is what we have
                // Scarab backend doesn't support column specification in lookups yet
                batchFetch.getByIds(valList, Type.resolveClass(clazzStr),'__IGNORE__', null);
            }
        }

        batchFetch.onComplete = function(err, objs){
            if(err != null){
                cb(err,null);
                //WorkspaceApplication.getApplication().showMessage('Data retrieval failure',err.message);
            }else{
                var mappedModels = new Array<Dynamic>();

                // Iterate across ExtJS model
                for(model in models){
                    var mappedModel = Type.createEmptyInstance(clazz);

                    // Iterate list of ExtJS model fields
                    #if SATURN_PATCH
                    for(field in modelDef.getFields()){
                    #else
                    for(field in modelDef.getAttributes()){
                    #end
                        // Fields with a period are synthetic and need to be deconvoluted
                        if(field.indexOf('.') > -1){
                            var parts = field.split('.');

                            // Synthetic field name
                            var instanceName = parts[0];

                            // Only deconvolute synethtic fields we know about for this class
                            if(syntheticSet.exists(instanceName)){
                                // Field that value originated from (i.e. alleleId in allele.alleleId)
                                var lookupField = parts[parts.length-1];

                                // Class of synthetic field
                                var lookupClazz = syntheticSet.get(instanceName).get('class');

                                // Value ExtJS model has with synthetic field (i.e. allele.alleleId)
                                var val = Reflect.field(model,field);

                                if(val == null || val == '') continue;

                                // Lookup real class
                                var clazz = Type.resolveClass(lookupClazz);

                                // Lookup cached object
                                var cachedObject = getObjectFromCache(clazz,lookupField,val);

                                // When cached object is null we need to get it
                                if(cachedObject != null){
                                    var idColumn = syntheticSet.get(instanceName).get('parentIdColumn');
                                    var val = Reflect.field(cachedObject, idColumn);

                                    if(val == null || (val == '' && !Std.is(val, Int))){
                                        cb('Unexpected mapping error',mappedModels);
                                        return;
                                    }

                                    var dstColumn = syntheticSet.get(instanceName).get('childIdColumn');

                                    Reflect.setField(mappedModel, dstColumn, val);
                                }else{
                                    cb('Unable to find ' + val,mappedModels);
                                    return;
                                }
                            }
                        }else{
                            var val = Reflect.field(model,field);
                            Reflect.setField(mappedModel, field, val);
                        }
                    }

                    mappedModels.push(mappedModel);
                }

                cb(null,mappedModels);
            }
        };

        batchFetch.execute();

        /*
        for(model in models){


            var priVal = Reflect.field(model, priKey);

            var instance = Type.createEmptyInstance(clazz);

            for(field in fields){
                Reflect.setField(instance, field, Reflect.field(model, field));
            }
        }*/
    }

    public function dataBinding(enable : Bool) : Void{
        enableBinding = enable;
    }

    public function isDataBinding() : Bool{
        return enableBinding;
    }

    public function queryPath(fromClazz : Class<Dynamic>, queryPath : String, fieldValue : String, functionName : String, cb : String->Array<Dynamic>->Void){
        var parts = queryPath.split('.');

        var fieldName = parts.pop();
        var synthField = parts.pop();

        var model = getModel(fromClazz);

        if(model.isSynthetic(synthField)){
            var fieldDef = model.getSynthenticFields().get(synthField);

            var childClazz = Type.resolveClass(fieldDef.get('class'));

            Reflect.callMethod(this, Reflect.field(this, functionName), [[fieldValue], childClazz, fieldName, function(objs: Array<Dynamic>, err){
                    if(err == null){
                        var values = [];

                        for(obj in objs){
                            values.push(Reflect.field(obj, fieldDef.get('fk_field')));
                        }

                        var parentField = fieldDef.get('field');

                        getByValues(values, fromClazz, parentField, function(objs, err){
                            cb(err, objs);
                        });
                    }else{
                        cb(err, null);
                    }
            }]);
        }
    }

    public function setAutoCommit(autoCommit : Bool, cb : String->Void) : Void{
        cb('Set auto commit mode ');
    }

    /**
    * attach is used to populate the primary key attribute of an object.  An object is considered deattached from the
    * database if it's primary key attribute has a null value.  Objects may be deattached because they were never attached
    * or have become deattached over time.
    *
    **/
    public function attach(objs : Array<Dynamic>, refreshFields : Bool,cb : String->Void){
        var bf = new BatchFetch(function(obj, err){
            cb(err);
        });

        bf.setProvider(this);

        _attach(objs, refreshFields, bf);

        bf.onComplete = function(){
            synchronizeInternalLinks(objs);

            cb(null);
        }

        bf.execute();
    }

    public function synchronizeInternalLinks(objs : Array<Dynamic>){
        if(!isDataBinding()){
            return;
        }

        for(obj in objs){
            var clazz : Class<Dynamic> = Type.getClass(obj);
            var model : Model = getModel(clazz);

            var synthFields = model.getSynthenticFields();

            if(synthFields != null){
                for(synthFieldName in synthFields.keys()){
                    var synthField = synthFields.get(synthFieldName);
                    var synthObj = Reflect.field(obj, synthFieldName);
                    var field = synthField.get('field');
                    var fkField = synthField.get('fk_field');

                    //TODO: Breaking change
                    if(synthObj != null){
                        if(fkField == null){
                            // We get here when the synthetic object is transient (i.e. doesn't exist in the database)
                            Reflect.setField(obj, field, synthObj.getValue());
                        }else{
                            Reflect.setField(obj, field, Reflect.field(synthObj, fkField));

                            synchronizeInternalLinks([synthObj]);
                        }
                    }
                }
            }
        }
    }

    private function _attach(objs : Array<Dynamic>, refreshFields : Bool, bf : BatchFetch){
        for(obj in objs){
            var clazz : Class<Dynamic> = Type.getClass(obj);
            
            var model : Model = getModel(clazz);

            var priField = model.getPrimaryKey();
            var secField = model.getFirstKey();

            if(Reflect.field(obj, priField) == null || Reflect.field(obj, priField) == ''){
                var fieldVal = Reflect.field(obj, secField);
                if(fieldVal != null){
                    bf.append(fieldVal, secField, clazz, function(dbObj){
                        if(refreshFields){
                            for(field in Reflect.fields(dbObj)){
                                Reflect.setField(obj, field, Reflect.field(dbObj, field));
                            }
                        }else{
                            Reflect.setField(obj, priField, Reflect.field(dbObj, priField));
                        }
                    });
                }
            }

            var synthFields = model.getSynthenticFields();

            if(synthFields != null){
                //debug('Going after synth fields');
                for(synthFieldName in synthFields.keys()){
                    var synthField = synthFields.get(synthFieldName);
                    //debug('Synth field: ' + synthField);
                    var synthObj = Reflect.field(obj, synthFieldName);

                    if(synthObj != null){
                        _attach([synthObj], refreshFields, bf);
                    }
                }
            }
        }
    }

    public function getQuery() : Query{
        var query = new Query(this);

        return query;
    }

    public function getProviderType() : String{
        return 'NONE';
    }

    public function isAttached(obj : Dynamic) : Bool{
        var model = getModel(Type.getClass(obj));
        var priField = model.getPrimaryKey();
        var val = Reflect.field(obj, priField);

        if(val == null || val == ''){
            return false;
        }else{
            return true;
        }
    }

    public function insertOrUpdate(objs : Array<Dynamic>, cb: String->Void, autoAttach = false){
        var run = function(){
            var insertList = [];
            var updateList = [];

            for(obj in objs){
                if(!isAttached(obj)){
                    insertList.push(obj);
                }else{
                    updateList.push(obj);
                }
            }

            if(insertList.length > 0){
                insertObjects(insertList,function(err){
                    if(err == null && updateList.length > 0){
                        updateObjects(updateList, cb);
                    }else{
                        cb(err);
                    }
                });
            }else if(updateList.length > 0){
                updateObjects(updateList, cb);
            }
        }

        if(autoAttach){
            attach(objs, false, function(err : String){
                if(err == null){
                    run();
                }else{
                    cb(err);
                }
            });
        }else{
            run();
        }
    }

    public function uploadFile(contents : Dynamic, file_identifier : String, cb : String->String->Void) : String{
        #if SERVER_SIDE
        if(file_identifier == null){
            // Open a new temporary file
            NodeTemp.open_untracked('upload_file', function(err, info){
                if(err != null){
                    cb(err, null);
                }else{
                    // Create buffer with file contents
                    var buffer : NodeBuffer = new NodeBuffer(contents, 'base64');

                    // Write buffer contents to temporary file
                    Node.fs.writeFile(info.path, buffer, function(err){
                        if(err != null){
                            cb(err, null);
                        }else{
                            // Associate a random key with the path so the client-side uses the key and never sees the real path
                            var client = SaturnServer.getDefaultServer().getRedisClient();

                            // Generate upload key so the client-side has a hook to refer to this file in subsequent web-service calls
                            var uuid = Node.require('node-uuid');
                            var upload_key = 'file_upload:' + uuid.v4();

                            // Store upload key / file path pair
                            client.set(upload_key, info.path);

                            // Return the upload key to the client-side
                            cb(null, upload_key);
                        }
                    });
                }
            });
        }else{
            var client = SaturnServer.getDefaultServer().getRedisClient();
            client.get(file_identifier, function(err, filePath){
                if(err != null || filePath == null || filePath == ''){
                    cb(err, null);
                }else{
                    var decodedContents = new NodeBuffer(contents, 'base64');

                    Node.fs.appendFile(filePath, decodedContents, function(err){
                        cb(err, file_identifier);
                    });
                }

            });
        }
        #end

        return null;
    }
}

class NamedQueryCache{
    public var queryName : String;
    public var queryParamSerial : String;
    public var queryParams : Array<Dynamic>;
    public var queryResults : Array<Dynamic>;

    public function new(){

    }
}
