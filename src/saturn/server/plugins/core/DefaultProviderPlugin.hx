/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.core;

import saturn.app.SaturnServer;
import saturn.client.core.CommonCore;
import js.Node;
import saturn.db.NodePool;

class DefaultProviderPlugin extends BaseServerPlugin{
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        configureProviders();
    }

    public function configureProviders(){
        var connections : Array<Dynamic> = config.connections;

        for(connection in connections){
            _configureProvider(connection);
        }
    }

    public function configureProviderold(){
        var driver = config.connection.driver;

        var clazz = null;
        try{
            clazz = Type.resolveClass(driver);
        }catch(e:Dynamic){
            Node.console.log(e);
            Node.process.exit(-1);
        }

        var models : Dynamic = null;
        try{
            models = Type.createInstance(Type.resolveClass(config.connection.model_mapping), []).models;
            debug('Hello World');
        }catch(e:Dynamic){
            Node.console.log(e);
            Node.process.exit(-1);
        }

        if(config.connection.use_pool){
            var pool = NodePool.generatePool(
                'main_db',
                3,
                3,
                2000000,
                true,
                function(cb : String->Dynamic->Void){
                    debug('Configuring provider');
                    var provider = Type.createInstance(clazz, [models, config.connection, false]);

                    provider.dataBinding(false);

                    provider.readModels(function(err : String){
                        cb(err, provider);

                        debug(err);
                        // Should be fatal but server is running so we don't exit
                    });

                    provider.enableCache(config.enable_cache);
                },
                function(resource : Dynamic){
                    //resource.close();
                }
            );

            CommonCore.setPool(config.name, pool, config.default_provider);

        }else{
            debug('Configuring provider');
            var provider :Dynamic = Type.createInstance(clazz, [models, config.connection, false]);

            provider.enableCache(config.enable_cache);

            provider.dataBinding(false);

            provider.readModels(function(err : String){
                if(err != null){
                    // Always fatal
                    debug(err);
                    Node.process.exit(-1);
                }
            });

            CommonCore.setDefaultProvider(provider, config.name, config.default_provider);
        }
    }

    public function _configureProvider(config){
        var driver = config.driver;

        var clazz = null;
        try{
            clazz = Type.resolveClass(driver);
        }catch(e:Dynamic){
            Node.console.log(e);
            Node.process.exit(-1);
        }
        var models = null;
        try{
            models = Type.createInstance(Type.resolveClass(config.model_mapping), []).models;
            debug('Hello World ' + config.model_mapping);
        }catch(e:Dynamic){
            Node.console.log(e);
            Node.process.exit(-1);
        }

        if(config.use_pool){
            var pool = NodePool.generatePool(
                'main_db',
                3,
                3,
                2000000,
                true,
                function(cb : String->Dynamic->Void){
                    debug('Configuring provider');
                    var provider = Type.createInstance(clazz, [models, config, false]);

                    provider.dataBinding(false);

                    provider.setName(config.name);

                    provider.readModels(function(err : String){
                        cb(err, provider);

                        debug(err);
                        // Should be fatal but server is running so we don't exit
                    });

                    provider.enableCache(config.enable_cache);
                },
                function(resource : Dynamic){
                    //resource.close();
                }
            );

            CommonCore.setPool(config.name, pool, config.default_provider);
        }else{
            debug('Configuring provider');
            var provider :Dynamic = Type.createInstance(clazz, [models, config, false]);

            provider.enableCache(config.enable_cache);

            provider.dataBinding(false);

            provider.setName(config.name);

            provider.readModels(function(err : String){
                if(err != null){
                    // Always fatal
                    debug(err);
                    Node.process.exit(-1);
                }
            });

            CommonCore.setDefaultProvider(provider, config.name, config.default_provider);
        }
    }
}