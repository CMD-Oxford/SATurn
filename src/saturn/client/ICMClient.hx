/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

import js.JQuery;
import saturn.util.StringUtils;
import bindings.Ext.NodeSocketIO;
import bindings.Ext.NodeSocket;
import bindings.Ext.ICMScript;

class ICMClient {
	var nodeSocket : NodeSocket;
	
	var callBackMap : Map<String, Dynamic>;
	
	var forwardICMCommands : Bool;
    var commandsWaiting : Array<Dynamic>;
	
	static var reg_jsonStart : EReg = ~/\\?"\s*<JSON_START>/g;
	static var reg_jsonStop : EReg = ~/<JSON_STOP>\\?"/g;
	
	static var theClient : ICMClient;

    public static function inScarab() : Bool {
        return Reflect.hasField(js.Browser.window,"ICMScript");
    }

	public static function setup(asCommandProxy : Bool, forwardICMCommands : Bool) {
		theClient = new ICMClient(asCommandProxy, forwardICMCommands);
	}
	
	public static function getClient() {
		return theClient;
	}
	
	public function new(asCommandProxy : Bool, forwardICMCommands : Bool) {
		callBackMap = new Map<String, Dynamic>();

        commandsWaiting = new Array<Dynamic>();

		this.forwardICMCommands = forwardICMCommands;
		
		if (forwardICMCommands == false && asCommandProxy == false) {
			return ;
		}
		
		nodeSocket = new NodeSocket(NodeSocketIO.connect('http://localhost'));

		var self = this;
		
		if (asCommandProxy) {
            nodeSocket.emit('registerAsICMNode',{});

			nodeSocket.on('icmForwardCommmand', function (data) {
                var command :String = data.COMMAND;

                /*var limit = 100;

                var commandBuf = new StringBuf();

                var i =0;
                while(i < command.length){
                    commandBuf.add(command.substr(i,limit) + "\\");
                    i += limit;
                }

                command = commandBuf.toString();*/

                try{

                    ICMScript.execute(command);
				    var c_out = ICMScript.getVarJSON('cout');


                    if(c_out == null){
                        nodeSocket.emit('icmForwardResponse',{'ID':data.ID});
                    }else{
                        var res : Dynamic = js.Lib.eval( "(" + c_out + ")" );

                        nodeSocket.emit('icmForwardResponse',res.cout);
                    }

                }catch(e : Dynamic){
                    nodeSocket.emit('icmForwardResponse',{'ID':data.ID});
                }

				/*Ext.Ajax.request({
					url: '/ICMForwardRequest',
					params: res.c_out,
					success: function(response) {
						
					}
				});*/
			});
		}else{
			nodeSocket.on('icmForward', function (data) {
				var g : Dynamic = js.Browser.window;
				g.myData = data;

                var passVal = null;

                if(Reflect.hasField(data,'RAW')){
                    var r = reg_jsonStart.replace(data.RAW, '');
                    r = reg_jsonStop.replace(r, '');

                   passVal = js.Lib.eval('('+r+')');
                }

                var callBack = self.callBackMap[data.ID];

                if(Reflect.hasField(data,'error')){
                    callBack(data);
                }else{
                    callBack(passVal);
                }


			
				self.callBackMap.remove(data.ID);
			});

            nodeSocket.on('recieveCommandID',function(data){
                var id = data.ID;
                var job = commandsWaiting.shift();

                job.params.COMMAND = StringTools.replace(job.params.COMMAND,'<COMMAND_ID>',id);
                job.params.ID = id;

                nodeSocket.emit(job.socketCommand,job.params);

                callBackMap[id] = job.callBack;
            });
		}
	}

    /*
    public function detectUncaughtNativeException() : Dynamic{
        ICMScript.execute('try\nc_out=sgc.molbio.catchUncaught()');
    }*/
	
