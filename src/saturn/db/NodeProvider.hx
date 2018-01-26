/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

import saturn.core.Util;
import saturn.core.User;
import saturn.db.query_lang.Query;
import haxe.Json;
import saturn.client.WorkspaceApplication;
import saturn.db.DefaultProvider;

import haxe.Unserializer;
import haxe.Serializer;
import saturn.client.core.CommonCore;
import saturn.client.core.ClientCore;

@:keep
class NodeProvider extends DefaultProvider{
    public function new(models : Map<String,Map<String,Map<String,Dynamic>>> = null){
        super(models, null, false);

        var app = WorkspaceApplication.getApplication();

        ClientCore.getClientCore().registerResponse('_data_receive_objects');
        ClientCore.getClientCore().registerResponse('_data_receive_objects_by_class');
        ClientCore.getClientCore().registerResponse('_data_receive_insert_response');
        ClientCore.getClientCore().registerResponse('_data_receive_update_response');
        ClientCore.getClientCore().registerResponse('_data_receive_delete_response');
        ClientCore.getClientCore().registerResponse('_data_commit_response');
        ClientCore.getClientCore().registerResponse('_error_receive');
        //app.registerResponse('_receive_models');

        /**
        * Retrieve model mapping from server.
        *
        * Model mapping to use is defined in the Server Services configuration with
        * the key model_mapping and is connection specific though at the moment
        * only one connection source can be used for each server.
        **/
        if(models == null){
            requestModels(function(models, err){
                if(err != null){
                    Util.debug('Error retrieving model definitions from server');
                }else{
                    Util.debug('Models retrieved');

                    setModels(models);

                    var models : Array<Model> = getModelClasses();

                    Util.debug('Models configured: ' + models.length);

                    if(app != null){
                        // Load default program associations
                        for(model in models){
                            var programs = model.getPrograms();

                            if(programs != null){
                                for(program in programs){
                                    Util.debug('Registering ' + program + '/' + model.getName());
                                    app.getProgramRegistry().openWith(cast Type.resolveClass(program), true, cast Type.resolveClass(model.getName()));
                                }
                            }else{
                                Util.debug('No programs for ' + model.getName());
                            }
                        }

                        app.makeAliasesAvailable();
                    }

                    if(app != null){
                        if(getModel(Type.getClass(app)).hasFlag('NO_LOGIN')){
                            var u = new User();
                            u.fullname = 'SQLite';

                            Util.debug('NO_LOGIN flag found');

                            ClientCore.getClientCore().disableLogout();
                            ClientCore.getClientCore().setLoggedIn(u);
                        }
                    }

                    getByNamedQuery('saturn.server.plugins.core.ConfigurationPlugin:clientConfiguration',[],null, false, function(config, err){
                        if(err == null){
                            if(Reflect.hasField(config, 'connections')){
                                var connectionConfigs : Array<Dynamic> = Reflect.field(config, 'connections');
                                for(connectionConfig in connectionConfigs){
                                    if(Reflect.hasField(connectionConfig, 'name')){
                                        var name = Reflect.field(connectionConfig, 'name');
                                        if(name == 'DEFAULT'){
                                            if(Reflect.hasField(connectionConfig, 'named_query_hooks')){
                                                addHooks(Reflect.field(connectionConfig, 'named_query_hooks'));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    });
                }
            });
        }
    }

    @:keep
    function hxSerialize(s:Serializer) {

    }

    @:keep
    function hxUnserialize(u:Unserializer) {

    }

    public function requestModels(cb){
        var app = WorkspaceApplication.getApplication();

        var d  :Dynamic = {};

        ClientCore.getClientCore().sendRequest('_remote_provider_._request_models',d, function(data,err ){
            if(err != null){
                cb(null, err);
            }else{
                var models :Dynamic= Unserializer.run(data.json.models);

                cb(models, null);
            }
        });
    }

    override public function _getByIds(ids : Array<String>, clazz : Class<Dynamic>, cb : Dynamic) : Void{
        var app = WorkspaceApplication.getApplication();

        var d  :Dynamic = {};
        d.class_name = Type.getClassName(clazz);
        d.ids = ids;

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_request_objects_ids',d, function(data,err ){
            if(data.json != null){
                cb(parseObjects(data.json.objects),err);
            }else{
                cb([],err);
            }
        });
    }

    override private function _getByValues(values : Array<String>, clazz : Class<Dynamic>, field : String, cb : Dynamic){
        var app = WorkspaceApplication.getApplication();

        var d  :Dynamic = {};
        d.class_name = Type.getClassName(clazz);
        d.values = values;
        d.field = field;

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_request_objects_values',d, function(data,err ){
            if(data.json != null){
                cb(parseObjects(data.json.objects),err);
            }else{
                cb([],err);
            }
        });
    }

    override private function _getByPkeys(ids : Array<String>, clazz : Class<Dynamic>, cb : Dynamic){
        var app = WorkspaceApplication.getApplication();

        var d  :Dynamic = {};
        d.class_name = Type.getClassName(clazz);
        d.ids = ids;

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_request_objects_pkeys',d, function(data,err ){
            if(data.json != null){
                cb(parseObjects(data.json.objects),err);
            }else{
                cb([],err);
            }
        });
    }

