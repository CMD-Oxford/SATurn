/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.provider.hooks;
import haxe.Json;
import saturn.core.Util;

#if CLIENT_SIDE

#elseif NODE
import js.Node.NodeChildProcess;
import bindings.NodeTemp;
import saturn.app.SaturnServer;
#end

class ExternalJsonHook {
    public static function run(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void, hookConfig : Map<String, Dynamic>){
        Util.debug('Running external command');

        if(hookConfig == null){
            cb(null, 'Hook configuration is missing');return;
        }

        var program :String = null;
        if(Reflect.hasField(hookConfig, 'program')){
            program = Reflect.field(hookConfig, 'program');
        }else{
            cb(null, 'Invalid configuration, program field missing');
            return;
        }

        var progArguments :Array<String> = new Array<String>();

        if(Reflect.hasField(hookConfig, 'arguments')){
            var localprogArguments :Array<String> = cast Reflect.field(hookConfig,'arguments');
            for(arg in localprogArguments){
                progArguments.push(arg);
            }
        }

        var config = params[0];

        #if CLIENT_SIDE
        Util.getNewExternalProcess(function(process){
            process.getTemporaryFileName(function(inputJsonFileName){
                process.getTemporaryFileName(function(outputJsonFileName){
                    progArguments.push(inputJsonFileName);
                    progArguments.push(outputJsonFileName);

                    var inputJson = Json.stringify(config);

                    process.writeFile(inputJsonFileName, inputJson, function(err){
                        if(err == ''){
                            process.start(program, progArguments);

                            process.waitForClose(function(state){
                                if(state == ''){
                                   process.readFile(outputJsonFileName, function(contents){

                                        if(contents != null){
                                            var outputJson = Json.parse(contents);

                                            cb(outputJson, null);
                                        }else{
                                            cb(null, 'Unable to read output JSON file');
                                        }
                                    });
                                }else{
                                    cb(null, 'An error has occurred ');
                                }
                            });
                        }else{
                            cb(null, err);
                        }
                    });
                });
            });
        });
        #elseif NODE
        NodeTemp.open('input_json', function(err : String, fh_input : Dynamic){
            if(err != null){
                Util.debug('Error generating temporary input file name');
                cb(null, err);
            }else{

                // Function below runs the external process via the next function below which replaces file upload keys
                // with real paths.  Silly callback set-up because of Node Async
                var run = function(){
                    var inputJsonStr = js.Node.json.stringify(config);
                    //Util.debug(inputJsonStr);

                    js.Node.fs.writeFileSync(fh_input.path, inputJsonStr);

                    //js.Node.fs.closeSync(fh_input);

                    NodeTemp.open('output_json', function(err : String, fh_output : Dynamic){

                        if(err != null){
                            Util.debug('Error generating temporary output file name');
                            cb(null, err);
                        }else{
                            progArguments.push(fh_input.path);
                            progArguments.push(fh_output.path);

                            Util.inspect(progArguments);
                            Util.print(program);

                            var p : NodeChildProcess = js.Node.child_process.spawn(program, progArguments);

                            p.stderr.on('data', function(data){
                                Util.debug(data.toString());
                            });

                            p.stdout.on('data', function(data){
                               Util.debug(data.toString());
                            });

                            p.on('close', function(retVal : String){
                                if(retVal == '0'){
                                    var jsonStr = js.Node.fs.readFileSync(fh_output.path, {encoding: 'utf8'});

                                    //js.Node.fs.closeSync(fh_output);

                                    js.Node.fs.unlinkSync(fh_output.path);
                                    js.Node.fs.unlinkSync(fh_input.path);

                                    var jsonObj = js.Node.json.parse(jsonStr);

                                    var error = null;
                                    if(Reflect.hasField(jsonObj, 'error')){
                                        error = Reflect.field(jsonObj, 'error');
                                    }

                                    cb([jsonObj], error);
                                }else{
                                    Util.debug('External process has failed');
                                    cb(null, 'External process returned a non-zero exit status');
                                }
                            });
                        }
                    });
                };

                // Function recursively checks the input parameters for client-side file upload keys
                // which need to be replaced with real paths before being passed to the external process
                var fields = Reflect.fields(config);

                var next = null;

                next = function(){
                    if(fields.length == 0){
                        run();
                    }else{
                        var field = fields.pop();

                        if(field.indexOf('upload_key') == 0){
                            Util.debug('Found upload key');
                            var saturn = SaturnServer.getDefaultServer();

                            var redis = saturn.getRedisClient();

                            var upload_key = Reflect.field(config, field);
                            var path = redis.get(upload_key, function(err, path){
                                if(path == null){
                                    cb(null, 'Invalid file upload key ' + upload_key);
                                    return;
                                }else{
                                    Reflect.setField(config, field, path);
                                    next();
                                }
                            });
                        }else if(field.indexOf('out_file') == 0){
                            var saturn = SaturnServer.getDefaultServer();
                            var baseFolder = saturn.getRelativePublicOuputFolder();

                            Reflect.setField(config, field, baseFolder);
                            next();
                        }else{
                            next();
                        }
                    }
                };

                next();

            }

        });
        #end
    }
}