	public function generateSetStringCommand(varName : String, value : String) {
		var varLen = value.length;
		var blockSize = 4000; // was 500
		if (varLen < blockSize) {
			return varName + " = '" + value + "'\n";
		}else {
			var done = blockSize;
			
			var setCode = varName + " = '" + value.substr(0, blockSize) + "'\n";
			
			while (done < varLen) {
				setCode = setCode + varName + " = " + varName + " + '" + value.substr(done, blockSize) + "'\n";
				
				done = done + blockSize;
			}
			
			return setCode;
		}
	}

    public function callFunction(functionName : String, arguments : Array<Dynamic>, onSuccess, onFailure){
        var icmCommand = functionName+'(';

        for(i in 0...arguments.length){
            var argument : Dynamic = arguments[i];
            if(Std.is(argument,Array)){
                var arrayType = 'StringArray';
                var valueStr = '{';
                if(argument.length > 0){
                    var value = argument[0];
                    if(Std.is(value, haxe.ds.StringMap)){
                        arrayType = 'ObjectList';
                        valueStr = 'Collection("ITEMS", Collection(';
                    }
                }

                for(j in 0...argument.length){
                    var value = argument[j];
                    if(arrayType == 'ObjectList'){
                        var map : Map<String,Dynamic> = value;
                        valueStr += '"'+(j+1)+'",Collection(';
                        var keys = new Array<String>();

                        for(key in map.keys()){
                            keys.push(key);
                        }

                        for(j in 0...keys.length){
                            var key = keys[j];
                            var value = value.get(key);
                            if(value == null){
                                value = '__MOLBIO_NULL_TYPE__';
                            }

                            valueStr += '\'' + key + '\',\'' + value + '\'';

                            if(j != keys.length-1){
                                valueStr += ',';
                            }
                        }

                        valueStr += ')';
                    }else{
                        valueStr += "'" + value + "'";
                    }
                    if(j != argument.length-1){
                        valueStr += ',';
                    }
                }

                if(arrayType == 'StringArray'){
                    icmCommand += valueStr + '}';
                }else{
                    icmCommand += valueStr + '),"POS",'+argument.length+')';
                }

            }else if(Std.is(argument,haxe.ds.StringMap)){
                var map : Map<String,Dynamic> = argument;
                var valueStr = 'Collection(';
                var keys = new Array<String>();

                for(key in map.keys()){
                    keys.push(key);
                }

                for(j in 0...keys.length){
                    var key = keys[j];
                    valueStr += '\'' + key + '\',\'' + argument.get(key) + '\'';

                    if(j != keys.length-1){
                        valueStr += ',';
                    }
                }
                valueStr += ')';
                icmCommand += valueStr;
            }else{
                icmCommand += '\'' + arguments[i] + '\'';
            }

            if(i< arguments.length-1){
                icmCommand += ',';
            }
        }

        icmCommand += '));\n';

        var callBack = function(data){
            if(data != null && Reflect.hasField(data,'__EXCEPTION')){
                onFailure(Reflect.field(data,'__EXCEPTION'));
            }else if(data != null && Reflect.hasField(data,'error')){
                onFailure({message: data.error});
            }else if(data == null){
                onFailure({message: 'An unexpected Scarab exception has occurred'});
            }else{
                onSuccess(data);
            }
        };

        // Below is an attempt to bypass runCommand for single line commands

        if (forwardICMCommands == false) {
            ICMScript.execute('delete cout\ntry\ncout=sgc.molbio.wrap(\'PSEUDO\',' + icmCommand);

            if (callBack != null) {
                try{
                    var c_out = ICMScript.getVarJSON('cout');

                    if(c_out == null){
                        callBack(null);
                    }else{
                        var r = reg_jsonStart.replace(c_out, '');
                        r = reg_jsonStop.replace(r, '');

                        var data : Dynamic = js.Lib.eval( "(" + r + ")" );

                        data = js.Lib.eval( "(" + data.cout.RAW + ")" );

                        callBack(data);
                    }
                }catch(e : Dynamic){
                    callBack(null);
                }
            }

            return;
        }

        icmCommand = 'delete cout\ntry\ncout=sgc.molbio.wrap(\'<COMMAND_ID>\',' + icmCommand;

        commandsWaiting.push({
            socketCommand:'icmForwardCommandRequest',
            params: {
                COMMAND : icmCommand,
                time: Date.now().getTime(),
            },
            callBack : callBack
        });

        nodeSocket.emit('sendCommandID',{});
    }

