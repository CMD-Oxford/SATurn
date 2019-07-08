/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

#if CLIENT_SIDE
import haxe.Unserializer;
import haxe.Serializer;
import saturn.client.core.ClientCore;
#elseif SERVER_SIDE
   import saturn.app.SaturnServer;
   import js.Node;
#elseif SCRIPT_ENGINE
    import saturn.scripts.BaseScript;
    import js.Node;
#end

#if WORKSPACE_CLIENT_APP
import saturn.client.WorkspaceApplication;
#end

import saturn.db.Provider;
import saturn.client.core.CommonCore;
@:keep
class Util {
    #if NODE
        public static var fs : Dynamic = Node.require('fs');
        public static var temp = Node.require('temp');
        public static var split : Dynamic = Node.require('split');
    #end

    public function new() {

    }

    @:keep
    public static function debug(msg : String){
        #if CLIENT_SIDE
            ClientCore.getClientCore().debug(msg);
        #elseif SERVER_SIDE
            SaturnServer.getDefaultServer().debug(msg);
        #elseif SCRIPT_ENGINE
            BaseScript.getRunningScript().debug(msg);
        #elseif PYTHON
            print(msg);
        #end
    }

    public static function inspect(obj : Dynamic) {
        #if CLIENT_SIDE
            //WorkspaceApplication.getApplication().debug(msg);
        #elseif SERVER_SIDE
            js.Node.console.log(obj);
            //SaturnServer.getDefaultServer().debug(msg);
        #elseif SCRIPT_ENGINE
            print(BaseScript.getRunningScript().nutil.inspect(obj, {depth: null}));
        #end
    }

    public static function print(msg : String){
        #if WORKSPACE_CLIENT_APP
            WorkspaceApplication.getApplication().debug(msg);
        #elseif NODE
            js.Node.console.log(msg);
        #end
    }

    public static function openw(path : String) : Stream{
        #if NODE
            return fs.createWriteStream(path);
        #else
            return null;
        #end
    }

    public static function opentemp(prefix : String, cb : String->Stream->String->Void) {
        #if NODE
            temp.open(prefix, function(error,info){
                cb(error, new Stream(info.fd), info.path);
            });
        #end
    }

    public static function isHostEnvironmentAvailable() : Bool{
        #if WORKSPACE_CLIENT_APP
            return WorkspaceApplication.getApplication().isHostEnvironmentAvailable();
        #else
            return false;
        #end
    }

    public static function exec(program : String, args : Array<String>, cb :Int->Void){
        #if NODE
        var proc = js.Node.child_process.spawn(program,args);

        proc.stderr.on('data', function(error){
            debug(error.toString('utf8'));
        });

        proc.stdout.on('data', function(msg){
            debug(msg.toString('utf8'));
        });

        proc.on('close', function(code){
            debug('Closed');
            cb(code);
        });

        proc.on('error', function(error){
            debug(error);
            cb(-1);
        });

        debug('Hello X');
        #elseif CLIENT_SIDE
        Util.getNewExternalProcess(function(process){
            process.start(program, args);

            process.waitForClose(function(state){
                if(state == ''){
                    cb(0);
                }else{
                    cb(-1);
                }
            });
        });
        #end
    }

    public static function getNewExternalProcess(cb:Dynamic->Void){
        #if WORKSPACE_CLIENT_APP
        WorkspaceApplication.getApplication().getNewQtProcess(cb);
        #end
    }

    public static function getNewFileDialog(cb: String->Dynamic->Void){
        #if WORKSPACE_CLIENT_APP
        WorkspaceApplication.getApplication().getNewFileDialog(cb);
        #end
    }

    public static function saveFileAsDialog(contents : Dynamic, cb : Dynamic->String->Void){
        #if CLIENT_SIDE
        getNewFileDialog(function(err : String, dialog : Dynamic){
            dialog.setSelectExisting(false);
            dialog.fileSelected.connect(function(fileName){
                js.Browser.alert(fileName);
                debug('Hello, saving ' + fileName);
                Util.saveFile(fileName, contents, function(err : String){
                    cb(err, fileName);
                });
            });

            dialog.open();
        });
        #end
    }

    public static function saveFile(fileName : String, contents : Dynamic, cb:String->Void){
        #if CLIENT_SIDE
        getNewExternalProcess(function(process){
            process.writeFile(fileName, contents, function(err){
                cb(err);
            });
        });
        #end
    }

    public static function jsImports(paths : Array<String>, cb:Map<String, String>->Void){
        var errs = new Map<String, String>();

        var next = null;
        next = function(){
            if(paths.length == 0){
                cb(errs);
            }else{
                var path = paths.pop();
                jsImport(path, function(err : String){
                    errs.set(path, err);
                    next();
                });
            }
        };

        next();
    }

    public static function jsImport(path :String, cb:String->Void){
        #if CLIENT_SIDE
            Util.readFile(path, function(err, content){
                if(err == null){
                    if(content != null){
                        print(content);
                        print('Content');
                        js.Lib.eval(content);
                    }else{
                        err = 'Empty import';
                    }
                }

                cb(err);
            });
        #end
    }

     public static function openFileAsDialog(cb : Dynamic->String->String->Void){
        #if CLIENT_SIDE
        getNewFileDialog(function(err : String, dialog : Dynamic){
            dialog.setSelectExisting(true);
            dialog.fileSelected.connect(function(fileName){
                Util.readFile(fileName, function(err, contents : String){
                    cb(err, fileName, contents);
                });
            });

            dialog.open();
        });
        #end
    }

    public static function readFile(fileName : String, cb:String->String->Void){
        #if CLIENT_SIDE
        getNewExternalProcess(function(process){
            process.readFile(fileName, function(contents){
                if(contents != null){
                    cb(null, contents);
                }else{
                    cb('Unable to read file', null);
                }
            });
        });
        #end
    }


    public static function open(path : String, cb : Dynamic->String->Void){
        #if NODE
        fs.createReadStream(path).pipe(split()).on('data', function(line){
            cb(null,line);
        }).on('error', function(err){
            cb(err, null);
        }).on('end', function(){
            cb(null, null);
        });
        #elseif CLIENT_SIDE
        Util.getNewExternalProcess(function(process){
            process.readFile(function(contents){
                if(contents == null){
                    cb('Unable to read file', null);
                }else{
                    cb(null, contents);
                }
            });
        });
        #end
    }

    public static function getProvider() : Provider{
        return CommonCore.getDefaultProvider();
    }

    public static function string(a : Dynamic) : String {
        return Std.string(a);
    }

    public static function clone(obj : Dynamic) : Dynamic {
        var ser = haxe.Serializer.run(obj);
        return haxe.Unserializer.run(ser);
    }
}

@:keep
class Stream {
    var streamId : Int;

    public function new(streamId : Int){
        this.streamId = streamId;
    }

    public function write(content : String){
        #if NODE
            Util.fs.writeSync(streamId, content);
        #end
    }

    public function end(cb : String->Void){
        #if NODE
            Util.fs.closeSync(streamId, cb);
        #end
    }
}
