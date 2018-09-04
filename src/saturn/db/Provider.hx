/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

import saturn.db.query_lang.Query;
import saturn.core.User;
interface Provider {
    public function getById(id : String, clazz : Class<Dynamic>, callBack : Dynamic->Dynamic->Void) : Void;
    public function getByIds(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic) : Void;
    public function getByPkey(id : String, clazz : Class<Dynamic>, callBack : Dynamic->Dynamic->Void) : Void;
    public function getByPkeys(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic) : Void;
    public function getByIdStartsWith(id : String, field : String, clazz : Class<Dynamic>, limit : Int, callBack : Dynamic) : Void;
    public function update(object : Dynamic, callBack : Dynamic) : Void;
    public function insert(object : Dynamic, callBack : Dynamic) : Void;
    public function delete(object : Dynamic, callBack : Dynamic) : Void;
    public function generateQualifiedName(schemaName : String, tableName : String) : String;

    public function updateObjects(objs : Array<Dynamic>, callBack : Dynamic) : Void;
    public function insertObjects(objs : Array<Dynamic>, callBack : Dynamic) : Void;
    public function insertOrUpdate(objs : Array<Dynamic>, cb: String->Void, autoAttach :Bool = false) : Void;

    public function rollback(callBack : Dynamic) : Void;
    public function commit(callBack : Dynamic) : Void;

    public function isAttached(obj : Dynamic) : Bool;

    public function sql(sql : String, parameters : Array<Dynamic>, cb : String->Dynamic->Void) : Void;
    public function getByNamedQuery(queryId : String, parameters: Dynamic, clazz : Class<Dynamic>, cache : Bool, callBack : Dynamic) : Void;
    public function getObjectFromCache<T>(clazz : Class<Dynamic>, field : String, val : Dynamic) : T;
    public function activate(objects : Array<Dynamic>, depth : Int, callBack :String->Void) :Void;
    public function getModel(clazz : Class<Dynamic>) : Model;
    public function getObjectModel(object : Dynamic) : Model;
    public function save(object : Dynamic, cb : String->Void, autoAttach : Bool = false) : Void;
    public function modelToReal(modelDef : Model, models : Array<Dynamic>, cb : String->Array<Dynamic>->Void) : Void;
    public function attach(objs : Array<Dynamic>, refreshFields : Bool, cb : String->Void) : Void;

    /**
    * resetCache evicts all objects from the current cache ensuring that no stale objects are returned
    **/
    public function resetCache() : Void;

    public function evictNamedQuery(queryId : String, arguments : Array<Dynamic>) : Void;
    public function readModels(cb : String->Void) : Void;
    public function dataBinding(enable : Bool) : Void;
    public function isDataBinding() : Bool;

    public function setSelectClause(className : String, selClause : String) : Void;

    public function _update(attributeMaps : Array<Map<String, Dynamic>>, className : String, callBack : Dynamic) : Void;
    public function _insert(attributeMaps : Array<Map<String, Dynamic>>, className : String, callBack : Dynamic) : Void;
    public function _delete(attributeMaps : Array<Map<String, Dynamic>>, className : String, callBack : Dynamic) : Void;

    public function getByValue(value : String, clazz : Class<Dynamic>, field : String, callBack : Dynamic) : Void;
    public function getByValues(values : Array<String>, clazz : Class<Dynamic>, field : String, callBack : Dynamic) : Void;
    public function getObjects(clazz : Class<Dynamic>, cb : Dynamic) : Void;

    public function queryPath(fromClazz : Class<Dynamic>, queryPath : String, fieldValue : String, functionName : String, cb : String->Array<Dynamic>->Void) : Void;

    public function getModels() : Dynamic;
    public function getModelClasses() : Array<Model>;

    public function connectAsUser() : Bool;
    public function setConnectAsUser(asUser : Bool) : Void;
    public function enableCache(cached : Bool) : Void;
    public function generatedLinkedClone() : Provider;
    public function setUser(user : User) : Void;
    public function getUser() : User;

    public function closeConnection(connection : Dynamic) : Void;
    public function _closeConnection() : Void;
    public function setAutoCommit(autoCommit : Bool, cb : String->Void) : Void;
    public function setName(name : String) : Void;
    public function getName() : String;
    public function getConfig() : Dynamic;
    public function setConfig(config : Dynamic) : Void;
    public function evictObject(object : Dynamic) : Void;
    public function getByExample(obj : Dynamic, cb : Dynamic->Array<Dynamic>->Void) : Void;
    public function query(query : Query, cb : Array<Dynamic>->Dynamic->Void) : Void;
    public function getQuery() : Query;
    public function getProviderType() : String;
    public function getModelByStringName(className : String) : Model;
    public function getConnection(config : Dynamic, cb : String->Connection->Void) : Void;
    public function uploadFile(contents : Dynamic, file_identifier : String, cb : String->String->Void) : String;
    public function addHook(func : Dynamic, name : String) : Void;
}