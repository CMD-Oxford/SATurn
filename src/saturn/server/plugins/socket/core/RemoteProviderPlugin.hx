/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket.core;

import saturn.db.Model;
import saturn.core.Util;
import saturn.db.query_lang.Query;
import saturn.core.User;
import saturn.app.SaturnServer;
import saturn.db.Provider;
import js.Node;
import bindings.Ext.NodeSocket;
import saturn.server.plugins.socket.core.BaseServerSocketPlugin;
import saturn.client.core.CommonCore;
import haxe.Serializer;
import haxe.Json;

class RemoteProviderPlugin extends BaseServerSocketPlugin{
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        registerProviderCommand('_request_models', getModels);
        registerProviderCommand('_data_request_objects_idstartswith', getByIdStartsWith);
        registerProviderCommand('_data_request_objects_ids', getObjectIds);
        registerProviderCommand('_data_request_objects_values', getByValues);
        registerProviderCommand('_data_request_objects_pkeys', getByPkeys);
        registerProviderCommand('_data_request_objects_by_class', getByClass);
        registerProviderCommand('_data_request_objects_namedquery', getByNamedQuery);
        registerProviderCommand('_data_delete_request', delete);
        registerProviderCommand('_data_insert_request', insert);
        registerProviderCommand('_data_update_request', update);
        registerProviderCommand('_data_commit_request', commit);
        registerProviderCommand('_data_request_query', query);
        registerProviderCommand('_data_request_upload_file', uploadFile);
    }

    public function registerProviderCommand(command : String, cb : Dynamic->Provider->User->Dynamic->Void){
        // Note this function doesn't provide any user-level security for the data access web-service
        // User security is enforced by BaseServerSocketPlugin.registerListener

        registerListener(command, function(data : Dynamic, socket : NodeSocket){
            var user = getSocketUserNoAuthCheck(socket);

            var providerName = CommonCore.getDefaultProviderName();

            if(Reflect.hasField(data, 'queryId')){
                var namedQuery = Reflect.field(data, 'queryId');
                debug('Looking ' + namedQuery);
                providerName = CommonCore.getProviderForNamedQuery(namedQuery);
                debug('Got for named query: ' + providerName);
            }else if(Reflect.hasField(data, 'class_name')){
                debug('Looking for provider');
                providerName = CommonCore.getProviderNameForModel(data.class_name);
                if(providerName == null){
                    debug('Error finding provider for ' + data.class_name);

                    handleError(data, 'Unable to find source for entity');
                    return;
                }
            }else if(Reflect.hasField(data, 'queryStr')){
                var query = Query.deserialise(Reflect.field(data, 'queryStr'));

                data.queryObj = query;

                var clazzList = query.getClassList();
                var clazz_name = clazzList[0];

                debug(clazz_name);

                providerName = CommonCore.getProviderNameForModel(clazz_name);

                debug(providerName);

                if(providerName == null){
                    debug('Error finding provider for ' + clazz_name);

                    handleError(data, 'Unable to find source for entity');
                    return;
                }
            }

            CommonCore.getDefaultProvider(function(err, provider : Provider){
                //We get here when the pool has yielded a provider or thrown an error
                if(err != null){
                    handleError(data, err);
                }else{
                    // If we the request is from an authenticated user and we require DB access as the user
                    // We generate a linked provider (to save resources) which will connect as the user
                    var disconnectOnEnd = false;
                    var connectAsUser = '';
                    var config = provider.getConfig();

                    if(config != null){
                        connectAsUser = config.connect_as_user;
                    }

                    debug('Connect as user is: ' + connectAsUser);

                    if(command != '_request_models' && (connectAsUser == 'preferred' || connectAsUser == 'force')){
                        if(user == null){
                            if(connectAsUser == 'force'){
                                debug('Connect as user is forced but user is not logged in to ' + providerName + ' ' + command);
                                //throw exception
                                handleError(data, 'You must be logged in to use this provider');
                                return;
                            }else{
                                //Actual work is performed here
                                debug('Calling method on Provider');
                                cb(data, provider, user, function(){
                                    if(disconnectOnEnd){
                                        provider._closeConnection();
                                    }
                                });
                            }
                        }else{
                            debug('Connecting as user');
                            var original_provider = provider;
                            var userProvider = provider.generatedLinkedClone();
                            userProvider.setConnectAsUser(true);

                            disconnectOnEnd = true;

                            getSaturnServer().getAuthenticationPlugin().decryptUserPassword(user, function(err : String, user : User){

                                userProvider.setUser(user);

                                if(err != null){
                                    handleError(data, err);
                                }else{
                                    //Actual work is performed here
                                    debug('Calling method on Provider');

                                    cb(data, userProvider, user, function(){
                                        if(disconnectOnEnd){
                                            userProvider._closeConnection();
                                        }
                                    });
                                }
                            });
                        }
                    }else{
                        //Actual work is performed here
                        debug('Calling method on Provider');
                        cb(data, provider, user, function(){
                            if(disconnectOnEnd){
                                provider._closeConnection();
                            }
                        });
                    }
                }
            }, providerName);
        });
    }

    public function getModels(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        var json : Dynamic = {};

        var combined_models = CommonCore.getCombinedModels();

        json.models = Serializer.run(combined_models);

        sendJson(data, json, null);

        cb();
    }

    public function getByIdStartsWith(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            provider.getByIdStartsWith(data.id, data.field, Type.resolveClass(data.class_name), data.limit,function(objs, err){
                var json : Dynamic = {};

                var i = CommonCore.releaseResource(provider);

                json.error = err;
                json.objects = objs;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            handleError(data, e);

            cb();
        }
    }

    public function query(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            var queryObj = data.queryObj;

            debug(Type.getClassName(Type.getClass(queryObj)));

            provider.query(queryObj, function(objs, err){
                var json : Dynamic = {};

                var i = CommonCore.releaseResource(provider);

                json.error = err;
                json.objects = objs;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            Util.debug(e);

            handleError(data, e);

            cb();
        }
    }

    public function getObjectIds(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            provider.getByIds(data.ids, Type.resolveClass(data.class_name), function(objs, err){
                var json : Dynamic = {};

                CommonCore.releaseResource(provider);

                json.error = err;
                json.objects = objs;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }

    public function getByValues(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            provider.getByValues(data.values, Type.resolveClass(data.class_name), data.field, function(objs, err){
                var json : Dynamic = {};

                CommonCore.releaseResource(provider);

                json.error = err;
                json.objects = objs;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }

    public function getByPkeys(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            provider.getByPkeys(data.ids, Type.resolveClass(data.class_name), function(objs, err){
                var json : Dynamic = {};

                CommonCore.releaseResource(provider);

                json.error = err;
                json.objects = objs;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }

    public function getByClass(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            provider.getObjects(Type.resolveClass(data.class_name), function(objs, err){
                var json : Dynamic = {};

                CommonCore.releaseResource(provider);

                json.error = err;
                json.objects = objs;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }

    public function getByNamedQuery(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            debug('Start ' + data.queryId);
            var params = haxe.Unserializer.run(data.parameters);
            debug('End');
            if(data.queryId == 'saturn.workflow'){
                params[1].setRemote(true);
            }

            params = autoCompleteFields(params, user);

            var clazz = null;

            if(data.class_name != null){
                    clazz = Type.resolveClass(data.class_name);
            }

            provider.getByNamedQuery(data.queryId, params, clazz, provider.getConfig().enable_cache, function(objs, err){
                debug('Returning from named query ' + data.queryId);

                var json : Dynamic = {};

                CommonCore.releaseResource(provider);

                json.error = err;
                json.objects = objs;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }

    public function autoCompleteFields(params :Array<Dynamic>, user : User){
        var retParams = [];

        if(Std.is(params, Array)){
            for(paramSet in params){
                for(field in Reflect.fields(paramSet)){
                    if(field == '_username'){
                        Util.debug('Setting username to ' + user.username);
                        Reflect.setField(paramSet, '_username', user.username);
                    }
                }
                retParams.push(paramSet);
            }
            return retParams;
        }else{
            return params;
        }
    }

    public function delete(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            var objs = convertJsonObjectArray(data.objs);

            provider._delete(objs, data.class_name, function(err){
                var json : Dynamic = {};

                json.error = err;

                CommonCore.releaseResource(provider);

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }

    public function insert(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        //try{
            var objs = convertJsonObjectArray(data.objs);

            provider._insert(objs, data.class_name, function(err){
                var json : Dynamic = {};

                CommonCore.releaseResource(provider);

                Node.console.log('Returning from insert: ' + err);

                if(err != null){
                    handleError(data, err, null);
                }else{
                    sendJson(data, json, null);
                }

                cb();
            });
        /*}catch(e : Dynamic){

            CommonCore.releaseResource(provider);

            sendError(data, e, null);
        }*/
    }

    public function update(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            var objs = convertJsonObjectArray(data.objs);

            provider._update(objs, data.class_name, function(err){
                var json : Dynamic = {};

                CommonCore.releaseResource(provider);

                json.error = err;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }

    public function commit(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            provider.commit(function(err){
                var json : Dynamic = {};

                CommonCore.releaseResource(provider);

                json.error = err;

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }

    function convertJsonObjectArray(jsonObjsStr : String) : Array<Map<String,String>>{
        var jsonObjs :Array<Dynamic> = Json.parse(jsonObjsStr);

        var objs = new Array<Map<String,String>>();

        for(jsonObj in jsonObjs){
            var obj = new Map<String,String>();

            for(field in Reflect.fields(jsonObj)){
                obj.set(field, Reflect.field(jsonObj, field));
            }

            objs.push(obj);
        }

        return objs;
    }

    public function uploadFile(data : Dynamic, provider : Provider, user: User, cb : Void->Void){
        try{
            provider.uploadFile(data.contents, data.file_identifier, function(err, upload_id){
                var json : Dynamic = {'upload_id': upload_id};

                CommonCore.releaseResource(provider);

                sendJson(data, json, null);

                cb();
            });
        }catch(e : Dynamic){
            CommonCore.releaseResource(provider);

            sendError(data, e, null);

            cb();
        }
    }
}