    static public function instanceOf(obj : Dynamic, className : String) : Bool{
        if(Reflect.hasField(obj,'__INTERNAL__CLASS_LIST')){
            var clazz = Reflect.field(obj,'__INTERNAL__CLASS_LIST');
            if(Reflect.hasField(clazz,className)){
                return true;
            }
        }

        return false;
    }

    public static function getError(data){
        if(data != null && Reflect.hasField(data,'__EXCEPTION')){
            return Reflect.field(data,'__EXCEPTION');
        }else if(data == null){
            return {message: 'An unexpected Scarab exception has occurred'};
        }else{
            return null;
        }
    }

	public function runCommand(icmCommand : String, callBack : Dynamic) {
        var ourCallBack = function(data){
            if(data != null && Reflect.hasField(data,'__EXCEPTION')){
                callBack(null,Reflect.field(data,'__EXCEPTION'));
            }else if(data == null){
                callBack(null,'An unexpected Scarab exception has occurred');
            }else{
                callBack(data,null);
            }
        };

		if (forwardICMCommands == false) {
			icmCommand = 'delete cout\ntry\nparams=Collection();\n' +
						  icmCommand + 
						  'cout = sgc.forwardData(params)\n';

            try{
                ICMScript.execute(icmCommand);

                if (callBack != null) {
                    var c_out = ICMScript.getVarJSON('cout');

                    if(c_out != null){
                        var r = reg_jsonStart.replace(c_out, '');
                        r = reg_jsonStop.replace(r, '');

                        var data : Dynamic = js.Lib.eval( "(" + r + ")" );

                        data = js.Lib.eval( "(" + data.cout.RAW + ")" );

                        ourCallBack(data);
                    }else{
                        ourCallBack(null);
                    }
                }
            }catch(e : Dynamic){
                callBack(null);
            }

			return;
		}

        icmCommand = 'delete cout\ntry\nsgc.NextCommandId = "<COMMAND_ID"' + "\n" +
                        'params=Collection();\n' +
                        icmCommand +
                        'cout = sgc.forwardData(params)\n';

        commandsWaiting.push({
            socketCommand:'icmForwardCommandRequest',
            params: {
                COMMAND : icmCommand,
                time: Date.now().getTime(),
            },
            callBack : ourCallBack
        });

        nodeSocket.emit('sendCommandID',{});
	}
	
	public function getVarJSON(varName : String) : Dynamic {
		var retVal = js.Lib.eval( "(" + ICMScript.getVarString(varName) + ")" ); 
		
		return retVal;
	}
	
	public function runTestCommand() {
		ICMScript.execute("params = Collection('ID','1');");
		ICMScript.execute("sys.curl.post('http://localhost:8080/ICMForwardRequest', params)");
	}
	
	public function forwardCommands( forwardCommands : Bool ) {
		this.forwardICMCommands = forwardCommands;
	}

    public function openUrl(url, useInternalViewer){
        if(useInternalViewer){
            runCommand('read html \"'+url+'\"\n',function(){});
        }else{
            runCommand('sys.openWithDefaultViewer("'+url+'")\n',function(){});
        }
    }

    public function saveToFile(fileName : String, content : String,cbSuccess, cbFailure){
        var arguments = [fileName, content];

        callFunction('sgc.molbio.exportToFile',arguments, cbSuccess, cbFailure);
    }

    public function saveToFileWithDialog(suggestion : String, content : String,cbSuccess : Dynamic, cbFailure : Dynamic){
        var arguments = [content, suggestion];

        callFunction('sgc.molbio.exportToFileDialog', arguments, cbSuccess, cbFailure);
    }
}
