/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.core;
#if CLIENT_SIDE
import saturn.core.annotations.AnnotationManager;
#end

import saturn.core.FileShim;

#if !PYTHON
import js.html.Uint8Array;
import js.html.ArrayBuffer;
#end

import haxe.ds.ObjectMap;
import saturn.db.Pool;
import saturn.db.Provider;

/**
* Summary:
*
* CommonCore is responsible for storing application wide resources which are
* generic in nature.  For example, you can use the methods setPool and getPool,
* to store pools of resources for use across the application.  The classic
* example of this would be to store a pool of connection objects.
*
* Why are pools needed in a single threaded environment?
*
* The single threaded nature of NodeJS and JavaScript make it tempting to use
* global variables to store, for example, a single database connection used by
* all NodeJS requests.  HOWEVER when you make a call, to for example a non-blocking
* IO function, you pass back control to the event loop which will call the
* callback you supplied to the IO function when the IO is completed.  In the time
* between you passing control back to the event loop and your callback being called
* the event loop may decide to process other incoming requests.  You should
* therefore use pools of objects which can only be used by a single work request
* at a time to avoid interleaving multiple "work transactions" into the same single
* database transaction.
*
* Obtaining a resource from a pool
*
* You can either obtain the pool by calling CommonCore.getPool(poolName).acquire(function(err, resource))
* or for convience you can call CommonCore.getResource(poolName, function(err, resource)).
*
* Return a resource to a pool
*
* When you obtain a resource via CommonCore.getResource() you must return it by
* calling CommonCore.releaseResource().  This is because CommonCore keeps track
* of which pool each object returned by CommonCore.getResource() came from.  This
* allows for downstream code to return the resource without needing to know the pool.
*
*
* Configuring global Provider instances
*
* Providers are objects which can be used to perform select/insert/update/delete
* operations on an underlying database.  The database might be local or remote.
* The saturn.db.Provider interface defines the functions a Provider must support.
*
* saturn.db.Provider Implementations
*
* NodeProvider implementation of Provider
*
* Use a Provider of this class if you need to pass on the requests to a remote
* NodeJS source.  The NodeJS server may in turn use it's own Provider class
* to serve the request but it doesn't have to.
*
* The default NodeProvider class doesn't support transactions.  You are therefore
* free to share a single NodeProvider instance across the whole application.  The
* MolBio client is configured in this way.  When the client starts up it calls
* CommonCore.setDefaultProvider with an instance of NodeProvider.  This ensures
* that each call to CommonCore.getDefaultProvider returns the same NodeProvider
* instance.
*
* saturn.db.SQLiteProvider
*
* The MolBio NodeJS server currently supports SQLite and Oracle databases.  The
* SQLiteProvider class implements the Provider interface for use on NodeJS.  Unlike
* NodeProvider, SQLiteProvider does support transactions.  Because of the way the
* event loop works in NodeJS (see above) it is important that you use a pool of
* SQLiteProvider instances rather than a singe instance like you can use for
* the NodeProvider class.
*
* The MolBio server creates a pool of Provider instances of the class specified
* in the server configuration file by calling CommonCore.setPool with the default
* option set to true.  By setting the default pool the MolBio server ensures that
* calls to CommonCore.getDefaultProvider will use the pool to obtain a new
* Provider instance.
*
**/
@:keep
class CommonCore {
    static var DEFAULT_POOL_NAME : String;

    static var pools = new Map<String, Pool>();
    static var resourceToPool = new ObjectMap<Dynamic, String>();

    static var providers : Map<String, Provider> = new Map<String, Provider>();

    static var combinedModels = null;

    #if CLIENT_SIDE
    static var annotationManager = new AnnotationManager();
    #end

    public static function setDefaultProvider(provider : Provider, ?name : String = 'DEFAULT', defaultProvider : Bool){
        providers.set(name, provider);

        if(defaultProvider){
            DEFAULT_POOL_NAME = name;
        }
    }

    #if CLIENT_SIDE
    public static function getAnnotationManager() : AnnotationManager {
        return annotationManager;
    }
    #end

