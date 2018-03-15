var $global = typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this;
var console = $global.console || {log:function(){}};
var $hxClasses = $hxClasses || {},$estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = $hxClasses["EReg"] = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
	this.rs = r;
	this.opt = opt;
};
EReg.__name__ = ["EReg"];
EReg.prototype = {
	r: null
	,rs: null
	,opt: null
	,regenerate: function() {
		this.r = new RegExp(this.rs,this.opt);
	}
	,hxUnserialize: function(u) {
		this.rs = u.unserialize();
		this.opt = u.unserialize();
	}
	,hxSerialize: function(s) {
		s.serialize(this.rs);
		s.serialize(this.opt);
		this.regenerate();
	}
	,match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,matched: function(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) return this.r.m[n]; else throw new js._Boot.HaxeError("EReg::matched");
	}
	,__class__: EReg
};
var HxOverrides = $hxClasses["HxOverrides"] = function() { };
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.strDate = function(s) {
	var _g = s.length;
	switch(_g) {
	case 8:
		var k = s.split(":");
		var d = new Date();
		d.setTime(0);
		d.setUTCHours(k[0]);
		d.setUTCMinutes(k[1]);
		d.setUTCSeconds(k[2]);
		return d;
	case 10:
		var k1 = s.split("-");
		return new Date(k1[0],k1[1] - 1,k1[2],0,0,0);
	case 19:
		var k2 = s.split(" ");
		var y = k2[0].split("-");
		var t = k2[1].split(":");
		return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
	default:
		throw new js._Boot.HaxeError("Invalid date format : " + s);
	}
};
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.remove = function(a,obj) {
	var i = HxOverrides.indexOf(a,obj,0);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Lambda = $hxClasses["Lambda"] = function() { };
Lambda.__name__ = ["Lambda"];
Lambda.exists = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) return true;
	}
	return false;
};
Lambda.filter = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) l.add(x);
	}
	return l;
};
var List = $hxClasses["List"] = function() {
	this.length = 0;
};
List.__name__ = ["List"];
List.prototype = {
	h: null
	,q: null
	,length: null
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,push: function(item) {
		var x = [item,this.h];
		this.h = x;
		if(this.q == null) this.q = x;
		this.length++;
	}
	,iterator: function() {
		return new _List.ListIterator(this.h);
	}
	,__class__: List
};
var _List = _List || {};
_List.ListIterator = $hxClasses["_List.ListIterator"] = function(head) {
	this.head = head;
	this.val = null;
};
_List.ListIterator.__name__ = ["_List","ListIterator"];
_List.ListIterator.prototype = {
	head: null
	,val: null
	,hasNext: function() {
		return this.head != null;
	}
	,next: function() {
		this.val = this.head[0];
		this.head = this.head[1];
		return this.val;
	}
	,__class__: _List.ListIterator
};
Math.__name__ = ["Math"];
var Reflect = $hxClasses["Reflect"] = function() { };
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	return Object.prototype.hasOwnProperty.call(o,field);
};
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		if (e instanceof js._Boot.HaxeError) e = e.val;
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.callMethod = function(o,func,args) {
	return func.apply(o,args);
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
};
Reflect.deleteField = function(o,field) {
	if(!Object.prototype.hasOwnProperty.call(o,field)) return false;
	delete(o[field]);
	return true;
};
var Std = $hxClasses["Std"] = function() { };
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
};
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
Std.parseFloat = function(x) {
	return parseFloat(x);
};
var StringBuf = $hxClasses["StringBuf"] = function() {
	this.b = "";
};
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	b: null
	,add: function(x) {
		this.b += Std.string(x);
	}
	,__class__: StringBuf
};
var StringTools = $hxClasses["StringTools"] = function() { };
StringTools.__name__ = ["StringTools"];
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
};
StringTools.fastCodeAt = function(s,index) {
	return s.charCodeAt(index);
};
var ValueType = $hxClasses["ValueType"] = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] };
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; };
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; };
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = $hxClasses["Type"] = function() { };
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null; else return js.Boot.getClass(o);
};
Type.getClassName = function(c) {
	var a = c.__name__;
	if(a == null) return null;
	return a.join(".");
};
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
};
Type.resolveClass = function(name) {
	var cl = $hxClasses[name];
	if(cl == null || !cl.__name__) return null;
	return cl;
};
Type.resolveEnum = function(name) {
	var e = $hxClasses[name];
	if(e == null || !e.__ename__) return null;
	return e;
};
Type.createInstance = function(cl,args) {
	var _g = args.length;
	switch(_g) {
	case 0:
		return new cl();
	case 1:
		return new cl(args[0]);
	case 2:
		return new cl(args[0],args[1]);
	case 3:
		return new cl(args[0],args[1],args[2]);
	case 4:
		return new cl(args[0],args[1],args[2],args[3]);
	case 5:
		return new cl(args[0],args[1],args[2],args[3],args[4]);
	case 6:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
	case 7:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
	case 8:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	default:
		throw new js._Boot.HaxeError("Too many arguments");
	}
	return null;
};
Type.createEmptyInstance = function(cl) {
	function empty() {}; empty.prototype = cl.prototype;
	return new empty();
};
Type.createEnum = function(e,constr,params) {
	var f = Reflect.field(e,constr);
	if(f == null) throw new js._Boot.HaxeError("No such constructor " + constr);
	if(Reflect.isFunction(f)) {
		if(params == null) throw new js._Boot.HaxeError("Constructor " + constr + " need parameters");
		return Reflect.callMethod(e,f,params);
	}
	if(params != null && params.length != 0) throw new js._Boot.HaxeError("Constructor " + constr + " does not need parameters");
	return f;
};
Type.getInstanceFields = function(c) {
	var a = [];
	for(var i in c.prototype) a.push(i);
	HxOverrides.remove(a,"__class__");
	HxOverrides.remove(a,"__properties__");
	return a;
};
Type.getEnumConstructs = function(e) {
	var a = e.__constructs__;
	return a.slice();
};
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = js.Boot.getClass(v);
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
};
var bindings = bindings || {};
bindings.NodeSocket = $hxClasses["bindings.NodeSocket"] = function(nativeSocket) {
	this.theNativeSocket = nativeSocket;
};
bindings.NodeSocket.__name__ = ["bindings","NodeSocket"];
bindings.NodeSocket.prototype = {
	theNativeSocket: null
	,on: function(command,func) {
		this.theNativeSocket.on(command,func);
	}
	,emit: function(command,obj) {
		this.theNativeSocket.emit(command,obj);
	}
	,disconnect: function() {
		this.theNativeSocket.disconnect();
	}
	,__class__: bindings.NodeSocket
};
var haxe = haxe || {};
haxe.IMap = $hxClasses["haxe.IMap"] = function() { };
haxe.IMap.__name__ = ["haxe","IMap"];
haxe.IMap.prototype = {
	get: null
	,set: null
	,exists: null
	,remove: null
	,keys: null
	,iterator: null
	,__class__: haxe.IMap
};
haxe.Http = $hxClasses["haxe.Http"] = function(url) {
	this.url = url;
	this.headers = new List();
	this.params = new List();
	this.async = true;
};
haxe.Http.__name__ = ["haxe","Http"];
haxe.Http.prototype = {
	url: null
	,responseData: null
	,async: null
	,postData: null
	,headers: null
	,params: null
	,setParameter: function(param,value) {
		this.params = Lambda.filter(this.params,function(p) {
			return p.param != param;
		});
		this.params.push({ param : param, value : value});
		return this;
	}
	,req: null
	,request: function(post) {
		var me = this;
		me.responseData = null;
		var r = this.req = js.Browser.createXMLHttpRequest();
		var onreadystatechange = function(_) {
			if(r.readyState != 4) return;
			var s;
			try {
				s = r.status;
			} catch( e ) {
				if (e instanceof js._Boot.HaxeError) e = e.val;
				s = null;
			}
			if(s != null) {
				var protocol = window.location.protocol.toLowerCase();
				var rlocalProtocol = new EReg("^(?:about|app|app-storage|.+-extension|file|res|widget):$","");
				var isLocal = rlocalProtocol.match(protocol);
				if(isLocal) if(r.responseText != null) s = 200; else s = 404;
			}
			if(s == undefined) s = null;
			if(s != null) me.onStatus(s);
			if(s != null && s >= 200 && s < 400) {
				me.req = null;
				me.onData(me.responseData = r.responseText);
			} else if(s == null) {
				me.req = null;
				me.onError("Failed to connect or resolve host");
			} else switch(s) {
			case 12029:
				me.req = null;
				me.onError("Failed to connect to host");
				break;
			case 12007:
				me.req = null;
				me.onError("Unknown host");
				break;
			default:
				me.req = null;
				me.responseData = r.responseText;
				me.onError("Http Error #" + r.status);
			}
		};
		if(this.async) r.onreadystatechange = onreadystatechange;
		var uri = this.postData;
		if(uri != null) post = true; else {
			var _g_head = this.params.h;
			var _g_val = null;
			while(_g_head != null) {
				var p;
				p = (function($this) {
					var $r;
					_g_val = _g_head[0];
					_g_head = _g_head[1];
					$r = _g_val;
					return $r;
				}(this));
				if(uri == null) uri = ""; else uri += "&";
				uri += encodeURIComponent(p.param) + "=" + encodeURIComponent(p.value);
			}
		}
		try {
			if(post) r.open("POST",this.url,this.async); else if(uri != null) {
				var question = this.url.split("?").length <= 1;
				r.open("GET",this.url + (question?"?":"&") + uri,this.async);
				uri = null;
			} else r.open("GET",this.url,this.async);
		} catch( e1 ) {
			if (e1 instanceof js._Boot.HaxeError) e1 = e1.val;
			me.req = null;
			this.onError(e1.toString());
			return;
		}
		if(!Lambda.exists(this.headers,function(h) {
			return h.header == "Content-Type";
		}) && post && this.postData == null) r.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
		var _g_head1 = this.headers.h;
		var _g_val1 = null;
		while(_g_head1 != null) {
			var h1;
			h1 = (function($this) {
				var $r;
				_g_val1 = _g_head1[0];
				_g_head1 = _g_head1[1];
				$r = _g_val1;
				return $r;
			}(this));
			r.setRequestHeader(h1.header,h1.value);
		}
		r.send(uri);
		if(!this.async) onreadystatechange(null);
	}
	,onData: function(data) {
	}
	,onError: function(msg) {
	}
	,onStatus: function(status) {
	}
	,__class__: haxe.Http
};
if(!haxe._Int64) haxe._Int64 = {};
haxe._Int64.___Int64 = $hxClasses["haxe._Int64.___Int64"] = function(high,low) {
	this.high = high;
	this.low = low;
};
haxe._Int64.___Int64.__name__ = ["haxe","_Int64","___Int64"];
haxe._Int64.___Int64.prototype = {
	high: null
	,low: null
	,__class__: haxe._Int64.___Int64
};
haxe.Serializer = $hxClasses["haxe.Serializer"] = function() {
	this.buf = new StringBuf();
	this.cache = [];
	this.useCache = haxe.Serializer.USE_CACHE;
	this.useEnumIndex = haxe.Serializer.USE_ENUM_INDEX;
	this.shash = new haxe.ds.StringMap();
	this.scount = 0;
};
haxe.Serializer.__name__ = ["haxe","Serializer"];
haxe.Serializer.run = function(v) {
	var s = new haxe.Serializer();
	s.serialize(v);
	return s.toString();
};
haxe.Serializer.prototype = {
	buf: null
	,cache: null
	,shash: null
	,scount: null
	,useCache: null
	,useEnumIndex: null
	,toString: function() {
		return this.buf.b;
	}
	,serializeString: function(s) {
		var x = this.shash.get(s);
		if(x != null) {
			this.buf.b += "R";
			if(x == null) this.buf.b += "null"; else this.buf.b += "" + x;
			return;
		}
		this.shash.set(s,this.scount++);
		this.buf.b += "y";
		s = encodeURIComponent(s);
		if(s.length == null) this.buf.b += "null"; else this.buf.b += "" + s.length;
		this.buf.b += ":";
		if(s == null) this.buf.b += "null"; else this.buf.b += "" + s;
	}
	,serializeRef: function(v) {
		var vt = typeof(v);
		var _g1 = 0;
		var _g = this.cache.length;
		while(_g1 < _g) {
			var i = _g1++;
			var ci = this.cache[i];
			if(typeof(ci) == vt && ci == v) {
				this.buf.b += "r";
				if(i == null) this.buf.b += "null"; else this.buf.b += "" + i;
				return true;
			}
		}
		this.cache.push(v);
		return false;
	}
	,serializeFields: function(v) {
		var _g = 0;
		var _g1 = Reflect.fields(v);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			this.serializeString(f);
			this.serialize(Reflect.field(v,f));
		}
		this.buf.b += "g";
	}
	,serialize: function(v) {
		{
			var _g = Type["typeof"](v);
			switch(_g[1]) {
			case 0:
				this.buf.b += "n";
				break;
			case 1:
				var v1 = v;
				if(v1 == 0) {
					this.buf.b += "z";
					return;
				}
				this.buf.b += "i";
				if(v1 == null) this.buf.b += "null"; else this.buf.b += "" + v1;
				break;
			case 2:
				var v2 = v;
				if(isNaN(v2)) this.buf.b += "k"; else if(!isFinite(v2)) if(v2 < 0) this.buf.b += "m"; else this.buf.b += "p"; else {
					this.buf.b += "d";
					if(v2 == null) this.buf.b += "null"; else this.buf.b += "" + v2;
				}
				break;
			case 3:
				if(v) this.buf.b += "t"; else this.buf.b += "f";
				break;
			case 6:
				var c = _g[2];
				if(c == String) {
					this.serializeString(v);
					return;
				}
				if(this.useCache && this.serializeRef(v)) return;
				switch(c) {
				case Array:
					var ucount = 0;
					this.buf.b += "a";
					var l = v.length;
					var _g1 = 0;
					while(_g1 < l) {
						var i = _g1++;
						if(v[i] == null) ucount++; else {
							if(ucount > 0) {
								if(ucount == 1) this.buf.b += "n"; else {
									this.buf.b += "u";
									if(ucount == null) this.buf.b += "null"; else this.buf.b += "" + ucount;
								}
								ucount = 0;
							}
							this.serialize(v[i]);
						}
					}
					if(ucount > 0) {
						if(ucount == 1) this.buf.b += "n"; else {
							this.buf.b += "u";
							if(ucount == null) this.buf.b += "null"; else this.buf.b += "" + ucount;
						}
					}
					this.buf.b += "h";
					break;
				case List:
					this.buf.b += "l";
					var v3 = v;
					var _g1_head = v3.h;
					var _g1_val = null;
					while(_g1_head != null) {
						var i1;
						_g1_val = _g1_head[0];
						_g1_head = _g1_head[1];
						i1 = _g1_val;
						this.serialize(i1);
					}
					this.buf.b += "h";
					break;
				case Date:
					var d = v;
					this.buf.b += "v";
					this.buf.add(d.getTime());
					break;
				case haxe.ds.StringMap:
					this.buf.b += "b";
					var v4 = v;
					var $it0 = v4.keys();
					while( $it0.hasNext() ) {
						var k = $it0.next();
						this.serializeString(k);
						this.serialize(__map_reserved[k] != null?v4.getReserved(k):v4.h[k]);
					}
					this.buf.b += "h";
					break;
				case haxe.ds.IntMap:
					this.buf.b += "q";
					var v5 = v;
					var $it1 = v5.keys();
					while( $it1.hasNext() ) {
						var k1 = $it1.next();
						this.buf.b += ":";
						if(k1 == null) this.buf.b += "null"; else this.buf.b += "" + k1;
						this.serialize(v5.h[k1]);
					}
					this.buf.b += "h";
					break;
				case haxe.ds.ObjectMap:
					this.buf.b += "M";
					var v6 = v;
					var $it2 = v6.keys();
					while( $it2.hasNext() ) {
						var k2 = $it2.next();
						var id = Reflect.field(k2,"__id__");
						Reflect.deleteField(k2,"__id__");
						this.serialize(k2);
						k2.__id__ = id;
						this.serialize(v6.h[k2.__id__]);
					}
					this.buf.b += "h";
					break;
				case haxe.io.Bytes:
					var v7 = v;
					var i2 = 0;
					var max = v7.length - 2;
					var charsBuf = new StringBuf();
					var b64 = haxe.Serializer.BASE64;
					while(i2 < max) {
						var b1 = v7.get(i2++);
						var b2 = v7.get(i2++);
						var b3 = v7.get(i2++);
						charsBuf.add(b64.charAt(b1 >> 2));
						charsBuf.add(b64.charAt((b1 << 4 | b2 >> 4) & 63));
						charsBuf.add(b64.charAt((b2 << 2 | b3 >> 6) & 63));
						charsBuf.add(b64.charAt(b3 & 63));
					}
					if(i2 == max) {
						var b11 = v7.get(i2++);
						var b21 = v7.get(i2++);
						charsBuf.add(b64.charAt(b11 >> 2));
						charsBuf.add(b64.charAt((b11 << 4 | b21 >> 4) & 63));
						charsBuf.add(b64.charAt(b21 << 2 & 63));
					} else if(i2 == max + 1) {
						var b12 = v7.get(i2++);
						charsBuf.add(b64.charAt(b12 >> 2));
						charsBuf.add(b64.charAt(b12 << 4 & 63));
					}
					var chars = charsBuf.b;
					this.buf.b += "s";
					if(chars.length == null) this.buf.b += "null"; else this.buf.b += "" + chars.length;
					this.buf.b += ":";
					if(chars == null) this.buf.b += "null"; else this.buf.b += "" + chars;
					break;
				default:
					if(this.useCache) this.cache.pop();
					if(v.hxSerialize != null) {
						this.buf.b += "C";
						this.serializeString(Type.getClassName(c));
						if(this.useCache) this.cache.push(v);
						v.hxSerialize(this);
						this.buf.b += "g";
					} else {
						this.buf.b += "c";
						this.serializeString(Type.getClassName(c));
						if(this.useCache) this.cache.push(v);
						this.serializeFields(v);
					}
				}
				break;
			case 4:
				if(js.Boot.__instanceof(v,Class)) {
					var className = Type.getClassName(v);
					this.buf.b += "A";
					this.serializeString(className);
				} else if(js.Boot.__instanceof(v,Enum)) {
					this.buf.b += "B";
					this.serializeString(Type.getEnumName(v));
				} else {
					if(this.useCache && this.serializeRef(v)) return;
					this.buf.b += "o";
					this.serializeFields(v);
				}
				break;
			case 7:
				var e = _g[2];
				if(this.useCache) {
					if(this.serializeRef(v)) return;
					this.cache.pop();
				}
				if(this.useEnumIndex) this.buf.b += "j"; else this.buf.b += "w";
				this.serializeString(Type.getEnumName(e));
				if(this.useEnumIndex) {
					this.buf.b += ":";
					this.buf.b += Std.string(v[1]);
				} else this.serializeString(v[0]);
				this.buf.b += ":";
				var l1 = v.length;
				this.buf.b += Std.string(l1 - 2);
				var _g11 = 2;
				while(_g11 < l1) {
					var i3 = _g11++;
					this.serialize(v[i3]);
				}
				if(this.useCache) this.cache.push(v);
				break;
			case 5:
				throw new js._Boot.HaxeError("Cannot serialize function");
				break;
			default:
				throw new js._Boot.HaxeError("Cannot serialize " + Std.string(v));
			}
		}
	}
	,__class__: haxe.Serializer
};
haxe.Unserializer = $hxClasses["haxe.Unserializer"] = function(buf) {
	this.buf = buf;
	this.length = buf.length;
	this.pos = 0;
	this.scache = [];
	this.cache = [];
	var r = haxe.Unserializer.DEFAULT_RESOLVER;
	if(r == null) {
		r = Type;
		haxe.Unserializer.DEFAULT_RESOLVER = r;
	}
	this.setResolver(r);
};
haxe.Unserializer.__name__ = ["haxe","Unserializer"];
haxe.Unserializer.initCodes = function() {
	var codes = [];
	var _g1 = 0;
	var _g = haxe.Unserializer.BASE64.length;
	while(_g1 < _g) {
		var i = _g1++;
		codes[haxe.Unserializer.BASE64.charCodeAt(i)] = i;
	}
	return codes;
};
haxe.Unserializer.run = function(v) {
	return new haxe.Unserializer(v).unserialize();
};
haxe.Unserializer.prototype = {
	buf: null
	,pos: null
	,length: null
	,cache: null
	,scache: null
	,resolver: null
	,setResolver: function(r) {
		if(r == null) this.resolver = { resolveClass : function(_) {
			return null;
		}, resolveEnum : function(_1) {
			return null;
		}}; else this.resolver = r;
	}
	,get: function(p) {
		return this.buf.charCodeAt(p);
	}
	,readDigits: function() {
		var k = 0;
		var s = false;
		var fpos = this.pos;
		while(true) {
			var c = this.buf.charCodeAt(this.pos);
			if(c != c) break;
			if(c == 45) {
				if(this.pos != fpos) break;
				s = true;
				this.pos++;
				continue;
			}
			if(c < 48 || c > 57) break;
			k = k * 10 + (c - 48);
			this.pos++;
		}
		if(s) k *= -1;
		return k;
	}
	,readFloat: function() {
		var p1 = this.pos;
		while(true) {
			var c = this.buf.charCodeAt(this.pos);
			if(c >= 43 && c < 58 || c == 101 || c == 69) this.pos++; else break;
		}
		return Std.parseFloat(HxOverrides.substr(this.buf,p1,this.pos - p1));
	}
	,unserializeObject: function(o) {
		while(true) {
			if(this.pos >= this.length) throw new js._Boot.HaxeError("Invalid object");
			if(this.buf.charCodeAt(this.pos) == 103) break;
			var k = this.unserialize();
			if(!(typeof(k) == "string")) throw new js._Boot.HaxeError("Invalid object key");
			var v = this.unserialize();
			o[k] = v;
		}
		this.pos++;
	}
	,unserializeEnum: function(edecl,tag) {
		if(this.get(this.pos++) != 58) throw new js._Boot.HaxeError("Invalid enum format");
		var nargs = this.readDigits();
		if(nargs == 0) return Type.createEnum(edecl,tag);
		var args = [];
		while(nargs-- > 0) args.push(this.unserialize());
		return Type.createEnum(edecl,tag,args);
	}
	,unserialize: function() {
		var _g = this.get(this.pos++);
		switch(_g) {
		case 110:
			return null;
		case 116:
			return true;
		case 102:
			return false;
		case 122:
			return 0;
		case 105:
			return this.readDigits();
		case 100:
			return this.readFloat();
		case 121:
			var len = this.readDigits();
			if(this.get(this.pos++) != 58 || this.length - this.pos < len) throw new js._Boot.HaxeError("Invalid string length");
			var s = HxOverrides.substr(this.buf,this.pos,len);
			this.pos += len;
			s = decodeURIComponent(s.split("+").join(" "));
			this.scache.push(s);
			return s;
		case 107:
			return NaN;
		case 109:
			return -Infinity;
		case 112:
			return Infinity;
		case 97:
			var buf = this.buf;
			var a = [];
			this.cache.push(a);
			while(true) {
				var c = this.buf.charCodeAt(this.pos);
				if(c == 104) {
					this.pos++;
					break;
				}
				if(c == 117) {
					this.pos++;
					var n = this.readDigits();
					a[a.length + n - 1] = null;
				} else a.push(this.unserialize());
			}
			return a;
		case 111:
			var o = { };
			this.cache.push(o);
			this.unserializeObject(o);
			return o;
		case 114:
			var n1 = this.readDigits();
			if(n1 < 0 || n1 >= this.cache.length) throw new js._Boot.HaxeError("Invalid reference");
			return this.cache[n1];
		case 82:
			var n2 = this.readDigits();
			if(n2 < 0 || n2 >= this.scache.length) throw new js._Boot.HaxeError("Invalid string reference");
			return this.scache[n2];
		case 120:
			throw new js._Boot.HaxeError(this.unserialize());
			break;
		case 99:
			var name = this.unserialize();
			var cl = this.resolver.resolveClass(name);
			if(cl == null) throw new js._Boot.HaxeError("Class not found " + name);
			var o1 = Type.createEmptyInstance(cl);
			this.cache.push(o1);
			this.unserializeObject(o1);
			return o1;
		case 119:
			var name1 = this.unserialize();
			var edecl = this.resolver.resolveEnum(name1);
			if(edecl == null) throw new js._Boot.HaxeError("Enum not found " + name1);
			var e = this.unserializeEnum(edecl,this.unserialize());
			this.cache.push(e);
			return e;
		case 106:
			var name2 = this.unserialize();
			var edecl1 = this.resolver.resolveEnum(name2);
			if(edecl1 == null) throw new js._Boot.HaxeError("Enum not found " + name2);
			this.pos++;
			var index = this.readDigits();
			var tag = Type.getEnumConstructs(edecl1)[index];
			if(tag == null) throw new js._Boot.HaxeError("Unknown enum index " + name2 + "@" + index);
			var e1 = this.unserializeEnum(edecl1,tag);
			this.cache.push(e1);
			return e1;
		case 108:
			var l = new List();
			this.cache.push(l);
			var buf1 = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) l.add(this.unserialize());
			this.pos++;
			return l;
		case 98:
			var h = new haxe.ds.StringMap();
			this.cache.push(h);
			var buf2 = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) {
				var s1 = this.unserialize();
				h.set(s1,this.unserialize());
			}
			this.pos++;
			return h;
		case 113:
			var h1 = new haxe.ds.IntMap();
			this.cache.push(h1);
			var buf3 = this.buf;
			var c1 = this.get(this.pos++);
			while(c1 == 58) {
				var i = this.readDigits();
				h1.set(i,this.unserialize());
				c1 = this.get(this.pos++);
			}
			if(c1 != 104) throw new js._Boot.HaxeError("Invalid IntMap format");
			return h1;
		case 77:
			var h2 = new haxe.ds.ObjectMap();
			this.cache.push(h2);
			var buf4 = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) {
				var s2 = this.unserialize();
				h2.set(s2,this.unserialize());
			}
			this.pos++;
			return h2;
		case 118:
			var d;
			if(this.buf.charCodeAt(this.pos) >= 48 && this.buf.charCodeAt(this.pos) <= 57 && this.buf.charCodeAt(this.pos + 1) >= 48 && this.buf.charCodeAt(this.pos + 1) <= 57 && this.buf.charCodeAt(this.pos + 2) >= 48 && this.buf.charCodeAt(this.pos + 2) <= 57 && this.buf.charCodeAt(this.pos + 3) >= 48 && this.buf.charCodeAt(this.pos + 3) <= 57 && this.buf.charCodeAt(this.pos + 4) == 45) {
				var s3 = HxOverrides.substr(this.buf,this.pos,19);
				d = HxOverrides.strDate(s3);
				this.pos += 19;
			} else {
				var t = this.readFloat();
				var d1 = new Date();
				d1.setTime(t);
				d = d1;
			}
			this.cache.push(d);
			return d;
		case 115:
			var len1 = this.readDigits();
			var buf5 = this.buf;
			if(this.get(this.pos++) != 58 || this.length - this.pos < len1) throw new js._Boot.HaxeError("Invalid bytes length");
			var codes = haxe.Unserializer.CODES;
			if(codes == null) {
				codes = haxe.Unserializer.initCodes();
				haxe.Unserializer.CODES = codes;
			}
			var i1 = this.pos;
			var rest = len1 & 3;
			var size;
			size = (len1 >> 2) * 3 + (rest >= 2?rest - 1:0);
			var max = i1 + (len1 - rest);
			var bytes = haxe.io.Bytes.alloc(size);
			var bpos = 0;
			while(i1 < max) {
				var c11 = codes[StringTools.fastCodeAt(buf5,i1++)];
				var c2 = codes[StringTools.fastCodeAt(buf5,i1++)];
				bytes.set(bpos++,c11 << 2 | c2 >> 4);
				var c3 = codes[StringTools.fastCodeAt(buf5,i1++)];
				bytes.set(bpos++,c2 << 4 | c3 >> 2);
				var c4 = codes[StringTools.fastCodeAt(buf5,i1++)];
				bytes.set(bpos++,c3 << 6 | c4);
			}
			if(rest >= 2) {
				var c12 = codes[StringTools.fastCodeAt(buf5,i1++)];
				var c21 = codes[StringTools.fastCodeAt(buf5,i1++)];
				bytes.set(bpos++,c12 << 2 | c21 >> 4);
				if(rest == 3) {
					var c31 = codes[StringTools.fastCodeAt(buf5,i1++)];
					bytes.set(bpos++,c21 << 4 | c31 >> 2);
				}
			}
			this.pos += len1;
			this.cache.push(bytes);
			return bytes;
		case 67:
			var name3 = this.unserialize();
			var cl1 = this.resolver.resolveClass(name3);
			if(cl1 == null) throw new js._Boot.HaxeError("Class not found " + name3);
			var o2 = Type.createEmptyInstance(cl1);
			this.cache.push(o2);
			o2.hxUnserialize(this);
			if(this.get(this.pos++) != 103) throw new js._Boot.HaxeError("Invalid custom data");
			return o2;
		case 65:
			var name4 = this.unserialize();
			var cl2 = this.resolver.resolveClass(name4);
			if(cl2 == null) throw new js._Boot.HaxeError("Class not found " + name4);
			return cl2;
		case 66:
			var name5 = this.unserialize();
			var e2 = this.resolver.resolveEnum(name5);
			if(e2 == null) throw new js._Boot.HaxeError("Enum not found " + name5);
			return e2;
		default:
		}
		this.pos--;
		throw new js._Boot.HaxeError("Invalid char " + this.buf.charAt(this.pos) + " at position " + this.pos);
	}
	,__class__: haxe.Unserializer
};
if(!haxe.ds) haxe.ds = {};
haxe.ds.IntMap = $hxClasses["haxe.ds.IntMap"] = function() {
	this.h = { };
};
haxe.ds.IntMap.__name__ = ["haxe","ds","IntMap"];
haxe.ds.IntMap.__interfaces__ = [haxe.IMap];
haxe.ds.IntMap.prototype = {
	h: null
	,set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty(key);
	}
	,remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref[i];
		}};
	}
	,__class__: haxe.ds.IntMap
};
haxe.ds.ObjectMap = $hxClasses["haxe.ds.ObjectMap"] = function() {
	this.h = { };
	this.h.__keys__ = { };
};
haxe.ds.ObjectMap.__name__ = ["haxe","ds","ObjectMap"];
haxe.ds.ObjectMap.__interfaces__ = [haxe.IMap];
haxe.ds.ObjectMap.prototype = {
	h: null
	,set: function(key,value) {
		var id = key.__id__ || (key.__id__ = ++haxe.ds.ObjectMap.count);
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,get: function(key) {
		return this.h[key.__id__];
	}
	,exists: function(key) {
		return this.h.__keys__[key.__id__] != null;
	}
	,remove: function(key) {
		var id = key.__id__;
		if(this.h.__keys__[id] == null) return false;
		delete(this.h[id]);
		delete(this.h.__keys__[id]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h.__keys__ ) {
		if(this.h.hasOwnProperty(key)) a.push(this.h.__keys__[key]);
		}
		return HxOverrides.iter(a);
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref[i.__id__];
		}};
	}
	,__class__: haxe.ds.ObjectMap
};
if(!haxe.ds._StringMap) haxe.ds._StringMap = {};
haxe.ds._StringMap.StringMapIterator = $hxClasses["haxe.ds._StringMap.StringMapIterator"] = function(map,keys) {
	this.map = map;
	this.keys = keys;
	this.index = 0;
	this.count = keys.length;
};
haxe.ds._StringMap.StringMapIterator.__name__ = ["haxe","ds","_StringMap","StringMapIterator"];
haxe.ds._StringMap.StringMapIterator.prototype = {
	map: null
	,keys: null
	,index: null
	,count: null
	,hasNext: function() {
		return this.index < this.count;
	}
	,next: function() {
		return this.map.get(this.keys[this.index++]);
	}
	,__class__: haxe.ds._StringMap.StringMapIterator
};
haxe.ds.StringMap = $hxClasses["haxe.ds.StringMap"] = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = ["haxe","ds","StringMap"];
haxe.ds.StringMap.__interfaces__ = [haxe.IMap];
haxe.ds.StringMap.prototype = {
	h: null
	,rh: null
	,set: function(key,value) {
		if(__map_reserved[key] != null) this.setReserved(key,value); else this.h[key] = value;
	}
	,get: function(key) {
		if(__map_reserved[key] != null) return this.getReserved(key);
		return this.h[key];
	}
	,exists: function(key) {
		if(__map_reserved[key] != null) return this.existsReserved(key);
		return this.h.hasOwnProperty(key);
	}
	,setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		if(this.rh == null) return null; else return this.rh["$" + key];
	}
	,existsReserved: function(key) {
		if(this.rh == null) return false;
		return this.rh.hasOwnProperty("$" + key);
	}
	,remove: function(key) {
		if(__map_reserved[key] != null) {
			key = "$" + key;
			if(this.rh == null || !this.rh.hasOwnProperty(key)) return false;
			delete(this.rh[key]);
			return true;
		} else {
			if(!this.h.hasOwnProperty(key)) return false;
			delete(this.h[key]);
			return true;
		}
	}
	,keys: function() {
		var _this = this.arrayKeys();
		return HxOverrides.iter(_this);
	}
	,arrayKeys: function() {
		var out = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) out.push(key);
		}
		if(this.rh != null) {
			for( var key in this.rh ) {
			if(key.charCodeAt(0) == 36) out.push(key.substr(1));
			}
		}
		return out;
	}
	,iterator: function() {
		return new haxe.ds._StringMap.StringMapIterator(this,this.arrayKeys());
	}
	,__class__: haxe.ds.StringMap
};
if(!haxe.io) haxe.io = {};
haxe.io.Bytes = $hxClasses["haxe.io.Bytes"] = function(data) {
	this.length = data.byteLength;
	this.b = new Uint8Array(data);
	this.b.bufferValue = data;
	data.hxBytes = this;
	data.bytes = this.b;
};
haxe.io.Bytes.__name__ = ["haxe","io","Bytes"];
haxe.io.Bytes.alloc = function(length) {
	return new haxe.io.Bytes(new ArrayBuffer(length));
};
haxe.io.Bytes.prototype = {
	length: null
	,b: null
	,get: function(pos) {
		return this.b[pos];
	}
	,set: function(pos,v) {
		this.b[pos] = v & 255;
	}
	,__class__: haxe.io.Bytes
};
haxe.io.Error = $hxClasses["haxe.io.Error"] = { __ename__ : ["haxe","io","Error"], __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] };
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; };
haxe.io.FPHelper = $hxClasses["haxe.io.FPHelper"] = function() { };
haxe.io.FPHelper.__name__ = ["haxe","io","FPHelper"];
haxe.io.FPHelper.i32ToFloat = function(i) {
	var sign = 1 - (i >>> 31 << 1);
	var exp = i >>> 23 & 255;
	var sig = i & 8388607;
	if(sig == 0 && exp == 0) return 0.0;
	return sign * (1 + Math.pow(2,-23) * sig) * Math.pow(2,exp - 127);
};
haxe.io.FPHelper.floatToI32 = function(f) {
	if(f == 0) return 0;
	var af;
	if(f < 0) af = -f; else af = f;
	var exp = Math.floor(Math.log(af) / 0.6931471805599453);
	if(exp < -127) exp = -127; else if(exp > 128) exp = 128;
	var sig = Math.round((af / Math.pow(2,exp) - 1) * 8388608) & 8388607;
	return (f < 0?-2147483648:0) | exp + 127 << 23 | sig;
};
haxe.io.FPHelper.i64ToDouble = function(low,high) {
	var sign = 1 - (high >>> 31 << 1);
	var exp = (high >> 20 & 2047) - 1023;
	var sig = (high & 1048575) * 4294967296. + (low >>> 31) * 2147483648. + (low & 2147483647);
	if(sig == 0 && exp == -1023) return 0.0;
	return sign * (1.0 + Math.pow(2,-52) * sig) * Math.pow(2,exp);
};
haxe.io.FPHelper.doubleToI64 = function(v) {
	var i64 = haxe.io.FPHelper.i64tmp;
	if(v == 0) {
		i64.low = 0;
		i64.high = 0;
	} else {
		var av;
		if(v < 0) av = -v; else av = v;
		var exp = Math.floor(Math.log(av) / 0.6931471805599453);
		var sig;
		var v1 = (av / Math.pow(2,exp) - 1) * 4503599627370496.;
		sig = Math.round(v1);
		var sig_l = sig | 0;
		var sig_h = sig / 4294967296.0 | 0;
		i64.low = sig_l;
		i64.high = (v < 0?-2147483648:0) | exp + 1023 << 20 | sig_h;
	}
	return i64;
};
var js = js || {};
if(!js._Boot) js._Boot = {};
js._Boot.HaxeError = $hxClasses["js._Boot.HaxeError"] = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js._Boot.HaxeError);
};
js._Boot.HaxeError.__name__ = ["js","_Boot","HaxeError"];
js._Boot.HaxeError.__super__ = Error;
js._Boot.HaxeError.prototype = $extend(Error.prototype,{
	val: null
	,__class__: js._Boot.HaxeError
});
js.Boot = $hxClasses["js.Boot"] = function() { };
js.Boot.__name__ = ["js","Boot"];
js.Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js.Boot.__nativeClassName(o);
		if(name != null) return js.Boot.__resolveNativeClass(name);
		return null;
	}
};
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js.Boot.__string_rec(o[i1],s); else str2 += js.Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js.Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js._Boot.HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js.Boot.__interfLoop(js.Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js.Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw new js._Boot.HaxeError("Cannot cast " + Std.string(o) + " to " + Std.string(t));
};
js.Boot.__nativeClassName = function(o) {
	var name = js.Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js.Boot.__isNativeObj = function(o) {
	return js.Boot.__nativeClassName(o) != null;
};
js.Boot.__resolveNativeClass = function(name) {
	return $global[name];
};
js.Browser = $hxClasses["js.Browser"] = function() { };
js.Browser.__name__ = ["js","Browser"];
js.Browser.createXMLHttpRequest = function() {
	if(typeof XMLHttpRequest != "undefined") return new XMLHttpRequest();
	if(typeof ActiveXObject != "undefined") return new ActiveXObject("Microsoft.XMLHTTP");
	throw new js._Boot.HaxeError("Unable to create XMLHttpRequest object.");
};
js.Lib = $hxClasses["js.Lib"] = function() { };
js.Lib.__name__ = ["js","Lib"];
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
};
if(!js.html) js.html = {};
if(!js.html.compat) js.html.compat = {};
js.html.compat.ArrayBuffer = $hxClasses["js.html.compat.ArrayBuffer"] = function(a) {
	if((a instanceof Array) && a.__enum__ == null) {
		this.a = a;
		this.byteLength = a.length;
	} else {
		var len = a;
		this.a = [];
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			this.a[i] = 0;
		}
		this.byteLength = len;
	}
};
js.html.compat.ArrayBuffer.__name__ = ["js","html","compat","ArrayBuffer"];
js.html.compat.ArrayBuffer.sliceImpl = function(begin,end) {
	var u = new Uint8Array(this,begin,end == null?null:end - begin);
	var result = new ArrayBuffer(u.byteLength);
	var resultArray = new Uint8Array(result);
	resultArray.set(u);
	return result;
};
js.html.compat.ArrayBuffer.prototype = {
	byteLength: null
	,a: null
	,slice: function(begin,end) {
		return new js.html.compat.ArrayBuffer(this.a.slice(begin,end));
	}
	,__class__: js.html.compat.ArrayBuffer
};
js.html.compat.DataView = $hxClasses["js.html.compat.DataView"] = function(buffer,byteOffset,byteLength) {
	this.buf = buffer;
	if(byteOffset == null) this.offset = 0; else this.offset = byteOffset;
	if(byteLength == null) this.length = buffer.byteLength - this.offset; else this.length = byteLength;
	if(this.offset < 0 || this.length < 0 || this.offset + this.length > buffer.byteLength) throw new js._Boot.HaxeError(haxe.io.Error.OutsideBounds);
};
js.html.compat.DataView.__name__ = ["js","html","compat","DataView"];
js.html.compat.DataView.prototype = {
	buf: null
	,offset: null
	,length: null
	,getInt8: function(byteOffset) {
		var v = this.buf.a[this.offset + byteOffset];
		if(v >= 128) return v - 256; else return v;
	}
	,getUint8: function(byteOffset) {
		return this.buf.a[this.offset + byteOffset];
	}
	,getInt16: function(byteOffset,littleEndian) {
		var v = this.getUint16(byteOffset,littleEndian);
		if(v >= 32768) return v - 65536; else return v;
	}
	,getUint16: function(byteOffset,littleEndian) {
		if(littleEndian) return this.buf.a[this.offset + byteOffset] | this.buf.a[this.offset + byteOffset + 1] << 8; else return this.buf.a[this.offset + byteOffset] << 8 | this.buf.a[this.offset + byteOffset + 1];
	}
	,getInt32: function(byteOffset,littleEndian) {
		var p = this.offset + byteOffset;
		var a = this.buf.a[p++];
		var b = this.buf.a[p++];
		var c = this.buf.a[p++];
		var d = this.buf.a[p++];
		if(littleEndian) return a | b << 8 | c << 16 | d << 24; else return d | c << 8 | b << 16 | a << 24;
	}
	,getUint32: function(byteOffset,littleEndian) {
		var v = this.getInt32(byteOffset,littleEndian);
		if(v < 0) return v + 4294967296.; else return v;
	}
	,getFloat32: function(byteOffset,littleEndian) {
		return haxe.io.FPHelper.i32ToFloat(this.getInt32(byteOffset,littleEndian));
	}
	,getFloat64: function(byteOffset,littleEndian) {
		var a = this.getInt32(byteOffset,littleEndian);
		var b = this.getInt32(byteOffset + 4,littleEndian);
		return haxe.io.FPHelper.i64ToDouble(littleEndian?a:b,littleEndian?b:a);
	}
	,setInt8: function(byteOffset,value) {
		if(value < 0) this.buf.a[byteOffset + this.offset] = value + 128 & 255; else this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setUint8: function(byteOffset,value) {
		this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setInt16: function(byteOffset,value,littleEndian) {
		this.setUint16(byteOffset,value < 0?value + 65536:value,littleEndian);
	}
	,setUint16: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
		} else {
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p] = value & 255;
		}
	}
	,setInt32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,value,littleEndian);
	}
	,setUint32: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p++] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >>> 24;
		} else {
			this.buf.a[p++] = value >>> 24;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value & 255;
		}
	}
	,setFloat32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,haxe.io.FPHelper.floatToI32(value),littleEndian);
	}
	,setFloat64: function(byteOffset,value,littleEndian) {
		var i64 = haxe.io.FPHelper.doubleToI64(value);
		if(littleEndian) {
			this.setUint32(byteOffset,i64.low);
			this.setUint32(byteOffset,i64.high);
		} else {
			this.setUint32(byteOffset,i64.high);
			this.setUint32(byteOffset,i64.low);
		}
	}
	,__class__: js.html.compat.DataView
};
js.html.compat.Uint8Array = $hxClasses["js.html.compat.Uint8Array"] = function() { };
js.html.compat.Uint8Array.__name__ = ["js","html","compat","Uint8Array"];
js.html.compat.Uint8Array._new = function(arg1,offset,length) {
	var arr;
	if(typeof(arg1) == "number") {
		arr = [];
		var _g = 0;
		while(_g < arg1) {
			var i = _g++;
			arr[i] = 0;
		}
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js.html.compat.ArrayBuffer(arr);
	} else if(js.Boot.__instanceof(arg1,js.html.compat.ArrayBuffer)) {
		var buffer = arg1;
		if(offset == null) offset = 0;
		if(length == null) length = buffer.byteLength - offset;
		if(offset == 0) arr = buffer.a; else arr = buffer.a.slice(offset,offset + length);
		arr.byteLength = arr.length;
		arr.byteOffset = offset;
		arr.buffer = buffer;
	} else if((arg1 instanceof Array) && arg1.__enum__ == null) {
		arr = arg1.slice();
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js.html.compat.ArrayBuffer(arr);
	} else throw new js._Boot.HaxeError("TODO " + Std.string(arg1));
	arr.subarray = js.html.compat.Uint8Array._subarray;
	arr.set = js.html.compat.Uint8Array._set;
	return arr;
};
js.html.compat.Uint8Array._set = function(arg,offset) {
	var t = this;
	if(js.Boot.__instanceof(arg.buffer,js.html.compat.ArrayBuffer)) {
		var a = arg;
		if(arg.byteLength + offset > t.byteLength) throw new js._Boot.HaxeError("set() outside of range");
		var _g1 = 0;
		var _g = arg.byteLength;
		while(_g1 < _g) {
			var i = _g1++;
			t[i + offset] = a[i];
		}
	} else if((arg instanceof Array) && arg.__enum__ == null) {
		var a1 = arg;
		if(a1.length + offset > t.byteLength) throw new js._Boot.HaxeError("set() outside of range");
		var _g11 = 0;
		var _g2 = a1.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t[i1 + offset] = a1[i1];
		}
	} else throw new js._Boot.HaxeError("TODO");
};
js.html.compat.Uint8Array._subarray = function(start,end) {
	var t = this;
	var a = js.html.compat.Uint8Array._new(t.slice(start,end));
	a.byteOffset = start;
	return a;
};
var saturn = saturn || {};
if(!saturn.client) saturn.client = {};
saturn.client.WorkspaceApplication = $hxClasses["saturn.client.WorkspaceApplication"] = function() { };
saturn.client.WorkspaceApplication.__name__ = ["saturn","client","WorkspaceApplication"];
saturn.client.WorkspaceApplication.getApplication = function() {
	return saturn.client.WorkspaceApplication.theApplication;
};
saturn.client.WorkspaceApplication.prototype = {
	theProgramRegistry: null
	,makeAliasesAvailable: function() {
		var dwin = window;
		dwin.models = { };
		var pack = saturn.core.domain;
		var _g = 0;
		var _g1 = Reflect.fields(pack);
		while(_g < _g1.length) {
			var field = _g1[_g];
			++_g;
			var qualifiedName = "saturn.core.domain." + field;
			var clazz = Type.resolveClass(qualifiedName);
			if(clazz != null) {
				dwin[field] = clazz;
				var model = this.getProvider().getModel(clazz);
				if(model != null) {
					dwin.models[field] = { };
					saturn.core.Util.debug("Alias " + qualifiedName + " created");
					var _g2 = 0;
					var _g3 = model.getAttributes();
					while(_g2 < _g3.length) {
						var modelField = _g3[_g2];
						++_g2;
						Reflect.setField(Reflect.field(dwin.models,field),modelField,new saturn.db.query_lang.Field(clazz,modelField));
					}
				}
			}
		}
		var pack1 = saturn.db.query_lang;
		var _g4 = 0;
		var _g11 = Reflect.fields(pack1);
		while(_g4 < _g11.length) {
			var field1 = _g11[_g4];
			++_g4;
			if(field1 == "Function") continue;
			var qualifiedName1 = "saturn.db.query_lang." + field1;
			var clazz1 = Type.resolveClass(qualifiedName1);
			if(clazz1 != null) {
				saturn.core.Util.debug("Alias " + field1 + " created");
				dwin[field1] = clazz1;
			} else saturn.core.Util.debug("Skipping " + qualifiedName1);
		}
	}
	,getProvider: function() {
		return saturn.client.core.CommonCore.getDefaultProvider();
	}
	,getProgramRegistry: function() {
		return this.theProgramRegistry;
	}
	,showMessage: function(title,obj) {
		var message = "Missing message<br/>Contact Developers";
		if(obj != null) {
			if(typeof(obj) == "string") {
				if(StringTools.startsWith(obj,"\"")) message = JSON.parse(obj); else message = obj;
			} else if(Object.prototype.hasOwnProperty.call(obj,"message")) message = obj.message;
		}
		Ext.Msg.alert(title,message);
	}
	,__class__: saturn.client.WorkspaceApplication
};
saturn.client.BuildingBlock = $hxClasses["saturn.client.BuildingBlock"] = function() { };
saturn.client.BuildingBlock.__name__ = ["saturn","client","BuildingBlock"];
saturn.client.Program = $hxClasses["saturn.client.Program"] = function() { };
saturn.client.Program.__name__ = ["saturn","client","Program"];
saturn.client.Program.__interfaces__ = [saturn.client.BuildingBlock];
saturn.client.BioinformaticsServicesClient = $hxClasses["saturn.client.BioinformaticsServicesClient"] = function(socket,helper) {
	var _g = this;
	this.helper = helper;
	this.cbsAwaitingIds = [];
	this.cbsAwaitingResponse = new haxe.ds.StringMap();
	saturn.client.core.ClientCore.getClientCore().getNodeSocket().on("__response__",function(data) {
		var cb = _g.getCb(data);
		if(cb != null) {
			if(data == null) cb(null,"Invalid, empty response from server"); else cb(data.json,data.error);
		}
	});
	this.initialise();
};
saturn.client.BioinformaticsServicesClient.__name__ = ["saturn","client","BioinformaticsServicesClient"];
saturn.client.BioinformaticsServicesClient.getClient = function(socket,helper) {
	if(saturn.client.BioinformaticsServicesClient.theClient == null) saturn.client.BioinformaticsServicesClient.theClient = new saturn.client.BioinformaticsServicesClient(socket,helper);
	return saturn.client.BioinformaticsServicesClient.theClient;
};
saturn.client.BioinformaticsServicesClient.prototype = {
	cbsAwaitingIds: null
	,cbsAwaitingResponse: null
	,blastList: null
	,helper: null
	,getCb: function(data) {
		var jobId = data.bioinfJobId;
		if(this.cbsAwaitingResponse.exists(jobId)) {
			var cb = this.cbsAwaitingResponse.get(jobId);
			this.cbsAwaitingResponse.remove(jobId);
			return cb;
		} else return null;
	}
	,sendBlastDatabaseListRequest: function(cb) {
		this.helper.sendRequest("_blast_.database_list",{ },cb);
	}
	,initialise: function() {
		var _g = this;
		this.sendBlastDatabaseListRequest(function(data,err) {
			if(err != null) saturn.client.WorkspaceApplication.getApplication().showMessage("Request failure","Failed to get list of BLAST DBs"); else _g.blastList = data.json.dbList;
		});
	}
	,__class__: saturn.client.BioinformaticsServicesClient
};
saturn.client.ConversationHelper = $hxClasses["saturn.client.ConversationHelper"] = function() { };
saturn.client.ConversationHelper.__name__ = ["saturn","client","ConversationHelper"];
saturn.client.ConversationHelper.prototype = {
	sendRequest: null
	,__class__: saturn.client.ConversationHelper
};
saturn.client.ProgramRegistry = $hxClasses["saturn.client.ProgramRegistry"] = function() { };
saturn.client.ProgramRegistry.__name__ = ["saturn","client","ProgramRegistry"];
saturn.client.ProgramRegistry.prototype = {
	clazzNameToPrograms: null
	,clazzNameToDefaultProgram: null
	,fileExtensionToDefaultProgram: null
	,openWith: function(progClazz,defaults,typeClazz) {
		var clazzName = Type.getClassName(progClazz);
		if(!(this.clazzNameToPrograms.h.__keys__[typeClazz.__id__] != null)) this.clazzNameToPrograms.set(typeClazz,new List());
		this.clazzNameToPrograms.h[typeClazz.__id__].add(progClazz);
		if(defaults) {
			this.clazzNameToDefaultProgram.set(typeClazz,progClazz);
			if(Object.prototype.hasOwnProperty.call(typeClazz,"FILE_IMPORT_FORMATS")) {
				var fileFormats = Reflect.field(typeClazz,"FILE_IMPORT_FORMATS");
				var _g = 0;
				while(_g < fileFormats.length) {
					var fileFormat = fileFormats[_g];
					++_g;
					this.fileExtensionToDefaultProgram.set(fileFormat,progClazz);
				}
			}
		}
	}
	,__class__: saturn.client.ProgramRegistry
};
if(!saturn.util) saturn.util = {};
saturn.util.HaxeException = $hxClasses["saturn.util.HaxeException"] = function(message) {
	this.errorMessage = message;
};
saturn.util.HaxeException.__name__ = ["saturn","util","HaxeException"];
saturn.util.HaxeException.prototype = {
	errorMessage: null
	,toString: function() {
		return this.errorMessage;
	}
	,__class__: saturn.util.HaxeException
};
if(!saturn.client.core) saturn.client.core = {};
saturn.client.core.ClientCore = $hxClasses["saturn.client.core.ClientCore"] = function() {
	this.disabledLogout = false;
	this.keepProgress = true;
	this.loggedIn = false;
	this.nextMsgId = 0;
	this.updateListeners = [];
	this.refreshListeners = [];
	this.listeners = new haxe.ds.StringMap();
	this.loginListeners = [];
	this.logoutListeners = [];
	this.debugLogger = debug("saturn:plugin");
};
saturn.client.core.ClientCore.__name__ = ["saturn","client","core","ClientCore"];
saturn.client.core.ClientCore.__interfaces__ = [saturn.client.ConversationHelper];
saturn.client.core.ClientCore.startClientCore = function() {
	saturn.client.core.ClientCore.clientCore = new saturn.client.core.ClientCore();
	return saturn.client.core.ClientCore.clientCore;
};
saturn.client.core.ClientCore.getClientCore = function() {
	return saturn.client.core.ClientCore.clientCore;
};
saturn.client.core.ClientCore.main = function() {
	saturn.client.core.ClientCore.startClientCore();
};
saturn.client.core.ClientCore.prototype = {
	theSocket: null
	,cbsAwaitingIds: null
	,msgIdToJobInfo: null
	,msgIds: null
	,cbsAwaitingResponse: null
	,listeners: null
	,nextMsgId: null
	,loggedIn: null
	,theUser: null
	,keepProgress: null
	,updateListeners: null
	,refreshListeners: null
	,showMessage: null
	,disabledLogout: null
	,loginListeners: null
	,logoutListeners: null
	,debugLogger: null
	,providerUpListener: null
	,addUpdateListener: function(listener) {
		this.updateListeners.push(listener);
	}
	,addRefreshListener: function(listener) {
		this.refreshListeners.push(listener);
	}
	,addLoginListener: function(listener) {
		this.loginListeners.push(listener);
	}
	,addLogoutListener: function(listener) {
		this.logoutListeners.push(listener);
	}
	,setShowMessage: function(func) {
		this.showMessage = func;
	}
	,installNodeSocket: function() {
		if(this.theSocket != null) {
			this.theSocket.disconnect();
			this.theSocket = null;
		}
		var wsProtocol = "ws";
		if(window.location.protocol == "https:") wsProtocol = "wss";
		this.theSocket = new bindings.NodeSocket(io.connect(wsProtocol + "://" + window.location.hostname + ":" + window.location.port,{ forceNew : true, tryTransportsOnConnectTimeout : false, rememberTransport : false, transports : ["websocket"]}));
		this.initialiseSocket(this.theSocket);
	}
	,login: function(username,password,cb) {
		var _g = this;
		var req = new haxe.Http("/login");
		req.setParameter("username",username);
		req.setParameter("password",password);
		req.onData = function(data) {
			var obj = JSON.parse(data);
			if(obj.error) {
				_g.showMessage("Login failed","Unable to authenticate");
				return;
			}
			var cookies = Cookies;
			cookies.set("user",{ 'fullname' : obj.full_name, 'token' : obj.token, 'username' : username.toUpperCase(), 'projects' : obj.projects},{ 'expires' : 14});
			var user = new saturn.core.User();
			user.fullname = obj.full_name;
			user.token = obj.token;
			user.username = username.toUpperCase();
			user.projects = obj.projects;
			_g.refreshSession(cb);
		};
		req.onError = function(err) {
			cb(err);
		};
		req.request(true);
	}
	,refreshSession: function(cb) {
		var _g = this;
		var cookies = Cookies;
		var cookie = cookies.getJSON("user");
		if(cookie != null) {
			saturn.core.Util.debug("Installing authenticated node socket");
			var user = new saturn.core.User();
			user.fullname = cookie.fullname;
			user.token = cookie.token;
			user.username = cookie.username;
			user.projects = cookie.projects;
			this.authenticateSocket(user,function(err,user1) {
				if(err == null) {
					_g.installProviders();
					var _g1 = 0;
					var _g2 = _g.loginListeners;
					while(_g1 < _g2.length) {
						var listener = _g2[_g1];
						++_g1;
						listener(user1);
					}
				}
				if(cb != null) cb(err);
			});
		} else {
			saturn.core.Util.debug("Installing unauthenticated node socket");
			this.installNodeSocket();
			this.installProviders();
			var _g3 = 0;
			var _g11 = this.refreshListeners;
			while(_g3 < _g11.length) {
				var listener1 = _g11[_g3];
				++_g3;
				listener1();
			}
			if(cb != null) cb(null);
		}
	}
	,installProviders: function() {
		saturn.client.core.CommonCore.setDefaultProvider(new saturn.db.NodeProvider(),null,true);
		saturn.client.BioinformaticsServicesClient.getClient(null,this);
		var dwin = window;
		dwin.DB = saturn.client.core.CommonCore.getDefaultProvider();
	}
	,authenticateSocket: function(user,cb) {
		var _g = this;
		saturn.core.Util.debug("Authenticating: " + user.token + "/" + user.fullname);
		if(this.theSocket != null) {
			this.theSocket.disconnect();
			this.theSocket = null;
		}
		var wsProtocol = "ws";
		if(window.location.protocol == "https:") wsProtocol = "wss";
		var sock = io.connect(wsProtocol + "://" + window.location.hostname + ":" + window.location.port,{ forceNew : true, tryTransportsOnConnectTimeout : false, rememberTransport : false, transports : ["websocket"]});
		sock.on("error",function(error) {
			if(error.type == "UnauthorizedError" || error.code == "invalid_token") Ext.Msg.info("Login failed","Unable to authenticate"); else if(error.type == "TransportError") _g.showMessage("Server unavailable","Unable to contact server<br/>Not all functionaility will be available.<br/>Attempting reconnection in the background"); else {
				_g.theSocket = null;
				_g.showMessage("Unexpected server error","An unexpected server error has occurred\nPlease contact your saturn administrator");
			}
		});
		sock.on("connect",function(socket) {
			sock.reconnecting = true;
			sock.emit("authenticate",{ token : user.token});
		});
		sock.on("authenticated",function() {
			saturn.core.Util.debug("Authenticated");
			_g.setLoggedIn(user);
			cb(null,user);
		});
		sock.on("unauthorized",function() {
			_g.logout(true);
			cb("rejected",null);
		});
		this.theSocket = new bindings.NodeSocket(sock);
		this.initialiseSocket(this.theSocket);
	}
	,initialiseSocket: function(socket) {
		var _g = this;
		this.cbsAwaitingIds = [];
		this.cbsAwaitingResponse = new haxe.ds.StringMap();
		this.msgIdToJobInfo = new haxe.ds.StringMap();
		this.msgIds = [];
		this.theSocket.on("receiveMsgId",function(data) {
			var cb = _g.cbsAwaitingIds.shift();
			if(Object.prototype.hasOwnProperty.call(data,"msgId")) cb(data.msgId,null); else cb(null,"Node has failed to return a valid message ID response");
		});
		this.theSocket.on("receiveError",function(data1) {
			var cb1 = _g.getCb(data1);
			if(cb1 != null) {
				var err = data1.error;
				if(err != null) {
					if(typeof(err) == "string") {
						if(StringTools.startsWith(err,"\"")) err = JSON.parse(err);
					}
				}
				cb1(data1,err);
			}
		});
		this.theSocket.on("__response__",function(data2) {
			var cb2 = _g.getCb(data2);
			if(cb2 != null) {
				if(data2 == null) cb2(null,"Invalid, empty response from server"); else {
					var err1 = data2.error;
					if(err1 != null) {
						if(typeof(err1) == "string") {
							if(StringTools.startsWith(err1,"\"")) err1 = JSON.parse(err1);
						}
					}
					cb2(data2,data2.error);
				}
			} else window.console.log("Untracked message recieved ");
		});
	}
	,setLoggedIn: function(user) {
		this.setUser(user);
		this.loggedIn = true;
		var _g = 0;
		var _g1 = this.loginListeners;
		while(_g < _g1.length) {
			var listener = _g1[_g];
			++_g;
			listener(user);
		}
	}
	,disableLogout: function() {
		this.disabledLogout = true;
	}
	,isLogoutDisabled: function() {
		return this.disabledLogout;
	}
	,setUser: function(user) {
		this.theUser = user;
	}
	,getUser: function() {
		return this.theUser;
	}
	,isLoggedIn: function() {
		return this.loggedIn;
	}
	,logout: function(skipLogoutEmit) {
		if(skipLogoutEmit == null) skipLogoutEmit = false;
		if(this.isLogoutDisabled()) return;
		var cookies = Cookies;
		cookies.remove("user");
		if(!skipLogoutEmit) this.getNodeSocket().emit("logout",{ });
		this.setLoggedOut();
		var _g = 0;
		var _g1 = this.logoutListeners;
		while(_g < _g1.length) {
			var listener = _g1[_g];
			++_g;
			listener();
		}
		this.refreshSession(function(err) {
		});
	}
	,setLoggedOut: function() {
		this.loggedIn = false;
	}
	,getNodeSocket: function() {
		return this.theSocket;
	}
	,registerResponse: function(msg) {
		var _g = this;
		this.theSocket.on(msg,function(data) {
			saturn.core.Util.debug("Message!!!!!");
			var cb = _g.getCb(data);
			if(cb != null) {
				if(data == null) cb(null,"Invalid, empty response from server"); else cb(data,data.error);
			} else window.console.log("Untracked message recieved " + msg);
		});
	}
	,registerListener: function(msg,cb) {
		var _g = this;
		if(!this.listeners.exists(msg)) {
			this.theSocket.on(msg,function(data) {
				if(_g.listenersRegistered(msg)) _g.notifyListeners(msg,data);
			});
			var value = [];
			this.listeners.set(msg,value);
		}
		this.listeners.get(msg).push(cb);
	}
	,removeListener: function(msg,cb) {
		if(this.listeners.exists(msg)) {
			var _this = this.listeners.get(msg);
			var x = cb;
			HxOverrides.remove(_this,x);
		}
	}
	,listenersRegistered: function(msg) {
		return this.listeners.exists(msg);
	}
	,notifyListeners: function(msg,data) {
		if(this.listeners.exists(msg)) {
			var _g = 0;
			var _g1 = this.listeners.get(msg);
			while(_g < _g1.length) {
				var cb = _g1[_g];
				++_g;
				cb(data);
			}
		}
	}
	,sendRequest: function(msg,json,cb) {
		var msgId = Std.string(this.nextMsgId++);
		json.msgId = msgId;
		this.cbsAwaitingResponse.set(msgId,cb);
		var value = { 'MSG' : msg, 'JSON' : json, 'START_TIME' : Date.now()};
		this.msgIdToJobInfo.set(msgId,value);
		this.msgIds.unshift(msgId);
		this.theSocket.emit(msg,json);
		var _g = 0;
		var _g1 = this.updateListeners;
		while(_g < _g1.length) {
			var listener = _g1[_g];
			++_g;
			listener();
		}
		return msgId;
	}
	,getCb: function(data) {
		var msgId = data.msgId;
		if(this.cbsAwaitingResponse.exists(msgId)) {
			var cb = this.cbsAwaitingResponse.get(msgId);
			this.cbsAwaitingResponse.remove(msgId);
			if(!this.keepProgress) {
				this.msgIdToJobInfo.remove(msgId);
				HxOverrides.remove(this.msgIds,msgId);
			} else Reflect.setField(this.msgIdToJobInfo.get(msgId),"END_TIME",Date.now());
			var _g = 0;
			var _g1 = this.updateListeners;
			while(_g < _g1.length) {
				var listener = _g1[_g];
				++_g;
				listener();
			}
			return cb;
		} else return null;
	}
	,requestNodeMsgId: function(cb) {
		this.cbsAwaitingIds.push(cb);
		this.theSocket.emit("sendMsgId",{ });
	}
	,debug: function(message) {
		this.debugLogger(message);
	}
	,onProviderUp: function(cb) {
		this.providerUpListener = cb;
	}
	,providerUp: function() {
		if(this.providerUpListener != null) {
			var a = this.providerUpListener;
			this.providerUpListener = null;
			a();
		}
	}
	,__class__: saturn.client.core.ClientCore
};
if(!saturn.core) saturn.core = {};
if(!saturn.core.annotations) saturn.core.annotations = {};
saturn.core.annotations.AnnotationManager = $hxClasses["saturn.core.annotations.AnnotationManager"] = function() {
	this.annotationSuppliers = new haxe.ds.StringMap();
};
saturn.core.annotations.AnnotationManager.__name__ = ["saturn","core","annotations","AnnotationManager"];
saturn.core.annotations.AnnotationManager.prototype = {
	annotationSuppliers: null
	,annotateMolecule: function(molecule,annotationName,config,cb) {
		if(this.annotationSuppliers.exists(annotationName)) this.annotationSuppliers.get(annotationName).annotateMolecule(molecule,annotationName,config,cb);
	}
	,__class__: saturn.core.annotations.AnnotationManager
};
saturn.client.core.CommonCore = $hxClasses["saturn.client.core.CommonCore"] = function() { };
saturn.client.core.CommonCore.__name__ = ["saturn","client","core","CommonCore"];
saturn.client.core.CommonCore.setDefaultProvider = function(provider,name,defaultProvider) {
	if(name == null) name = "DEFAULT";
	saturn.client.core.CommonCore.providers.set(name,provider);
	if(defaultProvider) saturn.client.core.CommonCore.DEFAULT_POOL_NAME = name;
};
saturn.client.core.CommonCore.getAnnotationManager = function() {
	return saturn.client.core.CommonCore.annotationManager;
};
saturn.client.core.CommonCore.closeProviders = function() {
	var $it0 = saturn.client.core.CommonCore.providers.keys();
	while( $it0.hasNext() ) {
		var name = $it0.next();
		saturn.client.core.CommonCore.providers.get(name)._closeConnection();
	}
};
saturn.client.core.CommonCore.getStringError = function(error) {
	var dwin = window;
	dwin.error = error;
	return error;
};
saturn.client.core.CommonCore.getCombinedModels = function() {
	if(saturn.client.core.CommonCore.combinedModels == null) {
		saturn.client.core.CommonCore.combinedModels = new haxe.ds.StringMap();
		var _g = 0;
		var _g1 = saturn.client.core.CommonCore.getProviderNames();
		while(_g < _g1.length) {
			var name = _g1[_g];
			++_g;
			var models = saturn.client.core.CommonCore.getDefaultProvider(null,name).getModels();
			var $it0 = models.keys();
			while( $it0.hasNext() ) {
				var key = $it0.next();
				var value;
				value = __map_reserved[key] != null?models.getReserved(key):models.h[key];
				saturn.client.core.CommonCore.combinedModels.set(key,value);
			}
		}
	}
	return saturn.client.core.CommonCore.combinedModels;
};
saturn.client.core.CommonCore.getProviderNameForModel = function(name) {
	var models = saturn.client.core.CommonCore.getCombinedModels();
	if(__map_reserved[name] != null?models.existsReserved(name):models.h.hasOwnProperty(name)) {
		if((__map_reserved[name] != null?models.getReserved(name):models.h[name]).exists("provider_name")) return (__map_reserved[name] != null?models.getReserved(name):models.h[name]).get("provider_name"); else return null;
	} else return null;
};
saturn.client.core.CommonCore.getProviderForNamedQuery = function(name) {
	var $it0 = saturn.client.core.CommonCore.providers.keys();
	while( $it0.hasNext() ) {
		var providerName = $it0.next();
		var provider = saturn.client.core.CommonCore.providers.get(providerName);
		var config = provider.getConfig();
		if(Object.prototype.hasOwnProperty.call(config,"named_queries")) {
			if(Reflect.hasField(Reflect.field(config,"named_queries"),name)) return providerName;
		}
	}
	return null;
};
saturn.client.core.CommonCore.getDefaultProvider = function(cb,name) {
	if(name == null) name = saturn.client.core.CommonCore.getDefaultProviderName();
	if(saturn.client.core.CommonCore.providers.exists(name)) {
		if(cb != null) cb(null,saturn.client.core.CommonCore.providers.get(name));
		return saturn.client.core.CommonCore.providers.get(name);
	} else if(name != null) {
		saturn.client.core.CommonCore.getResource(name,cb);
		return -1;
	}
	return null;
};
saturn.client.core.CommonCore.getProviderNames = function() {
	var names = [];
	var $it0 = saturn.client.core.CommonCore.providers.keys();
	while( $it0.hasNext() ) {
		var name = $it0.next();
		names.push(name);
	}
	var $it1 = saturn.client.core.CommonCore.pools.keys();
	while( $it1.hasNext() ) {
		var name1 = $it1.next();
		names.push(name1);
	}
	return names;
};
saturn.client.core.CommonCore.getFileExtension = function(fileName) {
	var r = new EReg("\\.(\\w+)","");
	r.match(fileName);
	return r.matched(1);
};
saturn.client.core.CommonCore.getBinaryFileAsArrayBuffer = function(file) {
	var fileReader = new FileReader();
	return fileReader.readAsArrayBuffer(file);
};
saturn.client.core.CommonCore.convertArrayBufferToBase64 = function(buffer) {
	var binary = "";
	var bytes = new Uint8Array(buffer);
	var len = bytes.byteLength;
	var _g = 0;
	while(_g < len) {
		var i = _g++;
		binary += String.fromCharCode(bytes[i]);
	}
	return window.btoa(binary);
};
saturn.client.core.CommonCore.getFileAsText = function(file,cb) {
	if(js.Boot.__instanceof(file,saturn.core.FileShim)) cb(file.getAsText()); else if(Object.prototype.hasOwnProperty.call(file,"_data")) cb(file.asText()); else {
		var fileReader = new FileReader();
		fileReader.onload = function(e) {
			cb(e.target.result);
		};
		fileReader.readAsText(file);
	}
};
saturn.client.core.CommonCore.getFileInChunks = function(file,chunkSize,cb) {
	var offset = 0;
	var fileSize = file.size;
	var chunker = null;
	chunker = function() {
		var reader = new FileReader();
		reader.readAsDataURL(file.slice(offset,offset + chunkSize));
		reader.onloadend = function(event) {
			if(event.target.error == null) cb(null,reader.result.split(",")[1],function() {
				offset += chunkSize;
				if(offset >= fileSize) cb(null,null,null); else chunker();
			}); else cb(event.target.error,null,null);
		};
	};
	chunker();
};
saturn.client.core.CommonCore.getFileAsArrayBuffer = function(file,cb) {
	if(js.Boot.__instanceof(file,saturn.core.FileShim)) cb(file.getAsArrayBuffer()); else if(Object.prototype.hasOwnProperty.call(file,"_data")) cb(file.asUint8Array()); else {
		var fileReader = new FileReader();
		fileReader.onload = function(e) {
			cb(e.target.result);
		};
		fileReader.readAsArrayBuffer(file);
	}
};
saturn.client.core.CommonCore.setPool = function(poolName,pool,isDefault) {
	if(poolName == null) poolName = "DEFAULT";
	saturn.client.core.CommonCore.pools.set(poolName,pool);
	if(isDefault) saturn.client.core.CommonCore.DEFAULT_POOL_NAME = poolName;
};
saturn.client.core.CommonCore.getPool = function(poolName) {
	if(poolName == null) poolName = "DEFAULT";
	if(saturn.client.core.CommonCore.pools.exists(poolName)) return saturn.client.core.CommonCore.pools.get(poolName); else return null;
};
saturn.client.core.CommonCore.getResource = function(poolName,cb) {
	if(poolName == null) poolName = "DEFAULT";
	var pool = saturn.client.core.CommonCore.getPool(poolName);
	if(pool != null) pool.acquire(function(err,resource) {
		if(err == null) saturn.client.core.CommonCore.resourceToPool.set(resource,poolName);
		cb(err,resource);
	}); else cb("Invalid pool name",null);
};
saturn.client.core.CommonCore.releaseResource = function(resource) {
	if(saturn.client.core.CommonCore.resourceToPool.exists(resource)) {
		var poolName = saturn.client.core.CommonCore.resourceToPool.get(resource);
		if(saturn.client.core.CommonCore.pools.exists(poolName)) {
			var pool = saturn.client.core.CommonCore.pools.get(poolName);
			pool.release(resource);
			return -3;
		} else return -2;
	} else return -1;
};
saturn.client.core.CommonCore.makeFullyQualified = function(path) {
	var location = window.location;
	return location.protocol + "//" + location.hostname + ":" + location.port + "/" + path;
};
saturn.client.core.CommonCore.getContent = function(url,onSuccess,onFailure) {
	if(onFailure == null) onFailure = function(err) {
		saturn.client.WorkspaceApplication.getApplication().showMessage("Error retrieving resource",url);
	};
	Ext.Ajax.request({ url : url, success : function(response,opts) {
		onSuccess(response.responseText);
	}, failure : function(response1,opts1) {
		onFailure(response1);
	}});
};
saturn.client.core.CommonCore.getDefaultProviderName = function() {
	return saturn.client.core.CommonCore.DEFAULT_POOL_NAME;
};
if(!saturn.core.molecule) saturn.core.molecule = {};
saturn.core.molecule.Molecule = $hxClasses["saturn.core.molecule.Molecule"] = function() { };
saturn.core.molecule.Molecule.__name__ = ["saturn","core","molecule","Molecule"];
saturn.core.FileShim = $hxClasses["saturn.core.FileShim"] = function() { };
saturn.core.FileShim.__name__ = ["saturn","core","FileShim"];
saturn.core.User = $hxClasses["saturn.core.User"] = function() {
};
saturn.core.User.__name__ = ["saturn","core","User"];
saturn.core.User.prototype = {
	username: null
	,fullname: null
	,token: null
	,projects: null
	,__class__: saturn.core.User
};
saturn.core.Util = $hxClasses["saturn.core.Util"] = function() {
};
saturn.core.Util.__name__ = ["saturn","core","Util"];
saturn.core.Util.debug = function(msg) {
	saturn.client.core.ClientCore.getClientCore().debug(msg);
};
saturn.core.Util.inspect = function(obj) {
};
saturn.core.Util.print = function(msg) {
};
saturn.core.Util.openw = function(path) {
	return null;
};
saturn.core.Util.opentemp = function(prefix,cb) {
};
saturn.core.Util.isHostEnvironmentAvailable = function() {
	return false;
};
saturn.core.Util.exec = function(program,args,cb) {
	saturn.core.Util.getNewExternalProcess(function(process) {
		process.start(program,args);
		process.waitForClose(function(state) {
			if(state == "") cb(0); else cb(-1);
		});
	});
};
saturn.core.Util.getNewExternalProcess = function(cb) {
};
saturn.core.Util.getNewFileDialog = function(cb) {
};
saturn.core.Util.saveFileAsDialog = function(contents,cb) {
	saturn.core.Util.getNewFileDialog(function(err,dialog) {
		dialog.setSelectExisting(false);
		dialog.fileSelected.connect(function(fileName) {
			js.Lib.alert(fileName);
			saturn.core.Util.debug("Hello, saving " + fileName);
			saturn.core.Util.saveFile(fileName,contents,function(err1) {
				cb(err1,fileName);
			});
		});
		dialog.open();
	});
};
saturn.core.Util.saveFile = function(fileName,contents,cb) {
	saturn.core.Util.getNewExternalProcess(function(process) {
		process.writeFile(fileName,contents,function(err) {
			cb(err);
		});
	});
};
saturn.core.Util.jsImports = function(paths,cb) {
	var errs = new haxe.ds.StringMap();
	var next = null;
	next = function() {
		if(paths.length == 0) cb(errs); else {
			var path = paths.pop();
			saturn.core.Util.jsImport(path,function(err) {
				if(__map_reserved[path] != null) errs.setReserved(path,err); else errs.h[path] = err;
				next();
			});
		}
	};
	next();
};
saturn.core.Util.jsImport = function(path,cb) {
	saturn.core.Util.readFile(path,function(err,content) {
		if(err == null) {
			if(content != null) {
				saturn.core.Util.print(content);
				saturn.core.Util.print("Content");
				eval(content);
			} else err = "Empty import";
		}
		cb(err);
	});
};
saturn.core.Util.openFileAsDialog = function(cb) {
	saturn.core.Util.getNewFileDialog(function(err,dialog) {
		dialog.setSelectExisting(true);
		dialog.fileSelected.connect(function(fileName) {
			saturn.core.Util.readFile(fileName,function(err1,contents) {
				cb(err1,fileName,contents);
			});
		});
		dialog.open();
	});
};
saturn.core.Util.readFile = function(fileName,cb) {
	saturn.core.Util.getNewExternalProcess(function(process) {
		process.readFile(fileName,function(contents) {
			if(contents != null) cb(null,contents); else cb("Unable to read file",null);
		});
	});
};
saturn.core.Util.open = function(path,cb) {
	saturn.core.Util.getNewExternalProcess(function(process) {
		process.readFile(function(contents) {
			if(contents == null) cb("Unable to read file",null); else cb(null,contents);
		});
	});
};
saturn.core.Util.getProvider = function() {
	return saturn.client.core.CommonCore.getDefaultProvider();
};
saturn.core.Util.string = function(a) {
	return Std.string(a);
};
saturn.core.Util.clone = function(obj) {
	var ser = haxe.Serializer.run(obj);
	return haxe.Unserializer.run(ser);
};
saturn.core.Util.prototype = {
	__class__: saturn.core.Util
};
saturn.core.Stream = $hxClasses["saturn.core.Stream"] = function(streamId) {
	this.streamId = streamId;
};
saturn.core.Stream.__name__ = ["saturn","core","Stream"];
saturn.core.Stream.prototype = {
	streamId: null
	,write: function(content) {
	}
	,end: function(cb) {
	}
	,__class__: saturn.core.Stream
};
saturn.core.annotations.AnnotationSupplier = $hxClasses["saturn.core.annotations.AnnotationSupplier"] = function() { };
saturn.core.annotations.AnnotationSupplier.__name__ = ["saturn","core","annotations","AnnotationSupplier"];
saturn.core.annotations.AnnotationSupplier.prototype = {
	annotateMolecule: function(molecule,annotationName,config,cb) {
		cb(null,null);
	}
	,__class__: saturn.core.annotations.AnnotationSupplier
};
if(!saturn.core.domain) saturn.core.domain = {};
saturn.core.domain.FileProxy = $hxClasses["saturn.core.domain.FileProxy"] = function() { };
saturn.core.domain.FileProxy.__name__ = ["saturn","core","domain","FileProxy"];
saturn.core.domain.MoleculeAnnotation = $hxClasses["saturn.core.domain.MoleculeAnnotation"] = function() { };
saturn.core.domain.MoleculeAnnotation.__name__ = ["saturn","core","domain","MoleculeAnnotation"];
if(!saturn.db) saturn.db = {};
saturn.db.BatchFetch = $hxClasses["saturn.db.BatchFetch"] = function(onError) {
	this.items = new haxe.ds.StringMap();
	this.fetchList = [];
	this.retrieved = new haxe.ds.StringMap();
	this.position = 0;
	this.onError = onError;
};
saturn.db.BatchFetch.__name__ = ["saturn","db","BatchFetch"];
saturn.db.BatchFetch.prototype = {
	fetchList: null
	,position: null
	,retrieved: null
	,onComplete: null
	,onError: null
	,provider: null
	,items: null
	,onFinish: function(cb) {
		this.onComplete = cb;
	}
	,getByIds: function(objectIds,clazz,key,callBack) {
		var work = new haxe.ds.StringMap();
		if(__map_reserved.IDS != null) work.setReserved("IDS",objectIds); else work.h["IDS"] = objectIds;
		if(__map_reserved.CLASS != null) work.setReserved("CLASS",clazz); else work.h["CLASS"] = clazz;
		if(__map_reserved.TYPE != null) work.setReserved("TYPE","getByIds"); else work.h["TYPE"] = "getByIds";
		if(__map_reserved.KEY != null) work.setReserved("KEY",key); else work.h["KEY"] = key;
		var value = callBack;
		work.set("CALLBACK",value);
		this.fetchList.push(work);
		return this;
	}
	,getByValues: function(values,clazz,field,key,callBack) {
		var work = new haxe.ds.StringMap();
		if(__map_reserved.VALUES != null) work.setReserved("VALUES",values); else work.h["VALUES"] = values;
		if(__map_reserved.CLASS != null) work.setReserved("CLASS",clazz); else work.h["CLASS"] = clazz;
		if(__map_reserved.FIELD != null) work.setReserved("FIELD",field); else work.h["FIELD"] = field;
		if(__map_reserved.TYPE != null) work.setReserved("TYPE","getByValues"); else work.h["TYPE"] = "getByValues";
		if(__map_reserved.KEY != null) work.setReserved("KEY",key); else work.h["KEY"] = key;
		var value = callBack;
		work.set("CALLBACK",value);
		this.fetchList.push(work);
		return this;
	}
	,append: function(val,field,clazz,cb) {
		var key = Type.getClassName(clazz) + "." + field;
		if(!this.items.exists(key)) {
			var value = [];
			this.items.set(key,value);
		}
		this.items.get(key).push({ val : val, field : field, clazz : clazz, cb : cb});
	}
	,setProvider: function(provider) {
		this.provider = provider;
	}
	,execute: function(cb) {
		var _g = this;
		var provider = this.provider;
		if(provider == null) provider = saturn.client.core.CommonCore.getDefaultProvider();
		if(cb != null) this.onFinish(cb);
		var $it0 = this.items.keys();
		while( $it0.hasNext() ) {
			var key = $it0.next();
			var units = this.items.get(key);
			var work1 = new haxe.ds.StringMap();
			if(__map_reserved.TYPE != null) work1.setReserved("TYPE","FETCHITEM"); else work1.h["TYPE"] = "FETCHITEM";
			work1.set("FIELD",units[0].field);
			work1.set("CLASS",units[0].clazz);
			if(__map_reserved.ITEMS != null) work1.setReserved("ITEMS",units); else work1.h["ITEMS"] = units;
			this.items.remove(key);
			this.fetchList.push(work1);
		}
		if(this.position == this.fetchList.length) {
			this.onComplete();
			return;
		}
		var work = this.fetchList[this.position];
		var type;
		type = __map_reserved.TYPE != null?work.getReserved("TYPE"):work.h["TYPE"];
		this.position++;
		if(type == "getByIds") provider.getByIds(__map_reserved.IDS != null?work.getReserved("IDS"):work.h["IDS"],__map_reserved.CLASS != null?work.getReserved("CLASS"):work.h["CLASS"],function(objs,exception) {
			if(exception != null || objs == null) _g.onError(objs,exception); else {
				var key1;
				key1 = __map_reserved.KEY != null?work.getReserved("KEY"):work.h["KEY"];
				_g.retrieved.set(key1,objs);
				var userCallBack;
				userCallBack = __map_reserved.CALLBACK != null?work.getReserved("CALLBACK"):work.h["CALLBACK"];
				if(userCallBack != null) userCallBack(objs,exception); else if(_g.position == _g.fetchList.length) _g.onComplete(); else _g.execute();
			}
		}); else if(type == "getByValues") provider.getByValues(__map_reserved.VALUES != null?work.getReserved("VALUES"):work.h["VALUES"],__map_reserved.CLASS != null?work.getReserved("CLASS"):work.h["CLASS"],__map_reserved.FIELD != null?work.getReserved("FIELD"):work.h["FIELD"],function(objs1,exception1) {
			if(exception1 != null || objs1 == null) _g.onError(objs1,exception1); else {
				var key2;
				key2 = __map_reserved.KEY != null?work.getReserved("KEY"):work.h["KEY"];
				_g.retrieved.set(key2,objs1);
				var userCallBack1;
				userCallBack1 = __map_reserved.CALLBACK != null?work.getReserved("CALLBACK"):work.h["CALLBACK"];
				if(userCallBack1 != null) userCallBack1(objs1,exception1); else if(_g.position == _g.fetchList.length) _g.onComplete(); else _g.execute();
			}
		}); else if(type == "getByPkeys") provider.getByPkeys(__map_reserved.IDS != null?work.getReserved("IDS"):work.h["IDS"],__map_reserved.CLASS != null?work.getReserved("CLASS"):work.h["CLASS"],function(obj,exception2) {
			if(exception2 != null || obj == null) _g.onError(obj,exception2); else {
				var key3;
				key3 = __map_reserved.KEY != null?work.getReserved("KEY"):work.h["KEY"];
				_g.retrieved.set(key3,obj);
				var userCallBack2;
				userCallBack2 = __map_reserved.CALLBACK != null?work.getReserved("CALLBACK"):work.h["CALLBACK"];
				if(userCallBack2 != null) userCallBack2(obj,exception2); else if(_g.position == _g.fetchList.length) _g.onComplete(); else _g.execute();
			}
		}); else if(type == "FETCHITEM") {
			var items;
			items = __map_reserved.ITEMS != null?work.getReserved("ITEMS"):work.h["ITEMS"];
			var itemMap = new haxe.ds.StringMap();
			var _g1 = 0;
			while(_g1 < items.length) {
				var item = items[_g1];
				++_g1;
				if(!itemMap.exists(item.val)) {
					var value = [];
					itemMap.set(item.val,value);
				}
				itemMap.get(item.val).push(item.cb);
			}
			var values = [];
			var $it1 = itemMap.keys();
			while( $it1.hasNext() ) {
				var key4 = $it1.next();
				values.push(key4);
			}
			var field;
			field = __map_reserved.FIELD != null?work.getReserved("FIELD"):work.h["FIELD"];
			provider.getByValues(values,__map_reserved.CLASS != null?work.getReserved("CLASS"):work.h["CLASS"],field,function(objs2,exception3) {
				if(exception3 != null || objs2 == null) _g.onError(objs2,exception3); else {
					var _g2 = 0;
					while(_g2 < objs2.length) {
						var obj1 = objs2[_g2];
						++_g2;
						var fieldValue = Reflect.field(obj1,field);
						if(__map_reserved[fieldValue] != null?itemMap.existsReserved(fieldValue):itemMap.h.hasOwnProperty(fieldValue)) {
							var _g11 = 0;
							var _g21;
							_g21 = __map_reserved[fieldValue] != null?itemMap.getReserved(fieldValue):itemMap.h[fieldValue];
							while(_g11 < _g21.length) {
								var cb1 = _g21[_g11];
								++_g11;
								cb1(obj1);
							}
						}
					}
					if(_g.position == _g.fetchList.length) _g.onComplete(); else _g.execute();
				}
			});
		}
	}
	,__class__: saturn.db.BatchFetch
};
saturn.db.Connection = $hxClasses["saturn.db.Connection"] = function() { };
saturn.db.Connection.__name__ = ["saturn","db","Connection"];
saturn.db.Provider = $hxClasses["saturn.db.Provider"] = function() { };
saturn.db.Provider.__name__ = ["saturn","db","Provider"];
saturn.db.Provider.prototype = {
	getByIds: null
	,getByPkeys: null
	,getModel: null
	,getByValues: null
	,_closeConnection: null
	,getConfig: null
	,__class__: saturn.db.Provider
};
saturn.db.DefaultProvider = $hxClasses["saturn.db.DefaultProvider"] = function(binding_map,config,autoClose) {
	this.user = null;
	this.namedQueryHookConfigs = new haxe.ds.StringMap();
	this.namedQueryHooks = new haxe.ds.StringMap();
	this.connectWithUserCreds = false;
	this.enableBinding = true;
	this.useCache = true;
	this.setPlatform();
	if(binding_map != null) this.setModels(binding_map);
	this.config = config;
	this.autoClose = autoClose;
	this.namedQueryHooks = new haxe.ds.StringMap();
	if(config != null && Object.prototype.hasOwnProperty.call(config,"named_query_hooks")) this.addHooks(Reflect.field(config,"named_query_hooks"));
	var $it0 = this.namedQueryHooks.keys();
	while( $it0.hasNext() ) {
		var hook = $it0.next();
		saturn.core.Util.debug("Installed hook: " + hook + "/" + Std.string(this.namedQueryHooks.get(hook)));
	}
};
saturn.db.DefaultProvider.__name__ = ["saturn","db","DefaultProvider"];
saturn.db.DefaultProvider.__interfaces__ = [saturn.db.Provider];
saturn.db.DefaultProvider.prototype = {
	theBindingMap: null
	,fieldIndexMap: null
	,objectCache: null
	,namedQueryCache: null
	,useCache: null
	,enableBinding: null
	,connectWithUserCreds: null
	,namedQueryHooks: null
	,namedQueryHookConfigs: null
	,modelClasses: null
	,user: null
	,autoClose: null
	,name: null
	,config: null
	,winConversions: null
	,linConversions: null
	,conversions: null
	,regexs: null
	,platform: null
	,setPlatform: function() {
	}
	,generateQualifiedName: function(schemaName,tableName) {
		return null;
	}
	,getConfig: function() {
		return this.config;
	}
	,setName: function(name) {
		this.name = name;
	}
	,getName: function() {
		return this.name;
	}
	,setUser: function(user) {
		this.user = user;
		this._closeConnection();
	}
	,getUser: function() {
		return this.user;
	}
	,closeConnection: function(connection) {
		if(this.autoClose) this._closeConnection();
	}
	,_closeConnection: function() {
	}
	,generatedLinkedClone: function() {
		var clazz = js.Boot.getClass(this);
		var provider = Type.createEmptyInstance(clazz);
		provider.theBindingMap = this.theBindingMap;
		provider.fieldIndexMap = this.fieldIndexMap;
		provider.namedQueryCache = this.namedQueryCache;
		provider.useCache = this.useCache;
		provider.enableBinding = this.enableBinding;
		provider.connectWithUserCreds = this.connectWithUserCreds;
		provider.namedQueryHooks = this.namedQueryHooks;
		provider.modelClasses = this.modelClasses;
		provider.platform = this.platform;
		provider.linConversions = this.linConversions;
		provider.winConversions = this.winConversions;
		provider.conversions = this.conversions;
		provider.regexs = this.regexs;
		return provider;
	}
	,enableCache: function(cached) {
		this.useCache = cached;
	}
	,connectAsUser: function() {
		return this.connectWithUserCreds;
	}
	,setConnectAsUser: function(asUser) {
		this.connectWithUserCreds = asUser;
	}
	,setModels: function(binding_map) {
		this.theBindingMap = binding_map;
		var $it0 = binding_map.keys();
		while( $it0.hasNext() ) {
			var clazz = $it0.next();
			if((function($this) {
				var $r;
				var this1;
				this1 = __map_reserved[clazz] != null?binding_map.getReserved(clazz):binding_map.h[clazz];
				$r = this1.exists("polymorphic");
				return $r;
			}(this))) {
				if(!(function($this) {
					var $r;
					var this2;
					this2 = __map_reserved[clazz] != null?binding_map.getReserved(clazz):binding_map.h[clazz];
					$r = this2.exists("fields.synthetic");
					return $r;
				}(this))) {
					var this3;
					this3 = __map_reserved[clazz] != null?binding_map.getReserved(clazz):binding_map.h[clazz];
					var value = new haxe.ds.StringMap();
					this3.set("fields.synthetic",value);
				}
				var d;
				var this4;
				this4 = __map_reserved[clazz] != null?binding_map.getReserved(clazz):binding_map.h[clazz];
				d = this4.get("fields.synthetic");
				d.set("polymorphic",(function($this) {
					var $r;
					var this5;
					this5 = __map_reserved[clazz] != null?binding_map.getReserved(clazz):binding_map.h[clazz];
					$r = this5.get("polymorphic");
					return $r;
				}(this)));
			}
		}
		this.initModelClasses();
		this.resetCache();
	}
	,readModels: function(cb) {
	}
	,postConfigureModels: function() {
		var $it0 = this.theBindingMap.keys();
		while( $it0.hasNext() ) {
			var class_name = $it0.next();
			var d = this.theBindingMap.get(class_name);
			var value = this.getName();
			d.set("provider_name",value);
		}
		if(this.isModel(saturn.core.domain.FileProxy)) {
			var this1 = this.getModel(saturn.core.domain.FileProxy).getOptions();
			this.winConversions = this1.get("windows_conversions");
			var this2 = this.getModel(saturn.core.domain.FileProxy).getOptions();
			this.linConversions = this2.get("linux_conversions");
			if(this.platform == "windows") {
				this.conversions = this.winConversions;
				var this3 = this.getModel(saturn.core.domain.FileProxy).getOptions();
				this.regexs = this3.get("windows_allowed_paths_regex");
			} else if(this.platform == "linux") {
				this.conversions = this.linConversions;
				var this4 = this.getModel(saturn.core.domain.FileProxy).getOptions();
				this.regexs = this4.get("linux_allowed_paths_regex");
			}
			if(this.regexs != null) {
				var $it1 = this.regexs.keys();
				while( $it1.hasNext() ) {
					var key = $it1.next();
					var s;
					s = js.Boot.__cast(this.regexs.get(key) , String);
					var value1 = new EReg(s,"");
					this.regexs.set(key,value1);
				}
			}
		}
	}
	,getModels: function() {
		return this.theBindingMap;
	}
	,resetCache: function() {
		this.objectCache = new haxe.ds.StringMap();
		var $it0 = this.theBindingMap.keys();
		while( $it0.hasNext() ) {
			var className = $it0.next();
			var this1 = this.theBindingMap.get(className);
			var value = new haxe.ds.StringMap();
			this1.set("statements",value);
			var value1 = new haxe.ds.StringMap();
			this.objectCache.set(className,value1);
			if((function($this) {
				var $r;
				var this2 = $this.theBindingMap.get(className);
				$r = this2.exists("indexes");
				return $r;
			}(this))) {
				var $it1 = (function($this) {
					var $r;
					var this3;
					{
						var this4 = $this.theBindingMap.get(className);
						this3 = this4.get("indexes");
					}
					$r = this3.keys();
					return $r;
				}(this));
				while( $it1.hasNext() ) {
					var field = $it1.next();
					var this5 = this.objectCache.get(className);
					var value2 = new haxe.ds.StringMap();
					this5.set(field,value2);
				}
			}
		}
		this.namedQueryCache = new haxe.ds.StringMap();
	}
	,getObjectFromCache: function(clazz,field,val) {
		var className = Type.getClassName(clazz);
		if(this.objectCache.exists(className)) {
			if((function($this) {
				var $r;
				var this1 = $this.objectCache.get(className);
				$r = this1.exists(field);
				return $r;
			}(this))) {
				if((function($this) {
					var $r;
					var this2;
					{
						var this3 = $this.objectCache.get(className);
						this2 = this3.get(field);
					}
					var key = val;
					$r = this2.exists(key);
					return $r;
				}(this))) {
					var this4;
					var this5 = this.objectCache.get(className);
					this4 = this5.get(field);
					var key1 = val;
					return this4.get(key1);
				} else return null;
			} else return null;
		} else return null;
	}
	,initialiseObjects: function(idsToFetch,toBind,prefetched,exception,callBack,clazz,bindField,cache,allowAutoBind) {
		if(allowAutoBind == null) allowAutoBind = true;
		if(idsToFetch.length > 0 && toBind == null || clazz == null || toBind != null && toBind.length > 0 && clazz != null && js.Boot.__instanceof(toBind[0],clazz)) callBack(toBind,exception); else {
			var model = this.getModel(clazz);
			if(model == null) {
				var boundObjs1 = [];
				var _g = 0;
				while(_g < toBind.length) {
					var item = toBind[_g];
					++_g;
					var obj = Type.createInstance(clazz,[]);
					var _g1 = 0;
					var _g2 = Type.getInstanceFields(clazz);
					while(_g1 < _g2.length) {
						var field = _g2[_g1];
						++_g1;
						if(Object.prototype.hasOwnProperty.call(item,field)) Reflect.setField(obj,field,Reflect.field(item,field));
					}
					boundObjs1.push(obj);
				}
				callBack(boundObjs1,exception);
				return;
			}
			var autoActivate = model.getAutoActivateLevel();
			var surpressSetup = false;
			if(autoActivate != -1 && this.enableBinding && allowAutoBind) surpressSetup = true;
			var boundObjs = [];
			if(toBind != null) {
				var _g3 = 0;
				while(_g3 < toBind.length) {
					var obj1 = toBind[_g3];
					++_g3;
					boundObjs.push(this.bindObject(obj1,clazz,cache,bindField,surpressSetup));
				}
			}
			if(autoActivate != -1 && this.enableBinding && allowAutoBind) this.activate(boundObjs,autoActivate,function(err) {
				if(err == null) {
					var _g4 = 0;
					while(_g4 < boundObjs.length) {
						var boundObj = boundObjs[_g4];
						++_g4;
						if(Reflect.isFunction(boundObj.setup)) boundObj.setup();
					}
					if(prefetched != null) {
						var _g5 = 0;
						while(_g5 < prefetched.length) {
							var obj2 = prefetched[_g5];
							++_g5;
							boundObjs.push(obj2);
						}
					}
					callBack(boundObjs,exception);
				} else callBack(null,err);
			}); else {
				if(prefetched != null) {
					var _g6 = 0;
					while(_g6 < prefetched.length) {
						var obj3 = prefetched[_g6];
						++_g6;
						boundObjs.push(obj3);
					}
				}
				callBack(boundObjs,exception);
			}
		}
	}
	,getById: function(id,clazz,callBack) {
		this.getByIds([id],clazz,function(objs,exception) {
			if(objs != null) callBack(objs[0],exception); else callBack(null,exception);
		});
	}
	,getByIds: function(ids,clazz,callBack) {
		var _g = this;
		var prefetched = null;
		var idsToFetch = null;
		if(this.useCache) {
			var model = this.getModel(clazz);
			if(model != null) {
				var firstKey = model.getFirstKey();
				prefetched = [];
				idsToFetch = [];
				var _g1 = 0;
				while(_g1 < ids.length) {
					var id = ids[_g1];
					++_g1;
					var cacheObject = this.getObjectFromCache(clazz,firstKey,id);
					if(cacheObject != null) prefetched.push(cacheObject); else idsToFetch.push(id);
				}
			} else idsToFetch = ids;
		} else idsToFetch = ids;
		if(idsToFetch.length > 0) this._getByIds(idsToFetch,clazz,function(toBind,exception) {
			_g.initialiseObjects(idsToFetch,toBind,prefetched,exception,callBack,clazz,null,true);
		}); else callBack(prefetched,null);
	}
	,_getByIds: function(ids,clazz,callBack) {
	}
	,getByExample: function(obj,cb) {
		var q = this.getQuery();
		q.addExample(obj);
		this.query(q,cb);
	}
	,query: function(query,cb) {
		var _g = this;
		this._query(query,function(objs,err) {
			if(_g.isDataBinding()) {
				if(err == null) {
					var clazzList = query.getSelectClassList();
					if(query.bindResults() && clazzList != null) {
						if(clazzList.length == 1) _g.initialiseObjects([],objs,[],err,cb,Type.resolveClass(clazzList[0]),null,true);
					} else cb(objs,err);
				} else cb(null,err);
			} else cb(objs,err);
		});
	}
	,_query: function(query,cb) {
	}
	,getByValue: function(value,clazz,field,callBack) {
		this.getByValues([value],clazz,field,function(objs,exception) {
			if(objs != null) callBack(objs[0],exception); else callBack(null,exception);
		});
	}
	,getByValues: function(ids,clazz,field,callBack) {
		var _g = this;
		var prefetched = null;
		var idsToFetch = null;
		if(this.useCache) {
			var model = this.getModel(clazz);
			if(model != null) {
				prefetched = [];
				idsToFetch = [];
				var _g1 = 0;
				while(_g1 < ids.length) {
					var id = ids[_g1];
					++_g1;
					var cacheObject = this.getObjectFromCache(clazz,field,id);
					if(cacheObject != null) {
						if((cacheObject instanceof Array) && cacheObject.__enum__ == null) {
							var objArray = cacheObject;
							var _g11 = 0;
							while(_g11 < objArray.length) {
								var obj = objArray[_g11];
								++_g11;
								prefetched.push(obj);
							}
						} else prefetched.push(cacheObject);
					} else idsToFetch.push(id);
				}
			} else idsToFetch = ids;
		} else idsToFetch = ids;
		if(idsToFetch.length > 0) this._getByValues(idsToFetch,clazz,field,function(toBind,exception) {
			_g.initialiseObjects(idsToFetch,toBind,prefetched,exception,callBack,clazz,field,true);
		}); else callBack(prefetched,null);
	}
	,_getByValues: function(values,clazz,field,callBack) {
	}
	,getObjects: function(clazz,callBack) {
		var _g = this;
		this._getObjects(clazz,function(toBind,exception) {
			if(exception != null) callBack(null,exception); else _g.initialiseObjects([],toBind,[],exception,callBack,clazz,null,true);
		});
	}
	,_getObjects: function(clazz,callBack) {
	}
	,getByPkey: function(id,clazz,callBack) {
		this.getByPkeys([id],clazz,function(objs,exception) {
			if(objs != null) callBack(objs[0],exception); else callBack(null,exception);
		});
	}
	,getByPkeys: function(ids,clazz,callBack) {
		var _g = this;
		var prefetched = null;
		var idsToFetch = null;
		if(this.useCache) {
			var model = this.getModel(clazz);
			if(model != null) {
				var priField = model.getPrimaryKey();
				prefetched = [];
				idsToFetch = [];
				var _g1 = 0;
				while(_g1 < ids.length) {
					var id = ids[_g1];
					++_g1;
					var cacheObject = this.getObjectFromCache(clazz,priField,id);
					if(cacheObject != null) prefetched.push(cacheObject); else idsToFetch.push(id);
				}
			} else idsToFetch = ids;
		} else idsToFetch = ids;
		if(idsToFetch.length > 0) this._getByPkeys(idsToFetch,clazz,function(toBind,exception) {
			_g.initialiseObjects(idsToFetch,toBind,prefetched,exception,callBack,clazz,null,true);
		}); else callBack(prefetched,null);
	}
	,_getByPkeys: function(ids,clazz,callBack) {
	}
	,getConnection: function(config,cb) {
	}
	,sql: function(sql,parameters,cb) {
		this.getByNamedQuery("saturn.db.provider.hooks.RawSQLHook:SQL",[sql,parameters],null,false,cb);
	}
	,getByNamedQuery: function(queryId,parameters,clazz,cache,callBack) {
		var _g = this;
		saturn.core.Util.debug("In getByNamedQuery");
		try {
			var isCached = false;
			if(cache && this.namedQueryCache.exists(queryId)) {
				var qResults = null;
				var queries = this.namedQueryCache.get(queryId);
				var _g1 = 0;
				while(_g1 < queries.length) {
					var query = queries[_g1];
					++_g1;
					saturn.core.Util.debug("Checking for existing results");
					var serialParamString = haxe.Serializer.run(parameters);
					if(query.queryParamSerial == serialParamString) {
						qResults = query.queryResults;
						break;
					}
				}
				if(qResults != null) {
					callBack(qResults,null);
					return;
				}
			} else {
				var value = [];
				this.namedQueryCache.set(queryId,value);
			}
			var privateCB = function(toBind,exception) {
				if(toBind == null) {
					if(isCached == false && _g.useCache && cache) {
						var namedQuery = new saturn.db.NamedQueryCache();
						namedQuery.queryName = queryId;
						namedQuery.queryParams = parameters;
						namedQuery.queryParamSerial = haxe.Serializer.run(parameters);
						namedQuery.queryResults = toBind;
						_g.namedQueryCache.get(queryId).push(namedQuery);
					}
					callBack(toBind,exception);
				} else _g.initialiseObjects([],toBind,[],exception,function(objs,err) {
					if(isCached == false && _g.useCache && cache) {
						var namedQuery1 = new saturn.db.NamedQueryCache();
						namedQuery1.queryName = queryId;
						namedQuery1.queryParams = parameters;
						namedQuery1.queryParamSerial = haxe.Serializer.run(parameters);
						namedQuery1.queryResults = objs;
						_g.namedQueryCache.get(queryId).push(namedQuery1);
					}
					callBack(objs,err);
				},clazz,null,cache);
			};
			if(queryId == "saturn.workflow") {
				var jobName = parameters[0];
				var config = parameters[1];
				saturn.core.Util.debug("Got workflow query " + jobName);
				saturn.core.Util.debug(Type.getClassName(config == null?null:js.Boot.getClass(config)));
				if(this.namedQueryHooks.exists(jobName)) this.namedQueryHooks.get(jobName)(config,function(object,error) {
					privateCB([object],object.getError());
				}); else {
					saturn.core.Util.debug("Unknown workflow query");
					this._getByNamedQuery(queryId,parameters,clazz,privateCB);
				}
			} else if(this.namedQueryHooks.exists(queryId)) {
				var config1 = null;
				if(this.namedQueryHookConfigs.exists(queryId)) config1 = this.namedQueryHookConfigs.get(queryId);
				saturn.core.Util.debug("Calling hook");
				this.namedQueryHooks.get(queryId)(queryId,parameters,clazz,privateCB,config1);
			} else this._getByNamedQuery(queryId,parameters,clazz,privateCB);
		} catch( ex ) {
			if (ex instanceof js._Boot.HaxeError) ex = ex.val;
			callBack(null,"An unexpected exception has occurred");
			saturn.core.Util.debug(ex);
		}
	}
	,addHooks: function(hooks) {
		var _g = 0;
		while(_g < hooks.length) {
			var hookdef = hooks[_g];
			++_g;
			var name = Reflect.field(hookdef,"name");
			var hook;
			if(Object.prototype.hasOwnProperty.call(hookdef,"func")) hook = Reflect.field(hookdef,"func"); else {
				var clazz = Reflect.field(hookdef,"class");
				var method = Reflect.field(hookdef,"method");
				hook = Reflect.field(Type.resolveClass(clazz),method);
			}
			this.namedQueryHooks.set(name,hook);
			var value = hookdef;
			this.namedQueryHookConfigs.set(name,value);
		}
	}
	,_getByNamedQuery: function(queryId,parameters,clazz,callBack) {
	}
	,getByIdStartsWith: function(id,field,clazz,limit,callBack) {
		var _g = this;
		var queryId = "__STARTSWITH_" + Type.getClassName(clazz);
		var parameters = [];
		parameters.push(field);
		parameters.push(id);
		var isCached = false;
		if(this.namedQueryCache.exists(queryId)) {
			var qResults = null;
			var queries = this.namedQueryCache.get(queryId);
			var _g1 = 0;
			while(_g1 < queries.length) {
				var query = queries[_g1];
				++_g1;
				var qParams = query.queryParams;
				if(qParams.length != parameters.length) continue; else {
					var matched = true;
					var _g2 = 0;
					var _g11 = qParams.length;
					while(_g2 < _g11) {
						var i = _g2++;
						if(qParams[i] != parameters[i]) matched = false;
					}
					if(matched) {
						qResults = query.queryResults;
						break;
					}
				}
			}
			if(qResults != null) {
				callBack(qResults,null);
				return;
			}
		} else {
			var value = [];
			this.namedQueryCache.set(queryId,value);
		}
		this._getByIdStartsWith(id,field,clazz,limit,function(toBind,exception) {
			if(toBind == null) callBack(toBind,exception); else _g.initialiseObjects([],toBind,[],exception,function(objs,err) {
				if(isCached == false && _g.useCache) {
					var namedQuery = new saturn.db.NamedQueryCache();
					namedQuery.queryName = queryId;
					namedQuery.queryParams = parameters;
					namedQuery.queryResults = objs;
					_g.namedQueryCache.get(queryId).push(namedQuery);
				}
				callBack(objs,err);
			},clazz,null,false,false);
		});
	}
	,_getByIdStartsWith: function(id,field,clazz,limit,callBack) {
	}
	,update: function(object,callBack) {
		this.synchronizeInternalLinks([object]);
		var className = Type.getClassName(Type.getClass(object));
		this.evictObject(object);
		var attributeMaps = [];
		attributeMaps.push(this.unbindObject(object));
		this._update(attributeMaps,className,callBack);
	}
	,insert: function(obj,cb) {
		var _g = this;
		this.synchronizeInternalLinks([obj]);
		var className = Type.getClassName(Type.getClass(obj));
		this.evictObject(obj);
		var attributeMaps = [];
		attributeMaps.push(this.unbindObject(obj));
		this._insert(attributeMaps,className,function(err) {
			if(err == null) _g.attach([obj],true,function(err1) {
				cb(err1);
			}); else cb(err);
		});
	}
	,'delete': function(obj,cb) {
		var _g = this;
		var className = Type.getClassName(Type.getClass(obj));
		var attributeMaps = [];
		attributeMaps.push(this.unbindObject(obj));
		this.evictObject(obj);
		this._delete(attributeMaps,className,function(err) {
			var model = _g.getModel(Type.getClass(obj));
			var field = model.getPrimaryKey();
			obj[field] = null;
			cb(err);
		});
	}
	,evictObject: function(object) {
		var clazz = Type.getClass(object);
		var className = Type.getClassName(clazz);
		if(this.objectCache.exists(className)) {
			var $it0 = (function($this) {
				var $r;
				var this1 = $this.objectCache.get(className);
				$r = this1.keys();
				return $r;
			}(this));
			while( $it0.hasNext() ) {
				var indexField = $it0.next();
				var val = Reflect.field(object,indexField);
				if(val != null && val != "") {
					if((function($this) {
						var $r;
						var this2;
						{
							var this3 = $this.objectCache.get(className);
							this2 = this3.get(indexField);
						}
						$r = this2.exists(val);
						return $r;
					}(this))) {
						var this4;
						var this5 = this.objectCache.get(className);
						this4 = this5.get(indexField);
						this4.remove(val);
					}
				}
			}
		}
	}
	,evictNamedQuery: function(queryId,parameters) {
		if(this.namedQueryCache.exists(queryId)) {
			var qResults = null;
			var queries = this.namedQueryCache.get(queryId);
			var _g = 0;
			while(_g < queries.length) {
				var query = queries[_g];
				++_g;
				var qParams = query.queryParams;
				if(qParams.length != parameters.length) continue; else {
					var matched = true;
					var _g2 = 0;
					var _g1 = qParams.length;
					while(_g2 < _g1) {
						var i = _g2++;
						if(qParams[i] != parameters[i]) matched = false;
					}
					if(matched) {
						HxOverrides.remove(queries,query);
						break;
					}
				}
			}
			if(queries.length > 0) this.namedQueryCache.remove(queryId); else this.namedQueryCache.set(queryId,queries);
		}
	}
	,updateObjects: function(objs,callBack) {
		this.synchronizeInternalLinks(objs);
		var className = Type.getClassName(Type.getClass(objs[0]));
		var attributeMaps = [];
		var _g = 0;
		while(_g < objs.length) {
			var object = objs[_g];
			++_g;
			this.evictObject(object);
			attributeMaps.push(this.unbindObject(object));
		}
		this._update(attributeMaps,className,callBack);
	}
	,insertObjects: function(objs,cb) {
		var _g1 = this;
		if(objs.length == 0) {
			cb(null);
			return;
		}
		this.synchronizeInternalLinks(objs);
		this.attach(objs,false,function(err) {
			if(err != null) cb(err); else {
				var className = Type.getClassName(Type.getClass(objs[0]));
				var attributeMaps = [];
				var _g = 0;
				while(_g < objs.length) {
					var object = objs[_g];
					++_g;
					_g1.evictObject(object);
					attributeMaps.push(_g1.unbindObject(object));
				}
				_g1._insert(attributeMaps,className,function(err1) {
					cb(err1);
				});
			}
		});
	}
	,rollback: function(callBack) {
		this._rollback(callBack);
	}
	,commit: function(callBack) {
		this._commit(callBack);
	}
	,_update: function(attributeMaps,className,callBack) {
	}
	,_insert: function(attributeMaps,className,callBack) {
	}
	,_delete: function(attributeMaps,className,callBack) {
	}
	,_rollback: function(callBack) {
	}
	,_commit: function(cb) {
		cb("Commit not supported");
	}
	,bindObject: function(attributeMap,clazz,cache,indexField,suspendSetup) {
		if(suspendSetup == null) suspendSetup = false;
		if(clazz == null) {
			var _g = 0;
			var _g1 = Reflect.fields(attributeMap);
			while(_g < _g1.length) {
				var key = _g1[_g];
				++_g;
				var val = Reflect.field(attributeMap,key);
				if(saturn.db.DefaultProvider.r_date.match(val)) Reflect.setField(attributeMap,key,new Date(Date.parse(val)));
			}
			return attributeMap;
		}
		if(this.enableBinding) {
			var className = Type.getClassName(clazz);
			var parts = className.split(".");
			var shortName = parts.pop();
			var packageName = parts.join(".");
			var obj = Type.createInstance(clazz,[]);
			if(this.theBindingMap.exists(className)) {
				var map;
				var this1 = this.theBindingMap.get(className);
				map = this1.get("fields");
				var indexes;
				var this2 = this.theBindingMap.get(className);
				indexes = this2.get("indexes");
				var atPriIndex = null;
				var $it0 = indexes.keys();
				while( $it0.hasNext() ) {
					var atIndexField = $it0.next();
					if((__map_reserved[atIndexField] != null?indexes.getReserved(atIndexField):indexes.h[atIndexField]) == 1) {
						atPriIndex = atIndexField;
						break;
					}
				}
				var colPriIndex = null;
				if(atPriIndex != null) colPriIndex = __map_reserved[atPriIndex] != null?map.getReserved(atPriIndex):map.h[atPriIndex];
				var priKeyValue = null;
				if(Reflect.hasField(attributeMap,colPriIndex)) priKeyValue = Reflect.field(attributeMap,colPriIndex); else if(Reflect.hasField(attributeMap,colPriIndex.toLowerCase())) priKeyValue = Reflect.field(attributeMap,colPriIndex.toLowerCase());
				var keys = [];
				var $it1 = map.keys();
				while( $it1.hasNext() ) {
					var key1 = $it1.next();
					keys.push(key1);
				}
				if(indexField != null && !(__map_reserved[indexField] != null?map.existsReserved(indexField):map.h.hasOwnProperty(indexField))) keys.push(indexField);
				var _g2 = 0;
				while(_g2 < keys.length) {
					var key2 = keys[_g2];
					++_g2;
					if(!(function($this) {
						var $r;
						var this3 = $this.objectCache.get(className);
						$r = this3.exists(key2);
						return $r;
					}(this))) {
						var this4 = this.objectCache.get(className);
						var value = new haxe.ds.StringMap();
						this4.set(key2,value);
					}
					var atKey;
					atKey = __map_reserved[key2] != null?map.getReserved(key2):map.h[key2];
					var val1 = null;
					if(Reflect.hasField(attributeMap,atKey)) val1 = Reflect.field(attributeMap,atKey); else if(Reflect.hasField(attributeMap,atKey.toLowerCase())) val1 = Reflect.field(attributeMap,atKey.toLowerCase());
					if(saturn.db.DefaultProvider.r_date.match(val1)) Reflect.setField(obj,key2,new Date(Date.parse(val))); else obj[key2] = val1;
					if(cache && indexes != null && ((__map_reserved[key2] != null?indexes.existsReserved(key2):indexes.h.hasOwnProperty(key2)) || key2 == indexField) && this.useCache) {
						if(priKeyValue != null) {
							if((function($this) {
								var $r;
								var this5;
								{
									var this6 = $this.objectCache.get(className);
									this5 = this6.get(key2);
								}
								$r = this5.exists(val1);
								return $r;
							}(this))) {
								var mappedObj;
								var this7;
								var this8 = this.objectCache.get(className);
								this7 = this8.get(key2);
								mappedObj = this7.get(val1);
								var toCheck = mappedObj;
								var isArray = (mappedObj instanceof Array) && mappedObj.__enum__ == null;
								if(!isArray) toCheck = [mappedObj];
								var match = false;
								var _g21 = 0;
								var _g11 = toCheck.length;
								while(_g21 < _g11) {
									var i = _g21++;
									var eObj = toCheck[i];
									var priValue = Reflect.field(eObj,atPriIndex);
									if(priValue == priKeyValue) {
										toCheck[i] = obj;
										match = true;
										break;
									}
								}
								if(match == false) toCheck.push(obj);
								if(toCheck.length == 1) {
									var this9;
									var this10 = this.objectCache.get(className);
									this9 = this10.get(key2);
									var value1 = toCheck[0];
									this9.set(val1,value1);
								} else {
									var this11;
									var this12 = this.objectCache.get(className);
									this11 = this12.get(key2);
									this11.set(val1,toCheck);
								}
								continue;
							}
						}
						var this13;
						var this14 = this.objectCache.get(className);
						this13 = this14.get(key2);
						this13.set(val1,obj);
					}
				}
			}
			if(!suspendSetup && Reflect.isFunction(obj.setup)) obj.setup();
			return obj;
		} else return attributeMap;
	}
	,unbindObject: function(object) {
		if(this.enableBinding) {
			var className = Type.getClassName(Type.getClass(object));
			var attributeMap = new haxe.ds.StringMap();
			if(this.theBindingMap.exists(className)) {
				var map;
				var this1 = this.theBindingMap.get(className);
				map = this1.get("fields");
				var $it0 = map.keys();
				while( $it0.hasNext() ) {
					var key = $it0.next();
					var val = Reflect.field(object,key);
					var key1;
					key1 = __map_reserved[key] != null?map.getReserved(key):map.h[key];
					if(__map_reserved[key1] != null) attributeMap.setReserved(key1,val); else attributeMap.h[key1] = val;
				}
				return attributeMap;
			} else return null;
		} else return object;
	}
	,activate: function(objects,depthLimit,callBack) {
		var _g = this;
		this._activate(objects,1,depthLimit,function(error) {
			if(error == null) _g.merge(objects);
			callBack(error);
		});
	}
	,_activate: function(objects,depth,depthLimit,callBack) {
		var _g1 = this;
		var objectsToFetch = 0;
		var batchQuery = new saturn.db.BatchFetch(function(obj,err) {
		});
		batchQuery.setProvider(this);
		var classToFetch = new haxe.ds.StringMap();
		var _g = 0;
		while(_g < objects.length) {
			var object = objects[_g];
			++_g;
			if(object == null || js.Boot.__instanceof(object,ArrayBuffer) || js.Boot.__instanceof(object,haxe.ds.StringMap)) continue;
			var clazz = Type.getClass(object);
			if(clazz == null) continue;
			var clazzName = Type.getClassName(clazz);
			if(this.theBindingMap.exists(clazzName)) {
				if((function($this) {
					var $r;
					var this1 = $this.theBindingMap.get(clazzName);
					$r = this1.exists("fields.synthetic");
					return $r;
				}(this))) {
					var synthFields;
					var this2 = this.theBindingMap.get(clazzName);
					synthFields = this2.get("fields.synthetic");
					var $it0 = synthFields.keys();
					while( $it0.hasNext() ) {
						var synthFieldName = $it0.next();
						var synthInfo;
						synthInfo = __map_reserved[synthFieldName] != null?synthFields.getReserved(synthFieldName):synthFields.h[synthFieldName];
						var fkField = synthInfo.get("fk_field");
						if(fkField == null) {
							Reflect.setField(object,synthFieldName,Type.createInstance(Type.resolveClass(synthInfo.get("class")),[Reflect.field(object,synthInfo.get("field"))]));
							continue;
						}
						var synthVal = Reflect.field(object,synthFieldName);
						if(synthVal != null) continue;
						var isPolymorphic = synthInfo.exists("selector_field");
						var synthClass;
						if(isPolymorphic) {
							var selectorField = synthInfo.get("selector_field");
							var objValue = Reflect.field(object,selectorField);
							if(synthInfo.get("selector_values").exists(objValue)) synthClass = synthInfo.get("selector_values").get(objValue); else continue;
							var selectorValue = synthInfo.get("selector_value");
							synthFieldName = "_MERGE";
						} else synthClass = synthInfo.get("class");
						var field = synthInfo.get("field");
						var val = Reflect.field(object,field);
						if(val == null || val == "" && !((val | 0) === val)) object[synthFieldName] = null; else {
							var cacheObj = this.getObjectFromCache(Type.resolveClass(synthClass),fkField,val);
							if(cacheObj == null) {
								objectsToFetch++;
								if(!(__map_reserved[synthClass] != null?classToFetch.existsReserved(synthClass):classToFetch.h.hasOwnProperty(synthClass))) {
									var value = new haxe.ds.StringMap();
									if(__map_reserved[synthClass] != null) classToFetch.setReserved(synthClass,value); else classToFetch.h[synthClass] = value;
								}
								if(!(function($this) {
									var $r;
									var this3;
									this3 = __map_reserved[synthClass] != null?classToFetch.getReserved(synthClass):classToFetch.h[synthClass];
									$r = this3.exists(fkField);
									return $r;
								}(this))) {
									var this4;
									this4 = __map_reserved[synthClass] != null?classToFetch.getReserved(synthClass):classToFetch.h[synthClass];
									var value1 = new haxe.ds.StringMap();
									this4.set(fkField,value1);
								}
								var this5;
								var this6;
								this6 = __map_reserved[synthClass] != null?classToFetch.getReserved(synthClass):classToFetch.h[synthClass];
								this5 = this6.get(fkField);
								this5.set(val,"");
							} else object[synthFieldName] = cacheObj;
						}
					}
				}
			}
		}
		var $it1 = classToFetch.keys();
		while( $it1.hasNext() ) {
			var synthClass1 = $it1.next();
			var $it2 = (function($this) {
				var $r;
				var this7;
				this7 = __map_reserved[synthClass1] != null?classToFetch.getReserved(synthClass1):classToFetch.h[synthClass1];
				$r = this7.keys();
				return $r;
			}(this));
			while( $it2.hasNext() ) {
				var fkField1 = $it2.next();
				var objList = [];
				var $it3 = (function($this) {
					var $r;
					var this8;
					{
						var this9;
						this9 = __map_reserved[synthClass1] != null?classToFetch.getReserved(synthClass1):classToFetch.h[synthClass1];
						this8 = this9.get(fkField1);
					}
					$r = this8.keys();
					return $r;
				}(this));
				while( $it3.hasNext() ) {
					var objId = $it3.next();
					objList.push(objId);
				}
				batchQuery.getByValues(objList,Type.resolveClass(synthClass1),fkField1,"__IGNORED__",null);
			}
		}
		batchQuery.onComplete = function() {
			var _g2 = 0;
			while(_g2 < objects.length) {
				var object1 = objects[_g2];
				++_g2;
				var clazz1 = Type.getClass(object1);
				if(object1 == null || js.Boot.__instanceof(object1,ArrayBuffer) || clazz1 == null) continue;
				var clazzName1 = Type.getClassName(clazz1);
				if(_g1.theBindingMap.exists(clazzName1)) {
					if((function($this) {
						var $r;
						var this10 = _g1.theBindingMap.get(clazzName1);
						$r = this10.exists("fields.synthetic");
						return $r;
					}(this))) {
						var synthFields1;
						var this11 = _g1.theBindingMap.get(clazzName1);
						synthFields1 = this11.get("fields.synthetic");
						var $it4 = synthFields1.keys();
						while( $it4.hasNext() ) {
							var synthFieldName1 = $it4.next();
							var synthVal1 = Reflect.field(object1,synthFieldName1);
							if(synthVal1 != null) continue;
							var synthInfo1;
							synthInfo1 = __map_reserved[synthFieldName1] != null?synthFields1.getReserved(synthFieldName1):synthFields1.h[synthFieldName1];
							var isPolymorphic1 = synthInfo1.exists("selector_field");
							var synthClass2;
							if(isPolymorphic1) {
								var selectorField1 = synthInfo1.get("selector_field");
								var objValue1 = Reflect.field(object1,selectorField1);
								if(synthInfo1.get("selector_values").exists(objValue1)) synthClass2 = synthInfo1.get("selector_values").get(objValue1); else continue;
								var selectorValue1 = synthInfo1.get("selector_value");
								synthFieldName1 = "_MERGE";
							} else synthClass2 = synthInfo1.get("class");
							var field1 = synthInfo1.get("field");
							var val1 = Reflect.field(object1,field1);
							if(val1 != null && val1 != "") {
								var fkField2 = synthInfo1.get("fk_field");
								if(synthInfo1.exists("selector_field")) synthFieldName1 = "_MERGE";
								var cacheObj1 = _g1.getObjectFromCache(Type.resolveClass(synthClass2),fkField2,val1);
								if(cacheObj1 != null) object1[synthFieldName1] = cacheObj1;
							}
						}
					}
				}
			}
			var newObjList = [];
			var _g3 = 0;
			while(_g3 < objects.length) {
				var object2 = objects[_g3];
				++_g3;
				var clazz2 = Type.getClass(object2);
				if(object2 == null || js.Boot.__instanceof(object2,ArrayBuffer) || clazz2 == null) continue;
				var model = _g1.getModel(clazz2);
				if(model != null) {
					var _g21 = 0;
					var _g31 = Reflect.fields(object2);
					while(_g21 < _g31.length) {
						var field2 = _g31[_g21];
						++_g21;
						var val2 = Reflect.field(object2,field2);
						if(!model.isSyntheticallyBound(field2) || val2 == null) continue;
						var objs = Reflect.field(object2,field2);
						if(!((objs instanceof Array) && objs.__enum__ == null)) objs = [objs];
						var _g4 = 0;
						while(_g4 < objs.length) {
							var newObject = objs[_g4];
							++_g4;
							newObjList.push(newObject);
						}
					}
				}
			}
			if(newObjList.length > 0 && depthLimit > depth) _g1._activate(newObjList,depth + 1,depthLimit,callBack); else callBack(null);
		};
		batchQuery.execute();
	}
	,merge: function(objects) {
		var toVisit = [];
		var _g1 = 0;
		var _g = objects.length;
		while(_g1 < _g) {
			var i = _g1++;
			toVisit.push({ 'parent' : objects, 'pos' : i, 'value' : objects[i]});
		}
		this._merge(toVisit);
	}
	,_merge: function(toVisit) {
		while(true) {
			if(toVisit.length == 0) break;
			var item = toVisit.pop();
			var original = Reflect.field(item,"value");
			if(Object.prototype.hasOwnProperty.call(original,"_MERGE")) {
				var obj = Reflect.field(original,"_MERGE");
				var _g = 0;
				var _g1 = Reflect.fields(original);
				while(_g < _g1.length) {
					var field = _g1[_g];
					++_g;
					if(field != "_MERGE") Reflect.setField(obj,field,Reflect.field(original,field));
				}
				var parent = Reflect.field(item,"parent");
				if(Object.prototype.hasOwnProperty.call(item,"pos")) parent[Reflect.field(item,"pos")] = obj; else Reflect.setField(parent,Reflect.field(item,"field"),obj);
				original = obj;
			}
			var model = this.getModel(original);
			if(model == null) continue;
			var _g2 = 0;
			var _g11 = model.getFields();
			while(_g2 < _g11.length) {
				var field1 = _g11[_g2];
				++_g2;
				var value = Reflect.field(original,field1);
				var isObject = false;
				isObject = Std["is"](value,Object);
				if(isObject) {
					if((value instanceof Array) && value.__enum__ == null) {
						var _g3 = 0;
						var _g21 = value.length;
						while(_g3 < _g21) {
							var i = _g3++;
							toVisit.push({ 'parent' : value, 'pos' : i, 'value' : value[i]});
						}
					} else toVisit.push({ 'parent' : original, 'value' : value, 'field' : field1});
				}
			}
		}
	}
	,getModel: function(clazz) {
		if(clazz == null) return null; else {
			var t = Type.getClass(clazz);
			var className = Type.getClassName(clazz);
			return this.getModelByStringName(className);
		}
	}
	,getObjectModel: function(object) {
		if(object == null) return null; else {
			var clazz = Type.getClass(object);
			return this.getModel(clazz);
		}
	}
	,save: function(object,cb,autoAttach) {
		if(autoAttach == null) autoAttach = false;
		this.insertOrUpdate([object],cb,autoAttach);
	}
	,initModelClasses: function() {
		this.modelClasses = [];
		var $it0 = this.theBindingMap.keys();
		while( $it0.hasNext() ) {
			var classStr = $it0.next();
			var clazz = Type.resolveClass(classStr);
			if(clazz != null) this.modelClasses.push(this.getModel(clazz));
		}
	}
	,getModelClasses: function() {
		return this.modelClasses;
	}
	,getModelByStringName: function(className) {
		if(this.theBindingMap.exists(className)) {
			if((function($this) {
				var $r;
				var this1 = $this.theBindingMap.get(className);
				$r = this1.exists("model");
				return $r;
			}(this))) return new saturn.db.Model(this.theBindingMap.get(className),className); else return new saturn.db.Model(this.theBindingMap.get(className),className);
		} else return null;
	}
	,isModel: function(clazz) {
		if(this.theBindingMap != null) {
			var key = Type.getClassName(clazz);
			return this.theBindingMap.exists(key);
		} else return false;
	}
	,setSelectClause: function(className,selClause) {
		if(this.theBindingMap.exists(className)) {
			var this1;
			var this2 = this.theBindingMap.get(className);
			this1 = this2.get("statements");
			this1.set("SELECT",selClause);
		}
	}
	,modelToReal: function(modelDef,models,cb) {
		var _g3 = this;
		var priKey = modelDef.getPrimaryKey();
		var fields = modelDef.getFields();
		var clazz = modelDef.getClass();
		var syntheticInstanceAttributes = modelDef.getSynthenticFields();
		var syntheticSet = null;
		if(syntheticInstanceAttributes != null) {
			syntheticSet = new haxe.ds.StringMap();
			var $it0 = syntheticInstanceAttributes.keys();
			while( $it0.hasNext() ) {
				var instanceName = $it0.next();
				var fkRel;
				fkRel = __map_reserved[instanceName] != null?syntheticInstanceAttributes.getReserved(instanceName):syntheticInstanceAttributes.h[instanceName];
				var parentIdColumn = fkRel.get("fk_field");
				var childIdColumn = fkRel.get("field");
				var value;
				var _g = new haxe.ds.StringMap();
				if(__map_reserved.childIdColumn != null) _g.setReserved("childIdColumn",childIdColumn); else _g.h["childIdColumn"] = childIdColumn;
				var value1 = fkRel.get("fk_field");
				_g.set("parentIdColumn",value1);
				var value2 = fkRel.get("class");
				_g.set("class",value2);
				value = _g;
				if(__map_reserved[instanceName] != null) syntheticSet.setReserved(instanceName,value); else syntheticSet.h[instanceName] = value;
			}
		}
		var clazzToFieldToIds = new haxe.ds.StringMap();
		var _g1 = 0;
		while(_g1 < models.length) {
			var model = models[_g1];
			++_g1;
			var _g11 = 0;
			var _g2 = modelDef.getFields();
			while(_g11 < _g2.length) {
				var field = _g2[_g11];
				++_g11;
				if(field.indexOf(".") > -1) {
					var parts = field.split(".");
					var instanceName1 = parts[0];
					if(syntheticSet != null && (__map_reserved[instanceName1] != null?syntheticSet.existsReserved(instanceName1):syntheticSet.h.hasOwnProperty(instanceName1))) {
						var lookupField = parts[parts.length - 1];
						var lookupClazz;
						var this1;
						this1 = __map_reserved[instanceName1] != null?syntheticSet.getReserved(instanceName1):syntheticSet.h[instanceName1];
						lookupClazz = this1.get("class");
						var val = Reflect.field(model,field);
						if(val == null || val == "" && !((val | 0) === val)) continue;
						var clazz1 = Type.resolveClass(lookupClazz);
						var cachedObject = this.getObjectFromCache(clazz1,lookupField,val);
						if(cachedObject == null) {
							if(!(function($this) {
								var $r;
								var key = lookupClazz;
								$r = __map_reserved[key] != null?clazzToFieldToIds.existsReserved(key):clazzToFieldToIds.h.hasOwnProperty(key);
								return $r;
							}(this))) {
								var key1 = lookupClazz;
								var value3 = new haxe.ds.StringMap();
								if(__map_reserved[key1] != null) clazzToFieldToIds.setReserved(key1,value3); else clazzToFieldToIds.h[key1] = value3;
							}
							if(!(function($this) {
								var $r;
								var this2;
								{
									var key2 = lookupClazz;
									this2 = __map_reserved[key2] != null?clazzToFieldToIds.getReserved(key2):clazzToFieldToIds.h[key2];
								}
								$r = this2.exists(lookupField);
								return $r;
							}(this))) {
								var this3;
								var key3 = lookupClazz;
								this3 = __map_reserved[key3] != null?clazzToFieldToIds.getReserved(key3):clazzToFieldToIds.h[key3];
								var value4 = new haxe.ds.StringMap();
								this3.set(lookupField,value4);
							}
							var this4;
							var this5;
							var key4 = lookupClazz;
							this5 = __map_reserved[key4] != null?clazzToFieldToIds.getReserved(key4):clazzToFieldToIds.h[key4];
							this4 = this5.get(lookupField);
							this4.set(val,"");
						}
					}
				}
			}
		}
		var batchFetch = new saturn.db.BatchFetch(function(obj,err) {
			cb(err,obj);
		});
		var $it1 = clazzToFieldToIds.keys();
		while( $it1.hasNext() ) {
			var clazzStr = $it1.next();
			var $it2 = (function($this) {
				var $r;
				var this6;
				this6 = __map_reserved[clazzStr] != null?clazzToFieldToIds.getReserved(clazzStr):clazzToFieldToIds.h[clazzStr];
				$r = this6.keys();
				return $r;
			}(this));
			while( $it2.hasNext() ) {
				var fieldStr = $it2.next();
				var valList = [];
				var $it3 = (function($this) {
					var $r;
					var this7;
					{
						var this8;
						this8 = __map_reserved[clazzStr] != null?clazzToFieldToIds.getReserved(clazzStr):clazzToFieldToIds.h[clazzStr];
						this7 = this8.get(fieldStr);
					}
					$r = this7.keys();
					return $r;
				}(this));
				while( $it3.hasNext() ) {
					var val1 = $it3.next();
					valList.push(val1);
				}
				batchFetch.getByIds(valList,Type.resolveClass(clazzStr),"__IGNORE__",null);
			}
		}
		batchFetch.onComplete = function(err1,objs) {
			if(err1 != null) cb(err1,null); else {
				var mappedModels = [];
				var _g4 = 0;
				while(_g4 < models.length) {
					var model1 = models[_g4];
					++_g4;
					var mappedModel = Type.createEmptyInstance(clazz);
					var _g12 = 0;
					var _g21 = modelDef.getFields();
					while(_g12 < _g21.length) {
						var field1 = _g21[_g12];
						++_g12;
						if(field1.indexOf(".") > -1) {
							var parts1 = field1.split(".");
							var instanceName2 = parts1[0];
							if(__map_reserved[instanceName2] != null?syntheticSet.existsReserved(instanceName2):syntheticSet.h.hasOwnProperty(instanceName2)) {
								var lookupField1 = parts1[parts1.length - 1];
								var lookupClazz1;
								var this9;
								this9 = __map_reserved[instanceName2] != null?syntheticSet.getReserved(instanceName2):syntheticSet.h[instanceName2];
								lookupClazz1 = this9.get("class");
								var val2 = Reflect.field(model1,field1);
								if(val2 == null || val2 == "") continue;
								var clazz2 = Type.resolveClass(lookupClazz1);
								var cachedObject1 = _g3.getObjectFromCache(clazz2,lookupField1,val2);
								if(cachedObject1 != null) {
									var idColumn;
									var this10;
									this10 = __map_reserved[instanceName2] != null?syntheticSet.getReserved(instanceName2):syntheticSet.h[instanceName2];
									idColumn = this10.get("parentIdColumn");
									var val3 = Reflect.field(cachedObject1,idColumn);
									if(val3 == null || val3 == "" && !((val3 | 0) === val3)) {
										cb("Unexpected mapping error",mappedModels);
										return;
									}
									var dstColumn;
									var this11;
									this11 = __map_reserved[instanceName2] != null?syntheticSet.getReserved(instanceName2):syntheticSet.h[instanceName2];
									dstColumn = this11.get("childIdColumn");
									Reflect.setField(mappedModel,dstColumn,val3);
								} else {
									cb("Unable to find " + val2,mappedModels);
									return;
								}
							}
						} else {
							var val4 = Reflect.field(model1,field1);
							mappedModel[field1] = val4;
						}
					}
					mappedModels.push(mappedModel);
				}
				cb(null,mappedModels);
			}
		};
		batchFetch.execute();
	}
	,dataBinding: function(enable) {
		this.enableBinding = enable;
	}
	,isDataBinding: function() {
		return this.enableBinding;
	}
	,queryPath: function(fromClazz,queryPath,fieldValue,functionName,cb) {
		var _g = this;
		var parts = queryPath.split(".");
		var fieldName = parts.pop();
		var synthField = parts.pop();
		var model = this.getModel(fromClazz);
		if(model.isSynthetic(synthField)) {
			var fieldDef;
			var this1 = model.getSynthenticFields();
			fieldDef = this1.get(synthField);
			var childClazz = Type.resolveClass(fieldDef.get("class"));
			Reflect.callMethod(this,Reflect.field(this,functionName),[[fieldValue],childClazz,fieldName,function(objs,err) {
				if(err == null) {
					var values = [];
					var _g1 = 0;
					while(_g1 < objs.length) {
						var obj = objs[_g1];
						++_g1;
						values.push(Reflect.field(obj,fieldDef.get("fk_field")));
					}
					var parentField = fieldDef.get("field");
					_g.getByValues(values,fromClazz,parentField,function(objs1,err1) {
						cb(err1,objs1);
					});
				} else cb(err,null);
			}]);
		}
	}
	,setAutoCommit: function(autoCommit,cb) {
		cb("Set auto commit mode ");
	}
	,attach: function(objs,refreshFields,cb) {
		var _g = this;
		var bf = new saturn.db.BatchFetch(function(obj,err) {
			cb(err);
		});
		bf.setProvider(this);
		this._attach(objs,refreshFields,bf);
		bf.onComplete = function() {
			_g.synchronizeInternalLinks(objs);
			cb(null);
		};
		bf.execute();
	}
	,synchronizeInternalLinks: function(objs) {
		if(!this.isDataBinding()) return;
		var _g = 0;
		while(_g < objs.length) {
			var obj = objs[_g];
			++_g;
			var clazz = Type.getClass(obj);
			var model = this.getModel(clazz);
			var synthFields = model.getSynthenticFields();
			if(synthFields != null) {
				var $it0 = synthFields.keys();
				while( $it0.hasNext() ) {
					var synthFieldName = $it0.next();
					var synthField;
					synthField = __map_reserved[synthFieldName] != null?synthFields.getReserved(synthFieldName):synthFields.h[synthFieldName];
					var synthObj = Reflect.field(obj,synthFieldName);
					var field = synthField.get("field");
					var fkField = synthField.get("fk_field");
					if(synthObj != null) {
						if(fkField == null) Reflect.setField(obj,field,synthObj.getValue()); else {
							Reflect.setField(obj,field,Reflect.field(synthObj,fkField));
							this.synchronizeInternalLinks([synthObj]);
						}
					}
				}
			}
		}
	}
	,_attach: function(objs,refreshFields,bf) {
		var _g = 0;
		while(_g < objs.length) {
			var obj = [objs[_g]];
			++_g;
			var clazz = Type.getClass(obj[0]);
			var model = this.getModel(clazz);
			var priField = [model.getPrimaryKey()];
			var secField = model.getFirstKey();
			if(Reflect.field(obj[0],priField[0]) == null || Reflect.field(obj[0],priField[0]) == "") {
				var fieldVal = Reflect.field(obj[0],secField);
				if(fieldVal != null) bf.append(fieldVal,secField,clazz,(function(priField,obj) {
					return function(dbObj) {
						if(refreshFields) {
							var _g1 = 0;
							var _g2 = Reflect.fields(dbObj);
							while(_g1 < _g2.length) {
								var field = _g2[_g1];
								++_g1;
								Reflect.setField(obj[0],field,Reflect.field(dbObj,field));
							}
						} else Reflect.setField(obj[0],priField[0],Reflect.field(dbObj,priField[0]));
					};
				})(priField,obj));
			}
			var synthFields = model.getSynthenticFields();
			if(synthFields != null) {
				var $it0 = synthFields.keys();
				while( $it0.hasNext() ) {
					var synthFieldName = $it0.next();
					var synthField;
					synthField = __map_reserved[synthFieldName] != null?synthFields.getReserved(synthFieldName):synthFields.h[synthFieldName];
					var synthObj = Reflect.field(obj[0],synthFieldName);
					if(synthObj != null) this._attach([synthObj],refreshFields,bf);
				}
			}
		}
	}
	,getQuery: function() {
		var query = new saturn.db.query_lang.Query(this);
		return query;
	}
	,getProviderType: function() {
		return "NONE";
	}
	,isAttached: function(obj) {
		var model = this.getModel(Type.getClass(obj));
		var priField = model.getPrimaryKey();
		var val = Reflect.field(obj,priField);
		if(val == null || val == "") return false; else return true;
	}
	,insertOrUpdate: function(objs,cb,autoAttach) {
		if(autoAttach == null) autoAttach = false;
		var _g1 = this;
		var run = function() {
			var insertList = [];
			var updateList = [];
			var _g = 0;
			while(_g < objs.length) {
				var obj = objs[_g];
				++_g;
				if(!_g1.isAttached(obj)) insertList.push(obj); else updateList.push(obj);
			}
			if(insertList.length > 0) _g1.insertObjects(insertList,function(err) {
				if(err == null && updateList.length > 0) _g1.updateObjects(updateList,cb); else cb(err);
			}); else if(updateList.length > 0) _g1.updateObjects(updateList,cb);
		};
		if(autoAttach) this.attach(objs,false,function(err1) {
			if(err1 == null) run(); else cb(err1);
		}); else run();
	}
	,uploadFile: function(contents,file_identifier,cb) {
		return null;
	}
	,__class__: saturn.db.DefaultProvider
};
saturn.db.NamedQueryCache = $hxClasses["saturn.db.NamedQueryCache"] = function() {
};
saturn.db.NamedQueryCache.__name__ = ["saturn","db","NamedQueryCache"];
saturn.db.NamedQueryCache.prototype = {
	queryName: null
	,queryParamSerial: null
	,queryParams: null
	,queryResults: null
	,__class__: saturn.db.NamedQueryCache
};
saturn.db.Model = $hxClasses["saturn.db.Model"] = function(model,name) {
	this.customSearchFunctionPath = null;
	this.theModel = model;
	this.theName = name;
	this.alias = "";
	this.actionMap = new haxe.ds.StringMap();
	if(this.theModel.exists("indexes")) {
		var i = 0;
		var $it0 = (function($this) {
			var $r;
			var this1 = $this.theModel.get("indexes");
			$r = this1.keys();
			return $r;
		}(this));
		while( $it0.hasNext() ) {
			var keyName = $it0.next();
			if(i == 0) this.busSingleColKey = keyName;
			if((function($this) {
				var $r;
				var this2 = $this.theModel.get("indexes");
				$r = this2.get(keyName);
				return $r;
			}(this))) this.priColKey = keyName;
			i++;
		}
	}
	if(this.theModel.exists("provider_name")) {
		var name1;
		name1 = js.Boot.__cast(this.theModel.get("provider_name") , String);
		this.setProviderName(name1);
	}
	if(this.theModel.exists("programs")) {
		this.programs = [];
		var $it1 = (function($this) {
			var $r;
			var this3 = $this.theModel.get("programs");
			$r = this3.keys();
			return $r;
		}(this));
		while( $it1.hasNext() ) {
			var program = $it1.next();
			this.programs.push(program);
		}
	}
	this.stripIdPrefix = false;
	this.autoActivate = -1;
	if(this.theModel.exists("options")) {
		var options = this.theModel.get("options");
		if(__map_reserved.id_pattern != null?options.existsReserved("id_pattern"):options.h.hasOwnProperty("id_pattern")) this.setIdRegEx(__map_reserved.id_pattern != null?options.getReserved("id_pattern"):options.h["id_pattern"]);
		if(__map_reserved.custom_search_function != null?options.existsReserved("custom_search_function"):options.h.hasOwnProperty("custom_search_function")) this.customSearchFunctionPath = __map_reserved.custom_search_function != null?options.getReserved("custom_search_function"):options.h["custom_search_function"];
		if(__map_reserved.constraints != null?options.existsReserved("constraints"):options.h.hasOwnProperty("constraints")) {
			if((__map_reserved.constraints != null?options.getReserved("constraints"):options.h["constraints"]).exists("user_constraint_field")) this.userConstraintField = (__map_reserved.constraints != null?options.getReserved("constraints"):options.h["constraints"]).get("user_constraint_field");
			if((__map_reserved.constraints != null?options.getReserved("constraints"):options.h["constraints"]).exists("public_constraint_field")) this.publicConstraintField = (__map_reserved.constraints != null?options.getReserved("constraints"):options.h["constraints"]).get("public_constraint_field");
		}
		if(__map_reserved.windows_allowed_paths != null?options.getReserved("windows_allowed_paths"):options.h["windows_allowed_paths"]) {
			var value = this.compileRegEx(__map_reserved.windows_allowed_paths != null?options.getReserved("windows_allowed_paths"):options.h["windows_allowed_paths"]);
			options.set("windows_allowed_paths_regex",value);
		}
		if(__map_reserved.linux_allowed_paths != null?options.getReserved("linux_allowed_paths"):options.h["linux_allowed_paths"]) {
			var value1 = this.compileRegEx(__map_reserved.linux_allowed_paths != null?options.getReserved("linux_allowed_paths"):options.h["linux_allowed_paths"]);
			options.set("linux_allowed_paths_regex",value1);
		}
		if(__map_reserved.strip_id_prefix != null?options.existsReserved("strip_id_prefix"):options.h.hasOwnProperty("strip_id_prefix")) this.stripIdPrefix = __map_reserved.strip_id_prefix != null?options.getReserved("strip_id_prefix"):options.h["strip_id_prefix"];
		if(__map_reserved.alias != null?options.existsReserved("alias"):options.h.hasOwnProperty("alias")) this.alias = __map_reserved.alias != null?options.getReserved("alias"):options.h["alias"];
		if(__map_reserved.flags != null?options.existsReserved("flags"):options.h.hasOwnProperty("flags")) this.flags = __map_reserved.flags != null?options.getReserved("flags"):options.h["flags"]; else this.flags = new haxe.ds.StringMap();
		if(__map_reserved["file.new.label"] != null?options.existsReserved("file.new.label"):options.h.hasOwnProperty("file.new.label")) this.file_new_label = __map_reserved["file.new.label"] != null?options.getReserved("file.new.label"):options.h["file.new.label"];
		if(__map_reserved.auto_activate != null?options.existsReserved("auto_activate"):options.h.hasOwnProperty("auto_activate")) this.autoActivate = Std.parseInt(__map_reserved.auto_activate != null?options.getReserved("auto_activate"):options.h["auto_activate"]);
		if(__map_reserved.actions != null?options.existsReserved("actions"):options.h.hasOwnProperty("actions")) {
			var actionTypeMap;
			actionTypeMap = __map_reserved.actions != null?options.getReserved("actions"):options.h["actions"];
			var $it2 = actionTypeMap.keys();
			while( $it2.hasNext() ) {
				var actionType = $it2.next();
				var actions;
				actions = __map_reserved[actionType] != null?actionTypeMap.getReserved(actionType):actionTypeMap.h[actionType];
				var value2 = new haxe.ds.StringMap();
				this.actionMap.set(actionType,value2);
				var $it3 = actions.keys();
				while( $it3.hasNext() ) {
					var actionName = $it3.next();
					var actionDef;
					actionDef = __map_reserved[actionName] != null?actions.getReserved(actionName):actions.h[actionName];
					if(!(__map_reserved.user_suffix != null?actionDef.existsReserved("user_suffix"):actionDef.h.hasOwnProperty("user_suffix"))) throw new js._Boot.HaxeError(new saturn.util.HaxeException(actionName + " action definition for " + this.getName() + " is missing user_suffix option"));
					if(!(__map_reserved["function"] != null?actionDef.existsReserved("function"):actionDef.h.hasOwnProperty("function"))) throw new js._Boot.HaxeError(new saturn.util.HaxeException(actionName + " action definition for " + this.getName() + " is missing function option"));
					var action = new saturn.db.ModelAction(actionName,__map_reserved.user_suffix != null?actionDef.getReserved("user_suffix"):actionDef.h["user_suffix"],__map_reserved["function"] != null?actionDef.getReserved("function"):actionDef.h["function"],__map_reserved.icon != null?actionDef.getReserved("icon"):actionDef.h["icon"]);
					if(actionType == "search_bar") {
						var clazz = Type.resolveClass(action.className);
						if(clazz == null) throw new js._Boot.HaxeError(new saturn.util.HaxeException(action.className + " does not exist for action " + actionName));
						var instanceFields = Type.getInstanceFields(clazz);
						var match = false;
						var _g = 0;
						while(_g < instanceFields.length) {
							var field = instanceFields[_g];
							++_g;
							if(field == action.functionName) {
								match = true;
								break;
							}
						}
						if(!match) throw new js._Boot.HaxeError(new saturn.util.HaxeException(action.className + " does not have function " + action.functionName + " for action " + actionName));
					}
					var this4 = this.actionMap.get(actionType);
					this4.set(actionName,action);
				}
			}
		}
	} else {
		this.flags = new haxe.ds.StringMap();
		var value3 = new haxe.ds.StringMap();
		this.actionMap.set("searchBar",value3);
	}
	if(this.theModel.exists("search")) {
		var fts = this.theModel.get("search");
		this.ftsColumns = new haxe.ds.StringMap();
		var $it4 = fts.keys();
		while( $it4.hasNext() ) {
			var key = $it4.next();
			var searchDef;
			searchDef = __map_reserved[key] != null?fts.getReserved(key):fts.h[key];
			var searchObj = new saturn.db.SearchDef();
			if(searchDef != null) {
				if(typeof(searchDef) == "boolean" && searchDef) this.ftsColumns.set(key,searchObj); else if(typeof(searchDef) == "string") searchObj.regex = new EReg(searchDef,""); else {
					if(searchDef.exists("search_when")) {
						var regexStr = searchDef.get("search_when");
						if(regexStr != null && regexStr != "") searchObj.regex = new EReg(regexStr,"");
					}
					if(searchDef.exists("replace_with")) searchObj.replaceWith = searchDef.get("replace_with");
				}
			}
			this.ftsColumns.set(key,searchObj);
		}
	}
	if(this.alias == null || this.alias == "") this.alias = this.theName;
};
saturn.db.Model.__name__ = ["saturn","db","Model"];
saturn.db.Model.prototype = {
	theModel: null
	,theName: null
	,busSingleColKey: null
	,priColKey: null
	,idRegEx: null
	,stripIdPrefix: null
	,file_new_label: null
	,ftsColumns: null
	,alias: null
	,programs: null
	,flags: null
	,autoActivate: null
	,actionMap: null
	,providerName: null
	,publicConstraintField: null
	,userConstraintField: null
	,customSearchFunctionPath: null
	,setProviderName: function(name) {
		this.providerName = name;
	}
	,getAutoActivateLevel: function() {
		return this.autoActivate;
	}
	,hasFlag: function(flag) {
		if(this.flags.exists(flag)) return this.flags.get(flag); else return false;
	}
	,getPrograms: function() {
		return this.programs;
	}
	,getOptions: function() {
		return this.theModel.get("options");
	}
	,compileRegEx: function(regexs) {
		var cregexs = new haxe.ds.StringMap();
		var $it0 = regexs.keys();
		while( $it0.hasNext() ) {
			var key = $it0.next();
			var regex;
			regex = __map_reserved[key] != null?regexs.getReserved(key):regexs.h[key];
			if(regex != "") {
				var value = new EReg(regex,"");
				if(__map_reserved[key] != null) cregexs.setReserved(key,value); else cregexs.h[key] = value;
			}
		}
		return cregexs;
	}
	,setIdRegEx: function(idRegExStr) {
		this.idRegEx = new EReg(idRegExStr,"");
	}
	,getFields: function() {
		var fields = [];
		var $it0 = (function($this) {
			var $r;
			var this1 = $this.theModel.get("model");
			$r = this1.iterator();
			return $r;
		}(this));
		while( $it0.hasNext() ) {
			var field = $it0.next();
			fields.push(field);
		}
		return fields;
	}
	,getAttributes: function() {
		var fields = [];
		if(this.theModel.exists("fields")) {
			var $it0 = (function($this) {
				var $r;
				var this1 = $this.theModel.get("fields");
				$r = this1.keys();
				return $r;
			}(this));
			while( $it0.hasNext() ) {
				var field = $it0.next();
				fields.push(field);
			}
		}
		return fields;
	}
	,modelAtrributeToRDBMS: function(field) {
		var this1 = this.theModel.get("fields");
		return this1.get(field);
	}
	,getSynthenticFields: function() {
		return this.theModel.get("fields.synthetic");
	}
	,isSyntheticallyBound: function(fieldName) {
		var synthFields = this.theModel.get("fields.synthetic");
		if(synthFields != null) {
			var $it0 = synthFields.keys();
			while( $it0.hasNext() ) {
				var syntheticFieldName = $it0.next();
				if((__map_reserved[syntheticFieldName] != null?synthFields.getReserved(syntheticFieldName):synthFields.h[syntheticFieldName]).get("field") == fieldName) return true;
			}
		}
		return false;
	}
	,isSynthetic: function(fieldName) {
		if(this.theModel.exists("fields.synthetic")) {
			var this1 = this.theModel.get("fields.synthetic");
			return this1.exists(fieldName);
		} else return false;
	}
	,getClass: function() {
		return Type.resolveClass(this.theName);
	}
	,getFirstKey: function() {
		return this.busSingleColKey;
	}
	,getPrimaryKey: function() {
		return this.priColKey;
	}
	,getName: function() {
		return this.theName;
	}
	,getPrimaryKey_rdbms: function() {
		var this1 = this.theModel.get("fields");
		var key = this.getPrimaryKey();
		return this1.get(key);
	}
	,__class__: saturn.db.Model
};
saturn.db.SearchDef = $hxClasses["saturn.db.SearchDef"] = function() {
	this.replaceWith = null;
	this.regex = null;
};
saturn.db.SearchDef.__name__ = ["saturn","db","SearchDef"];
saturn.db.SearchDef.prototype = {
	regex: null
	,replaceWith: null
	,__class__: saturn.db.SearchDef
};
saturn.db.ModelAction = $hxClasses["saturn.db.ModelAction"] = function(name,userSuffix,qName,icon) {
	this.name = name;
	this.userSuffix = userSuffix;
	this.setQualifiedName(qName);
	this.icon = icon;
};
saturn.db.ModelAction.__name__ = ["saturn","db","ModelAction"];
saturn.db.ModelAction.prototype = {
	name: null
	,userSuffix: null
	,functionName: null
	,className: null
	,icon: null
	,setQualifiedName: function(qName) {
		var i = qName.lastIndexOf(".");
		this.functionName = qName.substring(i + 1,qName.length);
		this.className = qName.substring(0,i);
	}
	,__class__: saturn.db.ModelAction
};
saturn.db.NodeProvider = $hxClasses["saturn.db.NodeProvider"] = function(models) {
	var _g = this;
	saturn.db.DefaultProvider.call(this,models,null,false);
	var app = saturn.client.WorkspaceApplication.getApplication();
	saturn.client.core.ClientCore.getClientCore().registerResponse("_data_receive_objects");
	saturn.client.core.ClientCore.getClientCore().registerResponse("_data_receive_objects_by_class");
	saturn.client.core.ClientCore.getClientCore().registerResponse("_data_receive_insert_response");
	saturn.client.core.ClientCore.getClientCore().registerResponse("_data_receive_update_response");
	saturn.client.core.ClientCore.getClientCore().registerResponse("_data_receive_delete_response");
	saturn.client.core.ClientCore.getClientCore().registerResponse("_data_commit_response");
	saturn.client.core.ClientCore.getClientCore().registerResponse("_error_receive");
	if(models == null) this.requestModels(function(models1,err) {
		if(err != null) saturn.core.Util.debug("Error retrieving model definitions from server"); else {
			saturn.core.Util.debug("Models retrieved");
			_g.setModels(models1);
			var models2 = _g.getModelClasses();
			saturn.core.Util.debug("Models configured: " + models2.length);
			if(app != null) {
				var _g1 = 0;
				while(_g1 < models2.length) {
					var model = models2[_g1];
					++_g1;
					var programs = model.getPrograms();
					if(programs != null) {
						var _g2 = 0;
						while(_g2 < programs.length) {
							var program = programs[_g2];
							++_g2;
							saturn.core.Util.debug("Registering " + program + "/" + model.getName());
							app.getProgramRegistry().openWith(Type.resolveClass(program),true,Type.resolveClass(model.getName()));
						}
					} else saturn.core.Util.debug("No programs for " + model.getName());
				}
				app.makeAliasesAvailable();
			}
			if(app != null) {
				if(_g.getModel(app == null?null:js.Boot.getClass(app)).hasFlag("NO_LOGIN")) {
					var u = new saturn.core.User();
					u.fullname = "SQLite";
					saturn.core.Util.debug("NO_LOGIN flag found");
					saturn.client.core.ClientCore.getClientCore().disableLogout();
					saturn.client.core.ClientCore.getClientCore().setLoggedIn(u);
				}
			}
			_g.getByNamedQuery("saturn.server.plugins.core.ConfigurationPlugin:clientConfiguration",[],null,false,function(config,err1) {
				if(err1 == null) {
					if(Object.prototype.hasOwnProperty.call(config,"connections")) {
						var connectionConfigs = Reflect.field(config,"connections");
						var _g11 = 0;
						while(_g11 < connectionConfigs.length) {
							var connectionConfig = connectionConfigs[_g11];
							++_g11;
							if(Object.prototype.hasOwnProperty.call(connectionConfig,"name")) {
								var name = Reflect.field(connectionConfig,"name");
								if(name == "DEFAULT") {
									if(Object.prototype.hasOwnProperty.call(connectionConfig,"named_query_hooks")) _g.addHooks(Reflect.field(connectionConfig,"named_query_hooks"));
								}
							}
						}
					} else {
					}
					saturn.client.core.ClientCore.getClientCore().providerUp();
				}
			});
		}
	});
};
saturn.db.NodeProvider.__name__ = ["saturn","db","NodeProvider"];
saturn.db.NodeProvider.__super__ = saturn.db.DefaultProvider;
saturn.db.NodeProvider.prototype = $extend(saturn.db.DefaultProvider.prototype,{
	hxSerialize: function(s) {
	}
	,hxUnserialize: function(u) {
	}
	,requestModels: function(cb) {
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._request_models",d,function(data,err) {
			if(err != null) cb(null,err); else {
				var models = haxe.Unserializer.run(data.json.models);
				cb(models,null);
			}
		});
	}
	,_getByIds: function(ids,clazz,cb) {
		var _g = this;
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		d.class_name = Type.getClassName(clazz);
		d.ids = ids;
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_request_objects_ids",d,function(data,err) {
			if(data.json != null) cb(_g.parseObjects(data.json.objects),err); else cb([],err);
		});
	}
	,_getByValues: function(values,clazz,field,cb) {
		var _g = this;
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		d.class_name = Type.getClassName(clazz);
		d.values = values;
		d.field = field;
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_request_objects_values",d,function(data,err) {
			if(data.json != null) cb(_g.parseObjects(data.json.objects),err); else cb([],err);
		});
	}
	,_getByPkeys: function(ids,clazz,cb) {
		var _g = this;
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		d.class_name = Type.getClassName(clazz);
		d.ids = ids;
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_request_objects_pkeys",d,function(data,err) {
			if(data.json != null) cb(_g.parseObjects(data.json.objects),err); else cb([],err);
		});
	}
	,_getByIdStartsWith: function(id,field,clazz,limit,cb) {
		var _g = this;
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		d.class_name = Type.getClassName(clazz);
		d.id = id;
		d.limit = limit;
		if(field == null) d.field = null; else {
			var model = this.getModel(clazz);
			d.field = model.modelAtrributeToRDBMS(field);
		}
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_request_objects_idstartswith",d,function(data,err) {
			if(data.json != null) cb(_g.parseObjects(data.json.objects),err); else cb([],err);
		});
	}
	,_query: function(query,cb) {
		var _g = this;
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		d.queryStr = query.serialise();
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_request_query",d,function(data,err) {
			if(data.json != null) cb(_g.parseObjects(data.json.objects),err); else cb([],err);
		});
	}
	,_getByNamedQuery: function(queryId,parameters,clazz,cb) {
		var _g = this;
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		if(clazz != null) d.class_name = Type.getClassName(clazz);
		d.queryId = queryId;
		d.parameters = haxe.Serializer.run(parameters);
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_request_objects_namedquery",d,function(data,err) {
			if(data.json != null) cb(_g.parseObjects(data.json.objects),err); else cb([],err);
		});
	}
	,_getObjects: function(clazz,cb) {
		var _g = this;
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		d.class_name = Type.getClassName(clazz);
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_request_objects_by_class",d,function(data,err) {
			if(data.json != null) cb(_g.parseObjects(data.json.objects),err); else cb([],err);
		});
	}
	,_update: function(attributeMaps,className,cb) {
		this.updateOrInsert("_remote_provider_._data_update_request",attributeMaps,className,cb);
	}
	,_insert: function(attributeMaps,className,cb) {
		this.updateOrInsert("_remote_provider_._data_insert_request",attributeMaps,className,cb);
	}
	,updateOrInsert: function(msg,attributeMaps,className,cb) {
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		d.class_name = className;
		var objs = [];
		var _g = 0;
		while(_g < attributeMaps.length) {
			var atMap = attributeMaps[_g];
			++_g;
			var obj = { };
			var $it0 = atMap.keys();
			while( $it0.hasNext() ) {
				var key = $it0.next();
				Reflect.setField(obj,key,__map_reserved[key] != null?atMap.getReserved(key):atMap.h[key]);
			}
			objs.push(obj);
		}
		d.objs = JSON.stringify(objs);
		saturn.client.core.ClientCore.getClientCore().sendRequest(msg,d,function(data,err) {
			cb(err);
		});
	}
	,_delete: function(attributeMaps,className,cb) {
		var model = this.getModelByStringName(className);
		var objPkeys = [];
		var priField = model.getPrimaryKey_rdbms();
		var d = { };
		d.class_name = className;
		var objs = [];
		var _g = 0;
		while(_g < attributeMaps.length) {
			var atMap = attributeMaps[_g];
			++_g;
			var obj = { };
			Reflect.setField(obj,priField,__map_reserved[priField] != null?atMap.getReserved(priField):atMap.h[priField]);
			objs.push(obj);
		}
		d.objs = JSON.stringify(objs);
		var d2 = attributeMaps;
		window.console.log(d2);
		var app = saturn.client.WorkspaceApplication.getApplication();
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_delete_request",d,function(data,err) {
			cb(err);
		});
	}
	,_rollback: function(cb) {
		cb("Updating not supported on server");
	}
	,_commit: function(cb) {
		var app = saturn.client.WorkspaceApplication.getApplication();
		var d = { };
		saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_commit_request",d,function(data,err) {
			cb(err);
		});
	}
	,parseObjects: function(data) {
		if(data != null) {
			var _g = 0;
			while(_g < data.length) {
				var item = data[_g];
				++_g;
				this.bindObject(item,null,false);
			}
		}
		return data;
	}
	,uploadFile: function(contents,file_identifier,cb) {
		return saturn.client.core.ClientCore.getClientCore().sendRequest("_remote_provider_._data_request_upload_file",{ 'contents' : contents, 'file_identifier' : file_identifier},function(data,err) {
			if(data.json != null) {
				Reflect.setField((function($this) {
					var $r;
					var this1 = saturn.client.core.ClientCore.getClientCore().msgIdToJobInfo;
					$r = this1.get(data.msgId);
					return $r;
				}(this)),"file_identifier",data.json.upload_id);
				cb(err,data.json.upload_id);
			} else cb(err,null);
		});
	}
	,__class__: saturn.db.NodeProvider
});
saturn.db.Pool = $hxClasses["saturn.db.Pool"] = function() { };
saturn.db.Pool.__name__ = ["saturn","db","Pool"];
saturn.db.Pool.prototype = {
	acquire: null
	,release: null
	,__class__: saturn.db.Pool
};
if(!saturn.db.query_lang) saturn.db.query_lang = {};
saturn.db.query_lang.Token = $hxClasses["saturn.db.query_lang.Token"] = function(tokens) {
	this.tokens = tokens;
	if(this.tokens != null) {
		var _g1 = 0;
		var _g = this.tokens.length;
		while(_g1 < _g) {
			var i = _g1++;
			var value = this.tokens[i];
			if(value != null) {
				if(!js.Boot.__instanceof(value,saturn.db.query_lang.Token)) this.tokens[i] = new saturn.db.query_lang.Value(value);
			}
		}
	}
};
saturn.db.query_lang.Token.__name__ = ["saturn","db","query_lang","Token"];
saturn.db.query_lang.Token.prototype = {
	tokens: null
	,name: null
	,getTokens: function() {
		return this.tokens;
	}
	,setTokens: function(tokens) {
		this.tokens = tokens;
	}
	,addToken: function(token) {
		if(this.tokens == null) this.tokens = [];
		this.tokens.push(token);
		return this;
	}
	,__class__: saturn.db.query_lang.Token
};
saturn.db.query_lang.Operator = $hxClasses["saturn.db.query_lang.Operator"] = function(token) {
	if(token != null) saturn.db.query_lang.Token.call(this,[token]); else saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.Operator.__name__ = ["saturn","db","query_lang","Operator"];
saturn.db.query_lang.Operator.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.Operator.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.Operator
});
saturn.db.query_lang.And = $hxClasses["saturn.db.query_lang.And"] = function() {
	saturn.db.query_lang.Operator.call(this,null);
};
saturn.db.query_lang.And.__name__ = ["saturn","db","query_lang","And"];
saturn.db.query_lang.And.__super__ = saturn.db.query_lang.Operator;
saturn.db.query_lang.And.prototype = $extend(saturn.db.query_lang.Operator.prototype,{
	__class__: saturn.db.query_lang.And
});
saturn.db.query_lang.ClassToken = $hxClasses["saturn.db.query_lang.ClassToken"] = function(clazz) {
	this.setClass(clazz);
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.ClassToken.__name__ = ["saturn","db","query_lang","ClassToken"];
saturn.db.query_lang.ClassToken.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.ClassToken.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	clazz: null
	,getClass: function() {
		return this.clazz;
	}
	,setClass: function(clazz) {
		if(js.Boot.__instanceof(clazz,Class)) {
			var c;
			c = js.Boot.__cast(clazz , Class);
			this.clazz = Type.getClassName(c);
		} else this.clazz = clazz;
	}
	,__class__: saturn.db.query_lang.ClassToken
});
saturn.db.query_lang.EndBlock = $hxClasses["saturn.db.query_lang.EndBlock"] = function() {
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.EndBlock.__name__ = ["saturn","db","query_lang","EndBlock"];
saturn.db.query_lang.EndBlock.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.EndBlock.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.EndBlock
});
saturn.db.query_lang.Equals = $hxClasses["saturn.db.query_lang.Equals"] = function(token) {
	saturn.db.query_lang.Operator.call(this,token);
};
saturn.db.query_lang.Equals.__name__ = ["saturn","db","query_lang","Equals"];
saturn.db.query_lang.Equals.__super__ = saturn.db.query_lang.Operator;
saturn.db.query_lang.Equals.prototype = $extend(saturn.db.query_lang.Operator.prototype,{
	__class__: saturn.db.query_lang.Equals
});
saturn.db.query_lang.Field = $hxClasses["saturn.db.query_lang.Field"] = function(clazz,attributeName,clazzAlias) {
	this.setClass(clazz);
	this.attributeName = attributeName;
	this.clazzAlias = clazzAlias;
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.Field.__name__ = ["saturn","db","query_lang","Field"];
saturn.db.query_lang.Field.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.Field.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	clazz: null
	,clazzAlias: null
	,attributeName: null
	,getClass: function() {
		return this.clazz;
	}
	,setClass: function(clazz) {
		if(js.Boot.__instanceof(clazz,Class)) {
			var c;
			c = js.Boot.__cast(clazz , Class);
			this.clazz = Type.getClassName(c);
		} else this.clazz = clazz;
	}
	,__class__: saturn.db.query_lang.Field
});
saturn.db.query_lang.From = $hxClasses["saturn.db.query_lang.From"] = function() {
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.From.__name__ = ["saturn","db","query_lang","From"];
saturn.db.query_lang.From.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.From.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.From
});
saturn.db.query_lang.GreaterThan = $hxClasses["saturn.db.query_lang.GreaterThan"] = function(token) {
	saturn.db.query_lang.Operator.call(this,token);
};
saturn.db.query_lang.GreaterThan.__name__ = ["saturn","db","query_lang","GreaterThan"];
saturn.db.query_lang.GreaterThan.__super__ = saturn.db.query_lang.Operator;
saturn.db.query_lang.GreaterThan.prototype = $extend(saturn.db.query_lang.Operator.prototype,{
	__class__: saturn.db.query_lang.GreaterThan
});
saturn.db.query_lang.Group = $hxClasses["saturn.db.query_lang.Group"] = function() {
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.Group.__name__ = ["saturn","db","query_lang","Group"];
saturn.db.query_lang.Group.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.Group.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.Group
});
saturn.db.query_lang.IsNotNull = $hxClasses["saturn.db.query_lang.IsNotNull"] = function() {
	saturn.db.query_lang.Operator.call(this,null);
};
saturn.db.query_lang.IsNotNull.__name__ = ["saturn","db","query_lang","IsNotNull"];
saturn.db.query_lang.IsNotNull.__super__ = saturn.db.query_lang.Operator;
saturn.db.query_lang.IsNotNull.prototype = $extend(saturn.db.query_lang.Operator.prototype,{
	__class__: saturn.db.query_lang.IsNotNull
});
saturn.db.query_lang.IsNull = $hxClasses["saturn.db.query_lang.IsNull"] = function() {
	saturn.db.query_lang.Operator.call(this,null);
};
saturn.db.query_lang.IsNull.__name__ = ["saturn","db","query_lang","IsNull"];
saturn.db.query_lang.IsNull.__super__ = saturn.db.query_lang.Operator;
saturn.db.query_lang.IsNull.prototype = $extend(saturn.db.query_lang.Operator.prototype,{
	__class__: saturn.db.query_lang.IsNull
});
saturn.db.query_lang.Limit = $hxClasses["saturn.db.query_lang.Limit"] = function(limit) {
	saturn.db.query_lang.Token.call(this,[limit]);
};
saturn.db.query_lang.Limit.__name__ = ["saturn","db","query_lang","Limit"];
saturn.db.query_lang.Limit.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.Limit.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.Limit
});
saturn.db.query_lang.OrderBy = $hxClasses["saturn.db.query_lang.OrderBy"] = function() {
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.OrderBy.__name__ = ["saturn","db","query_lang","OrderBy"];
saturn.db.query_lang.OrderBy.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.OrderBy.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.OrderBy
});
saturn.db.query_lang.OrderByItem = $hxClasses["saturn.db.query_lang.OrderByItem"] = function(token,descending) {
	if(descending == null) descending = false;
	this.descending = false;
	this.descending = descending;
	saturn.db.query_lang.Token.call(this,[token]);
};
saturn.db.query_lang.OrderByItem.__name__ = ["saturn","db","query_lang","OrderByItem"];
saturn.db.query_lang.OrderByItem.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.OrderByItem.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	descending: null
	,__class__: saturn.db.query_lang.OrderByItem
});
saturn.db.query_lang.Query = $hxClasses["saturn.db.query_lang.Query"] = function(provider) {
	saturn.db.query_lang.Token.call(this,null);
	this.provider = provider;
	this.selectToken = new saturn.db.query_lang.Select();
	this.whereToken = new saturn.db.query_lang.Where();
	this.fromToken = new saturn.db.query_lang.From();
	this.groupToken = new saturn.db.query_lang.Group();
	this.orderToken = new saturn.db.query_lang.OrderBy();
};
saturn.db.query_lang.Query.__name__ = ["saturn","db","query_lang","Query"];
saturn.db.query_lang.Query.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.Query.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	selectToken: null
	,fromToken: null
	,whereToken: null
	,groupToken: null
	,orderToken: null
	,provider: null
	,rawResults: null
	,pageOn: null
	,pageSize: null
	,lastPagedRowValue: null
	,isPaging: function() {
		return this.pageOn != null && this.pageSize != null;
	}
	,bindResults: function() {
		return !this.rawResults;
	}
	,getTokens: function() {
		var tokens = [];
		var checkTokens = [this.selectToken,this.whereToken];
		var _g = 0;
		while(_g < checkTokens.length) {
			var token = checkTokens[_g];
			++_g;
			this.addClassToken(token);
		}
		if(this.fromToken.getTokens() != null) {
			var seen = new haxe.ds.StringMap();
			var tokens1 = [];
			var _g1 = 0;
			var _g11 = this.fromToken.getTokens();
			while(_g1 < _g11.length) {
				var token1 = _g11[_g1];
				++_g1;
				if(js.Boot.__instanceof(token1,saturn.db.query_lang.ClassToken)) {
					var cToken;
					cToken = js.Boot.__cast(token1 , saturn.db.query_lang.ClassToken);
					if(cToken.getClass() != null) {
						var clazzName = cToken.getClass();
						if(!(__map_reserved[clazzName] != null?seen.existsReserved(clazzName):seen.h.hasOwnProperty(clazzName))) {
							tokens1.push(cToken);
							if(__map_reserved[clazzName] != null) seen.setReserved(clazzName,""); else seen.h[clazzName] = "";
						}
					} else tokens1.push(cToken);
				} else tokens1.push(token1);
			}
			this.fromToken.setTokens(tokens1);
			saturn.core.Util.print("Num targets" + this.fromToken.getTokens().length);
		}
		tokens.push(this.selectToken);
		tokens.push(this.fromToken);
		if(this.whereToken.getTokens() != null && this.whereToken.getTokens().length > 0) {
			tokens.push(this.whereToken);
			if(this.isPaging() && this.lastPagedRowValue != null) {
				tokens.push(new saturn.db.query_lang.And());
				tokens.push(this.pageOn);
				tokens.push(new saturn.db.query_lang.GreaterThan());
				tokens.push(this.lastPagedRowValue);
			}
		}
		if(this.groupToken.getTokens() != null && this.groupToken.getTokens().length > 0) tokens.push(this.groupToken);
		if(this.orderToken.getTokens() != null && this.orderToken.getTokens().length > 0) tokens.push(this.orderToken);
		if(this.isPaging()) {
			tokens.push(new saturn.db.query_lang.OrderBy());
			tokens.push(new saturn.db.query_lang.OrderByItem(this.pageOn));
			tokens.push(new saturn.db.query_lang.Limit(this.pageSize));
		}
		if(this.tokens != null && this.tokens.length > 0) {
			var _g2 = 0;
			var _g12 = this.tokens;
			while(_g2 < _g12.length) {
				var token2 = _g12[_g2];
				++_g2;
				tokens.push(token2);
			}
		}
		return tokens;
	}
	,getSelect: function() {
		return this.selectToken;
	}
	,getWhere: function() {
		return this.whereToken;
	}
	,serialise: function() {
		var keepMe = this.provider;
		this.provider = null;
		var newMe = haxe.Serializer.run(this);
		this.provider = keepMe;
		return newMe;
	}
	,getSelectClassList: function() {
		var set = new haxe.ds.StringMap();
		var _g = 0;
		var _g1 = this.selectToken.getTokens();
		while(_g < _g1.length) {
			var token = _g1[_g];
			++_g;
			if(js.Boot.__instanceof(token,saturn.db.query_lang.Field)) {
				var cToken;
				cToken = js.Boot.__cast(token , saturn.db.query_lang.Field);
				var clazz = cToken.getClass();
				if(clazz != null) {
					if(__map_reserved[clazz] != null) set.setReserved(clazz,clazz); else set.h[clazz] = clazz;
				}
			}
		}
		var list = [];
		var $it0 = set.keys();
		while( $it0.hasNext() ) {
			var className = $it0.next();
			list.push(__map_reserved[className] != null?set.getReserved(className):set.h[className]);
		}
		return list;
	}
	,addClassToken: function(token) {
		if(js.Boot.__instanceof(token,saturn.db.query_lang.Query) || token == null) return;
		if(js.Boot.__instanceof(token,saturn.db.query_lang.Field)) {
			var fToken;
			fToken = js.Boot.__cast(token , saturn.db.query_lang.Field);
			if(fToken.getClass() != null) {
				var cToken = new saturn.db.query_lang.ClassToken(fToken.getClass());
				if(fToken.clazzAlias != null) cToken.name = fToken.clazzAlias;
				this.fromToken.addToken(cToken);
			}
		}
		if(token.getTokens() != null) {
			var _g = 0;
			var _g1 = token.getTokens();
			while(_g < _g1.length) {
				var token1 = _g1[_g];
				++_g;
				this.addClassToken(token1);
			}
		}
	}
	,addExample: function(obj,fieldList) {
		var clazz = Type.getClass(obj);
		var model = this.provider.getModel(clazz);
		if(fieldList != null) {
			if(fieldList.length > 0) {
				var _g = 0;
				while(_g < fieldList.length) {
					var field = fieldList[_g];
					++_g;
					this.getSelect().addToken(new saturn.db.query_lang.Field(clazz,field));
				}
			}
		} else this.getSelect().addToken(new saturn.db.query_lang.Field(clazz,"*"));
		var fields = model.getFields();
		var hasPrevious = false;
		this.getWhere().addToken(new saturn.db.query_lang.StartBlock());
		var _g1 = 0;
		var _g2 = fields.length;
		while(_g1 < _g2) {
			var i = _g1++;
			var field1 = fields[i];
			var value = Reflect.field(obj,field1);
			if(value != null) {
				if(hasPrevious) this.getWhere().addToken(new saturn.db.query_lang.And());
				this.getWhere().addToken(new saturn.db.query_lang.Field(clazz,field1));
				this.getWhere().addToken(new saturn.db.query_lang.Equals());
				if(js.Boot.__instanceof(value,saturn.db.query_lang.IsNull)) {
					saturn.core.Util.print("Found NULL");
					this.getWhere().addToken(new saturn.db.query_lang.IsNull());
				} else if(js.Boot.__instanceof(value,saturn.db.query_lang.IsNotNull)) this.getWhere().addToken(new saturn.db.query_lang.IsNotNull()); else {
					saturn.core.Util.print("Found value" + Type.getClassName(value == null?null:js.Boot.getClass(value)));
					this.getWhere().addToken(new saturn.db.query_lang.Value(value));
				}
				hasPrevious = true;
			}
		}
		this.getWhere().addToken(new saturn.db.query_lang.EndBlock());
	}
	,__class__: saturn.db.query_lang.Query
});
saturn.db.query_lang.Select = $hxClasses["saturn.db.query_lang.Select"] = function() {
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.Select.__name__ = ["saturn","db","query_lang","Select"];
saturn.db.query_lang.Select.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.Select.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.Select
});
saturn.db.query_lang.StartBlock = $hxClasses["saturn.db.query_lang.StartBlock"] = function() {
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.StartBlock.__name__ = ["saturn","db","query_lang","StartBlock"];
saturn.db.query_lang.StartBlock.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.StartBlock.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.StartBlock
});
saturn.db.query_lang.Value = $hxClasses["saturn.db.query_lang.Value"] = function(value) {
	saturn.db.query_lang.Token.call(this,null);
	this.value = value;
};
saturn.db.query_lang.Value.__name__ = ["saturn","db","query_lang","Value"];
saturn.db.query_lang.Value.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.Value.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	value: null
	,__class__: saturn.db.query_lang.Value
});
saturn.db.query_lang.Where = $hxClasses["saturn.db.query_lang.Where"] = function() {
	saturn.db.query_lang.Token.call(this,null);
};
saturn.db.query_lang.Where.__name__ = ["saturn","db","query_lang","Where"];
saturn.db.query_lang.Where.__super__ = saturn.db.query_lang.Token;
saturn.db.query_lang.Where.prototype = $extend(saturn.db.query_lang.Token.prototype,{
	__class__: saturn.db.query_lang.Where
});
if(!saturn.workflow) saturn.workflow = {};
saturn.workflow.Object = $hxClasses["saturn.workflow.Object"] = function() { };
saturn.workflow.Object.__name__ = ["saturn","workflow","Object"];
saturn.workflow.Object.prototype = {
	error: null
	,getError: function() {
		return this.error;
	}
	,__class__: saturn.workflow.Object
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
$hxClasses.Math = Math;
String.prototype.__class__ = $hxClasses.String = String;
String.__name__ = ["String"];
$hxClasses.Array = Array;
Array.__name__ = ["Array"];
Date.prototype.__class__ = $hxClasses.Date = Date;
Date.__name__ = ["Date"];
var Int = $hxClasses.Int = { __name__ : ["Int"]};
var Dynamic = $hxClasses.Dynamic = { __name__ : ["Dynamic"]};
var Float = $hxClasses.Float = Number;
Float.__name__ = ["Float"];
var Bool = $hxClasses.Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = $hxClasses.Class = { __name__ : ["Class"]};
var Enum = { };
var __map_reserved = {}
var q = window.jQuery;
var js = js || {}
js.JQuery = q;
var ArrayBuffer = $global.ArrayBuffer || js.html.compat.ArrayBuffer;
if(ArrayBuffer.prototype.slice == null) ArrayBuffer.prototype.slice = js.html.compat.ArrayBuffer.sliceImpl;
var DataView = $global.DataView || js.html.compat.DataView;
var Uint8Array = $global.Uint8Array || js.html.compat.Uint8Array._new;
haxe.Serializer.USE_CACHE = false;
haxe.Serializer.USE_ENUM_INDEX = false;
haxe.Serializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
haxe.Unserializer.DEFAULT_RESOLVER = Type;
haxe.Unserializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
haxe.ds.ObjectMap.count = 0;
haxe.io.FPHelper.i64tmp = (function($this) {
	var $r;
	var x = new haxe._Int64.___Int64(0,0);
	$r = x;
	return $r;
}(this));
js.Boot.__toStr = {}.toString;
js.html.compat.Uint8Array.BYTES_PER_ELEMENT = 1;
saturn.client.core.CommonCore.pools = new haxe.ds.StringMap();
saturn.client.core.CommonCore.resourceToPool = new haxe.ds.ObjectMap();
saturn.client.core.CommonCore.providers = new haxe.ds.StringMap();
saturn.client.core.CommonCore.annotationManager = new saturn.core.annotations.AnnotationManager();
saturn.db.DefaultProvider.r_date = new EReg("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.000Z","");
saturn.client.core.ClientCore.main();
