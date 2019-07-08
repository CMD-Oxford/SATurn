/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.scripts;

import saturn.core.Util;
import saturn.core.Generator;
import saturn.db.Provider;
import saturn.db.NodePool;
import saturn.client.core.CommonCore;
import js.Node;
import saturn.db.NodePool;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class BaseScript {
    public var debug : Dynamic = Node.require('debug')('saturn:script_debug');
    public var print : Dynamic = Node.console.log;
    public var wft : Dynamic = Node.require('wtfnode');
    public var nutil : Dynamic = Node.require('util');

    public var split : Dynamic = Node.require('split');
    public var fs : Dynamic = Node.require('fs');
    public var provider : Provider = null;
    public var conn : Dynamic = null;

    var finished = false;

    var stacks : Array<Generator<Dynamic>>;

    static var runningScript : BaseScript;

    public function new() {
        debug('Starting');
        stacks = new Array<Generator<Dynamic>>();

        runningScript = this;

        var wait = null;

        wait = function(){
            if(finished){
                debug('Script Finished');

                cleanup();

                haxe.Timer.delay(function(){wft.dump();}, 1000);

                return;
            }else{
                haxe.Timer.delay(wait, 1000);
            }
        };

        wait();

        start(function(){

        });
    }

    public function inspect(obj : Dynamic){
        Util.inspect(obj);
    }

    public function cleanup(){
        CommonCore.closeProviders();
    }

    public static function getRunningScript() : BaseScript {
        return runningScript;
    }

    public function stop(){
        finished = true;
    }

    public function channel(workCb : Dynamic, endCb : Dynamic = null) : Generator<Dynamic>{
        var job = new Generator<Dynamic>(-1);

        job.setMaxAtOnce(1000);

        if(endCb != null){
            job.onEnd(endCb);
        }else{
            job.onEnd(function(err : String){
                stacks.remove(job);

                if(stacks.length == 0){
                    stop();
                }
            });

            stacks.push(job);
        }


        job.onNext(workCb);

        return job;
    }

    public function getArg(i : Int){
        return Node.process.argv[3+i];
    }

    public function getArgCount() : Int{
        return Node.process.argv.length -4;
    }

    @:async public function setup(){
        if(Node.process.argv.length >= 3){
            var servicesFile = Node.process.argv[2];

            debug('Loading ' + servicesFile);

            var err : String = @await processConfigurationFile(servicesFile);

            if(err != null){
                print('Error in prestart: ' + err);
                Node.process.exit(-3);
            }else{
                debug('Configuring provider');
                provider = CommonCore.getDefaultProvider();

                var p : Dynamic = provider;

                conn = p.theConnection;
            }

            usage(function(){

            });
        }
    }

    @:async public function usage(){

    }

    public static function main(){
        var obj = new BaseScript();

        obj.start(function(){

        });
    }

    @:async function start(){
        @await setup();

        @await run();

        finished = true;
    }

    @:async function run(){

    }

    function open(path, cb : NodeErr->String->Void){
        fs.createReadStream(path).pipe(split()).on('data', function(line){
            cb(null,line);
        }).on('error', function(err){
            cb(err, null);
        }).on('end', function(){
            cb(null, null);
        });
    }

    function openw(path){
        debug('Opening: ' + path);
        return fs.createWriteStream(path);
    }

    function write(fd, contents){
        fs.write(fd, contents);
    }

    @:async
    public static function processConfigurationFile(servicesFile : String) : String{
        var err: NodeErr, content : String = @await Node.fs.readFile(servicesFile,{'encoding':'utf8'});

        if(err == null){
            var serviceConfig = Node.json.parse(content);
            var plugins :Array<Dynamic> = Reflect.field(serviceConfig, 'plugins');

            var providerPlugin = null;

            for(plugin in plugins){
                if(Reflect.field(plugin, 'clazz') == 'saturn.server.plugins.core.DefaultProviderPlugin'){
                    providerPlugin = plugin;

                    break;
                }
            }

            if(providerPlugin == null){
                return 'Provider class not found';
            }else{
                @await configureProviders(providerPlugin);

                return null;
            }
        }else{
            return 'Unable to read service file';
        }
    }

    public static function configureProviders(config, onready : Void->Void){
        var connections : Array<Dynamic> = config.connections;
        var done =0;
        for(connection in connections){
            _configureProvider(connection, function(err: String){
                if(err != null){
                    Node.console.log('Error connecting');
                    Node.process.exit(-1);
                }else{
                    done ++;

                    if(done == connections.length){
                        for(name in CommonCore.getProviderNames()){

                        }
                        CommonCore.getDefaultProvider(null);
                        onready();
                    }
                }
            });
        }
    }

    public static  function _configureProvider(config, onready : String->Void){
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
                    var provider = Type.createInstance(clazz, [models, config, false]);

                    provider.dataBinding(false);

                    provider.setName(config.name);

                    provider.readModels(onready);

                    provider.enableCache(false);
                },
                function(resource : Dynamic){
//resource.close();
                }
            );

            CommonCore.setPool(config.name, pool, config.default_provider);
        }else{
            var provider :Dynamic = Type.createInstance(clazz, [models, config, false]);

            provider.enableCache(false);

            provider.dataBinding(false);

            provider.setName(config.name);

            provider.readModels(onready);

            Util.debug('Configured ' + config.name + ' default = '+ config.default_provider);

            CommonCore.setDefaultProvider(provider, config.name, config.default_provider);
        }
    }

    public  function die(msg : String){
        print(msg);
        Node.process.exit(-1);
    }

    public static function exit(code : Int){
        Node.process.exit(code);
    }
}