    public static function closeProviders(){
        for(name in providers.keys()){
            providers.get(name)._closeConnection();
        }
    }

    public static function getStringError(error : Dynamic) : String{
        #if !PYTHON
        var dwin : Dynamic = js.Browser.window;
        dwin.error = error;
        #end
        return error;
    }

    public static function getCombinedModels() : Map<String, Dynamic>{
        if(combinedModels == null){
            combinedModels = new Map<String, Map<String, Dynamic>>();

            for(name in CommonCore.getProviderNames()){
                var models : Map<String, Dynamic> = CommonCore.getDefaultProvider(name).getModels();

                for(key in models.keys()){
                    combinedModels.set(key, models.get(key));
                }
            }
        }

        return combinedModels;
    }

    public static function getProviderNameForModel(name : String) : String{
        var models = getCombinedModels();

        if(models.exists(name)){
            if(models.get(name).exists('provider_name')){
                return models.get(name).get('provider_name');
            }else{
                return null;
            }
        }else{
            return null;
        }
    }

    public static function getProviderForNamedQuery(name : String){
        //won't work for pools
        for(providerName in providers.keys()){
            var provider : Provider = providers.get(providerName);

            var config = provider.getConfig();

            if(Reflect.hasField(config, 'named_queries')){
                if(Reflect.hasField(Reflect.field(config, 'named_queries'), name)){
                    return providerName;
                }
            }
        }

        return null;
    }

    public static function getDefaultProvider(?cb: String->Dynamic->Void = null, ?name :String = null) : Dynamic{
        //Breaking change
        if(name == null){
            name = getDefaultProviderName();
        }
        if(providers.exists(name)){
            if(cb != null){
                cb(null, providers.get(name));
            }

            return providers.get(name);
        }else if(name != null){
            getResource(name,cb);

            return -1;
        }

        return null;
    }

    public static function getProviderNames() : Array<String>{
        var names = new Array<String>();

        for(name in providers.keys()){
            names.push(name);
        }

        for(name in pools.keys()){
            names.push(name);
        }

        return names;
    }

    public static function getFileExtension(fileName : String) : String{
        var r = ~/\.(\w+)/;

        r.match(fileName);

        return r.matched(1);
    }


    #if !PYTHON
    public static function getBinaryFileAsArrayBuffer(file : Dynamic) : ArrayBuffer{
        var fileReader : Dynamic = untyped __js__('new FileReader()');

        return fileReader.readAsArrayBuffer(file);
    }


    public static function convertArrayBufferToBase64(buffer : ArrayBuffer) : String{
        var binary = '';
        var bytes = new Uint8Array( buffer );
        var len = bytes.byteLength;

        for(i in 0...len){
            binary += String.fromCharCode( bytes[ i ] );
        }

        return js.Browser.window.btoa( binary );
    }
    #end

    /**
    * getFileAsText returns the contents of file as a string.
    *
    * @param file - Object from HTML5 File API or ZipObject from JSZip library
    * @param cb - Callback taking the file content as a String
    **/
    public static function getFileAsText(file : Dynamic, cb : String->Void){
        if(Std.is(file, FileShim)){
            cb(file.getAsText());
        }else if(Reflect.hasField(file, '_data')){
            cb(file.asText());
        }else{
            var fileReader : Dynamic = untyped __js__('new FileReader()');

            fileReader.onload = function(e) {
                cb(e.target.result);
            };

            fileReader.readAsText(file);
        }
    }

    public static function getFileInChunks(file : Dynamic, chunkSize : Int, cb : String->String->Dynamic->Void){
        // File position offset
        var offset = 0;

        // File size
        var fileSize = file.size;

        // Chunking function
        var chunker = null;

        chunker = function(){
            // File reader instance
            var reader = untyped __js__('new FileReader()');

            // Get bytes as base64 encoded string
            reader.readAsDataURL(file.slice(offset, offset + chunkSize));

            // Called on end of file reader (success or failure)
            reader.onloadend = function(event){
                // Check for reading errors
                if(event.target.error == null){
                    // When no errors send result to caller
                    cb(null, reader.result.split(',')[1], function(){
                        // Increment offset
                        offset += chunkSize;

                        // Check if we have reached the end of the file
                        if(offset >= fileSize){
                            // Inform caller we are finished
                            cb(null, null, null);
                        }else{
                            // Get next chunk
                            chunker();
                        }
                    });
                }else{
                    cb(event.target.error, null, null);
                }
            }
        }

        // Start chunker
        chunker();
    }

