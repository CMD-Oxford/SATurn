/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package bindings;

import saturn.util.StringUtils;

@:native('Ext')
extern class Ext {
    public static function application(config : Dynamic) : Dynamic;
    public static function create(name : String, config : Dynamic) : Dynamic;
    public static function getBody() : Dynamic;
    public static function define(name : String, config : Dynamic) : Dynamic;
	public static function bind(fuc : Dynamic, scope : Dynamic) : Dynamic;
    public static function id(?item : Dynamic, ?initialName : Dynamic) : Dynamic;
    public static function getCmp(id : Dynamic) : Dynamic;
    public static function get(id : Dynamic) : Dynamic;
    public static function getDom(id : Dynamic) : Dynamic;
    public static function decode( str: Dynamic) : Dynamic;
    public static function destroy(obj : Dynamic) : Void;
    public static function apply(obj : Dynamic, map : Dynamic) : Void;
    public static var ModelManager : Dynamic;
    public static var Msg : Dynamic;
    public static var Ajax : Dynamic;
	public static var data : Dynamic;
    public static var supports : Dynamic;
    public static var ClassManager: Dynamic;
    public static var Loader : Dynamic;
    public static var QuickTips : Dynamic;
    public static function require(className : String) : Dynamic;

    public static function suspendLayouts() : Void;

    public static function resumeLayouts(b : Bool) : Void;

	public static function onReady( callBack : Dynamic) : Void;
}

@:native('Ext.KeyMap')
extern class KeyMap {
	public function new(element : Dynamic, keyMap : Dynamic) : Void;
}


@:native('Ext.Element')
extern class Element {
    public function new(obj : Dynamic) : Void;
}

@:native('Phylo5SVGRenderer')
extern class Phylo5SVGRenderer {
	public function new(parentWidth : Dynamic, parentHeight : Dynamic, element : Dynamic) : Void;
	public function zoomIn() : Void;
	public function zoomOut() : Void;
}

@:native('Phylo5RadialTreeLayout')
extern class Phylo5RadialTreeLayout {
	public function new(parentWidth : Dynamic, parentHeight : Dynamic) : Void;
}

@:native('Phylo5NewickParser')
extern class Phylo5NewickParser {
	public function new() : Void;
	public function parse(newick : String) : Dynamic;
}

@:native('Buffer')
extern class Buffer {
	public function new(str : String) : Void;
	public var length : Int;
}

@:native('io')
extern class NodeSocketIO {
	public static function connect(url : String, params :Dynamic = Null) : NodeSocket;
}

@:native('Snap')
extern class Snap {
    public function new();
}

class NodeSocket {
	var theNativeSocket : Dynamic;
    public var id : String;
	
	public function new( nativeSocket : Dynamic) {
		theNativeSocket = nativeSocket;
	}
	
	public function on( command : String, func : Dynamic) {
		theNativeSocket.on(command, func);
	}
	
	public function emit( command : String, obj : Dynamic) {
		theNativeSocket.emit(command, obj);
	}

    public function getId() : String{
        return theNativeSocket.id;
    }

    public function disconnect(){
        theNativeSocket.disconnect();
    }
}

@:native('ICMScript')
extern class ICMScript {
	public static function execute( command : String ) : Void;
	public static function getVarJSON( icmVar : String ) :Dynamic;
	public static function getVarString( icmVar: String ) : Dynamic;
}

@:native('QWebChannel')
extern class QWebChannel {
    public function new(transport : Dynamic, cb:Dynamic->Void) : Void;
}

@:native('JSON')
extern class JSON {
	public static function stringify( obj : Dynamic) : String;
}

@:native('JSZip')
extern class JSZip {
    public var files : Array<String>;
	public function new(contents : Dynamic) : Void;
	public function file(regexp : Dynamic) : Dynamic;
}

@:native('JSONR')
extern class JSONR {
	public static function stringify(obj : Dynamic, replacer : Dynamic, indent : String) : Dynamic;
}

@:native('Chart')
extern class Chart{
    public function new(ctx : Dynamic): Void;
}