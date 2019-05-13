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
	,replace: function(s,by) {
		return s.replace(this.r,by);
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
haxe.Timer = $hxClasses["haxe.Timer"] = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	};
	return t;
};
haxe.Timer.prototype = {
	id: null
	,stop: function() {
		if(this.id == null) return;
		clearInterval(this.id);
		this.id = null;
	}
	,run: function() {
	}
	,__class__: haxe.Timer
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
if(!haxe.crypto) haxe.crypto = {};
haxe.crypto.Md5 = $hxClasses["haxe.crypto.Md5"] = function() {
};
haxe.crypto.Md5.__name__ = ["haxe","crypto","Md5"];
haxe.crypto.Md5.encode = function(s) {
	var m = new haxe.crypto.Md5();
	var h = m.doEncode(haxe.crypto.Md5.str2blks(s));
	return m.hex(h);
};
haxe.crypto.Md5.str2blks = function(str) {
	var nblk = (str.length + 8 >> 6) + 1;
	var blks = [];
	var blksSize = nblk * 16;
	var _g = 0;
	while(_g < blksSize) {
		var i1 = _g++;
		blks[i1] = 0;
	}
	var i = 0;
	while(i < str.length) {
		blks[i >> 2] |= HxOverrides.cca(str,i) << (str.length * 8 + i) % 4 * 8;
		i++;
	}
	blks[i >> 2] |= 128 << (str.length * 8 + i) % 4 * 8;
	var l = str.length * 8;
	var k = nblk * 16 - 2;
	blks[k] = l & 255;
	blks[k] |= (l >>> 8 & 255) << 8;
	blks[k] |= (l >>> 16 & 255) << 16;
	blks[k] |= (l >>> 24 & 255) << 24;
	return blks;
};
haxe.crypto.Md5.prototype = {
	bitOR: function(a,b) {
		var lsb = a & 1 | b & 1;
		var msb31 = a >>> 1 | b >>> 1;
		return msb31 << 1 | lsb;
	}
	,bitXOR: function(a,b) {
		var lsb = a & 1 ^ b & 1;
		var msb31 = a >>> 1 ^ b >>> 1;
		return msb31 << 1 | lsb;
	}
	,bitAND: function(a,b) {
		var lsb = a & 1 & (b & 1);
		var msb31 = a >>> 1 & b >>> 1;
		return msb31 << 1 | lsb;
	}
	,addme: function(x,y) {
		var lsw = (x & 65535) + (y & 65535);
		var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
		return msw << 16 | lsw & 65535;
	}
	,hex: function(a) {
		var str = "";
		var hex_chr = "0123456789abcdef";
		var _g = 0;
		while(_g < a.length) {
			var num = a[_g];
			++_g;
			var _g1 = 0;
			while(_g1 < 4) {
				var j = _g1++;
				str += hex_chr.charAt(num >> j * 8 + 4 & 15) + hex_chr.charAt(num >> j * 8 & 15);
			}
		}
		return str;
	}
	,rol: function(num,cnt) {
		return num << cnt | num >>> 32 - cnt;
	}
	,cmn: function(q,a,b,x,s,t) {
		return this.addme(this.rol(this.addme(this.addme(a,q),this.addme(x,t)),s),b);
	}
	,ff: function(a,b,c,d,x,s,t) {
		return this.cmn(this.bitOR(this.bitAND(b,c),this.bitAND(~b,d)),a,b,x,s,t);
	}
	,gg: function(a,b,c,d,x,s,t) {
		return this.cmn(this.bitOR(this.bitAND(b,d),this.bitAND(c,~d)),a,b,x,s,t);
	}
	,hh: function(a,b,c,d,x,s,t) {
		return this.cmn(this.bitXOR(this.bitXOR(b,c),d),a,b,x,s,t);
	}
	,ii: function(a,b,c,d,x,s,t) {
		return this.cmn(this.bitXOR(c,this.bitOR(b,~d)),a,b,x,s,t);
	}
	,doEncode: function(x) {
		var a = 1732584193;
		var b = -271733879;
		var c = -1732584194;
		var d = 271733878;
		var step;
		var i = 0;
		while(i < x.length) {
			var olda = a;
			var oldb = b;
			var oldc = c;
			var oldd = d;
			step = 0;
			a = this.ff(a,b,c,d,x[i],7,-680876936);
			d = this.ff(d,a,b,c,x[i + 1],12,-389564586);
			c = this.ff(c,d,a,b,x[i + 2],17,606105819);
			b = this.ff(b,c,d,a,x[i + 3],22,-1044525330);
			a = this.ff(a,b,c,d,x[i + 4],7,-176418897);
			d = this.ff(d,a,b,c,x[i + 5],12,1200080426);
			c = this.ff(c,d,a,b,x[i + 6],17,-1473231341);
			b = this.ff(b,c,d,a,x[i + 7],22,-45705983);
			a = this.ff(a,b,c,d,x[i + 8],7,1770035416);
			d = this.ff(d,a,b,c,x[i + 9],12,-1958414417);
			c = this.ff(c,d,a,b,x[i + 10],17,-42063);
			b = this.ff(b,c,d,a,x[i + 11],22,-1990404162);
			a = this.ff(a,b,c,d,x[i + 12],7,1804603682);
			d = this.ff(d,a,b,c,x[i + 13],12,-40341101);
			c = this.ff(c,d,a,b,x[i + 14],17,-1502002290);
			b = this.ff(b,c,d,a,x[i + 15],22,1236535329);
			a = this.gg(a,b,c,d,x[i + 1],5,-165796510);
			d = this.gg(d,a,b,c,x[i + 6],9,-1069501632);
			c = this.gg(c,d,a,b,x[i + 11],14,643717713);
			b = this.gg(b,c,d,a,x[i],20,-373897302);
			a = this.gg(a,b,c,d,x[i + 5],5,-701558691);
			d = this.gg(d,a,b,c,x[i + 10],9,38016083);
			c = this.gg(c,d,a,b,x[i + 15],14,-660478335);
			b = this.gg(b,c,d,a,x[i + 4],20,-405537848);
			a = this.gg(a,b,c,d,x[i + 9],5,568446438);
			d = this.gg(d,a,b,c,x[i + 14],9,-1019803690);
			c = this.gg(c,d,a,b,x[i + 3],14,-187363961);
			b = this.gg(b,c,d,a,x[i + 8],20,1163531501);
			a = this.gg(a,b,c,d,x[i + 13],5,-1444681467);
			d = this.gg(d,a,b,c,x[i + 2],9,-51403784);
			c = this.gg(c,d,a,b,x[i + 7],14,1735328473);
			b = this.gg(b,c,d,a,x[i + 12],20,-1926607734);
			a = this.hh(a,b,c,d,x[i + 5],4,-378558);
			d = this.hh(d,a,b,c,x[i + 8],11,-2022574463);
			c = this.hh(c,d,a,b,x[i + 11],16,1839030562);
			b = this.hh(b,c,d,a,x[i + 14],23,-35309556);
			a = this.hh(a,b,c,d,x[i + 1],4,-1530992060);
			d = this.hh(d,a,b,c,x[i + 4],11,1272893353);
			c = this.hh(c,d,a,b,x[i + 7],16,-155497632);
			b = this.hh(b,c,d,a,x[i + 10],23,-1094730640);
			a = this.hh(a,b,c,d,x[i + 13],4,681279174);
			d = this.hh(d,a,b,c,x[i],11,-358537222);
			c = this.hh(c,d,a,b,x[i + 3],16,-722521979);
			b = this.hh(b,c,d,a,x[i + 6],23,76029189);
			a = this.hh(a,b,c,d,x[i + 9],4,-640364487);
			d = this.hh(d,a,b,c,x[i + 12],11,-421815835);
			c = this.hh(c,d,a,b,x[i + 15],16,530742520);
			b = this.hh(b,c,d,a,x[i + 2],23,-995338651);
			a = this.ii(a,b,c,d,x[i],6,-198630844);
			d = this.ii(d,a,b,c,x[i + 7],10,1126891415);
			c = this.ii(c,d,a,b,x[i + 14],15,-1416354905);
			b = this.ii(b,c,d,a,x[i + 5],21,-57434055);
			a = this.ii(a,b,c,d,x[i + 12],6,1700485571);
			d = this.ii(d,a,b,c,x[i + 3],10,-1894986606);
			c = this.ii(c,d,a,b,x[i + 10],15,-1051523);
			b = this.ii(b,c,d,a,x[i + 1],21,-2054922799);
			a = this.ii(a,b,c,d,x[i + 8],6,1873313359);
			d = this.ii(d,a,b,c,x[i + 15],10,-30611744);
			c = this.ii(c,d,a,b,x[i + 6],15,-1560198380);
			b = this.ii(b,c,d,a,x[i + 13],21,1309151649);
			a = this.ii(a,b,c,d,x[i + 4],6,-145523070);
			d = this.ii(d,a,b,c,x[i + 11],10,-1120210379);
			c = this.ii(c,d,a,b,x[i + 2],15,718787259);
			b = this.ii(b,c,d,a,x[i + 9],21,-343485551);
			a = this.addme(a,olda);
			b = this.addme(b,oldb);
			c = this.addme(c,oldc);
			d = this.addme(d,oldd);
			i += 16;
		}
		return [a,b,c,d];
	}
	,__class__: haxe.crypto.Md5
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
js.Browser.alert = function(v) {
	window.alert(js.Boot.__string_rec(v,""));
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
var phylo = phylo || {};
phylo.PhyloAnnotation = $hxClasses["phylo.PhyloAnnotation"] = function() {
	this.hasAnnot = false;
	this.color = [];
	this.text = "";
	this.splitresults = false;
	this.optionSelected = [];
	this.alfaAnnot = [];
	this.hasAnnot = false;
	this.fromresults = [];
	this.auxMap = new haxe.ds.StringMap();
};
phylo.PhyloAnnotation.__name__ = ["phylo","PhyloAnnotation"];
phylo.PhyloAnnotation.prototype = {
	type: null
	,annotImg: null
	,defaultImg: null
	,shape: null
	,color: null
	,hookName: null
	,text: null
	,options: null
	,optionSelected: null
	,dbData: null
	,legend: null
	,legendClazz: null
	,legendMethod: null
	,hidden: null
	,hasClass: null
	,hasMethod: null
	,divMethod: null
	,familyMethod: null
	,hasAnnot: null
	,alfaAnnot: null
	,splitresults: null
	,popup: null
	,popMethod: null
	,option: null
	,fromresults: null
	,label: null
	,myleaf: null
	,auxMap: null
	,uploadImg: function(imgList) {
		var i;
		this.annotImg = [];
		var _g1 = 0;
		var _g = imgList.length;
		while(_g1 < _g) {
			var i1 = _g1++;
			this.annotImg[i1] = window.document.createElement("img");
			this.annotImg[i1].src = imgList[i1];
			this.annotImg[i1].onload = function() {
			};
		}
	}
	,saveAnnotationData: function(annotation,data,option,r) {
		this.type = annotation;
		this.dbData = [];
		this.dbData = data;
		this.option = option;
		if(r[annotation] != null) {
			if(this.color != null) this.color = r[annotation].color; else {
				this.color = [];
				this.color = r[annotation].color;
			}
			this.text = r[annotation].text;
		} else {
			this.defaultImg = r.defImage;
			if(this.color != null) this.color[0] = saturn.core.Util.clone(r.color); else {
				this.color = [];
				this.color[0] = saturn.core.Util.clone(r.color);
			}
			this.text = "" + Std.string(r.text) + "";
		}
		this.hasAnnot = true;
	}
	,__class__: phylo.PhyloAnnotation
};
phylo.PhyloAnnotationConfiguration = $hxClasses["phylo.PhyloAnnotationConfiguration"] = function() {
};
phylo.PhyloAnnotationConfiguration.__name__ = ["phylo","PhyloAnnotationConfiguration"];
phylo.PhyloAnnotationConfiguration.prototype = {
	name: null
	,annotationFunction: null
	,styleFunction: null
	,legendFunction: null
	,infoFunction: null
	,shape: null
	,colour: null
	,getColourOldFormat: function() {
		return { color : this.colour, 'used' : "false"};
	}
	,__class__: phylo.PhyloAnnotationConfiguration
};
phylo.PhyloAnnotationManager = $hxClasses["phylo.PhyloAnnotationManager"] = function() {
	this.selectedAnnotationOptions = [];
	this.annotations = [];
	this.activeAnnotation = [];
	this.alreadyGotAnnotation = new haxe.ds.StringMap();
	this.selectedAnnotationOptions = [];
	this.searchedGenes = [];
	this.annotationListeners = [];
	this.skipAnnotation = [];
	this.skipCurrentLegend = [];
};
phylo.PhyloAnnotationManager.__name__ = ["phylo","PhyloAnnotationManager"];
phylo.PhyloAnnotationManager.prototype = {
	annotations: null
	,rootNode: null
	,canvas: null
	,numTotalAnnot: null
	,searchedGenes: null
	,annotationListeners: null
	,annotationData: null
	,annotationString: null
	,annotationConfigs: null
	,nameAnnot: null
	,jsonFile: null
	,activeAnnotation: null
	,alreadyGotAnnotation: null
	,selectedAnnotationOptions: null
	,annotationNameToConfig: null
	,skipAnnotation: null
	,skipCurrentLegend: null
	,showAssociatedData: function(active,data,mx,my) {
		var annotation = this.annotations[data.annotation.type];
		if(!active && annotation.divMethod != null) annotation.divMethod(data,mx,my);
	}
	,showScreenData: function(active,data,mx,my) {
		if(this.canvas == null) return;
		this.showAssociatedData(active,data,mx,my);
	}
	,fillAnnotationwithJSonData: function() {
		var i = 0;
		var j = 0;
		var z = 0;
		this.nameAnnot = [];
		var b = 0;
		while(i < this.jsonFile.btnGroup.length) {
			j = 0;
			while(j < this.jsonFile.btnGroup[i].buttons.length) {
				if(this.jsonFile.btnGroup[i].buttons[j].isTitle == false) {
					var a;
					a = this.jsonFile.btnGroup[i].buttons[j].annotCode;
					this.annotations[a] = new phylo.PhyloAnnotation();
					this.selectedAnnotationOptions[a] = null;
					if(this.jsonFile.btnGroup[i].buttons[j].shape == "image") this.annotations[a].uploadImg(this.jsonFile.btnGroup[i].buttons[j].annotImg);
					{
						this.alreadyGotAnnotation.set(this.jsonFile.btnGroup[i].buttons[j].annotCode,false);
						false;
					}
					this.annotations[a].shape = this.jsonFile.btnGroup[i].buttons[j].shape;
					this.annotations[a].label = this.jsonFile.btnGroup[i].buttons[j].label;
					this.annotations[a].color = this.jsonFile.btnGroup[i].buttons[j].color;
					this.annotations[a].hookName = this.jsonFile.btnGroup[i].buttons[j].hookName;
					this.annotations[a].splitresults = this.jsonFile.btnGroup[i].buttons[j].splitresults;
					this.annotations[a].popup = this.jsonFile.btnGroup[i].buttons[j].popUpWindows;
					if(this.jsonFile.btnGroup[i].buttons[j].hasClass != null) this.annotations[a].hasClass = this.jsonFile.btnGroup[i].buttons[j].hasClass;
					if(this.jsonFile.btnGroup[i].buttons[j].hasMethod != null) this.annotations[a].hasMethod = this.jsonFile.btnGroup[i].buttons[j].hasMethod;
					if(this.jsonFile.btnGroup[i].buttons[j].divMethod != null) this.annotations[a].divMethod = this.jsonFile.btnGroup[i].buttons[j].divMethod;
					if(this.jsonFile.btnGroup[i].buttons[j].familyMethod != null) this.annotations[a].familyMethod = this.jsonFile.btnGroup[i].buttons[j].familyMethod;
					if(this.jsonFile.btnGroup[i].buttons[j].popUpWindows != null && this.jsonFile.btnGroup[i].buttons[j].popUpWindows == true) this.annotations[a].popMethod = this.jsonFile.btnGroup[i].buttons[j].windowsData[0].popMethod;
					this.annotations[a].options = [];
					if(this.jsonFile.btnGroup[i].buttons[j].legend != null) {
						this.annotations[a].legend = this.jsonFile.btnGroup[i].buttons[j].legend.image;
						if(this.jsonFile.btnGroup[i].buttons[j].legend.clazz != null) {
							this.annotations[a].legendClazz = this.jsonFile.btnGroup[i].buttons[j].legend.clazz;
							this.annotations[a].legendMethod = this.jsonFile.btnGroup[i].buttons[j].legend.method;
						} else if(this.jsonFile.btnGroup[i].buttons[j].legend.method != null) this.annotations[a].legendMethod = this.jsonFile.btnGroup[i].buttons[j].legend.method;
					}
					if(this.jsonFile.btnGroup[i].buttons[j].hidden != null) this.annotations[a].hidden = this.jsonFile.btnGroup[i].buttons[j].hidden;
					if(this.jsonFile.btnGroup[i].buttons[j].submenu == true) {
						var zz;
						var _g1 = 0;
						var _g = this.jsonFile.btnGroup[i].buttons[j].options.length;
						while(_g1 < _g) {
							var zz1 = _g1++;
							this.annotations[a].options[zz1] = this.jsonFile.btnGroup[i].buttons[j].options[zz1].hookName;
							if(this.jsonFile.btnGroup[i].buttons[j].options[zz1].defaultImg != null) this.annotations[a].defaultImg = this.jsonFile.btnGroup[i].buttons[j].options[zz1].defaultImg;
						}
						this.annotations[a].optionSelected[0] = this.jsonFile.btnGroup[i].buttons[j].optionSelected[0];
					}
					this.nameAnnot[b] = this.jsonFile.btnGroup[i].buttons[j].label;
					b++;
				}
				j++;
			}
			this.numTotalAnnot = this.numTotalAnnot + j;
			i++;
		}
	}
	,closeAnnotWindows: function() {
	}
	,addAnnotData: function(annotData,annotation,option,callback) {
		var i;
		var mapResults;
		mapResults = new haxe.ds.StringMap();
		var j = 0;
		var target;
		var _g1 = 0;
		var _g = annotData.length;
		while(_g1 < _g) {
			var i1 = _g1++;
			target = Std.string(annotData[i1].target_id) + "_" + j;
			while(__map_reserved[target] != null?mapResults.existsReserved(target):mapResults.h.hasOwnProperty(target)) {
				j++;
				target = Std.string(annotData[i1].target_id) + "_" + j;
			}
			j = 0;
			var value = annotData[i1];
			mapResults.set(target,value);
		}
		var items = [];
		var _g11 = 0;
		var _g2 = this.rootNode.targets.length;
		while(_g11 < _g2) {
			var i2 = _g11++;
			items[i2] = this.rootNode.targets[i2];
		}
		this.processAnnotationsSimple(items,mapResults,annotation,option,callback);
	}
	,processAnnotationsSimple: function(items,mapResults,annotation,option,cb) {
		var _g1 = this;
		var toComplete = items.length;
		var onDone = function() {
			if(toComplete == 0) cb();
		};
		if(toComplete == 0) {
			cb();
			return;
		}
		var _g = 0;
		while(_g < items.length) {
			var item = [items[_g]];
			++_g;
			var name = item[0] + "_0";
			var res = [__map_reserved[name] != null?mapResults.getReserved(name):mapResults.h[name]];
			if(this.annotations[annotation].hasClass != null && this.annotations[annotation].hasMethod != null) {
				var clazz = this.annotations[annotation].hasClass;
				var method = this.annotations[annotation].hasMethod;
				var _processAnnotation = (function(res,item) {
					return function(r) {
						if(r.hasAnnot) {
							var leafaux;
							leafaux = _g1.rootNode.leafNameToNode.get(item[0]);
							leafaux.activeAnnotation[annotation] = true;
							if(leafaux.annotations[annotation] == null) {
								leafaux.annotations[annotation] = new phylo.PhyloAnnotation();
								leafaux.annotations[annotation].myleaf = leafaux;
								leafaux.annotations[annotation].text = r.text;
								leafaux.annotations[annotation].defaultImg = _g1.annotations[annotation].defaultImg;
								leafaux.annotations[annotation].saveAnnotationData(annotation,res[0],option,r);
							} else if(_g1.annotations[annotation].splitresults == true) {
								leafaux.annotations[annotation].splitresults = true;
								var z = 0;
								while(leafaux.annotations[annotation].alfaAnnot[z] != null) z++;
								leafaux.annotations[annotation].alfaAnnot[z] = new phylo.PhyloAnnotation();
								leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
								leafaux.annotations[annotation].alfaAnnot[z].text = "";
								leafaux.annotations[annotation].alfaAnnot[z].defaultImg = _g1.annotations[annotation].defaultImg;
								leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res[0],option,r);
								if(leafaux.annotations[annotation].alfaAnnot[z].text == leafaux.annotations[annotation].text) leafaux.annotations[annotation].alfaAnnot[z] = null;
							} else if(leafaux.annotations[annotation].option != _g1.annotations[annotation].optionSelected[0]) {
								leafaux.annotations[annotation] = new phylo.PhyloAnnotation();
								leafaux.annotations[annotation].myleaf = leafaux;
								leafaux.annotations[annotation].text = "";
								leafaux.annotations[annotation].defaultImg = _g1.annotations[annotation].defaultImg;
								leafaux.annotations[annotation].saveAnnotationData(annotation,res[0],option,r);
							}
						}
						toComplete--;
						onDone();
					};
				})(res,item);
				if(Reflect.isFunction(method)) method(name,res[0],option,this.annotations,item[0],_processAnnotation); else {
					var hook = Reflect.field(Type.resolveClass(clazz),method);
					hook(name,res[0],option,this.annotations,item[0],_processAnnotation);
				}
			} else {
				var col = "";
				if(this.annotations[annotation].color[0] != null) col = this.annotations[annotation].color[0].color;
				var r1 = { hasAnnot : true, text : "", color : { color : col, used : true}, defImage : this.annotations[annotation].defaultImg};
				var leafaux1 = this.rootNode.leafNameToNode.get(item[0]);
				leafaux1.activeAnnotation[annotation] = true;
				if(leafaux1.annotations[annotation] == null) {
					leafaux1.annotations[annotation] = new phylo.PhyloAnnotation();
					leafaux1.annotations[annotation].myleaf = leafaux1;
					leafaux1.annotations[annotation].text = "";
					leafaux1.annotations[annotation].defaultImg = this.annotations[annotation].defaultImg;
					leafaux1.annotations[annotation].saveAnnotationData(annotation,res[0],option,r1);
				} else if(leafaux1.annotations[annotation].splitresults == true) {
					var z1 = 0;
					while(leafaux1.annotations[annotation].alfaAnnot[z1] != null) z1++;
					leafaux1.annotations[annotation].alfaAnnot[z1] = new phylo.PhyloAnnotation();
					leafaux1.annotations[annotation].alfaAnnot[z1].myleaf = leafaux1;
					leafaux1.annotations[annotation].alfaAnnot[z1].text = "";
					leafaux1.annotations[annotation].alfaAnnot[z1].defaultImg = this.annotations[annotation].defaultImg;
					leafaux1.annotations[annotation].alfaAnnot[z1].saveAnnotationData(annotation,res[0],option,r1);
				} else if(leafaux1.annotations[annotation].option != this.annotations[annotation].optionSelected[0]) {
					leafaux1.annotations[annotation] = new phylo.PhyloAnnotation();
					leafaux1.annotations[annotation].myleaf = leafaux1;
					leafaux1.annotations[annotation].text = "";
					leafaux1.annotations[annotation].defaultImg = this.annotations[annotation].defaultImg;
					leafaux1.annotations[annotation].saveAnnotationData(annotation,res[0],option,r1);
				}
				toComplete--;
				onDone();
			}
		}
	}
	,reloadAnnotationConfigurations: function() {
		this.setAnnotationConfigs(this.getAnnotationConfigs(),true,function() {
		});
	}
	,setAnnotationConfigs: function(configs,restoreData,cb) {
		var _g = this;
		this.annotationConfigs = configs;
		this.annotationNameToConfig = new haxe.ds.StringMap();
		var _g1 = 0;
		var _g11 = this.annotationConfigs;
		while(_g1 < _g11.length) {
			var config = _g11[_g1];
			++_g1;
			this.annotationNameToConfig.set(config.name,config);
		}
		var oldData = this.annotationData;
		this.annotationData = [];
		var activeAnnotationNames = new haxe.ds.StringMap();
		saturn.client.core.CommonCore.getDefaultProvider(function(err,provider) {
			if(err == null && provider != null) {
				provider.resetCache();
				var _g2 = 0;
				var _g12 = _g.activeAnnotation.length;
				while(_g2 < _g12) {
					var i = _g2++;
					if(_g.activeAnnotation[i]) {
						activeAnnotationNames.set(_g.annotations[i].label,"");
						_g.activeAnnotation[i] = false;
					}
				}
				if(_g.rootNode != null) _g.rootNode.clearAnnotations();
				_g.annotations = [];
				_g.jsonFile = { btnGroup : [{ title : "Annotations", buttons : []}]};
				var _g21 = 0;
				var _g13 = configs.length;
				while(_g21 < _g13) {
					var i1 = _g21++;
					var config1 = [configs[i1]];
					_g.annotationData[i1] = [];
					var hookName = ["STANDALONE_ANNOTATION_" + i1];
					var def = { label : config1[0].name, hookName : hookName[0], annotCode : i1 + 1, isTitle : false, enabled : true, familyMethod : "", hasMethod : config1[0].styleFunction, hasClass : "", legend : { method : config1[0].legendFunction}, divMethod : config1[0].infoFunction, color : [{ color : config1[0].colour, used : "false"}], shape : config1[0].shape};
					_g.jsonFile.btnGroup[0].buttons.push(def);
					saturn.client.core.CommonCore.getDefaultProvider((function(hookName,config1) {
						return function(error,provider1) {
							provider1.resetCache();
							provider1.addHook(config1[0].annotationFunction,hookName[0]);
						};
					})(hookName,config1));
				}
				_g.fillAnnotationwithJSonData();
				if(restoreData) _g.annotationData = oldData;
				_g.annotationsChanged(activeAnnotationNames);
				cb();
			}
		});
	}
	,getAnnotationConfigs: function() {
		return this.annotationConfigs;
	}
	,getAnnotationConfigByName: function(name) {
		return this.annotationNameToConfig.get(name);
	}
	,getAnnotationConfigById: function(id) {
		return this.getAnnotationConfigByName(this.annotations[id].label);
	}
	,loadAnnotationsFromString: function(annotationString,configs) {
		var _g2 = this;
		this.annotationString = annotationString;
		var lines = annotationString.split("\n");
		var header = lines[0];
		var cols = header.split(",");
		var configMap = new haxe.ds.StringMap();
		if(configs != null) {
			var _g = 0;
			while(_g < configs.length) {
				var config = configs[_g];
				++_g;
				configMap.set(config.name,config);
			}
		}
		var finalConfigs = [];
		var _g1 = 1;
		var _g3 = cols.length;
		while(_g1 < _g3) {
			var i = _g1++;
			var styleAnnotation = function(target,data,selected,annotList,item,callBack) {
				var config1 = _g2.getAnnotationConfigById(selected);
				var r = { hasAnnot : true, text : "", color : config1.getColourOldFormat(), defImage : 100};
				if(data == null || data.annotation == "No") r.hasAnnot = false;
				callBack(r);
			};
			var legendMethod = function(legendWidget,config2) {
				var row = new phylo.PhyloLegendRowWidget(legendWidget,config2);
			};
			var divMethod = function(data1,mx,my) {
				var $window = new phylo.PhyloWindowWidget(window.document.body,data1.target,false);
				var container = $window.getContainer();
				container.style.left = mx;
				container.style.top = my;
				container.style.width = "400px";
				container.style.height = "200px";
			};
			var name = cols[i];
			var hookFunction = $bind(this,this.handleAnnotation);
			var config3 = new phylo.PhyloAnnotationConfiguration();
			config3.shape = "cercle";
			config3.colour = "green";
			config3.name = name;
			config3.styleFunction = styleAnnotation;
			config3.annotationFunction = hookFunction;
			config3.infoFunction = divMethod;
			config3.legendFunction = legendMethod;
			if(__map_reserved[name] != null?configMap.existsReserved(name):configMap.h.hasOwnProperty(name)) {
				var configUser;
				configUser = __map_reserved[name] != null?configMap.getReserved(name):configMap.h[name];
				if(configUser.colour != null) config3.colour = configUser.colour;
				if(configUser.annotationFunction != null) config3.annotationFunction = configUser.annotationFunction;
				if(configUser.styleFunction != null) config3.styleFunction = configUser.styleFunction;
				if(configUser.legendFunction != null) config3.legendFunction = configUser.legendFunction;
				if(configUser.shape != null) config3.shape = configUser.shape;
			}
			finalConfigs.push(config3);
		}
		this.annotationData = [];
		var headerCols = header.split(",");
		var _g11 = 1;
		var _g4 = headerCols.length;
		while(_g11 < _g4) {
			var j = _g11++;
			this.annotationData[j - 1] = [];
		}
		var _g12 = 1;
		var _g5 = lines.length;
		while(_g12 < _g5) {
			var i1 = _g12++;
			var cols1 = lines[i1].split(",");
			var _g31 = 1;
			var _g21 = cols1.length;
			while(_g31 < _g21) {
				var j1 = _g31++;
				this.annotationData[j1 - 1].push({ 'target_id' : cols1[0], 'annotation' : cols1[j1]});
			}
		}
		this.setAnnotationConfigs(finalConfigs,true,function() {
		});
	}
	,handleAnnotation: function(alias,params,clazz,cb) {
		var annotationIndex = Std.parseInt(alias.charAt(alias.length - 1));
		cb(this.annotationData[annotationIndex],null);
	}
	,addAnnotationListener: function(listener) {
		this.annotationListeners.push(listener);
	}
	,annotationsChanged: function(activeAnnotationNames) {
		if(activeAnnotationNames != null) {
			if(this.canvas != null && this.canvas.getConfig().enableAnnotationMenu) {
				this.canvas.getAnnotationMenu().update(activeAnnotationNames);
				return;
			}
		}
		var _g = 0;
		var _g1 = this.annotationListeners;
		while(_g < _g1.length) {
			var listener = _g1[_g];
			++_g;
			listener();
		}
	}
	,toggleAnnotation: function(annotCode) {
		if(this.isAnnotationActive(annotCode)) this.setActiveAnnotation(annotCode,false); else this.setActiveAnnotation(annotCode,true);
	}
	,isAnnotationActive: function(annotCode) {
		return this.activeAnnotation[annotCode];
	}
	,setActiveAnnotation: function(annotCode,active) {
		var _g = this;
		this.activeAnnotation[annotCode] = active;
		if(active) {
			var annot = this.annotations[annotCode];
			saturn.client.core.CommonCore.getDefaultProvider(function(err,provider) {
				var parameters = _g.canvas.getRootNode().targets;
				provider.getByNamedQuery(annot.hookName,{ param : parameters},null,true,function(db_results,error) {
					if(error == null) _g.canvas.getAnnotationManager().addAnnotData(db_results,annotCode,annotCode,function() {
						_g.annotationsChanged();
					});
				});
			});
		} else this.annotationsChanged();
	}
	,getActiveAnnotations: function() {
		var annotations = [];
		var _g1 = 0;
		var _g = this.activeAnnotation.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(this.activeAnnotation[i]) annotations.push(this.annotations[i]);
		}
		return annotations;
	}
	,getAnnotationString: function() {
		return this.annotationString;
	}
	,setRootNode: function(rootNode) {
		this.rootNode = rootNode;
	}
	,getTreeName: function() {
		return "tree";
	}
	,hideAnnotationWindows: function() {
	}
	,__class__: phylo.PhyloAnnotationManager
};
phylo.PhyloAnnotationMenuWidget = $hxClasses["phylo.PhyloAnnotationMenuWidget"] = function(canvas,activeAnnotations) {
	this.canvas = canvas;
	this.activeAnnotations = activeAnnotations;
	this.build();
};
phylo.PhyloAnnotationMenuWidget.__name__ = ["phylo","PhyloAnnotationMenuWidget"];
phylo.PhyloAnnotationMenuWidget.prototype = {
	canvas: null
	,container: null
	,activeAnnotations: null
	,items: null
	,build: function() {
		this.addContainer();
		this.addAnnotationButtons();
	}
	,getContainer: function() {
		return this.container;
	}
	,update: function(activeAnnotations) {
		this.activeAnnotations = activeAnnotations;
		this.addAnnotationButtons();
	}
	,clearAnnotationItems: function() {
		if(this.items != null) {
			var _g = 0;
			var _g1 = this.items;
			while(_g < _g1.length) {
				var item = _g1[_g];
				++_g;
				this.container.removeChild(item);
			}
		}
	}
	,addContainer: function() {
		this.container = window.document.createElement("div");
		this.container.style.display = "inline-block";
		this.container.style.minWidth = "160px";
		this.container.style.position = "relative";
		this.container.style.verticalAlign = "top";
		this.container.style.height = "100%";
		this.container.style.backgroundColor = "#f7f8fb";
		this.container.marginLeft = "0px";
		this.container.marginTop = "0px";
		this.container.innerHTML = "<h1 style=\"margin-left:5px;margin-right:5px\">Annotations</h1>";
	}
	,addAnnotationButtons: function() {
		var _g3 = this;
		var btnGroups = this.canvas.getAnnotationManager().jsonFile.btnGroup;
		this.clearAnnotationItems();
		this.items = [];
		var _g1 = 0;
		var _g = btnGroups.length;
		while(_g1 < _g) {
			var i = _g1++;
			var btnGroupDef = btnGroups[i];
			var btnDefs = btnGroupDef.buttons;
			var _g2 = 0;
			while(_g2 < btnDefs.length) {
				var btnDef = [btnDefs[_g2]];
				++_g2;
				var row = window.document.createElement("div");
				row.style.display = "flex";
				var tooltipBtn = window.document.createElement("button");
				tooltipBtn.innerText = "?";
				tooltipBtn.style.backgroundColor = "rgb(247, 248, 251)";
				tooltipBtn.style.border = "none";
				tooltipBtn.style.font = "normal 11px/16px tahoma, arial, verdana, sans-serif";
				tooltipBtn.style.cursor = "pointer";
				var enabledBtn = [window.document.createElement("button")];
				enabledBtn[0].innerHTML = " &#9744;";
				enabledBtn[0].style.backgroundColor = "rgb(247, 248, 251)";
				enabledBtn[0].style.border = "none";
				enabledBtn[0].style.font = "normal 16px/20px tahoma, arial, verdana, sans-serif";
				enabledBtn[0].style.cursor = "pointer";
				var btn = [window.document.createElement("button")];
				btn[0].innerText = btnDef[0].label;
				btn[0].style.backgroundColor = "rgb(247, 248, 251)";
				btn[0].style.border = "none";
				btn[0].style.font = "normal 11px/16px tahoma, arial, verdana, sans-serif";
				btn[0].style.cursor = "pointer";
				btn[0].style.textAlign = "left";
				btn[0].style.flexGrow = "1";
				btn[0].setAttribute("title",btnDef[0].helpText);
				btn[0].addEventListener("mouseover",(function(btn) {
					return function() {
						btn[0].style.backgroundColor = "#dddee1";
					};
				})(btn));
				btn[0].addEventListener("mouseout",(function(btn) {
					return function() {
						btn[0].style.backgroundColor = "rgb(247, 248, 251)";
					};
				})(btn));
				btn[0].addEventListener("click",(function(enabledBtn,btnDef) {
					return function() {
						if(_g3.canvas.getAnnotationManager().isAnnotationActive(btnDef[0].annotCode)) enabledBtn[0].innerHTML = "&#9744;"; else enabledBtn[0].innerHTML = "&#9745;";
						_g3.canvas.getAnnotationManager().toggleAnnotation(btnDef[0].annotCode);
					};
				})(enabledBtn,btnDef));
				row.appendChild(tooltipBtn);
				row.appendChild(enabledBtn[0]);
				row.appendChild(btn[0]);
				this.items.push(row);
				this.container.appendChild(row);
				if(this.activeAnnotations != null && (function($this) {
					var $r;
					var key = btnDef[0].label;
					$r = $this.activeAnnotations.exists(key);
					return $r;
				}(this))) {
					this.canvas.getAnnotationManager().toggleAnnotation(btnDef[0].annotCode);
					enabledBtn[0].innerHTML = "&#9745;";
				}
			}
		}
	}
	,__class__: phylo.PhyloAnnotationMenuWidget
};
phylo.PhyloRendererI = $hxClasses["phylo.PhyloRendererI"] = function() { };
phylo.PhyloRendererI.__name__ = ["phylo","PhyloRendererI"];
phylo.PhyloRendererI.prototype = {
	mesureText: null
	,__class__: phylo.PhyloRendererI
};
phylo.PhyloCanvasRenderer = $hxClasses["phylo.PhyloCanvasRenderer"] = function(width,height,parentElement,rootNode,config,annotationManager) {
	this.autoFitting = false;
	this.nodeClickListeners = [];
	this.contextDiv = null;
	this.translateY = 0.;
	this.translateX = 0.;
	this.scale = 1.0;
	this.parent = parentElement;
	this.width = width;
	this.height = height;
	this.annotationManager = annotationManager;
	if(this.annotationManager == null) this.annotationManager = new phylo.PhyloAnnotationManager();
	this.annotationManager.addAnnotationListener($bind(this,this.onAnnotationChange));
	this.annotationManager.rootNode = rootNode;
	this.annotationManager.canvas = this;
	this.rootNode = rootNode;
	var doc;
	if(config == null) config = new phylo.PhyloCanvasConfiguration();
	this.config = config;
	config.dataChanged = true;
	if(config.enableTools) this.addNodeClickListener($bind(this,this.defaultNodeClickListener));
	this.createContainer();
	if(config.enableToolbar) this.toolBar = new phylo.PhyloToolBar(this);
	if(this.getConfig().autoFit) this.autoFitRedraw(); else this.redraw(true);
};
phylo.PhyloCanvasRenderer.__name__ = ["phylo","PhyloCanvasRenderer"];
phylo.PhyloCanvasRenderer.__interfaces__ = [phylo.PhyloRendererI];
phylo.PhyloCanvasRenderer.main = function() {
};
phylo.PhyloCanvasRenderer.prototype = {
	canvas: null
	,ctx: null
	,scale: null
	,parent: null
	,rootNode: null
	,cx: null
	,cy: null
	,config: null
	,width: null
	,height: null
	,translateX: null
	,translateY: null
	,selectedNode: null
	,contextDiv: null
	,annotationManager: null
	,nodeClickListeners: null
	,contextMenu: null
	,toolBar: null
	,container: null
	,outerContainer: null
	,autoFitting: null
	,legendWidget: null
	,annotationMenu: null
	,onAnnotationChange: function() {
		this.redraw();
		if(this.config.enableLegend) this.legendWidget.redraw();
	}
	,getRootNode: function() {
		return this.rootNode;
	}
	,getAnnotationManager: function() {
		return this.annotationManager;
	}
	,createContainer: function() {
		this.container = window.document.createElement("div");
		if(this.config.enableAnnotationMenu || this.config.enableLegend || this.config.enableImport) {
			this.outerContainer = window.document.createElement("div");
			this.outerContainer.style.display = "flex";
			this.outerContainer.style.height = "100%";
			var leftContainer = window.document.createElement("div");
			leftContainer.style.height = "100%";
			leftContainer.style.display = "flex";
			leftContainer.style.flexDirection = "column";
			if(this.config.enableAnnotationMenu) {
				this.annotationMenu = new phylo.PhyloAnnotationMenuWidget(this);
				this.annotationMenu.getContainer().style.flexGrow = "1";
				leftContainer.appendChild(this.annotationMenu.getContainer());
			}
			if(this.config.enableImport) {
				var importWidget = new phylo.PhyloImportWidget(this);
				leftContainer.appendChild(importWidget.getContainer());
			}
			this.outerContainer.appendChild(leftContainer);
			this.outerContainer.appendChild(this.container);
			this.container.style.display = "inline-block";
			this.container.style.position = "relative";
			this.container.style.flexGrow = "1";
			if(this.config.enableLegend) {
				this.legendWidget = new phylo.PhyloLegendWidget(this);
				this.outerContainer.appendChild(this.legendWidget.getContainer());
			}
			this.parent.appendChild(this.outerContainer);
		} else {
			this.container.style.height = "100%";
			this.parent.appendChild(this.container);
		}
	}
	,getCanvas: function() {
		return this.canvas;
	}
	,getParent: function() {
		return this.parent;
	}
	,getContainer: function() {
		return this.container;
	}
	,destroy: function() {
		if(this.config.enableAnnotationMenu || this.config.enableLegend || this.config.enableImport) this.parent.removeChild(this.outerContainer); else this.parent.removeChild(this.container);
	}
	,notifyNodeClickListeners: function(node,data,e) {
		var _g = 0;
		var _g1 = this.nodeClickListeners;
		while(_g < _g1.length) {
			var listener = _g1[_g];
			++_g;
			listener(node,data,e);
		}
	}
	,defaultNodeClickListener: function(node,data,e) {
		if(node == null) {
			if(this.contextMenu != null) {
				this.closeContextMenu();
				return;
			}
		} else {
			if(this.contextMenu != null) this.closeContextMenu();
			this.contextMenu = new phylo.PhyloContextMenu(this.parent,this,node,data,e);
		}
	}
	,addNodeClickListener: function(listener) {
		this.nodeClickListeners.push(listener);
	}
	,createCanvas: function() {
		var _g = this;
		if(this.config.enableLegend || this.config.enableAnnotationMenu || this.config.enableAnnotationMenu) {
			this.width = this.container.clientWidth;
			this.height = this.container.clientHeight;
		}
		if(this.canvas != null) {
			this.ctx.save();
			this.ctx.setTransform(1,0,0,1,0,0);
			this.ctx.clearRect(0,0,this.canvas.width,this.canvas.height);
			this.ctx.restore();
		} else {
			this.canvas = window.document.createElement("canvas");
			this.container.appendChild(this.canvas);
			this.canvas.width = this.width;
			this.canvas.height = this.height;
			this.ctx = this.canvas.getContext("2d");
			this.cx = Math.round(this.width / 2);
			this.cy = Math.round(this.height / 2);
			this.ctx.translate(this.cx,this.cy);
			if(this.config.enableZoom) {
				this.canvas.addEventListener("mousewheel",function(e) {
					if(e.wheelDelta < 0) _g.zoomIn(); else _g.zoomOut();
				});
				var mouseDownX = 0.;
				var mouseDownY = 0.;
				var mouseDown = false;
				this.canvas.addEventListener("mousedown",function(e1) {
					_g.annotationManager.hideAnnotationWindows();
					_g.annotationManager.closeAnnotWindows();
					mouseDownX = e1.pageX - _g.translateX;
					mouseDownY = e1.pageY - _g.translateY;
					mouseDown = true;
					if(_g.contextDiv != null) {
						_g.container.removeChild(_g.contextDiv);
						_g.contextDiv = null;
					}
					_g.notifyNodeClickListeners(null,null,null);
				});
				this.canvas.addEventListener("mousemove",function(e2) {
					if(mouseDown && mouseDownX != 0 && mouseDownY != 0) {
						_g.newPosition(e2.pageX - mouseDownX,e2.pageY - mouseDownY);
						_g.notifyNodeClickListeners(null,null,null);
					}
				});
				this.canvas.addEventListener("mouseup",function(e3) {
					mouseDown = false;
					mouseDownX = 0;
					mouseDownY = 0;
					var d = _g.checkPosition(e3);
					if(d != null) {
						if(d.isAnnot == true) _g.annotationManager.showScreenData(false,d,e3.pageX,e3.pageY); else {
							_g.selectedNode = _g.rootNode.nodeIdToNode.get(d.nodeId);
							_g.notifyNodeClickListeners(_g.selectedNode,d,e3);
						}
					} else _g.notifyNodeClickListeners(null,null,e3);
				});
			}
		}
	}
	,exportPNG: function(cb) {
		this.canvas.toBlob(function(blob) {
			cb(blob);
		});
	}
	,exportPNGToFile: function() {
		var _g = this;
		this.exportPNG(function(blob) {
			var uWin = window;
			uWin.saveAs(blob,_g.getAnnotationManager().getTreeName() + "_tree.png");
		});
	}
	,exportSVG: function() {
		var width = this.width;
		var height = this.height;
		var svgCtx = new C2S(width,height);
		var ctx = this.ctx;
		this.ctx = svgCtx;
		var rTranslateX = this.translateX;
		var rTranslateY = this.translateY;
		this.translateX = width / 2;
		this.translateY = height / 2;
		this.redraw(false);
		this.translateX = rTranslateX;
		this.translateY = rTranslateY;
		this.ctx = ctx;
		return svgCtx.getSerializedSvg(true);
	}
	,exportSVGToFile: function() {
		var svgStr = this.exportSVG();
		var blob = new Blob([svgStr],{ type : "text/plain;charset=utf-8"});
		var uWin = window;
		uWin.saveAs(blob,this.getAnnotationManager().getTreeName() + "_tree.svg");
	}
	,showHighlightDialog: function() {
		var dialog = new phylo.PhyloHighlightWidget(this.parent,this);
	}
	,center: function() {
		this.newPosition(0,0);
	}
	,newPosition: function(x,y) {
		this.createCanvas();
		this.translateX = x;
		this.translateY = y;
		this.redraw(false);
	}
	,drawLine: function(x0,y0,x1,y1,strokeStyle,lineWidth) {
		this.ctx.save();
		this.applyDefaultConfiguration();
		this.ctx.strokeStyle = strokeStyle;
		this.ctx.beginPath();
		this.ctx.moveTo(Math.round(x0),Math.round(y0));
		this.ctx.lineTo(Math.round(x1),Math.round(y1));
		this.ctx.lineWidth = lineWidth;
		this.ctx.stroke();
		this.ctx.restore();
	}
	,drawArc: function(x,y,radius,sAngle,eAngle,strokeStyle,lineWidth) {
		this.ctx.save();
		this.applyDefaultConfiguration();
		this.ctx.strokeStyle = strokeStyle;
		this.ctx.beginPath();
		this.ctx.arc(x,y,Math.abs(radius),sAngle,eAngle);
		this.ctx.lineWidth = lineWidth;
		this.ctx.stroke();
		this.ctx.restore();
	}
	,drawWedge: function(x,y,radius,sAngle,eAngle,strokeStyle,lineWidth) {
		this.ctx.save();
		this.ctx.fillStyle = strokeStyle;
		this.ctx.globalAlpha = 0.5;
		this.ctx.strokeStyle = strokeStyle;
		this.ctx.beginPath();
		this.ctx.moveTo(0,0);
		this.ctx.arc(x,y,Math.abs(radius),sAngle,eAngle);
		this.ctx.lineWidth = lineWidth;
		this.ctx.stroke();
		this.ctx.closePath();
		this.ctx.fill();
		this.ctx.restore();
	}
	,bezierCurve: function(x0,y0,x1,y1,firstX,firstY,secondX,secondY,strokeStyle,lineWidth) {
		this.ctx.save();
		this.applyDefaultConfiguration();
		this.ctx.strokeStyle = strokeStyle;
		this.ctx.beginPath();
		this.ctx.moveTo(Math.round(x0),Math.round(y0));
		this.ctx.bezierCurveTo(Math.round(firstX),Math.round(firstY),Math.round(secondX),Math.round(secondY),Math.round(x1),Math.round(y1));
		this.ctx.lineWidth = lineWidth;
		this.ctx.stroke();
		this.ctx.restore();
	}
	,drawText: function(text,tx,ty,x,y,rotation,textAlign,color) {
		this.ctx.save();
		this.applyDefaultConfiguration();
		this.ctx.translate(tx,ty);
		this.ctx.rotate(rotation);
		this.ctx.textAlign = textAlign;
		this.ctx.fillStyle = color;
		this.ctx.fillText(text,x,y);
		this.ctx.restore();
	}
	,drawTextNoTranslate: function(text,tx,ty,x,y,rotation,textAlign,color) {
		this.ctx.save();
		this.applyDefaultConfiguration();
		this.ctx.translate(tx,ty);
		this.ctx.rotate(rotation);
		this.ctx.textAlign = textAlign;
		this.ctx.fillStyle = color;
		this.ctx.fillText(text,x,y);
		this.ctx.restore();
	}
	,drawSquare: function(tx,ty,color) {
		this.ctx.save();
		this.applyDefaultConfiguration();
		this.ctx.beginPath();
		this.ctx.rect(tx,ty,10,10);
		this.ctx.fillStyle = color;
		this.ctx.fill();
		this.ctx.restore();
	}
	,drawCircle: function(tx,ty,color) {
		var radius = 5;
		this.ctx.save();
		this.applyDefaultConfiguration();
		this.ctx.beginPath();
		this.ctx.strokeStyle = color;
		this.ctx.arc(tx,ty,radius,0,2 * Math.PI);
		this.ctx.fillStyle = color;
		this.ctx.fill();
		this.ctx.restore();
	}
	,drawGraphic: function(tx,ty,columns) {
		this.ctx.save();
		this.applyDefaultConfiguration();
		this.ctx.beginPath();
		this.ctx.moveTo(Math.round(tx),Math.round(ty - 10));
		this.ctx.moveTo(Math.round(tx),Math.round(ty + 6));
		this.ctx.lineTo(Math.round(tx + 14),Math.round(ty + 6));
		this.ctx.strokeStyle = "rgb(6,6,6)";
		this.ctx.stroke();
		var len = columns[1];
		var pos = ty + 6 - columns[1];
		this.ctx.fillStyle = "rgb(41,128,214)";
		this.ctx.rect(tx + 1,pos,2,len);
		var len2 = columns[2];
		var pos2 = ty + 6 - columns[2];
		this.ctx.fillStyle = "rgb(191,0,0)";
		this.ctx.fillRect(tx + 3,pos2,2,len2);
		var len3 = columns[3];
		var pos3 = ty + 6 - columns[3];
		this.ctx.fillStyle = "rgb(99,207,27)";
		this.ctx.fillRect(tx + 5,pos3,2,len3);
		var len4 = columns[4];
		var pos4 = ty + 6 - columns[4];
		this.ctx.fillStyle = "rgb(255,128,0)";
		this.ctx.fillRect(tx + 7,pos4,2,len4);
		var len5 = columns[5];
		var pos5 = ty + 6 - columns[5];
		this.ctx.fillStyle = "rgb(192,86,145)";
		this.ctx.fillRect(tx + 9,pos5,2,len5);
		var len6 = columns[6];
		var pos6 = ty + 6 - columns[6];
		this.ctx.fillStyle = "rgb(255,204,0)";
		this.ctx.fillRect(tx + 11,pos6,2,len6);
		var len7 = columns[7];
		var pos7 = ty + 6 - columns[7];
		this.ctx.fillStyle = "rgb(121,63,243)";
		this.ctx.fillRect(tx + 13,pos7,2,len7);
		this.ctx.restore();
	}
	,drawImg: function(tx,ty,img,mode) {
		this.applyDefaultConfiguration();
		if(mode == 0) this.ctx.drawImage(img,tx,ty); else this.ctx.drawImage(img,28,0,125,125,tx,ty,20,20);
	}
	,mesureText: function(text) {
		return this.ctx.measureText(text).width;
	}
	,startGroup: function(groupName) {
	}
	,endGroup: function() {
	}
	,zoomIn: function(scale) {
		if(scale == null) {
			if(this.config.scale <= 4.0) this.config.scale = this.config.scale + 0.2;
			scale = this.config.scale;
		}
		this.scale = scale;
		this.redraw();
	}
	,zoomOut: function(scale) {
		if(scale == null) {
			this.config.scale = this.config.scale - 0.2;
			scale = this.config.scale;
		}
		this.scale = scale;
		this.redraw();
	}
	,updateActions: function() {
		if(this.toolBar != null) {
			this.toolBar.setLineTypeButtonVisible(this.config.drawingMode == phylo.PhyloDrawingMode.STRAIGHT);
			this.toolBar.setTitle(this.config.title);
		}
	}
	,autoFitRedraw: function() {
		var _g = this;
		this.autoFitting = true;
		this.config.dataChanged = true;
		this.redraw(true);
		haxe.Timer.delay(function() {
			_g.autoFit();
			_g.autoFitting = false;
			_g.canvas.style.display = "block";
		},1);
	}
	,redraw: function(create) {
		if(create == null) create = true;
		if(!this.autoFitting && this.config.autoFit && this.config.dataChanged) {
			this.autoFitRedraw();
			return;
		}
		this.updateActions();
		if(create) this.createCanvas();
		if(this.autoFitting) this.canvas.style.display = "none";
		var newWidth = this.canvas.width * this.scale;
		var newHeight = this.canvas.height * this.scale;
		this.ctx.save();
		this.ctx.translate(0,0);
		this.ctx.scale(1,1);
		this.ctx.clearRect(0,0,this.width,this.height);
		this.ctx.translate(this.translateX,this.translateY);
		this.ctx.scale(this.scale,this.scale);
		var radialRendererObj = new phylo.PhyloRadialTreeLayout(this.canvas.width,this.canvas.height);
		this.rootNode.screen = [];
		this.rootNode.rectangleLeft = this.rootNode.children[0].x | 0;
		this.rootNode.rectangleRight = this.rootNode.children[0].x | 0;
		this.rootNode.rectangleBottom = this.rootNode.children[0].y | 0;
		this.rootNode.rectangleTop = this.rootNode.children[0].y | 0;
		if(this.config.drawingMode == phylo.PhyloDrawingMode.CIRCULAR) radialRendererObj.renderCircle(this.rootNode,this,this.annotationManager.activeAnnotation,this.annotationManager.annotations); else radialRendererObj.render(this.rootNode,this,this.annotationManager.activeAnnotation,this.annotationManager.annotations);
		this.ctx.restore();
		this.config.dataChanged = false;
	}
	,setConfig: function(config) {
		this.config = config;
	}
	,getConfig: function() {
		return this.config;
	}
	,applyDefaultConfiguration: function() {
		if(this.config.enableShadow) {
			this.ctx.shadowOffsetX = 4;
			this.ctx.shadowOffsetY = 4;
			this.ctx.shadowBlur = 7;
			this.ctx.shadowColor = this.config.shadowColour;
		}
	}
	,checkPosition: function(e) {
		var i;
		var j;
		var sx;
		var sy;
		var res;
		res = false;
		var auxx;
		var auxy;
		var elementOffsetX = this.canvas.getBoundingClientRect().left - window.document.getElementsByTagName("html")[0].getBoundingClientRect().left;
		var auxx1 = e.clientX + window.pageXOffset - elementOffsetX - this.translateX;
		var elementOffsetY = this.canvas.getBoundingClientRect().top - window.document.getElementsByTagName("html")[0].getBoundingClientRect().top;
		var auxy1 = e.clientY + window.pageYOffset - elementOffsetY - this.translateY;
		var x;
		var y;
		x = auxx1 - Math.round(this.cx);
		y = auxy1 - Math.round(this.cy);
		var active;
		active = false;
		i = 0;
		while(i < this.rootNode.screen.length && res == false) {
			if(this.rootNode.screen[i].checkMouse(x,y) == true) {
				res = true;
				this.rootNode.screen[i].root = this.rootNode;
				this.rootNode.divactive = i;
			} else this.rootNode.screen[i].created = false;
			i = i + 1;
		}
		if(res == true) return this.rootNode.screen[i - 1]; else return null;
	}
	,setLineWidth: function(width) {
		this.rootNode.setLineWidth(width);
		this.redraw();
	}
	,toggleType: function() {
		this.dataChanged(true);
		this.translateX = 0;
		this.translateY = 0;
		if(this.config.drawingMode == phylo.PhyloDrawingMode.CIRCULAR) {
			this.config.drawingMode = phylo.PhyloDrawingMode.STRAIGHT;
			this.rootNode.preOrderTraversal2();
		} else {
			this.config.drawingMode = phylo.PhyloDrawingMode.CIRCULAR;
			this.rootNode.preOrderTraversal();
		}
		this.closeContextMenu();
		this.redraw();
	}
	,closeContextMenu: function() {
		if(this.contextMenu != null) {
			this.contextMenu.close();
			this.contextMenu = null;
		}
	}
	,toggleLineMode: function() {
		if(this.config.bezierLines) {
			this.rootNode.setLineMode(phylo.LineMode.STRAIGHT);
			this.config.bezierLines = false;
		} else {
			this.rootNode.setLineMode(phylo.LineMode.BEZIER);
			this.config.bezierLines = true;
		}
		this.redraw();
	}
	,rotateNode: function(node,clockwise) {
		node.rotateNode(clockwise,this.getConfig().drawingMode);
		this.redraw();
	}
	,setShadowColour: function(colour) {
		if(colour == null) {
			this.getConfig().shadowColour = null;
			this.getConfig().enableShadow = false;
		} else {
			this.getConfig().shadowColour = colour;
			this.getConfig().enableShadow = true;
		}
		this.redraw();
	}
	,toggleShadow: function() {
		this.getConfig().enableShadow = !this.getConfig().enableShadow;
		this.redraw();
	}
	,autoFit: function() {
		var minX = null;
		var maxX = null;
		var minY = null;
		var maxY = null;
		var screenDataList = this.rootNode.screen;
		var _g = 0;
		while(_g < screenDataList.length) {
			var screenData = screenDataList[_g];
			++_g;
			var x = screenData.x;
			var y = screenData.y;
			if(minX == null || x < minX) minX = x;
			if(maxX == null || x > maxX) maxX = x;
			if(minY == null || y < minY) minY = y;
			if(maxY == null || y > maxY) maxY = y;
		}
		var requiredWidth = maxX - minX + 300;
		var requiredHeight = maxY - minY + 300;
		var widthScale = 1.;
		var heightScale = 1.;
		widthScale = this.width / requiredWidth;
		heightScale = this.height / requiredHeight;
		var fitScale = 1.;
		if(widthScale < 1 || heightScale < 1) fitScale = Math.min(widthScale,heightScale);
		if(this.config.drawingMode != phylo.PhyloDrawingMode.CIRCULAR) {
		}
		if(fitScale == this.scale) {
		} else {
			this.config.autoFit = true;
			this.config.dataChanged = true;
			this.setScale(fitScale,false);
		}
	}
	,setScale: function(scale,disableAutoFit) {
		if(disableAutoFit == null) disableAutoFit = true;
		this.scale = scale;
		this.config.scale = scale;
		if(disableAutoFit) this.config.autoFit = false;
		this.redraw(true);
	}
	,dataChanged: function(changed) {
		this.getConfig().scale = 1;
		this.scale = 1;
		this.getConfig().dataChanged = changed;
	}
	,setNewickString: function(newickString) {
		var parser = new phylo.PhyloNewickParser();
		var rootNode = parser.parse(newickString);
		rootNode.calculateScale();
		rootNode.postOrderTraversal();
		if(this.config.drawingMode == phylo.PhyloDrawingMode.CIRCULAR) rootNode.preOrderTraversal(1); else rootNode.preOrderTraversal2(1);
		this.rootNode = rootNode;
		this.getAnnotationManager().setRootNode(rootNode);
		if(this.getAnnotationManager().getAnnotationString() != null) {
			this.getAnnotationManager().loadAnnotationsFromString(this.getAnnotationManager().getAnnotationString(),this.getAnnotationManager().getAnnotationConfigs());
			this.redraw(true);
		} else this.redraw(true);
	}
	,getAnnotationMenu: function() {
		return this.annotationMenu;
	}
	,setFromFasta: function(fasta) {
		var _g = this;
		saturn.client.BioinformaticsServicesClient.getClient().sendPhyloReportRequest(fasta,function(response,error) {
			var phyloReport = response.json.phyloReport;
			var location = window.location;
			var dstURL = location.protocol + "//" + location.hostname + ":" + location.port + "/" + phyloReport;
			var fetchFunc = fetch;
			fetchFunc(dstURL).then(function(response1) {
				response1.text().then(function(text) {
					_g.setNewickString(text);
					_g.rootNode.setFasta(fasta);
				});
			});
		});
	}
	,__class__: phylo.PhyloCanvasRenderer
};
phylo.PhyloCanvasConfiguration = $hxClasses["phylo.PhyloCanvasConfiguration"] = function() {
	this.enableFastaImport = false;
	this.enableImport = false;
	this.enableLegend = false;
	this.enableAnnotationMenu = false;
	this.dataChanged = false;
	this.autoFit = true;
	this.verticalToolBar = false;
	this.enableToolbar = false;
	this.enableTools = false;
	this.scale = 1;
	this.enableZoom = false;
	this.highlightedGenes = new haxe.ds.StringMap();
	this.editmode = false;
	this.drawingMode = phylo.PhyloDrawingMode.CIRCULAR;
	this.bezierLines = false;
	this.shadowColour = "gray";
	this.enableShadow = false;
};
phylo.PhyloCanvasConfiguration.__name__ = ["phylo","PhyloCanvasConfiguration"];
phylo.PhyloCanvasConfiguration.prototype = {
	enableShadow: null
	,shadowColour: null
	,bezierLines: null
	,drawingMode: null
	,editmode: null
	,highlightedGenes: null
	,enableZoom: null
	,scale: null
	,enableTools: null
	,enableToolbar: null
	,verticalToolBar: null
	,autoFit: null
	,dataChanged: null
	,title: null
	,enableAnnotationMenu: null
	,enableLegend: null
	,enableImport: null
	,enableFastaImport: null
	,__class__: phylo.PhyloCanvasConfiguration
};
phylo.PhyloDrawingMode = $hxClasses["phylo.PhyloDrawingMode"] = { __ename__ : ["phylo","PhyloDrawingMode"], __constructs__ : ["STRAIGHT","CIRCULAR"] };
phylo.PhyloDrawingMode.STRAIGHT = ["STRAIGHT",0];
phylo.PhyloDrawingMode.STRAIGHT.toString = $estr;
phylo.PhyloDrawingMode.STRAIGHT.__enum__ = phylo.PhyloDrawingMode;
phylo.PhyloDrawingMode.CIRCULAR = ["CIRCULAR",1];
phylo.PhyloDrawingMode.CIRCULAR.toString = $estr;
phylo.PhyloDrawingMode.CIRCULAR.__enum__ = phylo.PhyloDrawingMode;
phylo.PhyloContextMenu = $hxClasses["phylo.PhyloContextMenu"] = function(parent,canvas,node,data,e) {
	this.parent = parent;
	this.node = node;
	this.data = data;
	this.e = e;
	this.canvas = canvas;
	this.build();
};
phylo.PhyloContextMenu.__name__ = ["phylo","PhyloContextMenu"];
phylo.PhyloContextMenu.prototype = {
	contextContainer: null
	,parent: null
	,node: null
	,data: null
	,e: null
	,canvas: null
	,build: function() {
		this.addContainer();
		if(this.canvas.getConfig().drawingMode == phylo.PhyloDrawingMode.CIRCULAR) this.addWedgeOptions();
		this.addColourOption();
		if(this.canvas.getConfig().drawingMode == phylo.PhyloDrawingMode.STRAIGHT) this.addRotateNode();
		this.parent.appendChild(this.contextContainer);
	}
	,addContainer: function() {
		this.contextContainer = window.document.createElement("div");
		this.contextContainer.style.position = "absolute";
		this.contextContainer.style.left = this.e.offsetX;
		this.contextContainer.style.top = this.e.offsetY;
		this.contextContainer.style.background = "#f7f8fb";
		this.contextContainer.style.color = "black";
		this.contextContainer.style.padding = "4px";
	}
	,destroyContainer: function() {
		this.parent.removeChild(this.contextContainer);
		this.parent = null;
		this.node = null;
		this.data = null;
		this.e = null;
		this.canvas = null;
	}
	,close: function() {
		this.destroyContainer();
	}
	,addColourOption: function() {
		var _g = this;
		var rowContainer = window.document.createElement("div");
		var lineColourInputLabel = window.document.createElement("label");
		var lineColourRemoveButton = window.document.createElement("button");
		lineColourInputLabel.setAttribute("for","line_colour_input");
		lineColourInputLabel.innerText = "Pick line colour";
		lineColourInputLabel.style.width = "100px";
		lineColourInputLabel.style.display = "inline-block";
		var lineInputColour = window.document.createElement("input");
		lineInputColour.setAttribute("type","color");
		lineInputColour.setAttribute("name","line_colour_input");
		lineInputColour.style.width = "100px";
		lineInputColour.addEventListener("change",function() {
			_g.node.colour = lineInputColour.value;
			lineColourRemoveButton.style.display = "inline-block";
			_g.canvas.redraw();
		});
		rowContainer.appendChild(lineColourInputLabel);
		rowContainer.appendChild(lineInputColour);
		lineColourRemoveButton.setAttribute("for","wedge_colour_input");
		lineColourRemoveButton.innerText = "Remove";
		lineColourRemoveButton.style.marginLeft = "5px";
		lineColourRemoveButton.style.display = "none";
		lineColourRemoveButton.style.width = "100px";
		lineColourRemoveButton.addEventListener("click",function() {
			_g.node.colour = null;
			lineColourRemoveButton.style.display = "none";
			_g.canvas.redraw();
		});
		rowContainer.appendChild(lineColourRemoveButton);
		if(this.node.colour != null) lineColourRemoveButton.style.display = "inline-block";
		this.contextContainer.appendChild(rowContainer);
	}
	,addWedgeOptions: function() {
		var _g = this;
		var rowContainer = window.document.createElement("div");
		var wedgeInputLabel = window.document.createElement("label");
		var wedgeButtonLabel = window.document.createElement("button");
		wedgeInputLabel.setAttribute("for","wedge_colour_input");
		wedgeInputLabel.setAttribute("for","wedge_colour_input");
		wedgeInputLabel.innerText = "Pick wedge colour";
		wedgeInputLabel.style.width = "100px";
		wedgeInputLabel.style.display = "inline-block";
		var wedgeInputColour = window.document.createElement("input");
		wedgeInputColour.setAttribute("type","color");
		wedgeInputColour.setAttribute("name","wedge_colour_input");
		wedgeInputColour.style.width = "100px";
		wedgeInputColour.addEventListener("change",function() {
			_g.node.wedgeColour = wedgeInputColour.value;
			wedgeButtonLabel.style.display = "inline-block";
			_g.canvas.redraw();
		});
		rowContainer.appendChild(wedgeInputLabel);
		rowContainer.appendChild(wedgeInputColour);
		wedgeButtonLabel.setAttribute("for","wedge_colour_input");
		wedgeButtonLabel.setAttribute("for","wedge_colour_input");
		wedgeButtonLabel.innerText = "Remove";
		wedgeButtonLabel.style.marginLeft = "5px";
		wedgeButtonLabel.style.width = "100px";
		wedgeButtonLabel.style.display = "none";
		wedgeButtonLabel.addEventListener("click",function() {
			_g.node.wedgeColour = null;
			wedgeButtonLabel.style.display = "none";
			_g.canvas.redraw();
		});
		rowContainer.appendChild(wedgeButtonLabel);
		if(this.node.wedgeColour != null) wedgeButtonLabel.style.display = "inline-block";
		this.contextContainer.appendChild(rowContainer);
	}
	,addRotateNode: function() {
		var _g = this;
		var rowContainer = window.document.createElement("div");
		var label = window.document.createElement("label");
		label.innerText = "Rotate branch";
		label.style.display = "inline-block";
		label.style.width = "100px";
		rowContainer.appendChild(label);
		var rotateNodeClockwiseButton = window.document.createElement("button");
		rotateNodeClockwiseButton.innerText = "Clockwise";
		rotateNodeClockwiseButton.style.marginRight = "5px";
		rotateNodeClockwiseButton.style.width = "100px";
		rotateNodeClockwiseButton.style.display = "inline-block";
		rotateNodeClockwiseButton.addEventListener("click",function(e) {
			_g.canvas.rotateNode(_g.node,true);
		});
		rowContainer.appendChild(rotateNodeClockwiseButton);
		var rotateNodeAnticlockwiseButton = window.document.createElement("button");
		rotateNodeAnticlockwiseButton.innerText = "Anticlockwise";
		rotateNodeAnticlockwiseButton.style.marginRight = "5px";
		rotateNodeAnticlockwiseButton.style.width = "100px";
		rotateNodeAnticlockwiseButton.style.display = "inline-block";
		rotateNodeAnticlockwiseButton.addEventListener("click",function(e1) {
			_g.canvas.rotateNode(_g.node,false);
		});
		rowContainer.appendChild(rotateNodeAnticlockwiseButton);
		this.contextContainer.appendChild(rowContainer);
	}
	,__class__: phylo.PhyloContextMenu
};
phylo.PhyloWindowWidget = $hxClasses["phylo.PhyloWindowWidget"] = function(parent,title,modal) {
	if(modal == null) modal = false;
	this.parent = parent;
	this.title = title;
	this.modal = modal;
	this.build();
};
phylo.PhyloWindowWidget.__name__ = ["phylo","PhyloWindowWidget"];
phylo.PhyloWindowWidget.prototype = {
	container: null
	,content: null
	,parent: null
	,header: null
	,title: null
	,modal: null
	,onCloseFunc: null
	,setOnCloseEvent: function(func) {
		this.onCloseFunc = func;
	}
	,build: function() {
		this.addContainer();
		this.addWindowHeader();
		this.addContent();
		this.container.appendChild(this.content);
	}
	,getContainer: function() {
		return this.container;
	}
	,addContainer: function() {
		this.container = window.document.createElement("div");
		this.container.style.position = "fixed";
		this.container.style.zIndex = 1;
		this.container.style.paddingTop = "20px";
		this.container.style.left = 0;
		this.container.style.top = 0;
		this.container.style.minWidth = "200px";
		this.container.style.minHeight = "100px";
		this.container.style.backgroundColor = "rgb(247, 248, 251)";
		if(!this.isModal()) this.installMoveListeners();
		this.parent.appendChild(this.container);
	}
	,isModal: function() {
		return this.modal;
	}
	,addWindowHeader: function() {
		this.header = window.document.createElement("div");
		this.header.style.position = "absolute";
		this.header.style.top = "0px";
		this.header.style.backgroundColor = "rgb(125, 117, 117)";
		this.header.style.height = "20px";
		this.header.style.width = "100%";
		this.addTitle();
		this.addCloseButton();
		this.container.appendChild(this.header);
	}
	,addTitle: function() {
		var titleSpan = window.document.createElement("span");
		titleSpan.innerText = this.title;
		titleSpan.style.color = "white";
		titleSpan.style.fontSize = "16px";
		titleSpan.style.fontWeight = "bold";
		this.header.appendChild(titleSpan);
	}
	,addCloseButton: function() {
		var _g = this;
		var closeButton = window.document.createElement("span");
		closeButton.style.color = "white";
		closeButton.style["float"] = "right";
		closeButton.style.fontSize = "16px";
		closeButton.style.fontWeight = "bold";
		closeButton.innerHTML = "&times;";
		closeButton.style.cursor = "pointer";
		closeButton.addEventListener("click",function(e) {
			_g.close();
		});
		this.header.appendChild(closeButton);
	}
	,addContent: function() {
		this.content = window.document.createElement("div");
		this.content.style.backgroundColor = "#fefefe";
		this.content.style.width = "100%";
	}
	,close: function() {
		this.onClose();
		this.parent.removeChild(this.container);
	}
	,onClose: function() {
		if(this.onCloseFunc != null) this.onCloseFunc(this);
	}
	,installMoveListeners: function() {
		var _g = this;
		var isDown = false;
		var offsetX = 0.;
		var offsetY = 0.;
		var moveListener = function(event) {
			event.preventDefault();
			if(isDown) {
				_g.container.style.left = event.clientX + offsetX + "px";
				_g.container.style.top = event.clientY + offsetY + "px";
			}
		};
		this.container.addEventListener("mousedown",function(e) {
			isDown = true;
			offsetX = _g.container.offsetLeft - e.clientX;
			offsetY = _g.container.offsetTop - e.clientY;
			window.document.body.addEventListener("mousemove",moveListener);
		});
		this.container.addEventListener("mouseup",function() {
			isDown = false;
			window.document.body.removeEventListener("mousemove",moveListener);
		});
	}
	,__class__: phylo.PhyloWindowWidget
};
phylo.PhyloGlassPaneWidget = $hxClasses["phylo.PhyloGlassPaneWidget"] = function(parent,title,modal) {
	if(modal == null) modal = true;
	phylo.PhyloWindowWidget.call(this,parent,title,modal);
	this.container.style.width = "100%";
	this.container.style.height = "100%";
	this.container.style.backgroundColor = "rgba(0,0,0,0.4)";
	this.header.style.width = "50%";
	this.header.style.margin = "auto";
	this.header.style.position = "initial";
	this.header.style.padding = "20px";
	this.content.style.backgroundColor = "#fefefe";
	this.content.style.margin = "auto";
	this.content.style.padding = "20px";
	this.content.style.width = "50%";
};
phylo.PhyloGlassPaneWidget.__name__ = ["phylo","PhyloGlassPaneWidget"];
phylo.PhyloGlassPaneWidget.__super__ = phylo.PhyloWindowWidget;
phylo.PhyloGlassPaneWidget.prototype = $extend(phylo.PhyloWindowWidget.prototype,{
	addContainer: function() {
		phylo.PhyloWindowWidget.prototype.addContainer.call(this);
	}
	,__class__: phylo.PhyloGlassPaneWidget
});
phylo.PhyloHighlightWidget = $hxClasses["phylo.PhyloHighlightWidget"] = function(parent,canvas) {
	this.canvas = canvas;
	phylo.PhyloGlassPaneWidget.call(this,parent,"Select genes to highlight in tree",true);
};
phylo.PhyloHighlightWidget.__name__ = ["phylo","PhyloHighlightWidget"];
phylo.PhyloHighlightWidget.__super__ = phylo.PhyloGlassPaneWidget;
phylo.PhyloHighlightWidget.prototype = $extend(phylo.PhyloGlassPaneWidget.prototype,{
	highlightInputs: null
	,canvas: null
	,onClose: function() {
		this.canvas.getConfig().highlightedGenes = new haxe.ds.StringMap();
		var _g = 0;
		var _g1 = this.highlightInputs;
		while(_g < _g1.length) {
			var inputElement = _g1[_g];
			++_g;
			if(inputElement.checked) {
				var this1 = this.canvas.getConfig().highlightedGenes;
				var key = inputElement.getAttribute("value");
				this1.set(key,true);
			}
		}
		this.canvas.redraw();
	}
	,addContent: function() {
		phylo.PhyloGlassPaneWidget.prototype.addContent.call(this);
		this.addHighlightList();
	}
	,addHighlightList: function() {
		var formContainer = window.document.createElement("div");
		formContainer.setAttribute("id","highlight-box");
		formContainer.style.margin = "auto";
		formContainer.style.overflowY = "scroll";
		formContainer.style.height = "75%";
		this.highlightInputs = [];
		var targets = this.canvas.getRootNode().targets;
		targets.sort(function(a,b) {
			var targetA = a.toUpperCase();
			var targetB = b.toUpperCase();
			if(targetA < targetB) return -1; else if(targetA > targetB) return 1; else return 0;
		});
		var i = 0;
		var _g = 0;
		while(_g < targets.length) {
			var target = targets[_g];
			++_g;
			if(target == null || target == "") continue;
			i += 1;
			var elementWrapper = window.document.createElement("div");
			elementWrapper.setAttribute("class","element-wrapper");
			elementWrapper.style["float"] = "left";
			elementWrapper.style.marginRight = "28px";
			elementWrapper.style.marginBottom = "10px";
			var name = "target_highlight_" + i;
			var inputLabel = window.document.createElement("label");
			inputLabel.setAttribute("for",name);
			inputLabel.innerText = target;
			inputLabel.style["float"] = "left";
			inputLabel.style.width = "55px";
			inputLabel.style.margin = "0";
			var inputElement = window.document.createElement("input");
			inputElement.setAttribute("type","checkbox");
			inputElement.setAttribute("value",target);
			inputElement.setAttribute("name",name);
			inputElement.style.width = "15px";
			inputElement.style.height = "15px";
			inputElement.style.margin = "1px";
			this.highlightInputs.push(inputElement);
			formContainer.appendChild(elementWrapper);
			elementWrapper.appendChild(inputLabel);
			elementWrapper.appendChild(inputElement);
		}
		this.content.appendChild(formContainer);
	}
	,__class__: phylo.PhyloHighlightWidget
});
phylo.PhyloHubMath = $hxClasses["phylo.PhyloHubMath"] = function() { };
phylo.PhyloHubMath.__name__ = ["phylo","PhyloHubMath"];
phylo.PhyloHubMath.degreesToRadians = function(a) {
	return a * (Math.PI / 180);
};
phylo.PhyloHubMath.radiansToDegrees = function(b) {
	return b * (180 / Math.PI);
};
phylo.PhyloHubMath.getMaxOfArray = function(a) {
	var i;
	var n;
	n = a[0];
	var _g1 = 1;
	var _g = a.length;
	while(_g1 < _g) {
		var i1 = _g1++;
		if(n < a[i1]) n = a[i1];
	}
	return n;
};
phylo.PhyloImportWidget = $hxClasses["phylo.PhyloImportWidget"] = function(canvas) {
	this.canvas = canvas;
	this.build();
};
phylo.PhyloImportWidget.__name__ = ["phylo","PhyloImportWidget"];
phylo.PhyloImportWidget.prototype = {
	canvas: null
	,container: null
	,build: function() {
		this.addContainer();
	}
	,getContainer: function() {
		return this.container;
	}
	,addContainer: function() {
		this.container = window.document.createElement("div");
		this.container.style.display = "inline-block";
		this.container.style.minWidth = "160px";
		this.container.style.position = "relative";
		this.container.style.verticalAlign = "top";
		this.container.style.backgroundColor = "#f7f8fb";
		this.container.marginLeft = "0px";
		this.container.marginTop = "0px";
		this.container.innerHTML = "<h1 style=\"margin-left:5px;margin-right:5px\">Import</h1>";
		this.addButtons();
	}
	,addButtons: function() {
		this.addImportNewickButton();
		this.addImportAnnotationsButton();
		if(this.canvas.getConfig().enableFastaImport) this.addGenerateFromFASTAButton();
	}
	,addImportNewickButton: function() {
		var _g = this;
		var btn = window.document.createElement("button");
		btn.innerText = "Import Newick";
		btn.style.backgroundColor = "rgb(247, 248, 251)";
		btn.style.border = "none";
		btn.style.font = "normal 11px/16px tahoma, arial, verdana, sans-serif";
		btn.style.cursor = "pointer";
		btn.style.textAlign = "left";
		btn.style.width = "100%";
		btn.setAttribute("title","ImportNewick");
		btn.addEventListener("mouseover",function() {
			btn.style.backgroundColor = "#dddee1";
		});
		btn.addEventListener("mouseout",function() {
			btn.style.backgroundColor = "rgb(247, 248, 251)";
		});
		btn.addEventListener("click",function() {
			var dialog = new phylo.PhyloInputModalWidget(window.document.body,"Newick String","Enter newick string",_g.canvas.getRootNode().getNewickString());
			dialog.setOnCloseEvent($bind(_g,_g.updateTree));
		});
		this.container.appendChild(btn);
	}
	,updateTree: function(dialog) {
		this.canvas.setNewickString(dialog.getText());
	}
	,addImportAnnotationsButton: function() {
		var _g = this;
		var btn = window.document.createElement("button");
		btn.innerText = "Import Annotations";
		btn.style.backgroundColor = "rgb(247, 248, 251)";
		btn.style.border = "none";
		btn.style.font = "normal 11px/16px tahoma, arial, verdana, sans-serif";
		btn.style.cursor = "pointer";
		btn.style.textAlign = "left";
		btn.style.width = "100%";
		btn.setAttribute("title","ImportNewick");
		btn.addEventListener("mouseover",function() {
			btn.style.backgroundColor = "#dddee1";
		});
		btn.addEventListener("mouseout",function() {
			btn.style.backgroundColor = "rgb(247, 248, 251)";
		});
		btn.addEventListener("click",function() {
			var dialog = new phylo.PhyloInputModalWidget(window.document.body,"Annotations in CSV format (first column is gene name)","Enter Annotations",_g.canvas.getAnnotationManager().getAnnotationString());
			dialog.setOnCloseEvent($bind(_g,_g.updateAnnotations));
		});
		this.container.appendChild(btn);
	}
	,updateAnnotations: function(dialog) {
		this.canvas.getAnnotationManager().loadAnnotationsFromString(dialog.getText(),this.canvas.getAnnotationManager().getAnnotationConfigs());
	}
	,addGenerateFromFASTAButton: function() {
		var _g = this;
		var btn = window.document.createElement("button");
		btn.innerText = "Import FASTA";
		btn.style.backgroundColor = "rgb(247, 248, 251)";
		btn.style.border = "none";
		btn.style.font = "normal 11px/16px tahoma, arial, verdana, sans-serif";
		btn.style.cursor = "pointer";
		btn.style.textAlign = "left";
		btn.style.width = "100%";
		btn.setAttribute("title","Import Fasta");
		btn.addEventListener("mouseover",function() {
			btn.style.backgroundColor = "#dddee1";
		});
		btn.addEventListener("mouseout",function() {
			btn.style.backgroundColor = "rgb(247, 248, 251)";
		});
		btn.addEventListener("click",function() {
			var dialog = new phylo.PhyloInputModalWidget(window.document.body,"FASTA format","Enter sequences",_g.canvas.getRootNode().getFasta());
			dialog.setOnCloseEvent($bind(_g,_g.updateFASTA));
		});
		this.container.appendChild(btn);
	}
	,updateFASTA: function(dialog) {
		this.canvas.setFromFasta(dialog.getText());
	}
	,__class__: phylo.PhyloImportWidget
};
phylo.PhyloInputModalWidget = $hxClasses["phylo.PhyloInputModalWidget"] = function(parent,message,title,initialValue) {
	this.message = message;
	this.initialValue = initialValue;
	phylo.PhyloGlassPaneWidget.call(this,parent,title);
};
phylo.PhyloInputModalWidget.__name__ = ["phylo","PhyloInputModalWidget"];
phylo.PhyloInputModalWidget.__super__ = phylo.PhyloGlassPaneWidget;
phylo.PhyloInputModalWidget.prototype = $extend(phylo.PhyloGlassPaneWidget.prototype,{
	message: null
	,initialValue: null
	,textArea: null
	,addContent: function() {
		phylo.PhyloGlassPaneWidget.prototype.addContent.call(this);
		this.addMessage();
		this.addInputField();
	}
	,addMessage: function() {
		var p = window.document.createElement("p");
		p.innerText = this.message;
		this.content.appendChild(p);
	}
	,addInputField: function() {
		this.textArea = window.document.createElement("textarea");
		this.textArea.value = this.initialValue;
		this.textArea.style.width = "100%";
		this.textArea.setAttribute("rows","10");
		this.content.appendChild(this.textArea);
	}
	,getText: function() {
		return this.textArea.value;
	}
	,__class__: phylo.PhyloInputModalWidget
});
phylo.PhyloLegendRowWidget = $hxClasses["phylo.PhyloLegendRowWidget"] = function(legend,config) {
	this.legend = legend;
	this.config = config;
	this.build();
};
phylo.PhyloLegendRowWidget.__name__ = ["phylo","PhyloLegendRowWidget"];
phylo.PhyloLegendRowWidget.prototype = {
	legend: null
	,config: null
	,container: null
	,build: function() {
		this.addContainer();
		this.addLabel();
		this.addColourChooser();
	}
	,addContainer: function() {
		this.container = window.document.createElement("div");
		this.legend.getLegendContainer().appendChild(this.container);
	}
	,addLabel: function() {
		var label = window.document.createElement("span");
		label.innerText = this.config.name;
		label.style.marginLeft = "5px";
		label.style.width = "100px";
		label.style.display = "inline-block";
		this.container.appendChild(label);
	}
	,addColourChooser: function() {
		var _g = this;
		var picker = window.document.createElement("input");
		picker.setAttribute("type","color");
		picker.setAttribute("name","line_colour_input");
		picker.setAttribute("value",this.standardizeColour(this.config.colour));
		picker.style.width = "40px";
		picker.addEventListener("change",function() {
			_g.config.colour = picker.value;
			_g.legend.getCanvas().getAnnotationManager().reloadAnnotationConfigurations();
		});
		this.container.appendChild(picker);
	}
	,standardizeColour: function(colourStr) {
		var canvas = window.document.createElement("canvas");
		var ctx = canvas.getContext("2d");
		ctx.fillStyle = colourStr;
		return ctx.fillStyle;
	}
	,__class__: phylo.PhyloLegendRowWidget
};
phylo.PhyloLegendWidget = $hxClasses["phylo.PhyloLegendWidget"] = function(canvas) {
	this.canvas = canvas;
	this.build();
};
phylo.PhyloLegendWidget.__name__ = ["phylo","PhyloLegendWidget"];
phylo.PhyloLegendWidget.prototype = {
	canvas: null
	,container: null
	,legendContainer: null
	,build: function() {
		this.addContainer();
	}
	,getCanvas: function() {
		return this.canvas;
	}
	,getContainer: function() {
		return this.container;
	}
	,addContainer: function() {
		this.container = window.document.createElement("div");
		this.container.style.display = "inline-block";
		this.container.style.minWidth = "160px";
		this.container.style.position = "relative";
		this.container.style.verticalAlign = "top";
		this.container.style.height = "100%";
		this.container.style.backgroundColor = "#f7f8fb";
		this.container.marginLeft = "0px";
		this.container.marginTop = "0px";
		this.container.innerHTML = "<h1 style=\"margin-left:5px;margin-right:5px\">Legend</h1>";
		this.legendContainer = window.document.createElement("div");
		this.container.appendChild(this.legendContainer);
		this.redraw();
	}
	,clearLegendContainer: function() {
		while(this.legendContainer.firstChild) this.legendContainer.removeChild(this.legendContainer.firstChild);
	}
	,getLegendContainer: function() {
		return this.legendContainer;
	}
	,redraw: function() {
		this.clearLegendContainer();
		var annotationManager = this.canvas.getAnnotationManager();
		var activeAnnotations = annotationManager.getActiveAnnotations();
		var _g = 0;
		while(_g < activeAnnotations.length) {
			var annotationDef = activeAnnotations[_g];
			++_g;
			var config = this.canvas.getAnnotationManager().getAnnotationConfigByName(annotationDef.label);
			if(config.legendFunction != null) {
				var func = config.legendFunction;
				func(this,config);
			}
		}
	}
	,__class__: phylo.PhyloLegendWidget
};
phylo.PhyloNewickParser = $hxClasses["phylo.PhyloNewickParser"] = function() {
};
phylo.PhyloNewickParser.__name__ = ["phylo","PhyloNewickParser"];
phylo.PhyloNewickParser.prototype = {
	parse: function(newickString) {
		newickString = phylo.PhyloNewickParser.whiteSpaceReg.replace(newickString,"");
		newickString = phylo.PhyloNewickParser.newLineReg.replace(newickString,"");
		newickString = phylo.PhyloNewickParser.carLineReg.replace(newickString,"");
		var rootNode;
		rootNode = new phylo.PhyloTreeNode();
		rootNode.newickString = newickString;
		var currentNode = rootNode;
		var a;
		var branch;
		var charArray = newickString.split("");
		var j = 0;
		var _g1 = 0;
		var _g = charArray.length;
		while(_g1 < _g) {
			var j1 = _g1++;
			var i = j1;
			if(charArray[i] == "(" && charArray[i + 1] == "(") {
				var childNode = new phylo.PhyloTreeNode(currentNode,"",false,0);
				currentNode = childNode;
			} else if(charArray[i] == "(" && charArray[i + 1] != "(" && charArray[i - 1] != "/" || charArray[i] == "," && charArray[i + 1] != "(") {
				i++;
				var name = "";
				while(charArray[i] != ":" && charArray[i] != "," && (charArray[i] != ")" || charArray[i] == ")" && charArray[i - 1] == "/")) {
					var p = charArray[i];
					if(charArray[i] == "/" && (charArray[i + 1] == "[" || charArray[i + 1] == "(")) i++;
					if(charArray[i] == "[") name += "("; else if(charArray[i] == "]") name += ")"; else name += charArray[i];
					i++;
				}
				if(charArray[i] == ":") {
					i++;
					branch = "";
					while(charArray[i] != "," && (charArray[i] != ")" || charArray[i] == ")" && charArray[i - 1] == "/") && charArray[i] != ";") {
						branch += charArray[i];
						i++;
					}
					i--;
					branch = Std.parseFloat(branch);
				} else branch = 1;
				var child = new phylo.PhyloTreeNode(currentNode,name,true,branch);
			} else if(charArray[i] == "," && charArray[i + 1] == "(") {
				var child1 = new phylo.PhyloTreeNode(currentNode,"",false,0);
				currentNode = child1;
			} else if(charArray[i] == ")" && charArray[i - 1] != "/") {
				if(charArray[i + 1] == ":") {
					i += 2;
					branch = "";
					while(charArray[i] != "," && (charArray[i] != ")" || charArray[i] == ")" && charArray[i - 1] != "/") && charArray[i] != ";") {
						branch += charArray[i];
						i++;
					}
					i--;
					currentNode.branch = Std.parseFloat(branch);
				}
				currentNode = currentNode.parent;
			}
		}
		if(currentNode == null) return rootNode; else return currentNode;
	}
	,__class__: phylo.PhyloNewickParser
};
phylo.PhyloRadialTreeLayout = $hxClasses["phylo.PhyloRadialTreeLayout"] = function(width,height) {
	this.cx = width / 2;
	this.cy = height / 2;
};
phylo.PhyloRadialTreeLayout.__name__ = ["phylo","PhyloRadialTreeLayout"];
phylo.PhyloRadialTreeLayout.prototype = {
	cx: null
	,cy: null
	,annotations: null
	,renderCircle: function(treeNode,renderer,annotations,annotList,lineColour) {
		if(lineColour == null) lineColour = "rgb(28,102,224)";
		if(treeNode.colour != null) lineColour = treeNode.colour;
		this._renderCircle(treeNode,renderer,annotations,annotList,lineColour,lineColour);
	}
	,_renderCircle: function(treeNode,renderer,annotations,annotList,lineColour,parentColour) {
		if(parentColour == null) parentColour = "rgb(28,102,224)";
		if(lineColour == null) lineColour = "rgb(28,102,224)";
		var blue = "rgb(41,128,214)";
		var red = "rgb(255,0,0)";
		var black = "rgb(68,68,68)";
		if(treeNode.parent == null) {
		}
		treeNode.space = 0;
		var cx = renderer.cx;
		var cy = renderer.cy;
		var textSize = null;
		var branch = cx * 2 / treeNode.root.getHeight() / (4 - treeNode.root.getHeight() * 0.011);
		var k = 2 * Math.PI / treeNode.root.getLeafCount();
		var fontW = 12;
		var fontH = 12;
		var firstChild = treeNode.children[0];
		var lastChild = treeNode.children[treeNode.children.length - 1];
		var i = treeNode.angle;
		var _g = 0;
		var _g1 = treeNode.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			var childLineColour = lineColour;
			if(child.colour != null) childLineColour = child.colour;
			i = this._renderCircle(child,renderer,annotations,annotList,childLineColour,lineColour);
		}
		var h = null;
		var ph = null;
		var angle = null;
		var y1;
		var y2 = null;
		var x1;
		var x2 = null;
		if(treeNode.parent != null) {
			h = branch * (treeNode.root.getHeight() - treeNode.getHeight());
			ph = branch * (treeNode.root.getHeight() - treeNode.parent.getHeight());
			if(treeNode.wedgeColour != null) {
				var startNode = null;
				var endNode = null;
				if(!treeNode.isLeaf()) {
					startNode = treeNode.findLastLeaf();
					endNode = treeNode.findFirstLeaf();
				} else {
					startNode = treeNode.parent.findLastLeaf();
					endNode = treeNode.parent.findFirstLeaf();
				}
				var wedgeH = treeNode.root.getHeight() * (cx * 2 / treeNode.root.getHeight() / (4 - treeNode.root.getHeight() * 0.011));
				renderer.drawWedge(0,0,wedgeH,endNode.angle,startNode.angle,treeNode.wedgeColour,1);
			}
			if(treeNode.isLeaf()) angle = i; else {
				angle = (lastChild.angle - firstChild.angle) / 2 + firstChild.angle;
				if(Math.abs(phylo.PhyloHubMath.radiansToDegrees(lastChild.angle - firstChild.angle)) < 10) renderer.drawLine(firstChild.x,firstChild.y,lastChild.x,lastChild.y,lineColour,firstChild.lineWidth); else renderer.drawArc(0,0,h,firstChild.angle,lastChild.angle,lineColour,treeNode.lineWidth);
			}
			treeNode.angle = angle;
			if(angle == 0) {
				y1 = 0;
				y2 = 0;
			} else {
				y1 = h * Math.sin(angle);
				y2 = ph * Math.sin(angle);
			}
			x1 = h * Math.cos(angle);
			x2 = ph * Math.cos(angle);
			treeNode.x = x2;
			treeNode.y = y2;
			renderer.drawLine(x1,y1,x2,y2,lineColour,treeNode.lineWidth);
			if(treeNode.isLeaf()) {
				var dy = y1 - y2;
				var dx = x1 - x2;
				var x = 0;
				var y = 0;
				var gap = 2;
				var ta;
				if(dx < 0) {
					ta = Math.atan2(dy,dx) - Math.PI;
					x = -renderer.mesureText(treeNode.name) - gap;
				} else {
					ta = Math.atan2(dy,dx);
					x = gap;
				}
				y = 3;
				var labelColour = black;
				if((function($this) {
					var $r;
					var this1 = renderer.getConfig().highlightedGenes;
					$r = this1.exists(treeNode.name);
					return $r;
				}(this)) == true) labelColour = "red";
				renderer.drawTextNoTranslate(treeNode.name,x2 + dx,y2 + dy,x,y,ta,"top",labelColour);
				i += k;
				var t = treeNode.root.getMaximumLeafNameLength(renderer) + 10;
				treeNode.rad = ta;
				treeNode.x = x1;
				treeNode.y = y1;
				renderer.ctx.save();
				if(treeNode.y > y2 && treeNode.x > x2) treeNode.quad = 1;
				if(treeNode.y < y2 && treeNode.x > x2) treeNode.quad = 2;
				if(treeNode.y < y2 && treeNode.x < x2) treeNode.quad = 3;
				if(treeNode.y > y2 && treeNode.x < x2) treeNode.quad = 4;
				if(treeNode.y == y2 && treeNode.x > x2) treeNode.quad = 5;
				if(treeNode.y == y2 && treeNode.x < x2) treeNode.quad = 6;
				if(treeNode.y > y2 && treeNode.x == x2) treeNode.quad = 7;
				if(treeNode.y < y2 && treeNode.x == x2) treeNode.quad = 8;
				var j;
				var _g11 = 1;
				var _g2 = annotations.length;
				while(_g11 < _g2) {
					var j1 = _g11++;
					if(annotations[j1] == true) {
						var added;
						added = this.addAnnotation(treeNode,j1,t,renderer,annotList);
						if(treeNode.annotations[j1] != null && treeNode.annotations[j1].alfaAnnot[0] != null && treeNode.annotations[j1].alfaAnnot.length > 0) {
							var u = 0;
							if(added == true) treeNode.space = treeNode.space - 1;
							treeNode.space = treeNode.space + 1;
							var _g3 = 0;
							var _g21 = treeNode.annotations[j1].alfaAnnot.length;
							while(_g3 < _g21) {
								var u1 = _g3++;
								if(annotList[j1].shape == "text" && treeNode.quad == 2) treeNode.space = treeNode.space + 2; else if(annotList[j1].shape == "text" && treeNode.quad == 1) treeNode.space = treeNode.space + 2; else treeNode.space = treeNode.space + 1;
								added = this.addAlfaAnnotation(treeNode,treeNode.annotations[j1].alfaAnnot[u1],j1,t,renderer,annotList);
							}
							if(added == true) treeNode.space = treeNode.space + 1;
						} else if(added == true) treeNode.space = treeNode.space + 1;
					}
				}
				renderer.ctx.restore();
				treeNode.x = x2;
				treeNode.y = y2;
			}
		}
		var _g4 = 0;
		var _g12 = treeNode.children;
		while(_g4 < _g12.length) {
			var child1 = _g12[_g4];
			++_g4;
			var data;
			data = new phylo.PhyloScreenData();
			data.renderer = renderer;
			data.isAnnot = false;
			data.nodeId = child1.nodeId;
			data.point = 5;
			data.width = 10;
			data.height = 10;
			data.parentx = Math.round(treeNode.x);
			data.parenty = Math.round(treeNode.y);
			data.x = Math.round(child1.x);
			data.y = Math.round(child1.y);
			treeNode.root.screen[treeNode.root.screen.length] = data;
		}
		if(treeNode.parent == null) {
			var rootScreen = new phylo.PhyloScreenData();
			rootScreen.x = treeNode.x;
			rootScreen.y = treeNode.y;
			rootScreen.nodeId = treeNode.nodeId;
			rootScreen.renderer = renderer;
			rootScreen.point = 5;
			rootScreen.width = 10;
			rootScreen.height = 10;
			treeNode.screen.push(rootScreen);
		}
		return i;
	}
	,render: function(treeNode,renderer,annotations,annotList,lineColour) {
		if(lineColour == null) lineColour = "rgb(28,102,224)";
		var i = 0;
		var x = treeNode.x;
		var y = treeNode.y;
		if(renderer.getConfig().editmode == true) lineColour = "rgb(234,147,28)";
		while(i < treeNode.children.length) {
			treeNode.children[i].space = 0;
			if(treeNode.children[i].isLeaf()) {
				if(treeNode.children[i].lineMode == phylo.LineMode.BEZIER) {
					var deltaX1 = Math.abs(x - treeNode.children[i].x);
					var deltaY1 = Math.abs(y - treeNode.children[i].y);
					var firstY;
					var secondY;
					var firstX;
					var secondX;
					if(treeNode.children[i].xRandom == null) treeNode.children[i].xRandom = Math.random() * 0.3 + 0.3;
					if(treeNode.children[i].yRandom == null) treeNode.children[i].yRandom = Math.random() * 0.4 + 0.4;
					if(treeNode.children[i].y < y) {
						firstY = y - deltaY1 * treeNode.children[i].yRandom;
						secondY = treeNode.children[i].y + deltaY1 * treeNode.children[i].yRandom;
					} else {
						firstY = y + deltaY1 * treeNode.children[i].yRandom;
						secondY = treeNode.children[i].y - deltaY1 * treeNode.children[i].yRandom;
					}
					if(treeNode.children[i].x > x) {
						firstX = x + deltaX1 * 0.6;
						secondX = treeNode.children[i].x - deltaX1 * treeNode.children[i].xRandom;
					} else {
						firstX = x - deltaX1 * 0.6;
						secondX = treeNode.children[i].x + deltaX1 * treeNode.children[i].xRandom;
					}
					renderer.bezierCurve(x,y,treeNode.children[i].x,treeNode.children[i].y,firstX,firstY,secondX,secondY,lineColour,treeNode.children[i].lineWidth);
				} else renderer.drawLine(x,y,treeNode.children[i].x,treeNode.children[i].y,lineColour,treeNode.children[i].lineWidth);
				var t;
				var aux;
				var aux1;
				var yequalsign = false;
				if(treeNode.children[i].y > 0 && y > 0) yequalsign = true; else if(treeNode.children[i].y < 0 && y < 0) yequalsign = true;
				var xequalsign = false;
				if(treeNode.children[i].x > 0 && x > 0) xequalsign = true; else if(treeNode.children[i].x < 0 && x < 0) xequalsign = true;
				var deltaY;
				var deltaX;
				if(xequalsign == true) deltaX = Math.abs(treeNode.children[i].x - x); else deltaX = Math.abs(treeNode.children[i].x) + Math.abs(x);
				if(yequalsign == true) deltaY = Math.abs(treeNode.children[i].y - y); else deltaY = Math.abs(treeNode.children[i].y) + Math.abs(y);
				var tang = deltaY / deltaX;
				treeNode.children[i].rad = Math.atan(tang);
				var rot;
				rot = 0;
				var orign = "start";
				if(treeNode.children[i].y > y && treeNode.children[i].x > x) {
					rot = treeNode.children[i].rad;
					orign = "start";
					treeNode.children[i].quad = 1;
				}
				if(treeNode.children[i].y < y && treeNode.children[i].x > x) {
					rot = 2 * Math.PI - treeNode.children[i].rad;
					orign = "start";
					treeNode.children[i].quad = 2;
				}
				if(treeNode.children[i].y < y && treeNode.children[i].x < x) {
					rot = treeNode.children[i].rad;
					orign = "end";
					treeNode.children[i].quad = 3;
				}
				if(treeNode.children[i].y > y && treeNode.children[i].x < x) {
					rot = 2 * Math.PI - treeNode.children[i].rad;
					orign = "end";
					treeNode.children[i].quad = 4;
				}
				if(treeNode.children[i].y == y && treeNode.children[i].x > x) {
					treeNode.children[i].quad = 5;
					rot = 0;
				}
				if(treeNode.children[i].y == y && treeNode.children[i].x < x) {
					treeNode.children[i].quad = 6;
					rot = Math.PI;
				}
				if(treeNode.children[i].y > y && treeNode.children[i].x == x) {
					rot = 3 * Math.PI - Math.PI / 2;
					treeNode.children[i].quad = 7;
				}
				if(treeNode.children[i].y < y && treeNode.children[i].x == x) {
					treeNode.children[i].quad = 8;
					rot = 3 * Math.PI / 4;
				}
				var namecolor = "#585b5f";
				var ttar = treeNode.children[i].name;
				if((function($this) {
					var $r;
					var this1 = renderer.getConfig().highlightedGenes;
					$r = this1.exists(ttar);
					return $r;
				}(this)) == true) namecolor = "#ff0000";
				renderer.drawText(" " + treeNode.children[i].name,treeNode.children[i].x,treeNode.children[i].y,-2,3,rot,orign,namecolor);
				this.updateTreeRectangle(treeNode.children[i].x,treeNode.children[i].y,treeNode.root);
				t = renderer.mesureText(treeNode.children[i].name) + 10;
				treeNode.children[i].rad = rot;
				var j;
				var _g1 = 1;
				var _g = annotations.length;
				while(_g1 < _g) {
					var j1 = _g1++;
					if(annotations[j1] == true) {
						var added;
						added = this.addAnnotation(treeNode.children[i],j1,t,renderer,annotList);
						if(treeNode.children[i].annotations[j1] != null && treeNode.children[i].annotations[j1].alfaAnnot[0] != null && treeNode.children[i].annotations[j1].alfaAnnot.length > 0) {
							var u = 0;
							if(added == true) treeNode.children[i].space = treeNode.children[i].space - 1;
							treeNode.children[i].space = treeNode.children[i].space + 1;
							var _g3 = 0;
							var _g2 = treeNode.children[i].annotations[j1].alfaAnnot.length;
							while(_g3 < _g2) {
								var u1 = _g3++;
								if(annotList[j1].shape == "text" && treeNode.children[i].quad == 2) treeNode.children[i].space = treeNode.children[i].space + 2; else if(annotList[j1].shape == "text" && treeNode.children[i].quad == 1) treeNode.children[i].space = treeNode.children[i].space + 2; else treeNode.children[i].space = treeNode.children[i].space + 1;
								added = this.addAlfaAnnotation(treeNode.children[i],treeNode.children[i].annotations[j1].alfaAnnot[u1],j1,t,renderer,annotList);
							}
							if(added == true) treeNode.children[i].space = treeNode.children[i].space + 1;
						} else if(added == true) treeNode.children[i].space = treeNode.children[i].space + 1;
					}
				}
			} else {
				var childLineColour = lineColour;
				if(treeNode.children[i].colour != null) childLineColour = treeNode.children[i].colour;
				this.render(treeNode.children[i],renderer,annotations,annotList,childLineColour);
				if(treeNode.children[i].lineMode == phylo.LineMode.BEZIER) {
					var deltaX2 = Math.abs(x - treeNode.children[i].x);
					var deltaY2 = Math.abs(y - treeNode.children[i].y);
					var firstY1;
					var secondY1;
					var firstX1;
					var secondX1;
					if(treeNode.children[i].xRandom == null) treeNode.children[i].xRandom = Math.random() * 0.3 + 0.3;
					if(treeNode.children[i].yRandom == null) treeNode.children[i].yRandom = Math.random() * 0.4 + 0.4;
					if(treeNode.children[i].y < y) {
						firstY1 = y - deltaY2 * treeNode.children[i].yRandom;
						secondY1 = treeNode.children[i].y + deltaY2 * treeNode.children[i].yRandom;
					} else {
						firstY1 = y + deltaY2 * treeNode.children[i].yRandom;
						secondY1 = treeNode.children[i].y - deltaY2 * treeNode.children[i].yRandom;
					}
					if(treeNode.children[i].x > x) {
						firstX1 = x + deltaX2 * 0.6;
						secondX1 = treeNode.children[i].x - deltaX2 * treeNode.children[i].xRandom;
					} else {
						firstX1 = x - deltaX2 * 0.6;
						secondX1 = treeNode.children[i].x + deltaX2 * treeNode.children[i].xRandom;
					}
					renderer.bezierCurve(x,y,treeNode.children[i].x,treeNode.children[i].y,firstX1,firstY1,secondX1,secondY1,lineColour,treeNode.children[i].lineWidth);
				} else renderer.drawLine(x,y,treeNode.children[i].x,treeNode.children[i].y,lineColour,treeNode.children[i].lineWidth);
				var data;
				data = new phylo.PhyloScreenData();
				data.renderer = renderer;
				data.isAnnot = false;
				data.nodeId = treeNode.children[i].nodeId;
				data.point = 5;
				data.width = 10;
				data.height = 10;
				data.parentx = Math.round(x);
				data.parenty = Math.round(y);
				data.x = Math.round(treeNode.children[i].x);
				data.y = Math.round(treeNode.children[i].y);
				treeNode.root.screen[treeNode.root.screen.length] = data;
			}
			i++;
		}
		if(treeNode.parent == null) {
			var rootScreen = new phylo.PhyloScreenData();
			rootScreen.x = treeNode.x;
			rootScreen.y = treeNode.y;
			rootScreen.nodeId = treeNode.nodeId;
			rootScreen.renderer = renderer;
			rootScreen.point = 5;
			rootScreen.width = 10;
			rootScreen.height = 10;
			treeNode.screen.push(rootScreen);
		}
	}
	,addAnnotation: function(leave,annotation,$long,renderer,annotList) {
		if(annotList[annotation].optionSelected.length != 0) {
			if(leave.annotations[annotation] != null) {
				if(annotList[annotation].optionSelected[0] != leave.annotations[annotation].option) return false;
			}
		}
		var res = false;
		var data;
		data = new phylo.PhyloScreenData();
		data.renderer = renderer;
		data.target = leave.name;
		data.isAnnot = true;
		var name;
		name = "";
		if(leave.name.indexOf("(") != -1 || leave.name.indexOf("-") != -1) {
			var auxArray = leave.name.split("");
			var j;
			var _g1 = 0;
			var _g = auxArray.length;
			while(_g1 < _g) {
				var j1 = _g1++;
				if(auxArray[j1] == "(" || auxArray[j1] == "-") break;
				name += auxArray[j1];
			}
			data.targetClean = name;
		} else data.targetClean = leave.name;
		data.annot = annotation;
		data.annotation = leave.annotations[annotation];
		var nx;
		var ny;
		nx = 0.0;
		ny = 0.0;
		if(leave.space == 0) $long = $long + 1;
		var rootN = leave.root;
		var _g2 = annotList[annotation].shape;
		switch(_g2) {
		case "cercle":
			if(leave.activeAnnotation[annotation] == true) {
				if(leave.annotations[annotation].hasAnnot == true) {
					var _g11 = leave.quad;
					switch(_g11) {
					case 1:
						$long = $long + 23 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * ($long + 3);
						ny = leave.y + Math.sin(leave.rad) * ($long + 3);
						break;
					case 2:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * ($long + 3);
						ny = leave.y + Math.sin(leave.rad) * ($long + 3);
						break;
					case 3:
						$long = $long + 23 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * ($long + 3);
						nx = leave.x - Math.cos(leave.rad) * ($long + 3);
						break;
					case 4:
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * ($long + 3);
						nx = leave.x - Math.cos(leave.rad) * ($long + 3);
						break;
					case 5:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x + Math.cos(leave.rad) * $long;
						break;
					case 6:
						ny = leave.y;
						$long = $long + 20 * leave.space;
						nx = leave.x - Math.cos(leave.rad) * $long;
						break;
					case 7:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y + Math.sin(leave.rad) * $long;
						break;
					case 8:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * $long;
						break;
					}
					if(leave.space == 0) $long = $long + 1;
					renderer.drawCircle(nx,ny,leave.annotations[annotation].color[0].color);
					data.x = Math.round(nx);
					data.y = Math.round(ny);
					data.width = 14;
					data.height = 14;
					data.point = 3;
					res = true;
				} else return false;
			}
			break;
		case "image":
			if(leave.activeAnnotation[annotation] == true) {
				if(leave.annotations[annotation].hasAnnot == true) {
					if(annotList[annotation].annotImg[leave.annotations[annotation].defaultImg] != null) {
						var _g12 = leave.quad;
						switch(_g12) {
						case 1:
							$long = $long + 20 * leave.space;
							nx = leave.x + Math.cos(leave.rad) * $long;
							ny = leave.y + Math.sin(leave.rad) * $long;
							break;
						case 2:
							$long = $long + 20 * leave.space;
							nx = leave.x - 5 + Math.cos(leave.rad) * $long;
							ny = leave.y - 12 + Math.sin(leave.rad) * $long;
							break;
						case 3:
							$long = $long + 23 * leave.space;
							ny = leave.y - 12 - Math.sin(leave.rad) * $long;
							nx = leave.x - 10 - Math.cos(leave.rad) * $long;
							break;
						case 4:
							$long = $long + 23 * leave.space;
							ny = leave.y - Math.sin(leave.rad) * $long;
							nx = leave.x - 10 - Math.cos(leave.rad) * $long;
							break;
						case 5:
							$long = $long + 20 * leave.space;
							ny = leave.y;
							nx = leave.x + Math.cos(leave.rad) * $long;
							break;
						case 6:
							$long = $long + 20 * leave.space;
							ny = leave.y;
							nx = leave.x - Math.cos(leave.rad) * $long;
							break;
						case 7:
							$long = $long + 20 * leave.space;
							nx = leave.x;
							ny = leave.y + Math.sin(leave.rad) * $long;
							break;
						case 8:
							$long = $long + 20 * leave.space;
							nx = leave.x;
							ny = leave.y - Math.sin(leave.rad) * $long;
							break;
						}
						if(leave.space == 0) $long = $long + 1;
						var imge = annotList[annotation].annotImg[leave.annotations[annotation].defaultImg];
						if(imge != null) {
							if(annotation == 1) renderer.drawImg(nx,ny,imge,1); else renderer.drawImg(nx,ny,imge,0);
							data.x = Math.round(nx);
							data.y = Math.round(ny);
							data.width = 14;
							data.height = 14;
							data.point = 1;
						}
					}
					res = true;
				} else return false;
			}
			break;
		case "square":
			if(leave.activeAnnotation[annotation] == true) {
				if(leave.annotations[annotation].hasAnnot == true) {
					var _g13 = leave.quad;
					switch(_g13) {
					case 1:
						$long = $long + 23 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * $long;
						ny = leave.y + Math.sin(leave.rad) * $long;
						break;
					case 2:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * $long;
						ny = leave.y - 12 + Math.sin(leave.rad) * $long;
						break;
					case 3:
						$long = $long + 23 * leave.space;
						ny = leave.y - 12 - Math.sin(leave.rad) * $long;
						nx = leave.x - 10 - Math.cos(leave.rad) * $long;
						break;
					case 4:
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * $long;
						nx = leave.x - Math.cos(leave.rad) * $long;
						break;
					case 5:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x + Math.cos(leave.rad) * $long;
						break;
					case 6:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x - Math.cos(leave.rad) * $long;
						break;
					case 7:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y + Math.sin(leave.rad) * $long;
						break;
					case 8:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * $long;
						break;
					}
					if(leave.space == 0) $long = $long + 1;
					renderer.drawSquare(nx,ny,leave.annotations[annotation].color[0].color);
					data.x = Math.round(nx);
					data.y = Math.round(ny);
					data.width = 14;
					data.height = 10;
					data.point = 4;
					res = true;
				} else return false;
			}
			break;
		case "html":
			if(leave.activeAnnotation[annotation] == true) {
				if(leave.annotations[annotation].hasAnnot == true) {
					var _g14 = leave.quad;
					switch(_g14) {
					case 1:
						$long = $long + 23 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * $long;
						ny = leave.y + Math.sin(leave.rad) * $long;
						break;
					case 2:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * $long;
						ny = leave.y - 12 + Math.sin(leave.rad) * $long;
						break;
					case 3:
						$long = $long + 23 * leave.space;
						ny = leave.y - 12 - Math.sin(leave.rad) * $long;
						nx = leave.x - 10 - Math.cos(leave.rad) * $long;
						break;
					case 4:
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * $long;
						nx = leave.x - Math.cos(leave.rad) * $long;
						break;
					case 5:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x + Math.cos(leave.rad) * $long;
						break;
					case 6:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x - Math.cos(leave.rad) * $long;
						break;
					case 7:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y + Math.sin(leave.rad) * $long;
						break;
					case 8:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * $long;
						break;
					}
					if(leave.space == 0) $long = $long + 1;
					renderer.drawGraphic(nx,ny,leave.results);
					data.x = Math.round(nx);
					data.y = Math.round(ny);
					data.width = 14;
					data.height = 10;
					data.point = 4;
					res = true;
				} else return false;
			}
			break;
		case "text":
			if(leave.activeAnnotation[annotation] == true) {
				if(leave.annotations[annotation].hasAnnot == true) {
					var _g15 = leave.quad;
					switch(_g15) {
					case 1:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * ($long + 10);
						ny = leave.y + Math.sin(leave.rad) * ($long + 10);
						break;
					case 2:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * ($long + 10);
						ny = leave.y + Math.sin(leave.rad) * ($long + 10);
						break;
					case 3:
						$long = $long + 23 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * ($long + 10);
						nx = leave.x - Math.cos(leave.rad) * ($long + 10);
						break;
					case 4:
						$long = $long + 23 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * ($long + 10);
						nx = leave.x - Math.cos(leave.rad) * ($long + 10);
						break;
					case 5:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x + Math.cos(leave.rad) * ($long + 10);
						break;
					case 6:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x - Math.cos(leave.rad) * ($long + 10);
						break;
					case 7:
						$long = $long + 20 * leave.space;
						nx = leave.x;
						ny = leave.y + Math.sin(leave.rad) * ($long + 10);
						break;
					case 8:
						$long = $long + 20 * leave.space;
						nx = leave.x;
						ny = leave.y - Math.sin(leave.rad) * ($long + 5);
						break;
					}
					renderer.drawText(leave.annotations[annotation].text,nx,ny,-2,3,0,"start",leave.annotations[annotation].color[0].color);
					data.x = Math.round(nx);
					data.y = Math.round(ny);
					data.width = 7 * leave.annotations[annotation].text.length;
					data.height = 7;
					data.point = 2;
					res = true;
				} else return false;
			}
			break;
		}
		leave.root.screen[leave.root.screen.length] = data;
		return res;
	}
	,addAlfaAnnotation: function(leave,alfaAnnot,annotation,$long,renderer,annotList) {
		var res = false;
		var data;
		var nx;
		var ny;
		nx = 0.0;
		ny = 0.0;
		data = new phylo.PhyloScreenData();
		data.renderer = renderer;
		data.target = leave.name;
		data.isAnnot = true;
		var name;
		name = "";
		if(leave.name.indexOf("(") != -1 || leave.name.indexOf("-") != -1) {
			var auxArray = leave.name.split("");
			var j;
			var _g1 = 0;
			var _g = auxArray.length;
			while(_g1 < _g) {
				var j1 = _g1++;
				if(auxArray[j1] == "(" || auxArray[j1] == "-") break;
				name += auxArray[j1];
			}
			data.targetClean = name;
		} else data.targetClean = leave.name;
		data.annot = annotation;
		data.annotation = alfaAnnot;
		data.suboption = alfaAnnot.option;
		var _g2 = annotList[annotation].shape;
		switch(_g2) {
		case "cercle":
			if(leave.activeAnnotation[annotation] == true) {
				if(alfaAnnot.hasAnnot == true) {
					var _g11 = leave.quad;
					switch(_g11) {
					case 1:
						$long = $long + 23 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * ($long + 3);
						ny = leave.y + Math.sin(leave.rad) * ($long + 3);
						break;
					case 2:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * ($long + 3);
						ny = leave.y + Math.sin(leave.rad) * ($long + 3);
						break;
					case 3:
						$long = $long + 23 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * ($long + 3);
						nx = leave.x - Math.cos(leave.rad) * ($long + 3);
						break;
					case 4:
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * ($long + 3);
						nx = leave.x - Math.cos(leave.rad) * ($long + 3);
						break;
					case 5:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x + Math.cos(leave.rad) * $long;
						break;
					case 6:
						ny = leave.y;
						$long = $long + 20 * leave.space;
						nx = leave.x - Math.cos(leave.rad) * $long;
						break;
					case 7:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y + Math.sin(leave.rad) * $long;
						break;
					case 8:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * $long;
						break;
					case 9:
						$long = $long = $long + 20 * leave.space;
						break;
					}
					if(leave.space == 0) $long = $long + 1;
					if(leave.quad == 9) renderer.drawCircle(leave.x + $long,leave.y,alfaAnnot.color[0].color); else renderer.drawCircle(nx,ny,alfaAnnot.color[0].color);
					var aux = nx * renderer.scale;
					data.x = Math.round(aux) - 29;
					aux = ny * renderer.scale;
					data.y = Math.round(aux) - 3;
					aux = 10 * renderer.scale;
					data.width = Math.round(aux);
					data.height = Math.round(aux);
					data.point = 4;
					res = true;
				} else return false;
			}
			break;
		case "image":
			if(leave.activeAnnotation[annotation] == true) {
				if(alfaAnnot.hasAnnot == true) {
					if(annotList[annotation].annotImg[alfaAnnot.defaultImg] != null) {
						var _g12 = leave.quad;
						switch(_g12) {
						case 1:
							$long = $long + 20 * leave.space;
							nx = leave.x + Math.cos(leave.rad) * $long;
							ny = leave.y + Math.sin(leave.rad) * $long;
							break;
						case 2:
							$long = $long + 20 * leave.space;
							nx = leave.x - 5 + Math.cos(leave.rad) * $long;
							ny = leave.y - 12 + Math.sin(leave.rad) * $long;
							break;
						case 3:
							$long = $long + 23 * leave.space;
							ny = leave.y - 12 - Math.sin(leave.rad) * $long;
							nx = leave.x - 10 - Math.cos(leave.rad) * $long;
							break;
						case 4:
							$long = $long + 23 * leave.space;
							ny = leave.y - Math.sin(leave.rad) * $long;
							nx = leave.x - 10 - Math.cos(leave.rad) * $long;
							break;
						case 5:
							$long = $long + 20 * leave.space;
							ny = leave.y;
							nx = leave.x + Math.cos(leave.rad) * $long;
							break;
						case 6:
							$long = $long + 20 * leave.space;
							ny = leave.y;
							nx = leave.x - Math.cos(leave.rad) * $long;
							break;
						case 7:
							$long = $long + 20 * leave.space;
							nx = leave.x;
							ny = leave.y + Math.sin(leave.rad) * $long;
							break;
						case 8:
							$long = $long + 20 * leave.space;
							nx = leave.x;
							ny = leave.y - Math.sin(leave.rad) * $long;
							break;
						}
						var imge = annotList[annotation].annotImg[alfaAnnot.defaultImg];
						if(imge != null) {
							if(annotation == 1) renderer.drawImg(nx,ny,imge,1); else renderer.drawImg(nx,ny,imge,0);
							var aux1 = nx * renderer.scale;
							data.x = Math.round(aux1);
							aux1 = ny * renderer.scale;
							data.y = Math.round(aux1);
							aux1 = 14 * renderer.scale;
							data.width = Math.round(aux1);
							aux1 = 14 * renderer.scale;
							data.height = Math.round(aux1);
							data.point = 1;
						}
					}
					res = true;
				} else return false;
			}
			break;
		case "square":
			if(leave.activeAnnotation[annotation] == true) {
				if(alfaAnnot.hasAnnot == true) {
					var _g13 = leave.quad;
					switch(_g13) {
					case 1:
						$long = $long + 23 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * $long;
						ny = leave.y + Math.sin(leave.rad) * $long;
						break;
					case 2:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * $long;
						ny = leave.y - 12 + Math.sin(leave.rad) * $long;
						break;
					case 3:
						$long = $long + 23 * leave.space;
						ny = leave.y - 12 - Math.sin(leave.rad) * $long;
						nx = leave.x - 10 - Math.cos(leave.rad) * $long;
						break;
					case 4:
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * $long;
						nx = leave.x - Math.cos(leave.rad) * $long;
						break;
					case 5:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x + Math.cos(leave.rad) * $long;
						break;
					case 6:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x - Math.cos(leave.rad) * $long;
						break;
					case 7:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y + Math.sin(leave.rad) * $long;
						break;
					case 8:
						nx = leave.x;
						$long = $long + 20 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * $long;
						break;
					}
					if(leave.space == 0) $long = $long + 1;
					renderer.drawSquare(nx,ny,alfaAnnot.color[0].color);
					data.point = 1;
					var aux2 = nx * renderer.scale;
					data.x = Math.round(aux2);
					aux2 = ny * renderer.scale;
					data.y = Math.round(aux2);
					aux2 = 20 * renderer.scale;
					data.width = Math.round(aux2);
					aux2 = 20 * renderer.scale;
					data.height = Math.round(aux2);
					res = true;
				} else return false;
			}
			break;
		case "text":
			if(leave.activeAnnotation[annotation] == true) {
				if(alfaAnnot.hasAnnot == true) {
					if(alfaAnnot.text == "H4K5/12") {
						var i = 0;
						var u = 0;
						var ii = 0;
					}
					var _g14 = leave.quad;
					switch(_g14) {
					case 1:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * ($long + 10);
						ny = leave.y + Math.sin(leave.rad) * ($long + 10);
						break;
					case 2:
						$long = $long + 20 * leave.space;
						nx = leave.x + Math.cos(leave.rad) * ($long + 10);
						ny = leave.y + Math.sin(leave.rad) * ($long + 10);
						break;
					case 3:
						$long = $long + 23 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * ($long + 10);
						nx = leave.x - Math.cos(leave.rad) * ($long + 10);
						break;
					case 4:
						$long = $long + 23 * leave.space;
						ny = leave.y - Math.sin(leave.rad) * ($long + 10);
						nx = leave.x - Math.cos(leave.rad) * ($long + 10);
						break;
					case 5:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x + Math.cos(leave.rad) * ($long + 10);
						break;
					case 6:
						$long = $long + 20 * leave.space;
						ny = leave.y;
						nx = leave.x - Math.cos(leave.rad) * ($long + 10);
						break;
					case 7:
						$long = $long + 20 * leave.space;
						nx = leave.x;
						ny = leave.y + Math.sin(leave.rad) * ($long + 10);
						break;
					case 8:
						$long = $long + 20 * leave.space;
						nx = leave.x;
						ny = leave.y - Math.sin(leave.rad) * ($long + 5);
						break;
					}
					renderer.drawText(alfaAnnot.text,nx,ny,-2,3,0,"start",alfaAnnot.color[0].color);
					var aux3 = nx * renderer.scale;
					data.x = Math.round(nx);
					data.y = Math.round(ny);
					data.width = 7 * alfaAnnot.text.length;
					data.y = Math.round(ny);
					data.height = 7;
					data.point = 2;
					res = true;
				} else return false;
			}
			break;
		}
		leave.root.screen[leave.root.screen.length] = data;
		return res;
	}
	,updateTreeRectangle: function(x,y,treeNode) {
		var top;
		top = treeNode.rectangleTop | 0;
		var right;
		right = treeNode.rectangleRight | 0;
		var bottom;
		bottom = treeNode.rectangleBottom | 0;
		var left;
		left = treeNode.rectangleLeft | 0;
		x = x | 0;
		y = y | 0;
		if(x < left) treeNode.rectangleLeft = x;
		if(x > right) treeNode.rectangleRight = x;
		if(y < bottom) treeNode.rectangleBottom = y;
		if(y > top) treeNode.rectangleTop = y;
	}
	,__class__: phylo.PhyloRadialTreeLayout
};
phylo.PhyloScreenData = $hxClasses["phylo.PhyloScreenData"] = function() {
	this.suboption = 0;
	this.annotation = new phylo.PhyloAnnotation();
	this.created = false;
	this.divAccessed = false;
};
phylo.PhyloScreenData.__name__ = ["phylo","PhyloScreenData"];
phylo.PhyloScreenData.prototype = {
	point: null
	,x: null
	,y: null
	,parentx: null
	,parenty: null
	,width: null
	,height: null
	,annotation: null
	,created: null
	,target: null
	,targetClean: null
	,annot: null
	,divAccessed: null
	,suboption: null
	,renderer: null
	,isAnnot: null
	,nodeId: null
	,checkMouse: function(mx,my) {
		var scaleX = this.x * this.renderer.scale;
		var scaleY = this.y * this.renderer.scale;
		var scaleWidth = this.width * this.renderer.scale;
		var scaleHeight = this.height * this.renderer.scale;
		var _g = this.point;
		switch(_g) {
		case 1:
			if(mx >= scaleX && mx < scaleX + scaleWidth && my < scaleY + scaleHeight && my >= scaleY) return true; else return false;
			break;
		case 2:
			if(mx >= scaleX && mx < scaleX + scaleWidth && my > scaleY - scaleHeight && my <= scaleY) return true; else return false;
			break;
		case 3:
			scaleWidth = this.width * this.renderer.scale / 2;
			scaleHeight = this.height * this.renderer.scale / 2;
			var inXBoundary = mx >= scaleX && mx < scaleX + scaleWidth || mx <= scaleX && mx > scaleX - scaleWidth;
			var inYBoundary = my > scaleY - scaleHeight && my <= scaleY || my < scaleY + scaleHeight && my > scaleY;
			if(inXBoundary && inYBoundary) return true; else return false;
			break;
		case 4:
			if(mx >= scaleX && mx < scaleX + scaleWidth && my < scaleY + scaleHeight && my >= scaleY) return true; else return false;
			break;
		case 5:
			if(mx + 5 >= scaleX && mx < scaleX + scaleWidth - 5 && my < scaleY + scaleHeight + 5 && my >= scaleY - 5) return true; else return false;
			break;
		default:
			return false;
		}
	}
	,__class__: phylo.PhyloScreenData
};
phylo.PhyloToolBar = $hxClasses["phylo.PhyloToolBar"] = function(canvas,parent) {
	this.positionTop = false;
	this.canvas = canvas;
	this.build();
};
phylo.PhyloToolBar.__name__ = ["phylo","PhyloToolBar"];
phylo.PhyloToolBar.prototype = {
	canvas: null
	,parent: null
	,container: null
	,positionTop: null
	,titleElement: null
	,toolbarContainer: null
	,lineTypeButton: null
	,build: function() {
		if(this.parent == null) {
			this.parent = this.canvas.getContainer();
			this.positionTop = true;
		}
		this.createContainer();
		this.parent.appendChild(this.container);
	}
	,createContainer: function() {
		this.container = window.document.createElement("div");
		if(this.positionTop) {
			this.container.style.position = "absolute";
			this.container.style.top = "15px";
			this.container.style.left = "35px";
		}
		this.createTitleElement();
		this.createToolBar();
	}
	,createTitleElement: function() {
		this.titleElement = window.document.createElement("label");
		this.titleElement.style.color = "#1c66e0";
		this.titleElement.style.fontSize = "19px";
		this.titleElement.style.margin = "10px 0px 0px 0px";
		this.titleElement.style.left = "35px";
		this.setTitle(this.canvas.getConfig().title);
		this.container.appendChild(this.titleElement);
	}
	,createToolBar: function() {
		this.toolbarContainer = window.document.createElement("div");
		this.toolbarContainer.style.marginTop = "10px";
		this.addCenterButton();
		this.addZoomInButton();
		this.addZoomOutButton();
		this.addExportPNGButton();
		this.addExportSVGButton();
		this.addHighlightButton();
		this.addSetLineWidthButton();
		this.addTreeTypeButton();
		this.addTreeLineTypeButton();
		this.addShadowTypeButton();
		this.addAutoFitButton();
		this.container.appendChild(this.toolbarContainer);
	}
	,position: function(element) {
		if(this.canvas.getConfig().verticalToolBar) {
			element.style.display = "block";
			element.style.marginLeft = "0px";
			element.style.marginBottom = "20px";
		} else element.style.display = "inline-block";
	}
	,addCenterButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		this.position(button);
		button.style.backgroundImage = "url(js/images/center-single.png)";
		button.style.backgroundRepeat = "no-repeat";
		button.style.backgroundPosition = "center center";
		button.style.backgroundSize = "30px";
		button.style.height = "25px";
		button.style.width = "25px";
		button.style.backgroundColor = "initial";
		button.style.border = "none";
		button.style.cursor = "pointer";
		button.style.marginRight = "20px";
		button.addEventListener("click",function() {
			_g.canvas.center();
		});
		this.toolbarContainer.appendChild(button);
	}
	,addZoomInButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		this.position(button);
		button.style.backgroundImage = "url(js/images/mag_plus-single.png)";
		button.style.backgroundRepeat = "no-repeat";
		button.style.backgroundPosition = "center center";
		button.style.height = "25px";
		button.style.width = "25px";
		button.style.backgroundColor = "initial";
		button.style.border = "none";
		button.style.cursor = "pointer";
		button.style.marginRight = "20px";
		button.addEventListener("click",function() {
			_g.canvas.zoomIn();
		});
		this.toolbarContainer.appendChild(button);
	}
	,addZoomOutButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		this.position(button);
		button.style.backgroundImage = "url(js/images/mag_minus-single.png)";
		button.style.backgroundRepeat = "no-repeat";
		button.style.backgroundPosition = "center center";
		button.style.height = "25px";
		button.style.width = "25px";
		button.style.backgroundColor = "initial";
		button.style.border = "none";
		button.style.cursor = "pointer";
		button.style.marginRight = "20px";
		button.addEventListener("click",function() {
			_g.canvas.zoomOut();
		});
		this.toolbarContainer.appendChild(button);
	}
	,addExportPNGButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		this.position(button);
		button.style.backgroundImage = "url(js/images/png-single.png)";
		button.style.backgroundRepeat = "no-repeat";
		button.style.backgroundPosition = "center center";
		button.style.height = "25px";
		button.style.width = "25px";
		button.style.backgroundColor = "initial";
		button.style.border = "none";
		button.style.cursor = "pointer";
		button.style.marginRight = "20px";
		button.addEventListener("click",function() {
			_g.canvas.exportPNGToFile();
		});
		this.toolbarContainer.appendChild(button);
	}
	,addExportSVGButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		this.position(button);
		button.style.backgroundImage = "url(js/images/svg-single.png)";
		button.style.backgroundRepeat = "no-repeat";
		button.style.backgroundPosition = "center center";
		button.style.height = "25px";
		button.style.width = "25px";
		button.style.backgroundColor = "initial";
		button.style.border = "none";
		button.style.cursor = "pointer";
		button.style.marginRight = "20px";
		button.addEventListener("click",function() {
			_g.canvas.exportSVGToFile();
		});
		this.toolbarContainer.appendChild(button);
	}
	,addHighlightButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		this.position(button);
		button.style.backgroundImage = "url(js/images/hightlight-single.png)";
		button.style.backgroundRepeat = "no-repeat";
		button.style.backgroundPosition = "center center";
		button.style.backgroundSize = "30px";
		button.style.height = "25px";
		button.style.width = "25px";
		button.style.backgroundColor = "initial";
		button.style.border = "none";
		button.style.cursor = "pointer";
		button.style.marginRight = "20px";
		button.addEventListener("click",function() {
			_g.canvas.showHighlightDialog();
		});
		this.toolbarContainer.appendChild(button);
	}
	,setTitle: function(title) {
		this.titleElement.innerText = title;
	}
	,addSetLineWidthButton: function() {
		var _g = this;
		var inputLabel = window.document.createElement("label");
		inputLabel.setAttribute("for","tree_line_width");
		inputLabel.innerText = "Pen width";
		inputLabel.style.padding = "2px";
		inputLabel.style.display = "inline-block";
		var inputElement = window.document.createElement("input");
		inputElement.setAttribute("type","text");
		inputElement.style.width = "30px";
		inputElement.setAttribute("value","1");
		inputElement.style.padding = "2px";
		inputElement.style.marginLeft = "5px";
		this.position(inputElement);
		inputElement.addEventListener("input",function(e) {
			_g.canvas.setLineWidth(Std.parseFloat(inputElement.value));
		});
		this.toolbarContainer.appendChild(inputLabel);
		this.toolbarContainer.appendChild(inputElement);
	}
	,addTreeTypeButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		this.position(button);
		button.innerText = "Toggle Type";
		button.style.border = "1px solid #c1c1c1";
		button.style.cursor = "pointer";
		button.style.padding = "3px 6px";
		button.style.marginLeft = "25px";
		button.style.marginRight = "25px";
		this.position(button);
		button.addEventListener("click",function() {
			_g.canvas.toggleType();
		});
		this.toolbarContainer.appendChild(button);
	}
	,addTreeLineTypeButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		button.innerText = "Toggle Line Type";
		button.style.border = "1px solid #c1c1c1";
		button.style.cursor = "pointer";
		button.style.padding = "3px 6px";
		button.style.marginRight = "25px";
		this.position(button);
		button.addEventListener("click",function() {
			_g.canvas.toggleLineMode();
		});
		this.toolbarContainer.appendChild(button);
		this.lineTypeButton = button;
	}
	,setLineTypeButtonVisible: function(visible) {
		if(visible) this.position(this.lineTypeButton); else this.lineTypeButton.style.display = "none";
	}
	,addShadowTypeButton: function() {
		var _g = this;
		var shadowInputColourLabel = window.document.createElement("label");
		shadowInputColourLabel.innerText = "Shadow colour";
		this.toolbarContainer.appendChild(shadowInputColourLabel);
		var shadowInputColour = window.document.createElement("input");
		var removeShadowButton = window.document.createElement("button");
		shadowInputColour.style.marginLeft = "5px";
		shadowInputColour.setAttribute("type","color");
		shadowInputColour.setAttribute("name","shadow_colour_input");
		shadowInputColour.style.width = "50px";
		shadowInputColour.addEventListener("change",function() {
			_g.canvas.setShadowColour(shadowInputColour.value);
		});
		removeShadowButton.innerText = "Toggle Shadow";
		removeShadowButton.style.border = "1px solid #c1c1c1";
		removeShadowButton.style.cursor = "pointer";
		removeShadowButton.style.padding = "3px 6px";
		removeShadowButton.style.marginLeft = "25px";
		this.position(shadowInputColour);
		this.position(removeShadowButton);
		removeShadowButton.addEventListener("click",function() {
			_g.canvas.toggleShadow();
		});
		this.toolbarContainer.appendChild(shadowInputColour);
		this.toolbarContainer.appendChild(removeShadowButton);
	}
	,addAutoFitButton: function() {
		var _g = this;
		var button = window.document.createElement("button");
		button.innerText = "Fit";
		button.style.border = "1px solid #c1c1c1";
		button.style.cursor = "pointer";
		button.style.padding = "3px 6px";
		button.style.marginLeft = "25px";
		this.position(button);
		button.addEventListener("click",function() {
			_g.canvas.autoFit();
		});
		this.toolbarContainer.appendChild(button);
	}
	,__class__: phylo.PhyloToolBar
};
phylo.PhyloTreeNode = $hxClasses["phylo.PhyloTreeNode"] = function(parent,name,leaf,branch) {
	this.wedgeColour = null;
	this.maxNameLength = -1;
	this.angle_new = 0;
	this.lineMode = phylo.LineMode.STRAIGHT;
	this.lineWidth = 1;
	this.yRandom = null;
	this.xRandom = null;
	this.maxBranch = null;
	this.minBranch = null;
	this.numchild = 0;
	this.leaves = 0;
	this.ratio = 0.00006;
	this.dist = 50;
	this.space = 0;
	this.parent = parent;
	this.children = [];
	this.name = name;
	this.leaf = leaf;
	this.branch = branch;
	if(this.parent != null) {
		this.parent.addChild(this);
		this.root = this.parent.root;
	} else {
		this.targets = [];
		this.root = this;
		this.screen = [];
		this.divactive = 99999;
		this.leafNameToNode = new haxe.ds.StringMap();
		this.nodeIdToNode = new haxe.ds.IntMap();
	}
	this.angle = 0;
	this.x = 0;
	this.y = 0;
	this.wedge = 0;
	this.length = 0;
	this.targetFamilyGene = [];
	this.l = 0;
};
phylo.PhyloTreeNode.__name__ = ["phylo","PhyloTreeNode"];
phylo.PhyloTreeNode.prototype = {
	parent: null
	,nodeId: null
	,name: null
	,targetFamily: null
	,targetFamilyGene: null
	,leaf: null
	,branch: null
	,angle: null
	,x: null
	,y: null
	,wedge: null
	,length: null
	,l: null
	,root: null
	,rad: null
	,quad: null
	,annotations: null
	,activeAnnotation: null
	,targets: null
	,screen: null
	,divactive: null
	,space: null
	,colour: null
	,children: null
	,dist: null
	,ratio: null
	,leaves: null
	,numchild: null
	,leafNameToNode: null
	,nodeIdToNode: null
	,rectangleTop: null
	,rectangleRight: null
	,rectangleBottom: null
	,rectangleLeft: null
	,results: null
	,minBranch: null
	,maxBranch: null
	,xRandom: null
	,yRandom: null
	,lineWidth: null
	,lineMode: null
	,angle_new: null
	,maxNameLength: null
	,wedgeColour: null
	,newickString: null
	,fasta: null
	,postOrderTraversal: function() {
		if(this.isLeaf() == true) {
			this.l = 1;
			this.root.targets[this.root.leaves] = this.name;
			this.root.leaves = this.root.leaves + 1;
			this.annotations = [];
			this.activeAnnotation = [];
			this.root.leafNameToNode.set(this.name,this);
		} else {
			var i = 0;
			while(i < this.children.length) {
				this.children[i].postOrderTraversal();
				this.l = this.l + this.children[i].l;
				i++;
			}
		}
	}
	,preOrderTraversal2: function(mode) {
		if(this.parent != null) {
			var parent = this.parent;
			this.x = parent.x + Math.cos(this.angle + this.wedge / 2) * this.root.dist;
			this.y = parent.y + Math.sin(this.angle + this.wedge / 2) * this.root.dist;
			if(mode == 1) {
				this.nodeId = this.root.numchild;
				this.root.nodeIdToNode.h[this.nodeId] = this;
			}
		} else if(mode == 1) this.nodeId = 0;
		var n = this.angle;
		var i = 0;
		while(i < this.children.length) {
			if(mode == 1) this.root.numchild = this.root.numchild + 1;
			this.children[i].wedge = this.children[i].l / this.children[i].root.l * 2 * Math.PI + Math.PI / 50;
			this.children[i].angle = n;
			n = n + this.children[i].wedge;
			this.children[i].preOrderTraversal2(mode);
			i++;
		}
	}
	,areAllChildrenLeaf: function() {
		var _g = 0;
		var _g1 = this.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			if(!child.isLeaf()) return false;
		}
		return true;
	}
	,preOrderTraversal: function(mode) {
		if(this.parent != null) {
			if(mode == 1) {
				this.nodeId = this.root.numchild;
				this.root.nodeIdToNode.h[this.nodeId] = this;
			}
			var a = this.getDepth() * this.root.ratio;
			if(this.angle > this.parent.angle) this.angle += phylo.PhyloHubMath.degreesToRadians(a); else this.angle -= phylo.PhyloHubMath.degreesToRadians(a);
			this.angle_new = this.angle + this.wedge / 2;
			this.x = this.parent.x + Math.cos(this.angle_new) * this.root.dist;
			this.y = this.parent.y + Math.sin(this.angle_new) * this.root.dist;
		} else if(mode == 1) this.nodeId = 0;
		var n = this.angle;
		var _g = 0;
		var _g1 = this.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			if(mode == 1) this.root.numchild = this.root.numchild + 1;
			child.wedge = 2 * Math.PI * child.getLeafCount() / child.root.getLeafCount();
			child.angle = n;
			child.angle_new = child.angle + child.wedge / 2;
			n += child.wedge;
			child.preOrderTraversal(mode);
		}
	}
	,calculateScale: function() {
		if(this.branch != null) {
			if(this.root.maxBranch == null || this.branch > this.root.maxBranch) this.root.maxBranch = this.branch;
			if(this.root.minBranch == null || this.branch < this.root.minBranch) this.root.minBranch = this.branch;
		}
		var _g1 = 0;
		var _g = this.children.length;
		while(_g1 < _g) {
			var i = _g1++;
			this.children[i].calculateScale();
		}
	}
	,getChildren: function() {
		return this.children;
	}
	,getChildN: function(i) {
		return this.children[i];
	}
	,addChild: function(child) {
		this.children[this.children.length] = child;
	}
	,isLeaf: function() {
		return this.leaf;
	}
	,getLeafCount: function() {
		if(this.isLeaf() == true) return 1; else {
			var total = 0;
			var i;
			i = 0;
			var _g1 = 0;
			var _g = this.children.length;
			while(_g1 < _g) {
				var i1 = _g1++;
				total += this.children[i1].getLeafCount();
			}
			return total;
		}
	}
	,getDepth: function() {
		if(this.parent == null) return 0; else return 1 + this.parent.getDepth();
	}
	,getHeight: function() {
		if(this.isLeaf()) return 0; else {
			var heightList = [];
			var i;
			i = 0;
			var _g1 = 0;
			var _g = this.children.length;
			while(_g1 < _g) {
				var i1 = _g1++;
				heightList[i1] = this.children[i1].getHeight() + 1;
			}
			return phylo.PhyloHubMath.getMaxOfArray(heightList);
		}
	}
	,getMaximumLeafNameLength: function(renderer) {
		if(this.maxNameLength != -1) return this.maxNameLength;
		var nodes = [];
		nodes.push(this);
		this.maxNameLength = 0;
		var maxName = "";
		var _g = 0;
		while(_g < nodes.length) {
			var node = nodes[_g];
			++_g;
			if(node.isLeaf()) {
				var nodeNameLength = node.name.length;
				if(nodeNameLength > this.maxNameLength) {
					this.maxNameLength = nodeNameLength;
					maxName = node.name;
				}
			} else {
				var _g1 = 0;
				var _g2 = node.children;
				while(_g1 < _g2.length) {
					var child = _g2[_g1];
					++_g1;
					nodes.push(child);
				}
			}
		}
		if(renderer != null) this.maxNameLength = renderer.mesureText(maxName);
		return this.maxNameLength;
	}
	,findFirstLeaf: function() {
		var _g = 0;
		var _g1 = this.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			if(child.isLeaf()) return child; else return child.findFirstLeaf();
		}
		return null;
	}
	,findLastLeaf: function() {
		var lastChild = null;
		var _g = 0;
		var _g1 = this.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			if(child.isLeaf()) lastChild = child; else lastChild = child.findLastLeaf();
		}
		return lastChild;
	}
	,setLineWidth: function(width) {
		this.lineWidth = width;
		var _g = 0;
		var _g1 = this.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.setLineWidth(width);
		}
	}
	,setLineMode: function(mode) {
		this.lineMode = mode;
		var _g = 0;
		var _g1 = this.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.setLineMode(mode);
		}
	}
	,rotateNode: function(clockwise,drawingMode) {
		var delta = -0.3;
		if(clockwise) delta = 0.3;
		this.x = (this.x - this.parent.x) * Math.cos(delta) - (this.y - this.parent.y) * Math.sin(delta) + this.parent.x;
		this.y = (this.x - this.parent.x) * Math.sin(delta) + (this.y - this.parent.y) * Math.cos(delta) + this.parent.y;
		this.angle = this.angle + delta;
		var n = this.angle;
		var _g = 0;
		var _g1 = this.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.wedge = child.l / this.root.l * 2 * Math.PI + Math.PI / 20;
			child.angle = n;
			n = n + child.wedge;
			if(drawingMode == phylo.PhyloDrawingMode.STRAIGHT) child.preOrderTraversal2(0); else if(drawingMode == phylo.PhyloDrawingMode.CIRCULAR) child.preOrderTraversal(0);
		}
	}
	,clearAnnotations: function() {
		this.annotations = [];
		if(this.activeAnnotation != null) {
			var _g1 = 0;
			var _g = this.activeAnnotation.length;
			while(_g1 < _g) {
				var i = _g1++;
				this.activeAnnotation[i] = false;
			}
		}
		var _g2 = 0;
		var _g11 = this.children;
		while(_g2 < _g11.length) {
			var child = _g11[_g2];
			++_g2;
			child.clearAnnotations();
		}
	}
	,getNewickString: function() {
		return this.newickString;
	}
	,setFasta: function(fasta) {
		this.fasta = fasta;
	}
	,getFasta: function() {
		return this.fasta;
	}
	,__class__: phylo.PhyloTreeNode
};
phylo.LineMode = $hxClasses["phylo.LineMode"] = { __ename__ : ["phylo","LineMode"], __constructs__ : ["STRAIGHT","BEZIER"] };
phylo.LineMode.STRAIGHT = ["STRAIGHT",0];
phylo.LineMode.STRAIGHT.toString = $estr;
phylo.LineMode.STRAIGHT.__enum__ = phylo.LineMode;
phylo.LineMode.BEZIER = ["BEZIER",1];
phylo.LineMode.BEZIER.toString = $estr;
phylo.LineMode.BEZIER.__enum__ = phylo.LineMode;
phylo.PhyloUtil = $hxClasses["phylo.PhyloUtil"] = function() { };
phylo.PhyloUtil.__name__ = ["phylo","PhyloUtil"];
phylo.PhyloUtil.drawRadialFromNewick = function(newickStr,parent,config,annotationManager) {
	var parser = new phylo.PhyloNewickParser();
	var rootNode = parser.parse(newickStr);
	return phylo.PhyloUtil.drawRadialFromTree(rootNode,parent,config,annotationManager);
};
phylo.PhyloUtil.drawRadialFromTree = function(rootNode,parent,config,annotationManager) {
	rootNode.calculateScale();
	rootNode.postOrderTraversal();
	rootNode.preOrderTraversal(1);
	var parentWidth = parent.clientWidth;
	var parentHeight = parent.clientHeight;
	if(config == null) config = new phylo.PhyloCanvasConfiguration();
	var canvas = new phylo.PhyloCanvasRenderer(parentWidth,parentHeight,parent,rootNode,config,annotationManager);
	return canvas;
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
	,sendPhyloReportRequest: function(fasta,cb) {
		this.helper.sendRequest("_phylo_",{ fasta : fasta},cb);
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
	debug.enable("saturn:plugin");
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
			cookies.set("user",{ 'fullname' : obj.full_name, 'token' : obj.token, 'username' : username.toUpperCase()},{ 'expires' : 14});
			var user = new saturn.core.User();
			user.fullname = obj.full_name;
			user.token = obj.token;
			user.username = username.toUpperCase();
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
			this.authenticateSocket(user,function(err,user1) {
				if(err == null) _g.installProviders();
				if(cb != null) cb(err);
			});
		} else {
			saturn.core.Util.debug("Installing unauthenticated node socket");
			this.installNodeSocket();
			this.installProviders();
			var _g1 = 0;
			var _g11 = this.refreshListeners;
			while(_g1 < _g11.length) {
				var listener = _g11[_g1];
				++_g1;
				listener();
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
	,printQueryTimes: function() {
		var $it0 = this.msgIdToJobInfo.keys();
		while( $it0.hasNext() ) {
			var msgId = $it0.next();
			if(Reflect.hasField(this.msgIdToJobInfo.get(msgId),"END_TIME")) {
				saturn.core.Util.debug(">" + msgId + "\t\t" + Std.string(this.msgIdToJobInfo.get(msgId).msg) + "\t\t" + (this.msgIdToJobInfo.get(msgId).END_TIME - this.msgIdToJobInfo.get(msgId).START_TIME) / 1000);
				saturn.core.Util.debug(this.msgIdToJobInfo.get(msgId).JSON);
			}
		}
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
			js.Browser.alert(fileName);
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
	,getByNamedQuery: null
	,getModel: null
	,resetCache: null
	,getByValues: null
	,_closeConnection: null
	,getConfig: null
	,query: null
	,addHook: null
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
		null;
		return;
	}
	,generateQualifiedName: function(schemaName,tableName) {
		return null;
	}
	,getConfig: function() {
		return this.config;
	}
	,setConfig: function(config) {
		this.config = config;
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
		provider.namedQueryHookConfigs = this.namedQueryHookConfigs;
		provider.config = this.config;
		provider.objectCache = new haxe.ds.StringMap();
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
			saturn.core.Util.debug(class_name + " on " + this.getName());
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
		if(this.theBindingMap != null) {
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
		q.run(cb);
		return q;
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
		saturn.core.Util.debug("Using cache " + Std.string(this.useCache));
		if(this.useCache) {
			saturn.core.Util.debug("Using cache " + Std.string(this.useCache));
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
		saturn.core.Util.debug("In getByNamedQuery " + (cache == null?"null":"" + cache));
		try {
			if(cache) {
				saturn.core.Util.debug("Looking for cached result");
				var queries = this.namedQueryCache.get(queryId);
				var serialParamString = haxe.Serializer.run(parameters);
				var crc1 = haxe.crypto.Md5.encode(queryId + "/" + serialParamString);
				if(this.namedQueryCache.exists(crc1)) {
					var qResults = this.namedQueryCache.get(crc1).queryResults;
					saturn.core.Util.debug("Use cached result");
					callBack(qResults,null);
					return;
				}
			}
			var privateCB = function(toBind,exception) {
				if(toBind == null) callBack(toBind,exception); else _g.initialiseObjects([],toBind,[],exception,function(objs,err) {
					if(_g.useCache) {
						saturn.core.Util.debug("Caching result");
						var namedQuery = new saturn.db.NamedQueryCache();
						namedQuery.queryName = queryId;
						namedQuery.queryParams = parameters;
						namedQuery.queryParamSerial = haxe.Serializer.run(parameters);
						namedQuery.queryResults = objs;
						var crc = haxe.crypto.Md5.encode(queryId + "/" + namedQuery.queryParamSerial);
						_g.namedQueryCache.set(crc,namedQuery);
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
				saturn.core.Util.debug("Hook is known");
				var config1 = null;
				if(this.namedQueryHookConfigs.exists(queryId)) config1 = this.namedQueryHookConfigs.get(queryId);
				saturn.core.Util.debug("Calling hook");
				this.namedQueryHooks.get(queryId)(queryId,parameters,clazz,privateCB,config1);
			} else {
				saturn.core.Util.debug("Hook is not known");
				this._getByNamedQuery(queryId,parameters,clazz,privateCB);
			}
		} catch( ex ) {
			if (ex instanceof js._Boot.HaxeError) ex = ex.val;
			saturn.core.Util.debug(ex);
			callBack(null,"An unexpected exception has occurred");
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
	,addHook: function(hook,name) {
		var value = hook;
		this.namedQueryHooks.set(name,value);
	}
	,_getByNamedQuery: function(queryId,parameters,clazz,callBack) {
	}
	,getByIdStartsWith: function(id,field,clazz,limit,callBack) {
		var _g = this;
		saturn.core.Util.debug("Starts with using cache " + Std.string(this.useCache));
		var queryId = "__STARTSWITH_" + Type.getClassName(clazz);
		var parameters = [];
		parameters.push(field);
		parameters.push(id);
		var crc = null;
		if(this.useCache) {
			var crc1 = haxe.crypto.Md5.encode(queryId + "/" + haxe.Serializer.run(parameters));
			if(this.namedQueryCache.exists(crc1)) {
				callBack(this.namedQueryCache.get(crc1).queryResults,null);
				return;
			}
		}
		this._getByIdStartsWith(id,field,clazz,limit,function(toBind,exception) {
			if(toBind == null) callBack(toBind,exception); else _g.initialiseObjects([],toBind,[],exception,function(objs,err) {
				if(_g.useCache) {
					var namedQuery = new saturn.db.NamedQueryCache();
					namedQuery.queryName = queryId;
					namedQuery.queryParams = parameters;
					namedQuery.queryResults = objs;
					_g.namedQueryCache.set(crc,namedQuery);
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
		var crc = haxe.crypto.Md5.encode(queryId + "/" + haxe.Serializer.run(parameters));
		if(this.namedQueryCache.exists(crc)) this.namedQueryCache.remove(crc);
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
			var _g11 = model.getAttributes();
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
			saturn.core.Util.debug(classStr);
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
			var _g2 = modelDef.getAttributes();
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
					var _g21 = modelDef.getAttributes();
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
		if(!js.Boot.__instanceof(token,saturn.db.query_lang.Token)) token = new saturn.db.query_lang.Value(saturn.db.query_lang.Token);
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
	,getAttributeName: function() {
		return this.attributeName;
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
saturn.db.query_lang.Query.deserialise = function(querySer) {
	var clone = haxe.Unserializer.run(querySer);
	saturn.db.query_lang.Query.deserialiseToken(clone);
	return clone;
};
saturn.db.query_lang.Query.deserialiseToken = function(token) {
	if(token == null) return;
	if(token.getTokens() != null) {
		var _g = 0;
		var _g1 = token.getTokens();
		while(_g < _g1.length) {
			var token1 = _g1[_g];
			++_g;
			saturn.db.query_lang.Query.deserialiseToken(token1);
		}
	}
	if(js.Boot.__instanceof(token,saturn.db.query_lang.Query)) {
		var qToken;
		qToken = js.Boot.__cast(token , saturn.db.query_lang.Query);
		qToken.provider = null;
	}
};
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
	,results: null
	,error: null
	,setLastPagedRowValue: function(t) {
		this.lastPagedRowValue = t;
	}
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
	,clone: function() {
		var str = this.serialise();
		return saturn.db.query_lang.Query.deserialise(str);
	}
	,serialise: function() {
		var keepMe = this.provider;
		this.provider = null;
		var newMe = haxe.Serializer.run(this);
		this.provider = keepMe;
		return newMe;
	}
	,run: function(cb) {
		var _g = this;
		var clone = this.clone();
		clone.provider = null;
		clone.getTokens();
		this.provider.query(clone,function(objs,err) {
			if(err == null && objs.length > 0 && _g.isPaging()) {
				var fieldName = null;
				if(_g.pageOn.name != null) fieldName = _g.pageOn.name; else if(js.Boot.__instanceof(_g.pageOn,saturn.db.query_lang.Field)) {
					var fToken;
					fToken = js.Boot.__cast(_g.pageOn , saturn.db.query_lang.Field);
					fieldName = fToken.getAttributeName();
				}
				if(fieldName == null) err = "Unable to determine value of last paged row"; else _g.setLastPagedRowValue(new saturn.db.query_lang.Value(Reflect.field(objs[objs.length - 1],fieldName)));
			}
			_g.results = objs;
			_g.error = err;
			if(cb != null) cb(objs,err);
		});
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
		var fields = model.getAttributes();
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
				var fieldToken = new saturn.db.query_lang.Field(clazz,field1);
				this.getWhere().addToken(fieldToken);
				if(js.Boot.__instanceof(value,saturn.db.query_lang.IsNull)) {
					saturn.core.Util.print("Found NULL");
					this.getWhere().addToken(new saturn.db.query_lang.IsNull());
				} else if(js.Boot.__instanceof(value,saturn.db.query_lang.IsNotNull)) this.getWhere().addToken(new saturn.db.query_lang.IsNotNull()); else if(js.Boot.__instanceof(value,saturn.db.query_lang.Operator)) this.getWhere().addToken(value); else {
					this.getWhere().addToken(new saturn.db.query_lang.Equals());
					if(js.Boot.__instanceof(value,saturn.db.query_lang.Token)) this.getWhere().addToken(value); else {
						saturn.core.Util.print("Found value" + Type.getClassName(value == null?null:js.Boot.getClass(value)));
						this.getWhere().addToken(new saturn.db.query_lang.Value(value));
					}
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
phylo.PhyloNewickParser.newLineReg = new EReg("\n","g");
phylo.PhyloNewickParser.carLineReg = new EReg("\r","g");
phylo.PhyloNewickParser.whiteSpaceReg = new EReg("\\s","g");
saturn.client.core.CommonCore.pools = new haxe.ds.StringMap();
saturn.client.core.CommonCore.resourceToPool = new haxe.ds.ObjectMap();
saturn.client.core.CommonCore.providers = new haxe.ds.StringMap();
saturn.client.core.CommonCore.annotationManager = new saturn.core.annotations.AnnotationManager();
saturn.db.DefaultProvider.r_date = new EReg("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.000Z","");
saturn.client.core.ClientCore.main();