    #if !PYTHON
    public static function getFileAsArrayBuffer(file : Dynamic, cb : ArrayBuffer->Void){
        if(Std.is(file, FileShim)){
            cb(file.getAsArrayBuffer());
        }else if(Reflect.hasField(file, '_data')){
            cb(file.asUint8Array());
        }else{
            var fileReader : Dynamic = untyped __js__('new FileReader()');

            fileReader.onload = function(e) {
                cb(e.target.result);
            };

            fileReader.readAsArrayBuffer(file);
        }
    }
    #end

    /**
    * setPool should be called to store a pool by name for use application wide
    *
    * poolName : The name of the pool
    * pool : The pool to store
    *
    * @returns :
    **/
    public static function setPool(?poolName : String = 'DEFAULT', pool : Pool, isDefault : Bool) : Void{
        pools.set(poolName, pool);

        if(isDefault){
            DEFAULT_POOL_NAME = poolName;
        }
    }

    /**
    * getPool should be called to obtain the pool with the given name.
    *
    * poolName : The name of the pool to retrieve
    *
    * @returns: The Pool object or null if the pool name isn't valid
    **/
    public static function getPool(?poolName : String = 'DEFAULT') : Pool {
        if(pools.exists(poolName)){
            return pools.get(poolName);
        }else{
            return null;
        }
    }

    /**
    * getResource should be called to obtain a resource from the given pool
    *
    * The callback is passed an error message and null resource if the pool name
    * isn't valid.  You must call releaseResource after you are done with the
    * resource otherwise the resource will never be freed as CommonCore remembers
    * which resources are in use and which pool they came from.
    *
    * poolName : The name of the pool
    * cb : Callback which is passed the resource from the pool or the error message
    **/
    public static function getResource(?poolName : String = 'DEFAULT', cb : String->Dynamic->Void) : Void {
        var pool = getPool(poolName);

        if(pool != null){
            pool.acquire(function(err : String, resource : Dynamic){
                if(err == null){
                    resourceToPool.set(resource, poolName);
                }

                cb(err, resource);
            });
        }else{
            cb('Invalid pool name',null);
        }
    }

    /**
    * releaseResource should be called to pass back a resource to the pool it came from.
    *
    * A resource can only be mapped back to a pool if you obtained it via CommonCore.getResource
    *
    * resource : the resource to place back into the pool
    **/
    public static function releaseResource(resource : Dynamic) : Int{
        if(resourceToPool.exists(resource)){
            var poolName : String = resourceToPool.get(resource);

            if(pools.exists(poolName)){
                var pool : Pool = pools.get(poolName);

                pool.release(resource);
                return -3;
            }else{
                return -2;
            }
        }else{
            return -1;
        }
    }

    public static function makeFullyQualified(path : String){
        #if !PYTHON
        var location = js.Browser.location;

        return location.protocol+'//'+location.hostname+':'+location.port+'/'+path;
        #else
        return null;
        #end
    }

    public static function getContent(url : String, onSuccess, onFailure = null){
        #if CLIENT_SIDE
        if(onFailure == null){
            onFailure = function(err : String){
                WorkspaceApplication.getApplication().showMessage('Error retrieving resource', url);
            };
        }
        #end

        bindings.Ext.Ajax.request({
            url: url,
            success: function(response, opts) {
                onSuccess(response.responseText);
            },
            failure: function(response, opts) {
                onFailure(response);
            }
        });
    }

    public static function getDefaultProviderName() : String{
        return DEFAULT_POOL_NAME;
    }
}