    override private function _getByIdStartsWith(id : String, field : String, clazz : Class<Dynamic>, limit : Int, cb : Dynamic) : Void{
        var app = WorkspaceApplication.getApplication();

        var d  :Dynamic = {};
        d.class_name = Type.getClassName(clazz);
        d.id = id;
        d.limit = limit;

        if(field == null){
            d.field = null;
        }else{
            var model = getModel(clazz);
            d.field = model.modelAtrributeToRDBMS(field);
        }

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_request_objects_idstartswith',d, function(data,err ){
            if(data.json != null){
                cb(parseObjects(data.json.objects),err);
            }else{
                cb([],err);
            }
        });
    }

    override private function _query(query : Query, cb : Array<Dynamic>->Dynamic->Void) : Void{
        var app = WorkspaceApplication.getApplication();

        var d  :Dynamic = {};

        d.queryStr = query.serialise();

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_request_query', d, function(data, err){
            if(data.json != null){
                cb(parseObjects(data.json.objects), err);
            }else{
                cb([], err);
            }
        });
    }

    override public function _getByNamedQuery(queryId : String, parameters : Dynamic, clazz : Class<Dynamic>, cb : Dynamic) : Void{
        var app = WorkspaceApplication.getApplication();

        var d  :Dynamic = {};

        if(clazz != null){
            d.class_name = Type.getClassName(clazz);
        }

        d.queryId = queryId;
        d.parameters = haxe.Serializer.run(parameters);

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_request_objects_namedquery',d, function(data,err ){
            if(data.json != null){
                cb(parseObjects(data.json.objects),err);
            }else{
                cb([],err);
            }
        });
    }

    override private function _getObjects(clazz : Class<Dynamic>, cb : Dynamic){
        var app = WorkspaceApplication.getApplication();

        var d  :Dynamic = {};
        d.class_name = Type.getClassName(clazz);

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_request_objects_by_class',d, function(data,err ){
            if(data.json != null){
                cb(parseObjects(data.json.objects),err);
            }else{
                cb([],err);
            }
        });
    }

    override public function _update(attributeMaps : Array<Map<String, Dynamic>>,className : String,  cb : Dynamic) : Void{
        updateOrInsert('_remote_provider_._data_update_request', attributeMaps, className, cb);
    }

    override public function _insert(attributeMaps : Array<Map<String, Dynamic>>,className : String,  cb : Dynamic) : Void{
        updateOrInsert('_remote_provider_._data_insert_request', attributeMaps, className, cb);
    }

    private function updateOrInsert(msg : String, attributeMaps : Array<Map<String, Dynamic>>,className : String,  cb : Dynamic) : Void{
        var app = WorkspaceApplication.getApplication();

        var d : Dynamic = {};

        d.class_name = className;

        var objs = new Array<Dynamic>();

        for(atMap in attributeMaps){
            var obj : Dynamic = {};

            for(key in atMap.keys()){
                Reflect.setField(obj, key, atMap.get(key));
            }

            objs.push(obj);
        }

        d.objs = Json.stringify(objs);

        ClientCore.getClientCore().sendRequest(msg, d, function(data,err){
            cb(err);
        });
    }

    override public function _delete(attributeMaps : Array<Map<String, Dynamic>>,className : String,  cb : Dynamic) : Void{
        var model = getModelByStringName(className);

        var objPkeys = new Array<String>();

        var priField = model.getPrimaryKey_rdbms();

        var d : Dynamic = {};

        d.class_name = className;

        var objs = new Array<Dynamic>();

        for(atMap in attributeMaps){
            var obj : Dynamic = {};

            Reflect.setField(obj, priField, atMap.get(priField));

            objs.push(obj);
        }

        d.objs = Json.stringify(objs);

        var d2 : Dynamic = cast attributeMaps;

        js.Browser.window.console.log(d2);

        var app = WorkspaceApplication.getApplication();

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_delete_request', d, function(data,err){
            cb(err);
        });
    }

    override private function _rollback(cb : Dynamic) : Void{
        cb('Updating not supported on server');
    }

    override private function _commit(cb : Dynamic) : Void{
        var app = WorkspaceApplication.getApplication();

        var d : Dynamic = {};

        ClientCore.getClientCore().sendRequest('_remote_provider_._data_commit_request',d, function(data, err){
            cb(err);
        });
    }

    private function parseObjects(data : Array<Dynamic>) : Array<Dynamic>{
        //TODO: Check this doesn't introduce lag into named queries which use this.
        if(data != null){
            for(item in data){
                bindObject(item,null, false);
            }
        }

        return data;
    }

    override public function uploadFile(contents : Dynamic, file_identifier : String, cb : String->String->Void) : String{
        return ClientCore.getClientCore().sendRequest('_remote_provider_._data_request_upload_file', {'contents': contents, 'file_identifier': file_identifier}, function(data,err ){
            if(data.json != null){
                Reflect.setField(ClientCore.getClientCore().msgIdToJobInfo.get(data.msgId), 'file_identifier', data.json.upload_id);

                cb(err, data.json.upload_id);
            }else{
                cb(err, null);
            }
        });
    }

}