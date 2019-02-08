# Haxe portion is MIT and SATurn portion is CC0

# ChemiReg - web-based compound registration platform
# Written in 2017 by David Damerell <david.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
# 
# To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

from datetime import datetime as python_lib_datetime_Datetime
import math as python_lib_Math
import math as Math
import functools as python_lib_Functools
import inspect as python_lib_Inspect
import re as python_lib_Re
from io import StringIO as python_lib_io_StringIO
import urllib.parse as python_lib_urllib_Parse
import time


class _hx_AnonObject:
	def __init__(self, fields):
		self.__dict__ = fields


_hx_classes = {}


class Enum:
	_hx_class_name = "Enum"
	_hx_fields = ["tag", "index", "params"]
	_hx_methods = ["__str__"]

	def __init__(self,tag,index,params):
		self.tag = None
		self.index = None
		self.params = None
		self.tag = tag
		self.index = index
		self.params = params

	def __str__(self):
		if (self.params is None):
			return self.tag
		else:
			return (((HxOverrides.stringOrNull(self.tag) + "(") + HxOverrides.stringOrNull(",".join([python_Boot.toString1(x1,'') for x1 in self.params]))) + ")")

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.tag = None
		_hx_o.index = None
		_hx_o.params = None
Enum._hx_class = Enum
_hx_classes["Enum"] = Enum


class Class:
	_hx_class_name = "Class"
Class._hx_class = Class
_hx_classes["Class"] = Class


class Date:
	_hx_class_name = "Date"
	_hx_fields = ["date"]
	_hx_statics = ["EPOCH_LOCAL", "fromTime", "datetimeTimestamp", "fromString"]

	def __init__(self,year,month,day,hour,_hx_min,sec):
		self.date = None
		if (year < python_lib_datetime_Datetime.min.year):
			year = python_lib_datetime_Datetime.min.year
		if (day == 0):
			day = 1
		self.date = python_lib_datetime_Datetime(year, (month + 1), day, hour, _hx_min, sec, 0)

	@staticmethod
	def fromTime(t):
		d = Date(1970, 0, 1, 0, 0, 0)
		d.date = python_lib_datetime_Datetime.fromtimestamp((t / 1000.0))
		return d

	@staticmethod
	def datetimeTimestamp(dt,epoch):
		return ((dt - epoch).total_seconds() * 1000)

	@staticmethod
	def fromString(s):
		_g = len(s)
		if (_g == 8):
			k = s.split(":")
			d = Date(0, 0, 0, Std.parseInt((k[0] if 0 < len(k) else None)), Std.parseInt((k[1] if 1 < len(k) else None)), Std.parseInt((k[2] if 2 < len(k) else None)))
			return d
		elif (_g == 10):
			k1 = s.split("-")
			return Date(Std.parseInt((k1[0] if 0 < len(k1) else None)), (Std.parseInt((k1[1] if 1 < len(k1) else None)) - 1), Std.parseInt((k1[2] if 2 < len(k1) else None)), 0, 0, 0)
		elif (_g == 19):
			k2 = s.split(" ")
			y = None
			_this = (k2[0] if 0 < len(k2) else None)
			y = _this.split("-")
			t = None
			_this1 = (k2[1] if 1 < len(k2) else None)
			t = _this1.split(":")
			return Date(Std.parseInt((y[0] if 0 < len(y) else None)), (Std.parseInt((y[1] if 1 < len(y) else None)) - 1), Std.parseInt((y[2] if 2 < len(y) else None)), Std.parseInt((t[0] if 0 < len(t) else None)), Std.parseInt((t[1] if 1 < len(t) else None)), Std.parseInt((t[2] if 2 < len(t) else None)))
		else:
			raise _HxException(("Invalid date format : " + ("null" if s is None else s)))

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.date = None
Date._hx_class = Date
_hx_classes["Date"] = Date


class EReg:
	_hx_class_name = "EReg"
	_hx_fields = ["pattern", "matchObj", "global"]
	_hx_methods = ["matchSub", "replace"]

	def __init__(self,r,opt):
		self.pattern = None
		self.matchObj = None
		self._hx_global = None
		self._hx_global = False
		options = 0
		_g1 = 0
		_g = len(opt)
		while (_g1 < _g):
			i = _g1
			_g1 = (_g1 + 1)
			c = None
			if (i >= len(opt)):
				c = -1
			else:
				c = ord(opt[i])
			if (c == 109):
				options = (options | python_lib_Re.M)
			if (c == 105):
				options = (options | python_lib_Re.I)
			if (c == 115):
				options = (options | python_lib_Re.S)
			if (c == 117):
				options = (options | python_lib_Re.U)
			if (c == 103):
				self._hx_global = True
		self.pattern = python_lib_Re.compile(r,options)

	def matchSub(self,s,pos,_hx_len = -1):
		if (_hx_len is None):
			_hx_len = -1
		if (_hx_len != -1):
			self.matchObj = self.pattern.search(s,pos,(pos + _hx_len))
		else:
			self.matchObj = self.pattern.search(s,pos)
		return (self.matchObj is not None)

	def replace(self,s,by):
		by1 = None
		_this = by.split("$$")
		by1 = "_hx_#repl#__".join([python_Boot.toString1(x1,'') for x1 in _this])
		def _hx_local_0(x):
			res = by1
			g = x.groups()
			_g1 = 0
			_g = len(g)
			while (_g1 < _g):
				i = _g1
				_g1 = (_g1 + 1)
				_this1 = None
				delimiter = ("$" + HxOverrides.stringOrNull(str((i + 1))))
				if (delimiter == ""):
					_this1 = list(res)
				else:
					_this1 = res.split(delimiter)
				res = g[i].join([python_Boot.toString1(x1,'') for x1 in _this1])
			_this2 = res.split("_hx_#repl#__")
			res = "$".join([python_Boot.toString1(x1,'') for x1 in _this2])
			return res
		replace = _hx_local_0
		return python_lib_Re.sub(self.pattern,replace,s,(0 if (self._hx_global) else 1))

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.pattern = None
		_hx_o.matchObj = None
		_hx_o._hx_global = None
EReg._hx_class = EReg
_hx_classes["EReg"] = EReg


class EnumValue:
	_hx_class_name = "EnumValue"
EnumValue._hx_class = EnumValue
_hx_classes["EnumValue"] = EnumValue


class Lambda:
	_hx_class_name = "Lambda"
	_hx_statics = ["count"]

	@staticmethod
	def count(it,pred = None):
		n = 0
		if (pred is None):
			_hx_local_1 = HxOverrides.iterator(it)
			while _hx_local_1.hasNext():
				_ = _hx_local_1.next()
				n = (n + 1)
		else:
			_hx_local_3 = HxOverrides.iterator(it)
			while _hx_local_3.hasNext():
				x = _hx_local_3.next()
				if pred(x):
					n = (n + 1)
		return n
Lambda._hx_class = Lambda
_hx_classes["Lambda"] = Lambda


class List:
	_hx_class_name = "List"
	_hx_fields = ["h", "q", "length"]
	_hx_methods = ["add", "first", "isEmpty"]

	def __init__(self):
		self.h = None
		self.q = None
		self.length = None
		self.length = 0

	def add(self,item):
		x = [item]
		if (self.h is None):
			self.h = x
		else:
			python_internal_ArrayImpl._set(self.q, 1, x)
		self.q = x
		_hx_local_0 = self
		_hx_local_1 = _hx_local_0.length
		_hx_local_0.length = (_hx_local_1 + 1)
		_hx_local_1

	def first(self):
		if (self.h is None):
			return None
		else:
			return (self.h[0] if 0 < len(self.h) else None)

	def isEmpty(self):
		return (self.h is None)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.h = None
		_hx_o.q = None
		_hx_o.length = None
List._hx_class = List
_hx_classes["List"] = List


class Reflect:
	_hx_class_name = "Reflect"
	_hx_statics = ["field", "setField", "callMethod", "isFunction", "deleteField"]

	@staticmethod
	def field(o,field):
		return python_Boot.field(o,field)

	@staticmethod
	def setField(o,field,value):
		setattr(o,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)),value)

	@staticmethod
	def callMethod(o,func,args):
		if callable(func):
			return func(*args)
		else:
			return None

	@staticmethod
	def isFunction(f):
		return ((python_lib_Inspect.isfunction(f) or python_lib_Inspect.ismethod(f)) or hasattr(f,"func_code"))

	@staticmethod
	def deleteField(o,field):
		if (not hasattr(o,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)))):
			return False
		o.__delattr__(field)
		return True
Reflect._hx_class = Reflect
_hx_classes["Reflect"] = Reflect


class Std:
	_hx_class_name = "Std"
	_hx_statics = ["is", "string", "parseInt", "shortenPossibleNumber", "parseFloat"]

	@staticmethod
	def _hx_is(v,t):
		if ((v is None) and ((t is None))):
			return False
		if (t is None):
			return False
		if (t == Dynamic):
			return True
		isBool = isinstance(v,bool)
		if ((t == Bool) and isBool):
			return True
		if ((((not isBool) and (not (t == Bool))) and (t == Int)) and isinstance(v,int)):
			return True
		vIsFloat = isinstance(v,float)
		def _hx_local_0():
			f = v
			return (((f != Math.POSITIVE_INFINITY) and ((f != Math.NEGATIVE_INFINITY))) and (not python_lib_Math.isnan(f)))
		def _hx_local_1():
			x = v
			def _hx_local_4():
				def _hx_local_3():
					_hx_local_2 = None
					try:
						_hx_local_2 = int(x)
					except Exception as _hx_e:
						_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
						e = _hx_e1
						_hx_local_2 = None
					return _hx_local_2
				return _hx_local_3()
			return _hx_local_4()
		if (((((((not isBool) and vIsFloat) and (t == Int)) and _hx_local_0()) and ((v == _hx_local_1()))) and ((v <= 2147483647))) and ((v >= -2147483648))):
			return True
		if (((not isBool) and (t == Float)) and isinstance(v,(float, int))):
			return True
		if (t == str):
			return isinstance(v,str)
		isEnumType = (t == Enum)
		if ((isEnumType and python_lib_Inspect.isclass(v)) and hasattr(v,"_hx_constructs")):
			return True
		if isEnumType:
			return False
		isClassType = (t == Class)
		if ((((isClassType and (not isinstance(v,Enum))) and python_lib_Inspect.isclass(v)) and hasattr(v,"_hx_class_name")) and (not hasattr(v,"_hx_constructs"))):
			return True
		if isClassType:
			return False
		def _hx_local_6():
			_hx_local_5 = None
			try:
				_hx_local_5 = isinstance(v,t)
			except Exception as _hx_e:
				_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
				e1 = _hx_e1
				_hx_local_5 = False
			return _hx_local_5
		if _hx_local_6():
			return True
		if python_lib_Inspect.isclass(t):
			loop = None
			loop1 = None
			def _hx_local_8(intf):
				f1 = None
				if hasattr(intf,"_hx_interfaces"):
					f1 = intf._hx_interfaces
				else:
					f1 = []
				if (f1 is not None):
					_g = 0
					while (_g < len(f1)):
						i = (f1[_g] if _g >= 0 and _g < len(f1) else None)
						_g = (_g + 1)
						if HxOverrides.eq(i,t):
							return True
						else:
							l = loop1(i)
							if l:
								return True
					return False
				else:
					return False
			loop1 = _hx_local_8
			loop = loop1
			currentClass = v.__class__
			while (currentClass is not None):
				if loop(currentClass):
					return True
				currentClass = python_Boot.getSuperClass(currentClass)
			return False
		else:
			return False

	@staticmethod
	def string(s):
		return python_Boot.toString1(s,"")

	@staticmethod
	def parseInt(x):
		if (x is None):
			return None
		try:
			return int(x)
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			e = _hx_e1
			try:
				prefix = None
				_this = HxString.substr(x,0,2)
				prefix = _this.lower()
				if (prefix == "0x"):
					return int(x,16)
				raise _HxException("fail")
			except Exception as _hx_e:
				_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
				e1 = _hx_e1
				r = None
				x1 = Std.parseFloat(x)
				try:
					r = int(x1)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e2 = _hx_e1
					r = None
				if (r is None):
					r1 = Std.shortenPossibleNumber(x)
					if (r1 != x):
						return Std.parseInt(r1)
					else:
						return None
				return r

	@staticmethod
	def shortenPossibleNumber(x):
		r = ""
		_g1 = 0
		_g = len(x)
		while (_g1 < _g):
			i = _g1
			_g1 = (_g1 + 1)
			c = None
			if ((i < 0) or ((i >= len(x)))):
				c = ""
			else:
				c = x[i]
			_g2 = HxString.charCodeAt(c,0)
			if (_g2 is not None):
				if (((((((((((_g2 == 46) or ((_g2 == 57))) or ((_g2 == 56))) or ((_g2 == 55))) or ((_g2 == 54))) or ((_g2 == 53))) or ((_g2 == 52))) or ((_g2 == 51))) or ((_g2 == 50))) or ((_g2 == 49))) or ((_g2 == 48))):
					r = (("null" if r is None else r) + ("null" if c is None else c))
				else:
					break
			else:
				break
		return r

	@staticmethod
	def parseFloat(x):
		try:
			return float(x)
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			e = _hx_e1
			if (x is not None):
				r1 = Std.shortenPossibleNumber(x)
				if (r1 != x):
					return Std.parseFloat(r1)
			return Math.NaN
Std._hx_class = Std
_hx_classes["Std"] = Std


class Float:
	_hx_class_name = "Float"
Float._hx_class = Float
_hx_classes["Float"] = Float


class Int:
	_hx_class_name = "Int"
Int._hx_class = Int
_hx_classes["Int"] = Int


class Bool:
	_hx_class_name = "Bool"
Bool._hx_class = Bool
_hx_classes["Bool"] = Bool


class Dynamic:
	_hx_class_name = "Dynamic"
Dynamic._hx_class = Dynamic
_hx_classes["Dynamic"] = Dynamic


class StringBuf:
	_hx_class_name = "StringBuf"
	_hx_fields = ["b"]
	_hx_methods = ["toString"]

	def __init__(self):
		self.b = None
		self.b = python_lib_io_StringIO()

	def toString(self):
		return self.b.getvalue()

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.b = None
		_hx_o.length = None
StringBuf._hx_class = StringBuf
_hx_classes["StringBuf"] = StringBuf


class StringTools:
	_hx_class_name = "StringTools"
	_hx_statics = ["startsWith", "replace"]

	@staticmethod
	def startsWith(s,start):
		return ((len(s) >= len(start)) and ((HxString.substr(s,0,len(start)) == start)))

	@staticmethod
	def replace(s,sub,by):
		_this = None
		if (sub == ""):
			_this = list(s)
		else:
			_this = s.split(sub)
		return by.join([python_Boot.toString1(x1,'') for x1 in _this])
StringTools._hx_class = StringTools
_hx_classes["StringTools"] = StringTools


class haxe_IMap:
	_hx_class_name = "haxe.IMap"
	_hx_methods = ["get", "set", "exists", "remove", "keys", "iterator"]
haxe_IMap._hx_class = haxe_IMap
_hx_classes["haxe.IMap"] = haxe_IMap


class haxe_ds_StringMap:
	_hx_class_name = "haxe.ds.StringMap"
	_hx_fields = ["h"]
	_hx_methods = ["set", "get", "exists", "remove", "keys", "iterator", "toString"]
	_hx_interfaces = [haxe_IMap]

	def __init__(self):
		self.h = None
		self.h = dict()

	def set(self,key,value):
		self.h[key] = value

	def get(self,key):
		return self.h.get(key,None)

	def exists(self,key):
		return key in self.h

	def remove(self,key):
		has = key in self.h
		if has:
			del self.h[key]
		return has

	def keys(self):
		this1 = None
		_this = list(self.h.keys())
		this1 = iter(_this)
		return python_HaxeIterator(this1)

	def iterator(self):
		this1 = None
		_this = self.h.values()
		this1 = iter(_this)
		return python_HaxeIterator(this1)

	def toString(self):
		s_b = python_lib_io_StringIO()
		s_b.write("{")
		it = self.keys()
		_hx_local_0 = it
		while _hx_local_0.hasNext():
			i = _hx_local_0.next()
			s_b.write(Std.string(i))
			s_b.write(" => ")
			x = Std.string(self.h.get(i,None))
			s_b.write(Std.string(x))
			if it.hasNext():
				s_b.write(", ")
		s_b.write("}")
		return s_b.getvalue()

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.h = None
haxe_ds_StringMap._hx_class = haxe_ds_StringMap
_hx_classes["haxe.ds.StringMap"] = haxe_ds_StringMap


class python_HaxeIterator:
	_hx_class_name = "python.HaxeIterator"
	_hx_fields = ["it", "x", "has", "checked"]
	_hx_methods = ["next", "hasNext"]

	def __init__(self,it):
		self.it = None
		self.x = None
		self.has = None
		self.checked = None
		self.checked = False
		self.has = False
		self.x = None
		self.it = it

	def next(self):
		if (not self.checked):
			self.hasNext()
		self.checked = False
		return self.x

	def hasNext(self):
		if (not self.checked):
			try:
				self.x = self.it.__next__()
				self.has = True
			except Exception as _hx_e:
				_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
				if isinstance(_hx_e1, StopIteration):
					s = _hx_e1
					self.has = False
					self.x = None
				else:
					raise _hx_e
			self.checked = True
		return self.has

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.it = None
		_hx_o.x = None
		_hx_o.has = None
		_hx_o.checked = None
python_HaxeIterator._hx_class = python_HaxeIterator
_hx_classes["python.HaxeIterator"] = python_HaxeIterator

class ValueType(Enum):
	_hx_class_name = "ValueType"
	_hx_constructs = ["TNull", "TInt", "TFloat", "TBool", "TObject", "TFunction", "TClass", "TEnum", "TUnknown"]

	@staticmethod
	def TClass(c):
		return ValueType("TClass", 6, [c])

	@staticmethod
	def TEnum(e):
		return ValueType("TEnum", 7, [e])
ValueType.TNull = ValueType("TNull", 0, list())
ValueType.TInt = ValueType("TInt", 1, list())
ValueType.TFloat = ValueType("TFloat", 2, list())
ValueType.TBool = ValueType("TBool", 3, list())
ValueType.TObject = ValueType("TObject", 4, list())
ValueType.TFunction = ValueType("TFunction", 5, list())
ValueType.TUnknown = ValueType("TUnknown", 8, list())
ValueType._hx_class = ValueType
_hx_classes["ValueType"] = ValueType


class Type:
	_hx_class_name = "Type"
	_hx_statics = ["getClass", "getSuperClass", "getClassName", "getEnumName", "resolveClass", "resolveEnum", "createInstance", "createEmptyInstance", "createEnum", "getEnumConstructs", "typeof"]

	@staticmethod
	def getClass(o):
		if (o is None):
			return None
		if ((o is not None) and (((o == str) or python_lib_Inspect.isclass(o)))):
			return None
		if isinstance(o,_hx_AnonObject):
			return None
		if hasattr(o,"_hx_class"):
			return o._hx_class
		if hasattr(o,"__class__"):
			return o.__class__
		else:
			return None

	@staticmethod
	def getSuperClass(c):
		return python_Boot.getSuperClass(c)

	@staticmethod
	def getClassName(c):
		if hasattr(c,"_hx_class_name"):
			return c._hx_class_name
		else:
			if (c == list):
				return "Array"
			if (c == Math):
				return "Math"
			if (c == str):
				return "String"
			try:
				s = c.__name__
			except Exception as _hx_e:
				_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
				pass
		res = None
		return res

	@staticmethod
	def getEnumName(e):
		return e._hx_class_name

	@staticmethod
	def resolveClass(name):
		if (name == "Array"):
			return list
		if (name == "Math"):
			return Math
		if (name == "String"):
			return str
		cl = _hx_classes.get(name,None)
		if ((cl is None) or (not (((cl is not None) and (((cl == str) or python_lib_Inspect.isclass(cl))))))):
			return None
		return cl

	@staticmethod
	def resolveEnum(name):
		if (name == "Bool"):
			return Bool
		o = Type.resolveClass(name)
		if hasattr(o,"_hx_constructs"):
			return o
		else:
			return None

	@staticmethod
	def createInstance(cl,args):
		l = len(args)
		if (l == 0):
			return cl()
		elif (l == 1):
			return cl((args[0] if 0 < len(args) else None))
		elif (l == 2):
			return cl((args[0] if 0 < len(args) else None), (args[1] if 1 < len(args) else None))
		elif (l == 3):
			return cl((args[0] if 0 < len(args) else None), (args[1] if 1 < len(args) else None), (args[2] if 2 < len(args) else None))
		elif (l == 4):
			return cl((args[0] if 0 < len(args) else None), (args[1] if 1 < len(args) else None), (args[2] if 2 < len(args) else None), (args[3] if 3 < len(args) else None))
		elif (l == 5):
			return cl((args[0] if 0 < len(args) else None), (args[1] if 1 < len(args) else None), (args[2] if 2 < len(args) else None), (args[3] if 3 < len(args) else None), (args[4] if 4 < len(args) else None))
		elif (l == 6):
			return cl((args[0] if 0 < len(args) else None), (args[1] if 1 < len(args) else None), (args[2] if 2 < len(args) else None), (args[3] if 3 < len(args) else None), (args[4] if 4 < len(args) else None), (args[5] if 5 < len(args) else None))
		elif (l == 7):
			return cl((args[0] if 0 < len(args) else None), (args[1] if 1 < len(args) else None), (args[2] if 2 < len(args) else None), (args[3] if 3 < len(args) else None), (args[4] if 4 < len(args) else None), (args[5] if 5 < len(args) else None), (args[6] if 6 < len(args) else None))
		elif (l == 8):
			return cl((args[0] if 0 < len(args) else None), (args[1] if 1 < len(args) else None), (args[2] if 2 < len(args) else None), (args[3] if 3 < len(args) else None), (args[4] if 4 < len(args) else None), (args[5] if 5 < len(args) else None), (args[6] if 6 < len(args) else None), (args[7] if 7 < len(args) else None))
		else:
			raise _HxException("Too many arguments")

	@staticmethod
	def createEmptyInstance(cl):
		i = cl.__new__(cl)
		callInit = None
		callInit1 = None
		def _hx_local_0(cl1):
			sc = Type.getSuperClass(cl1)
			if (sc is not None):
				callInit1(sc)
			if hasattr(cl1,"_hx_empty_init"):
				cl1._hx_empty_init(i)
		callInit1 = _hx_local_0
		callInit = callInit1
		callInit(cl)
		return i

	@staticmethod
	def createEnum(e,constr,params = None):
		f = Reflect.field(e,constr)
		if (f is None):
			raise _HxException(("No such constructor " + ("null" if constr is None else constr)))
		if Reflect.isFunction(f):
			if (params is None):
				raise _HxException((("Constructor " + ("null" if constr is None else constr)) + " need parameters"))
			return Reflect.callMethod(e,f,params)
		if ((params is not None) and ((len(params) != 0))):
			raise _HxException((("Constructor " + ("null" if constr is None else constr)) + " does not need parameters"))
		return f

	@staticmethod
	def getEnumConstructs(e):
		if hasattr(e,"_hx_constructs"):
			x = e._hx_constructs
			return list(x)
		else:
			return []

	@staticmethod
	def typeof(v):
		if (v is None):
			return ValueType.TNull
		elif isinstance(v,bool):
			return ValueType.TBool
		elif isinstance(v,int):
			return ValueType.TInt
		elif isinstance(v,float):
			return ValueType.TFloat
		elif isinstance(v,str):
			return ValueType.TClass(str)
		elif isinstance(v,list):
			return ValueType.TClass(list)
		elif (isinstance(v,_hx_AnonObject) or python_lib_Inspect.isclass(v)):
			return ValueType.TObject
		elif isinstance(v,Enum):
			return ValueType.TEnum(v.__class__)
		elif (isinstance(v,type) or hasattr(v,"_hx_class")):
			return ValueType.TClass(v.__class__)
		elif callable(v):
			return ValueType.TFunction
		else:
			return ValueType.TUnknown
Type._hx_class = Type
_hx_classes["Type"] = Type


class bindings_NodeSocket:
	_hx_class_name = "bindings.NodeSocket"
	_hx_fields = ["theNativeSocket", "id"]
	_hx_methods = ["on", "emit", "getId", "disconnect"]

	def __init__(self,nativeSocket):
		self.theNativeSocket = None
		self.id = None
		self.theNativeSocket = nativeSocket

	def on(self,command,func):
		Reflect.field(self.theNativeSocket,"on")(command,func)

	def emit(self,command,obj):
		Reflect.field(self.theNativeSocket,"emit")(command,obj)

	def getId(self):
		return Reflect.field(self.theNativeSocket,"id")

	def disconnect(self):
		Reflect.field(self.theNativeSocket,"disconnect")()

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.theNativeSocket = None
		_hx_o.id = None
bindings_NodeSocket._hx_class = bindings_NodeSocket
_hx_classes["bindings.NodeSocket"] = bindings_NodeSocket


class haxe_Serializer:
	_hx_class_name = "haxe.Serializer"
	_hx_fields = ["buf", "cache", "shash", "scount", "useCache", "useEnumIndex"]
	_hx_methods = ["toString", "serializeString", "serializeRef", "serializeFields", "serialize"]
	_hx_statics = ["USE_CACHE", "USE_ENUM_INDEX", "BASE64", "run"]

	def __init__(self):
		self.buf = None
		self.cache = None
		self.shash = None
		self.scount = None
		self.useCache = None
		self.useEnumIndex = None
		self.buf = StringBuf()
		self.cache = list()
		self.useCache = haxe_Serializer.USE_CACHE
		self.useEnumIndex = haxe_Serializer.USE_ENUM_INDEX
		self.shash = haxe_ds_StringMap()
		self.scount = 0

	def toString(self):
		return self.buf.b.getvalue()

	def serializeString(self,s):
		x = self.shash.h.get(s,None)
		if (x is not None):
			self.buf.b.write("R")
			self.buf.b.write(Std.string(x))
			return
		value = self.scount
		self.scount = (self.scount + 1)
		self.shash.h[s] = value
		self.buf.b.write("y")
		s = python_lib_urllib_Parse.quote(s,"")
		self.buf.b.write(Std.string(len(s)))
		self.buf.b.write(":")
		self.buf.b.write(Std.string(s))

	def serializeRef(self,v):
		_g1 = 0
		_g = len(self.cache)
		while (_g1 < _g):
			i = _g1
			_g1 = (_g1 + 1)
			if ((self.cache[i] if i >= 0 and i < len(self.cache) else None) == v):
				self.buf.b.write("r")
				self.buf.b.write(Std.string(i))
				return True
		_this = self.cache
		_this.append(v)
		return False

	def serializeFields(self,v):
		_g = 0
		_g1 = python_Boot.fields(v)
		while (_g < len(_g1)):
			f = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
			_g = (_g + 1)
			self.serializeString(f)
			self.serialize(Reflect.field(v,f))
		self.buf.b.write("g")

	def serialize(self,v):
		_g = Type.typeof(v)
		if ((_g.index) == 0):
			self.buf.b.write("n")
		elif ((_g.index) == 1):
			v1 = v
			if (v1 == 0):
				self.buf.b.write("z")
				return
			self.buf.b.write("i")
			self.buf.b.write(Std.string(v1))
		elif ((_g.index) == 2):
			v2 = v
			if python_lib_Math.isnan(v2):
				self.buf.b.write("k")
			elif (not ((((v2 != Math.POSITIVE_INFINITY) and ((v2 != Math.NEGATIVE_INFINITY))) and (not python_lib_Math.isnan(v2))))):
				self.buf.b.write(("m" if ((v2 < 0)) else "p"))
			else:
				self.buf.b.write("d")
				self.buf.b.write(Std.string(v2))
		elif ((_g.index) == 3):
			self.buf.b.write(("t" if v else "f"))
		elif ((_g.index) == 6):
			c = _g.params[0]
			if (c == str):
				self.serializeString(v)
				return
			if (self.useCache and self.serializeRef(v)):
				return
			_g1 = Type.getClassName(c)
			_hx_local_0 = len(_g1)
			if (_hx_local_0 == 17):
				if (_g1 == "haxe.ds.StringMap"):
					self.buf.b.write("b")
					v5 = v
					_hx_local_1 = v5.keys()
					while _hx_local_1.hasNext():
						k = _hx_local_1.next()
						self.serializeString(k)
						self.serialize(v5.h.get(k,None))
					self.buf.b.write("h")
				elif (_g1 == "haxe.ds.ObjectMap"):
					self.buf.b.write("M")
					v7 = v
					_hx_local_2 = v7.keys()
					while _hx_local_2.hasNext():
						k2 = _hx_local_2.next()
						self.serialize(k2)
						self.serialize(v7.h.get(k2,None))
					self.buf.b.write("h")
				else:
					if self.useCache:
						_this = self.cache
						if (len(_this) == 0):
							None
						else:
							_this.pop()
					if hasattr(v,(("_hx_" + "hxSerialize") if ("hxSerialize" in python_Boot.keywords) else (("_hx_" + "hxSerialize") if (((((len("hxSerialize") > 2) and ((ord("hxSerialize"[0]) == 95))) and ((ord("hxSerialize"[1]) == 95))) and ((ord("hxSerialize"[(len("hxSerialize") - 1)]) != 95)))) else "hxSerialize"))):
						self.buf.b.write("C")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this1 = self.cache
							x10 = v
							_this1.append(x10)
						Reflect.field(v,"hxSerialize")(self)
						self.buf.b.write("g")
					else:
						self.buf.b.write("c")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this2 = self.cache
							x11 = v
							_this2.append(x11)
						self.serializeFields(v)
			elif (_hx_local_0 == 5):
				if (_g1 == "Array"):
					ucount = 0
					self.buf.b.write("a")
					v3 = v
					l = len(v3)
					_g2 = 0
					while (_g2 < l):
						i = _g2
						_g2 = (_g2 + 1)
						if ((v3[i] if i >= 0 and i < len(v3) else None) is None):
							ucount = (ucount + 1)
						else:
							if (ucount > 0):
								if (ucount == 1):
									self.buf.b.write("n")
								else:
									self.buf.b.write("u")
									self.buf.b.write(Std.string(ucount))
								ucount = 0
							self.serialize((v3[i] if i >= 0 and i < len(v3) else None))
					if (ucount > 0):
						if (ucount == 1):
							self.buf.b.write("n")
						else:
							self.buf.b.write("u")
							self.buf.b.write(Std.string(ucount))
					self.buf.b.write("h")
				else:
					if self.useCache:
						_this = self.cache
						if (len(_this) == 0):
							None
						else:
							_this.pop()
					if hasattr(v,(("_hx_" + "hxSerialize") if ("hxSerialize" in python_Boot.keywords) else (("_hx_" + "hxSerialize") if (((((len("hxSerialize") > 2) and ((ord("hxSerialize"[0]) == 95))) and ((ord("hxSerialize"[1]) == 95))) and ((ord("hxSerialize"[(len("hxSerialize") - 1)]) != 95)))) else "hxSerialize"))):
						self.buf.b.write("C")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this1 = self.cache
							x10 = v
							_this1.append(x10)
						Reflect.field(v,"hxSerialize")(self)
						self.buf.b.write("g")
					else:
						self.buf.b.write("c")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this2 = self.cache
							x11 = v
							_this2.append(x11)
						self.serializeFields(v)
			elif (_hx_local_0 == 4):
				if (_g1 == "List"):
					self.buf.b.write("l")
					v4 = v
					_g2_head = v4.h
					_g2_val = None
					while (_g2_head is not None):
						i1 = None
						_g2_val = (_g2_head[0] if 0 < len(_g2_head) else None)
						_g2_head = (_g2_head[1] if 1 < len(_g2_head) else None)
						i1 = _g2_val
						self.serialize(i1)
					self.buf.b.write("h")
				elif (_g1 == "Date"):
					d = v
					self.buf.b.write("v")
					x = Date.datetimeTimestamp(d.date,Date.EPOCH_LOCAL)
					self.buf.b.write(Std.string(x))
				else:
					if self.useCache:
						_this = self.cache
						if (len(_this) == 0):
							None
						else:
							_this.pop()
					if hasattr(v,(("_hx_" + "hxSerialize") if ("hxSerialize" in python_Boot.keywords) else (("_hx_" + "hxSerialize") if (((((len("hxSerialize") > 2) and ((ord("hxSerialize"[0]) == 95))) and ((ord("hxSerialize"[1]) == 95))) and ((ord("hxSerialize"[(len("hxSerialize") - 1)]) != 95)))) else "hxSerialize"))):
						self.buf.b.write("C")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this1 = self.cache
							x10 = v
							_this1.append(x10)
						Reflect.field(v,"hxSerialize")(self)
						self.buf.b.write("g")
					else:
						self.buf.b.write("c")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this2 = self.cache
							x11 = v
							_this2.append(x11)
						self.serializeFields(v)
			elif (_hx_local_0 == 13):
				if (_g1 == "haxe.io.Bytes"):
					v8 = v
					i2 = 0
					_hx_max = (v8.length - 2)
					charsBuf_b = python_lib_io_StringIO()
					b64 = haxe_Serializer.BASE64
					while (i2 < _hx_max):
						b1 = None
						pos = i2
						i2 = (i2 + 1)
						b1 = v8.b[pos]
						b2 = None
						pos1 = i2
						i2 = (i2 + 1)
						b2 = v8.b[pos1]
						b3 = None
						pos2 = i2
						i2 = (i2 + 1)
						b3 = v8.b[pos2]
						x1 = None
						index = (b1 >> 2)
						if ((index < 0) or ((index >= len(b64)))):
							x1 = ""
						else:
							x1 = b64[index]
						charsBuf_b.write(Std.string(x1))
						x2 = None
						index1 = ((((b1 << 4) | ((b2 >> 4)))) & 63)
						if ((index1 < 0) or ((index1 >= len(b64)))):
							x2 = ""
						else:
							x2 = b64[index1]
						charsBuf_b.write(Std.string(x2))
						x3 = None
						index2 = ((((b2 << 2) | ((b3 >> 6)))) & 63)
						if ((index2 < 0) or ((index2 >= len(b64)))):
							x3 = ""
						else:
							x3 = b64[index2]
						charsBuf_b.write(Std.string(x3))
						x4 = None
						index3 = (b3 & 63)
						if ((index3 < 0) or ((index3 >= len(b64)))):
							x4 = ""
						else:
							x4 = b64[index3]
						charsBuf_b.write(Std.string(x4))
					if (i2 == _hx_max):
						b11 = None
						pos3 = i2
						i2 = (i2 + 1)
						b11 = v8.b[pos3]
						b21 = None
						pos4 = i2
						i2 = (i2 + 1)
						b21 = v8.b[pos4]
						x5 = None
						index4 = (b11 >> 2)
						if ((index4 < 0) or ((index4 >= len(b64)))):
							x5 = ""
						else:
							x5 = b64[index4]
						charsBuf_b.write(Std.string(x5))
						x6 = None
						index5 = ((((b11 << 4) | ((b21 >> 4)))) & 63)
						if ((index5 < 0) or ((index5 >= len(b64)))):
							x6 = ""
						else:
							x6 = b64[index5]
						charsBuf_b.write(Std.string(x6))
						x7 = None
						index6 = ((b21 << 2) & 63)
						if ((index6 < 0) or ((index6 >= len(b64)))):
							x7 = ""
						else:
							x7 = b64[index6]
						charsBuf_b.write(Std.string(x7))
					elif (i2 == ((_hx_max + 1))):
						b12 = None
						pos5 = i2
						i2 = (i2 + 1)
						b12 = v8.b[pos5]
						x8 = None
						index7 = (b12 >> 2)
						if ((index7 < 0) or ((index7 >= len(b64)))):
							x8 = ""
						else:
							x8 = b64[index7]
						charsBuf_b.write(Std.string(x8))
						x9 = None
						index8 = ((b12 << 4) & 63)
						if ((index8 < 0) or ((index8 >= len(b64)))):
							x9 = ""
						else:
							x9 = b64[index8]
						charsBuf_b.write(Std.string(x9))
					chars = charsBuf_b.getvalue()
					self.buf.b.write("s")
					self.buf.b.write(Std.string(len(chars)))
					self.buf.b.write(":")
					self.buf.b.write(Std.string(chars))
				else:
					if self.useCache:
						_this = self.cache
						if (len(_this) == 0):
							None
						else:
							_this.pop()
					if hasattr(v,(("_hx_" + "hxSerialize") if ("hxSerialize" in python_Boot.keywords) else (("_hx_" + "hxSerialize") if (((((len("hxSerialize") > 2) and ((ord("hxSerialize"[0]) == 95))) and ((ord("hxSerialize"[1]) == 95))) and ((ord("hxSerialize"[(len("hxSerialize") - 1)]) != 95)))) else "hxSerialize"))):
						self.buf.b.write("C")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this1 = self.cache
							x10 = v
							_this1.append(x10)
						Reflect.field(v,"hxSerialize")(self)
						self.buf.b.write("g")
					else:
						self.buf.b.write("c")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this2 = self.cache
							x11 = v
							_this2.append(x11)
						self.serializeFields(v)
			elif (_hx_local_0 == 14):
				if (_g1 == "haxe.ds.IntMap"):
					self.buf.b.write("q")
					v6 = v
					_hx_local_4 = v6.keys()
					while _hx_local_4.hasNext():
						k1 = _hx_local_4.next()
						self.buf.b.write(":")
						self.buf.b.write(Std.string(k1))
						self.serialize(v6.h.get(k1,None))
					self.buf.b.write("h")
				else:
					if self.useCache:
						_this = self.cache
						if (len(_this) == 0):
							None
						else:
							_this.pop()
					if hasattr(v,(("_hx_" + "hxSerialize") if ("hxSerialize" in python_Boot.keywords) else (("_hx_" + "hxSerialize") if (((((len("hxSerialize") > 2) and ((ord("hxSerialize"[0]) == 95))) and ((ord("hxSerialize"[1]) == 95))) and ((ord("hxSerialize"[(len("hxSerialize") - 1)]) != 95)))) else "hxSerialize"))):
						self.buf.b.write("C")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this1 = self.cache
							x10 = v
							_this1.append(x10)
						Reflect.field(v,"hxSerialize")(self)
						self.buf.b.write("g")
					else:
						self.buf.b.write("c")
						self.serializeString(Type.getClassName(c))
						if self.useCache:
							_this2 = self.cache
							x11 = v
							_this2.append(x11)
						self.serializeFields(v)
			else:
				if self.useCache:
					_this = self.cache
					if (len(_this) == 0):
						None
					else:
						_this.pop()
				if hasattr(v,(("_hx_" + "hxSerialize") if ("hxSerialize" in python_Boot.keywords) else (("_hx_" + "hxSerialize") if (((((len("hxSerialize") > 2) and ((ord("hxSerialize"[0]) == 95))) and ((ord("hxSerialize"[1]) == 95))) and ((ord("hxSerialize"[(len("hxSerialize") - 1)]) != 95)))) else "hxSerialize"))):
					self.buf.b.write("C")
					self.serializeString(Type.getClassName(c))
					if self.useCache:
						_this1 = self.cache
						x10 = v
						_this1.append(x10)
					Reflect.field(v,"hxSerialize")(self)
					self.buf.b.write("g")
				else:
					self.buf.b.write("c")
					self.serializeString(Type.getClassName(c))
					if self.useCache:
						_this2 = self.cache
						x11 = v
						_this2.append(x11)
					self.serializeFields(v)
		elif ((_g.index) == 4):
			if Std._hx_is(v,Class):
				className = Type.getClassName(v)
				self.buf.b.write("A")
				self.serializeString(className)
			elif Std._hx_is(v,Enum):
				self.buf.b.write("B")
				self.serializeString(Type.getEnumName(v))
			else:
				if (self.useCache and self.serializeRef(v)):
					return
				self.buf.b.write("o")
				self.serializeFields(v)
		elif ((_g.index) == 7):
			e = _g.params[0]
			if self.useCache:
				if self.serializeRef(v):
					return
				_this3 = self.cache
				if (len(_this3) == 0):
					None
				else:
					_this3.pop()
			self.buf.b.write(("j" if (self.useEnumIndex) else "w"))
			self.serializeString(Type.getEnumName(e))
			if self.useEnumIndex:
				self.buf.b.write(":")
				def _hx_local_5():
					e1 = v
					return e1.index
				self.buf.b.write(Std.string(_hx_local_5()))
			else:
				def _hx_local_6():
					e2 = v
					return e2.tag
				self.serializeString(_hx_local_6())
			self.buf.b.write(":")
			arr = None
			e3 = v
			arr = e3.params
			if (arr is not None):
				self.buf.b.write(Std.string(len(arr)))
				_g11 = 0
				while (_g11 < len(arr)):
					v9 = (arr[_g11] if _g11 >= 0 and _g11 < len(arr) else None)
					_g11 = (_g11 + 1)
					self.serialize(v9)
			else:
				self.buf.b.write("0")
			if self.useCache:
				_this4 = self.cache
				x12 = v
				_this4.append(x12)
		elif ((_g.index) == 5):
			raise _HxException("Cannot serialize function")
		else:
			raise _HxException(("Cannot serialize " + Std.string(v)))

	@staticmethod
	def run(v):
		s = haxe_Serializer()
		s.serialize(v)
		return s.toString()

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.buf = None
		_hx_o.cache = None
		_hx_o.shash = None
		_hx_o.scount = None
		_hx_o.useCache = None
		_hx_o.useEnumIndex = None
haxe_Serializer._hx_class = haxe_Serializer
_hx_classes["haxe.Serializer"] = haxe_Serializer


class haxe_Timer:
	_hx_class_name = "haxe.Timer"
	_hx_methods = ["stop", "run"]
	_hx_statics = ["delay"]

	def __init__(self,time_ms):
		pass

	def stop(self):
		pass

	def run(self):
		pass

	@staticmethod
	def delay(f,time_ms):
		t = haxe_Timer(time_ms)
		def _hx_local_0():
			t.stop()
			f()
		t.run = _hx_local_0
		return t

	@staticmethod
	def _hx_empty_init(_hx_o):		pass
haxe_Timer._hx_class = haxe_Timer
_hx_classes["haxe.Timer"] = haxe_Timer


class haxe_Unserializer:
	_hx_class_name = "haxe.Unserializer"
	_hx_fields = ["buf", "pos", "length", "cache", "scache", "resolver"]
	_hx_methods = ["setResolver", "readDigits", "readFloat", "unserializeObject", "unserializeEnum", "unserialize"]
	_hx_statics = ["DEFAULT_RESOLVER", "BASE64", "CODES", "initCodes", "run"]

	def __init__(self,buf):
		self.buf = None
		self.pos = None
		self.length = None
		self.cache = None
		self.scache = None
		self.resolver = None
		self.buf = buf
		self.length = len(buf)
		self.pos = 0
		self.scache = list()
		self.cache = list()
		r = haxe_Unserializer.DEFAULT_RESOLVER
		if (r is None):
			r = Type
			haxe_Unserializer.DEFAULT_RESOLVER = r
		self.setResolver(r)

	def setResolver(self,r):
		if (r is None):
			def _hx_local_0(_):
				return None
			def _hx_local_1(_1):
				return None
			self.resolver = _hx_AnonObject({'resolveClass': _hx_local_0, 'resolveEnum': _hx_local_1})
		else:
			self.resolver = r

	def readDigits(self):
		k = 0
		s = False
		fpos = self.pos
		while True:
			c = None
			p = self.pos
			s1 = self.buf
			if (p >= len(s1)):
				c = -1
			else:
				c = ord(s1[p])
			if (c == -1):
				break
			if (c == 45):
				if (self.pos != fpos):
					break
				s = True
				_hx_local_0 = self
				_hx_local_1 = _hx_local_0.pos
				_hx_local_0.pos = (_hx_local_1 + 1)
				_hx_local_1
				continue
			if ((c < 48) or ((c > 57))):
				break
			k = ((k * 10) + ((c - 48)))
			_hx_local_2 = self
			_hx_local_3 = _hx_local_2.pos
			_hx_local_2.pos = (_hx_local_3 + 1)
			_hx_local_3
		if s:
			k = (k * -1)
		return k

	def readFloat(self):
		p1 = self.pos
		while True:
			c = None
			p = self.pos
			s = self.buf
			if (p >= len(s)):
				c = -1
			else:
				c = ord(s[p])
			if ((((c >= 43) and ((c < 58))) or ((c == 101))) or ((c == 69))):
				_hx_local_0 = self
				_hx_local_1 = _hx_local_0.pos
				_hx_local_0.pos = (_hx_local_1 + 1)
				_hx_local_1
			else:
				break
		return Std.parseFloat(HxString.substr(self.buf,p1,(self.pos - p1)))

	def unserializeObject(self,o):
		while True:
			if (self.pos >= self.length):
				raise _HxException("Invalid object")
			def _hx_local_0():
				p = self.pos
				def _hx_local_2():
					def _hx_local_1():
						s = self.buf
						return (-1 if ((p >= len(s))) else ord(s[p]))
					return _hx_local_1()
				return _hx_local_2()
			if (_hx_local_0() == 103):
				break
			k = self.unserialize()
			if (not Std._hx_is(k,str)):
				raise _HxException("Invalid object key")
			v = self.unserialize()
			setattr(o,(("_hx_" + k) if (k in python_Boot.keywords) else (("_hx_" + k) if (((((len(k) > 2) and ((ord(k[0]) == 95))) and ((ord(k[1]) == 95))) and ((ord(k[(len(k) - 1)]) != 95)))) else k)),v)
		_hx_local_3 = self
		_hx_local_4 = _hx_local_3.pos
		_hx_local_3.pos = (_hx_local_4 + 1)
		_hx_local_4

	def unserializeEnum(self,edecl,tag):
		def _hx_local_0():
			p = self.pos
			self.pos = (self.pos + 1)
			def _hx_local_2():
				def _hx_local_1():
					s = self.buf
					return (-1 if ((p >= len(s))) else ord(s[p]))
				return _hx_local_1()
			return _hx_local_2()
		if (_hx_local_0() != 58):
			raise _HxException("Invalid enum format")
		nargs = self.readDigits()
		if (nargs == 0):
			return Type.createEnum(edecl,tag)
		args = list()
		def _hx_local_4():
			nonlocal nargs
			_hx_local_3 = nargs
			nargs = (nargs - 1)
			return _hx_local_3
		while (_hx_local_4() > 0):
			x = self.unserialize()
			args.append(x)
		return Type.createEnum(edecl,tag,args)

	def unserialize(self):
		_g = None
		p = self.pos
		self.pos = (self.pos + 1)
		s = self.buf
		if (p >= len(s)):
			_g = -1
		else:
			_g = ord(s[p])
		if (_g == 110):
			return None
		elif (_g == 116):
			return True
		elif (_g == 102):
			return False
		elif (_g == 122):
			return 0
		elif (_g == 105):
			return self.readDigits()
		elif (_g == 100):
			return self.readFloat()
		elif (_g == 121):
			_hx_len = self.readDigits()
			def _hx_local_0():
				p1 = self.pos
				self.pos = (self.pos + 1)
				def _hx_local_2():
					def _hx_local_1():
						s1 = self.buf
						return (-1 if ((p1 >= len(s1))) else ord(s1[p1]))
					return _hx_local_1()
				return _hx_local_2()
			if ((_hx_local_0() != 58) or (((self.length - self.pos) < _hx_len))):
				raise _HxException("Invalid string length")
			s2 = HxString.substr(self.buf,self.pos,_hx_len)
			_hx_local_3 = self
			_hx_local_4 = _hx_local_3.pos
			_hx_local_3.pos = (_hx_local_4 + _hx_len)
			_hx_local_3.pos
			s2 = python_lib_urllib_Parse.unquote(s2)
			_this = self.scache
			_this.append(s2)
			return s2
		elif (_g == 107):
			return Math.NaN
		elif (_g == 109):
			return Math.NEGATIVE_INFINITY
		elif (_g == 112):
			return Math.POSITIVE_INFINITY
		elif (_g == 97):
			buf = self.buf
			a = list()
			_this1 = self.cache
			_this1.append(a)
			while True:
				c = None
				p2 = self.pos
				s3 = self.buf
				if (p2 >= len(s3)):
					c = -1
				else:
					c = ord(s3[p2])
				if (c == 104):
					_hx_local_5 = self
					_hx_local_6 = _hx_local_5.pos
					_hx_local_5.pos = (_hx_local_6 + 1)
					_hx_local_6
					break
				if (c == 117):
					_hx_local_7 = self
					_hx_local_8 = _hx_local_7.pos
					_hx_local_7.pos = (_hx_local_8 + 1)
					_hx_local_8
					n = self.readDigits()
					python_internal_ArrayImpl._set(a, ((len(a) + n) - 1), None)
				else:
					x = self.unserialize()
					a.append(x)
			return a
		elif (_g == 111):
			o = _hx_AnonObject({})
			_this2 = self.cache
			_this2.append(o)
			self.unserializeObject(o)
			return o
		elif (_g == 114):
			n1 = self.readDigits()
			if ((n1 < 0) or ((n1 >= len(self.cache)))):
				raise _HxException("Invalid reference")
			return (self.cache[n1] if n1 >= 0 and n1 < len(self.cache) else None)
		elif (_g == 82):
			n2 = self.readDigits()
			if ((n2 < 0) or ((n2 >= len(self.scache)))):
				raise _HxException("Invalid string reference")
			return (self.scache[n2] if n2 >= 0 and n2 < len(self.scache) else None)
		elif (_g == 120):
			raise _HxException(self.unserialize())
		elif (_g == 99):
			name = self.unserialize()
			cl = self.resolver.resolveClass(name)
			if (cl is None):
				raise _HxException(("Class not found " + ("null" if name is None else name)))
			o1 = Type.createEmptyInstance(cl)
			_this3 = self.cache
			_this3.append(o1)
			self.unserializeObject(o1)
			return o1
		elif (_g == 119):
			name1 = self.unserialize()
			edecl = self.resolver.resolveEnum(name1)
			if (edecl is None):
				raise _HxException(("Enum not found " + ("null" if name1 is None else name1)))
			e = self.unserializeEnum(edecl,self.unserialize())
			_this4 = self.cache
			_this4.append(e)
			return e
		elif (_g == 106):
			name2 = self.unserialize()
			edecl1 = self.resolver.resolveEnum(name2)
			if (edecl1 is None):
				raise _HxException(("Enum not found " + ("null" if name2 is None else name2)))
			_hx_local_9 = self
			_hx_local_10 = _hx_local_9.pos
			_hx_local_9.pos = (_hx_local_10 + 1)
			_hx_local_10
			index = self.readDigits()
			tag = python_internal_ArrayImpl._get(Type.getEnumConstructs(edecl1), index)
			if (tag is None):
				raise _HxException(((("Unknown enum index " + ("null" if name2 is None else name2)) + "@") + Std.string(index)))
			e1 = self.unserializeEnum(edecl1,tag)
			_this5 = self.cache
			_this5.append(e1)
			return e1
		elif (_g == 108):
			l = List()
			_this6 = self.cache
			_this6.append(l)
			buf1 = self.buf
			def _hx_local_11():
				p3 = self.pos
				def _hx_local_13():
					def _hx_local_12():
						s4 = self.buf
						return (-1 if ((p3 >= len(s4))) else ord(s4[p3]))
					return _hx_local_12()
				return _hx_local_13()
			while (_hx_local_11() != 104):
				l.add(self.unserialize())
			_hx_local_14 = self
			_hx_local_15 = _hx_local_14.pos
			_hx_local_14.pos = (_hx_local_15 + 1)
			_hx_local_15
			return l
		elif (_g == 98):
			h = haxe_ds_StringMap()
			_this7 = self.cache
			_this7.append(h)
			buf2 = self.buf
			def _hx_local_16():
				p4 = self.pos
				def _hx_local_18():
					def _hx_local_17():
						s5 = self.buf
						return (-1 if ((p4 >= len(s5))) else ord(s5[p4]))
					return _hx_local_17()
				return _hx_local_18()
			while (_hx_local_16() != 104):
				s6 = self.unserialize()
				value = self.unserialize()
				h.h[s6] = value
			_hx_local_19 = self
			_hx_local_20 = _hx_local_19.pos
			_hx_local_19.pos = (_hx_local_20 + 1)
			_hx_local_20
			return h
		elif (_g == 113):
			h1 = haxe_ds_IntMap()
			_this8 = self.cache
			_this8.append(h1)
			buf3 = self.buf
			c1 = None
			p5 = self.pos
			self.pos = (self.pos + 1)
			s7 = self.buf
			if (p5 >= len(s7)):
				c1 = -1
			else:
				c1 = ord(s7[p5])
			while (c1 == 58):
				i = self.readDigits()
				h1.set(i,self.unserialize())
				p6 = self.pos
				self.pos = (self.pos + 1)
				s8 = self.buf
				if (p6 >= len(s8)):
					c1 = -1
				else:
					c1 = ord(s8[p6])
			if (c1 != 104):
				raise _HxException("Invalid IntMap format")
			return h1
		elif (_g == 77):
			h2 = haxe_ds_ObjectMap()
			_this9 = self.cache
			_this9.append(h2)
			buf4 = self.buf
			def _hx_local_21():
				p7 = self.pos
				def _hx_local_23():
					def _hx_local_22():
						s9 = self.buf
						return (-1 if ((p7 >= len(s9))) else ord(s9[p7]))
					return _hx_local_22()
				return _hx_local_23()
			while (_hx_local_21() != 104):
				s10 = self.unserialize()
				h2.set(s10,self.unserialize())
			_hx_local_24 = self
			_hx_local_25 = _hx_local_24.pos
			_hx_local_24.pos = (_hx_local_25 + 1)
			_hx_local_25
			return h2
		elif (_g == 118):
			d = None
			def _hx_local_26():
				p8 = self.pos
				def _hx_local_28():
					def _hx_local_27():
						s11 = self.buf
						return (-1 if ((p8 >= len(s11))) else ord(s11[p8]))
					return _hx_local_27()
				return _hx_local_28()
			def _hx_local_29():
				p9 = self.pos
				def _hx_local_31():
					def _hx_local_30():
						s12 = self.buf
						return (-1 if ((p9 >= len(s12))) else ord(s12[p9]))
					return _hx_local_30()
				return _hx_local_31()
			def _hx_local_32():
				p10 = (self.pos + 1)
				def _hx_local_34():
					def _hx_local_33():
						s13 = self.buf
						return (-1 if ((p10 >= len(s13))) else ord(s13[p10]))
					return _hx_local_33()
				return _hx_local_34()
			def _hx_local_35():
				p11 = (self.pos + 1)
				def _hx_local_37():
					def _hx_local_36():
						s14 = self.buf
						return (-1 if ((p11 >= len(s14))) else ord(s14[p11]))
					return _hx_local_36()
				return _hx_local_37()
			def _hx_local_38():
				p12 = (self.pos + 2)
				def _hx_local_40():
					def _hx_local_39():
						s15 = self.buf
						return (-1 if ((p12 >= len(s15))) else ord(s15[p12]))
					return _hx_local_39()
				return _hx_local_40()
			def _hx_local_41():
				p13 = (self.pos + 2)
				def _hx_local_43():
					def _hx_local_42():
						s16 = self.buf
						return (-1 if ((p13 >= len(s16))) else ord(s16[p13]))
					return _hx_local_42()
				return _hx_local_43()
			def _hx_local_44():
				p14 = (self.pos + 3)
				def _hx_local_46():
					def _hx_local_45():
						s17 = self.buf
						return (-1 if ((p14 >= len(s17))) else ord(s17[p14]))
					return _hx_local_45()
				return _hx_local_46()
			def _hx_local_47():
				p15 = (self.pos + 3)
				def _hx_local_49():
					def _hx_local_48():
						s18 = self.buf
						return (-1 if ((p15 >= len(s18))) else ord(s18[p15]))
					return _hx_local_48()
				return _hx_local_49()
			def _hx_local_50():
				p16 = (self.pos + 4)
				def _hx_local_52():
					def _hx_local_51():
						s19 = self.buf
						return (-1 if ((p16 >= len(s19))) else ord(s19[p16]))
					return _hx_local_51()
				return _hx_local_52()
			if (((((((((_hx_local_26() >= 48) and ((_hx_local_29() <= 57))) and ((_hx_local_32() >= 48))) and ((_hx_local_35() <= 57))) and ((_hx_local_38() >= 48))) and ((_hx_local_41() <= 57))) and ((_hx_local_44() >= 48))) and ((_hx_local_47() <= 57))) and ((_hx_local_50() == 45))):
				d = Date.fromString(HxString.substr(self.buf,self.pos,19))
				_hx_local_53 = self
				_hx_local_54 = _hx_local_53.pos
				_hx_local_53.pos = (_hx_local_54 + 19)
				_hx_local_53.pos
			else:
				d = Date.fromTime(self.readFloat())
			_this10 = self.cache
			_this10.append(d)
			return d
		elif (_g == 115):
			len1 = self.readDigits()
			buf5 = self.buf
			def _hx_local_55():
				p17 = self.pos
				self.pos = (self.pos + 1)
				def _hx_local_57():
					def _hx_local_56():
						s20 = self.buf
						return (-1 if ((p17 >= len(s20))) else ord(s20[p17]))
					return _hx_local_56()
				return _hx_local_57()
			if ((_hx_local_55() != 58) or (((self.length - self.pos) < len1))):
				raise _HxException("Invalid bytes length")
			codes = haxe_Unserializer.CODES
			if (codes is None):
				codes = haxe_Unserializer.initCodes()
				haxe_Unserializer.CODES = codes
			i1 = self.pos
			rest = (len1 & 3)
			size = None
			size = ((((len1 >> 2)) * 3) + (((rest - 1) if ((rest >= 2)) else 0)))
			_hx_max = (i1 + ((len1 - rest)))
			_hx_bytes = haxe_io_Bytes.alloc(size)
			bpos = 0
			while (i1 < _hx_max):
				def _hx_local_58():
					nonlocal i1
					index1 = i1
					i1 = (i1 + 1)
					return (-1 if ((index1 >= len(buf5))) else ord(buf5[index1]))
				c11 = python_internal_ArrayImpl._get(codes, _hx_local_58())
				def _hx_local_59():
					nonlocal i1
					index2 = i1
					i1 = (i1 + 1)
					return (-1 if ((index2 >= len(buf5))) else ord(buf5[index2]))
				c2 = python_internal_ArrayImpl._get(codes, _hx_local_59())
				pos = bpos
				bpos = (bpos + 1)
				_hx_bytes.b[pos] = ((((c11 << 2) | ((c2 >> 4)))) & 255)
				def _hx_local_60():
					nonlocal i1
					index3 = i1
					i1 = (i1 + 1)
					return (-1 if ((index3 >= len(buf5))) else ord(buf5[index3]))
				c3 = python_internal_ArrayImpl._get(codes, _hx_local_60())
				pos1 = bpos
				bpos = (bpos + 1)
				_hx_bytes.b[pos1] = ((((c2 << 4) | ((c3 >> 2)))) & 255)
				def _hx_local_61():
					nonlocal i1
					index4 = i1
					i1 = (i1 + 1)
					return (-1 if ((index4 >= len(buf5))) else ord(buf5[index4]))
				c4 = python_internal_ArrayImpl._get(codes, _hx_local_61())
				pos2 = bpos
				bpos = (bpos + 1)
				_hx_bytes.b[pos2] = ((((c3 << 6) | c4)) & 255)
			if (rest >= 2):
				def _hx_local_62():
					nonlocal i1
					index5 = i1
					i1 = (i1 + 1)
					return (-1 if ((index5 >= len(buf5))) else ord(buf5[index5]))
				c12 = python_internal_ArrayImpl._get(codes, _hx_local_62())
				def _hx_local_63():
					nonlocal i1
					index6 = i1
					i1 = (i1 + 1)
					return (-1 if ((index6 >= len(buf5))) else ord(buf5[index6]))
				c21 = python_internal_ArrayImpl._get(codes, _hx_local_63())
				pos3 = bpos
				bpos = (bpos + 1)
				_hx_bytes.b[pos3] = ((((c12 << 2) | ((c21 >> 4)))) & 255)
				if (rest == 3):
					def _hx_local_64():
						nonlocal i1
						index7 = i1
						i1 = (i1 + 1)
						return (-1 if ((index7 >= len(buf5))) else ord(buf5[index7]))
					c31 = python_internal_ArrayImpl._get(codes, _hx_local_64())
					pos4 = bpos
					bpos = (bpos + 1)
					_hx_bytes.b[pos4] = ((((c21 << 4) | ((c31 >> 2)))) & 255)
			_hx_local_65 = self
			_hx_local_66 = _hx_local_65.pos
			_hx_local_65.pos = (_hx_local_66 + len1)
			_hx_local_65.pos
			_this11 = self.cache
			_this11.append(_hx_bytes)
			return _hx_bytes
		elif (_g == 67):
			name3 = self.unserialize()
			cl1 = self.resolver.resolveClass(name3)
			if (cl1 is None):
				raise _HxException(("Class not found " + ("null" if name3 is None else name3)))
			o2 = Type.createEmptyInstance(cl1)
			_this12 = self.cache
			x1 = o2
			_this12.append(x1)
			Reflect.field(o2,"hxUnserialize")(self)
			def _hx_local_67():
				p18 = self.pos
				self.pos = (self.pos + 1)
				def _hx_local_69():
					def _hx_local_68():
						s21 = self.buf
						return (-1 if ((p18 >= len(s21))) else ord(s21[p18]))
					return _hx_local_68()
				return _hx_local_69()
			if (_hx_local_67() != 103):
				raise _HxException("Invalid custom data")
			return o2
		elif (_g == 65):
			name4 = self.unserialize()
			cl2 = self.resolver.resolveClass(name4)
			if (cl2 is None):
				raise _HxException(("Class not found " + ("null" if name4 is None else name4)))
			return cl2
		elif (_g == 66):
			name5 = self.unserialize()
			e2 = self.resolver.resolveEnum(name5)
			if (e2 is None):
				raise _HxException(("Enum not found " + ("null" if name5 is None else name5)))
			return e2
		else:
			pass
		_hx_local_70 = self
		_hx_local_71 = _hx_local_70.pos
		_hx_local_70.pos = (_hx_local_71 - 1)
		_hx_local_71
		def _hx_local_72():
			_this13 = self.buf
			index8 = self.pos
			return ("" if (((index8 < 0) or ((index8 >= len(_this13))))) else _this13[index8])
		raise _HxException(((("Invalid char " + HxOverrides.stringOrNull(_hx_local_72())) + " at position ") + Std.string(self.pos)))

	@staticmethod
	def initCodes():
		codes = list()
		_g1 = 0
		_g = len(haxe_Unserializer.BASE64)
		while (_g1 < _g):
			i = _g1
			_g1 = (_g1 + 1)
			def _hx_local_0():
				s = haxe_Unserializer.BASE64
				return (-1 if ((i >= len(s))) else ord(s[i]))
			python_internal_ArrayImpl._set(codes, _hx_local_0(), i)
		return codes

	@staticmethod
	def run(v):
		return haxe_Unserializer(v).unserialize()

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.buf = None
		_hx_o.pos = None
		_hx_o.length = None
		_hx_o.cache = None
		_hx_o.scache = None
		_hx_o.resolver = None
haxe_Unserializer._hx_class = haxe_Unserializer
_hx_classes["haxe.Unserializer"] = haxe_Unserializer


class haxe_crypto_Md5:
	_hx_class_name = "haxe.crypto.Md5"
	_hx_methods = ["bitOR", "bitXOR", "bitAND", "addme", "hex", "rol", "cmn", "ff", "gg", "hh", "ii", "doEncode"]
	_hx_statics = ["encode", "str2blks"]

	def __init__(self):
		pass

	def bitOR(self,a,b):
		lsb = ((a & 1) | ((b & 1)))
		msb31 = (HxOverrides.rshift(a, 1) | (HxOverrides.rshift(b, 1)))
		return ((msb31 << 1) | lsb)

	def bitXOR(self,a,b):
		lsb = ((a & 1) ^ ((b & 1)))
		msb31 = (HxOverrides.rshift(a, 1) ^ (HxOverrides.rshift(b, 1)))
		return ((msb31 << 1) | lsb)

	def bitAND(self,a,b):
		lsb = ((a & 1) & ((b & 1)))
		msb31 = (HxOverrides.rshift(a, 1) & (HxOverrides.rshift(b, 1)))
		return ((msb31 << 1) | lsb)

	def addme(self,x,y):
		lsw = (((x & 65535)) + ((y & 65535)))
		msw = ((((x >> 16)) + ((y >> 16))) + ((lsw >> 16)))
		return ((msw << 16) | ((lsw & 65535)))

	def hex(self,a):
		_hx_str = ""
		hex_chr = "0123456789abcdef"
		_g = 0
		while (_g < len(a)):
			num = (a[_g] if _g >= 0 and _g < len(a) else None)
			_g = (_g + 1)
			_g1 = 0
			while (_g1 < 4):
				j = _g1
				_g1 = (_g1 + 1)
				def _hx_local_1():
					index = ((num >> (((j * 8) + 4))) & 15)
					return ("" if (((index < 0) or ((index >= len(hex_chr))))) else hex_chr[index])
				def _hx_local_2():
					index1 = ((num >> ((j * 8))) & 15)
					return ("" if (((index1 < 0) or ((index1 >= len(hex_chr))))) else hex_chr[index1])
				_hx_str = (("null" if _hx_str is None else _hx_str) + HxOverrides.stringOrNull(((HxOverrides.stringOrNull(_hx_local_1()) + HxOverrides.stringOrNull(_hx_local_2())))))
		return _hx_str

	def rol(self,num,cnt):
		return ((num << cnt) | (HxOverrides.rshift(num, ((32 - cnt)))))

	def cmn(self,q,a,b,x,s,t):
		return self.addme(self.rol(self.addme(self.addme(a,q),self.addme(x,t)),s),b)

	def ff(self,a,b,c,d,x,s,t):
		return self.cmn(self.bitOR(self.bitAND(b,c),self.bitAND(~b,d)),a,b,x,s,t)

	def gg(self,a,b,c,d,x,s,t):
		return self.cmn(self.bitOR(self.bitAND(b,d),self.bitAND(c,~d)),a,b,x,s,t)

	def hh(self,a,b,c,d,x,s,t):
		return self.cmn(self.bitXOR(self.bitXOR(b,c),d),a,b,x,s,t)

	def ii(self,a,b,c,d,x,s,t):
		return self.cmn(self.bitXOR(c,self.bitOR(b,~d)),a,b,x,s,t)

	def doEncode(self,x):
		a = 1732584193
		b = -271733879
		c = -1732584194
		d = 271733878
		step = None
		i = 0
		while (i < len(x)):
			olda = a
			oldb = b
			oldc = c
			oldd = d
			step = 0
			a = self.ff(a,b,c,d,(x[i] if i >= 0 and i < len(x) else None),7,-680876936)
			d = self.ff(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 1)),12,-389564586)
			c = self.ff(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 2)),17,606105819)
			b = self.ff(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 3)),22,-1044525330)
			a = self.ff(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 4)),7,-176418897)
			d = self.ff(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 5)),12,1200080426)
			c = self.ff(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 6)),17,-1473231341)
			b = self.ff(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 7)),22,-45705983)
			a = self.ff(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 8)),7,1770035416)
			d = self.ff(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 9)),12,-1958414417)
			c = self.ff(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 10)),17,-42063)
			b = self.ff(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 11)),22,-1990404162)
			a = self.ff(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 12)),7,1804603682)
			d = self.ff(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 13)),12,-40341101)
			c = self.ff(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 14)),17,-1502002290)
			b = self.ff(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 15)),22,1236535329)
			a = self.gg(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 1)),5,-165796510)
			d = self.gg(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 6)),9,-1069501632)
			c = self.gg(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 11)),14,643717713)
			b = self.gg(b,c,d,a,(x[i] if i >= 0 and i < len(x) else None),20,-373897302)
			a = self.gg(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 5)),5,-701558691)
			d = self.gg(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 10)),9,38016083)
			c = self.gg(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 15)),14,-660478335)
			b = self.gg(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 4)),20,-405537848)
			a = self.gg(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 9)),5,568446438)
			d = self.gg(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 14)),9,-1019803690)
			c = self.gg(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 3)),14,-187363961)
			b = self.gg(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 8)),20,1163531501)
			a = self.gg(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 13)),5,-1444681467)
			d = self.gg(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 2)),9,-51403784)
			c = self.gg(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 7)),14,1735328473)
			b = self.gg(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 12)),20,-1926607734)
			a = self.hh(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 5)),4,-378558)
			d = self.hh(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 8)),11,-2022574463)
			c = self.hh(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 11)),16,1839030562)
			b = self.hh(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 14)),23,-35309556)
			a = self.hh(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 1)),4,-1530992060)
			d = self.hh(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 4)),11,1272893353)
			c = self.hh(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 7)),16,-155497632)
			b = self.hh(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 10)),23,-1094730640)
			a = self.hh(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 13)),4,681279174)
			d = self.hh(d,a,b,c,(x[i] if i >= 0 and i < len(x) else None),11,-358537222)
			c = self.hh(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 3)),16,-722521979)
			b = self.hh(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 6)),23,76029189)
			a = self.hh(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 9)),4,-640364487)
			d = self.hh(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 12)),11,-421815835)
			c = self.hh(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 15)),16,530742520)
			b = self.hh(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 2)),23,-995338651)
			a = self.ii(a,b,c,d,(x[i] if i >= 0 and i < len(x) else None),6,-198630844)
			d = self.ii(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 7)),10,1126891415)
			c = self.ii(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 14)),15,-1416354905)
			b = self.ii(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 5)),21,-57434055)
			a = self.ii(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 12)),6,1700485571)
			d = self.ii(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 3)),10,-1894986606)
			c = self.ii(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 10)),15,-1051523)
			b = self.ii(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 1)),21,-2054922799)
			a = self.ii(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 8)),6,1873313359)
			d = self.ii(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 15)),10,-30611744)
			c = self.ii(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 6)),15,-1560198380)
			b = self.ii(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 13)),21,1309151649)
			a = self.ii(a,b,c,d,python_internal_ArrayImpl._get(x, (i + 4)),6,-145523070)
			d = self.ii(d,a,b,c,python_internal_ArrayImpl._get(x, (i + 11)),10,-1120210379)
			c = self.ii(c,d,a,b,python_internal_ArrayImpl._get(x, (i + 2)),15,718787259)
			b = self.ii(b,c,d,a,python_internal_ArrayImpl._get(x, (i + 9)),21,-343485551)
			a = self.addme(a,olda)
			b = self.addme(b,oldb)
			c = self.addme(c,oldc)
			d = self.addme(d,oldd)
			i = (i + 16)
		return [a, b, c, d]

	@staticmethod
	def encode(s):
		m = haxe_crypto_Md5()
		h = m.doEncode(haxe_crypto_Md5.str2blks(s))
		return m.hex(h)

	@staticmethod
	def str2blks(_hx_str):
		nblk = ((((len(_hx_str) + 8) >> 6)) + 1)
		blks = list()
		blksSize = (nblk * 16)
		_g = 0
		while (_g < blksSize):
			i = _g
			_g = (_g + 1)
			python_internal_ArrayImpl._set(blks, i, 0)
		i1 = 0
		while (i1 < len(_hx_str)):
			_hx_local_0 = blks
			_hx_local_1 = (i1 >> 2)
			_hx_local_2 = (_hx_local_0[_hx_local_1] if _hx_local_1 >= 0 and _hx_local_1 < len(_hx_local_0) else None)
			python_internal_ArrayImpl._set(_hx_local_0, _hx_local_1, (_hx_local_2 | ((HxString.charCodeAt(_hx_str,i1) << ((HxOverrides.mod((((len(_hx_str) * 8) + i1)), 4) * 8))))))
			(_hx_local_0[_hx_local_1] if _hx_local_1 >= 0 and _hx_local_1 < len(_hx_local_0) else None)
			i1 = (i1 + 1)
		_hx_local_4 = blks
		_hx_local_5 = (i1 >> 2)
		_hx_local_6 = (_hx_local_4[_hx_local_5] if _hx_local_5 >= 0 and _hx_local_5 < len(_hx_local_4) else None)
		python_internal_ArrayImpl._set(_hx_local_4, _hx_local_5, (_hx_local_6 | ((128 << ((HxOverrides.mod((((len(_hx_str) * 8) + i1)), 4) * 8))))))
		(_hx_local_4[_hx_local_5] if _hx_local_5 >= 0 and _hx_local_5 < len(_hx_local_4) else None)
		l = (len(_hx_str) * 8)
		k = ((nblk * 16) - 2)
		python_internal_ArrayImpl._set(blks, k, (l & 255))
		python_internal_ArrayImpl._set(blks, k, ((blks[k] if k >= 0 and k < len(blks) else None) | ((((HxOverrides.rshift(l, 8) & 255)) << 8))))
		python_internal_ArrayImpl._set(blks, k, ((blks[k] if k >= 0 and k < len(blks) else None) | ((((HxOverrides.rshift(l, 16) & 255)) << 16))))
		python_internal_ArrayImpl._set(blks, k, ((blks[k] if k >= 0 and k < len(blks) else None) | ((((HxOverrides.rshift(l, 24) & 255)) << 24))))
		return blks

	@staticmethod
	def _hx_empty_init(_hx_o):		pass
haxe_crypto_Md5._hx_class = haxe_crypto_Md5
_hx_classes["haxe.crypto.Md5"] = haxe_crypto_Md5


class haxe_ds_IntMap:
	_hx_class_name = "haxe.ds.IntMap"
	_hx_fields = ["h"]
	_hx_methods = ["set", "get", "exists", "remove", "keys", "iterator"]
	_hx_interfaces = [haxe_IMap]

	def __init__(self):
		self.h = None
		self.h = dict()

	def set(self,key,value):
		self.h[key] = value

	def get(self,key):
		return self.h.get(key,None)

	def exists(self,key):
		return key in self.h

	def remove(self,key):
		if (not key in self.h):
			return False
		del self.h[key]
		return True

	def keys(self):
		this1 = None
		_this = list(self.h.keys())
		this1 = iter(_this)
		return python_HaxeIterator(this1)

	def iterator(self):
		this1 = None
		_this = self.h.values()
		this1 = iter(_this)
		return python_HaxeIterator(this1)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.h = None
haxe_ds_IntMap._hx_class = haxe_ds_IntMap
_hx_classes["haxe.ds.IntMap"] = haxe_ds_IntMap


class haxe_ds_ObjectMap:
	_hx_class_name = "haxe.ds.ObjectMap"
	_hx_fields = ["h"]
	_hx_methods = ["set", "get", "exists", "remove", "keys", "iterator"]
	_hx_interfaces = [haxe_IMap]

	def __init__(self):
		self.h = None
		self.h = dict()

	def set(self,key,value):
		self.h[key] = value

	def get(self,key):
		return self.h.get(key,None)

	def exists(self,key):
		return key in self.h

	def remove(self,key):
		r = key in self.h
		if r:
			del self.h[key]
		return r

	def keys(self):
		this1 = None
		_this = list(self.h.keys())
		this1 = iter(_this)
		return python_HaxeIterator(this1)

	def iterator(self):
		this1 = None
		_this = self.h.values()
		this1 = iter(_this)
		return python_HaxeIterator(this1)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.h = None
haxe_ds_ObjectMap._hx_class = haxe_ds_ObjectMap
_hx_classes["haxe.ds.ObjectMap"] = haxe_ds_ObjectMap


class haxe_io_Bytes:
	_hx_class_name = "haxe.io.Bytes"
	_hx_fields = ["length", "b"]
	_hx_statics = ["alloc"]

	def __init__(self,length,b):
		self.length = None
		self.b = None
		self.length = length
		self.b = b

	@staticmethod
	def alloc(length):
		return haxe_io_Bytes(length, bytearray(length))

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.length = None
		_hx_o.b = None
haxe_io_Bytes._hx_class = haxe_io_Bytes
_hx_classes["haxe.io.Bytes"] = haxe_io_Bytes


class haxe_io_Eof:
	_hx_class_name = "haxe.io.Eof"
	_hx_methods = ["toString"]

	def toString(self):
		return "Eof"

	@staticmethod
	def _hx_empty_init(_hx_o):		pass
haxe_io_Eof._hx_class = haxe_io_Eof
_hx_classes["haxe.io.Eof"] = haxe_io_Eof


class python_Boot:
	_hx_class_name = "python.Boot"
	_hx_statics = ["keywords", "toString1", "fields", "simpleField", "field", "getInstanceFields", "getSuperClass", "getClassFields", "prefixLength", "unhandleKeywords"]

	@staticmethod
	def toString1(o,s):
		if (o is None):
			return "null"
		if isinstance(o,str):
			return o
		if (s is None):
			s = ""
		if (len(s) >= 5):
			return "<...>"
		if isinstance(o,bool):
			if o:
				return "true"
			else:
				return "false"
		if isinstance(o,int):
			return str(o)
		if isinstance(o,float):
			try:
				if (o == int(o)):
					def _hx_local_1():
						def _hx_local_0():
							v = o
							return Math.floor((v + 0.5))
						return str(_hx_local_0())
					return _hx_local_1()
				else:
					return str(o)
			except Exception as _hx_e:
				_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
				e = _hx_e1
				return str(o)
		if isinstance(o,list):
			o1 = o
			l = len(o1)
			st = "["
			s = (("null" if s is None else s) + "\t")
			_g = 0
			while (_g < l):
				i = _g
				_g = (_g + 1)
				prefix = ""
				if (i > 0):
					prefix = ","
				st = (("null" if st is None else st) + HxOverrides.stringOrNull(((("null" if prefix is None else prefix) + HxOverrides.stringOrNull(python_Boot.toString1((o1[i] if i >= 0 and i < len(o1) else None),s))))))
			st = (("null" if st is None else st) + "]")
			return st
		try:
			if hasattr(o,"toString"):
				return o.toString()
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			pass
		if (python_lib_Inspect.isfunction(o) or python_lib_Inspect.ismethod(o)):
			return "<function>"
		if hasattr(o,"__class__"):
			if isinstance(o,_hx_AnonObject):
				toStr = None
				try:
					fields = python_Boot.fields(o)
					fieldsStr = None
					_g1 = []
					_g11 = 0
					while (_g11 < len(fields)):
						f = (fields[_g11] if _g11 >= 0 and _g11 < len(fields) else None)
						_g11 = (_g11 + 1)
						x = ((("" + ("null" if f is None else f)) + " : ") + HxOverrides.stringOrNull(python_Boot.toString1(python_Boot.simpleField(o,f),(("null" if s is None else s) + "\t"))))
						_g1.append(x)
					fieldsStr = _g1
					toStr = (("{ " + HxOverrides.stringOrNull(", ".join([x1 for x1 in fieldsStr]))) + " }")
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e2 = _hx_e1
					return "{ ... }"
				if (toStr is None):
					return "{ ... }"
				else:
					return toStr
			if isinstance(o,Enum):
				o2 = o
				l1 = len(o2.params)
				hasParams = (l1 > 0)
				if hasParams:
					paramsStr = ""
					_g2 = 0
					while (_g2 < l1):
						i1 = _g2
						_g2 = (_g2 + 1)
						prefix1 = ""
						if (i1 > 0):
							prefix1 = ","
						paramsStr = (("null" if paramsStr is None else paramsStr) + HxOverrides.stringOrNull(((("null" if prefix1 is None else prefix1) + HxOverrides.stringOrNull(python_Boot.toString1((o2.params[i1] if i1 >= 0 and i1 < len(o2.params) else None),s))))))
					return (((HxOverrides.stringOrNull(o2.tag) + "(") + ("null" if paramsStr is None else paramsStr)) + ")")
				else:
					return o2.tag
			if hasattr(o,"_hx_class_name"):
				if (o.__class__.__name__ != "type"):
					fields1 = python_Boot.getInstanceFields(o)
					fieldsStr1 = None
					_g3 = []
					_g12 = 0
					while (_g12 < len(fields1)):
						f1 = (fields1[_g12] if _g12 >= 0 and _g12 < len(fields1) else None)
						_g12 = (_g12 + 1)
						x1 = ((("" + ("null" if f1 is None else f1)) + " : ") + HxOverrides.stringOrNull(python_Boot.toString1(python_Boot.simpleField(o,f1),(("null" if s is None else s) + "\t"))))
						_g3.append(x1)
					fieldsStr1 = _g3
					toStr1 = (((HxOverrides.stringOrNull(o._hx_class_name) + "( ") + HxOverrides.stringOrNull(", ".join([x1 for x1 in fieldsStr1]))) + " )")
					return toStr1
				else:
					fields2 = python_Boot.getClassFields(o)
					fieldsStr2 = None
					_g4 = []
					_g13 = 0
					while (_g13 < len(fields2)):
						f2 = (fields2[_g13] if _g13 >= 0 and _g13 < len(fields2) else None)
						_g13 = (_g13 + 1)
						x2 = ((("" + ("null" if f2 is None else f2)) + " : ") + HxOverrides.stringOrNull(python_Boot.toString1(python_Boot.simpleField(o,f2),(("null" if s is None else s) + "\t"))))
						_g4.append(x2)
					fieldsStr2 = _g4
					toStr2 = (((("#" + HxOverrides.stringOrNull(o._hx_class_name)) + "( ") + HxOverrides.stringOrNull(", ".join([x1 for x1 in fieldsStr2]))) + " )")
					return toStr2
			if (o == str):
				return "#String"
			if (o == list):
				return "#Array"
			if callable(o):
				return "function"
			try:
				if hasattr(o,"__repr__"):
					return o.__repr__()
			except Exception as _hx_e:
				_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
				pass
			if hasattr(o,"__str__"):
				return o.__str__([])
			if hasattr(o,"__name__"):
				return o.__name__
			return "???"
		else:
			return str(o)

	@staticmethod
	def fields(o):
		a = []
		if (o is not None):
			if hasattr(o,"_hx_fields"):
				fields = o._hx_fields
				return list(fields)
			if isinstance(o,_hx_AnonObject):
				d = o.__dict__
				keys = d.keys()
				handler = python_Boot.unhandleKeywords
				for k in keys:
					a.append(handler(k))
			elif hasattr(o,"__dict__"):
				a1 = []
				d1 = o.__dict__
				keys1 = d1.keys()
				for k in keys1:
					a.append(k)
		return a

	@staticmethod
	def simpleField(o,field):
		if (field is None):
			return None
		field1 = None
		if field in python_Boot.keywords:
			field1 = ("_hx_" + field)
		elif ((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95))):
			field1 = ("_hx_" + field)
		else:
			field1 = field
		if hasattr(o,field1):
			return getattr(o,field1)
		else:
			return None

	@staticmethod
	def field(o,field):
		if (field is None):
			return None
		_hx_local_0 = len(field)
		if (_hx_local_0 == 10):
			if (field == "charCodeAt"):
				if isinstance(o,str):
					s4 = o
					def _hx_local_1(a11):
						return HxString.charCodeAt(s4,a11)
					return _hx_local_1
		elif (_hx_local_0 == 11):
			if (field == "toLowerCase"):
				if isinstance(o,str):
					s1 = o
					def _hx_local_2():
						return HxString.toLowerCase(s1)
					return _hx_local_2
			elif (field == "toUpperCase"):
				if isinstance(o,str):
					s2 = o
					def _hx_local_3():
						return HxString.toUpperCase(s2)
					return _hx_local_3
			elif (field == "lastIndexOf"):
				if isinstance(o,str):
					s6 = o
					def _hx_local_4(a13):
						return HxString.lastIndexOf(s6,a13)
					return _hx_local_4
				elif isinstance(o,list):
					a2 = o
					def _hx_local_5(x2):
						return python_internal_ArrayImpl.lastIndexOf(a2,x2)
					return _hx_local_5
		elif (_hx_local_0 == 9):
			if (field == "substring"):
				if isinstance(o,str):
					s9 = o
					def _hx_local_6(a15):
						return HxString.substring(s9,a15)
					return _hx_local_6
		elif (_hx_local_0 == 5):
			if (field == "split"):
				if isinstance(o,str):
					s7 = o
					def _hx_local_7(d):
						return HxString.split(s7,d)
					return _hx_local_7
			elif (field == "shift"):
				if isinstance(o,list):
					x14 = o
					def _hx_local_8():
						return python_internal_ArrayImpl.shift(x14)
					return _hx_local_8
			elif (field == "slice"):
				if isinstance(o,list):
					x15 = o
					def _hx_local_9(a18):
						return python_internal_ArrayImpl.slice(x15,a18)
					return _hx_local_9
		elif (_hx_local_0 == 4):
			if (field == "copy"):
				if isinstance(o,list):
					def _hx_local_10():
						x6 = o
						return list(x6)
					return _hx_local_10
			elif (field == "join"):
				if isinstance(o,list):
					def _hx_local_11(sep):
						x9 = o
						return sep.join([python_Boot.toString1(x1,'') for x1 in x9])
					return _hx_local_11
			elif (field == "push"):
				if isinstance(o,list):
					x11 = o
					def _hx_local_12(e):
						return python_internal_ArrayImpl.push(x11,e)
					return _hx_local_12
			elif (field == "sort"):
				if isinstance(o,list):
					x16 = o
					def _hx_local_13(f2):
						python_internal_ArrayImpl.sort(x16,f2)
					return _hx_local_13
		elif (_hx_local_0 == 7):
			if (field == "indexOf"):
				if isinstance(o,str):
					s5 = o
					def _hx_local_14(a12):
						return HxString.indexOf(s5,a12)
					return _hx_local_14
				elif isinstance(o,list):
					a = o
					def _hx_local_15(x1):
						return python_internal_ArrayImpl.indexOf(a,x1)
					return _hx_local_15
			elif (field == "unshift"):
				if isinstance(o,list):
					x12 = o
					def _hx_local_16(e1):
						python_internal_ArrayImpl.unshift(x12,e1)
					return _hx_local_16
			elif (field == "reverse"):
				if isinstance(o,list):
					a4 = o
					def _hx_local_17():
						python_internal_ArrayImpl.reverse(a4)
					return _hx_local_17
		elif (_hx_local_0 == 3):
			if (field == "map"):
				if isinstance(o,list):
					x4 = o
					def _hx_local_18(f):
						return python_internal_ArrayImpl.map(x4,f)
					return _hx_local_18
			elif (field == "pop"):
				if isinstance(o,list):
					x10 = o
					def _hx_local_19():
						return python_internal_ArrayImpl.pop(x10)
					return _hx_local_19
		elif (_hx_local_0 == 8):
			if (field == "toString"):
				if isinstance(o,str):
					s10 = o
					def _hx_local_20():
						return HxString.toString(s10)
					return _hx_local_20
				elif isinstance(o,list):
					x3 = o
					def _hx_local_21():
						return python_internal_ArrayImpl.toString(x3)
					return _hx_local_21
			elif (field == "iterator"):
				if isinstance(o,list):
					x7 = o
					def _hx_local_22():
						return python_internal_ArrayImpl.iterator(x7)
					return _hx_local_22
		elif (_hx_local_0 == 6):
			if (field == "length"):
				if isinstance(o,str):
					s = o
					return len(s)
				elif isinstance(o,list):
					x = o
					return len(x)
			elif (field == "charAt"):
				if isinstance(o,str):
					s3 = o
					def _hx_local_23(a1):
						return HxString.charAt(s3,a1)
					return _hx_local_23
			elif (field == "substr"):
				if isinstance(o,str):
					s8 = o
					def _hx_local_24(a14):
						return HxString.substr(s8,a14)
					return _hx_local_24
			elif (field == "filter"):
				if isinstance(o,list):
					x5 = o
					def _hx_local_25(f1):
						return python_internal_ArrayImpl.filter(x5,f1)
					return _hx_local_25
			elif (field == "concat"):
				if isinstance(o,list):
					a16 = o
					def _hx_local_26(a21):
						return python_internal_ArrayImpl.concat(a16,a21)
					return _hx_local_26
			elif (field == "insert"):
				if isinstance(o,list):
					a3 = o
					def _hx_local_27(a17,x8):
						python_internal_ArrayImpl.insert(a3,a17,x8)
					return _hx_local_27
			elif (field == "remove"):
				if isinstance(o,list):
					x13 = o
					def _hx_local_28(e2):
						return python_internal_ArrayImpl.remove(x13,e2)
					return _hx_local_28
			elif (field == "splice"):
				if isinstance(o,list):
					x17 = o
					def _hx_local_29(a19,a22):
						return python_internal_ArrayImpl.splice(x17,a19,a22)
					return _hx_local_29
		else:
			pass
		field1 = None
		if field in python_Boot.keywords:
			field1 = ("_hx_" + field)
		elif ((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95))):
			field1 = ("_hx_" + field)
		else:
			field1 = field
		if hasattr(o,field1):
			return getattr(o,field1)
		else:
			return None

	@staticmethod
	def getInstanceFields(c):
		f = None
		if hasattr(c,"_hx_fields"):
			f = c._hx_fields
		else:
			f = []
		if hasattr(c,"_hx_methods"):
			a = c._hx_methods
			f = (f + a)
		sc = python_Boot.getSuperClass(c)
		if (sc is None):
			return f
		else:
			scArr = python_Boot.getInstanceFields(sc)
			scMap = set(scArr)
			res = []
			_g = 0
			while (_g < len(f)):
				f1 = (f[_g] if _g >= 0 and _g < len(f) else None)
				_g = (_g + 1)
				if (not f1 in scMap):
					scArr.append(f1)
			return scArr

	@staticmethod
	def getSuperClass(c):
		if (c is None):
			return None
		try:
			if hasattr(c,"_hx_super"):
				return c._hx_super
			return None
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			pass
		return None

	@staticmethod
	def getClassFields(c):
		if hasattr(c,"_hx_statics"):
			x = c._hx_statics
			return list(x)
		else:
			return []

	@staticmethod
	def unhandleKeywords(name):
		if (HxString.substr(name,0,python_Boot.prefixLength) == "_hx_"):
			real = HxString.substr(name,python_Boot.prefixLength,None)
			if real in python_Boot.keywords:
				return real
		return name
python_Boot._hx_class = python_Boot
_hx_classes["python.Boot"] = python_Boot


class python_internal_ArrayImpl:
	_hx_class_name = "python.internal.ArrayImpl"
	_hx_statics = ["get_length", "concat", "iterator", "indexOf", "lastIndexOf", "toString", "pop", "push", "unshift", "remove", "shift", "slice", "sort", "splice", "map", "filter", "insert", "reverse", "_get", "_set"]

	@staticmethod
	def get_length(x):
		return len(x)

	@staticmethod
	def concat(a1,a2):
		return (a1 + a2)

	@staticmethod
	def iterator(x):
		return python_HaxeIterator(x.__iter__())

	@staticmethod
	def indexOf(a,x,fromIndex = None):
		_hx_len = len(a)
		l = None
		if (fromIndex is None):
			l = 0
		elif (fromIndex < 0):
			l = (_hx_len + fromIndex)
		else:
			l = fromIndex
		if (l < 0):
			l = 0
		_g = l
		while (_g < _hx_len):
			i = _g
			_g = (_g + 1)
			if (a[i] == x):
				return i
		return -1

	@staticmethod
	def lastIndexOf(a,x,fromIndex = None):
		_hx_len = len(a)
		l = None
		if (fromIndex is None):
			l = _hx_len
		elif (fromIndex < 0):
			l = ((_hx_len + fromIndex) + 1)
		else:
			l = (fromIndex + 1)
		if (l > _hx_len):
			l = _hx_len
		def _hx_local_1():
			nonlocal l
			l = (l - 1)
			return l
		while (_hx_local_1() > -1):
			if (a[l] == x):
				return l
		return -1

	@staticmethod
	def toString(x):
		return (("[" + HxOverrides.stringOrNull(",".join([python_Boot.toString1(x1,'') for x1 in x]))) + "]")

	@staticmethod
	def pop(x):
		if (len(x) == 0):
			return None
		else:
			return x.pop()

	@staticmethod
	def push(x,e):
		x.append(e)
		return len(x)

	@staticmethod
	def unshift(x,e):
		x.insert(0, e)

	@staticmethod
	def remove(x,e):
		try:
			x.remove(e)
			return True
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			e1 = _hx_e1
			return False

	@staticmethod
	def shift(x):
		if (len(x) == 0):
			return None
		return x.pop(0)

	@staticmethod
	def slice(x,pos,end = None):
		return x[pos:end]

	@staticmethod
	def sort(x,f):
		x.sort(key= python_lib_Functools.cmp_to_key(f))

	@staticmethod
	def splice(x,pos,_hx_len):
		if (pos < 0):
			pos = (len(x) + pos)
		if (pos < 0):
			pos = 0
		res = x[pos:(pos + _hx_len)]
		del x[pos:(pos + _hx_len)]
		return res

	@staticmethod
	def map(x,f):
		return list(map(f,x))

	@staticmethod
	def filter(x,f):
		return list(filter(f,x))

	@staticmethod
	def insert(a,pos,x):
		a.insert(pos, x)

	@staticmethod
	def reverse(a):
		a.reverse()

	@staticmethod
	def _get(x,idx):
		if ((idx > -1) and ((idx < len(x)))):
			return x[idx]
		else:
			return None

	@staticmethod
	def _set(x,idx,v):
		l = len(x)
		while (l < idx):
			x.append(None)
			l = (l + 1)
		if (l == idx):
			x.append(v)
		else:
			x[idx] = v
		return v
python_internal_ArrayImpl._hx_class = python_internal_ArrayImpl
_hx_classes["python.internal.ArrayImpl"] = python_internal_ArrayImpl


class _HxException(Exception):
	_hx_class_name = "_HxException"
	_hx_fields = ["val"]
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = Exception


	def __init__(self,val):
		self.val = None
		message = str(val)
		super().__init__(message)
		self.val = val

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.val = None
_HxException._hx_class = _HxException
_hx_classes["_HxException"] = _HxException


class HxOverrides:
	_hx_class_name = "HxOverrides"
	_hx_statics = ["iterator", "eq", "stringOrNull", "toUpperCase", "toLowerCase", "rshift", "modf", "mod", "arrayGet"]

	@staticmethod
	def iterator(x):
		if isinstance(x,list):
			return python_HaxeIterator(x.__iter__())
		return x.iterator()

	@staticmethod
	def eq(a,b):
		if (isinstance(a,list) or isinstance(b,list)):
			return a is b
		return (a == b)

	@staticmethod
	def stringOrNull(s):
		if (s is None):
			return "null"
		else:
			return s

	@staticmethod
	def toUpperCase(x):
		if isinstance(x,str):
			return x.upper()
		return x.toUpperCase()

	@staticmethod
	def toLowerCase(x):
		if isinstance(x,str):
			return x.lower()
		return x.toLowerCase()

	@staticmethod
	def rshift(val,n):
		return ((val % 0x100000000) >> n)

	@staticmethod
	def modf(a,b):
		return float('nan') if (b == 0.0) else a % b if a >= 0 else -(-a % b)

	@staticmethod
	def mod(a,b):
		return a % b if a >= 0 else -(-a % b)

	@staticmethod
	def arrayGet(a,i):
		if isinstance(a,list):
			x = a
			if ((i > -1) and ((i < len(x)))):
				return x[i]
			else:
				return None
		else:
			return a[i]
HxOverrides._hx_class = HxOverrides
_hx_classes["HxOverrides"] = HxOverrides


class HxString:
	_hx_class_name = "HxString"
	_hx_statics = ["split", "charCodeAt", "charAt", "lastIndexOf", "toUpperCase", "toLowerCase", "indexOf", "toString", "get_length", "substring", "substr"]

	@staticmethod
	def split(s,d):
		if (d == ""):
			return list(s)
		else:
			return s.split(d)

	@staticmethod
	def charCodeAt(s,index):
		if ((((s is None) or ((len(s) == 0))) or ((index < 0))) or ((index >= len(s)))):
			return None
		else:
			return ord(s[index])

	@staticmethod
	def charAt(s,index):
		if ((index < 0) or ((index >= len(s)))):
			return ""
		else:
			return s[index]

	@staticmethod
	def lastIndexOf(s,_hx_str,startIndex = None):
		if (startIndex is None):
			return s.rfind(_hx_str, 0, len(s))
		else:
			i = s.rfind(_hx_str, 0, (startIndex + 1))
			startLeft = None
			if (i == -1):
				startLeft = max(0,((startIndex + 1) - len(_hx_str)))
			else:
				startLeft = (i + 1)
			check = s.find(_hx_str, startLeft, len(s))
			if ((check > i) and ((check <= startIndex))):
				return check
			else:
				return i

	@staticmethod
	def toUpperCase(s):
		return s.upper()

	@staticmethod
	def toLowerCase(s):
		return s.lower()

	@staticmethod
	def indexOf(s,_hx_str,startIndex = None):
		if (startIndex is None):
			return s.find(_hx_str)
		else:
			return s.find(_hx_str, startIndex)

	@staticmethod
	def toString(s):
		return s

	@staticmethod
	def get_length(s):
		return len(s)

	@staticmethod
	def substring(s,startIndex,endIndex = None):
		if (startIndex < 0):
			startIndex = 0
		if (endIndex is None):
			return s[startIndex:]
		else:
			if (endIndex < 0):
				endIndex = 0
			if (endIndex < startIndex):
				return s[endIndex:startIndex]
			else:
				return s[startIndex:endIndex]

	@staticmethod
	def substr(s,startIndex,_hx_len = None):
		if (_hx_len is None):
			return s[startIndex:]
		else:
			if (_hx_len == 0):
				return ""
			return s[startIndex:(startIndex + _hx_len)]
HxString._hx_class = HxString
_hx_classes["HxString"] = HxString


class saturn_app_PythonExport:
	_hx_class_name = "saturn.app.PythonExport"
	_hx_statics = ["main"]

	@staticmethod
	def main():
		a = saturn_core_DNA("")
		b = saturn_core_Protein("")
		python_Boot.fields(a)
		a1 = saturn_db_provider_GenericRDBMSProvider(None, None, False)
saturn_app_PythonExport._hx_class = saturn_app_PythonExport
_hx_classes["saturn.app.PythonExport"] = saturn_app_PythonExport


class saturn_client_core_CommonCore:
	_hx_class_name = "saturn.client.core.CommonCore"
	_hx_statics = ["DEFAULT_POOL_NAME", "pools", "resourceToPool", "providers", "combinedModels", "setDefaultProvider", "closeProviders", "getStringError", "getCombinedModels", "getProviderNameForModel", "getProviderForNamedQuery", "getDefaultProvider", "getProviderNames", "getFileExtension", "getFileAsText", "getFileInChunks", "setPool", "getPool", "getResource", "releaseResource", "makeFullyQualified", "getContent", "getDefaultProviderName"]
	DEFAULT_POOL_NAME = None

	@staticmethod
	def setDefaultProvider(provider,name = "DEFAULT",defaultProvider = None):
		if (name is None):
			name = "DEFAULT"
		saturn_client_core_CommonCore.providers.h[name] = provider
		if defaultProvider:
			saturn_client_core_CommonCore.DEFAULT_POOL_NAME = name

	@staticmethod
	def closeProviders():
		_hx_local_0 = saturn_client_core_CommonCore.providers.keys()
		while _hx_local_0.hasNext():
			name = _hx_local_0.next()
			saturn_client_core_CommonCore.providers.h.get(name,None)._closeConnection()

	@staticmethod
	def getStringError(error):
		return error

	@staticmethod
	def getCombinedModels():
		if (saturn_client_core_CommonCore.combinedModels is None):
			saturn_client_core_CommonCore.combinedModels = haxe_ds_StringMap()
			_g = 0
			_g1 = saturn_client_core_CommonCore.getProviderNames()
			while (_g < len(_g1)):
				name = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
				_g = (_g + 1)
				models = Reflect.field(saturn_client_core_CommonCore.getDefaultProvider(None,name),"getModels")()
				_hx_local_1 = models.keys()
				while _hx_local_1.hasNext():
					key = _hx_local_1.next()
					value = models.h.get(key,None)
					saturn_client_core_CommonCore.combinedModels.h[key] = value
		return saturn_client_core_CommonCore.combinedModels

	@staticmethod
	def getProviderNameForModel(name):
		models = saturn_client_core_CommonCore.getCombinedModels()
		if name in models.h:
			if Reflect.field(models.h.get(name,None),"exists")("provider_name"):
				return Reflect.field(models.h.get(name,None),"get")("provider_name")
			else:
				return None
		else:
			return None

	@staticmethod
	def getProviderForNamedQuery(name):
		_hx_local_1 = saturn_client_core_CommonCore.providers.keys()
		while _hx_local_1.hasNext():
			providerName = _hx_local_1.next()
			provider = saturn_client_core_CommonCore.providers.h.get(providerName,None)
			config = provider.getConfig()
			if hasattr(config,(("_hx_" + "named_queries") if ("named_queries" in python_Boot.keywords) else (("_hx_" + "named_queries") if (((((len("named_queries") > 2) and ((ord("named_queries"[0]) == 95))) and ((ord("named_queries"[1]) == 95))) and ((ord("named_queries"[(len("named_queries") - 1)]) != 95)))) else "named_queries"))):
				def _hx_local_0():
					o = Reflect.field(config,"named_queries")
					return hasattr(o,(("_hx_" + name) if (name in python_Boot.keywords) else (("_hx_" + name) if (((((len(name) > 2) and ((ord(name[0]) == 95))) and ((ord(name[1]) == 95))) and ((ord(name[(len(name) - 1)]) != 95)))) else name)))
				if _hx_local_0():
					return providerName
		return None

	@staticmethod
	def getDefaultProvider(cb = None,name = None):
		if (name is None):
			name = saturn_client_core_CommonCore.getDefaultProviderName()
		if name in saturn_client_core_CommonCore.providers.h:
			if (cb is not None):
				cb(None,saturn_client_core_CommonCore.providers.h.get(name,None))
			return saturn_client_core_CommonCore.providers.h.get(name,None)
		elif (name is not None):
			saturn_client_core_CommonCore.getResource(name,cb)
			return -1
		return None

	@staticmethod
	def getProviderNames():
		names = list()
		_hx_local_0 = saturn_client_core_CommonCore.providers.keys()
		while _hx_local_0.hasNext():
			name = _hx_local_0.next()
			names.append(name)
		_hx_local_1 = saturn_client_core_CommonCore.pools.keys()
		while _hx_local_1.hasNext():
			name1 = _hx_local_1.next()
			names.append(name1)
		return names

	@staticmethod
	def getFileExtension(fileName):
		r = EReg("\\.(\\w+)", "")
		r.matchObj = python_lib_Re.search(r.pattern,fileName)
		(r.matchObj is not None)
		return r.matchObj.group(1)

	@staticmethod
	def getFileAsText(file,cb):
		if Std._hx_is(file,saturn_core_FileShim):
			cb(Reflect.field(file,"getAsText")())
		elif hasattr(file,(("_hx_" + "_data") if ("_data" in python_Boot.keywords) else (("_hx_" + "_data") if (((((len("_data") > 2) and ((ord("_data"[0]) == 95))) and ((ord("_data"[1]) == 95))) and ((ord("_data"[(len("_data") - 1)]) != 95)))) else "_data"))):
			cb(Reflect.field(file,"asText")())
		else:
			fileReader = __js__("new FileReader()")
			def _hx_local_0(e):
				cb(e.target.result)
			Reflect.setField(fileReader,"onload",_hx_local_0)
			Reflect.field(fileReader,"readAsText")(file)

	@staticmethod
	def getFileInChunks(file,chunkSize,cb):
		offset = 0
		fileSize = Reflect.field(file,"size")
		chunker = None
		def _hx_local_3():
			reader = __js__("new FileReader()")
			reader.readAsDataURL(Reflect.field(file,"slice")(offset,(offset + chunkSize)))
			def _hx_local_2(event):
				if (event.target.error is None):
					def _hx_local_1():
						nonlocal offset
						offset = (offset + chunkSize)
						if (offset >= fileSize):
							cb(None,None,None)
						else:
							chunker()
					cb(None,python_internal_ArrayImpl._get(reader.result.split(","), 1),_hx_local_1)
				else:
					cb(event.target.error,None,None)
			reader.onloadend = _hx_local_2
		chunker = _hx_local_3
		chunker()

	@staticmethod
	def setPool(poolName = "DEFAULT",pool = None,isDefault = None):
		if (poolName is None):
			poolName = "DEFAULT"
		saturn_client_core_CommonCore.pools.h[poolName] = pool
		if isDefault:
			saturn_client_core_CommonCore.DEFAULT_POOL_NAME = poolName

	@staticmethod
	def getPool(poolName = "DEFAULT"):
		if (poolName is None):
			poolName = "DEFAULT"
		if poolName in saturn_client_core_CommonCore.pools.h:
			return saturn_client_core_CommonCore.pools.h.get(poolName,None)
		else:
			return None

	@staticmethod
	def getResource(poolName = "DEFAULT",cb = None):
		if (poolName is None):
			poolName = "DEFAULT"
		pool = saturn_client_core_CommonCore.getPool(poolName)
		if (pool is not None):
			def _hx_local_0(err,resource):
				if (err is None):
					saturn_client_core_CommonCore.resourceToPool.set(resource,poolName)
				cb(err,resource)
			pool.acquire(_hx_local_0)
		else:
			cb("Invalid pool name",None)

	@staticmethod
	def releaseResource(resource):
		def _hx_local_0():
			key = resource
			return key in saturn_client_core_CommonCore.resourceToPool.h
		if _hx_local_0():
			poolName = None
			key1 = resource
			poolName = saturn_client_core_CommonCore.resourceToPool.h.get(key1,None)
			if poolName in saturn_client_core_CommonCore.pools.h:
				pool = saturn_client_core_CommonCore.pools.h.get(poolName,None)
				pool.release(resource)
				return -3
			else:
				return -2
		else:
			return -1

	@staticmethod
	def makeFullyQualified(path):
		return None

	@staticmethod
	def getContent(url,onSuccess,onFailure = None):
		def _hx_local_0(response,opts):
			onSuccess(response.responseText)
		def _hx_local_1(response1,opts1):
			onFailure(response1)
		Reflect.field(Ext.Ajax,"request")(_hx_AnonObject({'url': url, 'success': _hx_local_0, 'failure': _hx_local_1}))

	@staticmethod
	def getDefaultProviderName():
		return saturn_client_core_CommonCore.DEFAULT_POOL_NAME
saturn_client_core_CommonCore._hx_class = saturn_client_core_CommonCore
_hx_classes["saturn.client.core.CommonCore"] = saturn_client_core_CommonCore

class saturn_core_CutProductDirection(Enum):
	_hx_class_name = "saturn.core.CutProductDirection"
	_hx_constructs = ["UPSTREAM", "DOWNSTREAM", "UPDOWN"]
saturn_core_CutProductDirection.UPSTREAM = saturn_core_CutProductDirection("UPSTREAM", 0, list())
saturn_core_CutProductDirection.DOWNSTREAM = saturn_core_CutProductDirection("DOWNSTREAM", 1, list())
saturn_core_CutProductDirection.UPDOWN = saturn_core_CutProductDirection("UPDOWN", 2, list())
saturn_core_CutProductDirection._hx_class = saturn_core_CutProductDirection
_hx_classes["saturn.core.CutProductDirection"] = saturn_core_CutProductDirection


class saturn_core_molecule_Molecule:
	_hx_class_name = "saturn.core.molecule.Molecule"
	_hx_fields = ["sequence", "starPosition", "originalSequence", "linkedOriginField", "sequenceField", "floatAttributes", "stringAttributes", "name", "alternativeName", "annotations", "rawAnnotationData", "annotationCRC", "crc", "allowStar", "parent", "linked"]
	_hx_methods = ["isLinked", "setParent", "getParent", "isChild", "setCRC", "updateCRC", "getAnnotationCRC", "getCRC", "setRawAnnotationData", "getRawAnnotationData", "setAllAnnotations", "removeAllAnnotations", "setAnnotations", "getAnnotations", "getAllAnnotations", "getAlternativeName", "setAlternativeName", "getMoleculeName", "setMoleculeName", "getName", "setName", "getSequence", "setSequence", "getFirstPosition", "getLastPosition", "getLocusCount", "contains", "getLength", "getStarPosition", "setStarPosition", "getStarSequence", "equals", "getCutPosition", "getAfterCutSequence", "getBeforeCutSequence", "getLastCutPosition", "getLastBeforeCutSequence", "getLastAfterCutSequence", "getCutProduct", "getFloatAttribute", "_getFloatAttribute", "_setFloatAttribute", "setFloatAttribute", "getStringAttribute", "_getStringAttribute", "_setStringAttribute", "setStringAttribute", "getMW", "findMatchingLocuses", "findMatchingLocusesSimple", "findMatchingLocusesRegEx", "updateAnnotations"]
	_hx_statics = ["newLineReg", "carLineReg", "whiteSpaceReg", "reg_starReplace"]

	def __init__(self,seq):
		self.sequence = None
		self.starPosition = None
		self.originalSequence = None
		self.linkedOriginField = None
		self.sequenceField = None
		self.floatAttributes = None
		self.stringAttributes = None
		self.name = None
		self.alternativeName = None
		self.annotations = None
		self.rawAnnotationData = None
		self.annotationCRC = None
		self.crc = None
		self.allowStar = None
		self.parent = None
		self.linked = None
		self.linked = False
		self.allowStar = False
		self.floatAttributes = haxe_ds_StringMap()
		self.stringAttributes = haxe_ds_StringMap()
		self.annotations = haxe_ds_StringMap()
		self.rawAnnotationData = haxe_ds_StringMap()
		self.annotationCRC = haxe_ds_StringMap()
		self.setSequence(seq)

	def isLinked(self):
		return self.linked

	def setParent(self,parent):
		self.parent = parent

	def getParent(self):
		return self.parent

	def isChild(self):
		return (self.parent is not None)

	def setCRC(self,crc):
		self.crc = crc

	def updateCRC(self):
		if (self.sequence is not None):
			self.crc = haxe_crypto_Md5.encode(self.sequence)

	def getAnnotationCRC(self,annotationName):
		return self.annotationCRC.h.get(annotationName,None)

	def getCRC(self):
		return self.crc

	def setRawAnnotationData(self,rawAnnotationData,annotationName):
		value = rawAnnotationData
		value1 = value
		self.rawAnnotationData.h[annotationName] = value1

	def getRawAnnotationData(self,annotationName):
		return self.rawAnnotationData.h.get(annotationName,None)

	def setAllAnnotations(self,annotations):
		self.removeAllAnnotations()
		_hx_local_0 = annotations.keys()
		while _hx_local_0.hasNext():
			annotationName = _hx_local_0.next()
			self.setAnnotations(annotations.h.get(annotationName,None),annotationName)

	def removeAllAnnotations(self):
		_hx_local_0 = self.annotations.keys()
		while _hx_local_0.hasNext():
			annotationName = _hx_local_0.next()
			self.annotations.remove(annotationName)
			self.annotationCRC.remove(annotationName)

	def setAnnotations(self,annotations,annotationName):
		self.annotations.h[annotationName] = annotations
		value = self.getCRC()
		self.annotationCRC.h[annotationName] = value

	def getAnnotations(self,name):
		return self.annotations.h.get(name,None)

	def getAllAnnotations(self):
		return self.annotations

	def getAlternativeName(self):
		return self.alternativeName

	def setAlternativeName(self,altName):
		self.alternativeName = altName

	def getMoleculeName(self):
		return self.name

	def setMoleculeName(self,name):
		self.name = name

	def getName(self):
		return self.getMoleculeName()

	def setName(self,name):
		self.setMoleculeName(name)

	def getSequence(self):
		return self.sequence

	def setSequence(self,seq):
		if (seq is not None):
			seq = seq.upper()
			seq = saturn_core_molecule_Molecule.whiteSpaceReg.replace(seq,"")
			seq = saturn_core_molecule_Molecule.newLineReg.replace(seq,"")
			seq = saturn_core_molecule_Molecule.carLineReg.replace(seq,"")
			self.starPosition = seq.find("*")
			if (not self.allowStar):
				self.originalSequence = seq
				seq = saturn_core_molecule_Molecule.reg_starReplace.replace(seq,"")
			self.sequence = seq
		self.updateCRC()

	def getFirstPosition(self,seq):
		_this = self.sequence
		return _this.find(seq)

	def getLastPosition(self,seq):
		if (seq == ""):
			return -1
		c = 0
		lastMatchPos = -1
		lastLastMatchPos = -1
		while True:
			_this = self.sequence
			startIndex = (lastMatchPos + 1)
			lastMatchPos = (_this.find(seq) if ((startIndex is None)) else _this.find(seq, startIndex))
			if (lastMatchPos != -1):
				lastLastMatchPos = lastMatchPos
				c = (c + 1)
			else:
				break
		return lastLastMatchPos

	def getLocusCount(self,seq):
		if (seq == ""):
			return 0
		c = 0
		lastMatchPos = -1
		while True:
			_this = self.sequence
			startIndex = (lastMatchPos + 1)
			lastMatchPos = (_this.find(seq) if ((startIndex is None)) else _this.find(seq, startIndex))
			if (lastMatchPos != -1):
				c = (c + 1)
			else:
				break
		return c

	def contains(self,seq):
		def _hx_local_0():
			_this = self.sequence
			return _this.find(seq)
		if (_hx_local_0() > -1):
			return True
		else:
			return False

	def getLength(self):
		return len(self.sequence)

	def getStarPosition(self):
		return self.starPosition

	def setStarPosition(self,starPosition):
		self.starPosition = starPosition

	def getStarSequence(self):
		return self.originalSequence

	def equals(self,other):
		if (other.getStarPosition() != self.getStarPosition()):
			return False
		elif (self.getSequence() != other.getSequence()):
			return False
		return True

	def getCutPosition(self,template):
		if (template.getLocusCount(self.getSequence()) > 0):
			siteStartPosition = template.getFirstPosition(self.getSequence())
			return (siteStartPosition + self.starPosition)
		else:
			return -1

	def getAfterCutSequence(self,template):
		cutPosition = self.getCutPosition(template)
		if (cutPosition == -1):
			return ""
		else:
			seq = template.getSequence()
			return HxString.substring(seq,cutPosition,len(seq))

	def getBeforeCutSequence(self,template):
		cutPosition = self.getCutPosition(template)
		if (cutPosition == -1):
			return ""
		else:
			seq = template.getSequence()
			return HxString.substring(seq,0,cutPosition)

	def getLastCutPosition(self,template):
		if (template.getLocusCount(self.getSequence()) > 0):
			siteStartPosition = template.getLastPosition(self.getSequence())
			return (siteStartPosition + self.starPosition)
		else:
			return -1

	def getLastBeforeCutSequence(self,template):
		cutPosition = self.getLastCutPosition(template)
		if (cutPosition == -1):
			return ""
		else:
			seq = template.getSequence()
			return HxString.substring(seq,0,cutPosition)

	def getLastAfterCutSequence(self,template):
		cutPosition = self.getLastCutPosition(template)
		if (cutPosition == -1):
			return ""
		else:
			seq = template.getSequence()
			return HxString.substring(seq,cutPosition,len(seq))

	def getCutProduct(self,template,direction):
		if (direction == saturn_core_CutProductDirection.UPSTREAM):
			return self.getBeforeCutSequence(template)
		elif (direction == saturn_core_CutProductDirection.DOWNSTREAM):
			return self.getAfterCutSequence(template)
		elif (direction == saturn_core_CutProductDirection.UPDOWN):
			startPos = self.getCutPosition(template)
			endPos = (self.getLastCutPosition(template) - self.getLength())
			_this = template.getSequence()
			return HxString.substring(_this,startPos,endPos)
		else:
			return None

	def getFloatAttribute(self,attr):
		return self._getFloatAttribute(Std.string(attr))

	def _getFloatAttribute(self,attributeName):
		if attributeName in self.floatAttributes.h:
			return self.floatAttributes.h.get(attributeName,None)
		return None

	def _setFloatAttribute(self,attributeName,val):
		self.floatAttributes.h[attributeName] = val

	def setFloatAttribute(self,attr,val):
		self._setFloatAttribute(Std.string(attr),val)

	def getStringAttribute(self,attr):
		return self._getStringAttribute(Std.string(attr))

	def _getStringAttribute(self,attributeName):
		if attributeName in self.stringAttributes.h:
			return self.stringAttributes.h.get(attributeName,None)
		return None

	def _setStringAttribute(self,attributeName,val):
		self.stringAttributes.h[attributeName] = val

	def setStringAttribute(self,attr,val):
		self._setStringAttribute(Std.string(attr),val)
		return

	def getMW(self):
		return self.getFloatAttribute(saturn_core_molecule_MoleculeFloatAttribute.MW)

	def findMatchingLocuses(self,locus,mode = None):
		collookup_single = EReg("^(\\d+)$", "")
		def _hx_local_0():
			collookup_single.matchObj = python_lib_Re.search(collookup_single.pattern,locus)
			return (collookup_single.matchObj is not None)
		if _hx_local_0():
			num = collookup_single.matchObj.group(1)
			locusPosition = saturn_core_LocusPosition()
			locusPosition.start = (Std.parseInt(num) - 1)
			locusPosition.end = locusPosition.start
			return [locusPosition]
		collookup_double = EReg("^(\\d+)-(\\d+)$", "")
		def _hx_local_1():
			collookup_double.matchObj = python_lib_Re.search(collookup_double.pattern,locus)
			return (collookup_double.matchObj is not None)
		if _hx_local_1():
			locusPosition1 = saturn_core_LocusPosition()
			locusPosition1.start = (Std.parseInt(collookup_double.matchObj.group(1)) - 1)
			locusPosition1.end = (Std.parseInt(collookup_double.matchObj.group(2)) - 1)
			return [locusPosition1]
		collookup_toend = EReg("^(\\d+)-$", "")
		def _hx_local_2():
			collookup_toend.matchObj = python_lib_Re.search(collookup_toend.pattern,locus)
			return (collookup_toend.matchObj is not None)
		if _hx_local_2():
			locusPosition2 = saturn_core_LocusPosition()
			locusPosition2.start = (Std.parseInt(collookup_toend.matchObj.group(1)) - 1)
			locusPosition2.end = (self.getLength() - 1)
			return [locusPosition2]
		re_missMatchTotal = EReg("^(\\d+)(.+)", "")
		if (mode is None):
			mode = saturn_core_molecule_MoleculeAlignMode.REGEX
			def _hx_local_3():
				re_missMatchTotal.matchObj = python_lib_Re.search(re_missMatchTotal.pattern,locus)
				return (re_missMatchTotal.matchObj is not None)
			if _hx_local_3():
				mode = saturn_core_molecule_MoleculeAlignMode.SIMPLE
		if (mode == saturn_core_molecule_MoleculeAlignMode.REGEX):
			return self.findMatchingLocusesRegEx(locus)
		elif (mode == saturn_core_molecule_MoleculeAlignMode.SIMPLE):
			missMatchesAllowed = 0
			def _hx_local_4():
				re_missMatchTotal.matchObj = python_lib_Re.search(re_missMatchTotal.pattern,locus)
				return (re_missMatchTotal.matchObj is not None)
			if _hx_local_4():
				missMatchesAllowed = Std.parseInt(re_missMatchTotal.matchObj.group(1))
				locus = re_missMatchTotal.matchObj.group(2)
			return self.findMatchingLocusesSimple(locus,missMatchesAllowed)
		else:
			return None

	def findMatchingLocusesSimple(self,locus,missMatchesAllowed = 0):
		if (missMatchesAllowed is None):
			missMatchesAllowed = 0
		positions = list()
		if ((locus is None) or ((locus == ""))):
			return positions
		currentMissMatches = 0
		seqI = -1
		lI = -1
		startPos = 0
		missMatchLimit = (missMatchesAllowed + 1)
		missMatchPositions = list()
		while True:
			lI = (lI + 1)
			seqI = (seqI + 1)
			if (seqI > ((len(self.sequence) - 1))):
				break
			def _hx_local_2():
				_this = self.sequence
				return ("" if (((seqI < 0) or ((seqI >= len(_this))))) else _this[seqI])
			if ((("" if (((lI < 0) or ((lI >= len(locus))))) else locus[lI])) != _hx_local_2()):
				currentMissMatches = (currentMissMatches + 1)
				missMatchPositions.append(seqI)
			if (lI == 0):
				startPos = seqI
			if (currentMissMatches == missMatchLimit):
				seqI = startPos
				lI = -1
				currentMissMatches = 0
				missMatchPositions = list()
			elif (lI == ((len(locus) - 1))):
				locusPosition = saturn_core_LocusPosition()
				locusPosition.start = startPos
				locusPosition.end = seqI
				locusPosition.missMatchPositions = missMatchPositions
				positions.append(locusPosition)
				lI = -1
				currentMissMatches = 0
				missMatchPositions = list()
		return positions

	def findMatchingLocusesRegEx(self,regex):
		r = EReg(regex, "i")
		positions = list()
		if ((regex is None) or ((regex == ""))):
			return positions
		offSet = 0
		matchAgainst = self.sequence
		while (matchAgainst is not None):
			def _hx_local_0():
				r.matchObj = python_lib_Re.search(r.pattern,matchAgainst)
				return (r.matchObj is not None)
			if _hx_local_0():
				locusPosition = saturn_core_LocusPosition()
				match_pos = r.matchObj.start()
				match_len = (r.matchObj.end() - r.matchObj.start())
				locusPosition.start = (match_pos + offSet)
				locusPosition.end = (((match_pos + match_len) - 1) + offSet)
				offSet = (locusPosition.end + 1)
				pos = r.matchObj.end()
				matchAgainst = HxString.substr(r.matchObj.string,pos,None)
				positions.append(locusPosition)
			else:
				break
		return positions

	def updateAnnotations(self,annotationName,config,annotationManager,cb):
		if (self.getAnnotationCRC(annotationName) == self.getCRC()):
			cb(None,self.getAnnotations(annotationName))
		else:
			def _hx_local_0(err,res):
				cb(err,res)
			annotationManager.annotateMolecule(self,annotationName,config,_hx_local_0)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.sequence = None
		_hx_o.starPosition = None
		_hx_o.originalSequence = None
		_hx_o.linkedOriginField = None
		_hx_o.sequenceField = None
		_hx_o.floatAttributes = None
		_hx_o.stringAttributes = None
		_hx_o.name = None
		_hx_o.alternativeName = None
		_hx_o.annotations = None
		_hx_o.rawAnnotationData = None
		_hx_o.annotationCRC = None
		_hx_o.crc = None
		_hx_o.allowStar = None
		_hx_o.parent = None
		_hx_o.linked = None
saturn_core_molecule_Molecule._hx_class = saturn_core_molecule_Molecule
_hx_classes["saturn.core.molecule.Molecule"] = saturn_core_molecule_Molecule


class saturn_core_DNA(saturn_core_molecule_Molecule):
	_hx_class_name = "saturn.core.DNA"
	_hx_fields = ["protein", "reg_tReplace"]
	_hx_methods = ["getProtein", "setProtein", "getGCFraction", "convertToRNA", "getHydrogenBondCount", "getMolecularWeight", "setSequence", "proteinSequenceUpdated", "getComposition", "getMeltingTemperature", "findPrimer", "getNumGC", "getInverse", "getComplement", "getInverseComplement", "getFirstStartCodonPosition", "getTranslation", "getFrameTranslation", "getThreeFrameTranslation", "getSixFrameTranslation", "getFirstStartCodonPositionByFrame", "getStartCodonPositions", "getFirstStopCodonPosition", "getStopCodonPositions", "canHaveCodons", "getFrameRegion", "mutateResidue", "getCodonStartPosition", "getCodonStopPosition", "getRegion", "getFrom", "findMatchingLocuses"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_molecule_Molecule


	def __init__(self,seq):
		self.protein = None
		self.reg_tReplace = None
		self.reg_tReplace = EReg("T", "g")
		super().__init__(seq)

	def getProtein(self):
		return self.protein

	def setProtein(self,prot):
		if (self.protein is not None):
			self.protein.dna.setParent(None)
			self.protein.dna = None
			self.protein.setParent(None)
			self.protein.linked = False
		self.protein = prot
		if (self.protein is not None):
			self.protein.linked = True
			self.protein.dna = self
			self.protein.setParent(self)
			self.linked = True
			if ((prot.getMoleculeName() is None) or ((prot.getMoleculeName() == ""))):
				prot.setMoleculeName((HxOverrides.stringOrNull(self.getMoleculeName()) + " (Protein)"))
		else:
			self.linked = False

	def getGCFraction(self):
		dnaComposition = self.getComposition()
		return (((dnaComposition.cCount + dnaComposition.gCount)) / self.getLength())

	def convertToRNA(self):
		return self.reg_tReplace.replace(self.getSequence(),"U")

	def getHydrogenBondCount(self):
		dnaComposition = self.getComposition()
		return ((((dnaComposition.gCount + dnaComposition.cCount)) * 3) + ((((dnaComposition.aCount + dnaComposition.tCount)) * 2)))

	def getMolecularWeight(self,phosphateAt5Prime):
		dnaComposition = self.getComposition()
		seqMW = 0.0
		seqMW = (seqMW + ((dnaComposition.aCount * saturn_core_molecule_MoleculeConstants.aChainMW)))
		seqMW = (seqMW + ((dnaComposition.tCount * saturn_core_molecule_MoleculeConstants.tChainMW)))
		seqMW = (seqMW + ((dnaComposition.gCount * saturn_core_molecule_MoleculeConstants.gChainMW)))
		seqMW = (seqMW + ((dnaComposition.cCount * saturn_core_molecule_MoleculeConstants.cChainMW)))
		if (phosphateAt5Prime == False):
			seqMW = (seqMW - saturn_core_molecule_MoleculeConstants.PO3)
		seqMW = (seqMW + saturn_core_molecule_MoleculeConstants.OH)
		return seqMW

	def setSequence(self,sequence):
		super().setSequence(sequence)
		if self.isChild():
			p = self.getParent()
			p.dnaSequenceUpdated(self.sequence)

	def proteinSequenceUpdated(self,sequence):
		pass

	def getComposition(self):
		aCount = 0
		tCount = 0
		gCount = 0
		cCount = 0
		seqLen = len(self.sequence)
		_g = 0
		while (_g < seqLen):
			i = _g
			_g = (_g + 1)
			nuc = None
			_this = self.sequence
			if ((i < 0) or ((i >= len(_this)))):
				nuc = ""
			else:
				nuc = _this[i]
			if (nuc == "A"):
				aCount = (aCount + 1)
			elif (nuc == "T"):
				tCount = (tCount + 1)
			elif (nuc == "G"):
				gCount = (gCount + 1)
			elif (nuc == "C"):
				cCount = (cCount + 1)
			elif (nuc == "U"):
				tCount = (tCount + 1)
			else:
				pass
		return saturn_core_DNAComposition(aCount, tCount, gCount, cCount)

	def getMeltingTemperature(self):
		saltConc = 50
		primerConc = 500
		testTmCalc = saturn_core_TmCalc()
		return testTmCalc.tmCalculation(self,saltConc,primerConc)

	def findPrimer(self,startPos,minLength,maxLength,minMelting,maxMelting,extensionSequence = None,minLengthExtended = -1,minMeltingExtended = -1,maxMeltingExtentded = -1):
		if (minLengthExtended is None):
			minLengthExtended = -1
		if (minMeltingExtended is None):
			minMeltingExtended = -1
		if (maxMeltingExtentded is None):
			maxMeltingExtentded = -1
		cCount = None
		gCount = None
		tCount = None
		aCount = 0
		seq = HxString.substr(self.sequence,(startPos - 1),(minLength - 1))
		comp = saturn_core_DNA(seq).getComposition()
		cCount = comp.cCount
		gCount = comp.gCount
		tCount = comp.tCount
		aCount = comp.aCount
		rangeStart = (((startPos - 1) + minLength) - 1)
		rangeStop = (rangeStart + maxLength)
		_g = rangeStart
		while (_g < rangeStop):
			i = _g
			_g = (_g + 1)
			char = None
			_this = self.sequence
			if ((i < 0) or ((i >= len(_this)))):
				char = ""
			else:
				char = _this[i]
			if (char == "C"):
				cCount = (cCount + 1)
			elif (char == "G"):
				gCount = (gCount + 1)
			elif (char == "A"):
				aCount = (aCount + 1)
			elif (char == "T"):
				tCount = (tCount + 1)
			seq = (("null" if seq is None else seq) + ("null" if char is None else char))
			mt = saturn_core_DNA(seq).getMeltingTemperature()
			if (mt > maxMelting):
				raise _HxException(saturn_util_HaxeException("Maximum melting temperature exceeded"))
			elif ((mt >= minMelting) and ((mt <= maxMelting))):
				if (extensionSequence is None):
					return seq
				else:
					completeSequence = saturn_core_DNA((("null" if extensionSequence is None else extensionSequence) + ("null" if seq is None else seq)))
					completeMT = completeSequence.getMeltingTemperature()
					if (((completeMT >= minMeltingExtended) and ((completeMT <= maxMeltingExtentded))) and ((completeSequence.getLength() >= minLengthExtended))):
						return seq
					elif (completeMT < minMeltingExtended):
						continue
					elif (completeMT > maxMeltingExtentded):
						raise _HxException(saturn_util_HaxeException("Maximum melting temperature for extended primer sequence exceeded"))
					elif (completeSequence.getLength() < minLengthExtended):
						continue
		raise _HxException(saturn_util_HaxeException("Unable to find region with required parameters"))

	def getNumGC(self):
		seqLen = len(self.sequence)
		gcNum = 0
		_g = 0
		while (_g < seqLen):
			i = _g
			_g = (_g + 1)
			nuc = None
			_this = self.sequence
			if ((i < 0) or ((i >= len(_this)))):
				nuc = ""
			else:
				nuc = _this[i]
			if ((nuc == "G") or ((nuc == "C"))):
				gcNum = (gcNum + 1)
		return gcNum

	def getInverse(self):
		newSequence_b = python_lib_io_StringIO()
		seqLen = len(self.sequence)
		_g = 0
		while (_g < seqLen):
			i = _g
			_g = (_g + 1)
			j = ((seqLen - i) - 1)
			nuc = None
			_this = self.sequence
			if ((j < 0) or ((j >= len(_this)))):
				nuc = ""
			else:
				nuc = _this[j]
			newSequence_b.write(Std.string(nuc))
		return newSequence_b.getvalue()

	def getComplement(self):
		newSequence_b = python_lib_io_StringIO()
		seqLen = len(self.sequence)
		_g = 0
		while (_g < seqLen):
			i = _g
			_g = (_g + 1)
			nuc = None
			_this = self.sequence
			if ((i < 0) or ((i >= len(_this)))):
				nuc = ""
			else:
				nuc = _this[i]
			if (nuc == "A"):
				nuc = "T"
			elif (nuc == "T"):
				nuc = "A"
			elif (nuc == "G"):
				nuc = "C"
			elif (nuc == "C"):
				nuc = "G"
			else:
				pass
			newSequence_b.write(Std.string(nuc))
		return newSequence_b.getvalue()

	def getInverseComplement(self):
		newSequence_b = python_lib_io_StringIO()
		seqLen = len(self.sequence)
		_g = 0
		while (_g < seqLen):
			i = _g
			_g = (_g + 1)
			j = ((seqLen - i) - 1)
			nuc = None
			_this = self.sequence
			if ((j < 0) or ((j >= len(_this)))):
				nuc = ""
			else:
				nuc = _this[j]
			if (nuc == "A"):
				nuc = "T"
			elif (nuc == "T"):
				nuc = "A"
			elif (nuc == "G"):
				nuc = "C"
			elif (nuc == "C"):
				nuc = "G"
			else:
				pass
			newSequence_b.write(Std.string(nuc))
		return newSequence_b.getvalue()

	def getFirstStartCodonPosition(self,geneticCode):
		geneticCode1 = saturn_core_GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode)
		codons = geneticCode1.getStartCodons()
		minStartPos = -1
		_hx_local_0 = codons.keys()
		while _hx_local_0.hasNext():
			codon = _hx_local_0.next()
			index = None
			_this = self.sequence
			index = _this.find(codon)
			if (index > -1):
				if ((minStartPos == -1) or ((minStartPos > index))):
					minStartPos = index
		return minStartPos

	def getTranslation(self,geneticCode,offSetPosition = 0,stopAtFirstStop = None):
		if (offSetPosition is None):
			offSetPosition = 0
		if (not self.canHaveCodons()):
			raise _HxException(saturn_util_HaxeException("Unable to translate a sequence with less than 3 nucleotides"))
		proteinSequenceBuffer_b = python_lib_io_StringIO()
		seqLength = len(self.sequence)
		finalCodonPosition = (seqLength - (HxOverrides.mod(((seqLength - offSetPosition)), 3)))
		geneticCode1 = saturn_core_GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode)
		startIndex = offSetPosition
		stopCodons = geneticCode1.getStopCodons()
		while (startIndex < finalCodonPosition):
			endIndex = (startIndex + 3)
			codon = HxString.substring(self.sequence,startIndex,endIndex)
			code = geneticCode1.lookupCodon(codon)
			if (stopAtFirstStop and ((code == "!"))):
				break
			proteinSequenceBuffer_b.write(Std.string(code))
			startIndex = endIndex
		return proteinSequenceBuffer_b.getvalue()

	def getFrameTranslation(self,geneticCode,frame):
		if (self.sequence is None):
			return None
		offSetPos = 0
		if (frame == saturn_core_Frame.TWO):
			offSetPos = 1
		elif (frame == saturn_core_Frame.THREE):
			offSetPos = 2
		return self.getTranslation(geneticCode,offSetPos,True)

	def getThreeFrameTranslation(self,geneticCode):
		threeFrameTranslations = haxe_ds_StringMap()
		value = self.getFrameTranslation(geneticCode,saturn_core_Frame.ONE)
		threeFrameTranslations.h[Std.string(saturn_core_Frame.ONE)] = value
		value1 = self.getFrameTranslation(geneticCode,saturn_core_Frame.TWO)
		threeFrameTranslations.h[Std.string(saturn_core_Frame.TWO)] = value1
		value2 = self.getFrameTranslation(geneticCode,saturn_core_Frame.THREE)
		threeFrameTranslations.h[Std.string(saturn_core_Frame.THREE)] = value2
		return threeFrameTranslations

	def getSixFrameTranslation(self,geneticCode):
		forwardFrames = self.getThreeFrameTranslation(geneticCode)
		dnaSeq = self.getInverseComplement()
		inverseComplementDNAObj = saturn_core_DNA(dnaSeq)
		reverseFrames = inverseComplementDNAObj.getThreeFrameTranslation(geneticCode)
		value = reverseFrames.h.get("ONE",None)
		forwardFrames.h["ONE_IC"] = value
		value1 = reverseFrames.h.get("TWO",None)
		forwardFrames.h["TWO_IC"] = value1
		value2 = reverseFrames.h.get("THREE",None)
		forwardFrames.h["THREE_IC"] = value2
		return forwardFrames

	def getFirstStartCodonPositionByFrame(self,geneticCode,frame):
		startCodons = self.getStartCodonPositions(geneticCode,frame,True)
		if (len(startCodons) == 0):
			return -1
		else:
			return (startCodons[0] if 0 < len(startCodons) else None)

	def getStartCodonPositions(self,geneticCode,frame,stopAtFirst):
		offSet = 0
		if (frame == saturn_core_Frame.TWO):
			offSet = 1
		elif (frame == saturn_core_Frame.THREE):
			offSet = 2
		seqLength = len(self.sequence)
		startingIndex = offSet
		if (seqLength < ((startingIndex + 3))):
			raise _HxException(saturn_util_HaxeException(("Insufficient DNA length to find codon start position for frame " + Std.string(frame))))
		startCodonPositions = list()
		finalCodonPosition = (seqLength - (HxOverrides.mod(((seqLength - offSet)), 3)))
		geneticCode1 = saturn_core_GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode)
		startIndex = startingIndex
		while (startIndex < finalCodonPosition):
			endIndex = (startIndex + 3)
			codon = HxString.substring(self.sequence,startIndex,endIndex)
			if geneticCode1.isStartCodon(codon):
				startCodonPositions.append(startIndex)
				if stopAtFirst:
					break
			startIndex = endIndex
		return startCodonPositions

	def getFirstStopCodonPosition(self,geneticCode,frame):
		startCodons = self.getStopCodonPositions(geneticCode,frame,True)
		if startCodons.isEmpty():
			return -1
		else:
			return startCodons.first()

	def getStopCodonPositions(self,geneticCode,frame,stopAtFirst):
		offSet = 0
		if (frame == saturn_core_Frame.TWO):
			offSet = 1
		elif (frame == saturn_core_Frame.THREE):
			offSet = 2
		seqLength = len(self.sequence)
		startingIndex = offSet
		if (seqLength < ((startingIndex + 3))):
			raise _HxException(saturn_util_HaxeException(("Insufficient DNA length to find codon start position for frame " + Std.string(frame))))
		startCodonPositions = List()
		finalCodonPosition = (seqLength - (HxOverrides.mod(((seqLength - offSet)), 3)))
		geneticCode1 = saturn_core_GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode)
		startIndex = startingIndex
		while (startIndex < finalCodonPosition):
			endIndex = (startIndex + 3)
			codon = HxString.substring(self.sequence,startIndex,endIndex)
			if geneticCode1.isStopCodon(codon):
				startCodonPositions.add(startIndex)
				if stopAtFirst:
					break
			startIndex = endIndex
		return startCodonPositions

	def canHaveCodons(self):
		if (len(self.sequence) >= 3):
			return True
		else:
			return False

	def getFrameRegion(self,frame,start,stop):
		dnaStart = None
		dnaStop = None
		if (frame == saturn_core_Frame.ONE):
			dnaStart = ((start * 3) - 2)
			dnaStop = (stop * 3)
		elif (frame == saturn_core_Frame.TWO):
			dnaStart = ((start * 3) - 1)
			dnaStop = ((stop * 3) + 1)
		elif (frame == saturn_core_Frame.THREE):
			dnaStart = (start * 3)
			dnaStop = ((stop * 3) + 2)
		else:
			return None
		return HxString.substring(self.sequence,(dnaStart - 1),dnaStop)

	def mutateResidue(self,frame,geneticCode,pos,mutAA):
		nucPos = self.getCodonStartPosition(frame,pos)
		if (nucPos >= len(self.sequence)):
			raise _HxException(saturn_util_HaxeException("Sequence not long enough for requested frame and position"))
		geneticCode1 = saturn_core_GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode)
		codon = geneticCode1.getFirstCodon(mutAA)
		return ((HxOverrides.stringOrNull(HxString.substring(self.sequence,0,(nucPos - 1))) + ("null" if codon is None else codon)) + HxOverrides.stringOrNull(HxString.substring(self.sequence,(nucPos + 2),len(self.sequence))))

	def getCodonStartPosition(self,frame,start):
		dnaStart = None
		if (frame == saturn_core_Frame.ONE):
			dnaStart = ((start * 3) - 2)
		elif (frame == saturn_core_Frame.TWO):
			dnaStart = ((start * 3) - 1)
		elif (frame == saturn_core_Frame.THREE):
			dnaStart = (start * 3)
		else:
			return None
		return dnaStart

	def getCodonStopPosition(self,frame,stop):
		dnaStop = None
		if (frame == saturn_core_Frame.ONE):
			dnaStop = (stop * 3)
		elif (frame == saturn_core_Frame.TWO):
			dnaStop = ((stop * 3) + 1)
		elif (frame == saturn_core_Frame.THREE):
			dnaStop = ((stop * 3) + 2)
		else:
			return None
		return dnaStop

	def getRegion(self,start,stop):
		return HxString.substr(self.sequence,(start - 1),((stop - start) + 1))

	def getFrom(self,start,_hx_len):
		return HxString.substr(self.sequence,(start - 1),_hx_len)

	def findMatchingLocuses(self,regex,mode = None):
		direction = saturn_core_Direction.Forward
		if StringTools.startsWith(regex,"r"):
			templateIC = saturn_core_DNA(self.getInverseComplement())
			regexIC = HxString.substring(regex,1,len(regex))
			positions = templateIC.findMatchingLocuses(regexIC,mode)
			length = self.getLength()
			_g = 0
			while (_g < len(positions)):
				position = (positions[_g] if _g >= 0 and _g < len(positions) else None)
				_g = (_g + 1)
				originalStart = position.start
				position.start = ((length - 1) - position.end)
				position.end = ((length - 1) - originalStart)
				if (position.missMatchPositions is not None):
					fPositions = list()
					_g1 = 0
					_g2 = position.missMatchPositions
					while (_g1 < len(_g2)):
						position1 = (_g2[_g1] if _g1 >= 0 and _g1 < len(_g2) else None)
						_g1 = (_g1 + 1)
						fPositions.append(((length - 1) - position1))
					position.missMatchPositions = fPositions
			return positions
		else:
			return super().findMatchingLocuses(regex)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.protein = None
		_hx_o.reg_tReplace = None
saturn_core_DNA._hx_class = saturn_core_DNA
_hx_classes["saturn.core.DNA"] = saturn_core_DNA

class saturn_core_Frame(Enum):
	_hx_class_name = "saturn.core.Frame"
	_hx_constructs = ["ONE", "TWO", "THREE"]
saturn_core_Frame.ONE = saturn_core_Frame("ONE", 0, list())
saturn_core_Frame.TWO = saturn_core_Frame("TWO", 1, list())
saturn_core_Frame.THREE = saturn_core_Frame("THREE", 2, list())
saturn_core_Frame._hx_class = saturn_core_Frame
_hx_classes["saturn.core.Frame"] = saturn_core_Frame


class saturn_core_Frames:
	_hx_class_name = "saturn.core.Frames"
	_hx_statics = ["toInt"]

	@staticmethod
	def toInt(frame):
		if ((frame.index) == 0):
			return 0
		elif ((frame.index) == 1):
			return 1
		elif ((frame.index) == 2):
			return 2
		else:
			pass
saturn_core_Frames._hx_class = saturn_core_Frames
_hx_classes["saturn.core.Frames"] = saturn_core_Frames

class saturn_core_Direction(Enum):
	_hx_class_name = "saturn.core.Direction"
	_hx_constructs = ["Forward", "Reverse"]
saturn_core_Direction.Forward = saturn_core_Direction("Forward", 0, list())
saturn_core_Direction.Reverse = saturn_core_Direction("Reverse", 1, list())
saturn_core_Direction._hx_class = saturn_core_Direction
_hx_classes["saturn.core.Direction"] = saturn_core_Direction


class saturn_core_DNAComposition:
	_hx_class_name = "saturn.core.DNAComposition"
	_hx_fields = ["aCount", "tCount", "gCount", "cCount"]

	def __init__(self,aCount,tCount,gCount,cCount):
		self.aCount = None
		self.tCount = None
		self.gCount = None
		self.cCount = None
		self.aCount = aCount
		self.tCount = tCount
		self.gCount = gCount
		self.cCount = cCount

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.aCount = None
		_hx_o.tCount = None
		_hx_o.gCount = None
		_hx_o.cCount = None
saturn_core_DNAComposition._hx_class = saturn_core_DNAComposition
_hx_classes["saturn.core.DNAComposition"] = saturn_core_DNAComposition


class saturn_core_GeneticCode:
	_hx_class_name = "saturn.core.GeneticCode"
	_hx_fields = ["codonLookupTable", "aaToCodonTable", "startCodons", "stopCodons"]
	_hx_methods = ["addStartCodon", "isStartCodon", "addStopCodon", "isStopCodon", "getStopCodons", "getCodonCount", "getStartCodons", "populateTable", "lookupCodon", "getCodonLookupTable", "getAAToCodonTable", "getFirstCodon"]

	def __init__(self):
		self.codonLookupTable = None
		self.aaToCodonTable = None
		self.startCodons = None
		self.stopCodons = None
		self.codonLookupTable = haxe_ds_StringMap()
		self.aaToCodonTable = haxe_ds_StringMap()
		self.startCodons = haxe_ds_StringMap()
		self.stopCodons = haxe_ds_StringMap()
		self.populateTable()

	def addStartCodon(self,codon):
		self.startCodons.h[codon] = "1"

	def isStartCodon(self,codon):
		return codon in self.startCodons.h

	def addStopCodon(self,codon):
		self.stopCodons.h[codon] = "1"

	def isStopCodon(self,codon):
		return codon in self.stopCodons.h

	def getStopCodons(self):
		return self.stopCodons

	def getCodonCount(self):
		return Lambda.count(self.codonLookupTable)

	def getStartCodons(self):
		clone = haxe_ds_StringMap()
		_hx_local_0 = self.startCodons.keys()
		while _hx_local_0.hasNext():
			key = _hx_local_0.next()
			value = self.startCodons.h.get(key,None)
			clone.h[key] = value
		return clone

	def populateTable(self):
		pass

	def lookupCodon(self,codon):
		if codon in self.codonLookupTable.h:
			return self.codonLookupTable.h.get(codon,None)
		else:
			return "?"

	def getCodonLookupTable(self):
		return self.codonLookupTable

	def getAAToCodonTable(self):
		return self.aaToCodonTable

	def getFirstCodon(self,aa):
		if aa in self.aaToCodonTable.h:
			codons = self.aaToCodonTable.h.get(aa,None)
			return codons.first()
		else:
			return None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.codonLookupTable = None
		_hx_o.aaToCodonTable = None
		_hx_o.startCodons = None
		_hx_o.stopCodons = None
saturn_core_GeneticCode._hx_class = saturn_core_GeneticCode
_hx_classes["saturn.core.GeneticCode"] = saturn_core_GeneticCode


class saturn_core_StandardGeneticCode(saturn_core_GeneticCode):
	_hx_class_name = "saturn.core.StandardGeneticCode"
	_hx_fields = []
	_hx_methods = ["populateTable"]
	_hx_statics = ["instance", "standardTable", "aaToCodon", "getDefaultInstance"]
	_hx_interfaces = []
	_hx_super = saturn_core_GeneticCode


	def __init__(self):
		super().__init__()
		super().addStartCodon("ATG")
		super().addStopCodon("TAA")
		super().addStopCodon("TGA")
		super().addStopCodon("TAG")

	def populateTable(self):
		self.codonLookupTable.h["TTT"] = "F"
		self.codonLookupTable.h["TTC"] = "F"
		self.codonLookupTable.h["TTA"] = "L"
		self.codonLookupTable.h["TTG"] = "L"
		self.codonLookupTable.h["TCT"] = "S"
		self.codonLookupTable.h["TCC"] = "S"
		self.codonLookupTable.h["TCA"] = "S"
		self.codonLookupTable.h["TCG"] = "S"
		self.codonLookupTable.h["TAT"] = "Y"
		self.codonLookupTable.h["TAC"] = "Y"
		self.codonLookupTable.h["TAA"] = "!"
		self.codonLookupTable.h["TAG"] = "!"
		self.codonLookupTable.h["TGT"] = "C"
		self.codonLookupTable.h["TGC"] = "C"
		self.codonLookupTable.h["TGA"] = "!"
		self.codonLookupTable.h["TGG"] = "W"
		self.codonLookupTable.h["CTT"] = "L"
		self.codonLookupTable.h["CTC"] = "L"
		self.codonLookupTable.h["CTA"] = "L"
		self.codonLookupTable.h["CTG"] = "L"
		self.codonLookupTable.h["CCT"] = "P"
		self.codonLookupTable.h["CCC"] = "P"
		self.codonLookupTable.h["CCA"] = "P"
		self.codonLookupTable.h["CCG"] = "P"
		self.codonLookupTable.h["CAT"] = "H"
		self.codonLookupTable.h["CAC"] = "H"
		self.codonLookupTable.h["CAA"] = "Q"
		self.codonLookupTable.h["CAG"] = "Q"
		self.codonLookupTable.h["CGT"] = "R"
		self.codonLookupTable.h["CGC"] = "R"
		self.codonLookupTable.h["CGA"] = "R"
		self.codonLookupTable.h["CGG"] = "R"
		self.codonLookupTable.h["ATT"] = "I"
		self.codonLookupTable.h["ATC"] = "I"
		self.codonLookupTable.h["ATA"] = "I"
		self.codonLookupTable.h["ATG"] = "M"
		self.codonLookupTable.h["ACT"] = "T"
		self.codonLookupTable.h["ACC"] = "T"
		self.codonLookupTable.h["ACA"] = "T"
		self.codonLookupTable.h["ACG"] = "T"
		self.codonLookupTable.h["AAT"] = "N"
		self.codonLookupTable.h["AAC"] = "N"
		self.codonLookupTable.h["AAA"] = "K"
		self.codonLookupTable.h["AAG"] = "K"
		self.codonLookupTable.h["AGT"] = "S"
		self.codonLookupTable.h["AGC"] = "S"
		self.codonLookupTable.h["AGA"] = "R"
		self.codonLookupTable.h["AGG"] = "R"
		self.codonLookupTable.h["GTT"] = "V"
		self.codonLookupTable.h["GTC"] = "V"
		self.codonLookupTable.h["GTA"] = "V"
		self.codonLookupTable.h["GTG"] = "V"
		self.codonLookupTable.h["GCT"] = "A"
		self.codonLookupTable.h["GCC"] = "A"
		self.codonLookupTable.h["GCA"] = "A"
		self.codonLookupTable.h["GCG"] = "A"
		self.codonLookupTable.h["GAT"] = "D"
		self.codonLookupTable.h["GAC"] = "D"
		self.codonLookupTable.h["GAA"] = "E"
		self.codonLookupTable.h["GAG"] = "E"
		self.codonLookupTable.h["GGT"] = "G"
		self.codonLookupTable.h["GGC"] = "G"
		self.codonLookupTable.h["GGA"] = "G"
		self.codonLookupTable.h["GGG"] = "G"
		_hx_local_0 = self.codonLookupTable.keys()
		while _hx_local_0.hasNext():
			key = _hx_local_0.next()
			aa = self.codonLookupTable.h.get(key,None)
			if (not aa in self.aaToCodonTable.h):
				value = List()
				self.aaToCodonTable.h[aa] = value
			self.aaToCodonTable.h.get(aa,None).add(key)

	@staticmethod
	def getDefaultInstance():
		return saturn_core_StandardGeneticCode.instance

	@staticmethod
	def _hx_empty_init(_hx_o):		pass
saturn_core_StandardGeneticCode._hx_class = saturn_core_StandardGeneticCode
_hx_classes["saturn.core.StandardGeneticCode"] = saturn_core_StandardGeneticCode

class saturn_core_GeneticCodes(Enum):
	_hx_class_name = "saturn.core.GeneticCodes"
	_hx_constructs = ["STANDARD"]
saturn_core_GeneticCodes.STANDARD = saturn_core_GeneticCodes("STANDARD", 0, list())
saturn_core_GeneticCodes._hx_class = saturn_core_GeneticCodes
_hx_classes["saturn.core.GeneticCodes"] = saturn_core_GeneticCodes


class saturn_core_GeneticCodeRegistry:
	_hx_class_name = "saturn.core.GeneticCodeRegistry"
	_hx_fields = ["shortNameToCodeObj"]
	_hx_methods = ["getGeneticCodeNames", "getGeneticCodeByName", "getGeneticCodeByEnum"]
	_hx_statics = ["CODE_REGISTRY", "getRegistry", "getDefault"]

	def __init__(self):
		self.shortNameToCodeObj = None
		self.shortNameToCodeObj = haxe_ds_StringMap()
		value = saturn_core_StandardGeneticCode.getDefaultInstance()
		self.shortNameToCodeObj.h[Std.string(saturn_core_GeneticCodes.STANDARD)] = value

	def getGeneticCodeNames(self):
		nameList = List()
		_hx_local_0 = self.shortNameToCodeObj.keys()
		while _hx_local_0.hasNext():
			key = _hx_local_0.next()
			nameList.add(key)
		return nameList

	def getGeneticCodeByName(self,shortName):
		if (not shortName in self.shortNameToCodeObj.h):
			raise _HxException(saturn_core_InvalidGeneticCodeException((("null" if shortName is None else shortName) + " doesn't correspond to a genetic code in the main registry.")))
		else:
			return self.shortNameToCodeObj.h.get(shortName,None)

	def getGeneticCodeByEnum(self,code):
		return self.getGeneticCodeByName(Std.string(code))

	@staticmethod
	def getRegistry():
		return saturn_core_GeneticCodeRegistry.CODE_REGISTRY

	@staticmethod
	def getDefault():
		return saturn_core_GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(saturn_core_GeneticCodes.STANDARD)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.shortNameToCodeObj = None
saturn_core_GeneticCodeRegistry._hx_class = saturn_core_GeneticCodeRegistry
_hx_classes["saturn.core.GeneticCodeRegistry"] = saturn_core_GeneticCodeRegistry


class saturn_util_HaxeException:
	_hx_class_name = "saturn.util.HaxeException"
	_hx_fields = ["errorMessage"]
	_hx_methods = ["getMessage", "toString"]

	def __init__(self,message):
		self.errorMessage = None
		self.errorMessage = message

	def getMessage(self):
		return self.errorMessage

	def toString(self):
		return self.errorMessage

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.errorMessage = None
saturn_util_HaxeException._hx_class = saturn_util_HaxeException
_hx_classes["saturn.util.HaxeException"] = saturn_util_HaxeException


class saturn_core_InvalidGeneticCodeException(saturn_util_HaxeException):
	_hx_class_name = "saturn.core.InvalidGeneticCodeException"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_util_HaxeException


	def __init__(self,message):
		super().__init__(message)
saturn_core_InvalidGeneticCodeException._hx_class = saturn_core_InvalidGeneticCodeException
_hx_classes["saturn.core.InvalidGeneticCodeException"] = saturn_core_InvalidGeneticCodeException


class saturn_core_InvalidCodonException(saturn_util_HaxeException):
	_hx_class_name = "saturn.core.InvalidCodonException"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_util_HaxeException


	def __init__(self,message):
		super().__init__(message)
saturn_core_InvalidCodonException._hx_class = saturn_core_InvalidCodonException
_hx_classes["saturn.core.InvalidCodonException"] = saturn_core_InvalidCodonException


class saturn_core_EUtils:
	_hx_class_name = "saturn.core.EUtils"
	_hx_statics = ["eutils", "getProteinsForGene", "getProteinInfo", "getDNAForAccessions", "getProteinGIsForGene", "insertProteins", "getGeneInfo"]

	def __init__(self):
		pass

	@staticmethod
	def getProteinsForGene(geneId,cb):
		def _hx_local_1(err,ids):
			if (err is not None):
				cb(err,None)
			else:
				def _hx_local_0(err1,objs):
					cb(err1,objs)
				saturn_core_EUtils.getProteinInfo(ids,True,_hx_local_0)
		saturn_core_EUtils.getProteinGIsForGene(geneId,_hx_local_1)

	@staticmethod
	def getProteinInfo(ids,lookupDNA = False,cb = None):
		if (lookupDNA is None):
			lookupDNA = False
		def _hx_local_8(d):
			if (not hasattr(d,(("_hx_" + "GBSet") if ("GBSet" in python_Boot.keywords) else (("_hx_" + "GBSet") if (((((len("GBSet") > 2) and ((ord("GBSet"[0]) == 95))) and ((ord("GBSet"[1]) == 95))) and ((ord("GBSet"[(len("GBSet") - 1)]) != 95)))) else "GBSet")))):
				cb(("Unable to retrieve proteins for  " + HxOverrides.stringOrNull(((("[" + HxOverrides.stringOrNull(",".join([python_Boot.toString1(x1,'') for x1 in ids]))) + "]")))),None)
				return
			objs = None
			if Std._hx_is(Reflect.field(Reflect.field(d,"GBSet"),"GBSeq"),list):
				objs = Reflect.field(Reflect.field(d,"GBSet"),"GBSeq")
			else:
				objs = [Reflect.field(Reflect.field(d,"GBSet"),"GBSeq")]
			if ((objs is None) or ((len(objs) == 0))):
				cb(("Unable to retrieve proteins for  " + HxOverrides.stringOrNull(",".join([python_Boot.toString1(x1,'') for x1 in ids]))),None)
				return
			protObjs = list()
			_g = 0
			while (_g < len(objs)):
				seqObj = (objs[_g] if _g >= 0 and _g < len(objs) else None)
				_g = (_g + 1)
				protein = saturn_core_Protein(Reflect.field(seqObj,"GBSeq_sequence"))
				protObjs.append(protein)
				protein.setMoleculeName(Reflect.field(seqObj,"GBSeq_accession-version"))
				if hasattr(seqObj,(("_hx_" + "GBSeq_other-seqids") if ("GBSeq_other-seqids" in python_Boot.keywords) else (("_hx_" + "GBSeq_other-seqids") if (((((len("GBSeq_other-seqids") > 2) and ((ord("GBSeq_other-seqids"[0]) == 95))) and ((ord("GBSeq_other-seqids"[1]) == 95))) and ((ord("GBSeq_other-seqids"[(len("GBSeq_other-seqids") - 1)]) != 95)))) else "GBSeq_other-seqids"))):
					seqIdElems = Reflect.field(Reflect.field(seqObj,"GBSeq_other-seqids"),"GBSeqid")
					_g1 = 0
					while (_g1 < len(seqIdElems)):
						seqIdElem = (seqIdElems[_g1] if _g1 >= 0 and _g1 < len(seqIdElems) else None)
						_g1 = (_g1 + 1)
						seqId = seqIdElem
						if (seqId.find("gi|") == 0):
							protein.setAlternativeName(seqId)
							break
				if hasattr(seqObj,(("_hx_" + "GBSeq_feature-table") if ("GBSeq_feature-table" in python_Boot.keywords) else (("_hx_" + "GBSeq_feature-table") if (((((len("GBSeq_feature-table") > 2) and ((ord("GBSeq_feature-table"[0]) == 95))) and ((ord("GBSeq_feature-table"[1]) == 95))) and ((ord("GBSeq_feature-table"[(len("GBSeq_feature-table") - 1)]) != 95)))) else "GBSeq_feature-table"))):
					table = Reflect.field(seqObj,"GBSeq_feature-table")
					features = table.GBFeature
					_g11 = 0
					while (_g11 < len(features)):
						feature = (features[_g11] if _g11 >= 0 and _g11 < len(features) else None)
						_g11 = (_g11 + 1)
						if (Reflect.field(feature,"GBFeature_key") == "CDS"):
							feature_quals = Reflect.field(Reflect.field(feature,"GBFeature_quals"),"GBQualifier")
							_g2 = 0
							while (_g2 < len(feature_quals)):
								feature1 = (feature_quals[_g2] if _g2 >= 0 and _g2 < len(feature_quals) else None)
								_g2 = (_g2 + 1)
								if (Reflect.field(feature1,"GBQualifier_name") == "coded_by"):
									acStr = Reflect.field(feature1,"GBQualifier_value")
									parts = acStr.split(":")
									if (len(parts) > 2):
										cb(("Parts greater than two for  " + HxOverrides.stringOrNull(protein.getMoleculeName())),None)
										return
									else:
										dna = saturn_core_DNA(None)
										name = (parts[0] if 0 < len(parts) else None)
										dna.setMoleculeName(name)
										dna.setProtein(protein)
										protein.setReferenceCoordinates((parts[1] if 1 < len(parts) else None))
			if lookupDNA:
				dnaRefs = list()
				_g3 = 0
				while (_g3 < len(protObjs)):
					protObj = (protObjs[_g3] if _g3 >= 0 and _g3 < len(protObjs) else None)
					_g3 = (_g3 + 1)
					x = protObj.getDNA().getMoleculeName()
					dnaRefs.append(x)
				def _hx_local_7(err,dnaObjs):
					if (err is not None):
						cb(err,None)
					else:
						refMap = haxe_ds_StringMap()
						_g4 = 0
						while (_g4 < len(dnaObjs)):
							obj = (dnaObjs[_g4] if _g4 >= 0 and _g4 < len(dnaObjs) else None)
							_g4 = (_g4 + 1)
							key = obj.getMoleculeName()
							refMap.h[key] = obj
						_g5 = 0
						while (_g5 < len(protObjs)):
							protObj1 = (protObjs[_g5] if _g5 >= 0 and _g5 < len(protObjs) else None)
							_g5 = (_g5 + 1)
							dnaAccession = protObj1.getDNA().getMoleculeName()
							if dnaAccession in refMap.h:
								dna1 = refMap.h.get(dnaAccession,None)
								protObj1.setDNA(dna1)
								coords = None
								_this = protObj1.getReferenceCoordinates()
								coords = _this.split("..")
								if (len(coords) > 2):
									cb(((("Invalid coordinate string for " + HxOverrides.stringOrNull(protObj1.getMoleculeName())) + " ") + HxOverrides.stringOrNull(protObj1.getReferenceCoordinates())),None)
									return
								dna1.setSequence(dna1.getRegion(Std.parseInt((coords[0] if 0 < len(coords) else None)),Std.parseInt((coords[1] if 1 < len(coords) else None))))
								protSeq = dna1.getFrameTranslation(saturn_core_GeneticCodes.STANDARD,saturn_core_Frame.ONE)
							else:
								cb((("null" if dnaAccession is None else dnaAccession) + " not found"),None)
								return
						cb(None,protObjs)
				saturn_core_EUtils.getDNAForAccessions(dnaRefs,_hx_local_7)
			else:
				cb(None,protObjs)
		c1 = Reflect.field(Reflect.field(saturn_core_EUtils.eutils,"efetch")(_hx_AnonObject({'db': "protein", 'id': ids, 'retmode': "xml"})),"then")(_hx_local_8)
		__js__("c1.catch(function(d){cb(d)});")

	@staticmethod
	def getDNAForAccessions(accessions,cb):
		def _hx_local_2(d):
			objs = None
			if Std._hx_is(Reflect.field(Reflect.field(d,"GBSet"),"GBSeq"),list):
				objs = Reflect.field(Reflect.field(d,"GBSet"),"GBSeq")
			else:
				objs = [Reflect.field(Reflect.field(d,"GBSet"),"GBSeq")]
			if ((objs is None) or ((len(objs) == 0))):
				cb(("Unable to retrieve proteins for  " + HxOverrides.stringOrNull(",".join([python_Boot.toString1(x1,'') for x1 in accessions]))),None)
				return
			dnaObjs = list()
			_g = 0
			while (_g < len(objs)):
				seqObj = (objs[_g] if _g >= 0 and _g < len(objs) else None)
				_g = (_g + 1)
				dna = saturn_core_DNA(Reflect.field(seqObj,"GBSeq_sequence"))
				dnaObjs.append(dna)
				dna.setMoleculeName(Reflect.field(seqObj,"GBSeq_accession-version"))
				if hasattr(seqObj,(("_hx_" + "GBSeq_other-seqids") if ("GBSeq_other-seqids" in python_Boot.keywords) else (("_hx_" + "GBSeq_other-seqids") if (((((len("GBSeq_other-seqids") > 2) and ((ord("GBSeq_other-seqids"[0]) == 95))) and ((ord("GBSeq_other-seqids"[1]) == 95))) and ((ord("GBSeq_other-seqids"[(len("GBSeq_other-seqids") - 1)]) != 95)))) else "GBSeq_other-seqids"))):
					seqIdElems = Reflect.field(Reflect.field(seqObj,"GBSeq_other-seqids"),"GBSeqid")
					_g1 = 0
					while (_g1 < len(seqIdElems)):
						seqIdElem = (seqIdElems[_g1] if _g1 >= 0 and _g1 < len(seqIdElems) else None)
						_g1 = (_g1 + 1)
						seqId = seqIdElem
						if (seqId.find("gi|") == 0):
							dna.setAlternativeName(seqId)
							break
			cb(None,dnaObjs)
		c1 = Reflect.field(Reflect.field(saturn_core_EUtils.eutils,"efetch")(_hx_AnonObject({'db': "nucleotide", 'id': accessions, 'retmode': "xml"})),"then")(_hx_local_2)
		__js__("c1.catch(function(d){cb(d)});")

	@staticmethod
	def getProteinGIsForGene(geneId,cb):
		def _hx_local_1(d):
			saturn_core_Util.debug("")
			found = False
			if hasattr(d,(("_hx_" + "linksets") if ("linksets" in python_Boot.keywords) else (("_hx_" + "linksets") if (((((len("linksets") > 2) and ((ord("linksets"[0]) == 95))) and ((ord("linksets"[1]) == 95))) and ((ord("linksets"[(len("linksets") - 1)]) != 95)))) else "linksets"))):
				linksets = Reflect.field(d,"linksets")
				if (len(linksets) > 0):
					if hasattr((linksets[0] if 0 < len(linksets) else None),(("_hx_" + "linksetdbs") if ("linksetdbs" in python_Boot.keywords) else (("_hx_" + "linksetdbs") if (((((len("linksetdbs") > 2) and ((ord("linksetdbs"[0]) == 95))) and ((ord("linksetdbs"[1]) == 95))) and ((ord("linksetdbs"[(len("linksetdbs") - 1)]) != 95)))) else "linksetdbs"))):
						linksetdbs = Reflect.field((linksets[0] if 0 < len(linksets) else None),"linksetdbs")
						if (len(linksetdbs) > 0):
							_g = 0
							while (_g < len(linksetdbs)):
								_hx_set = (linksetdbs[_g] if _g >= 0 and _g < len(linksetdbs) else None)
								_g = (_g + 1)
								if (Reflect.field(_hx_set,"linkname") == "gene_protein_refseq"):
									ids = Reflect.field(_hx_set,"links")
									cb(None,ids)
									found = True
									break
			if (not found):
				cb(("Unable to lookup gene entry " + Std.string(geneId)),None)
		c1 = Reflect.field(Reflect.field(Reflect.field(saturn_core_EUtils.eutils,"esearch")(_hx_AnonObject({'db': "gene", 'term': geneId})),"then")(Reflect.field(saturn_core_EUtils.eutils,"elink")(_hx_AnonObject({'dbto': "protein"}))),"then")(_hx_local_1)
		__js__("c1.catch(function(d){cb(d)});")

	@staticmethod
	def insertProteins(objs,cb):
		run = None
		def _hx_local_1():
			if (len(objs) == 0):
				return
			protein = None
			protein = (None if ((len(objs) == 0)) else objs.pop())
			saturn_core_Util.debug(("Inserting: " + HxOverrides.stringOrNull(protein.getMoleculeName())))
			def _hx_local_0(err):
				if (err is not None):
					saturn_core_Util.debug(err)
				else:
					run()
			saturn_core_Protein.insertTranslation(protein.getDNA().getMoleculeName(),protein.getDNA().getAlternativeName(),protein.getDNA().getSequence(),"NUCLEOTIDE",protein.getMoleculeName(),protein.getAlternativeName(),protein.getSequence(),"PROTEIN","7158","GENE",_hx_local_0)
		run = _hx_local_1
		run()

	@staticmethod
	def getGeneInfo(geneId,cb):
		saturn_core_Util.debug("Fetching gene record (tends to be very slow)")
		def _hx_local_0(d):
			set1 = Reflect.field(d,"Entrezgene-Set")
			set2 = Reflect.field(set1,"Entrezgene")
			set3 = Reflect.field(set2,"Entrezgene_gene")
			set4 = Reflect.field(set3,"Gene-ref")
			cb(None,_hx_AnonObject({'symbol': Reflect.field(set4,"Gene-ref_locus"), 'description': Reflect.field(set4,"Gene-ref_desc")}))
		c1 = Reflect.field(Reflect.field(saturn_core_EUtils.eutils,"efetch")(_hx_AnonObject({'db': "gene", 'id': geneId})),"then")(_hx_local_0)
		__js__("c1.catch(function(d){cb(d)});")
saturn_core_EUtils._hx_class = saturn_core_EUtils
_hx_classes["saturn.core.EUtils"] = saturn_core_EUtils


class saturn_core_EntityType:
	_hx_class_name = "saturn.core.EntityType"
	_hx_fields = ["id", "name"]

	def __init__(self):
		self.id = None
		self.name = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
saturn_core_EntityType._hx_class = saturn_core_EntityType
_hx_classes["saturn.core.EntityType"] = saturn_core_EntityType


class saturn_core_FileShim:
	_hx_class_name = "saturn.core.FileShim"
	_hx_fields = ["name", "base64"]
	_hx_methods = ["getAsText", "getAsArrayBuffer"]

	def __init__(self,name,base64):
		self.name = None
		self.base64 = None
		self.name = name
		self.base64 = base64

	def getAsText(self):
		return ""

	def getAsArrayBuffer(self):
		return None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.name = None
		_hx_o.base64 = None
saturn_core_FileShim._hx_class = saturn_core_FileShim
_hx_classes["saturn.core.FileShim"] = saturn_core_FileShim


class saturn_core_Generator:
	_hx_class_name = "saturn.core.Generator"
	_hx_fields = ["limit", "processed", "done", "cb", "endCb", "maxAtOnce", "items"]
	_hx_methods = ["push", "pop", "die", "stop", "next", "count", "setMaxAtOnce", "setLimit", "onEnd", "onNext", "finished"]

	def __init__(self,limit):
		self.limit = None
		self.processed = None
		self.done = None
		self.cb = None
		self.endCb = None
		self.maxAtOnce = None
		self.items = None
		self.limit = limit
		self.processed = 0
		self.done = False
		self.items = list()
		self.maxAtOnce = 1

	def push(self,item):
		_this = self.items
		x = item
		_this.append(x)

	def pop(self,item):
		_this = self.items
		return (None if ((len(_this) == 0)) else _this.pop())

	def die(self,err):
		saturn_core_Util.debug(err)
		self.stop(err)

	def stop(self,err):
		self.finished()
		self.endCb(err)

	def next(self):
		_g = self
		if ((self.done and ((len(self.items) == 0))) or (((self.limit != -1) and ((self.processed == self.limit))))):
			self.endCb(None)
			return
		elif (len(self.items) > 0):
			if (self.maxAtOnce != 1):
				_hx_list = list()
				added = 0
				while (len(self.items) > 0):
					item = None
					_this = self.items
					item = (None if ((len(_this) == 0)) else _this.pop())
					x = item
					_hx_list.append(x)
					_hx_local_0 = self
					_hx_local_1 = _hx_local_0.processed
					_hx_local_0.processed = (_hx_local_1 + 1)
					_hx_local_1
					added = (added + 1)
					if (added == self.maxAtOnce):
						break
				def _hx_local_3():
					haxe_Timer.delay(_g.next,1)
				self.cb(_hx_list,_hx_local_3,self)
			else:
				item1 = None
				_this1 = self.items
				item1 = (None if ((len(_this1) == 0)) else _this1.pop())
				_hx_local_4 = self
				_hx_local_5 = _hx_local_4.processed
				_hx_local_4.processed = (_hx_local_5 + 1)
				_hx_local_5
				def _hx_local_6():
					haxe_Timer.delay(_g.next,1)
				self.cb(item1,_hx_local_6,self)
		else:
			saturn_core_Util.debug("waiting")
			haxe_Timer.delay(self.next,100)

	def count(self):
		return self.processed

	def setMaxAtOnce(self,maxAtOnce):
		self.maxAtOnce = maxAtOnce

	def setLimit(self,limit):
		self.limit = limit

	def onEnd(self,cb):
		self.endCb = cb

	def onNext(self,cb):
		self.cb = cb
		self.next()

	def finished(self):
		self.done = True

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.limit = None
		_hx_o.processed = None
		_hx_o.done = None
		_hx_o.cb = None
		_hx_o.endCb = None
		_hx_o.maxAtOnce = None
		_hx_o.items = None
saturn_core_Generator._hx_class = saturn_core_Generator
_hx_classes["saturn.core.Generator"] = saturn_core_Generator


class saturn_core_LocusPosition:
	_hx_class_name = "saturn.core.LocusPosition"
	_hx_fields = ["start", "end", "missMatchPositions"]

	def __init__(self):
		self.start = None
		self.end = None
		self.missMatchPositions = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.start = None
		_hx_o.end = None
		_hx_o.missMatchPositions = None
saturn_core_LocusPosition._hx_class = saturn_core_LocusPosition
_hx_classes["saturn.core.LocusPosition"] = saturn_core_LocusPosition


class saturn_core_Protein(saturn_core_molecule_Molecule):
	_hx_class_name = "saturn.core.Protein"
	_hx_fields = ["dna", "coordinates", "hydrophobicityLookUp"]
	_hx_methods = ["setSequence", "getHydrophobicity", "setDNA", "dnaSequenceUpdated", "getDNA", "setReferenceCoordinates", "getReferenceCoordinates"]
	_hx_statics = ["_insertGene", "insertTranslation"]
	_hx_interfaces = []
	_hx_super = saturn_core_molecule_Molecule


	def __init__(self,seq):
		self.dna = None
		self.coordinates = None
		self.hydrophobicityLookUp = None
		def _hx_local_0():
			_g = haxe_ds_StringMap()
			_g.h["A"] = 1.8
			_g.h["G"] = -0.4
			_g.h["M"] = 1.9
			_g.h["S"] = -0.8
			_g.h["C"] = 2.5
			_g.h["H"] = -3.2
			_g.h["N"] = -3.5
			_g.h["T"] = -0.7
			_g.h["D"] = -3.5
			_g.h["I"] = 4.5
			_g.h["P"] = -1.6
			_g.h["V"] = 4.2
			_g.h["E"] = -3.5
			_g.h["K"] = -3.9
			_g.h["Q"] = -3.5
			_g.h["W"] = -0.9
			_g.h["F"] = 2.8
			_g.h["L"] = 3.8
			_g.h["R"] = -4.5
			_g.h["Y"] = -1.3
			return _g
		self.hydrophobicityLookUp = _hx_local_0()
		super().__init__(seq)

	def setSequence(self,sequence):
		super().setSequence(sequence)
		if (sequence is not None):
			mSet = saturn_core_molecule_MoleculeSetRegistry.getStandardMoleculeSet()
			mw = mSet.getMolecule("H2O").getFloatAttribute(saturn_core_molecule_MoleculeFloatAttribute.MW)
			_g1 = 0
			_g = len(self.sequence)
			while (_g1 < _g):
				i = _g1
				_g1 = (_g1 + 1)
				def _hx_local_0():
					_this = self.sequence
					return ("" if (((i < 0) or ((i >= len(_this))))) else _this[i])
				molecule = mSet.getMolecule(_hx_local_0())
				if (molecule is not None):
					mw = (mw + molecule.getFloatAttribute(saturn_core_molecule_MoleculeFloatAttribute.MW_CONDESATION))
				else:
					mw = -1
					break
			self.setFloatAttribute(saturn_core_molecule_MoleculeFloatAttribute.MW,mw)
		if self.isLinked():
			d = self.getParent()
			if (d is not None):
				d.proteinSequenceUpdated(self.sequence)

	def getHydrophobicity(self):
		proteinSequence = self.sequence
		seqLength = len(self.sequence)
		totalGravy = 0.0
		averageGravy = 0.0
		_g = 0
		while (_g < seqLength):
			i = _g
			_g = (_g + 1)
			aminoAcid = HxString.substr(proteinSequence,i,1)
			hydroValue = self.hydrophobicityLookUp.h.get(aminoAcid,None)
			totalGravy = (totalGravy + hydroValue)
		averageGravy = (totalGravy / seqLength)
		return averageGravy

	def setDNA(self,dna):
		if (self.dna is not None):
			self.dna.protein.setParent(None)
			self.dna.protein = None
			self.dna.linked = False
			self.dna.setParent(None)
		self.dna = dna
		if (self.dna is not None):
			self.dna.linked = True
			self.dna.protein = self
			self.dna.setParent(self)
			self.linked = True
			if ((dna.getMoleculeName() is None) or ((dna.getMoleculeName() == ""))):
				dna.setMoleculeName((HxOverrides.stringOrNull(self.getMoleculeName()) + " (DNA)"))
		else:
			self.linked = False

	def dnaSequenceUpdated(self,sequence):
		pass

	def getDNA(self):
		return self.dna

	def setReferenceCoordinates(self,coordinates):
		self.coordinates = coordinates

	def getReferenceCoordinates(self):
		return self.coordinates

	@staticmethod
	def _insertGene(geneId,source,cb):
		provider = saturn_core_Util.getProvider()
		def _hx_local_2(obj,err):
			if (err is not None):
				cb(err)
			elif (obj is not None):
				cb(None)
			else:
				gene = saturn_core_domain_Entity()
				gene.entityId = geneId
				gene.source = saturn_core_domain_DataSource()
				gene.source.name = source
				gene.entityType = saturn_core_EntityType()
				gene.entityType.name = "DNA"
				def _hx_local_1(err1,info):
					gene.altName = Reflect.field(info,"symbol")
					gene.description = Reflect.field(info,"description")
					def _hx_local_0(err2):
						cb(err2)
					provider.insertObjects([gene],_hx_local_0)
				saturn_core_EUtils.getGeneInfo(Std.parseInt(geneId),_hx_local_1)
		provider.getById(geneId,saturn_core_domain_Entity,_hx_local_2)

	@staticmethod
	def insertTranslation(dnaId,dnaAltName,dnaSeq,dnaSource,protId,protAltName,protSeq,protSource,geneId,geneSource,cb):
		provider = saturn_core_Util.getProvider()
		def _hx_local_7(err):
			if (err is not None):
				cb(err)
			else:
				dna = saturn_core_domain_Entity()
				dna.entityId = dnaId
				dna.altName = dnaAltName
				dna.source = saturn_core_domain_DataSource()
				dna.source.name = dnaSource
				dna.entityType = saturn_core_EntityType()
				dna.entityType.name = "DNA"
				dna_mol = saturn_core_domain_Molecule()
				dna_mol.entity = dna
				dna_mol.sequence = dnaSeq
				annotation = saturn_core_domain_MoleculeAnnotation()
				annotation.entity = dna
				annotation.referent = saturn_core_domain_Entity()
				annotation.referent.entityId = geneId
				annotation.referent.source = saturn_core_domain_DataSource()
				annotation.referent.source.name = "GENE"
				prot = saturn_core_domain_Entity()
				prot.entityId = protId
				prot.altName = protAltName
				prot.source = saturn_core_domain_DataSource()
				prot.source.name = protSource
				prot.entityType = saturn_core_EntityType()
				prot.entityType.name = "PROTEIN"
				prot_mol = saturn_core_domain_Molecule()
				prot_mol.entity = prot
				prot_mol.sequence = protSeq
				reaction = saturn_core_Reaction()
				reaction.name = (("null" if dnaId is None else dnaId) + "-TRANS")
				reaction.reactionType = saturn_core_ReactionType()
				reaction.reactionType.name = "TRANSLATION"
				prot.reaction = reaction
				reactionComp = saturn_core_ReactionComponent()
				reactionComp.entity = dna
				reactionComp.reactionRole = saturn_core_ReactionRole()
				reactionComp.reactionRole.name = "TEMPLATE"
				reactionComp.reaction = reaction
				reactionComp.position = 1
				def _hx_local_6(err1):
					if (err1 is not None):
						cb(err1)
					else:
						def _hx_local_5(err2):
							if (err2 is not None):
								cb(err2)
							else:
								def _hx_local_4(err3):
									if (err3 is not None):
										cb(err3)
									else:
										def _hx_local_3(err4):
											if (err4 is not None):
												cb(err4)
											else:
												def _hx_local_2(err5):
													if (err5 is not None):
														cb(err5)
													else:
														def _hx_local_1(err6):
															if (err6 is not None):
																cb(err6)
															else:
																def _hx_local_0(err7):
																	if (err7 is not None):
																		saturn_core_Util.debug(err7)
																	cb(err7)
																provider.insertObjects([annotation],_hx_local_0)
														provider.insertObjects([prot_mol],_hx_local_1)
												provider.insertObjects([prot],_hx_local_2)
										provider.insertObjects([reactionComp],_hx_local_3)
								provider.insertObjects([reaction],_hx_local_4)
						provider.insertObjects([dna_mol],_hx_local_5)
				provider.insertObjects([dna],_hx_local_6)
		saturn_core_Protein._insertGene(geneId,geneSource,_hx_local_7)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.dna = None
		_hx_o.coordinates = None
		_hx_o.hydrophobicityLookUp = None
saturn_core_Protein._hx_class = saturn_core_Protein
_hx_classes["saturn.core.Protein"] = saturn_core_Protein


class saturn_core_Reaction:
	_hx_class_name = "saturn.core.Reaction"
	_hx_fields = ["id", "name", "reactionTypeId", "reactionType"]

	def __init__(self):
		self.id = None
		self.name = None
		self.reactionTypeId = None
		self.reactionType = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
		_hx_o.reactionTypeId = None
		_hx_o.reactionType = None
saturn_core_Reaction._hx_class = saturn_core_Reaction
_hx_classes["saturn.core.Reaction"] = saturn_core_Reaction


class saturn_core_ReactionComponent:
	_hx_class_name = "saturn.core.ReactionComponent"
	_hx_fields = ["id", "position", "reactionRoleId", "entityId", "reactionId", "reaction", "reactionRole", "entity"]

	def __init__(self):
		self.id = None
		self.position = None
		self.reactionRoleId = None
		self.entityId = None
		self.reactionId = None
		self.reaction = None
		self.reactionRole = None
		self.entity = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.position = None
		_hx_o.reactionRoleId = None
		_hx_o.entityId = None
		_hx_o.reactionId = None
		_hx_o.reaction = None
		_hx_o.reactionRole = None
		_hx_o.entity = None
saturn_core_ReactionComponent._hx_class = saturn_core_ReactionComponent
_hx_classes["saturn.core.ReactionComponent"] = saturn_core_ReactionComponent


class saturn_core_ReactionRole:
	_hx_class_name = "saturn.core.ReactionRole"
	_hx_fields = ["id", "name"]

	def __init__(self):
		self.id = None
		self.name = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
saturn_core_ReactionRole._hx_class = saturn_core_ReactionRole
_hx_classes["saturn.core.ReactionRole"] = saturn_core_ReactionRole


class saturn_core_ReactionType:
	_hx_class_name = "saturn.core.ReactionType"
	_hx_fields = ["id", "name"]

	def __init__(self):
		self.id = None
		self.name = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
saturn_core_ReactionType._hx_class = saturn_core_ReactionType
_hx_classes["saturn.core.ReactionType"] = saturn_core_ReactionType


class saturn_core_RestrictionSite(saturn_core_DNA):
	_hx_class_name = "saturn.core.RestrictionSite"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self,seq):
		super().__init__(seq)
saturn_core_RestrictionSite._hx_class = saturn_core_RestrictionSite
_hx_classes["saturn.core.RestrictionSite"] = saturn_core_RestrictionSite


class saturn_core_molecule_MoleculeSet:
	_hx_class_name = "saturn.core.molecule.MoleculeSet"
	_hx_fields = ["moleculeSet"]
	_hx_methods = ["setMolecule", "getMolecule"]

	def __init__(self):
		self.moleculeSet = None
		self.moleculeSet = haxe_ds_StringMap()

	def setMolecule(self,name,molecule):
		self.moleculeSet.h[name] = molecule

	def getMolecule(self,name):
		return self.moleculeSet.h.get(name,None)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.moleculeSet = None
saturn_core_molecule_MoleculeSet._hx_class = saturn_core_molecule_MoleculeSet
_hx_classes["saturn.core.molecule.MoleculeSet"] = saturn_core_molecule_MoleculeSet


class saturn_core_StandardMoleculeSet(saturn_core_molecule_MoleculeSet):
	_hx_class_name = "saturn.core.StandardMoleculeSet"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_molecule_MoleculeSet


	def __init__(self):
		super().__init__()
		mMap = [_hx_AnonObject({'NAME': "A", 'MW': 71.0788}), _hx_AnonObject({'NAME': "R", 'MW': 156.1875}), _hx_AnonObject({'NAME': "N", 'MW': 114.1038}), _hx_AnonObject({'NAME': "D", 'MW': 115.0886}), _hx_AnonObject({'NAME': "C", 'MW': 103.1448}), _hx_AnonObject({'NAME': "E", 'MW': 129.1155}), _hx_AnonObject({'NAME': "Q", 'MW': 128.1308}), _hx_AnonObject({'NAME': "G", 'MW': 57.052}), _hx_AnonObject({'NAME': "H", 'MW': 137.1412}), _hx_AnonObject({'NAME': "I", 'MW': 113.1595}), _hx_AnonObject({'NAME': "L", 'MW': 113.1595}), _hx_AnonObject({'NAME': "K", 'MW': 128.1742}), _hx_AnonObject({'NAME': "M", 'MW': 131.1986}), _hx_AnonObject({'NAME': "F", 'MW': 147.1766}), _hx_AnonObject({'NAME': "P", 'MW': 97.1167}), _hx_AnonObject({'NAME': "S", 'MW': 87.0782}), _hx_AnonObject({'NAME': "T", 'MW': 101.1051}), _hx_AnonObject({'NAME': "W", 'MW': 186.2133}), _hx_AnonObject({'NAME': "Y", 'MW': 163.176}), _hx_AnonObject({'NAME': "V", 'MW': 99.1326})]
		_g = 0
		while (_g < len(mMap)):
			mDef = (mMap[_g] if _g >= 0 and _g < len(mMap) else None)
			_g = (_g + 1)
			m = saturn_core_molecule_Molecule(mDef.NAME)
			m.setFloatAttribute(saturn_core_molecule_MoleculeFloatAttribute.MW_CONDESATION,mDef.MW)
			m.setStringAttribute(saturn_core_molecule_MoleculeStringAttribute.NAME,mDef.NAME)
			self.setMolecule(mDef.NAME,m)
		mMap = [_hx_AnonObject({'NAME': "H2O", 'MW': 18.02})]
		_g1 = 0
		while (_g1 < len(mMap)):
			mDef1 = (mMap[_g1] if _g1 >= 0 and _g1 < len(mMap) else None)
			_g1 = (_g1 + 1)
			m1 = saturn_core_molecule_Molecule(mDef1.NAME)
			m1.setFloatAttribute(saturn_core_molecule_MoleculeFloatAttribute.MW,mDef1.MW)
			m1.setStringAttribute(saturn_core_molecule_MoleculeStringAttribute.NAME,mDef1.NAME)
			self.setMolecule(mDef1.NAME,m1)
saturn_core_StandardMoleculeSet._hx_class = saturn_core_StandardMoleculeSet
_hx_classes["saturn.core.StandardMoleculeSet"] = saturn_core_StandardMoleculeSet


class saturn_core_TmCalc:
	_hx_class_name = "saturn.core.TmCalc"
	_hx_fields = ["deltaHTable", "deltaSTable", "endHTable", "endSTable"]
	_hx_methods = ["populateDeltaHTable", "populateDeltaSTable", "populateEndHTable", "populateEndSTable", "getDeltaH", "getDeltaS", "saltCorrection", "tmCalculation"]

	def __init__(self):
		self.deltaHTable = None
		self.deltaSTable = None
		self.endHTable = None
		self.endSTable = None
		self.deltaHTable = haxe_ds_StringMap()
		self.deltaSTable = haxe_ds_StringMap()
		self.endHTable = haxe_ds_StringMap()
		self.endSTable = haxe_ds_StringMap()
		self.populateDeltaHTable()
		self.populateDeltaSTable()
		self.populateEndHTable()
		self.populateEndSTable()

	def populateDeltaHTable(self):
		self.deltaHTable.h["AA"] = -7900
		self.deltaHTable.h["TT"] = -7900
		self.deltaHTable.h["AT"] = -7200
		self.deltaHTable.h["TA"] = -7200
		self.deltaHTable.h["CA"] = -8500
		self.deltaHTable.h["TG"] = -8500
		self.deltaHTable.h["GT"] = -8400
		self.deltaHTable.h["AC"] = -8400
		self.deltaHTable.h["CT"] = -7800
		self.deltaHTable.h["AG"] = -7800
		self.deltaHTable.h["GA"] = -8200
		self.deltaHTable.h["TC"] = -8200
		self.deltaHTable.h["CG"] = -10600
		self.deltaHTable.h["GC"] = -9800
		self.deltaHTable.h["GG"] = -8000
		self.deltaHTable.h["CC"] = -8000

	def populateDeltaSTable(self):
		self.deltaSTable.h["AA"] = -22.2
		self.deltaSTable.h["TT"] = -22.2
		self.deltaSTable.h["AT"] = -20.4
		self.deltaSTable.h["TA"] = -21.3
		self.deltaSTable.h["CA"] = -22.7
		self.deltaSTable.h["TG"] = -22.7
		self.deltaSTable.h["GT"] = -22.4
		self.deltaSTable.h["AC"] = -22.4
		self.deltaSTable.h["CT"] = -21.0
		self.deltaSTable.h["AG"] = -21.0
		self.deltaSTable.h["GA"] = -22.2
		self.deltaSTable.h["TC"] = -22.2
		self.deltaSTable.h["CG"] = -27.2
		self.deltaSTable.h["GC"] = -24.4
		self.deltaSTable.h["GG"] = -19.9
		self.deltaSTable.h["CC"] = -19.9

	def populateEndHTable(self):
		self.endHTable.h["A"] = 2300
		self.endHTable.h["T"] = 2300
		self.endHTable.h["G"] = 100
		self.endHTable.h["C"] = 100

	def populateEndSTable(self):
		self.endSTable.h["A"] = 4.1
		self.endSTable.h["T"] = 4.1
		self.endSTable.h["G"] = -2.8
		self.endSTable.h["C"] = -2.8

	def getDeltaH(self,primerSeq):
		dnaSeq = primerSeq.getSequence()
		seqLen = len(dnaSeq)
		startNuc = None
		if (0 >= len(dnaSeq)):
			startNuc = ""
		else:
			startNuc = dnaSeq[0]
		endNuc = None
		index = (seqLen - 1)
		if ((index < 0) or ((index >= len(dnaSeq)))):
			endNuc = ""
		else:
			endNuc = dnaSeq[index]
		startH = self.endHTable.h.get(startNuc,None)
		endH = self.endHTable.h.get(endNuc,None)
		deltaH = (startH + endH)
		_g = 1
		while (_g < seqLen):
			i = _g
			_g = (_g + 1)
			currNuc = None
			if ((i < 0) or ((i >= len(dnaSeq)))):
				currNuc = ""
			else:
				currNuc = dnaSeq[i]
			currH = self.deltaHTable.h.get((("null" if startNuc is None else startNuc) + ("null" if currNuc is None else currNuc)),None)
			startNuc = currNuc
			deltaH = (deltaH + currH)
		return deltaH

	def getDeltaS(self,primerSeq):
		dnaSeq = primerSeq.getSequence()
		seqLen = len(dnaSeq)
		startNuc = None
		if (0 >= len(dnaSeq)):
			startNuc = ""
		else:
			startNuc = dnaSeq[0]
		endNuc = None
		index = (seqLen - 1)
		if ((index < 0) or ((index >= len(dnaSeq)))):
			endNuc = ""
		else:
			endNuc = dnaSeq[index]
		startS = self.endSTable.h.get(startNuc,None)
		endS = self.endSTable.h.get(endNuc,None)
		deltaS = (startS + endS)
		_g = 1
		while (_g < seqLen):
			i = _g
			_g = (_g + 1)
			currNuc = None
			if ((i < 0) or ((i >= len(dnaSeq)))):
				currNuc = ""
			else:
				currNuc = dnaSeq[i]
			currS = self.deltaSTable.h.get((("null" if startNuc is None else startNuc) + ("null" if currNuc is None else currNuc)),None)
			startNuc = currNuc
			deltaS = (deltaS + currS)
		return deltaS

	def saltCorrection(self,primerSeq,saltConc):
		saltPenalty = 0.368
		dnaSeq = primerSeq.getSequence()
		seqLen = len(dnaSeq)
		saltConc = (saltConc / 1000.0)
		lnSalt = None
		if (saltConc == 0.0):
			lnSalt = Math.NEGATIVE_INFINITY
		elif (saltConc < 0.0):
			lnSalt = Math.NaN
		else:
			lnSalt = python_lib_Math.log(saltConc)
		deltaS = self.getDeltaS(primerSeq)
		saltCorrDeltaS = (deltaS + (((saltPenalty * ((seqLen - 1))) * lnSalt)))
		return saltCorrDeltaS

	def tmCalculation(self,primerSeq,saltConc,primerConc):
		deltaH = self.getDeltaH(primerSeq)
		saltCorrDeltaS = self.saltCorrection(primerSeq,saltConc)
		gasConst = 1.987
		lnPrimerConc = None
		v = ((primerConc / 1000000000) / 2)
		if (v == 0.0):
			lnPrimerConc = Math.NEGATIVE_INFINITY
		elif (v < 0.0):
			lnPrimerConc = Math.NaN
		else:
			lnPrimerConc = python_lib_Math.log(v)
		tmKelvin = (deltaH / ((saltCorrDeltaS + ((gasConst * lnPrimerConc)))))
		tmCelcius = (tmKelvin - 273.15)
		if (tmCelcius > 75):
			return 75
		else:
			return tmCelcius

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.deltaHTable = None
		_hx_o.deltaSTable = None
		_hx_o.endHTable = None
		_hx_o.endSTable = None
saturn_core_TmCalc._hx_class = saturn_core_TmCalc
_hx_classes["saturn.core.TmCalc"] = saturn_core_TmCalc


class saturn_core_User:
	_hx_class_name = "saturn.core.User"
	_hx_fields = ["id", "username", "password", "firstname", "lastname", "email", "fullname", "uuid", "token", "projects"]

	def __init__(self):
		self.id = None
		self.username = None
		self.password = None
		self.firstname = None
		self.lastname = None
		self.email = None
		self.fullname = None
		self.uuid = None
		self.token = None
		self.projects = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.username = None
		_hx_o.password = None
		_hx_o.firstname = None
		_hx_o.lastname = None
		_hx_o.email = None
		_hx_o.fullname = None
		_hx_o.uuid = None
		_hx_o.token = None
		_hx_o.projects = None
saturn_core_User._hx_class = saturn_core_User
_hx_classes["saturn.core.User"] = saturn_core_User


class saturn_core_Util:
	_hx_class_name = "saturn.core.Util"
	_hx_statics = ["debug", "inspect", "print", "openw", "opentemp", "isHostEnvironmentAvailable", "exec", "getNewExternalProcess", "getNewFileDialog", "saveFileAsDialog", "saveFile", "jsImports", "jsImport", "openFileAsDialog", "readFile", "open", "getProvider", "string", "clone"]

	def __init__(self):
		pass

	@staticmethod
	def debug(msg):
		saturn_core_Util.print(msg)

	@staticmethod
	def inspect(obj):
		pass

	@staticmethod
	def print(msg):
		pass

	@staticmethod
	def openw(path):
		return None

	@staticmethod
	def opentemp(prefix,cb):
		pass

	@staticmethod
	def isHostEnvironmentAvailable():
		return False

	@staticmethod
	def _hx_exec(program,args,cb):
		pass

	@staticmethod
	def getNewExternalProcess(cb):
		pass

	@staticmethod
	def getNewFileDialog(cb):
		pass

	@staticmethod
	def saveFileAsDialog(contents,cb):
		pass

	@staticmethod
	def saveFile(fileName,contents,cb):
		pass

	@staticmethod
	def jsImports(paths,cb):
		errs = haxe_ds_StringMap()
		next = None
		def _hx_local_1():
			if (len(paths) == 0):
				cb(errs)
			else:
				path = None
				path = (None if ((len(paths) == 0)) else paths.pop())
				def _hx_local_0(err):
					errs.h[path] = err
					next()
				saturn_core_Util.jsImport(path,_hx_local_0)
		next = _hx_local_1
		next()

	@staticmethod
	def jsImport(path,cb):
		pass

	@staticmethod
	def openFileAsDialog(cb):
		pass

	@staticmethod
	def readFile(fileName,cb):
		pass

	@staticmethod
	def open(path,cb):
		pass

	@staticmethod
	def getProvider():
		return saturn_client_core_CommonCore.getDefaultProvider()

	@staticmethod
	def string(a):
		return Std.string(a)

	@staticmethod
	def clone(obj):
		ser = haxe_Serializer.run(obj)
		return haxe_Unserializer.run(ser)
saturn_core_Util._hx_class = saturn_core_Util
_hx_classes["saturn.core.Util"] = saturn_core_Util


class saturn_core_Stream:
	_hx_class_name = "saturn.core.Stream"
	_hx_fields = ["streamId"]
	_hx_methods = ["write", "end"]

	def __init__(self,streamId):
		self.streamId = None
		self.streamId = streamId

	def write(self,content):
		pass

	def end(self,cb):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.streamId = None
saturn_core_Stream._hx_class = saturn_core_Stream
_hx_classes["saturn.core.Stream"] = saturn_core_Stream


class saturn_core_domain_Compound:
	_hx_class_name = "saturn.core.domain.Compound"
	_hx_fields = ["id", "compoundId", "supplierId", "shortCompoundId", "sdf", "supplier", "description", "concentration", "location", "solute", "comments", "mw", "confidential", "datestamp", "person", "inchi", "smiles"]
	_hx_methods = ["setup", "substructureSearch", "assaySearch", "test"]
	_hx_statics = ["molCache", "r", "rw", "rh", "appendMolImage", "getMolImage", "clearMolCache"]

	def __init__(self):
		self.id = None
		self.compoundId = None
		self.supplierId = None
		self.shortCompoundId = None
		self.sdf = None
		self.supplier = None
		self.description = None
		self.concentration = None
		self.location = None
		self.solute = None
		self.comments = None
		self.mw = None
		self.confidential = None
		self.datestamp = None
		self.person = None
		self.inchi = None
		self.smiles = None

	def setup(self):
		pass

	def substructureSearch(self,cb):
		pass

	def assaySearch(self,cb):
		pass

	def test(self,cb):
		pass

	@staticmethod
	def appendMolImage(objs,structureField,outputField,format):
		_g = 0
		while (_g < len(objs)):
			row = (objs[_g] if _g >= 0 and _g < len(objs) else None)
			_g = (_g + 1)
			value = Reflect.field(row,structureField)
			if ((value == "") or ((value is None))):
				value = ""
			else:
				s = saturn_core_domain_Compound.getMolImage(value,format)
				value = s
			setattr(row,(("_hx_" + outputField) if (outputField in python_Boot.keywords) else (("_hx_" + outputField) if (((((len(outputField) > 2) and ((ord(outputField[0]) == 95))) and ((ord(outputField[1]) == 95))) and ((ord(outputField[(len(outputField) - 1)]) != 95)))) else outputField)),value)

	@staticmethod
	def getMolImage(value,format):
		if (not format in saturn_core_domain_Compound.molCache.h):
			value1 = haxe_ds_StringMap()
			saturn_core_domain_Compound.molCache.h[format] = value1
		def _hx_local_0():
			this1 = saturn_core_domain_Compound.molCache.h.get(format,None)
			return this1.exists(value)
		if (not _hx_local_0()):
			try:
				rdkit = __js__("RDKit")
				mol = None
				if (format == "SDF"):
					mol = rdkit.Molecule.MolBlockToMol(value)
				else:
					mol = rdkit.Molecule.fromSmiles(value)
				Reflect.field(mol,"Kekulize")()
				s = Reflect.field(mol,"Drawing2D")()
				s = saturn_core_domain_Compound.r.replace(s,"")
				s = saturn_core_domain_Compound.rw.replace(s,"width=\"100%\"")
				s = saturn_core_domain_Compound.rh.replace(s,"height=\"100%\" viewBox=\"0 0 300 300\"")
				this2 = saturn_core_domain_Compound.molCache.h.get(format,None)
				this2.set(value,s)
			except Exception as _hx_e:
				_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
				err = _hx_e1
				this3 = saturn_core_domain_Compound.molCache.h.get(format,None)
				this3.set(value,None)
		this4 = saturn_core_domain_Compound.molCache.h.get(format,None)
		return this4.get(value)

	@staticmethod
	def clearMolCache():
		_hx_local_2 = saturn_core_domain_Compound.molCache.keys()
		while _hx_local_2.hasNext():
			format = _hx_local_2.next()
			def _hx_local_0():
				this1 = saturn_core_domain_Compound.molCache.h.get(format,None)
				return this1.keys()
			_hx_local_1 = _hx_local_0()
			while _hx_local_1.hasNext():
				key = _hx_local_1.next()
				this2 = saturn_core_domain_Compound.molCache.h.get(format,None)
				this2.remove(key)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.compoundId = None
		_hx_o.supplierId = None
		_hx_o.shortCompoundId = None
		_hx_o.sdf = None
		_hx_o.supplier = None
		_hx_o.description = None
		_hx_o.concentration = None
		_hx_o.location = None
		_hx_o.solute = None
		_hx_o.comments = None
		_hx_o.mw = None
		_hx_o.confidential = None
		_hx_o.datestamp = None
		_hx_o.person = None
		_hx_o.inchi = None
		_hx_o.smiles = None
saturn_core_domain_Compound._hx_class = saturn_core_domain_Compound
_hx_classes["saturn.core.domain.Compound"] = saturn_core_domain_Compound


class saturn_core_domain_DataSource:
	_hx_class_name = "saturn.core.domain.DataSource"
	_hx_fields = ["id", "name"]
	_hx_statics = ["getEntities", "getSource"]

	def __init__(self):
		self.id = None
		self.name = None

	@staticmethod
	def getEntities(source,cb):
		p = saturn_core_Util.getProvider()
		def _hx_local_1(obj,err):
			if (err is not None):
				cb(err,None)
			elif (obj is None):
				cb(("Data source not found " + ("null" if source is None else source)),None)
			else:
				saturn_core_Util.debug(("Retreiving records for source " + ("null" if source is None else source)))
				def _hx_local_0(objs,error):
					saturn_core_Util.debug(("Entities retrieved for source " + ("null" if source is None else source)))
					if (error is not None):
						cb(((("An error occurred retrieving data source " + ("null" if source is None else source)) + " entities\n") + ("null" if error is None else error)),None)
					else:
						cb(None,objs)
				p.getByValues([saturn_core_Util.string(obj.id)],saturn_core_domain_Entity,"dataSourceId",_hx_local_0)
		p.getById(source,saturn_core_domain_DataSource,_hx_local_1)

	@staticmethod
	def getSource(source,insert,cb):
		p = saturn_core_Util.getProvider()
		def _hx_local_2(obj,err):
			if (err is not None):
				cb(((("An error occurred looking for source: " + ("null" if source is None else source)) + "\n") + ("null" if err is None else err)),None)
			elif (obj is None):
				if insert:
					obj1 = saturn_core_domain_DataSource()
					obj1.name = source
					def _hx_local_1(err1):
						if (err1 is not None):
							cb(((("An error occurred inserting source: " + ("null" if source is None else source)) + "\n") + ("null" if err1 is None else err1)),None)
						else:
							def _hx_local_0(obj2,err2):
								if (err2 is not None):
									cb(((("An error occurred looking for source: " + ("null" if source is None else source)) + "\n") + ("null" if err2 is None else err2)),None)
								elif (obj2 is None):
									cb((("Inserted source " + ("null" if source is None else source)) + " could not be found"),None)
								else:
									cb(None,obj2)
							p.getById(source,saturn_core_domain_DataSource,_hx_local_0)
					p.insert(source,_hx_local_1)
				else:
					cb(None,None)
			else:
				cb(None,obj)
		p.getById(source,saturn_core_domain_DataSource,_hx_local_2)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
saturn_core_domain_DataSource._hx_class = saturn_core_domain_DataSource
_hx_classes["saturn.core.domain.DataSource"] = saturn_core_domain_DataSource


class saturn_core_domain_Entity:
	_hx_class_name = "saturn.core.domain.Entity"
	_hx_fields = ["id", "entityId", "dataSourceId", "reactionId", "entityTypeId", "altName", "description", "source", "reaction", "entityType"]
	_hx_statics = ["insertList", "getObjects"]

	def __init__(self):
		self.id = None
		self.entityId = None
		self.dataSourceId = None
		self.reactionId = None
		self.entityTypeId = None
		self.altName = None
		self.description = None
		self.source = None
		self.reaction = None
		self.entityType = None

	@staticmethod
	def insertList(ids,source,cb):
		uqx = haxe_ds_StringMap()
		_g = 0
		while (_g < len(ids)):
			id = (ids[_g] if _g >= 0 and _g < len(ids) else None)
			_g = (_g + 1)
			uqx.h[id] = id
		ids = list()
		_hx_local_1 = uqx.keys()
		while _hx_local_1.hasNext():
			id1 = _hx_local_1.next()
			ids.append(id1)
		def _hx_local_5(err,sourceObj):
			if (err is not None):
				cb(err,None)
			elif (sourceObj is None):
				cb(("Unable to find source " + ("null" if source is None else source)),None)
			else:
				objs = list()
				_g1 = 0
				while (_g1 < len(ids)):
					id2 = (ids[_g1] if _g1 >= 0 and _g1 < len(ids) else None)
					_g1 = (_g1 + 1)
					entity = saturn_core_domain_Entity()
					entity.entityId = id2
					entity.dataSourceId = sourceObj.id
					objs.append(entity)
				p = saturn_core_Util.getProvider()
				def _hx_local_4(err1):
					if (err1 is not None):
						cb(("An error occurred inserting entities\n" + ("null" if err1 is None else err1)),None)
					else:
						def _hx_local_3(objs1,err2):
							if (err2 is not None):
								cb(("An error occurred looking for inserted objects\n" + ("null" if err2 is None else err2)),None)
							else:
								cb(None,objs1)
						p.getByIds(ids,saturn_core_domain_Entity,_hx_local_3)
				p.insertObjects(objs,_hx_local_4)
		saturn_core_domain_DataSource.getSource(source,False,_hx_local_5)

	@staticmethod
	def getObjects(ids,cb):
		p = saturn_core_Util.getProvider()
		def _hx_local_0(objs,err):
			if (err is not None):
				cb(err,None)
			else:
				cb(None,objs)
		p.getByIds(ids,saturn_core_domain_Entity,_hx_local_0)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.entityId = None
		_hx_o.dataSourceId = None
		_hx_o.reactionId = None
		_hx_o.entityTypeId = None
		_hx_o.altName = None
		_hx_o.description = None
		_hx_o.source = None
		_hx_o.reaction = None
		_hx_o.entityType = None
saturn_core_domain_Entity._hx_class = saturn_core_domain_Entity
_hx_classes["saturn.core.domain.Entity"] = saturn_core_domain_Entity


class saturn_core_domain_FileProxy:
	_hx_class_name = "saturn.core.domain.FileProxy"
	_hx_fields = ["path"]

	def __init__(self):
		self.path = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.path = None
saturn_core_domain_FileProxy._hx_class = saturn_core_domain_FileProxy
_hx_classes["saturn.core.domain.FileProxy"] = saturn_core_domain_FileProxy


class saturn_core_domain_Molecule:
	_hx_class_name = "saturn.core.domain.Molecule"
	_hx_fields = ["id", "name", "sequence", "entityId", "entity"]

	def __init__(self):
		self.id = None
		self.name = None
		self.sequence = None
		self.entityId = None
		self.entity = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
		_hx_o.sequence = None
		_hx_o.entityId = None
		_hx_o.entity = None
saturn_core_domain_Molecule._hx_class = saturn_core_domain_Molecule
_hx_classes["saturn.core.domain.Molecule"] = saturn_core_domain_Molecule


class saturn_core_domain_MoleculeAnnotation:
	_hx_class_name = "saturn.core.domain.MoleculeAnnotation"
	_hx_fields = ["id", "entityId", "labelId", "start", "stop", "evalue", "altevalue", "entity", "referent"]

	def __init__(self):
		self.id = None
		self.entityId = None
		self.labelId = None
		self.start = None
		self.stop = None
		self.evalue = None
		self.altevalue = None
		self.entity = None
		self.referent = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.entityId = None
		_hx_o.labelId = None
		_hx_o.start = None
		_hx_o.stop = None
		_hx_o.evalue = None
		_hx_o.altevalue = None
		_hx_o.entity = None
		_hx_o.referent = None
saturn_core_domain_MoleculeAnnotation._hx_class = saturn_core_domain_MoleculeAnnotation
_hx_classes["saturn.core.domain.MoleculeAnnotation"] = saturn_core_domain_MoleculeAnnotation


class saturn_core_domain_Uploader:
	_hx_class_name = "saturn.core.domain.Uploader"
	_hx_fields = ["referentMap", "provider", "generator", "initialised", "source", "cutoff"]
	_hx_methods = ["next", "setupReferentMap", "insertReferents"]

	def __init__(self,source,evalue):
		self.referentMap = None
		self.provider = None
		self.generator = None
		self.initialised = None
		self.source = None
		self.cutoff = None
		self.initialised = False
		self.source = source
		self.cutoff = evalue

	def next(self,items,generator):
		_g = self
		self.generator = generator
		if (self.initialised == False):
			self.provider = saturn_core_Util.getProvider()
			def _hx_local_0(err):
				if (err is not None):
					generator.die(err)
				else:
					_g.initialised = True
					_g.next(items,generator)
			self.setupReferentMap(_hx_local_0)
		else:
			if (len(items) == 0):
				return
			ids = saturn_db_Model.generateUniqueListWithField(items,"entity.entityId")
			acList = saturn_db_Model.generateUniqueListWithField(items,"referent.entityId")
			newReferents = list()
			_g1 = 0
			while (_g1 < len(acList)):
				id = (acList[_g1] if _g1 >= 0 and _g1 < len(acList) else None)
				_g1 = (_g1 + 1)
				if (not id in self.referentMap.h):
					newReferents.append(id)
			_g2 = 0
			while (_g2 < len(items)):
				item = (items[_g2] if _g2 >= 0 and _g2 < len(items) else None)
				_g2 = (_g2 + 1)
				if (item.evalue > self.cutoff):
					python_internal_ArrayImpl.remove(items,item)
			def _hx_local_4(err1):
				if (err1 is not None):
					generator.die(err1)
				else:
					def _hx_local_3(err2):
						if (err2 is not None):
							generator.die(err2)
						else:
							generator.next()
					_g.provider.insertObjects(items,_hx_local_3)
			self.insertReferents(newReferents,_hx_local_4)

	def setupReferentMap(self,cb):
		_g = self
		def _hx_local_0(err,objs):
			if (err is not None):
				cb(err)
			else:
				_g.referentMap = saturn_db_Model.generateIDMap(objs)
				cb(None)
		saturn_core_domain_DataSource.getEntities(self.source,_hx_local_0)

	def insertReferents(self,accessions,cb):
		_g1 = self
		if (len(accessions) == 0):
			cb(None)
		else:
			def _hx_local_1(err,objs):
				if (err is None):
					_g = 0
					while (_g < len(objs)):
						obj = (objs[_g] if _g >= 0 and _g < len(objs) else None)
						_g = (_g + 1)
						_g1.referentMap.h[obj.entityId] = obj.id
				cb(err)
			saturn_core_domain_Entity.insertList(accessions,self.source,_hx_local_1)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.referentMap = None
		_hx_o.provider = None
		_hx_o.generator = None
		_hx_o.initialised = None
		_hx_o.source = None
		_hx_o.cutoff = None
saturn_core_domain_Uploader._hx_class = saturn_core_domain_Uploader
_hx_classes["saturn.core.domain.Uploader"] = saturn_core_domain_Uploader


class saturn_core_domain_SaturnSession:
	_hx_class_name = "saturn.core.domain.SaturnSession"
	_hx_fields = ["id", "userName", "isPublic", "sessionContent", "sessionName", "user"]
	_hx_methods = ["load", "getShortDescription"]

	def __init__(self):
		self.id = None
		self.userName = None
		self.isPublic = None
		self.sessionContent = None
		self.sessionName = None
		self.user = None

	def load(self,cb):
		pass

	def getShortDescription(self):
		if (self.user is not None):
			def _hx_local_1():
				def _hx_local_0():
					_this = self.sessionName
					return _this.split("-")
				return ((HxOverrides.stringOrNull(self.user.fullname) + " - ") + HxOverrides.stringOrNull(python_internal_ArrayImpl._get((_hx_local_0()), 1)))
			return _hx_local_1()
		else:
			return self.sessionName

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.userName = None
		_hx_o.isPublic = None
		_hx_o.sessionContent = None
		_hx_o.sessionName = None
		_hx_o.user = None
saturn_core_domain_SaturnSession._hx_class = saturn_core_domain_SaturnSession
_hx_classes["saturn.core.domain.SaturnSession"] = saturn_core_domain_SaturnSession


class saturn_core_domain_SgcAllele(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.SgcAllele"
	_hx_fields = ["alleleId", "id", "entryCloneId", "forwardPrimerId", "reversePrimerId", "dnaSeq", "proteinSeq", "plateWell", "plate", "entryClone", "elnId", "alleleStatus", "forwardPrimer", "reversePrimer"]
	_hx_methods = ["setup", "getMoleculeName", "setSequence"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.alleleId = None
		self.id = None
		self.entryCloneId = None
		self.forwardPrimerId = None
		self.reversePrimerId = None
		self.dnaSeq = None
		self.proteinSeq = None
		self.plateWell = None
		self.plate = None
		self.entryClone = None
		self.elnId = None
		self.alleleStatus = None
		self.forwardPrimer = None
		self.reversePrimer = None
		super().__init__(None)
		self.setup()

	def setup(self):
		self.setSequence(self.dnaSeq)
		self.linkedOriginField = "proteinSeq"
		self.sequenceField = "dnaSeq"
		self.setProtein(saturn_core_Protein(self.proteinSeq))

	def getMoleculeName(self):
		return self.alleleId

	def setSequence(self,sequence):
		super().setSequence(sequence)
		self.dnaSeq = sequence

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.alleleId = None
		_hx_o.id = None
		_hx_o.entryCloneId = None
		_hx_o.forwardPrimerId = None
		_hx_o.reversePrimerId = None
		_hx_o.dnaSeq = None
		_hx_o.proteinSeq = None
		_hx_o.plateWell = None
		_hx_o.plate = None
		_hx_o.entryClone = None
		_hx_o.elnId = None
		_hx_o.alleleStatus = None
		_hx_o.forwardPrimer = None
		_hx_o.reversePrimer = None
saturn_core_domain_SgcAllele._hx_class = saturn_core_domain_SgcAllele
_hx_classes["saturn.core.domain.SgcAllele"] = saturn_core_domain_SgcAllele


class saturn_core_domain_SgcAllelePlate:
	_hx_class_name = "saturn.core.domain.SgcAllelePlate"
	_hx_fields = ["plateName", "id", "elnRef"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.plateName = None
		self.id = None
		self.elnRef = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.plateName = None
		_hx_o.id = None
		_hx_o.elnRef = None
saturn_core_domain_SgcAllelePlate._hx_class = saturn_core_domain_SgcAllelePlate
_hx_classes["saturn.core.domain.SgcAllelePlate"] = saturn_core_domain_SgcAllelePlate


class saturn_core_domain_SgcClone:
	_hx_class_name = "saturn.core.domain.SgcClone"
	_hx_fields = ["id", "cloneId", "constructId", "construct", "elnId", "comments"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.cloneId = None
		self.constructId = None
		self.construct = None
		self.elnId = None
		self.comments = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.cloneId = None
		_hx_o.constructId = None
		_hx_o.construct = None
		_hx_o.elnId = None
		_hx_o.comments = None
saturn_core_domain_SgcClone._hx_class = saturn_core_domain_SgcClone
_hx_classes["saturn.core.domain.SgcClone"] = saturn_core_domain_SgcClone


class saturn_core_domain_SgcConstruct(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.SgcConstruct"
	_hx_fields = ["constructId", "id", "proteinSeq", "proteinSeqNoTag", "dnaSeq", "docId", "vectorId", "alleleId", "constructStart", "constructStop", "vector", "person", "status", "allele", "wellId", "constructPlate", "res1", "res2", "expectedMassNoTag", "expectedMass", "elnId", "constructComments"]
	_hx_methods = ["setup", "getMoleculeName", "setSequence"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.constructId = None
		self.id = None
		self.proteinSeq = None
		self.proteinSeqNoTag = None
		self.dnaSeq = None
		self.docId = None
		self.vectorId = None
		self.alleleId = None
		self.constructStart = None
		self.constructStop = None
		self.vector = None
		self.person = None
		self.status = None
		self.allele = None
		self.wellId = None
		self.constructPlate = None
		self.res1 = None
		self.res2 = None
		self.expectedMassNoTag = None
		self.expectedMass = None
		self.elnId = None
		self.constructComments = None
		super().__init__(None)
		self.setup()

	def setup(self):
		self.setSequence(self.dnaSeq)
		self.sequenceField = "dnaSeq"
		self.linkedOriginField = "proteinSeqNoTag"
		self.setProtein(saturn_core_Protein(self.proteinSeqNoTag))

	def getMoleculeName(self):
		return self.constructId

	def setSequence(self,sequence):
		super().setSequence(sequence)
		self.dnaSeq = sequence

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.constructId = None
		_hx_o.id = None
		_hx_o.proteinSeq = None
		_hx_o.proteinSeqNoTag = None
		_hx_o.dnaSeq = None
		_hx_o.docId = None
		_hx_o.vectorId = None
		_hx_o.alleleId = None
		_hx_o.constructStart = None
		_hx_o.constructStop = None
		_hx_o.vector = None
		_hx_o.person = None
		_hx_o.status = None
		_hx_o.allele = None
		_hx_o.wellId = None
		_hx_o.constructPlate = None
		_hx_o.res1 = None
		_hx_o.res2 = None
		_hx_o.expectedMassNoTag = None
		_hx_o.expectedMass = None
		_hx_o.elnId = None
		_hx_o.constructComments = None
saturn_core_domain_SgcConstruct._hx_class = saturn_core_domain_SgcConstruct
_hx_classes["saturn.core.domain.SgcConstruct"] = saturn_core_domain_SgcConstruct


class saturn_core_domain_SgcConstructPlate:
	_hx_class_name = "saturn.core.domain.SgcConstructPlate"
	_hx_fields = ["plateName", "id", "elnRef"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.plateName = None
		self.id = None
		self.elnRef = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.plateName = None
		_hx_o.id = None
		_hx_o.elnRef = None
saturn_core_domain_SgcConstructPlate._hx_class = saturn_core_domain_SgcConstructPlate
_hx_classes["saturn.core.domain.SgcConstructPlate"] = saturn_core_domain_SgcConstructPlate


class saturn_core_domain_SgcConstructStatus:
	_hx_class_name = "saturn.core.domain.SgcConstructStatus"
	_hx_fields = ["constructPkey", "status"]
	_hx_methods = ["setup"]

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.constructPkey = None
		_hx_o.status = None
saturn_core_domain_SgcConstructStatus._hx_class = saturn_core_domain_SgcConstructStatus
_hx_classes["saturn.core.domain.SgcConstructStatus"] = saturn_core_domain_SgcConstructStatus


class saturn_core_domain_SgcDomain:
	_hx_class_name = "saturn.core.domain.SgcDomain"
	_hx_fields = ["id", "accession", "start", "stop", "targetId"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.accession = None
		self.start = None
		self.stop = None
		self.targetId = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.accession = None
		_hx_o.start = None
		_hx_o.stop = None
		_hx_o.targetId = None
saturn_core_domain_SgcDomain._hx_class = saturn_core_domain_SgcDomain
_hx_classes["saturn.core.domain.SgcDomain"] = saturn_core_domain_SgcDomain


class saturn_core_domain_SgcEntryClone(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.SgcEntryClone"
	_hx_fields = ["entryCloneId", "id", "dnaSeq", "target", "seqSource", "sourceId", "sequenceConfirmed", "elnId"]
	_hx_methods = ["getMoleculeName", "setup", "setSequence", "loadTranslation"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.entryCloneId = None
		self.id = None
		self.dnaSeq = None
		self.target = None
		self.seqSource = None
		self.sourceId = None
		self.sequenceConfirmed = None
		self.elnId = None
		super().__init__(None)
		self.setup()

	def getMoleculeName(self):
		return self.entryCloneId

	def setup(self):
		self.setSequence(self.dnaSeq)
		self.setProtein(saturn_core_Protein(self.getFrameTranslation(saturn_core_GeneticCodes.STANDARD,saturn_core_Frame.ONE)))

	def setSequence(self,sequence):
		super().setSequence(sequence)
		self.dnaSeq = sequence
		self.setProtein(saturn_core_Protein(self.getFrameTranslation(saturn_core_GeneticCodes.STANDARD,saturn_core_Frame.ONE)))

	def loadTranslation(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.entryCloneId = None
		_hx_o.id = None
		_hx_o.dnaSeq = None
		_hx_o.target = None
		_hx_o.seqSource = None
		_hx_o.sourceId = None
		_hx_o.sequenceConfirmed = None
		_hx_o.elnId = None
saturn_core_domain_SgcEntryClone._hx_class = saturn_core_domain_SgcEntryClone
_hx_classes["saturn.core.domain.SgcEntryClone"] = saturn_core_domain_SgcEntryClone


class saturn_core_domain_SgcExpression:
	_hx_class_name = "saturn.core.domain.SgcExpression"
	_hx_fields = ["id", "expressionId", "cloneId", "clone", "elnId", "comments"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.expressionId = None
		self.cloneId = None
		self.clone = None
		self.elnId = None
		self.comments = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.expressionId = None
		_hx_o.cloneId = None
		_hx_o.clone = None
		_hx_o.elnId = None
		_hx_o.comments = None
saturn_core_domain_SgcExpression._hx_class = saturn_core_domain_SgcExpression
_hx_classes["saturn.core.domain.SgcExpression"] = saturn_core_domain_SgcExpression


class saturn_core_domain_SgcForwardPrimer(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.SgcForwardPrimer"
	_hx_fields = ["primerId", "id", "dnaSequence", "targetId"]
	_hx_methods = ["setup", "getMoleculeName", "setSequence"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.primerId = None
		self.id = None
		self.dnaSequence = None
		self.targetId = None
		super().__init__(None)

	def setup(self):
		self.setSequence(self.dnaSequence)

	def getMoleculeName(self):
		return self.primerId

	def setSequence(self,sequence):
		super().setSequence(sequence)
		self.dnaSequence = sequence

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.primerId = None
		_hx_o.id = None
		_hx_o.dnaSequence = None
		_hx_o.targetId = None
saturn_core_domain_SgcForwardPrimer._hx_class = saturn_core_domain_SgcForwardPrimer
_hx_classes["saturn.core.domain.SgcForwardPrimer"] = saturn_core_domain_SgcForwardPrimer


class saturn_core_domain_SgcPurification:
	_hx_class_name = "saturn.core.domain.SgcPurification"
	_hx_fields = ["id", "purificationId", "expressionId", "expression", "column", "elnId", "comments"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.purificationId = None
		self.expressionId = None
		self.expression = None
		self.column = None
		self.elnId = None
		self.comments = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.purificationId = None
		_hx_o.expressionId = None
		_hx_o.expression = None
		_hx_o.column = None
		_hx_o.elnId = None
		_hx_o.comments = None
saturn_core_domain_SgcPurification._hx_class = saturn_core_domain_SgcPurification
_hx_classes["saturn.core.domain.SgcPurification"] = saturn_core_domain_SgcPurification


class saturn_core_domain_SgcRestrictionSite(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.SgcRestrictionSite"
	_hx_fields = ["enzymeName", "cutSequence", "id"]
	_hx_methods = ["setup", "setSequence", "getSequence"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.enzymeName = None
		self.cutSequence = None
		self.id = None
		super().__init__(None)
		self.allowStar = True

	def setup(self):
		self.setSequence(self.cutSequence)

	def setSequence(self,sequence):
		super().setSequence(sequence)
		self.cutSequence = sequence

	def getSequence(self):
		return self.cutSequence

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.enzymeName = None
		_hx_o.cutSequence = None
		_hx_o.id = None
saturn_core_domain_SgcRestrictionSite._hx_class = saturn_core_domain_SgcRestrictionSite
_hx_classes["saturn.core.domain.SgcRestrictionSite"] = saturn_core_domain_SgcRestrictionSite


class saturn_core_domain_SgcReversePrimer(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.SgcReversePrimer"
	_hx_fields = ["primerId", "id", "dnaSequence", "targetId"]
	_hx_methods = ["setup", "getMoleculeName", "setSequence"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.primerId = None
		self.id = None
		self.dnaSequence = None
		self.targetId = None
		super().__init__(None)

	def setup(self):
		self.setSequence(self.dnaSequence)

	def getMoleculeName(self):
		return self.primerId

	def setSequence(self,sequence):
		super().setSequence(sequence)
		self.dnaSequence = sequence

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.primerId = None
		_hx_o.id = None
		_hx_o.dnaSequence = None
		_hx_o.targetId = None
saturn_core_domain_SgcReversePrimer._hx_class = saturn_core_domain_SgcReversePrimer
_hx_classes["saturn.core.domain.SgcReversePrimer"] = saturn_core_domain_SgcReversePrimer


class saturn_core_domain_SgcSeqData:
	_hx_class_name = "saturn.core.domain.SgcSeqData"
	_hx_fields = ["id", "type", "sequence", "version", "targetId", "target", "crc"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.type = None
		self.sequence = None
		self.version = None
		self.targetId = None
		self.target = None
		self.crc = None

	def setup(self):
		if (self.sequence is not None):
			self.crc = haxe_crypto_Md5.encode(self.sequence)
		else:
			self.crc = ""

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.type = None
		_hx_o.sequence = None
		_hx_o.version = None
		_hx_o.targetId = None
		_hx_o.target = None
		_hx_o.crc = None
saturn_core_domain_SgcSeqData._hx_class = saturn_core_domain_SgcSeqData
_hx_classes["saturn.core.domain.SgcSeqData"] = saturn_core_domain_SgcSeqData


class saturn_core_domain_SgcTarget(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.SgcTarget"
	_hx_fields = ["targetId", "id", "gi", "dnaSeq", "proteinSeq", "dnaSequence", "geneId", "activeStatus", "pi", "comments"]
	_hx_methods = ["setup", "setProtein", "proteinSequenceUpdated", "setSequence", "loadWonka"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.targetId = None
		self.id = None
		self.gi = None
		self.dnaSeq = None
		self.proteinSeq = None
		self.dnaSequence = None
		self.geneId = None
		self.activeStatus = None
		self.pi = None
		self.comments = None
		super().__init__(None)
		self.setup()

	def setup(self):
		self.setSequence(self.dnaSeq)
		self.setName(self.targetId)
		self.linkedOriginField = "proteinSeq"
		self.sequenceField = "dnaSeq"
		self.setProtein(saturn_core_Protein(self.proteinSeq))

	def setProtein(self,prot):
		super().setProtein(prot)
		if (prot is None):
			self.proteinSeq = None
		else:
			self.proteinSeq = prot.getSequence()

	def proteinSequenceUpdated(self,sequence):
		self.proteinSeq = sequence

	def setSequence(self,sequence):
		super().setSequence(sequence)
		self.dnaSeq = sequence
		if (self.dnaSequence is None):
			self.dnaSequence = saturn_core_domain_SgcSeqData()
		self.dnaSequence.sequence = self.dnaSeq

	def loadWonka(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.targetId = None
		_hx_o.id = None
		_hx_o.gi = None
		_hx_o.dnaSeq = None
		_hx_o.proteinSeq = None
		_hx_o.dnaSequence = None
		_hx_o.geneId = None
		_hx_o.activeStatus = None
		_hx_o.pi = None
		_hx_o.comments = None
saturn_core_domain_SgcTarget._hx_class = saturn_core_domain_SgcTarget
_hx_classes["saturn.core.domain.SgcTarget"] = saturn_core_domain_SgcTarget


class saturn_core_domain_SgcUtil:
	_hx_class_name = "saturn.core.domain.SgcUtil"
	_hx_statics = ["generateNextIDForClasses", "generateNextID"]

	def __init__(self):
		pass

	@staticmethod
	def generateNextIDForClasses(provider,targets,clazzes,cb):
		classToIds = haxe_ds_StringMap()
		next = None
		def _hx_local_1():
			clazz = None
			clazz = (None if ((len(clazzes) == 0)) else clazzes.pop())
			def _hx_local_0(_hx_map,error):
				if (error is not None):
					cb(None,error)
				else:
					key = Type.getClassName(clazz)
					classToIds.h[key] = _hx_map
					if (len(clazzes) == 0):
						cb(classToIds,None)
					else:
						next()
			saturn_core_domain_SgcUtil.generateNextID(provider,targets,clazz,_hx_local_0)
		next = _hx_local_1
		next()

	@staticmethod
	def generateNextID(provider,targets,clazz,cb):
		q = saturn_db_query_lang_Query(provider)
		s = q.getSelect()
		model = provider.getModel(clazz)
		idField = saturn_db_query_lang_Field(clazz, model.getFirstKey())
		q.getSelect().add(idField.substr(0,idField.instr("-",1).minus(1))._hx_as("target"))
		q.getSelect().add(idField.substr(idField.instr("-",1).plus(2),idField.length())._hx_as("ID"))
		_g1 = 0
		_g = len(targets)
		while (_g1 < _g):
			i = _g1
			_g1 = (_g1 + 1)
			target = (targets[i] if i >= 0 and i < len(targets) else None)
			q.getWhere().add(idField.like(saturn_db_query_lang_Value(target).concat("%")))
			if (i < ((len(targets) - 1))):
				q.getWhere().addToken(saturn_db_query_lang_Or())
		q2 = saturn_db_query_lang_Query(provider)
		q2.fetchRawResults()
		q2.getSelect().add(saturn_db_query_lang_Field(None, "target", "a")._hx_as("targetName"))
		q2.getSelect().add(saturn_db_query_lang_Trim(saturn_db_query_lang_Max(saturn_db_query_lang_Field(None, "ID", "a")))._hx_as("lastId"))
		q2.getFrom().add(q._hx_as("a"))
		q2.getGroup().add(saturn_db_query_lang_Field(None, "target", "a"))
		def _hx_local_3(objs,err):
			if (err is not None):
				cb(None,err)
			else:
				_hx_map = haxe_ds_StringMap()
				_g2 = 0
				while (_g2 < len(objs)):
					obj = (objs[_g2] if _g2 >= 0 and _g2 < len(objs) else None)
					_g2 = (_g2 + 1)
					nextId = (Std.parseInt(Reflect.field(obj,"lastId")) + 1)
					def _hx_local_1():
						f = nextId
						return python_lib_Math.isnan(f)
					if ((_hx_local_1() or ((nextId is None))) or ((nextId == "null"))):
						nextId = 0
					setattr(obj,(("_hx_" + "lastId") if ("lastId" in python_Boot.keywords) else (("_hx_" + "lastId") if (((((len("lastId") > 2) and ((ord("lastId"[0]) == 95))) and ((ord("lastId"[1]) == 95))) and ((ord("lastId"[(len("lastId") - 1)]) != 95)))) else "lastId")),nextId)
					saturn_core_Util.debug(Reflect.field(obj,"targetName"))
					key = Reflect.field(obj,"targetName")
					value = Reflect.field(obj,"lastId")
					_hx_map.h[key] = value
				_g3 = 0
				while (_g3 < len(targets)):
					target1 = (targets[_g3] if _g3 >= 0 and _g3 < len(targets) else None)
					_g3 = (_g3 + 1)
					if (not target1 in _hx_map.h):
						_hx_map.h[target1] = 1
				cb(_hx_map,None)
		q2.run(_hx_local_3)
saturn_core_domain_SgcUtil._hx_class = saturn_core_domain_SgcUtil
_hx_classes["saturn.core.domain.SgcUtil"] = saturn_core_domain_SgcUtil


class saturn_core_domain_SgcVector(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.SgcVector"
	_hx_fields = ["vectorId", "id", "vectorComments", "proteaseName", "proteaseCutSequence", "proteaseProduct", "antibiotic", "organism", "res1Id", "res2Id", "res1", "res2", "addStopCodon", "requiredForwardExtension", "requiredReverseExtension"]
	_hx_methods = ["setup"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.vectorId = None
		self.id = None
		self.vectorComments = None
		self.proteaseName = None
		self.proteaseCutSequence = None
		self.proteaseProduct = None
		self.antibiotic = None
		self.organism = None
		self.res1Id = None
		self.res2Id = None
		self.res1 = None
		self.res2 = None
		self.addStopCodon = None
		self.requiredForwardExtension = None
		self.requiredReverseExtension = None
		self.addStopCodon = "no"
		super().__init__(None)

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.vectorId = None
		_hx_o.id = None
		_hx_o.vectorComments = None
		_hx_o.proteaseName = None
		_hx_o.proteaseCutSequence = None
		_hx_o.proteaseProduct = None
		_hx_o.antibiotic = None
		_hx_o.organism = None
		_hx_o.res1Id = None
		_hx_o.res2Id = None
		_hx_o.res1 = None
		_hx_o.res2 = None
		_hx_o.addStopCodon = None
		_hx_o.requiredForwardExtension = None
		_hx_o.requiredReverseExtension = None
saturn_core_domain_SgcVector._hx_class = saturn_core_domain_SgcVector
_hx_classes["saturn.core.domain.SgcVector"] = saturn_core_domain_SgcVector


class saturn_core_domain_SgcXtalDataSet:
	_hx_class_name = "saturn.core.domain.SgcXtalDataSet"
	_hx_fields = ["id", "xtalDataSetId", "xtalMountId", "estimatedResolution", "scaledResolution", "xtalMount", "beamline", "outcome", "dsType", "visit", "spaceGroup", "dateRecordCreated"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.xtalDataSetId = None
		self.xtalMountId = None
		self.estimatedResolution = None
		self.scaledResolution = None
		self.xtalMount = None
		self.beamline = None
		self.outcome = None
		self.dsType = None
		self.visit = None
		self.spaceGroup = None
		self.dateRecordCreated = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.xtalDataSetId = None
		_hx_o.xtalMountId = None
		_hx_o.estimatedResolution = None
		_hx_o.scaledResolution = None
		_hx_o.xtalMount = None
		_hx_o.beamline = None
		_hx_o.outcome = None
		_hx_o.dsType = None
		_hx_o.visit = None
		_hx_o.spaceGroup = None
		_hx_o.dateRecordCreated = None
saturn_core_domain_SgcXtalDataSet._hx_class = saturn_core_domain_SgcXtalDataSet
_hx_classes["saturn.core.domain.SgcXtalDataSet"] = saturn_core_domain_SgcXtalDataSet


class saturn_core_domain_SgcXtalDeposition:
	_hx_class_name = "saturn.core.domain.SgcXtalDeposition"
	_hx_fields = ["id", "pdbId", "xtalModelId", "counted", "site", "followUp", "dateDeposited", "xtalModel"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.pdbId = None
		self.xtalModelId = None
		self.counted = None
		self.site = None
		self.followUp = None
		self.dateDeposited = None
		self.xtalModel = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.pdbId = None
		_hx_o.xtalModelId = None
		_hx_o.counted = None
		_hx_o.site = None
		_hx_o.followUp = None
		_hx_o.dateDeposited = None
		_hx_o.xtalModel = None
saturn_core_domain_SgcXtalDeposition._hx_class = saturn_core_domain_SgcXtalDeposition
_hx_classes["saturn.core.domain.SgcXtalDeposition"] = saturn_core_domain_SgcXtalDeposition


class saturn_core_domain_SgcXtalForm:
	_hx_class_name = "saturn.core.domain.SgcXtalForm"
	_hx_fields = ["id", "formId", "phasingId", "a", "b", "c", "alpha", "beta", "gamma", "spaceGroup", "latticeSymbol", "lattice", "xtalPhasing"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.formId = None
		self.phasingId = None
		self.a = None
		self.b = None
		self.c = None
		self.alpha = None
		self.beta = None
		self.gamma = None
		self.spaceGroup = None
		self.latticeSymbol = None
		self.lattice = None
		self.xtalPhasing = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.formId = None
		_hx_o.phasingId = None
		_hx_o.a = None
		_hx_o.b = None
		_hx_o.c = None
		_hx_o.alpha = None
		_hx_o.beta = None
		_hx_o.gamma = None
		_hx_o.spaceGroup = None
		_hx_o.latticeSymbol = None
		_hx_o.lattice = None
		_hx_o.xtalPhasing = None
saturn_core_domain_SgcXtalForm._hx_class = saturn_core_domain_SgcXtalForm
_hx_classes["saturn.core.domain.SgcXtalForm"] = saturn_core_domain_SgcXtalForm


class saturn_core_domain_SgcXtalModel:
	_hx_class_name = "saturn.core.domain.SgcXtalModel"
	_hx_fields = ["id", "xtalModelId", "modelType", "compound1Id", "compound2Id", "xtalDataSetId", "status", "pathToCrystallographicPDB", "pathToChemistsPDB", "pathToXDSLog", "pathToMTZ", "estimatedEffort", "proofingEffort", "spaceGroup", "xtalDataDataSet"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.xtalModelId = None
		self.modelType = None
		self.compound1Id = None
		self.compound2Id = None
		self.xtalDataSetId = None
		self.status = None
		self.pathToCrystallographicPDB = None
		self.pathToChemistsPDB = None
		self.pathToXDSLog = None
		self.pathToMTZ = None
		self.estimatedEffort = None
		self.proofingEffort = None
		self.spaceGroup = None
		self.xtalDataDataSet = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.xtalModelId = None
		_hx_o.modelType = None
		_hx_o.compound1Id = None
		_hx_o.compound2Id = None
		_hx_o.xtalDataSetId = None
		_hx_o.status = None
		_hx_o.pathToCrystallographicPDB = None
		_hx_o.pathToChemistsPDB = None
		_hx_o.pathToXDSLog = None
		_hx_o.pathToMTZ = None
		_hx_o.estimatedEffort = None
		_hx_o.proofingEffort = None
		_hx_o.spaceGroup = None
		_hx_o.xtalDataDataSet = None
saturn_core_domain_SgcXtalModel._hx_class = saturn_core_domain_SgcXtalModel
_hx_classes["saturn.core.domain.SgcXtalModel"] = saturn_core_domain_SgcXtalModel


class saturn_core_domain_SgcXtalMount:
	_hx_class_name = "saturn.core.domain.SgcXtalMount"
	_hx_fields = ["id", "xtalMountId", "xtbmId", "xtalProjectId", "dropStatus", "compoundId", "pinId", "xtalFormId", "xtbm", "xtalProject", "compound", "xtalForm"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.xtalMountId = None
		self.xtbmId = None
		self.xtalProjectId = None
		self.dropStatus = None
		self.compoundId = None
		self.pinId = None
		self.xtalFormId = None
		self.xtbm = None
		self.xtalProject = None
		self.compound = None
		self.xtalForm = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.xtalMountId = None
		_hx_o.xtbmId = None
		_hx_o.xtalProjectId = None
		_hx_o.dropStatus = None
		_hx_o.compoundId = None
		_hx_o.pinId = None
		_hx_o.xtalFormId = None
		_hx_o.xtbm = None
		_hx_o.xtalProject = None
		_hx_o.compound = None
		_hx_o.xtalForm = None
saturn_core_domain_SgcXtalMount._hx_class = saturn_core_domain_SgcXtalMount
_hx_classes["saturn.core.domain.SgcXtalMount"] = saturn_core_domain_SgcXtalMount


class saturn_core_domain_SgcXtalPhasing:
	_hx_class_name = "saturn.core.domain.SgcXtalPhasing"
	_hx_fields = ["id", "phasingId", "xtalDataSetId", "phasingMethod", "phasingConfidence", "spaceGroup", "xtalDataSet"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.phasingId = None
		self.xtalDataSetId = None
		self.phasingMethod = None
		self.phasingConfidence = None
		self.spaceGroup = None
		self.xtalDataSet = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.phasingId = None
		_hx_o.xtalDataSetId = None
		_hx_o.phasingMethod = None
		_hx_o.phasingConfidence = None
		_hx_o.spaceGroup = None
		_hx_o.xtalDataSet = None
saturn_core_domain_SgcXtalPhasing._hx_class = saturn_core_domain_SgcXtalPhasing
_hx_classes["saturn.core.domain.SgcXtalPhasing"] = saturn_core_domain_SgcXtalPhasing


class saturn_core_domain_SgcXtalPlate:
	_hx_class_name = "saturn.core.domain.SgcXtalPlate"
	_hx_fields = ["id", "barcode", "purificationId", "purification"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.barcode = None
		self.purificationId = None
		self.purification = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.barcode = None
		_hx_o.purificationId = None
		_hx_o.purification = None
saturn_core_domain_SgcXtalPlate._hx_class = saturn_core_domain_SgcXtalPlate
_hx_classes["saturn.core.domain.SgcXtalPlate"] = saturn_core_domain_SgcXtalPlate


class saturn_core_domain_SgcXtalProject:
	_hx_class_name = "saturn.core.domain.SgcXtalProject"
	_hx_fields = ["id", "xtalProjectId", "dataPath", "targetId", "target"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.xtalProjectId = None
		self.dataPath = None
		self.targetId = None
		self.target = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.xtalProjectId = None
		_hx_o.dataPath = None
		_hx_o.targetId = None
		_hx_o.target = None
saturn_core_domain_SgcXtalProject._hx_class = saturn_core_domain_SgcXtalProject
_hx_classes["saturn.core.domain.SgcXtalProject"] = saturn_core_domain_SgcXtalProject


class saturn_core_domain_SgcXtbm:
	_hx_class_name = "saturn.core.domain.SgcXtbm"
	_hx_fields = ["id", "xtbmId", "plateRow", "plateColumn", "subwell", "xtalPlateId", "barcode", "xtalPlate", "score"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.xtbmId = None
		self.plateRow = None
		self.plateColumn = None
		self.subwell = None
		self.xtalPlateId = None
		self.barcode = None
		self.xtalPlate = None
		self.score = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.xtbmId = None
		_hx_o.plateRow = None
		_hx_o.plateColumn = None
		_hx_o.subwell = None
		_hx_o.xtalPlateId = None
		_hx_o.barcode = None
		_hx_o.xtalPlate = None
		_hx_o.score = None
saturn_core_domain_SgcXtbm._hx_class = saturn_core_domain_SgcXtbm
_hx_classes["saturn.core.domain.SgcXtbm"] = saturn_core_domain_SgcXtbm


class saturn_core_domain_StructureModel:
	_hx_class_name = "saturn.core.domain.StructureModel"
	_hx_fields = ["id", "modelId", "contents", "pdb", "pathToPdb", "ribbonOn", "wireOn", "labelsOn", "renderer", "icbURL"]
	_hx_methods = ["getContent"]

	def __init__(self):
		self.id = None
		self.modelId = None
		self.contents = None
		self.pdb = None
		self.pathToPdb = None
		self.ribbonOn = None
		self.wireOn = None
		self.labelsOn = None
		self.renderer = None
		self.icbURL = None
		self.ribbonOn = True
		self.wireOn = False

	def getContent(self):
		if (self.contents is not None):
			return self.contents
		else:
			return None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.modelId = None
		_hx_o.contents = None
		_hx_o.pdb = None
		_hx_o.pathToPdb = None
		_hx_o.ribbonOn = None
		_hx_o.wireOn = None
		_hx_o.labelsOn = None
		_hx_o.renderer = None
		_hx_o.icbURL = None
saturn_core_domain_StructureModel._hx_class = saturn_core_domain_StructureModel
_hx_classes["saturn.core.domain.StructureModel"] = saturn_core_domain_StructureModel


class saturn_core_domain_TiddlyWiki:
	_hx_class_name = "saturn.core.domain.TiddlyWiki"
	_hx_fields = ["id", "pageId", "content"]
	_hx_methods = ["setup"]

	def __init__(self):
		self.id = None
		self.pageId = None
		self.content = None

	def setup(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.pageId = None
		_hx_o.content = None
saturn_core_domain_TiddlyWiki._hx_class = saturn_core_domain_TiddlyWiki
_hx_classes["saturn.core.domain.TiddlyWiki"] = saturn_core_domain_TiddlyWiki


class saturn_core_domain_oppf_Oppf:
	_hx_class_name = "saturn.core.domain.oppf.Oppf"
	_hx_fields = ["oppfId", "type", "genbankInfoId"]

	def __init__(self):
		self.oppfId = None
		self.type = None
		self.genbankInfoId = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.oppfId = None
		_hx_o.type = None
		_hx_o.genbankInfoId = None
saturn_core_domain_oppf_Oppf._hx_class = saturn_core_domain_oppf_Oppf
_hx_classes["saturn.core.domain.oppf.Oppf"] = saturn_core_domain_oppf_Oppf


class saturn_core_domain_oppf_OppfAnnotation:
	_hx_class_name = "saturn.core.domain.oppf.OppfAnnotation"
	_hx_fields = ["id", "genbankInfoId", "startSeq", "endSeq", "annotation", "annotatedBy", "annotatedAt", "annotationType", "referenceId", "sequenceType", "filePath"]

	def __init__(self):
		self.id = None
		self.genbankInfoId = None
		self.startSeq = None
		self.endSeq = None
		self.annotation = None
		self.annotatedBy = None
		self.annotatedAt = None
		self.annotationType = None
		self.referenceId = None
		self.sequenceType = None
		self.filePath = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.genbankInfoId = None
		_hx_o.startSeq = None
		_hx_o.endSeq = None
		_hx_o.annotation = None
		_hx_o.annotatedBy = None
		_hx_o.annotatedAt = None
		_hx_o.annotationType = None
		_hx_o.referenceId = None
		_hx_o.sequenceType = None
		_hx_o.filePath = None
saturn_core_domain_oppf_OppfAnnotation._hx_class = saturn_core_domain_oppf_OppfAnnotation
_hx_classes["saturn.core.domain.oppf.OppfAnnotation"] = saturn_core_domain_oppf_OppfAnnotation


class saturn_core_domain_oppf_OppfAnnotationType:
	_hx_class_name = "saturn.core.domain.oppf.OppfAnnotationType"
	_hx_fields = ["annotationTypeId", "annotationType", "description"]

	def __init__(self):
		self.annotationTypeId = None
		self.annotationType = None
		self.description = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.annotationTypeId = None
		_hx_o.annotationType = None
		_hx_o.description = None
saturn_core_domain_oppf_OppfAnnotationType._hx_class = saturn_core_domain_oppf_OppfAnnotationType
_hx_classes["saturn.core.domain.oppf.OppfAnnotationType"] = saturn_core_domain_oppf_OppfAnnotationType


class saturn_core_domain_oppf_OppfBaseContent:
	_hx_class_name = "saturn.core.domain.oppf.OppfBaseContent"
	_hx_fields = ["id", "As", "Cs", "Gs", "Ts", "percentageAT", "percentageGC"]

	def __init__(self):
		self.id = None
		self.As = None
		self.Cs = None
		self.Gs = None
		self.Ts = None
		self.percentageAT = None
		self.percentageGC = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.As = None
		_hx_o.Cs = None
		_hx_o.Gs = None
		_hx_o.Ts = None
		_hx_o.percentageAT = None
		_hx_o.percentageGC = None
saturn_core_domain_oppf_OppfBaseContent._hx_class = saturn_core_domain_oppf_OppfBaseContent
_hx_classes["saturn.core.domain.oppf.OppfBaseContent"] = saturn_core_domain_oppf_OppfBaseContent


class saturn_core_domain_oppf_OppfBindBlast:
	_hx_class_name = "saturn.core.domain.oppf.OppfBindBlast"
	_hx_fields = ["id", "proteinId", "hitDescription", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverHit", "percentageIdentityOverQuery", "hitLengthOverQueryLength", "querySequence", "hitSequence", "midline"]

	def __init__(self):
		self.id = None
		self.proteinId = None
		self.hitDescription = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverHit = None
		self.percentageIdentityOverQuery = None
		self.hitLengthOverQueryLength = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.proteinId = None
		_hx_o.hitDescription = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverHit = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.hitLengthOverQueryLength = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
saturn_core_domain_oppf_OppfBindBlast._hx_class = saturn_core_domain_oppf_OppfBindBlast
_hx_classes["saturn.core.domain.oppf.OppfBindBlast"] = saturn_core_domain_oppf_OppfBindBlast


class saturn_core_domain_oppf_OppfCellularLocation:
	_hx_class_name = "saturn.core.domain.oppf.OppfCellularLocation"
	_hx_fields = ["id", "length", "mtp", "sp", "other", "location", "rc", "tplength"]

	def __init__(self):
		self.id = None
		self.length = None
		self.mtp = None
		self.sp = None
		self.other = None
		self.location = None
		self.rc = None
		self.tplength = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.length = None
		_hx_o.mtp = None
		_hx_o.sp = None
		_hx_o.other = None
		_hx_o.location = None
		_hx_o.rc = None
		_hx_o.tplength = None
saturn_core_domain_oppf_OppfCellularLocation._hx_class = saturn_core_domain_oppf_OppfCellularLocation
_hx_classes["saturn.core.domain.oppf.OppfCellularLocation"] = saturn_core_domain_oppf_OppfCellularLocation


class saturn_core_domain_oppf_OppfCodons:
	_hx_class_name = "saturn.core.domain.oppf.OppfCodons"
	_hx_fields = ["id", "rareCodonLocation", "rareCodonTable", "first20Codons", "numberBadCodons", "badCodonsInFirst20"]

	def __init__(self):
		self.id = None
		self.rareCodonLocation = None
		self.rareCodonTable = None
		self.first20Codons = None
		self.numberBadCodons = None
		self.badCodonsInFirst20 = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.rareCodonLocation = None
		_hx_o.rareCodonTable = None
		_hx_o.first20Codons = None
		_hx_o.numberBadCodons = None
		_hx_o.badCodonsInFirst20 = None
saturn_core_domain_oppf_OppfCodons._hx_class = saturn_core_domain_oppf_OppfCodons
_hx_classes["saturn.core.domain.oppf.OppfCodons"] = saturn_core_domain_oppf_OppfCodons


class saturn_core_domain_oppf_OppfConstruct(saturn_core_Protein):
	_hx_class_name = "saturn.core.domain.oppf.OppfConstruct"
	_hx_fields = ["constructId", "id", "start", "stop", "description", "fwdAnnealLen", "revAnnealLen", "fwdTagId", "revTagId", "pickedBy", "pickedAt", "authBy", "authAt", "auth", "manual", "limsRead", "annotationId", "vectorId", "target", "vector", "constructSeq", "forwardTag", "reverseTag", "vectorProteinProduct"]
	_hx_methods = ["setup", "showProtein", "vectorProduct"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_Protein


	def __init__(self):
		self.constructId = None
		self.id = None
		self.start = None
		self.stop = None
		self.description = None
		self.fwdAnnealLen = None
		self.revAnnealLen = None
		self.fwdTagId = None
		self.revTagId = None
		self.pickedBy = None
		self.pickedAt = None
		self.authBy = None
		self.authAt = None
		self.auth = None
		self.manual = None
		self.limsRead = None
		self.annotationId = None
		self.vectorId = None
		self.target = None
		self.vector = None
		self.constructSeq = None
		self.forwardTag = None
		self.reverseTag = None
		self.vectorProteinProduct = None
		super().__init__("")

	def setup(self):
		s = self
		self.name = ("OPPF" + Std.string(Reflect.field(s,"constructId")))
		if (self.target is not None):
			tempDnaSequence = self.target.dnaSequence
			Reflect.setField(s,"sequence",HxString.substr(tempDnaSequence,(self.start - 1),((self.stop - self.start) + 1)))

	def showProtein(self,obj,cb):
		pass

	def vectorProduct(self):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.constructId = None
		_hx_o.id = None
		_hx_o.start = None
		_hx_o.stop = None
		_hx_o.description = None
		_hx_o.fwdAnnealLen = None
		_hx_o.revAnnealLen = None
		_hx_o.fwdTagId = None
		_hx_o.revTagId = None
		_hx_o.pickedBy = None
		_hx_o.pickedAt = None
		_hx_o.authBy = None
		_hx_o.authAt = None
		_hx_o.auth = None
		_hx_o.manual = None
		_hx_o.limsRead = None
		_hx_o.annotationId = None
		_hx_o.vectorId = None
		_hx_o.target = None
		_hx_o.vector = None
		_hx_o.constructSeq = None
		_hx_o.forwardTag = None
		_hx_o.reverseTag = None
		_hx_o.vectorProteinProduct = None
saturn_core_domain_oppf_OppfConstruct._hx_class = saturn_core_domain_oppf_OppfConstruct
_hx_classes["saturn.core.domain.oppf.OppfConstruct"] = saturn_core_domain_oppf_OppfConstruct


class saturn_core_domain_oppf_OppfConstructMilestone:
	_hx_class_name = "saturn.core.domain.oppf.OppfConstructMilestone"
	_hx_fields = ["id", "constructId", "milestoneId", "reachedAt", "aliquotId"]

	def __init__(self):
		self.id = None
		self.constructId = None
		self.milestoneId = None
		self.reachedAt = None
		self.aliquotId = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.constructId = None
		_hx_o.milestoneId = None
		_hx_o.reachedAt = None
		_hx_o.aliquotId = None
saturn_core_domain_oppf_OppfConstructMilestone._hx_class = saturn_core_domain_oppf_OppfConstructMilestone
_hx_classes["saturn.core.domain.oppf.OppfConstructMilestone"] = saturn_core_domain_oppf_OppfConstructMilestone


class saturn_core_domain_oppf_OppfForwardTag:
	_hx_class_name = "saturn.core.domain.oppf.OppfForwardTag"
	_hx_fields = ["id", "name", "sequence"]

	def __init__(self):
		self.id = None
		self.name = None
		self.sequence = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
		_hx_o.sequence = None
saturn_core_domain_oppf_OppfForwardTag._hx_class = saturn_core_domain_oppf_OppfForwardTag
_hx_classes["saturn.core.domain.oppf.OppfForwardTag"] = saturn_core_domain_oppf_OppfForwardTag


class saturn_core_domain_oppf_OppfGenbankInfo(saturn_core_DNA):
	_hx_class_name = "saturn.core.domain.oppf.OppfGenbankInfo"
	_hx_fields = ["id", "genbankAccession", "giNumber", "mgcAccession", "imageNumber", "dnaSequence", "proteinSequence", "description", "dnaDescription", "genbankLocus", "locus", "speciesId"]
	_hx_methods = ["setup", "showProtein"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_DNA


	def __init__(self):
		self.id = None
		self.genbankAccession = None
		self.giNumber = None
		self.mgcAccession = None
		self.imageNumber = None
		self.dnaSequence = None
		self.proteinSequence = None
		self.description = None
		self.dnaDescription = None
		self.genbankLocus = None
		self.locus = None
		self.speciesId = None
		super().__init__("")

	def setup(self):
		s = self
		self.name = ("OPTIC" + Std.string(Reflect.field(s,"id")))
		Reflect.setField(s,"sequence",self.dnaSequence)

	def showProtein(self,obj,cb):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.genbankAccession = None
		_hx_o.giNumber = None
		_hx_o.mgcAccession = None
		_hx_o.imageNumber = None
		_hx_o.dnaSequence = None
		_hx_o.proteinSequence = None
		_hx_o.description = None
		_hx_o.dnaDescription = None
		_hx_o.genbankLocus = None
		_hx_o.locus = None
		_hx_o.speciesId = None
saturn_core_domain_oppf_OppfGenbankInfo._hx_class = saturn_core_domain_oppf_OppfGenbankInfo
_hx_classes["saturn.core.domain.oppf.OppfGenbankInfo"] = saturn_core_domain_oppf_OppfGenbankInfo


class saturn_core_domain_oppf_OppfGroupInfo:
	_hx_class_name = "saturn.core.domain.oppf.OppfGroupInfo"
	_hx_fields = ["id", "proteinId", "name", "owner", "annotation"]

	def __init__(self):
		self.id = None
		self.proteinId = None
		self.name = None
		self.owner = None
		self.annotation = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.proteinId = None
		_hx_o.name = None
		_hx_o.owner = None
		_hx_o.annotation = None
saturn_core_domain_oppf_OppfGroupInfo._hx_class = saturn_core_domain_oppf_OppfGroupInfo
_hx_classes["saturn.core.domain.oppf.OppfGroupInfo"] = saturn_core_domain_oppf_OppfGroupInfo


class saturn_core_domain_oppf_OppfGroupTarget:
	_hx_class_name = "saturn.core.domain.oppf.OppfGroupTarget"
	_hx_fields = ["groupId", "targetId"]

	def __init__(self):
		self.groupId = None
		self.targetId = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.groupId = None
		_hx_o.targetId = None
saturn_core_domain_oppf_OppfGroupTarget._hx_class = saturn_core_domain_oppf_OppfGroupTarget
_hx_classes["saturn.core.domain.oppf.OppfGroupTarget"] = saturn_core_domain_oppf_OppfGroupTarget


class saturn_core_domain_oppf_OppfMGCBlast:
	_hx_class_name = "saturn.core.domain.oppf.OppfMGCBlast"
	_hx_fields = ["id", "hitDescription", "giNumber", "mgcAccession", "imageNumber", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverQuery", "querySequence", "hitSequence", "midline"]

	def __init__(self):
		self.id = None
		self.hitDescription = None
		self.giNumber = None
		self.mgcAccession = None
		self.imageNumber = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverQuery = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.hitDescription = None
		_hx_o.giNumber = None
		_hx_o.mgcAccession = None
		_hx_o.imageNumber = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
saturn_core_domain_oppf_OppfMGCBlast._hx_class = saturn_core_domain_oppf_OppfMGCBlast
_hx_classes["saturn.core.domain.oppf.OppfMGCBlast"] = saturn_core_domain_oppf_OppfMGCBlast


class saturn_core_domain_oppf_OppfMilestone:
	_hx_class_name = "saturn.core.domain.oppf.OppfMilestone"
	_hx_fields = ["id", "name", "description", "spinedtd", "orderNo", "reported"]

	def __init__(self):
		self.id = None
		self.name = None
		self.description = None
		self.spinedtd = None
		self.orderNo = None
		self.reported = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
		_hx_o.description = None
		_hx_o.spinedtd = None
		_hx_o.orderNo = None
		_hx_o.reported = None
saturn_core_domain_oppf_OppfMilestone._hx_class = saturn_core_domain_oppf_OppfMilestone
_hx_classes["saturn.core.domain.oppf.OppfMilestone"] = saturn_core_domain_oppf_OppfMilestone


class saturn_core_domain_oppf_OppfMouseMGCBlast:
	_hx_class_name = "saturn.core.domain.oppf.OppfMouseMGCBlast"
	_hx_fields = ["id", "hitDescription", "giNumber", "mgcAccession", "imageNumber", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverQuery", "querySequence", "hitSequence", "midline"]

	def __init__(self):
		self.id = None
		self.hitDescription = None
		self.giNumber = None
		self.mgcAccession = None
		self.imageNumber = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverQuery = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.hitDescription = None
		_hx_o.giNumber = None
		_hx_o.mgcAccession = None
		_hx_o.imageNumber = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
saturn_core_domain_oppf_OppfMouseMGCBlast._hx_class = saturn_core_domain_oppf_OppfMouseMGCBlast
_hx_classes["saturn.core.domain.oppf.OppfMouseMGCBlast"] = saturn_core_domain_oppf_OppfMouseMGCBlast


class saturn_core_domain_oppf_OppfMouseProteomeBlast:
	_hx_class_name = "saturn.core.domain.oppf.OppfMouseProteomeBlast"
	_hx_fields = ["id", "proteinId", "hitDescription", "giNumber", "mgcAccession", "imageNumber", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverQuery", "querySequence", "hitSequence", "midline"]

	def __init__(self):
		self.id = None
		self.proteinId = None
		self.hitDescription = None
		self.giNumber = None
		self.mgcAccession = None
		self.imageNumber = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverQuery = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.proteinId = None
		_hx_o.hitDescription = None
		_hx_o.giNumber = None
		_hx_o.mgcAccession = None
		_hx_o.imageNumber = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
saturn_core_domain_oppf_OppfMouseProteomeBlast._hx_class = saturn_core_domain_oppf_OppfMouseProteomeBlast
_hx_classes["saturn.core.domain.oppf.OppfMouseProteomeBlast"] = saturn_core_domain_oppf_OppfMouseProteomeBlast


class saturn_core_domain_oppf_OppfNetNGlyc:
	_hx_class_name = "saturn.core.domain.oppf.OppfNetNGlyc"
	_hx_fields = ["id", "output", "glycosylationSites", "numberofGlycSites"]

	def __init__(self):
		self.id = None
		self.output = None
		self.glycosylationSites = None
		self.numberofGlycSites = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.output = None
		_hx_o.glycosylationSites = None
		_hx_o.numberofGlycSites = None
saturn_core_domain_oppf_OppfNetNGlyc._hx_class = saturn_core_domain_oppf_OppfNetNGlyc
_hx_classes["saturn.core.domain.oppf.OppfNetNGlyc"] = saturn_core_domain_oppf_OppfNetNGlyc


class saturn_core_domain_oppf_OppfNetOGlyc:
	_hx_class_name = "saturn.core.domain.oppf.OppfNetOGlyc"
	_hx_fields = ["id", "output", "glycosylationSites", "numberofGlycSites"]

	def __init__(self):
		self.id = None
		self.output = None
		self.glycosylationSites = None
		self.numberofGlycSites = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.output = None
		_hx_o.glycosylationSites = None
		_hx_o.numberofGlycSites = None
saturn_core_domain_oppf_OppfNetOGlyc._hx_class = saturn_core_domain_oppf_OppfNetOGlyc
_hx_classes["saturn.core.domain.oppf.OppfNetOGlyc"] = saturn_core_domain_oppf_OppfNetOGlyc


class saturn_core_domain_oppf_OppfNuclearSignals:
	_hx_class_name = "saturn.core.domain.oppf.OppfNuclearSignals"
	_hx_fields = ["id", "results", "summary"]

	def __init__(self):
		self.id = None
		self.results = None
		self.summary = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.results = None
		_hx_o.summary = None
saturn_core_domain_oppf_OppfNuclearSignals._hx_class = saturn_core_domain_oppf_OppfNuclearSignals
_hx_classes["saturn.core.domain.oppf.OppfNuclearSignals"] = saturn_core_domain_oppf_OppfNuclearSignals


class saturn_core_domain_oppf_OppfOpticGroup:
	_hx_class_name = "saturn.core.domain.oppf.OppfOpticGroup"
	_hx_fields = ["id", "name", "description", "readOnly", "type"]

	def __init__(self):
		self.id = None
		self.name = None
		self.description = None
		self.readOnly = None
		self.type = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
		_hx_o.description = None
		_hx_o.readOnly = None
		_hx_o.type = None
saturn_core_domain_oppf_OppfOpticGroup._hx_class = saturn_core_domain_oppf_OppfOpticGroup
_hx_classes["saturn.core.domain.oppf.OppfOpticGroup"] = saturn_core_domain_oppf_OppfOpticGroup


class saturn_core_domain_oppf_OppfPDBBlast:
	_hx_class_name = "saturn.core.domain.oppf.OppfPDBBlast"
	_hx_fields = ["id", "proteinId", "hitDescription", "giNumber", "pdbAccession", "imageNumber", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverHit", "percentageIdentityOverQuery", "hitLengthOverQueryLength", "querySequence", "hitSequence", "midline", "sourceDetails", "crystallisationConditions", "molecularReplacement"]

	def __init__(self):
		self.id = None
		self.proteinId = None
		self.hitDescription = None
		self.giNumber = None
		self.pdbAccession = None
		self.imageNumber = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverHit = None
		self.percentageIdentityOverQuery = None
		self.hitLengthOverQueryLength = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None
		self.sourceDetails = None
		self.crystallisationConditions = None
		self.molecularReplacement = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.proteinId = None
		_hx_o.hitDescription = None
		_hx_o.giNumber = None
		_hx_o.pdbAccession = None
		_hx_o.imageNumber = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverHit = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.hitLengthOverQueryLength = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
		_hx_o.sourceDetails = None
		_hx_o.crystallisationConditions = None
		_hx_o.molecularReplacement = None
saturn_core_domain_oppf_OppfPDBBlast._hx_class = saturn_core_domain_oppf_OppfPDBBlast
_hx_classes["saturn.core.domain.oppf.OppfPDBBlast"] = saturn_core_domain_oppf_OppfPDBBlast


class saturn_core_domain_oppf_OppfPerson:
	_hx_class_name = "saturn.core.domain.oppf.OppfPerson"
	_hx_fields = ["id", "laboratoryId", "surname", "firstname", "title", "email", "phone", "fax", "internal", "management", "password", "createdOn", "personUserId", "admin"]

	def __init__(self):
		self.id = None
		self.laboratoryId = None
		self.surname = None
		self.firstname = None
		self.title = None
		self.email = None
		self.phone = None
		self.fax = None
		self.internal = None
		self.management = None
		self.password = None
		self.createdOn = None
		self.personUserId = None
		self.admin = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.laboratoryId = None
		_hx_o.surname = None
		_hx_o.firstname = None
		_hx_o.title = None
		_hx_o.email = None
		_hx_o.phone = None
		_hx_o.fax = None
		_hx_o.internal = None
		_hx_o.management = None
		_hx_o.password = None
		_hx_o.createdOn = None
		_hx_o.personUserId = None
		_hx_o.admin = None
saturn_core_domain_oppf_OppfPerson._hx_class = saturn_core_domain_oppf_OppfPerson
_hx_classes["saturn.core.domain.oppf.OppfPerson"] = saturn_core_domain_oppf_OppfPerson


class saturn_core_domain_oppf_OppfPersonGroupMapping:
	_hx_class_name = "saturn.core.domain.oppf.OppfPersonGroupMapping"
	_hx_fields = ["personId", "groupId"]

	def __init__(self):
		self.personId = None
		self.groupId = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.personId = None
		_hx_o.groupId = None
saturn_core_domain_oppf_OppfPersonGroupMapping._hx_class = saturn_core_domain_oppf_OppfPersonGroupMapping
_hx_classes["saturn.core.domain.oppf.OppfPersonGroupMapping"] = saturn_core_domain_oppf_OppfPersonGroupMapping


class saturn_core_domain_oppf_OppfProtein:
	_hx_class_name = "saturn.core.domain.oppf.OppfProtein"
	_hx_fields = ["id", "genbankInfoId"]

	def __init__(self):
		self.id = None
		self.genbankInfoId = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.genbankInfoId = None
saturn_core_domain_oppf_OppfProtein._hx_class = saturn_core_domain_oppf_OppfProtein
_hx_classes["saturn.core.domain.oppf.OppfProtein"] = saturn_core_domain_oppf_OppfProtein


class saturn_core_domain_oppf_OppfProteinCalculator:
	_hx_class_name = "saturn.core.domain.oppf.OppfProteinCalculator"
	_hx_fields = ["id", "ala", "arg", "asn", "asp", "gln", "glu", "gly", "his", "ile", "leu", "lys", "met", "phe", "pro", "ser", "thr", "tyr", "val", "trp", "cys", "molWeight", "pi", "ph7Charge", "carbon", "nitrogen", "oxygen", "sulphur", "hydrogen", "gravy"]

	def __init__(self):
		self.id = None
		self.ala = None
		self.arg = None
		self.asn = None
		self.asp = None
		self.gln = None
		self.glu = None
		self.gly = None
		self.his = None
		self.ile = None
		self.leu = None
		self.lys = None
		self.met = None
		self.phe = None
		self.pro = None
		self.ser = None
		self.thr = None
		self.tyr = None
		self.val = None
		self.trp = None
		self.cys = None
		self.molWeight = None
		self.pi = None
		self.ph7Charge = None
		self.carbon = None
		self.nitrogen = None
		self.oxygen = None
		self.sulphur = None
		self.hydrogen = None
		self.gravy = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.ala = None
		_hx_o.arg = None
		_hx_o.asn = None
		_hx_o.asp = None
		_hx_o.gln = None
		_hx_o.glu = None
		_hx_o.gly = None
		_hx_o.his = None
		_hx_o.ile = None
		_hx_o.leu = None
		_hx_o.lys = None
		_hx_o.met = None
		_hx_o.phe = None
		_hx_o.pro = None
		_hx_o.ser = None
		_hx_o.thr = None
		_hx_o.tyr = None
		_hx_o.val = None
		_hx_o.trp = None
		_hx_o.cys = None
		_hx_o.molWeight = None
		_hx_o.pi = None
		_hx_o.ph7Charge = None
		_hx_o.carbon = None
		_hx_o.nitrogen = None
		_hx_o.oxygen = None
		_hx_o.sulphur = None
		_hx_o.hydrogen = None
		_hx_o.gravy = None
saturn_core_domain_oppf_OppfProteinCalculator._hx_class = saturn_core_domain_oppf_OppfProteinCalculator
_hx_classes["saturn.core.domain.oppf.OppfProteinCalculator"] = saturn_core_domain_oppf_OppfProteinCalculator


class saturn_core_domain_oppf_OppfProteinFunction:
	_hx_class_name = "saturn.core.domain.oppf.OppfProteinFunction"
	_hx_fields = ["id", "name"]

	def __init__(self):
		self.id = None
		self.name = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
saturn_core_domain_oppf_OppfProteinFunction._hx_class = saturn_core_domain_oppf_OppfProteinFunction
_hx_classes["saturn.core.domain.oppf.OppfProteinFunction"] = saturn_core_domain_oppf_OppfProteinFunction


class saturn_core_domain_oppf_OppfRPSBlast:
	_hx_class_name = "saturn.core.domain.oppf.OppfRPSBlast"
	_hx_fields = ["id", "proteinId", "hitDescription", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverHit", "percentageIdentityOverQuery", "hitLengthOverQueryLength", "querySequence", "hitSequence", "midline"]

	def __init__(self):
		self.id = None
		self.proteinId = None
		self.hitDescription = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverHit = None
		self.percentageIdentityOverQuery = None
		self.hitLengthOverQueryLength = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.proteinId = None
		_hx_o.hitDescription = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverHit = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.hitLengthOverQueryLength = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
saturn_core_domain_oppf_OppfRPSBlast._hx_class = saturn_core_domain_oppf_OppfRPSBlast
_hx_classes["saturn.core.domain.oppf.OppfRPSBlast"] = saturn_core_domain_oppf_OppfRPSBlast


class saturn_core_domain_oppf_OppfReverseTag:
	_hx_class_name = "saturn.core.domain.oppf.OppfReverseTag"
	_hx_fields = ["id", "name", "sequence"]

	def __init__(self):
		self.id = None
		self.name = None
		self.sequence = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
		_hx_o.sequence = None
saturn_core_domain_oppf_OppfReverseTag._hx_class = saturn_core_domain_oppf_OppfReverseTag
_hx_classes["saturn.core.domain.oppf.OppfReverseTag"] = saturn_core_domain_oppf_OppfReverseTag


class saturn_core_domain_oppf_OppfRonn:
	_hx_class_name = "saturn.core.domain.oppf.OppfRonn"
	_hx_fields = ["id", "disorderedRegions", "graphData", "file"]

	def __init__(self):
		self.id = None
		self.disorderedRegions = None
		self.graphData = None
		self.file = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.disorderedRegions = None
		_hx_o.graphData = None
		_hx_o.file = None
saturn_core_domain_oppf_OppfRonn._hx_class = saturn_core_domain_oppf_OppfRonn
_hx_classes["saturn.core.domain.oppf.OppfRonn"] = saturn_core_domain_oppf_OppfRonn


class saturn_core_domain_oppf_OppfSCOPBlast:
	_hx_class_name = "saturn.core.domain.oppf.OppfSCOPBlast"
	_hx_fields = ["id", "proteinId", "hitDescription", "familyMembers", "superFamilyMembers", "foldMembers", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverHit", "percentageIdentityOverQuery", "hitLengthOverQueryLength", "querySequence", "hitSequence", "midline"]

	def __init__(self):
		self.id = None
		self.proteinId = None
		self.hitDescription = None
		self.familyMembers = None
		self.superFamilyMembers = None
		self.foldMembers = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverHit = None
		self.percentageIdentityOverQuery = None
		self.hitLengthOverQueryLength = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.proteinId = None
		_hx_o.hitDescription = None
		_hx_o.familyMembers = None
		_hx_o.superFamilyMembers = None
		_hx_o.foldMembers = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverHit = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.hitLengthOverQueryLength = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
saturn_core_domain_oppf_OppfSCOPBlast._hx_class = saturn_core_domain_oppf_OppfSCOPBlast
_hx_classes["saturn.core.domain.oppf.OppfSCOPBlast"] = saturn_core_domain_oppf_OppfSCOPBlast


class saturn_core_domain_oppf_OppfShortNames:
	_hx_class_name = "saturn.core.domain.oppf.OppfShortNames"
	_hx_fields = ["id", "shortName", "defaultName"]

	def __init__(self):
		self.id = None
		self.shortName = None
		self.defaultName = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.shortName = None
		_hx_o.defaultName = None
saturn_core_domain_oppf_OppfShortNames._hx_class = saturn_core_domain_oppf_OppfShortNames
_hx_classes["saturn.core.domain.oppf.OppfShortNames"] = saturn_core_domain_oppf_OppfShortNames


class saturn_core_domain_oppf_OppfSignalP:
	_hx_class_name = "saturn.core.domain.oppf.OppfSignalP"
	_hx_fields = ["id", "cMax", "residuePosition", "resultCleavage", "sProb", "resultSignal"]

	def __init__(self):
		self.id = None
		self.cMax = None
		self.residuePosition = None
		self.resultCleavage = None
		self.sProb = None
		self.resultSignal = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.cMax = None
		_hx_o.residuePosition = None
		_hx_o.resultCleavage = None
		_hx_o.sProb = None
		_hx_o.resultSignal = None
saturn_core_domain_oppf_OppfSignalP._hx_class = saturn_core_domain_oppf_OppfSignalP
_hx_classes["saturn.core.domain.oppf.OppfSignalP"] = saturn_core_domain_oppf_OppfSignalP


class saturn_core_domain_oppf_OppfSpecies:
	_hx_class_name = "saturn.core.domain.oppf.OppfSpecies"
	_hx_fields = ["id", "scientificName", "commonName", "lineage"]

	def __init__(self):
		self.id = None
		self.scientificName = None
		self.commonName = None
		self.lineage = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.scientificName = None
		_hx_o.commonName = None
		_hx_o.lineage = None
saturn_core_domain_oppf_OppfSpecies._hx_class = saturn_core_domain_oppf_OppfSpecies
_hx_classes["saturn.core.domain.oppf.OppfSpecies"] = saturn_core_domain_oppf_OppfSpecies


class saturn_core_domain_oppf_OppfSwissProtBlast:
	_hx_class_name = "saturn.core.domain.oppf.OppfSwissProtBlast"
	_hx_fields = ["id", "hitDescription", "swissProtAccession", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverHit", "percentageIdentityOverQuery", "hitLengthOverQueryLength", "querySequence", "hitSequence", "midline"]

	def __init__(self):
		self.id = None
		self.hitDescription = None
		self.swissProtAccession = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverHit = None
		self.percentageIdentityOverQuery = None
		self.hitLengthOverQueryLength = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.hitDescription = None
		_hx_o.swissProtAccession = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverHit = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.hitLengthOverQueryLength = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
saturn_core_domain_oppf_OppfSwissProtBlast._hx_class = saturn_core_domain_oppf_OppfSwissProtBlast
_hx_classes["saturn.core.domain.oppf.OppfSwissProtBlast"] = saturn_core_domain_oppf_OppfSwissProtBlast


class saturn_core_domain_oppf_OppfTargetAccess:
	_hx_class_name = "saturn.core.domain.oppf.OppfTargetAccess"
	_hx_fields = ["id", "access", "assignedBy", "assignedAt"]

	def __init__(self):
		self.id = None
		self.access = None
		self.assignedBy = None
		self.assignedAt = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.access = None
		_hx_o.assignedBy = None
		_hx_o.assignedAt = None
saturn_core_domain_oppf_OppfTargetAccess._hx_class = saturn_core_domain_oppf_OppfTargetAccess
_hx_classes["saturn.core.domain.oppf.OppfTargetAccess"] = saturn_core_domain_oppf_OppfTargetAccess


class saturn_core_domain_oppf_OppfTargetDB:
	_hx_class_name = "saturn.core.domain.oppf.OppfTargetDB"
	_hx_fields = ["id", "proteinId", "hitDescription", "queryLength", "hitLength", "hspScore", "hspEValue", "queryFrom", "queryTo", "hitFrom", "hitTo", "identities", "positives", "gaps", "alignmentLength", "percentageIdentityOverAlignment", "percentageIdentityOverHit", "percentageIdentityOverQuery", "hitLengthOverQueryLength", "querySequence", "hitSequence", "midline"]

	def __init__(self):
		self.id = None
		self.proteinId = None
		self.hitDescription = None
		self.queryLength = None
		self.hitLength = None
		self.hspScore = None
		self.hspEValue = None
		self.queryFrom = None
		self.queryTo = None
		self.hitFrom = None
		self.hitTo = None
		self.identities = None
		self.positives = None
		self.gaps = None
		self.alignmentLength = None
		self.percentageIdentityOverAlignment = None
		self.percentageIdentityOverHit = None
		self.percentageIdentityOverQuery = None
		self.hitLengthOverQueryLength = None
		self.querySequence = None
		self.hitSequence = None
		self.midline = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.proteinId = None
		_hx_o.hitDescription = None
		_hx_o.queryLength = None
		_hx_o.hitLength = None
		_hx_o.hspScore = None
		_hx_o.hspEValue = None
		_hx_o.queryFrom = None
		_hx_o.queryTo = None
		_hx_o.hitFrom = None
		_hx_o.hitTo = None
		_hx_o.identities = None
		_hx_o.positives = None
		_hx_o.gaps = None
		_hx_o.alignmentLength = None
		_hx_o.percentageIdentityOverAlignment = None
		_hx_o.percentageIdentityOverHit = None
		_hx_o.percentageIdentityOverQuery = None
		_hx_o.hitLengthOverQueryLength = None
		_hx_o.querySequence = None
		_hx_o.hitSequence = None
		_hx_o.midline = None
saturn_core_domain_oppf_OppfTargetDB._hx_class = saturn_core_domain_oppf_OppfTargetDB
_hx_classes["saturn.core.domain.oppf.OppfTargetDB"] = saturn_core_domain_oppf_OppfTargetDB


class saturn_core_domain_oppf_OppfTransmembrane:
	_hx_class_name = "saturn.core.domain.oppf.OppfTransmembrane"
	_hx_fields = ["id", "length", "expaa", "first60", "predictedHelix", "topology"]

	def __init__(self):
		self.id = None
		self.length = None
		self.expaa = None
		self.first60 = None
		self.predictedHelix = None
		self.topology = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.length = None
		_hx_o.expaa = None
		_hx_o.first60 = None
		_hx_o.predictedHelix = None
		_hx_o.topology = None
saturn_core_domain_oppf_OppfTransmembrane._hx_class = saturn_core_domain_oppf_OppfTransmembrane
_hx_classes["saturn.core.domain.oppf.OppfTransmembrane"] = saturn_core_domain_oppf_OppfTransmembrane


class saturn_core_domain_oppf_OppfVector:
	_hx_class_name = "saturn.core.domain.oppf.OppfVector"
	_hx_fields = ["id", "name", "antibiotic", "background", "product", "infusion", "periplasm", "eukaryotic", "bacterial", "mammalian", "insect", "stable", "status", "rank", "res1", "res2", "fwdSequence", "revSequence", "glycerolPos"]

	def __init__(self):
		self.id = None
		self.name = None
		self.antibiotic = None
		self.background = None
		self.product = None
		self.infusion = None
		self.periplasm = None
		self.eukaryotic = None
		self.bacterial = None
		self.mammalian = None
		self.insect = None
		self.stable = None
		self.status = None
		self.rank = None
		self.res1 = None
		self.res2 = None
		self.fwdSequence = None
		self.revSequence = None
		self.glycerolPos = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.id = None
		_hx_o.name = None
		_hx_o.antibiotic = None
		_hx_o.background = None
		_hx_o.product = None
		_hx_o.infusion = None
		_hx_o.periplasm = None
		_hx_o.eukaryotic = None
		_hx_o.bacterial = None
		_hx_o.mammalian = None
		_hx_o.insect = None
		_hx_o.stable = None
		_hx_o.status = None
		_hx_o.rank = None
		_hx_o.res1 = None
		_hx_o.res2 = None
		_hx_o.fwdSequence = None
		_hx_o.revSequence = None
		_hx_o.glycerolPos = None
saturn_core_domain_oppf_OppfVector._hx_class = saturn_core_domain_oppf_OppfVector
_hx_classes["saturn.core.domain.oppf.OppfVector"] = saturn_core_domain_oppf_OppfVector


class saturn_core_domain_oppf_OppfVectorForwardTag:
	_hx_class_name = "saturn.core.domain.oppf.OppfVectorForwardTag"
	_hx_fields = ["vectorId", "fwdTagId"]

	def __init__(self):
		self.vectorId = None
		self.fwdTagId = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.vectorId = None
		_hx_o.fwdTagId = None
saturn_core_domain_oppf_OppfVectorForwardTag._hx_class = saturn_core_domain_oppf_OppfVectorForwardTag
_hx_classes["saturn.core.domain.oppf.OppfVectorForwardTag"] = saturn_core_domain_oppf_OppfVectorForwardTag


class saturn_core_domain_oppf_OppfVectorReverseTag:
	_hx_class_name = "saturn.core.domain.oppf.OppfVectorReverseTag"
	_hx_fields = ["vectorId", "revTagId"]

	def __init__(self):
		self.vectorId = None
		self.revTagId = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.vectorId = None
		_hx_o.revTagId = None
saturn_core_domain_oppf_OppfVectorReverseTag._hx_class = saturn_core_domain_oppf_OppfVectorReverseTag
_hx_classes["saturn.core.domain.oppf.OppfVectorReverseTag"] = saturn_core_domain_oppf_OppfVectorReverseTag

class saturn_core_molecule_MoleculeFloatAttribute(Enum):
	_hx_class_name = "saturn.core.molecule.MoleculeFloatAttribute"
	_hx_constructs = ["MW", "MW_CONDESATION"]
saturn_core_molecule_MoleculeFloatAttribute.MW = saturn_core_molecule_MoleculeFloatAttribute("MW", 0, list())
saturn_core_molecule_MoleculeFloatAttribute.MW_CONDESATION = saturn_core_molecule_MoleculeFloatAttribute("MW_CONDESATION", 1, list())
saturn_core_molecule_MoleculeFloatAttribute._hx_class = saturn_core_molecule_MoleculeFloatAttribute
_hx_classes["saturn.core.molecule.MoleculeFloatAttribute"] = saturn_core_molecule_MoleculeFloatAttribute

class saturn_core_molecule_MoleculeStringAttribute(Enum):
	_hx_class_name = "saturn.core.molecule.MoleculeStringAttribute"
	_hx_constructs = ["NAME"]
saturn_core_molecule_MoleculeStringAttribute.NAME = saturn_core_molecule_MoleculeStringAttribute("NAME", 0, list())
saturn_core_molecule_MoleculeStringAttribute._hx_class = saturn_core_molecule_MoleculeStringAttribute
_hx_classes["saturn.core.molecule.MoleculeStringAttribute"] = saturn_core_molecule_MoleculeStringAttribute

class saturn_core_molecule_MoleculeAlignMode(Enum):
	_hx_class_name = "saturn.core.molecule.MoleculeAlignMode"
	_hx_constructs = ["REGEX", "SIMPLE"]
saturn_core_molecule_MoleculeAlignMode.REGEX = saturn_core_molecule_MoleculeAlignMode("REGEX", 0, list())
saturn_core_molecule_MoleculeAlignMode.SIMPLE = saturn_core_molecule_MoleculeAlignMode("SIMPLE", 1, list())
saturn_core_molecule_MoleculeAlignMode._hx_class = saturn_core_molecule_MoleculeAlignMode
_hx_classes["saturn.core.molecule.MoleculeAlignMode"] = saturn_core_molecule_MoleculeAlignMode


class saturn_core_molecule_MoleculeConstants:
	_hx_class_name = "saturn.core.molecule.MoleculeConstants"
	_hx_statics = ["aMW", "tMW", "gMW", "cMW", "aChainMW", "tChainMW", "gChainMW", "cChainMW", "O2H", "OH", "PO3"]
saturn_core_molecule_MoleculeConstants._hx_class = saturn_core_molecule_MoleculeConstants
_hx_classes["saturn.core.molecule.MoleculeConstants"] = saturn_core_molecule_MoleculeConstants

class saturn_core_molecule_MoleculeSets(Enum):
	_hx_class_name = "saturn.core.molecule.MoleculeSets"
	_hx_constructs = ["STANDARD"]
saturn_core_molecule_MoleculeSets.STANDARD = saturn_core_molecule_MoleculeSets("STANDARD", 0, list())
saturn_core_molecule_MoleculeSets._hx_class = saturn_core_molecule_MoleculeSets
_hx_classes["saturn.core.molecule.MoleculeSets"] = saturn_core_molecule_MoleculeSets


class saturn_core_molecule_MoleculeSetRegistry:
	_hx_class_name = "saturn.core.molecule.MoleculeSetRegistry"
	_hx_fields = ["moleculeSets"]
	_hx_methods = ["register", "get", "registerSet", "getSet"]
	_hx_statics = ["defaultRegistry", "getStandardMoleculeSet"]

	def __init__(self):
		self.moleculeSets = None
		self.moleculeSets = haxe_ds_StringMap()
		self.register(saturn_core_molecule_MoleculeSets.STANDARD,saturn_core_StandardMoleculeSet())

	def register(self,setType,_hx_set):
		self.registerSet(Std.string(setType),_hx_set)

	def get(self,setType):
		return self.getSet(Std.string(setType))

	def registerSet(self,name,_hx_set):
		self.moleculeSets.h[name] = _hx_set

	def getSet(self,name):
		return self.moleculeSets.h.get(name,None)

	@staticmethod
	def getStandardMoleculeSet():
		return saturn_core_molecule_MoleculeSetRegistry.defaultRegistry.get(saturn_core_molecule_MoleculeSets.STANDARD)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.moleculeSets = None
saturn_core_molecule_MoleculeSetRegistry._hx_class = saturn_core_molecule_MoleculeSetRegistry
_hx_classes["saturn.core.molecule.MoleculeSetRegistry"] = saturn_core_molecule_MoleculeSetRegistry


class saturn_core_parsers_BaseParser(saturn_core_Generator):
	_hx_class_name = "saturn.core.parsers.BaseParser"
	_hx_fields = ["doneCB", "path", "content", "lineCount"]
	_hx_methods = ["setContent", "read", "parseLine"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_core_Generator


	def __init__(self,path,handler,done):
		self.doneCB = None
		self.path = None
		self.content = None
		self.lineCount = None
		self.lineCount = 0
		_g = self
		super().__init__(-1)
		self.doneCB = done
		self.path = path
		self.setMaxAtOnce(200)
		self.onEnd(done)
		def _hx_local_0(objs,next,c):
			handler(objs,_g)
		self.onNext(_hx_local_0)
		if (path is not None):
			self.read()

	def setContent(self,content):
		self.content = content
		self.read()

	def read(self):
		_g = self
		if (self.path is not None):
			def _hx_local_1(err,line):
				if (err is not None):
					_g.die("Error reading file")
				else:
					_g.lineCount = (_g.lineCount + 1)
					if (line is None):
						saturn_core_Util.debug(("Lines read: " + Std.string(_g.lineCount)))
						_g.finished()
					else:
						obj = _g.parseLine(line)
						if (obj is not None):
							_g.push(obj)
			saturn_core_Util.open(self.path,_hx_local_1)
		elif (self.content is not None):
			lines = None
			_this = self.content
			lines = _this.split("\n")
			_g1 = 0
			while (_g1 < len(lines)):
				line1 = (lines[_g1] if _g1 >= 0 and _g1 < len(lines) else None)
				_g1 = (_g1 + 1)
				obj1 = self.parseLine(line1)
				if (obj1 is not None):
					self.push(obj1)
			self.finished()

	def parseLine(self,line):
		return None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.doneCB = None
		_hx_o.path = None
		_hx_o.content = None
		_hx_o.lineCount = None
saturn_core_parsers_BaseParser._hx_class = saturn_core_parsers_BaseParser
_hx_classes["saturn.core.parsers.BaseParser"] = saturn_core_parsers_BaseParser


class saturn_db_BatchFetch:
	_hx_class_name = "saturn.db.BatchFetch"
	_hx_fields = ["fetchList", "userOnError", "userOnComplete", "position", "retrieved", "onComplete", "onError", "provider", "items"]
	_hx_methods = ["onFinish", "getById", "getByIds", "getByValue", "getByValues", "getByPkey", "getByPkeys", "append", "next", "setProvider", "execute", "getObject"]

	def __init__(self,onError):
		self.fetchList = None
		self.userOnError = None
		self.userOnComplete = None
		self.position = None
		self.retrieved = None
		self.onComplete = None
		self.onError = None
		self.provider = None
		self.items = None
		self.items = haxe_ds_StringMap()
		self.fetchList = list()
		self.retrieved = haxe_ds_StringMap()
		self.position = 0
		self.onError = onError

	def onFinish(self,cb):
		self.onComplete = cb

	def getById(self,objectId,clazz,key,callBack):
		_hx_list = list()
		_hx_list.append(objectId)
		return self.getByIds(_hx_list,clazz,key,callBack)

	def getByIds(self,objectIds,clazz,key,callBack):
		work = haxe_ds_StringMap()
		work.h["IDS"] = objectIds
		work.h["CLASS"] = clazz
		work.h["TYPE"] = "getByIds"
		work.h["KEY"] = key
		value = callBack
		value1 = value
		work.h["CALLBACK"] = value1
		_this = self.fetchList
		_this.append(work)
		return self

	def getByValue(self,value,clazz,field,key,callBack):
		_hx_list = list()
		_hx_list.append(value)
		return self.getByValues(_hx_list,clazz,field,key,callBack)

	def getByValues(self,values,clazz,field,key,callBack):
		work = haxe_ds_StringMap()
		work.h["VALUES"] = values
		work.h["CLASS"] = clazz
		work.h["FIELD"] = field
		work.h["TYPE"] = "getByValues"
		work.h["KEY"] = key
		value = callBack
		value1 = value
		work.h["CALLBACK"] = value1
		_this = self.fetchList
		_this.append(work)
		return self

	def getByPkey(self,objectId,clazz,key,callBack):
		_hx_list = list()
		x = objectId
		_hx_list.append(x)
		return self.getByPkeys(_hx_list,clazz,key,callBack)

	def getByPkeys(self,objectIds,clazz,key,callBack):
		work = haxe_ds_StringMap()
		work.h["IDS"] = objectIds
		work.h["CLASS"] = clazz
		work.h["TYPE"] = "getByPkeys"
		work.h["KEY"] = key
		value = callBack
		value1 = value
		work.h["CALLBACK"] = value1
		_this = self.fetchList
		_this.append(work)
		return self

	def append(self,val,field,clazz,cb):
		key = ((HxOverrides.stringOrNull(Type.getClassName(clazz)) + ".") + ("null" if field is None else field))
		if (not key in self.items.h):
			value = list()
			self.items.h[key] = value
		_this = self.items.h.get(key,None)
		_this.append(_hx_AnonObject({'val': val, 'field': field, 'clazz': clazz, 'cb': cb}))

	def next(self):
		self.execute()

	def setProvider(self,provider):
		self.provider = provider

	def execute(self,cb = None):
		_g = self
		provider = self.provider
		if (provider is None):
			provider = saturn_client_core_CommonCore.getDefaultProvider()
		if (cb is not None):
			self.onFinish(cb)
		_hx_local_0 = self.items.keys()
		while _hx_local_0.hasNext():
			key = _hx_local_0.next()
			units = self.items.h.get(key,None)
			work = haxe_ds_StringMap()
			work.h["TYPE"] = "FETCHITEM"
			work.h["FIELD"] = (units[0] if 0 < len(units) else None).field
			work.h["CLASS"] = (units[0] if 0 < len(units) else None).clazz
			work.h["ITEMS"] = units
			self.items.remove(key)
			_this = self.fetchList
			_this.append(work)
		if (self.position == len(self.fetchList)):
			self.onComplete()
			return
		work1 = python_internal_ArrayImpl._get(self.fetchList, self.position)
		_hx_type = work1.h.get("TYPE",None)
		_hx_local_1 = self
		_hx_local_2 = _hx_local_1.position
		_hx_local_1.position = (_hx_local_2 + 1)
		_hx_local_2
		if (_hx_type == "getByIds"):
			def _hx_local_3(objs,exception):
				if ((exception is not None) or ((objs is None))):
					_g.onError(objs,exception)
				else:
					key1 = work1.h.get("KEY",None)
					_g.retrieved.h[key1] = objs
					userCallBack = work1.h.get("CALLBACK",None)
					if (userCallBack is not None):
						userCallBack(objs,exception)
					elif (_g.position == len(_g.fetchList)):
						_g.onComplete()
					else:
						_g.execute()
			provider.getByIds(work1.h.get("IDS",None),work1.h.get("CLASS",None),_hx_local_3)
		elif (_hx_type == "getByValues"):
			def _hx_local_4(objs1,exception1):
				if ((exception1 is not None) or ((objs1 is None))):
					_g.onError(objs1,exception1)
				else:
					key2 = work1.h.get("KEY",None)
					_g.retrieved.h[key2] = objs1
					userCallBack1 = work1.h.get("CALLBACK",None)
					if (userCallBack1 is not None):
						userCallBack1(objs1,exception1)
					elif (_g.position == len(_g.fetchList)):
						_g.onComplete()
					else:
						_g.execute()
			provider.getByValues(work1.h.get("VALUES",None),work1.h.get("CLASS",None),work1.h.get("FIELD",None),_hx_local_4)
		elif (_hx_type == "getByPkeys"):
			def _hx_local_5(obj,exception2):
				if ((exception2 is not None) or ((obj is None))):
					_g.onError(obj,exception2)
				else:
					key3 = work1.h.get("KEY",None)
					_g.retrieved.h[key3] = obj
					userCallBack2 = work1.h.get("CALLBACK",None)
					if (userCallBack2 is not None):
						userCallBack2(obj,exception2)
					elif (_g.position == len(_g.fetchList)):
						_g.onComplete()
					else:
						_g.execute()
			provider.getByPkeys(work1.h.get("IDS",None),work1.h.get("CLASS",None),_hx_local_5)
		elif (_hx_type == "FETCHITEM"):
			items = work1.h.get("ITEMS",None)
			itemMap = haxe_ds_StringMap()
			_g1 = 0
			while (_g1 < len(items)):
				item = (items[_g1] if _g1 >= 0 and _g1 < len(items) else None)
				_g1 = (_g1 + 1)
				if (not item.val in itemMap.h):
					value = list()
					itemMap.h[item.val] = value
				_this1 = itemMap.h.get(item.val,None)
				_this1.append(item.cb)
			values = list()
			_hx_local_7 = itemMap.keys()
			while _hx_local_7.hasNext():
				key4 = _hx_local_7.next()
				values.append(key4)
			field = work1.h.get("FIELD",None)
			def _hx_local_10(objs2,exception3):
				if ((exception3 is not None) or ((objs2 is None))):
					_g.onError(objs2,exception3)
				else:
					_g2 = 0
					while (_g2 < len(objs2)):
						obj1 = (objs2[_g2] if _g2 >= 0 and _g2 < len(objs2) else None)
						_g2 = (_g2 + 1)
						fieldValue = Reflect.field(obj1,field)
						if fieldValue in itemMap.h:
							_g11 = 0
							_g21 = itemMap.h.get(fieldValue,None)
							while (_g11 < len(_g21)):
								cb1 = (_g21[_g11] if _g11 >= 0 and _g11 < len(_g21) else None)
								_g11 = (_g11 + 1)
								cb1(obj1)
					if (_g.position == len(_g.fetchList)):
						_g.onComplete()
					else:
						_g.execute()
			provider.getByValues(values,work1.h.get("CLASS",None),field,_hx_local_10)

	def getObject(self,key):
		return self.retrieved.h.get(key,None)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.fetchList = None
		_hx_o.userOnError = None
		_hx_o.userOnComplete = None
		_hx_o.position = None
		_hx_o.retrieved = None
		_hx_o.onComplete = None
		_hx_o.onError = None
		_hx_o.provider = None
		_hx_o.items = None
saturn_db_BatchFetch._hx_class = saturn_db_BatchFetch
_hx_classes["saturn.db.BatchFetch"] = saturn_db_BatchFetch


class saturn_db_Connection:
	_hx_class_name = "saturn.db.Connection"
	_hx_methods = ["execute", "close", "commit", "setAutoCommit"]
saturn_db_Connection._hx_class = saturn_db_Connection
_hx_classes["saturn.db.Connection"] = saturn_db_Connection


class saturn_db_Provider:
	_hx_class_name = "saturn.db.Provider"
	_hx_methods = ["getById", "getByIds", "getByPkey", "getByPkeys", "getByIdStartsWith", "update", "insert", "delete", "generateQualifiedName", "updateObjects", "insertObjects", "insertOrUpdate", "rollback", "commit", "isAttached", "sql", "getByNamedQuery", "getObjectFromCache", "activate", "getModel", "getObjectModel", "save", "modelToReal", "attach", "resetCache", "evictNamedQuery", "readModels", "dataBinding", "isDataBinding", "setSelectClause", "_update", "_insert", "_delete", "getByValue", "getByValues", "getObjects", "queryPath", "getModels", "getModelClasses", "connectAsUser", "setConnectAsUser", "enableCache", "generatedLinkedClone", "setUser", "getUser", "closeConnection", "_closeConnection", "setAutoCommit", "setName", "getName", "getConfig", "evictObject", "getByExample", "query", "getQuery", "getProviderType", "getModelByStringName", "getConnection", "uploadFile"]
saturn_db_Provider._hx_class = saturn_db_Provider
_hx_classes["saturn.db.Provider"] = saturn_db_Provider


class saturn_db_DefaultProvider:
	_hx_class_name = "saturn.db.DefaultProvider"
	_hx_fields = ["theBindingMap", "fieldIndexMap", "objectCache", "namedQueryCache", "useCache", "enableBinding", "connectWithUserCreds", "namedQueryHooks", "namedQueryHookConfigs", "modelClasses", "user", "autoClose", "name", "config", "winConversions", "linConversions", "conversions", "regexs", "platform"]
	_hx_methods = ["setPlatform", "generateQualifiedName", "getConfig", "setName", "getName", "setUser", "getUser", "closeConnection", "_closeConnection", "generatedLinkedClone", "enableCache", "connectAsUser", "setConnectAsUser", "setModels", "readModels", "postConfigureModels", "getModels", "resetCache", "getObjectFromCache", "initialiseObjects", "getById", "getByIds", "_getByIds", "getByExample", "query", "_query", "getByValue", "getByValues", "_getByValues", "getObjects", "_getObjects", "getByPkey", "getByPkeys", "_getByPkeys", "getConnection", "sql", "getByNamedQuery", "addHooks", "_getByNamedQuery", "getByIdStartsWith", "_getByIdStartsWith", "update", "insert", "delete", "evictObject", "evictNamedQuery", "updateObjects", "insertObjects", "rollback", "commit", "_update", "_insert", "_delete", "_rollback", "_commit", "bindObject", "unbindObject", "activate", "_activate", "merge", "_merge", "getModel", "getObjectModel", "save", "initModelClasses", "getModelClasses", "getModelByStringName", "isModel", "setSelectClause", "modelToReal", "dataBinding", "isDataBinding", "queryPath", "setAutoCommit", "attach", "synchronizeInternalLinks", "_attach", "getQuery", "getProviderType", "isAttached", "insertOrUpdate", "uploadFile"]
	_hx_statics = ["r_date"]
	_hx_interfaces = [saturn_db_Provider]

	def __init__(self,binding_map,config,autoClose):
		self.theBindingMap = None
		self.fieldIndexMap = None
		self.objectCache = None
		self.namedQueryCache = None
		self.useCache = None
		self.enableBinding = None
		self.connectWithUserCreds = None
		self.namedQueryHooks = None
		self.namedQueryHookConfigs = None
		self.modelClasses = None
		self.user = None
		self.autoClose = None
		self.name = None
		self.config = None
		self.winConversions = None
		self.linConversions = None
		self.conversions = None
		self.regexs = None
		self.platform = None
		self.user = None
		self.namedQueryHookConfigs = haxe_ds_StringMap()
		self.namedQueryHooks = haxe_ds_StringMap()
		self.connectWithUserCreds = False
		self.enableBinding = True
		self.useCache = True
		self.setPlatform()
		if (binding_map is not None):
			self.setModels(binding_map)
		self.config = config
		self.autoClose = autoClose
		self.namedQueryHooks = haxe_ds_StringMap()
		if ((config is not None) and hasattr(config,(("_hx_" + "named_query_hooks") if ("named_query_hooks" in python_Boot.keywords) else (("_hx_" + "named_query_hooks") if (((((len("named_query_hooks") > 2) and ((ord("named_query_hooks"[0]) == 95))) and ((ord("named_query_hooks"[1]) == 95))) and ((ord("named_query_hooks"[(len("named_query_hooks") - 1)]) != 95)))) else "named_query_hooks")))):
			self.addHooks(Reflect.field(config,"named_query_hooks"))
		_hx_local_0 = self.namedQueryHooks.keys()
		while _hx_local_0.hasNext():
			hook = _hx_local_0.next()
			saturn_core_Util.debug(((("Installed hook: " + ("null" if hook is None else hook)) + "/") + Std.string(self.namedQueryHooks.h.get(hook,None))))

	def setPlatform(self):
		pass

	def generateQualifiedName(self,schemaName,tableName):
		return None

	def getConfig(self):
		return self.config

	def setName(self,name):
		self.name = name

	def getName(self):
		return self.name

	def setUser(self,user):
		self.user = user
		self._closeConnection()

	def getUser(self):
		return self.user

	def closeConnection(self,connection):
		if self.autoClose:
			self._closeConnection()

	def _closeConnection(self):
		pass

	def generatedLinkedClone(self):
		clazz = Type.getClass(self)
		provider = Type.createEmptyInstance(clazz)
		provider.theBindingMap = self.theBindingMap
		provider.fieldIndexMap = self.fieldIndexMap
		provider.namedQueryCache = self.namedQueryCache
		provider.useCache = self.useCache
		provider.enableBinding = self.enableBinding
		provider.connectWithUserCreds = self.connectWithUserCreds
		provider.namedQueryHooks = self.namedQueryHooks
		provider.modelClasses = self.modelClasses
		provider.platform = self.platform
		provider.linConversions = self.linConversions
		provider.winConversions = self.winConversions
		provider.conversions = self.conversions
		provider.regexs = self.regexs
		return provider

	def enableCache(self,cached):
		self.useCache = cached

	def connectAsUser(self):
		return self.connectWithUserCreds

	def setConnectAsUser(self,asUser):
		self.connectWithUserCreds = asUser

	def setModels(self,binding_map):
		self.theBindingMap = binding_map
		_hx_local_3 = binding_map.keys()
		while _hx_local_3.hasNext():
			clazz = _hx_local_3.next()
			def _hx_local_0():
				this1 = binding_map.h.get(clazz,None)
				return this1.exists("polymorphic")
			if _hx_local_0():
				def _hx_local_1():
					this2 = binding_map.h.get(clazz,None)
					return this2.exists("fields.synthetic")
				if (not _hx_local_1()):
					this3 = binding_map.h.get(clazz,None)
					value = haxe_ds_StringMap()
					this3.set("fields.synthetic",value)
				d = None
				this4 = binding_map.h.get(clazz,None)
				d = this4.get("fields.synthetic")
				def _hx_local_2():
					this5 = binding_map.h.get(clazz,None)
					return this5.get("polymorphic")
				Reflect.field(d,"set")("polymorphic",_hx_local_2())
		self.initModelClasses()
		self.resetCache()

	def readModels(self,cb):
		pass

	def postConfigureModels(self):
		_hx_local_0 = self.theBindingMap.keys()
		while _hx_local_0.hasNext():
			class_name = _hx_local_0.next()
			d = self.theBindingMap.h.get(class_name,None)
			value = self.getName()
			value1 = value
			d.h["provider_name"] = value1
		if self.isModel(saturn_core_domain_FileProxy):
			this1 = self.getModel(saturn_core_domain_FileProxy).getOptions()
			self.winConversions = this1.get("windows_conversions")
			this2 = self.getModel(saturn_core_domain_FileProxy).getOptions()
			self.linConversions = this2.get("linux_conversions")
			if (self.platform == "windows"):
				self.conversions = self.winConversions
				this3 = self.getModel(saturn_core_domain_FileProxy).getOptions()
				self.regexs = this3.get("windows_allowed_paths_regex")
			elif (self.platform == "linux"):
				self.conversions = self.linConversions
				this4 = self.getModel(saturn_core_domain_FileProxy).getOptions()
				self.regexs = this4.get("linux_allowed_paths_regex")
			if (self.regexs is not None):
				_hx_local_2 = self.regexs.keys()
				while _hx_local_2.hasNext():
					key = _hx_local_2.next()
					s = None
					def _hx_local_0():
						_hx_local_1 = self.regexs.h.get(key,None)
						if Std._hx_is(_hx_local_1,str):
							_hx_local_1
						else:
							raise _HxException("Class cast error")
						return _hx_local_1
					s = _hx_local_0()
					value2 = EReg(s, "")
					self.regexs.h[key] = value2

	def getModels(self):
		return self.theBindingMap

	def resetCache(self):
		self.objectCache = haxe_ds_StringMap()
		_hx_local_3 = self.theBindingMap.keys()
		while _hx_local_3.hasNext():
			className = _hx_local_3.next()
			this1 = self.theBindingMap.h.get(className,None)
			value = haxe_ds_StringMap()
			this1.set("statements",value)
			value1 = haxe_ds_StringMap()
			self.objectCache.h[className] = value1
			def _hx_local_0():
				this2 = self.theBindingMap.h.get(className,None)
				return this2.exists("indexes")
			if _hx_local_0():
				def _hx_local_1():
					this3 = None
					this4 = self.theBindingMap.h.get(className,None)
					this3 = this4.get("indexes")
					return this3.keys()
				_hx_local_2 = _hx_local_1()
				while _hx_local_2.hasNext():
					field = _hx_local_2.next()
					this5 = self.objectCache.h.get(className,None)
					value2 = haxe_ds_StringMap()
					this5.set(field,value2)
		self.namedQueryCache = haxe_ds_StringMap()

	def getObjectFromCache(self,clazz,field,val):
		className = Type.getClassName(clazz)
		if className in self.objectCache.h:
			def _hx_local_0():
				this1 = self.objectCache.h.get(className,None)
				return this1.exists(field)
			if _hx_local_0():
				def _hx_local_1():
					this2 = None
					this3 = self.objectCache.h.get(className,None)
					this2 = this3.get(field)
					key = val
					return this2.exists(key)
				if _hx_local_1():
					this4 = None
					this5 = self.objectCache.h.get(className,None)
					this4 = this5.get(field)
					key1 = val
					return this4.get(key1)
				else:
					return None
			else:
				return None
		else:
			return None

	def initialiseObjects(self,idsToFetch,toBind,prefetched,exception,callBack,clazz,bindField,cache,allowAutoBind = True):
		if (allowAutoBind is None):
			allowAutoBind = True
		if ((((len(idsToFetch) > 0) and ((toBind is None))) or ((clazz is None))) or (((((toBind is not None) and ((len(toBind) > 0))) and ((clazz is not None))) and Std._hx_is((toBind[0] if 0 < len(toBind) else None),clazz)))):
			callBack(toBind,exception)
		else:
			model = self.getModel(clazz)
			if (model is None):
				boundObjs = list()
				_g = 0
				while (_g < len(toBind)):
					item = (toBind[_g] if _g >= 0 and _g < len(toBind) else None)
					_g = (_g + 1)
					obj = Type.createInstance(clazz,[])
					_g1 = 0
					_g2 = python_Boot.getInstanceFields(clazz)
					while (_g1 < len(_g2)):
						field = (_g2[_g1] if _g1 >= 0 and _g1 < len(_g2) else None)
						_g1 = (_g1 + 1)
						if hasattr(item,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field))):
							value = Reflect.field(item,field)
							setattr(obj,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)),value)
					boundObjs.append(obj)
				callBack(boundObjs,exception)
				return
			autoActivate = model.getAutoActivateLevel()
			surpressSetup = False
			if (((autoActivate != -1) and self.enableBinding) and allowAutoBind):
				surpressSetup = True
			boundObjs1 = list()
			if (toBind is not None):
				_g3 = 0
				while (_g3 < len(toBind)):
					obj1 = (toBind[_g3] if _g3 >= 0 and _g3 < len(toBind) else None)
					_g3 = (_g3 + 1)
					x = self.bindObject(obj1,clazz,cache,bindField,surpressSetup)
					boundObjs1.append(x)
			if (((autoActivate != -1) and self.enableBinding) and allowAutoBind):
				def _hx_local_5(err):
					if (err is None):
						_g4 = 0
						while (_g4 < len(boundObjs1)):
							boundObj = (boundObjs1[_g4] if _g4 >= 0 and _g4 < len(boundObjs1) else None)
							_g4 = (_g4 + 1)
							if Reflect.isFunction(Reflect.field(boundObj,"setup")):
								Reflect.field(boundObj,"setup")()
						if (prefetched is not None):
							_g5 = 0
							while (_g5 < len(prefetched)):
								obj2 = (prefetched[_g5] if _g5 >= 0 and _g5 < len(prefetched) else None)
								_g5 = (_g5 + 1)
								x1 = obj2
								boundObjs1.append(x1)
						callBack(boundObjs1,exception)
					else:
						callBack(None,err)
				self.activate(boundObjs1,autoActivate,_hx_local_5)
			else:
				if (prefetched is not None):
					_g6 = 0
					while (_g6 < len(prefetched)):
						obj3 = (prefetched[_g6] if _g6 >= 0 and _g6 < len(prefetched) else None)
						_g6 = (_g6 + 1)
						x2 = obj3
						boundObjs1.append(x2)
				callBack(boundObjs1,exception)

	def getById(self,id,clazz,callBack):
		def _hx_local_0(objs,exception):
			if (objs is not None):
				callBack((objs[0] if 0 < len(objs) else None),exception)
			else:
				callBack(None,exception)
		self.getByIds([id],clazz,_hx_local_0)

	def getByIds(self,ids,clazz,callBack):
		_g = self
		prefetched = None
		idsToFetch = None
		if self.useCache:
			model = self.getModel(clazz)
			if (model is not None):
				firstKey = model.getFirstKey()
				prefetched = list()
				idsToFetch = list()
				_g1 = 0
				while (_g1 < len(ids)):
					id = (ids[_g1] if _g1 >= 0 and _g1 < len(ids) else None)
					_g1 = (_g1 + 1)
					cacheObject = self.getObjectFromCache(clazz,firstKey,id)
					if (cacheObject is not None):
						prefetched.append(cacheObject)
					else:
						idsToFetch.append(id)
			else:
				idsToFetch = ids
		else:
			idsToFetch = ids
		if (len(idsToFetch) > 0):
			def _hx_local_1(toBind,exception):
				_g.initialiseObjects(idsToFetch,toBind,prefetched,exception,callBack,clazz,None,True)
			self._getByIds(idsToFetch,clazz,_hx_local_1)
		else:
			callBack(prefetched,None)

	def _getByIds(self,ids,clazz,callBack):
		pass

	def getByExample(self,obj,cb = None):
		q = self.getQuery()
		q.addExample(obj)
		q.run(cb)
		return q

	def query(self,query,cb):
		_g = self
		def _hx_local_0(objs,err):
			if _g.isDataBinding():
				if (err is None):
					clazzList = query.getSelectClassList()
					if (query.bindResults() and ((clazzList is not None))):
						if (len(clazzList) == 1):
							_g.initialiseObjects([],objs,[],err,cb,Type.resolveClass((clazzList[0] if 0 < len(clazzList) else None)),None,True)
					else:
						cb(objs,err)
				else:
					cb(None,err)
			else:
				cb(objs,err)
		self._query(query,_hx_local_0)

	def _query(self,query,cb):
		pass

	def getByValue(self,value,clazz,field,callBack):
		def _hx_local_0(objs,exception):
			if (objs is not None):
				callBack((objs[0] if 0 < len(objs) else None),exception)
			else:
				callBack(None,exception)
		self.getByValues([value],clazz,field,_hx_local_0)

	def getByValues(self,ids,clazz,field,callBack):
		_g = self
		prefetched = None
		idsToFetch = None
		if self.useCache:
			model = self.getModel(clazz)
			if (model is not None):
				prefetched = list()
				idsToFetch = list()
				_g1 = 0
				while (_g1 < len(ids)):
					id = (ids[_g1] if _g1 >= 0 and _g1 < len(ids) else None)
					_g1 = (_g1 + 1)
					cacheObject = self.getObjectFromCache(clazz,field,id)
					if (cacheObject is not None):
						if Std._hx_is(cacheObject,list):
							objArray = cacheObject
							_g11 = 0
							while (_g11 < len(objArray)):
								obj = (objArray[_g11] if _g11 >= 0 and _g11 < len(objArray) else None)
								_g11 = (_g11 + 1)
								x = obj
								prefetched.append(x)
						else:
							prefetched.append(cacheObject)
					else:
						idsToFetch.append(id)
			else:
				idsToFetch = ids
		else:
			idsToFetch = ids
		if (len(idsToFetch) > 0):
			def _hx_local_2(toBind,exception):
				_g.initialiseObjects(idsToFetch,toBind,prefetched,exception,callBack,clazz,field,True)
			self._getByValues(idsToFetch,clazz,field,_hx_local_2)
		else:
			callBack(prefetched,None)

	def _getByValues(self,values,clazz,field,callBack):
		pass

	def getObjects(self,clazz,callBack):
		_g = self
		def _hx_local_0(toBind,exception):
			if (exception is not None):
				callBack(None,exception)
			else:
				_g.initialiseObjects([],toBind,[],exception,callBack,clazz,None,True)
		self._getObjects(clazz,_hx_local_0)

	def _getObjects(self,clazz,callBack):
		pass

	def getByPkey(self,id,clazz,callBack):
		def _hx_local_0(objs,exception):
			if (objs is not None):
				callBack((objs[0] if 0 < len(objs) else None),exception)
			else:
				callBack(None,exception)
		self.getByPkeys([id],clazz,_hx_local_0)

	def getByPkeys(self,ids,clazz,callBack):
		_g = self
		prefetched = None
		idsToFetch = None
		if self.useCache:
			model = self.getModel(clazz)
			if (model is not None):
				priField = model.getPrimaryKey()
				prefetched = list()
				idsToFetch = list()
				_g1 = 0
				while (_g1 < len(ids)):
					id = (ids[_g1] if _g1 >= 0 and _g1 < len(ids) else None)
					_g1 = (_g1 + 1)
					cacheObject = self.getObjectFromCache(clazz,priField,id)
					if (cacheObject is not None):
						prefetched.append(cacheObject)
					else:
						idsToFetch.append(id)
			else:
				idsToFetch = ids
		else:
			idsToFetch = ids
		if (len(idsToFetch) > 0):
			def _hx_local_1(toBind,exception):
				_g.initialiseObjects(idsToFetch,toBind,prefetched,exception,callBack,clazz,None,True)
			self._getByPkeys(idsToFetch,clazz,_hx_local_1)
		else:
			callBack(prefetched,None)

	def _getByPkeys(self,ids,clazz,callBack):
		pass

	def getConnection(self,config,cb):
		pass

	def sql(self,sql,parameters,cb):
		self.getByNamedQuery("saturn.db.provider.hooks.RawSQLHook:SQL",[sql, parameters],None,False,cb)

	def getByNamedQuery(self,queryId,parameters,clazz,cache,callBack):
		_g = self
		saturn_core_Util.debug("In getByNamedQuery")
		try:
			isCached = False
			if (cache and queryId in self.namedQueryCache.h):
				qResults = None
				queries = self.namedQueryCache.h.get(queryId,None)
				_g1 = 0
				while (_g1 < len(queries)):
					query = (queries[_g1] if _g1 >= 0 and _g1 < len(queries) else None)
					_g1 = (_g1 + 1)
					saturn_core_Util.debug("Checking for existing results")
					serialParamString = haxe_Serializer.run(parameters)
					if (query.queryParamSerial == serialParamString):
						qResults = query.queryResults
						break
				if (qResults is not None):
					callBack(qResults,None)
					return
			else:
				value = list()
				self.namedQueryCache.h[queryId] = value
			def _hx_local_2(toBind,exception):
				if (toBind is None):
					if (((isCached == False) and _g.useCache) and cache):
						namedQuery = saturn_db_NamedQueryCache()
						namedQuery.queryName = queryId
						namedQuery.queryParams = parameters
						namedQuery.queryParamSerial = haxe_Serializer.run(parameters)
						namedQuery.queryResults = toBind
						_this = _g.namedQueryCache.h.get(queryId,None)
						_this.append(namedQuery)
					callBack(toBind,exception)
				else:
					def _hx_local_1(objs,err):
						if (((isCached == False) and _g.useCache) and cache):
							namedQuery1 = saturn_db_NamedQueryCache()
							namedQuery1.queryName = queryId
							namedQuery1.queryParams = parameters
							namedQuery1.queryParamSerial = haxe_Serializer.run(parameters)
							namedQuery1.queryResults = objs
							_this1 = _g.namedQueryCache.h.get(queryId,None)
							_this1.append(namedQuery1)
						callBack(objs,err)
					_g.initialiseObjects([],toBind,[],exception,_hx_local_1,clazz,None,cache)
			privateCB = _hx_local_2
			if (queryId == "saturn.workflow"):
				jobName = HxOverrides.arrayGet(parameters, 0)
				config = HxOverrides.arrayGet(parameters, 1)
				saturn_core_Util.debug(("Got workflow query " + ("null" if jobName is None else jobName)))
				saturn_core_Util.debug(Type.getClassName(Type.getClass(config)))
				if jobName in self.namedQueryHooks.h:
					def _hx_local_3(object,error):
						privateCB([object],object.getError())
					self.namedQueryHooks.h.get(jobName,None)(config,_hx_local_3)
				else:
					saturn_core_Util.debug("Unknown workflow query")
					self._getByNamedQuery(queryId,parameters,clazz,privateCB)
			elif queryId in self.namedQueryHooks.h:
				config1 = None
				if queryId in self.namedQueryHookConfigs.h:
					config1 = self.namedQueryHookConfigs.h.get(queryId,None)
				saturn_core_Util.debug("Calling hook")
				self.namedQueryHooks.h.get(queryId,None)(queryId,parameters,clazz,privateCB,config1)
			else:
				self._getByNamedQuery(queryId,parameters,clazz,privateCB)
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			ex = _hx_e1
			callBack(None,"An unexpected exception has occurred")
			saturn_core_Util.debug(ex)

	def addHooks(self,hooks):
		_g = 0
		while (_g < len(hooks)):
			hookdef = (hooks[_g] if _g >= 0 and _g < len(hooks) else None)
			_g = (_g + 1)
			name = Reflect.field(hookdef,"name")
			hook = None
			if hasattr(hookdef,(("_hx_" + "func") if ("func" in python_Boot.keywords) else (("_hx_" + "func") if (((((len("func") > 2) and ((ord("func"[0]) == 95))) and ((ord("func"[1]) == 95))) and ((ord("func"[(len("func") - 1)]) != 95)))) else "func"))):
				hook = Reflect.field(hookdef,"func")
			else:
				clazz = Reflect.field(hookdef,"class")
				method = Reflect.field(hookdef,"method")
				hook = Reflect.field(Type.resolveClass(clazz),method)
			self.namedQueryHooks.h[name] = hook
			value = hookdef
			value1 = value
			self.namedQueryHookConfigs.h[name] = value1

	def _getByNamedQuery(self,queryId,parameters,clazz,callBack):
		pass

	def getByIdStartsWith(self,id,field,clazz,limit,callBack):
		_g = self
		queryId = ("__STARTSWITH_" + HxOverrides.stringOrNull(Type.getClassName(clazz)))
		parameters = list()
		parameters.append(field)
		parameters.append(id)
		isCached = False
		if queryId in self.namedQueryCache.h:
			qResults = None
			queries = self.namedQueryCache.h.get(queryId,None)
			_g1 = 0
			while (_g1 < len(queries)):
				query = (queries[_g1] if _g1 >= 0 and _g1 < len(queries) else None)
				_g1 = (_g1 + 1)
				qParams = query.queryParams
				if (len(qParams) != len(parameters)):
					continue
				else:
					matched = True
					_g2 = 0
					_g11 = len(qParams)
					while (_g2 < _g11):
						i = _g2
						_g2 = (_g2 + 1)
						if not HxOverrides.eq((qParams[i] if i >= 0 and i < len(qParams) else None),(parameters[i] if i >= 0 and i < len(parameters) else None)):
							matched = False
					if matched:
						qResults = query.queryResults
						break
			if (qResults is not None):
				callBack(qResults,None)
				return
		else:
			value = list()
			self.namedQueryCache.h[queryId] = value
		def _hx_local_2(toBind,exception):
			if (toBind is None):
				callBack(toBind,exception)
			else:
				def _hx_local_1(objs,err):
					if ((isCached == False) and _g.useCache):
						namedQuery = saturn_db_NamedQueryCache()
						namedQuery.queryName = queryId
						namedQuery.queryParams = parameters
						namedQuery.queryResults = objs
						_this = _g.namedQueryCache.h.get(queryId,None)
						_this.append(namedQuery)
					callBack(objs,err)
				_g.initialiseObjects([],toBind,[],exception,_hx_local_1,clazz,None,False,False)
		self._getByIdStartsWith(id,field,clazz,limit,_hx_local_2)

	def _getByIdStartsWith(self,id,field,clazz,limit,callBack):
		pass

	def update(self,object,callBack):
		self.synchronizeInternalLinks([object])
		className = Type.getClassName(Type.getClass(object))
		self.evictObject(object)
		attributeMaps = list()
		x = self.unbindObject(object)
		attributeMaps.append(x)
		self._update(attributeMaps,className,callBack)

	def insert(self,obj,cb):
		_g = self
		self.synchronizeInternalLinks([obj])
		className = Type.getClassName(Type.getClass(obj))
		self.evictObject(obj)
		attributeMaps = list()
		x = self.unbindObject(obj)
		attributeMaps.append(x)
		def _hx_local_1(err):
			if (err is None):
				def _hx_local_0(err1):
					cb(err1)
				_g.attach([obj],True,_hx_local_0)
			else:
				cb(err)
		self._insert(attributeMaps,className,_hx_local_1)

	def delete(self,obj,cb):
		_g = self
		className = Type.getClassName(Type.getClass(obj))
		attributeMaps = list()
		x = self.unbindObject(obj)
		attributeMaps.append(x)
		self.evictObject(obj)
		def _hx_local_0(err):
			model = _g.getModel(Type.getClass(obj))
			field = model.getPrimaryKey()
			setattr(obj,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)),None)
			cb(err)
		self._delete(attributeMaps,className,_hx_local_0)

	def evictObject(self,object):
		clazz = Type.getClass(object)
		className = Type.getClassName(clazz)
		if className in self.objectCache.h:
			def _hx_local_0():
				this1 = self.objectCache.h.get(className,None)
				return this1.keys()
			_hx_local_2 = _hx_local_0()
			while _hx_local_2.hasNext():
				indexField = _hx_local_2.next()
				val = Reflect.field(object,indexField)
				if ((val is not None) and ((val != ""))):
					def _hx_local_1():
						this2 = None
						this3 = self.objectCache.h.get(className,None)
						this2 = this3.get(indexField)
						return this2.exists(val)
					if _hx_local_1():
						this4 = None
						this5 = self.objectCache.h.get(className,None)
						this4 = this5.get(indexField)
						this4.remove(val)

	def evictNamedQuery(self,queryId,parameters):
		if queryId in self.namedQueryCache.h:
			qResults = None
			queries = self.namedQueryCache.h.get(queryId,None)
			_g = 0
			while (_g < len(queries)):
				query = (queries[_g] if _g >= 0 and _g < len(queries) else None)
				_g = (_g + 1)
				qParams = query.queryParams
				if (len(qParams) != len(parameters)):
					continue
				else:
					matched = True
					_g2 = 0
					_g1 = len(qParams)
					while (_g2 < _g1):
						i = _g2
						_g2 = (_g2 + 1)
						if not HxOverrides.eq((qParams[i] if i >= 0 and i < len(qParams) else None),(parameters[i] if i >= 0 and i < len(parameters) else None)):
							matched = False
					if matched:
						python_internal_ArrayImpl.remove(queries,query)
						break
			if (len(queries) > 0):
				self.namedQueryCache.remove(queryId)
			else:
				self.namedQueryCache.h[queryId] = queries

	def updateObjects(self,objs,callBack):
		self.synchronizeInternalLinks(objs)
		className = Type.getClassName(Type.getClass((objs[0] if 0 < len(objs) else None)))
		attributeMaps = list()
		_g = 0
		while (_g < len(objs)):
			object = (objs[_g] if _g >= 0 and _g < len(objs) else None)
			_g = (_g + 1)
			self.evictObject(object)
			x = self.unbindObject(object)
			attributeMaps.append(x)
		self._update(attributeMaps,className,callBack)

	def insertObjects(self,objs,cb):
		_g1 = self
		if (len(objs) == 0):
			cb(None)
			return
		self.synchronizeInternalLinks(objs)
		def _hx_local_2(err):
			if (err is not None):
				cb(err)
			else:
				className = Type.getClassName(Type.getClass((objs[0] if 0 < len(objs) else None)))
				attributeMaps = list()
				_g = 0
				while (_g < len(objs)):
					object = (objs[_g] if _g >= 0 and _g < len(objs) else None)
					_g = (_g + 1)
					_g1.evictObject(object)
					x = _g1.unbindObject(object)
					attributeMaps.append(x)
				def _hx_local_1(err1):
					cb(err1)
				_g1._insert(attributeMaps,className,_hx_local_1)
		self.attach(objs,False,_hx_local_2)

	def rollback(self,callBack):
		self._rollback(callBack)

	def commit(self,callBack):
		self._commit(callBack)

	def _update(self,attributeMaps,className,callBack):
		pass

	def _insert(self,attributeMaps,className,callBack):
		pass

	def _delete(self,attributeMaps,className,callBack):
		pass

	def _rollback(self,callBack):
		pass

	def _commit(self,cb):
		cb("Commit not supported")

	def bindObject(self,attributeMap,clazz,cache,indexField = None,suspendSetup = False):
		if (suspendSetup is None):
			suspendSetup = False
		if (clazz is None):
			_g = 0
			_g1 = python_Boot.fields(attributeMap)
			while (_g < len(_g1)):
				key = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
				_g = (_g + 1)
				val = Reflect.field(attributeMap,key)
				def _hx_local_1():
					_this = saturn_db_DefaultProvider.r_date
					_this.matchObj = python_lib_Re.search(_this.pattern,val)
					return (_this.matchObj is not None)
				if _hx_local_1():
					pass
			return attributeMap
		if self.enableBinding:
			className = Type.getClassName(clazz)
			parts = className.split(".")
			shortName = None
			shortName = (None if ((len(parts) == 0)) else parts.pop())
			packageName = ".".join([python_Boot.toString1(x1,'') for x1 in parts])
			obj = Type.createInstance(clazz,[])
			if className in self.theBindingMap.h:
				_hx_map = None
				this1 = self.theBindingMap.h.get(className,None)
				_hx_map = this1.get("fields")
				indexes = None
				this2 = self.theBindingMap.h.get(className,None)
				indexes = this2.get("indexes")
				atPriIndex = None
				_hx_local_2 = indexes.keys()
				while _hx_local_2.hasNext():
					atIndexField = _hx_local_2.next()
					if (indexes.h.get(atIndexField,None) == 1):
						atPriIndex = atIndexField
						break
				colPriIndex = None
				if (atPriIndex is not None):
					colPriIndex = _hx_map.h.get(atPriIndex,None)
				priKeyValue = None
				def _hx_local_3():
					field = colPriIndex
					return hasattr(attributeMap,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)))
				if _hx_local_3():
					priKeyValue = Reflect.field(attributeMap,colPriIndex)
				else:
					def _hx_local_4():
						field1 = Reflect.field(colPriIndex,"toLowerCase")()
						return hasattr(attributeMap,(("_hx_" + field1) if (field1 in python_Boot.keywords) else (("_hx_" + field1) if (((((len(field1) > 2) and ((ord(field1[0]) == 95))) and ((ord(field1[1]) == 95))) and ((ord(field1[(len(field1) - 1)]) != 95)))) else field1)))
					if _hx_local_4():
						priKeyValue = Reflect.field(attributeMap,Reflect.field(colPriIndex,"toLowerCase")())
				keys = []
				_hx_local_5 = _hx_map.keys()
				while _hx_local_5.hasNext():
					key1 = _hx_local_5.next()
					keys.append(key1)
				if ((indexField is not None) and (not indexField in _hx_map.h)):
					keys.append(indexField)
				_g2 = 0
				while (_g2 < len(keys)):
					key2 = (keys[_g2] if _g2 >= 0 and _g2 < len(keys) else None)
					_g2 = (_g2 + 1)
					def _hx_local_7():
						this3 = self.objectCache.h.get(className,None)
						return this3.exists(key2)
					if (not _hx_local_7()):
						this4 = self.objectCache.h.get(className,None)
						value = haxe_ds_StringMap()
						this4.set(key2,value)
					atKey = _hx_map.h.get(key2,None)
					val1 = None
					def _hx_local_8():
						field2 = atKey
						return hasattr(attributeMap,(("_hx_" + field2) if (field2 in python_Boot.keywords) else (("_hx_" + field2) if (((((len(field2) > 2) and ((ord(field2[0]) == 95))) and ((ord(field2[1]) == 95))) and ((ord(field2[(len(field2) - 1)]) != 95)))) else field2)))
					if _hx_local_8():
						val1 = Reflect.field(attributeMap,atKey)
					else:
						def _hx_local_9():
							field3 = Reflect.field(atKey,"toLowerCase")()
							return hasattr(attributeMap,(("_hx_" + field3) if (field3 in python_Boot.keywords) else (("_hx_" + field3) if (((((len(field3) > 2) and ((ord(field3[0]) == 95))) and ((ord(field3[1]) == 95))) and ((ord(field3[(len(field3) - 1)]) != 95)))) else field3)))
						if _hx_local_9():
							val1 = Reflect.field(attributeMap,Reflect.field(atKey,"toLowerCase")())
					setattr(obj,(("_hx_" + key2) if (key2 in python_Boot.keywords) else (("_hx_" + key2) if (((((len(key2) > 2) and ((ord(key2[0]) == 95))) and ((ord(key2[1]) == 95))) and ((ord(key2[(len(key2) - 1)]) != 95)))) else key2)),val1)
					if (((cache and ((indexes is not None))) and ((key2 in indexes.h or ((key2 == indexField))))) and self.useCache):
						if (priKeyValue is not None):
							def _hx_local_10():
								this5 = None
								this6 = self.objectCache.h.get(className,None)
								this5 = this6.get(key2)
								return this5.exists(val1)
							if _hx_local_10():
								mappedObj = None
								this7 = None
								this8 = self.objectCache.h.get(className,None)
								this7 = this8.get(key2)
								mappedObj = this7.get(val1)
								toCheck = mappedObj
								isArray = Std._hx_is(mappedObj,list)
								if (not isArray):
									toCheck = [mappedObj]
								match = False
								_g21 = 0
								_g11 = len(toCheck)
								while (_g21 < _g11):
									i = _g21
									_g21 = (_g21 + 1)
									eObj = (toCheck[i] if i >= 0 and i < len(toCheck) else None)
									priValue = Reflect.field(eObj,atPriIndex)
									if (priValue == priKeyValue):
										python_internal_ArrayImpl._set(toCheck, i, obj)
										match = True
										break
								if (match == False):
									toCheck.append(obj)
								if (len(toCheck) == 1):
									this9 = None
									this10 = self.objectCache.h.get(className,None)
									this9 = this10.get(key2)
									value1 = (toCheck[0] if 0 < len(toCheck) else None)
									this9.set(val1,value1)
								else:
									this11 = None
									this12 = self.objectCache.h.get(className,None)
									this11 = this12.get(key2)
									this11.set(val1,toCheck)
								continue
						this13 = None
						this14 = self.objectCache.h.get(className,None)
						this13 = this14.get(key2)
						this13.set(val1,obj)
			if ((not suspendSetup) and Reflect.isFunction(obj.setup)):
				obj.setup()
			return obj
		else:
			return attributeMap

	def unbindObject(self,object):
		if self.enableBinding:
			className = Type.getClassName(Type.getClass(object))
			attributeMap = haxe_ds_StringMap()
			if className in self.theBindingMap.h:
				_hx_map = None
				this1 = self.theBindingMap.h.get(className,None)
				_hx_map = this1.get("fields")
				_hx_local_0 = _hx_map.keys()
				while _hx_local_0.hasNext():
					key = _hx_local_0.next()
					val = Reflect.field(object,key)
					key1 = _hx_map.h.get(key,None)
					attributeMap.h[key1] = val
				return attributeMap
			else:
				return None
		else:
			return object

	def activate(self,objects,depthLimit,callBack):
		_g = self
		def _hx_local_0(error):
			if (error is None):
				_g.merge(objects)
			callBack(error)
		self._activate(objects,1,depthLimit,_hx_local_0)

	def _activate(self,objects,depth,depthLimit,callBack):
		_g1 = self
		objectsToFetch = 0
		def _hx_local_0(obj,err):
			saturn_core_Util.print(err)
		batchQuery = saturn_db_BatchFetch(_hx_local_0)
		batchQuery.setProvider(self)
		classToFetch = haxe_ds_StringMap()
		_g = 0
		while (_g < len(objects)):
			object = (objects[_g] if _g >= 0 and _g < len(objects) else None)
			_g = (_g + 1)
			if ((object is None) or Std._hx_is(object,haxe_ds_StringMap)):
				continue
			clazz = Type.getClass(object)
			if (clazz is None):
				continue
			clazzName = Type.getClassName(clazz)
			if clazzName in self.theBindingMap.h:
				def _hx_local_2():
					this1 = self.theBindingMap.h.get(clazzName,None)
					return this1.exists("fields.synthetic")
				if _hx_local_2():
					synthFields = None
					this2 = self.theBindingMap.h.get(clazzName,None)
					synthFields = this2.get("fields.synthetic")
					_hx_local_5 = synthFields.keys()
					while _hx_local_5.hasNext():
						synthFieldName = _hx_local_5.next()
						synthVal = Reflect.field(object,synthFieldName)
						if (synthVal is not None):
							continue
						synthInfo = synthFields.h.get(synthFieldName,None)
						isPolymorphic = Reflect.field(synthInfo,"exists")("selector_field")
						synthClass = None
						if isPolymorphic:
							selectorField = Reflect.field(synthInfo,"get")("selector_field")
							objValue = Reflect.field(object,selectorField)
							if Reflect.field(Reflect.field(synthInfo,"get")("selector_values"),"exists")(objValue):
								synthClass = Reflect.field(Reflect.field(synthInfo,"get")("selector_values"),"get")(objValue)
							else:
								continue
							selectorValue = Reflect.field(synthInfo,"get")("selector_value")
							synthFieldName = "_MERGE"
						else:
							synthClass = Reflect.field(synthInfo,"get")("class")
						field = Reflect.field(synthInfo,"get")("field")
						val = Reflect.field(object,field)
						if ((val is None) or (((val == "") and (not Std._hx_is(val,Int))))):
							setattr(object,(("_hx_" + synthFieldName) if (synthFieldName in python_Boot.keywords) else (("_hx_" + synthFieldName) if (((((len(synthFieldName) > 2) and ((ord(synthFieldName[0]) == 95))) and ((ord(synthFieldName[1]) == 95))) and ((ord(synthFieldName[(len(synthFieldName) - 1)]) != 95)))) else synthFieldName)),None)
						else:
							fkField = Reflect.field(synthInfo,"get")("fk_field")
							cacheObj = self.getObjectFromCache(Type.resolveClass(synthClass),fkField,val)
							if (cacheObj is None):
								objectsToFetch = (objectsToFetch + 1)
								if (not synthClass in classToFetch.h):
									value = haxe_ds_StringMap()
									classToFetch.h[synthClass] = value
								def _hx_local_4():
									this3 = classToFetch.h.get(synthClass,None)
									return this3.exists(fkField)
								if (not _hx_local_4()):
									this4 = classToFetch.h.get(synthClass,None)
									value1 = haxe_ds_StringMap()
									this4.set(fkField,value1)
								this5 = None
								this6 = classToFetch.h.get(synthClass,None)
								this5 = this6.get(fkField)
								this5.set(val,"")
							else:
								setattr(object,(("_hx_" + synthFieldName) if (synthFieldName in python_Boot.keywords) else (("_hx_" + synthFieldName) if (((((len(synthFieldName) > 2) and ((ord(synthFieldName[0]) == 95))) and ((ord(synthFieldName[1]) == 95))) and ((ord(synthFieldName[(len(synthFieldName) - 1)]) != 95)))) else synthFieldName)),cacheObj)
		_hx_local_10 = classToFetch.keys()
		while _hx_local_10.hasNext():
			synthClass1 = _hx_local_10.next()
			def _hx_local_6():
				this7 = classToFetch.h.get(synthClass1,None)
				return this7.keys()
			_hx_local_9 = _hx_local_6()
			while _hx_local_9.hasNext():
				fkField1 = _hx_local_9.next()
				objList = list()
				def _hx_local_7():
					this8 = None
					this9 = classToFetch.h.get(synthClass1,None)
					this8 = this9.get(fkField1)
					return this8.keys()
				_hx_local_8 = _hx_local_7()
				while _hx_local_8.hasNext():
					objId = _hx_local_8.next()
					objList.append(objId)
				batchQuery.getByValues(objList,Type.resolveClass(synthClass1),fkField1,"__IGNORED__",None)
		def _hx_local_17():
			_g2 = 0
			while (_g2 < len(objects)):
				object1 = (objects[_g2] if _g2 >= 0 and _g2 < len(objects) else None)
				_g2 = (_g2 + 1)
				clazz1 = Type.getClass(object1)
				if ((object1 is None) or ((clazz1 is None))):
					continue
				clazzName1 = Type.getClassName(clazz1)
				if clazzName1 in _g1.theBindingMap.h:
					def _hx_local_12():
						this10 = _g1.theBindingMap.h.get(clazzName1,None)
						return this10.exists("fields.synthetic")
					if _hx_local_12():
						synthFields1 = None
						this11 = _g1.theBindingMap.h.get(clazzName1,None)
						synthFields1 = this11.get("fields.synthetic")
						_hx_local_13 = synthFields1.keys()
						while _hx_local_13.hasNext():
							synthFieldName1 = _hx_local_13.next()
							synthVal1 = Reflect.field(object1,synthFieldName1)
							if (synthVal1 is not None):
								continue
							synthInfo1 = synthFields1.h.get(synthFieldName1,None)
							isPolymorphic1 = Reflect.field(synthInfo1,"exists")("selector_field")
							synthClass2 = None
							if isPolymorphic1:
								selectorField1 = Reflect.field(synthInfo1,"get")("selector_field")
								objValue1 = Reflect.field(object1,selectorField1)
								if Reflect.field(Reflect.field(synthInfo1,"get")("selector_values"),"exists")(objValue1):
									synthClass2 = Reflect.field(Reflect.field(synthInfo1,"get")("selector_values"),"get")(objValue1)
								else:
									continue
								selectorValue1 = Reflect.field(synthInfo1,"get")("selector_value")
								synthFieldName1 = "_MERGE"
							else:
								synthClass2 = Reflect.field(synthInfo1,"get")("class")
							field1 = Reflect.field(synthInfo1,"get")("field")
							val1 = Reflect.field(object1,field1)
							if ((val1 is not None) and ((val1 != ""))):
								fkField2 = Reflect.field(synthInfo1,"get")("fk_field")
								if Reflect.field(synthInfo1,"exists")("selector_field"):
									synthFieldName1 = "_MERGE"
								cacheObj1 = _g1.getObjectFromCache(Type.resolveClass(synthClass2),fkField2,val1)
								if (cacheObj1 is not None):
									setattr(object1,(("_hx_" + synthFieldName1) if (synthFieldName1 in python_Boot.keywords) else (("_hx_" + synthFieldName1) if (((((len(synthFieldName1) > 2) and ((ord(synthFieldName1[0]) == 95))) and ((ord(synthFieldName1[1]) == 95))) and ((ord(synthFieldName1[(len(synthFieldName1) - 1)]) != 95)))) else synthFieldName1)),cacheObj1)
			newObjList = list()
			_g3 = 0
			while (_g3 < len(objects)):
				object2 = (objects[_g3] if _g3 >= 0 and _g3 < len(objects) else None)
				_g3 = (_g3 + 1)
				clazz2 = Type.getClass(object2)
				if ((object2 is None) or ((clazz2 is None))):
					continue
				model = _g1.getModel(clazz2)
				if (model is not None):
					_g21 = 0
					_g31 = python_Boot.fields(object2)
					while (_g21 < len(_g31)):
						field2 = (_g31[_g21] if _g21 >= 0 and _g21 < len(_g31) else None)
						_g21 = (_g21 + 1)
						val2 = Reflect.field(object2,field2)
						if ((((((val2 is not None) and ((val2 != ""))) and (not Std._hx_is(val2,Int))) and (not Std._hx_is(val2,Float))) and (not Std._hx_is(val2,str))) and (not Std._hx_is(val2,Bool))):
							objs = Reflect.field(object2,field2)
							if (not Std._hx_is(objs,list)):
								objs = [objs]
							_g4 = 0
							while (_g4 < len(objs)):
								newObject = (objs[_g4] if _g4 >= 0 and _g4 < len(objs) else None)
								_g4 = (_g4 + 1)
								x = newObject
								newObjList.append(x)
			if ((len(newObjList) > 0) and ((depthLimit > depth))):
				_g1._activate(newObjList,(depth + 1),depthLimit,callBack)
			else:
				callBack(None)
		batchQuery.onComplete = _hx_local_17
		batchQuery.execute()

	def merge(self,objects):
		toVisit = []
		_g1 = 0
		_g = len(objects)
		while (_g1 < _g):
			i = _g1
			_g1 = (_g1 + 1)
			toVisit.append(_hx_AnonObject({'parent': objects, 'pos': i, 'value': (objects[i] if i >= 0 and i < len(objects) else None)}))
		try:
			self._merge(toVisit)
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			unknown = _hx_e1
			print(str(unknown))

	def _merge(self,toVisit):
		while True:
			if (len(toVisit) == 0):
				break
			item = None
			item = (None if ((len(toVisit) == 0)) else toVisit.pop())
			original = Reflect.field(item,"value")
			if hasattr(original,(("_hx_" + "_MERGE") if ("_MERGE" in python_Boot.keywords) else (("_hx_" + "_MERGE") if (((((len("_MERGE") > 2) and ((ord("_MERGE"[0]) == 95))) and ((ord("_MERGE"[1]) == 95))) and ((ord("_MERGE"[(len("_MERGE") - 1)]) != 95)))) else "_MERGE"))):
				obj = Reflect.field(original,"_MERGE")
				_g = 0
				_g1 = python_Boot.fields(original)
				while (_g < len(_g1)):
					field = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
					_g = (_g + 1)
					if (field != "_MERGE"):
						value = Reflect.field(original,field)
						setattr(obj,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)),value)
				parent = Reflect.field(item,"parent")
				if hasattr(item,(("_hx_" + "pos") if ("pos" in python_Boot.keywords) else (("_hx_" + "pos") if (((((len("pos") > 2) and ((ord("pos"[0]) == 95))) and ((ord("pos"[1]) == 95))) and ((ord("pos"[(len("pos") - 1)]) != 95)))) else "pos"))):
					python_internal_ArrayImpl._set(parent, Reflect.field(item,"pos"), obj)
				else:
					field1 = Reflect.field(item,"field")
					setattr(parent,(("_hx_" + field1) if (field1 in python_Boot.keywords) else (("_hx_" + field1) if (((((len(field1) > 2) and ((ord(field1[0]) == 95))) and ((ord(field1[1]) == 95))) and ((ord(field1[(len(field1) - 1)]) != 95)))) else field1)),obj)
				original = obj
			model = self.getModel(original)
			if (model is None):
				continue
			_g2 = 0
			_g11 = model.getAttributes()
			while (_g2 < len(_g11)):
				field2 = (_g11[_g2] if _g2 >= 0 and _g2 < len(_g11) else None)
				_g2 = (_g2 + 1)
				value1 = Reflect.field(original,field2)
				isObject = False
				isObject = hasattr(value1,(("_hx_" + "__class__") if ("__class__" in python_Boot.keywords) else (("_hx_" + "__class__") if (((((len("__class__") > 2) and ((ord("__class__"[0]) == 95))) and ((ord("__class__"[1]) == 95))) and ((ord("__class__"[(len("__class__") - 1)]) != 95)))) else "__class__")))
				if isObject:
					if Std._hx_is(value1,list):
						_g3 = 0
						_g21 = Reflect.field(value1,"length")
						while (_g3 < _g21):
							i = _g3
							_g3 = (_g3 + 1)
							toVisit.append(_hx_AnonObject({'parent': value1, 'pos': i, 'value': HxOverrides.arrayGet(value1, i)}))
					else:
						toVisit.append(_hx_AnonObject({'parent': original, 'value': value1, 'field': field2}))

	def getModel(self,clazz):
		if (clazz is None):
			return None
		else:
			t = Type.getClass(clazz)
			className = Type.getClassName(clazz)
			return self.getModelByStringName(className)

	def getObjectModel(self,object):
		if (object is None):
			return None
		else:
			clazz = Type.getClass(object)
			return self.getModel(clazz)

	def save(self,object,cb,autoAttach = False):
		if (autoAttach is None):
			autoAttach = False
		self.insertOrUpdate([object],cb,autoAttach)

	def initModelClasses(self):
		self.modelClasses = list()
		_hx_local_0 = self.theBindingMap.keys()
		while _hx_local_0.hasNext():
			classStr = _hx_local_0.next()
			clazz = Type.resolveClass(classStr)
			if (clazz is not None):
				_this = self.modelClasses
				x = self.getModel(clazz)
				_this.append(x)

	def getModelClasses(self):
		return self.modelClasses

	def getModelByStringName(self,className):
		if className in self.theBindingMap.h:
			def _hx_local_0():
				this1 = self.theBindingMap.h.get(className,None)
				return this1.exists("model")
			if _hx_local_0():
				return saturn_db_Model(self.theBindingMap.h.get(className,None), className)
			else:
				return saturn_db_Model(self.theBindingMap.h.get(className,None), className)
		else:
			return None

	def isModel(self,clazz):
		if (self.theBindingMap is not None):
			key = Type.getClassName(clazz)
			return key in self.theBindingMap.h
		else:
			return False

	def setSelectClause(self,className,selClause):
		if className in self.theBindingMap.h:
			this1 = None
			this2 = self.theBindingMap.h.get(className,None)
			this1 = this2.get("statements")
			this1.set("SELECT",selClause)

	def modelToReal(self,modelDef,models,cb):
		_g3 = self
		priKey = modelDef.getPrimaryKey()
		fields = modelDef.getFields()
		clazz = modelDef.getClass()
		syntheticInstanceAttributes = modelDef.getSynthenticFields()
		syntheticSet = None
		if (syntheticInstanceAttributes is not None):
			syntheticSet = haxe_ds_StringMap()
			_hx_local_0 = syntheticInstanceAttributes.keys()
			while _hx_local_0.hasNext():
				instanceName = _hx_local_0.next()
				fkRel = syntheticInstanceAttributes.h.get(instanceName,None)
				parentIdColumn = Reflect.field(fkRel,"get")("fk_field")
				childIdColumn = Reflect.field(fkRel,"get")("field")
				value = None
				_g = haxe_ds_StringMap()
				_g.h["childIdColumn"] = childIdColumn
				value1 = Reflect.field(fkRel,"get")("fk_field")
				value2 = value1
				_g.h["parentIdColumn"] = value2
				value3 = Reflect.field(fkRel,"get")("class")
				value4 = value3
				_g.h["class"] = value4
				value = _g
				syntheticSet.h[instanceName] = value
		clazzToFieldToIds = haxe_ds_StringMap()
		_g1 = 0
		while (_g1 < len(models)):
			model = (models[_g1] if _g1 >= 0 and _g1 < len(models) else None)
			_g1 = (_g1 + 1)
			_g11 = 0
			_g2 = modelDef.getFields()
			while (_g11 < len(_g2)):
				field = (_g2[_g11] if _g11 >= 0 and _g11 < len(_g2) else None)
				_g11 = (_g11 + 1)
				if (field.find(".") > -1):
					parts = field.split(".")
					instanceName1 = (parts[0] if 0 < len(parts) else None)
					if ((syntheticSet is not None) and instanceName1 in syntheticSet.h):
						lookupField = python_internal_ArrayImpl._get(parts, (len(parts) - 1))
						lookupClazz = None
						this1 = syntheticSet.h.get(instanceName1,None)
						lookupClazz = this1.get("class")
						val = Reflect.field(model,field)
						if ((val is None) or (((val == "") and (not Std._hx_is(val,Int))))):
							continue
						clazz1 = Type.resolveClass(lookupClazz)
						cachedObject = self.getObjectFromCache(clazz1,lookupField,val)
						if (cachedObject is None):
							def _hx_local_3():
								key = lookupClazz
								return key in clazzToFieldToIds.h
							if (not _hx_local_3()):
								key1 = lookupClazz
								value5 = haxe_ds_StringMap()
								clazzToFieldToIds.h[key1] = value5
							def _hx_local_4():
								this2 = None
								key2 = lookupClazz
								this2 = clazzToFieldToIds.h.get(key2,None)
								return this2.exists(lookupField)
							if (not _hx_local_4()):
								this3 = None
								key3 = lookupClazz
								this3 = clazzToFieldToIds.h.get(key3,None)
								value6 = haxe_ds_StringMap()
								this3.set(lookupField,value6)
							this4 = None
							this5 = None
							key4 = lookupClazz
							this5 = clazzToFieldToIds.h.get(key4,None)
							this4 = this5.get(lookupField)
							this4.set(val,"")
		def _hx_local_5(obj,err):
			cb(err,obj)
		batchFetch = saturn_db_BatchFetch(_hx_local_5)
		_hx_local_10 = clazzToFieldToIds.keys()
		while _hx_local_10.hasNext():
			clazzStr = _hx_local_10.next()
			def _hx_local_6():
				this6 = clazzToFieldToIds.h.get(clazzStr,None)
				return this6.keys()
			_hx_local_9 = _hx_local_6()
			while _hx_local_9.hasNext():
				fieldStr = _hx_local_9.next()
				valList = list()
				def _hx_local_7():
					this7 = None
					this8 = clazzToFieldToIds.h.get(clazzStr,None)
					this7 = this8.get(fieldStr)
					return this7.keys()
				_hx_local_8 = _hx_local_7()
				while _hx_local_8.hasNext():
					val1 = _hx_local_8.next()
					valList.append(val1)
				batchFetch.getByIds(valList,Type.resolveClass(clazzStr),"__IGNORE__",None)
		def _hx_local_13(err1,objs):
			if (err1 is not None):
				cb(err1,None)
			else:
				mappedModels = list()
				_g4 = 0
				while (_g4 < len(models)):
					model1 = (models[_g4] if _g4 >= 0 and _g4 < len(models) else None)
					_g4 = (_g4 + 1)
					mappedModel = Type.createEmptyInstance(clazz)
					_g12 = 0
					_g21 = modelDef.getFields()
					while (_g12 < len(_g21)):
						field1 = (_g21[_g12] if _g12 >= 0 and _g12 < len(_g21) else None)
						_g12 = (_g12 + 1)
						if (field1.find(".") > -1):
							parts1 = field1.split(".")
							instanceName2 = (parts1[0] if 0 < len(parts1) else None)
							if instanceName2 in syntheticSet.h:
								lookupField1 = python_internal_ArrayImpl._get(parts1, (len(parts1) - 1))
								lookupClazz1 = None
								this9 = syntheticSet.h.get(instanceName2,None)
								lookupClazz1 = this9.get("class")
								val2 = Reflect.field(model1,field1)
								if ((val2 is None) or ((val2 == ""))):
									continue
								clazz2 = Type.resolveClass(lookupClazz1)
								cachedObject1 = _g3.getObjectFromCache(clazz2,lookupField1,val2)
								if (cachedObject1 is not None):
									idColumn = None
									this10 = syntheticSet.h.get(instanceName2,None)
									idColumn = this10.get("parentIdColumn")
									val3 = Reflect.field(cachedObject1,idColumn)
									if ((val3 is None) or (((val3 == "") and (not Std._hx_is(val3,Int))))):
										cb("Unexpected mapping error",mappedModels)
										return
									dstColumn = None
									this11 = syntheticSet.h.get(instanceName2,None)
									dstColumn = this11.get("childIdColumn")
									field2 = dstColumn
									setattr(mappedModel,(("_hx_" + field2) if (field2 in python_Boot.keywords) else (("_hx_" + field2) if (((((len(field2) > 2) and ((ord(field2[0]) == 95))) and ((ord(field2[1]) == 95))) and ((ord(field2[(len(field2) - 1)]) != 95)))) else field2)),val3)
								else:
									cb(("Unable to find " + ("null" if val2 is None else val2)),mappedModels)
									return
						else:
							val4 = Reflect.field(model1,field1)
							setattr(mappedModel,(("_hx_" + field1) if (field1 in python_Boot.keywords) else (("_hx_" + field1) if (((((len(field1) > 2) and ((ord(field1[0]) == 95))) and ((ord(field1[1]) == 95))) and ((ord(field1[(len(field1) - 1)]) != 95)))) else field1)),val4)
					mappedModels.append(mappedModel)
				cb(None,mappedModels)
		batchFetch.onComplete = _hx_local_13
		batchFetch.execute()

	def dataBinding(self,enable):
		self.enableBinding = enable

	def isDataBinding(self):
		return self.enableBinding

	def queryPath(self,fromClazz,queryPath,fieldValue,functionName,cb):
		_g = self
		parts = queryPath.split(".")
		fieldName = None
		fieldName = (None if ((len(parts) == 0)) else parts.pop())
		synthField = None
		synthField = (None if ((len(parts) == 0)) else parts.pop())
		model = self.getModel(fromClazz)
		if model.isSynthetic(synthField):
			fieldDef = None
			this1 = model.getSynthenticFields()
			fieldDef = this1.get(synthField)
			childClazz = Type.resolveClass(Reflect.field(fieldDef,"get")("class"))
			def _hx_local_2(objs,err):
				if (err is None):
					values = []
					_g1 = 0
					while (_g1 < len(objs)):
						obj = (objs[_g1] if _g1 >= 0 and _g1 < len(objs) else None)
						_g1 = (_g1 + 1)
						x = Reflect.field(obj,Reflect.field(fieldDef,"get")("fk_field"))
						values.append(x)
					parentField = Reflect.field(fieldDef,"get")("field")
					def _hx_local_1(objs1,err1):
						cb(err1,objs1)
					_g.getByValues(values,fromClazz,parentField,_hx_local_1)
				else:
					cb(err,None)
			Reflect.callMethod(self,Reflect.field(self,functionName),[[fieldValue], childClazz, fieldName, _hx_local_2])

	def setAutoCommit(self,autoCommit,cb):
		cb("Set auto commit mode ")

	def attach(self,objs,refreshFields,cb):
		_g = self
		def _hx_local_0(obj,err):
			cb(err)
		bf = saturn_db_BatchFetch(_hx_local_0)
		bf.setProvider(self)
		self._attach(objs,refreshFields,bf)
		def _hx_local_1():
			_g.synchronizeInternalLinks(objs)
			cb(None)
		bf.onComplete = _hx_local_1
		bf.execute()

	def synchronizeInternalLinks(self,objs):
		if (not self.isDataBinding()):
			return
		_g = 0
		while (_g < len(objs)):
			obj = (objs[_g] if _g >= 0 and _g < len(objs) else None)
			_g = (_g + 1)
			clazz = Type.getClass(obj)
			model = self.getModel(obj)
			synthFields = model.getSynthenticFields()
			if (synthFields is not None):
				_hx_local_1 = synthFields.keys()
				while _hx_local_1.hasNext():
					synthFieldName = _hx_local_1.next()
					synthField = synthFields.h.get(synthFieldName,None)
					synthObj = Reflect.field(obj,synthFieldName)
					field = Reflect.field(synthField,"get")("field")
					fkField = Reflect.field(synthField,"get")("fk_field")
					if (synthObj is not None):
						value = Reflect.field(synthObj,fkField)
						setattr(obj,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)),value)
						self.synchronizeInternalLinks([synthObj])

	def _attach(self,objs,refreshFields,bf):
		_g = 0
		while (_g < len(objs)):
			obj = [(objs[_g] if _g >= 0 and _g < len(objs) else None)]
			_g = (_g + 1)
			clazz = Type.getClass((obj[0] if 0 < len(obj) else None))
			model = self.getModel((obj[0] if 0 < len(obj) else None))
			priField = [model.getPrimaryKey()]
			secField = model.getFirstKey()
			if ((Reflect.field((obj[0] if 0 < len(obj) else None),(priField[0] if 0 < len(priField) else None)) is None) or ((Reflect.field((obj[0] if 0 < len(obj) else None),(priField[0] if 0 < len(priField) else None)) == ""))):
				fieldVal = Reflect.field((obj[0] if 0 < len(obj) else None),secField)
				if (fieldVal is not None):
					def _hx_local_3(priField,obj):
						def _hx_local_1(dbObj):
							if refreshFields:
								_g1 = 0
								_g2 = python_Boot.fields(dbObj)
								while (_g1 < len(_g2)):
									field = (_g2[_g1] if _g1 >= 0 and _g1 < len(_g2) else None)
									_g1 = (_g1 + 1)
									value = Reflect.field(dbObj,field)
									setattr((obj[0] if 0 < len(obj) else None),(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)),value)
							else:
								value1 = Reflect.field(dbObj,(priField[0] if 0 < len(priField) else None))
								setattr((obj[0] if 0 < len(obj) else None),(("_hx_" + (priField[0] if 0 < len(priField) else None)) if ((priField[0] if 0 < len(priField) else None) in python_Boot.keywords) else (("_hx_" + (priField[0] if 0 < len(priField) else None)) if (((((len((priField[0] if 0 < len(priField) else None)) > 2) and ((ord((priField[0] if 0 < len(priField) else None)[0]) == 95))) and ((ord((priField[0] if 0 < len(priField) else None)[1]) == 95))) and ((ord((priField[0] if 0 < len(priField) else None)[(len((priField[0] if 0 < len(priField) else None)) - 1)]) != 95)))) else (priField[0] if 0 < len(priField) else None))),value1)
						return _hx_local_1
					bf.append(fieldVal,secField,clazz,_hx_local_3(priField,obj))
			synthFields = model.getSynthenticFields()
			if (synthFields is not None):
				_hx_local_4 = synthFields.keys()
				while _hx_local_4.hasNext():
					synthFieldName = _hx_local_4.next()
					synthField = synthFields.h.get(synthFieldName,None)
					synthObj = Reflect.field((obj[0] if 0 < len(obj) else None),synthFieldName)
					if (synthObj is not None):
						self._attach([synthObj],refreshFields,bf)

	def getQuery(self):
		query = saturn_db_query_lang_Query(self)
		return query

	def getProviderType(self):
		return "NONE"

	def isAttached(self,obj):
		model = self.getModel(Type.getClass(obj))
		priField = model.getPrimaryKey()
		val = Reflect.field(obj,priField)
		if ((val is None) or ((val == ""))):
			return False
		else:
			return True

	def insertOrUpdate(self,objs,cb,autoAttach = False):
		if (autoAttach is None):
			autoAttach = False
		_g1 = self
		def _hx_local_2():
			insertList = []
			updateList = []
			_g = 0
			while (_g < len(objs)):
				obj = (objs[_g] if _g >= 0 and _g < len(objs) else None)
				_g = (_g + 1)
				if (not _g1.isAttached(obj)):
					x = obj
					insertList.append(x)
				else:
					x1 = obj
					updateList.append(x1)
			if (len(insertList) > 0):
				def _hx_local_1(err):
					if ((err is None) and ((len(updateList) > 0))):
						_g1.updateObjects(updateList,cb)
					else:
						cb(err)
				_g1.insertObjects(insertList,_hx_local_1)
			elif (len(updateList) > 0):
				_g1.updateObjects(updateList,cb)
		run = _hx_local_2
		if autoAttach:
			def _hx_local_3(err1):
				if (err1 is None):
					run()
				else:
					cb(err1)
			self.attach(objs,False,_hx_local_3)
		else:
			run()

	def uploadFile(self,contents,file_identifier,cb):
		return None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.theBindingMap = None
		_hx_o.fieldIndexMap = None
		_hx_o.objectCache = None
		_hx_o.namedQueryCache = None
		_hx_o.useCache = None
		_hx_o.enableBinding = None
		_hx_o.connectWithUserCreds = None
		_hx_o.namedQueryHooks = None
		_hx_o.namedQueryHookConfigs = None
		_hx_o.modelClasses = None
		_hx_o.user = None
		_hx_o.autoClose = None
		_hx_o.name = None
		_hx_o.config = None
		_hx_o.winConversions = None
		_hx_o.linConversions = None
		_hx_o.conversions = None
		_hx_o.regexs = None
		_hx_o.platform = None
saturn_db_DefaultProvider._hx_class = saturn_db_DefaultProvider
_hx_classes["saturn.db.DefaultProvider"] = saturn_db_DefaultProvider


class saturn_db_NamedQueryCache:
	_hx_class_name = "saturn.db.NamedQueryCache"
	_hx_fields = ["queryName", "queryParamSerial", "queryParams", "queryResults"]

	def __init__(self):
		self.queryName = None
		self.queryParamSerial = None
		self.queryParams = None
		self.queryResults = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.queryName = None
		_hx_o.queryParamSerial = None
		_hx_o.queryParams = None
		_hx_o.queryResults = None
saturn_db_NamedQueryCache._hx_class = saturn_db_NamedQueryCache
_hx_classes["saturn.db.NamedQueryCache"] = saturn_db_NamedQueryCache


class saturn_db_Model:
	_hx_class_name = "saturn.db.Model"
	_hx_fields = ["theModel", "theName", "busSingleColKey", "priColKey", "idRegEx", "stripIdPrefix", "searchMap", "ftsColumns", "alias", "programs", "flags", "autoActivate", "actionMap", "providerName", "publicConstraintField", "userConstraintField", "customSearchFunctionPath"]
	_hx_methods = ["isProgramSaveAs", "getProviderName", "setProviderName", "getActions", "getAutoActivateLevel", "hasFlag", "getCustomSearchFunction", "getPrograms", "getAlias", "getFTSColumns", "getSearchMap", "getOptions", "compileRegEx", "setIdRegEx", "getIdRegEx", "isValidId", "stripPrefixes", "processId", "getIndexes", "getAutoFunctions", "getFields", "getAttributes", "isField", "isRDBMSField", "modelAtrributeToRDBMS", "hasDefaults", "hasOptions", "getFieldDefault", "hasRequired", "isRequired", "getFieldDefs", "getUserFieldDefinitions", "convertUserFieldName", "getExtTableDefinition", "getSynthenticFields", "isSyntheticallyBound", "isSynthetic", "getSyntheticallyBoundField", "getClass", "getFirstKey", "getIcon", "getWorkspaceWrapper", "getWorkspaceWrapperClass", "getPrimaryKey", "getName", "getExtModelName", "getExtStoreName", "getFirstKey_rdbms", "getSqlColumn", "unbindFieldName", "getPrimaryKey_rdbms", "getSchemaName", "getTableName", "getQualifiedTableName", "hasTableInfo", "getSelectClause", "setInsertClause", "getInsertClause", "setUpdateClause", "getUpdateClause", "setDeleteClause", "getDeleteClause", "setSelectKeyClause", "getSelectKeyClause", "setColumns", "getColumns", "getColumnSet", "getSelectorField", "getSelectorValue", "isPolymorph", "getUserConstraintField", "getPublicConstraintField"]
	_hx_statics = ["generateIDMap", "generateUniqueList", "generateUniqueListWithField", "extractField", "setField", "getModel", "generateMap", "generateMapWithField"]

	def __init__(self,model,name):
		self.theModel = None
		self.theName = None
		self.busSingleColKey = None
		self.priColKey = None
		self.idRegEx = None
		self.stripIdPrefix = None
		self.searchMap = None
		self.ftsColumns = None
		self.alias = None
		self.programs = None
		self.flags = None
		self.autoActivate = None
		self.actionMap = None
		self.providerName = None
		self.publicConstraintField = None
		self.userConstraintField = None
		self.customSearchFunctionPath = None
		self.customSearchFunctionPath = None
		self.theModel = model
		self.theName = name
		self.alias = ""
		self.actionMap = haxe_ds_StringMap()
		if "indexes" in self.theModel.h:
			i = 0
			def _hx_local_0():
				this1 = self.theModel.h.get("indexes",None)
				return this1.keys()
			_hx_local_3 = _hx_local_0()
			while _hx_local_3.hasNext():
				keyName = _hx_local_3.next()
				if (i == 0):
					self.busSingleColKey = keyName
				def _hx_local_1():
					this2 = self.theModel.h.get("indexes",None)
					return this2.get(keyName)
				if _hx_local_1():
					self.priColKey = keyName
				i = (i + 1)
		if "provider_name" in self.theModel.h:
			name1 = None
			def _hx_local_0():
				_hx_local_4 = self.theModel.h.get("provider_name",None)
				if Std._hx_is(_hx_local_4,str):
					_hx_local_4
				else:
					raise _HxException("Class cast error")
				return _hx_local_4
			name1 = _hx_local_0()
			self.setProviderName(name1)
		if "programs" in self.theModel.h:
			self.programs = list()
			def _hx_local_5():
				this3 = self.theModel.h.get("programs",None)
				return this3.keys()
			_hx_local_6 = _hx_local_5()
			while _hx_local_6.hasNext():
				program = _hx_local_6.next()
				_this = self.programs
				_this.append(program)
		self.stripIdPrefix = False
		self.autoActivate = -1
		if "options" in self.theModel.h:
			options = self.theModel.h.get("options",None)
			if "id_pattern" in options.h:
				self.setIdRegEx(options.h.get("id_pattern",None))
			if "custom_search_function" in options.h:
				self.customSearchFunctionPath = options.h.get("custom_search_function",None)
			if "constraints" in options.h:
				if Reflect.field(options.h.get("constraints",None),"exists")("user_constraint_field"):
					self.userConstraintField = Reflect.field(options.h.get("constraints",None),"get")("user_constraint_field")
				if Reflect.field(options.h.get("constraints",None),"exists")("public_constraint_field"):
					self.publicConstraintField = Reflect.field(options.h.get("constraints",None),"get")("public_constraint_field")
			if options.h.get("windows_allowed_paths",None):
				value = self.compileRegEx(options.h.get("windows_allowed_paths",None))
				value1 = value
				options.h["windows_allowed_paths_regex"] = value1
			if options.h.get("linux_allowed_paths",None):
				value2 = self.compileRegEx(options.h.get("linux_allowed_paths",None))
				value3 = value2
				options.h["linux_allowed_paths_regex"] = value3
			if "strip_id_prefix" in options.h:
				self.stripIdPrefix = options.h.get("strip_id_prefix",None)
			if "alias" in options.h:
				self.alias = options.h.get("alias",None)
			if "flags" in options.h:
				self.flags = options.h.get("flags",None)
			else:
				self.flags = haxe_ds_StringMap()
			if "auto_activate" in options.h:
				self.autoActivate = Std.parseInt(options.h.get("auto_activate",None))
			if "actions" in options.h:
				actionTypeMap = options.h.get("actions",None)
				_hx_local_9 = actionTypeMap.keys()
				while _hx_local_9.hasNext():
					actionType = _hx_local_9.next()
					actions = actionTypeMap.h.get(actionType,None)
					value4 = haxe_ds_StringMap()
					self.actionMap.h[actionType] = value4
					_hx_local_8 = actions.keys()
					while _hx_local_8.hasNext():
						actionName = _hx_local_8.next()
						actionDef = actions.h.get(actionName,None)
						if (not "user_suffix" in actionDef.h):
							raise _HxException(saturn_util_HaxeException((((("null" if actionName is None else actionName) + " action definition for ") + HxOverrides.stringOrNull(self.getName())) + " is missing user_suffix option")))
						if (not "function" in actionDef.h):
							raise _HxException(saturn_util_HaxeException((((("null" if actionName is None else actionName) + " action definition for ") + HxOverrides.stringOrNull(self.getName())) + " is missing function option")))
						action = saturn_db_ModelAction(actionName, actionDef.h.get("user_suffix",None), actionDef.h.get("function",None), actionDef.h.get("icon",None))
						if (actionType == "search_bar"):
							clazz = Type.resolveClass(action.className)
							if (clazz is None):
								raise _HxException(saturn_util_HaxeException(((HxOverrides.stringOrNull(action.className) + " does not exist for action ") + ("null" if actionName is None else actionName))))
							instanceFields = python_Boot.getInstanceFields(clazz)
							match = False
							_g = 0
							while (_g < len(instanceFields)):
								field = (instanceFields[_g] if _g >= 0 and _g < len(instanceFields) else None)
								_g = (_g + 1)
								if (field == action.functionName):
									match = True
									break
							if (not match):
								raise _HxException(saturn_util_HaxeException(((((HxOverrides.stringOrNull(action.className) + " does not have function ") + HxOverrides.stringOrNull(action.functionName)) + " for action ") + ("null" if actionName is None else actionName))))
						this4 = self.actionMap.h.get(actionType,None)
						this4.set(actionName,action)
		else:
			self.flags = haxe_ds_StringMap()
			value5 = haxe_ds_StringMap()
			self.actionMap.h["searchBar"] = value5
		if "search" in self.theModel.h:
			fts = self.theModel.h.get("search",None)
			self.ftsColumns = haxe_ds_StringMap()
			_hx_local_10 = fts.keys()
			while _hx_local_10.hasNext():
				key = _hx_local_10.next()
				searchDef = fts.h.get(key,None)
				searchObj = saturn_db_SearchDef()
				if (searchDef is not None):
					if (Std._hx_is(searchDef,Bool) and searchDef):
						self.ftsColumns.h[key] = searchObj
					elif Std._hx_is(searchDef,str):
						searchObj.regex = EReg(searchDef, "")
					else:
						if Reflect.field(searchDef,"exists")("search_when"):
							regexStr = Reflect.field(searchDef,"get")("search_when")
							if ((regexStr is not None) and ((regexStr != ""))):
								searchObj.regex = EReg(regexStr, "")
						if Reflect.field(searchDef,"exists")("replace_with"):
							searchObj.replaceWith = Reflect.field(searchDef,"get")("replace_with")
				self.ftsColumns.h[key] = searchObj
		if ((self.alias is None) or ((self.alias == ""))):
			self.alias = self.theName

	def isProgramSaveAs(self,clazzName):
		def _hx_local_0():
			this1 = self.theModel.h.get("programs",None)
			return this1.get(clazzName)
		if ("programs" in self.theModel.h and _hx_local_0()):
			return True
		else:
			def _hx_local_1():
				this2 = self.theModel.h.get("options",None)
				return this2.exists("canSave")
			if _hx_local_1():
				def _hx_local_2():
					def _hx_local_0():
						this3 = self.theModel.h.get("options",None)
						return this3.get("canSave")
					return Reflect.field((_hx_local_0()),"get")(clazzName)
				return _hx_local_2()
			else:
				return False

	def getProviderName(self):
		return self.providerName

	def setProviderName(self,name):
		self.providerName = name

	def getActions(self,actionType):
		if actionType in self.actionMap.h:
			return self.actionMap.h.get(actionType,None)
		else:
			return haxe_ds_StringMap()

	def getAutoActivateLevel(self):
		return self.autoActivate

	def hasFlag(self,flag):
		if flag in self.flags.h:
			return self.flags.h.get(flag,None)
		else:
			return False

	def getCustomSearchFunction(self):
		return self.customSearchFunctionPath

	def getPrograms(self):
		return self.programs

	def getAlias(self):
		return self.alias

	def getFTSColumns(self):
		if (self.ftsColumns is not None):
			return self.ftsColumns
		else:
			return None

	def getSearchMap(self):
		return self.searchMap

	def getOptions(self):
		return self.theModel.h.get("options",None)

	def compileRegEx(self,regexs):
		cregexs = haxe_ds_StringMap()
		_hx_local_0 = regexs.keys()
		while _hx_local_0.hasNext():
			key = _hx_local_0.next()
			regex = regexs.h.get(key,None)
			if (regex != ""):
				value = EReg(regex, "")
				cregexs.h[key] = value
		return cregexs

	def setIdRegEx(self,idRegExStr):
		self.idRegEx = EReg(idRegExStr, "")

	def getIdRegEx(self):
		return self.idRegEx

	def isValidId(self,id):
		if (self.idRegEx is not None):
			_this = self.idRegEx
			_this.matchObj = python_lib_Re.search(_this.pattern,id)
			return (_this.matchObj is not None)
		else:
			return False

	def stripPrefixes(self):
		return self.stripIdPrefix

	def processId(self,id):
		if self.stripIdPrefix:
			id = self.idRegEx.replace(id,"")
		return id

	def getIndexes(self):
		indexFields = list()
		def _hx_local_0():
			this1 = self.theModel.h.get("indexes",None)
			return this1.keys()
		_hx_local_1 = _hx_local_0()
		while _hx_local_1.hasNext():
			keyName = _hx_local_1.next()
			indexFields.append(keyName)
		return indexFields

	def getAutoFunctions(self):
		if "auto_functions" in self.theModel.h:
			return self.theModel.h.get("auto_functions",None)
		else:
			return None

	def getFields(self):
		fields = list()
		def _hx_local_0():
			this1 = self.theModel.h.get("model",None)
			return this1.iterator()
		_hx_local_1 = _hx_local_0()
		while _hx_local_1.hasNext():
			field = _hx_local_1.next()
			fields.append(field)
		return fields

	def getAttributes(self):
		fields = list()
		if "fields" in self.theModel.h:
			def _hx_local_0():
				this1 = self.theModel.h.get("fields",None)
				return this1.keys()
			_hx_local_1 = _hx_local_0()
			while _hx_local_1.hasNext():
				field = _hx_local_1.next()
				fields.append(field)
		return fields

	def isField(self,field):
		this1 = self.theModel.h.get("fields",None)
		return this1.exists(field)

	def isRDBMSField(self,rdbmsField):
		fields = self.theModel.h.get("fields",None)
		_hx_local_0 = fields.keys()
		while _hx_local_0.hasNext():
			field = _hx_local_0.next()
			if (fields.h.get(field,None) == rdbmsField):
				return True
		return False

	def modelAtrributeToRDBMS(self,field):
		this1 = self.theModel.h.get("fields",None)
		return this1.get(field)

	def hasDefaults(self):
		return "defaults" in self.theModel.h

	def hasOptions(self):
		return "options" in self.theModel.h

	def getFieldDefault(self,field):
		def _hx_local_0():
			this1 = self.theModel.h.get("defaults",None)
			return this1.exists(field)
		if (self.hasDefaults() and _hx_local_0()):
			this2 = self.theModel.h.get("defaults",None)
			return this2.get(field)
		else:
			return None

	def hasRequired(self):
		return "required" in self.theModel.h

	def isRequired(self,field):
		if self.hasRequired():
			def _hx_local_0():
				this1 = self.theModel.h.get("required",None)
				return this1.exists(field)
			if _hx_local_0():
				return True
			elif (field.find(".") > 0):
				cmps = field.split(".")
				refField = self.getSyntheticallyBoundField((cmps[0] if 0 < len(cmps) else None))
				return self.isRequired(refField)
		return False

	def getFieldDefs(self):
		fields = list()
		defaults = None
		if "defaults" in self.theModel.h:
			defaults = self.theModel.h.get("defaults",None)
		else:
			return self.getFields()
		def _hx_local_0():
			this1 = self.theModel.h.get("model",None)
			return this1.iterator()
		_hx_local_1 = _hx_local_0()
		while _hx_local_1.hasNext():
			field = _hx_local_1.next()
			val = None
			if field in defaults.h:
				this2 = self.theModel.h.get("defaults",None)
				val = this2.get(field)
			fields.append(_hx_AnonObject({'name': field, 'defaultValue': val}))
		return fields

	def getUserFieldDefinitions(self):
		fields = list()
		defaults = None
		if "defaults" in self.theModel.h:
			defaults = self.theModel.h.get("defaults",None)
		else:
			defaults = haxe_ds_StringMap()
		model = self.theModel.h.get("model",None)
		if (model is None):
			return None
		_hx_local_1 = model.keys()
		while _hx_local_1.hasNext():
			field = _hx_local_1.next()
			val = None
			if field in defaults.h:
				this1 = self.theModel.h.get("defaults",None)
				val = this1.get(field)
			def _hx_local_0():
				this2 = self.theModel.h.get("model",None)
				return this2.get(field)
			x = _hx_AnonObject({'name': field, 'defaultValue': val, 'field': _hx_local_0()})
			fields.append(x)
		return fields

	def convertUserFieldName(self,userFieldName):
		if "model" in self.theModel.h:
			def _hx_local_0():
				this1 = self.theModel.h.get("model",None)
				return this1.exists(userFieldName)
			if _hx_local_0():
				this2 = self.theModel.h.get("model",None)
				return this2.get(userFieldName)
			else:
				return None
		else:
			return None

	def getExtTableDefinition(self):
		tableDefinition = list()
		def _hx_local_0():
			this1 = self.theModel.h.get("model",None)
			return this1.keys()
		_hx_local_1 = _hx_local_0()
		while _hx_local_1.hasNext():
			name = _hx_local_1.next()
			field = None
			this2 = self.theModel.h.get("model",None)
			field = this2.get(name)
			_hx_def = _hx_AnonObject({'header': name, 'dataIndex': field, 'editor': "textfield"})
			if self.isRequired(field):
				Reflect.setField(_hx_def,"tdCls","required-column")
				Reflect.setField(_hx_def,"allowBlank",False)
			x = _hx_def
			tableDefinition.append(x)
		return tableDefinition

	def getSynthenticFields(self):
		return self.theModel.h.get("fields.synthetic",None)

	def isSyntheticallyBound(self,fieldName):
		synthFields = self.theModel.h.get("fields.synthetic",None)
		_hx_local_0 = synthFields.keys()
		while _hx_local_0.hasNext():
			syntheticFieldName = _hx_local_0.next()
			if (Reflect.field(synthFields.h.get(syntheticFieldName,None),"get")("field") == fieldName):
				return True
		return False

	def isSynthetic(self,fieldName):
		if "fields.synthetic" in self.theModel.h:
			this1 = self.theModel.h.get("fields.synthetic",None)
			return this1.exists(fieldName)
		else:
			return False

	def getSyntheticallyBoundField(self,syntheticFieldName):
		if "fields.synthetic" in self.theModel.h:
			def _hx_local_0():
				this1 = self.theModel.h.get("fields.synthetic",None)
				return this1.exists(syntheticFieldName)
			if _hx_local_0():
				def _hx_local_1():
					def _hx_local_0():
						this2 = self.theModel.h.get("fields.synthetic",None)
						return this2.get(syntheticFieldName)
					return Reflect.field((_hx_local_0()),"get")("field")
				return _hx_local_1()
		return None

	def getClass(self):
		return Type.resolveClass(self.theName)

	def getFirstKey(self):
		return self.busSingleColKey

	def getIcon(self):
		if self.hasOptions():
			def _hx_local_0():
				this1 = self.getOptions()
				return this1.exists("icon")
			if _hx_local_0():
				this2 = self.getOptions()
				return this2.get("icon")
		return ""

	def getWorkspaceWrapper(self):
		if self.hasOptions():
			def _hx_local_0():
				this1 = self.getOptions()
				return this1.exists("workspace_wrapper")
			if _hx_local_0():
				this2 = self.getOptions()
				return this2.get("workspace_wrapper")
		return ""

	def getWorkspaceWrapperClass(self):
		return Type.resolveClass(self.getWorkspaceWrapper())

	def getPrimaryKey(self):
		return self.priColKey

	def getName(self):
		return self.theName

	def getExtModelName(self):
		return (HxOverrides.stringOrNull(self.theName) + ".MODEL")

	def getExtStoreName(self):
		return (HxOverrides.stringOrNull(self.theName) + ".STORE")

	def getFirstKey_rdbms(self):
		this1 = self.theModel.h.get("fields",None)
		key = self.getFirstKey()
		return this1.get(key)

	def getSqlColumn(self,field):
		this1 = self.theModel.h.get("fields",None)
		return this1.get(field)

	def unbindFieldName(self,field):
		return self.getSqlColumn(field)

	def getPrimaryKey_rdbms(self):
		this1 = self.theModel.h.get("fields",None)
		key = self.getPrimaryKey()
		return this1.get(key)

	def getSchemaName(self):
		this1 = self.theModel.h.get("table_info",None)
		return this1.get("schema")

	def getTableName(self):
		this1 = self.theModel.h.get("table_info",None)
		return this1.get("name")

	def getQualifiedTableName(self):
		schemaName = self.getSchemaName()
		if ((schemaName is None) or ((schemaName == ""))):
			return self.getTableName()
		else:
			return ((HxOverrides.stringOrNull(self.getSchemaName()) + ".") + HxOverrides.stringOrNull(self.getTableName()))

	def hasTableInfo(self):
		return "table_info" in self.theModel.h

	def getSelectClause(self):
		this1 = self.theModel.h.get("statements",None)
		return this1.get("SELECT")

	def setInsertClause(self,insertClause):
		this1 = self.theModel.h.get("statements",None)
		this1.set("INSERT",insertClause)

	def getInsertClause(self):
		this1 = self.theModel.h.get("statements",None)
		return this1.get("INSERT")

	def setUpdateClause(self,updateClause):
		this1 = self.theModel.h.get("statements",None)
		this1.set("UPDATE",updateClause)

	def getUpdateClause(self):
		this1 = self.theModel.h.get("statements",None)
		return this1.get("UPDATE")

	def setDeleteClause(self,deleteClause):
		this1 = self.theModel.h.get("statements",None)
		this1.set("DELETE",deleteClause)

	def getDeleteClause(self):
		this1 = self.theModel.h.get("statements",None)
		return this1.get("DELETE")

	def setSelectKeyClause(self,selKeyClause):
		this1 = self.theModel.h.get("statements",None)
		this1.set("SELECT_KEY",selKeyClause)

	def getSelectKeyClause(self):
		this1 = self.theModel.h.get("statements",None)
		return this1.get("SELECT_KEY")

	def setColumns(self,columns):
		this1 = self.theModel.h.get("statements",None)
		this1.set("COLUMNS",columns)
		colSet = haxe_ds_StringMap()
		_g = 0
		while (_g < len(columns)):
			column = (columns[_g] if _g >= 0 and _g < len(columns) else None)
			_g = (_g + 1)
			colSet.h[column] = ""
		this2 = self.theModel.h.get("statements",None)
		this2.set("COLUMNS_SET",colSet)

	def getColumns(self):
		this1 = self.theModel.h.get("statements",None)
		return this1.get("COLUMNS")

	def getColumnSet(self):
		this1 = self.theModel.h.get("statements",None)
		return this1.get("COLUMNS_SET")

	def getSelectorField(self):
		if "selector" in self.theModel.h:
			this1 = self.theModel.h.get("selector",None)
			return this1.get("polymorph_key")
		else:
			return None

	def getSelectorValue(self):
		this1 = self.theModel.h.get("selector",None)
		return this1.get("value")

	def isPolymorph(self):
		return "selector" in self.theModel.h

	def getUserConstraintField(self):
		return self.userConstraintField

	def getPublicConstraintField(self):
		return self.publicConstraintField

	@staticmethod
	def generateIDMap(objs):
		if ((objs is None) or ((len(objs) == 0))):
			return None
		else:
			_hx_map = haxe_ds_StringMap()
			model = saturn_core_Util.getProvider().getModel(Type.getClass((objs[0] if 0 < len(objs) else None)))
			firstKey = model.getFirstKey()
			priKey = model.getPrimaryKey()
			_g = 0
			while (_g < len(objs)):
				obj = (objs[_g] if _g >= 0 and _g < len(objs) else None)
				_g = (_g + 1)
				key = Reflect.field(obj,firstKey)
				value = Reflect.field(obj,priKey)
				_hx_map.h[key] = value
			return _hx_map

	@staticmethod
	def generateUniqueList(objs):
		if ((objs is None) or ((len(objs) == 0))):
			return None
		else:
			model = saturn_core_Util.getProvider().getModel(Type.getClass((objs[0] if 0 < len(objs) else None)))
			firstKey = model.getFirstKey()
			return saturn_db_Model.generateUniqueListWithField(objs,firstKey)

	@staticmethod
	def generateUniqueListWithField(objs,field):
		_hx_set = haxe_ds_StringMap()
		_g = 0
		while (_g < len(objs)):
			obj = (objs[_g] if _g >= 0 and _g < len(objs) else None)
			_g = (_g + 1)
			key = saturn_db_Model.extractField(obj,field)
			_hx_set.h[key] = None
		ids = list()
		_hx_local_1 = _hx_set.keys()
		while _hx_local_1.hasNext():
			key1 = _hx_local_1.next()
			ids.append(key1)
		return ids

	@staticmethod
	def extractField(obj,field):
		if (field.find(".") < 0):
			return Reflect.field(obj,field)
		else:
			a = (field.find(".") - 1)
			nextField = HxString.substring(field,0,(a + 1))
			nextObj = Reflect.field(obj,nextField)
			remaining = HxString.substring(field,(a + 2),len(field))
			return saturn_db_Model.extractField(nextObj,remaining)

	@staticmethod
	def setField(obj,field,value,newTerminal = False):
		if (newTerminal is None):
			newTerminal = False
		if (field.find(".") < 0):
			setattr(obj,(("_hx_" + field) if (field in python_Boot.keywords) else (("_hx_" + field) if (((((len(field) > 2) and ((ord(field[0]) == 95))) and ((ord(field[1]) == 95))) and ((ord(field[(len(field) - 1)]) != 95)))) else field)),value)
		else:
			a = (field.find(".") - 1)
			nextField = HxString.substring(field,0,(a + 1))
			nextObj = Reflect.field(obj,nextField)
			remaining = HxString.substring(field,(a + 2),len(field))
			if ((nextObj is None) or ((newTerminal and ((remaining.find(".") < 0))))):
				clazz = Type.getClass(obj)
				if (clazz is not None):
					model = saturn_core_Util.getProvider().getModel(clazz)
					synthDef = None
					this1 = model.getSynthenticFields()
					synthDef = this1.get(nextField)
					if (synthDef is not None):
						clazzStr = Reflect.field(synthDef,"get")("class")
						nextObj = Type.createInstance(Type.resolveClass(clazzStr),[])
						setattr(obj,(("_hx_" + nextField) if (nextField in python_Boot.keywords) else (("_hx_" + nextField) if (((((len(nextField) > 2) and ((ord(nextField[0]) == 95))) and ((ord(nextField[1]) == 95))) and ((ord(nextField[(len(nextField) - 1)]) != 95)))) else nextField)),nextObj)
						field1 = Reflect.field(synthDef,"field")
						setattr(obj,(("_hx_" + field1) if (field1 in python_Boot.keywords) else (("_hx_" + field1) if (((((len(field1) > 2) and ((ord(field1[0]) == 95))) and ((ord(field1[1]) == 95))) and ((ord(field1[(len(field1) - 1)]) != 95)))) else field1)),None)
			saturn_db_Model.setField(nextObj,remaining,value)

	@staticmethod
	def getModel(obj):
		return saturn_core_Util.getProvider().getModel(Type.getClass(obj))

	@staticmethod
	def generateMap(objs):
		model = saturn_db_Model.getModel((objs[0] if 0 < len(objs) else None))
		firstKey = model.getFirstKey()
		return saturn_db_Model.generateMapWithField(objs,firstKey)

	@staticmethod
	def generateMapWithField(objs,field):
		_hx_map = haxe_ds_StringMap()
		_g = 0
		while (_g < len(objs)):
			obj = (objs[_g] if _g >= 0 and _g < len(objs) else None)
			_g = (_g + 1)
			key = saturn_db_Model.extractField(obj,field)
			value = obj
			value1 = value
			_hx_map.h[key] = value1
		return _hx_map

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.theModel = None
		_hx_o.theName = None
		_hx_o.busSingleColKey = None
		_hx_o.priColKey = None
		_hx_o.idRegEx = None
		_hx_o.stripIdPrefix = None
		_hx_o.searchMap = None
		_hx_o.ftsColumns = None
		_hx_o.alias = None
		_hx_o.programs = None
		_hx_o.flags = None
		_hx_o.autoActivate = None
		_hx_o.actionMap = None
		_hx_o.providerName = None
		_hx_o.publicConstraintField = None
		_hx_o.userConstraintField = None
		_hx_o.customSearchFunctionPath = None
saturn_db_Model._hx_class = saturn_db_Model
_hx_classes["saturn.db.Model"] = saturn_db_Model


class saturn_db_SearchDef:
	_hx_class_name = "saturn.db.SearchDef"
	_hx_fields = ["regex", "replaceWith"]

	def __init__(self):
		self.regex = None
		self.replaceWith = None
		self.replaceWith = None
		self.regex = None

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.regex = None
		_hx_o.replaceWith = None
saturn_db_SearchDef._hx_class = saturn_db_SearchDef
_hx_classes["saturn.db.SearchDef"] = saturn_db_SearchDef


class saturn_db_ModelAction:
	_hx_class_name = "saturn.db.ModelAction"
	_hx_fields = ["name", "userSuffix", "functionName", "className", "icon"]
	_hx_methods = ["setQualifiedName", "run"]

	def __init__(self,name,userSuffix,qName,icon):
		self.name = None
		self.userSuffix = None
		self.functionName = None
		self.className = None
		self.icon = None
		self.name = name
		self.userSuffix = userSuffix
		self.setQualifiedName(qName)
		self.icon = icon

	def setQualifiedName(self,qName):
		i = qName.rfind(".", 0, len(qName))
		self.functionName = HxString.substring(qName,(i + 1),len(qName))
		self.className = HxString.substring(qName,0,i)

	def run(self,obj,cb):
		Reflect.callMethod(obj,Reflect.field(obj,self.functionName),[cb])

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.name = None
		_hx_o.userSuffix = None
		_hx_o.functionName = None
		_hx_o.className = None
		_hx_o.icon = None
saturn_db_ModelAction._hx_class = saturn_db_ModelAction
_hx_classes["saturn.db.ModelAction"] = saturn_db_ModelAction


class saturn_db_Pool:
	_hx_class_name = "saturn.db.Pool"
	_hx_methods = ["acquire", "release", "drain", "destroyAllNow"]
saturn_db_Pool._hx_class = saturn_db_Pool
_hx_classes["saturn.db.Pool"] = saturn_db_Pool


class saturn_db_mapping_FamaPublic:
	_hx_class_name = "saturn.db.mapping.FamaPublic"
	_hx_statics = ["models"]
saturn_db_mapping_FamaPublic._hx_class = saturn_db_mapping_FamaPublic
_hx_classes["saturn.db.mapping.FamaPublic"] = saturn_db_mapping_FamaPublic


class saturn_db_mapping_KIR:
	_hx_class_name = "saturn.db.mapping.KIR"
	_hx_fields = ["models"]
	_hx_methods = ["buildModels"]

	def __init__(self):
		self.models = None
		self.buildModels()

	def buildModels(self):
		_g = haxe_ds_StringMap()
		value = None
		_g1 = haxe_ds_StringMap()
		value1 = None
		_g2 = haxe_ds_StringMap()
		_g2.h["experimentNo"] = "Experiment_No"
		_g2.h["id"] = "Id"
		_g2.h["dateStarted"] = "Date_Started"
		_g2.h["title"] = "Title"
		_g2.h["userId"] = "UserId"
		_g2.h["elnDocumentId"] = "ELNDOCUMENTID"
		_g2.h["minEditableItem"] = "Min_Editable_Item"
		_g2.h["lastEdited"] = "Last_Edited"
		_g2.h["user"] = "User"
		_g2.h["sharingAllowed"] = "SharingAllowed"
		_g2.h["personalTemplate"] = "PersonalTemplate"
		_g2.h["globalTemplate"] = "GlocalTemplate"
		_g2.h["dateExperimentStarted"] = "Date_ExperimentStarted"
		value1 = _g2
		_g1.h["fields"] = value1
		value2 = None
		_g3 = haxe_ds_StringMap()
		_g3.h["sharingAllowed"] = "NO"
		_g3.h["personalTemplate"] = "NO"
		_g3.h["globalTemplate"] = "NO"
		value2 = _g3
		_g1.h["defaults"] = value2
		value3 = None
		_g4 = haxe_ds_StringMap()
		_g4.h["id"] = "1"
		_g4.h["experimentNo"] = "1"
		value3 = _g4
		_g1.h["required"] = value3
		value4 = None
		_g5 = haxe_ds_StringMap()
		_g5.h["schema"] = "icmdb_page_secure"
		_g5.h["name"] = "V_LABPAGE"
		value4 = _g5
		_g1.h["table_info"] = value4
		value5 = None
		_g6 = haxe_ds_StringMap()
		_g6.h["Experiment No"] = "experimentNo"
		_g6.h["ID"] = "id"
		_g6.h["Date Started"] = "dateStarted"
		_g6.h["Title"] = "title"
		_g6.h["User ID"] = "userId"
		_g6.h["ELN Document ID"] = "elnDocumentId"
		_g6.h["Min Editable Item"] = "minEditableItem"
		_g6.h["Last Edited"] = "lastEdited"
		_g6.h["User"] = "user"
		_g6.h["Sharing Allowed"] = "sharingAllowed"
		_g6.h["Personal Template"] = "personalTemplate"
		_g6.h["Global Template"] = "globalTemplate"
		_g6.h["Date Experiment Started"] = "dateExperimentStarted"
		value5 = _g6
		_g1.h["model"] = value5
		value6 = None
		_g7 = haxe_ds_StringMap()
		_g7.h["experimentNo"] = False
		_g7.h["id"] = True
		value6 = _g7
		_g1.h["indexes"] = value6
		value7 = None
		_g8 = haxe_ds_StringMap()
		value8 = None
		_g9 = haxe_ds_StringMap()
		_g9.h["field"] = "id"
		_g9.h["class"] = "saturn.core.scarab.LabPageItem"
		_g9.h["fk_field"] = "labPage"
		value8 = _g9
		value9 = value8
		_g8.h["items"] = value9
		value10 = None
		_g10 = haxe_ds_StringMap()
		_g10.h["field"] = "user"
		_g10.h["class"] = "saturn.core.scarab.LabPageUser"
		_g10.h["fk_field"] = "id"
		value10 = _g10
		value11 = value10
		_g8.h["userObj"] = value11
		value7 = _g8
		_g1.h["fields.synthetic"] = value7
		value12 = None
		_g11 = haxe_ds_StringMap()
		_g11.h["id_pattern"] = "PAGE.+"
		_g11.h["icon"] = "structure_16.png"
		_g11.h["workspace_wrapper"] = "saturn.client.workspace.ScarabELNWO"
		_g11.h["alias"] = "ELN"
		_g11.h["display_field"] = "title"
		value12 = _g11
		_g1.h["options"] = value12
		value13 = None
		_g12 = haxe_ds_StringMap()
		_g12.h["title"] = None
		_g12.h["userObj.fullName"] = None
		value13 = _g12
		_g1.h["search"] = value13
		value14 = None
		_g13 = haxe_ds_StringMap()
		_g13.h["saturn.client.programs.ScarabELNViewer"] = True
		value14 = _g13
		_g1.h["programs"] = value14
		value = _g1
		_g.h["saturn.core.scarab.LabPage"] = value
		value15 = None
		_g14 = haxe_ds_StringMap()
		value16 = None
		_g15 = haxe_ds_StringMap()
		_g15.h["labPage"] = "Labpage"
		_g15.h["order"] = "Num"
		_g15.h["id"] = "Id"
		_g15.h["name"] = "Name"
		_g15.h["caption"] = "Caption"
		_g15.h["userId"] = "UserId"
		_g15.h["elnSectionId"] = "ELN_SECTIONID"
		_g15.h["mergePrev"] = "Merge_Prev"
		_g15.h["user"] = "User"
		value16 = _g15
		_g14.h["fields"] = value16
		value17 = None
		_g16 = haxe_ds_StringMap()
		_g16.h["schema"] = "icmdb_page_secure"
		_g16.h["name"] = "V_LABPAGE_ITEM"
		value17 = _g16
		_g14.h["table_info"] = value17
		value18 = None
		_g17 = haxe_ds_StringMap()
		_g17.h["id"] = True
		value18 = _g17
		_g14.h["indexes"] = value18
		value19 = None
		_g18 = haxe_ds_StringMap()
		_g18.h["field"] = "id"
		_g18.h["fk_field"] = "id"
		_g18.h["selector_field"] = "name"
		value20 = None
		_g19 = haxe_ds_StringMap()
		_g19.h["LABPAGE_TEXT"] = "saturn.core.scarab.LabPageText"
		_g19.h["LABPAGE_EXCEL"] = "saturn.core.scarab.LabPageExcel"
		_g19.h["LABPAGE_IMAGE"] = "saturn.core.scarab.LabPageImage"
		value20 = _g19
		value21 = value20
		_g18.h["selector_values"] = value21
		value19 = _g18
		_g14.h["polymorphic"] = value19
		value15 = _g14
		_g.h["saturn.core.scarab.LabPageItem"] = value15
		value22 = None
		_g20 = haxe_ds_StringMap()
		value23 = None
		_g21 = haxe_ds_StringMap()
		_g21.h["id"] = "Id"
		_g21.h["fullName"] = "Full_Name"
		value23 = _g21
		_g20.h["fields"] = value23
		value24 = None
		_g22 = haxe_ds_StringMap()
		_g22.h["schema"] = "icmdb_page_secure"
		_g22.h["name"] = "V_USERS2"
		value24 = _g22
		_g20.h["table_info"] = value24
		value25 = None
		_g23 = haxe_ds_StringMap()
		_g23.h["id"] = True
		value25 = _g23
		_g20.h["indexes"] = value25
		value22 = _g20
		_g.h["saturn.core.scarab.LabPageUser"] = value22
		value26 = None
		_g24 = haxe_ds_StringMap()
		value27 = None
		_g25 = haxe_ds_StringMap()
		_g25.h["id"] = "Id"
		_g25.h["content"] = "Content"
		value27 = _g25
		_g24.h["fields"] = value27
		value28 = None
		_g26 = haxe_ds_StringMap()
		_g26.h["schema"] = "icmdb_page_secure"
		_g26.h["name"] = "V_LABPAGE_TEXT"
		value28 = _g26
		_g24.h["table_info"] = value28
		value29 = None
		_g27 = haxe_ds_StringMap()
		_g27.h["id"] = True
		value29 = _g27
		_g24.h["indexes"] = value29
		value26 = _g24
		_g.h["saturn.core.scarab.LabPageText"] = value26
		value30 = None
		_g28 = haxe_ds_StringMap()
		value31 = None
		_g29 = haxe_ds_StringMap()
		_g29.h["id"] = "Id"
		_g29.h["imageEdit"] = "Image_Edit"
		_g29.h["imageAnnot"] = "Image_Annot"
		_g29.h["vectorized"] = "Vectorized"
		_g29.h["elnProperties"] = "ELN_PROPERTIES"
		_g29.h["annotTexts"] = "AnnotTexts"
		_g29.h["wmf"] = "WMF"
		value31 = _g29
		_g28.h["fields"] = value31
		value32 = None
		_g30 = haxe_ds_StringMap()
		_g30.h["schema"] = "icmdb_page_secure"
		_g30.h["name"] = "V_LABPAGE_IMAGE"
		value32 = _g30
		_g28.h["table_info"] = value32
		value33 = None
		_g31 = haxe_ds_StringMap()
		_g31.h["id"] = True
		value33 = _g31
		_g28.h["indexes"] = value33
		value30 = _g28
		_g.h["saturn.core.scarab.LabPageImage"] = value30
		value34 = None
		_g32 = haxe_ds_StringMap()
		value35 = None
		_g33 = haxe_ds_StringMap()
		_g33.h["id"] = "Id"
		_g33.h["pdf"] = "PDF"
		_g33.h["image"] = "Image"
		value35 = _g33
		_g32.h["fields"] = value35
		value36 = None
		_g34 = haxe_ds_StringMap()
		_g34.h["schema"] = "icmdb_page_secure"
		_g34.h["name"] = "V_LABPAGE_PDF"
		value36 = _g34
		_g32.h["table_info"] = value36
		value37 = None
		_g35 = haxe_ds_StringMap()
		_g35.h["id"] = True
		value37 = _g35
		_g32.h["indexes"] = value37
		value34 = _g32
		_g.h["saturn.core.scarab.LabPagePdf"] = value34
		value38 = None
		_g36 = haxe_ds_StringMap()
		value39 = None
		_g37 = haxe_ds_StringMap()
		_g37.h["id"] = "Id"
		_g37.h["excel"] = "Excel"
		_g37.h["filename"] = "Filename"
		_g37.h["html"] = "Html"
		_g37.h["htmlFolder"] = "HtmlFolder"
		value39 = _g37
		_g36.h["fields"] = value39
		value40 = None
		_g38 = haxe_ds_StringMap()
		_g38.h["schema"] = "icmdb_page_secure"
		_g38.h["name"] = "V_LABPAGE_EXCEL"
		value40 = _g38
		_g36.h["table_info"] = value40
		value41 = None
		_g39 = haxe_ds_StringMap()
		_g39.h["id"] = True
		value41 = _g39
		_g36.h["indexes"] = value41
		value38 = _g36
		_g.h["saturn.core.scarab.LabPageExcel"] = value38
		value42 = None
		_g40 = haxe_ds_StringMap()
		value43 = None
		_g41 = haxe_ds_StringMap()
		_g41.h["id"] = "Id"
		_g41.h["displayOrder"] = "num"
		_g41.h["filename"] = "Filename"
		_g41.h["content"] = "Content"
		_g41.h["modifiedInICMdb"] = "ModifiedInICMdb"
		value43 = _g41
		_g40.h["fields"] = value43
		value44 = None
		_g42 = haxe_ds_StringMap()
		_g42.h["schema"] = "icmdb_page_secure"
		_g42.h["name"] = "V_LABPAGE_ATT"
		value44 = _g42
		_g40.h["table_info"] = value44
		value45 = None
		_g43 = haxe_ds_StringMap()
		_g43.h["id"] = True
		_g43.h["displayOrder"] = True
		value45 = _g43
		_g40.h["indexes"] = value45
		value42 = _g40
		_g.h["saturn.core.scarab.LabPageAttachments"] = value42
		value46 = None
		_g44 = haxe_ds_StringMap()
		value47 = None
		_g45 = haxe_ds_StringMap()
		_g45.h["path"] = "PATH"
		_g45.h["content"] = "CONTENT"
		value47 = _g45
		_g44.h["fields"] = value47
		value48 = None
		_g46 = haxe_ds_StringMap()
		_g46.h["path"] = True
		value48 = _g46
		_g44.h["indexes"] = value48
		value49 = None
		_g47 = haxe_ds_StringMap()
		value50 = None
		_g48 = haxe_ds_StringMap()
		_g48.h["/work"] = "W:"
		_g48.h["/home/share"] = "S:"
		value50 = _g48
		value51 = value50
		_g47.h["windows_conversions"] = value51
		value52 = None
		_g49 = haxe_ds_StringMap()
		_g49.h["WORK"] = "^W:[^\\.]+.pdb$"
		value52 = _g49
		value53 = value52
		_g47.h["windows_allowed_paths_regex"] = value53
		value54 = None
		_g50 = haxe_ds_StringMap()
		_g50.h["W:"] = "/work"
		value54 = _g50
		value55 = value54
		_g47.h["linux_conversions"] = value55
		value56 = None
		_g51 = haxe_ds_StringMap()
		_g51.h["WORK"] = "^/work"
		value56 = _g51
		value57 = value56
		_g47.h["linux_allowed_paths_regex"] = value57
		value49 = _g47
		_g44.h["options"] = value49
		value46 = _g44
		_g.h["saturn.core.domain.FileProxy"] = value46
		self.models = _g

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.models = None
saturn_db_mapping_KIR._hx_class = saturn_db_mapping_KIR
_hx_classes["saturn.db.mapping.KIR"] = saturn_db_mapping_KIR


class saturn_db_mapping_KISGC:
	_hx_class_name = "saturn.db.mapping.KISGC"
	_hx_fields = ["models"]
	_hx_methods = ["buildModels"]
	_hx_statics = ["getNextAvailableId"]

	def __init__(self):
		self.models = None
		self.buildModels()

	def buildModels(self):
		_g = haxe_ds_StringMap()
		value = None
		_g1 = haxe_ds_StringMap()
		value1 = None
		_g2 = haxe_ds_StringMap()
		_g2.h["constructId"] = "CONSTRUCTID"
		_g2.h["id"] = "PKEY"
		_g2.h["proteinSeq"] = "CONSTRUCTPROTSEQ"
		_g2.h["proteinSeqNoTag"] = "CONSTRUCTPROTSEQNOTAG"
		_g2.h["dnaSeq"] = "CONSTRUCTDNASEQ"
		_g2.h["docId"] = "ELNEXP"
		_g2.h["vectorId"] = "SGCVECTOR"
		_g2.h["alleleId"] = "SGCDNAINSERT"
		_g2.h["res1Id"] = "SGCRESTRICTENZYME1"
		_g2.h["res2Id"] = "SGCRESTRICTENZYME2"
		_g2.h["constructPlateId"] = "SGCPLATE"
		_g2.h["wellId"] = "PLATEWELL"
		_g2.h["expectedMass"] = "EXPECTEDMASS"
		_g2.h["expectedMassNoTag"] = "EXPETCEDMASSNOTAG"
		_g2.h["status"] = "STATUS"
		_g2.h["location"] = "SGCLOCATION"
		_g2.h["elnId"] = "ELNEXP"
		_g2.h["constructComments"] = "SEQUENCINGCOMMENTS"
		_g2.h["person"] = "PERSON"
		value1 = _g2
		_g1.h["fields"] = value1
		value2 = None
		_g3 = haxe_ds_StringMap()
		_g3.h["status"] = "In progress"
		value2 = _g3
		_g1.h["defaults"] = value2
		value3 = None
		_g4 = haxe_ds_StringMap()
		_g4.h["PERSON"] = "insert.username"
		value3 = _g4
		_g1.h["auto_functions"] = value3
		value4 = None
		_g5 = haxe_ds_StringMap()
		_g5.h["wellId"] = "1"
		_g5.h["constructPlateId"] = "1"
		_g5.h["constructId"] = "1"
		_g5.h["alleleId"] = "1"
		_g5.h["vectorId"] = "1"
		value4 = _g5
		_g1.h["required"] = value4
		value5 = None
		_g6 = haxe_ds_StringMap()
		_g6.h["constructId"] = False
		_g6.h["id"] = True
		value5 = _g6
		_g1.h["indexes"] = value5
		value6 = None
		_g7 = haxe_ds_StringMap()
		_g7.h["Construct ID"] = "constructId"
		_g7.h["Construct Plate"] = "constructPlate.plateName"
		_g7.h["Well ID"] = "wellId"
		_g7.h["Vector ID"] = "vector.vectorId"
		_g7.h["Allele ID"] = "allele.alleleId"
		_g7.h["Status"] = "status"
		_g7.h["Protein Sequence"] = "proteinSeq"
		_g7.h["Expected Mass"] = "expectedMass"
		_g7.h["Restriction Site 1"] = "res1.enzymeName"
		_g7.h["Restriction Site 2"] = "res2.enzymeName"
		_g7.h["Protein Sequence (No Tag)"] = "proteinSeqNoTag"
		_g7.h["Expected Mass (No Tag)"] = "expectedMassNoTag"
		_g7.h["Construct DNA Sequence"] = "dnaSeq"
		_g7.h["Location"] = "location"
		_g7.h["ELN ID"] = "elnId"
		_g7.h["Construct Comments"] = "constructComments"
		_g7.h["Creator"] = "person"
		_g7.h["Construct Start"] = "constructStart"
		_g7.h["Construct Stop"] = "constructStop"
		_g7.h["__HIDDEN__PKEY__"] = "id"
		value6 = _g7
		_g1.h["model"] = value6
		value7 = None
		_g8 = haxe_ds_StringMap()
		value8 = None
		_g9 = haxe_ds_StringMap()
		_g9.h["field"] = "alleleId"
		_g9.h["class"] = "saturn.core.domain.SgcAllele"
		_g9.h["fk_field"] = "alleleId"
		value8 = _g9
		value9 = value8
		_g8.h["allele"] = value9
		value10 = None
		_g10 = haxe_ds_StringMap()
		_g10.h["field"] = "vectorId"
		_g10.h["class"] = "saturn.core.domain.SgcVector"
		_g10.h["fk_field"] = "vectorId"
		value10 = _g10
		value11 = value10
		_g8.h["vector"] = value11
		value12 = None
		_g11 = haxe_ds_StringMap()
		_g11.h["field"] = "res1Id"
		_g11.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g11.h["fk_field"] = "enzymeName"
		value12 = _g11
		value13 = value12
		_g8.h["res1"] = value13
		value14 = None
		_g12 = haxe_ds_StringMap()
		_g12.h["field"] = "res2Id"
		_g12.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g12.h["fk_field"] = "enzymeName"
		value14 = _g12
		value15 = value14
		_g8.h["res2"] = value15
		value16 = None
		_g13 = haxe_ds_StringMap()
		_g13.h["field"] = "constructPlateId"
		_g13.h["class"] = "saturn.core.domain.SgcConstructPlate"
		_g13.h["fk_field"] = "plateName"
		value16 = _g13
		value17 = value16
		_g8.h["constructPlate"] = value17
		value7 = _g8
		_g1.h["fields.synthetic"] = value7
		value18 = None
		_g14 = haxe_ds_StringMap()
		_g14.h["schema"] = "SGC"
		_g14.h["name"] = "CONSTRUCT"
		value18 = _g14
		_g1.h["table_info"] = value18
		value19 = None
		_g15 = haxe_ds_StringMap()
		_g15.h["saturn.client.programs.DNASequenceEditor"] = True
		value19 = _g15
		_g1.h["programs"] = value19
		value20 = None
		_g16 = haxe_ds_StringMap()
		_g16.h["constructId"] = True
		value20 = _g16
		_g1.h["search"] = value20
		value21 = None
		_g17 = haxe_ds_StringMap()
		_g17.h["alias"] = "Construct"
		_g17.h["icon"] = "dna_conical_16.png"
		_g17.h["auto_activate"] = "3"
		value21 = _g17
		_g1.h["options"] = value21
		value = _g1
		_g.h["saturn.core.domain.SgcConstruct"] = value
		value22 = None
		_g18 = haxe_ds_StringMap()
		value23 = None
		_g19 = haxe_ds_StringMap()
		_g19.h["constructPkey"] = "SGCCONSTRUCT_PKEY"
		_g19.h["status"] = "STATUS"
		value23 = _g19
		_g18.h["fields"] = value23
		value24 = None
		_g20 = haxe_ds_StringMap()
		_g20.h["schema"] = "SGC"
		_g20.h["name"] = "CONSTR_STATUS_SNAPSHOT"
		value24 = _g20
		_g18.h["table_info"] = value24
		value25 = None
		_g21 = haxe_ds_StringMap()
		_g21.h["constructPkey"] = True
		value25 = _g21
		_g18.h["indexes"] = value25
		value22 = _g18
		_g.h["saturn.core.domain.SgcConstructStatus"] = value22
		value26 = None
		_g22 = haxe_ds_StringMap()
		value27 = None
		_g23 = haxe_ds_StringMap()
		_g23.h["alleleId"] = "DNAINSERTID"
		_g23.h["allelePlateId"] = "SGCPLATE"
		_g23.h["id"] = "PKEY"
		_g23.h["entryCloneId"] = "SGCENTRYCLONE"
		_g23.h["forwardPrimerId"] = "SGCPRIMER"
		_g23.h["reversePrimerId"] = "SGCPRIMERREV"
		_g23.h["dnaSeq"] = "DNAINSERTSEQUENCE"
		_g23.h["proteinSeq"] = "DNAINSERTPROTSEQ"
		_g23.h["status"] = "DNAINSERTSTATUS"
		_g23.h["comments"] = "COMMENTS"
		_g23.h["elnId"] = "ELNEXP"
		_g23.h["dateStamp"] = "DATESTAMP"
		_g23.h["person"] = "PERSON"
		_g23.h["plateWell"] = "PLATEWELL"
		_g23.h["dnaSeqLen"] = "DNAINSERTSEQLENGTH"
		_g23.h["domainSummary"] = "DOMAINSUMMARY"
		_g23.h["domainStartDelta"] = "DOMAINSTARTDELTA"
		_g23.h["domainStopDelta"] = "DOMAINSTOPDELTA"
		_g23.h["containsPharmaDomain"] = "CONTAINSPHARMADOMAIN"
		_g23.h["domainSummaryLong"] = "DOMAINSUMMARYLONG"
		value27 = _g23
		_g22.h["fields"] = value27
		value28 = None
		_g24 = haxe_ds_StringMap()
		_g24.h["status"] = "In process"
		value28 = _g24
		_g22.h["defaults"] = value28
		value29 = None
		_g25 = haxe_ds_StringMap()
		_g25.h["Allele ID"] = "alleleId"
		_g25.h["Plate"] = "plate.plateName"
		_g25.h["Entry Clone ID"] = "entryClone.entryCloneId"
		_g25.h["Forward Primer ID"] = "forwardPrimer.primerId"
		_g25.h["Reverse Primer ID"] = "reversePrimer.primerId"
		_g25.h["DNA Sequence"] = "dnaSeq"
		_g25.h["Protein Sequence"] = "proteinSeq"
		_g25.h["Status"] = "status"
		_g25.h["Location"] = "location"
		_g25.h["Comments"] = "comments"
		_g25.h["ELN ID"] = "elnId"
		_g25.h["Date Record"] = "dateStamp"
		_g25.h["Person"] = "person"
		_g25.h["Plate Well"] = "plateWell"
		_g25.h["DNA Length"] = "dnaSeqLen"
		_g25.h["Complex"] = "complex"
		_g25.h["Domain Summary"] = "domainSummary"
		_g25.h["Domain  Start Delta"] = "domainStartDelta"
		_g25.h["Domain Stop Delta"] = "domainStopDelta"
		_g25.h["Contains Pharma Domain"] = "containsPharmaDomain"
		_g25.h["Domain Summary Long"] = "domainSummaryLong"
		_g25.h["IMP PI"] = "impPI"
		_g25.h["__HIDDEN__PKEY__"] = "id"
		value29 = _g25
		_g22.h["model"] = value29
		value30 = None
		_g26 = haxe_ds_StringMap()
		_g26.h["alleleId"] = False
		_g26.h["id"] = True
		value30 = _g26
		_g22.h["indexes"] = value30
		value31 = None
		_g27 = haxe_ds_StringMap()
		value32 = None
		_g28 = haxe_ds_StringMap()
		_g28.h["field"] = "entryCloneId"
		_g28.h["class"] = "saturn.core.domain.SgcEntryClone"
		_g28.h["fk_field"] = "entryCloneId"
		value32 = _g28
		value33 = value32
		_g27.h["entryClone"] = value33
		value34 = None
		_g29 = haxe_ds_StringMap()
		_g29.h["field"] = "forwardPrimerId"
		_g29.h["class"] = "saturn.core.domain.SgcForwardPrimer"
		_g29.h["fk_field"] = "primerId"
		value34 = _g29
		value35 = value34
		_g27.h["forwardPrimer"] = value35
		value36 = None
		_g30 = haxe_ds_StringMap()
		_g30.h["field"] = "reversePrimerId"
		_g30.h["class"] = "saturn.core.domain.SgcReversePrimer"
		_g30.h["fk_field"] = "primerId"
		value36 = _g30
		value37 = value36
		_g27.h["reversePrimer"] = value37
		value38 = None
		_g31 = haxe_ds_StringMap()
		_g31.h["field"] = "allelePlateId"
		_g31.h["class"] = "saturn.core.domain.SgcAllelePlate"
		_g31.h["fk_field"] = "plateName"
		value38 = _g31
		value39 = value38
		_g27.h["plate"] = value39
		value31 = _g27
		_g22.h["fields.synthetic"] = value31
		value40 = None
		_g32 = haxe_ds_StringMap()
		_g32.h["schema"] = "SGC"
		_g32.h["name"] = "DNAINSERT"
		value40 = _g32
		_g22.h["table_info"] = value40
		value41 = None
		_g33 = haxe_ds_StringMap()
		_g33.h["saturn.client.programs.DNASequenceEditor"] = True
		value41 = _g33
		_g22.h["programs"] = value41
		value42 = None
		_g34 = haxe_ds_StringMap()
		_g34.h["alleleId"] = True
		value42 = _g34
		_g22.h["search"] = value42
		value43 = None
		_g35 = haxe_ds_StringMap()
		_g35.h["alias"] = "Allele"
		_g35.h["icon"] = "dna_conical_16.png"
		value43 = _g35
		_g22.h["options"] = value43
		value26 = _g22
		_g.h["saturn.core.domain.SgcAllele"] = value26
		value44 = None
		_g36 = haxe_ds_StringMap()
		value45 = None
		_g37 = haxe_ds_StringMap()
		_g37.h["entryCloneId"] = "ENTRYCLONEID"
		_g37.h["id"] = "PKEY"
		_g37.h["dnaSeq"] = "DNARAWSEQUENCE"
		_g37.h["targetId"] = "SGCTARGET"
		_g37.h["seqSource"] = "SEQSOURCE"
		_g37.h["sourceId"] = "SUPPLIERID"
		_g37.h["sequenceConfirmed"] = "SEQUENCECONFIRMED"
		value45 = _g37
		_g36.h["fields"] = value45
		value46 = None
		_g38 = haxe_ds_StringMap()
		_g38.h["entryCloneId"] = False
		_g38.h["id"] = True
		value46 = _g38
		_g36.h["indexes"] = value46
		value47 = None
		_g39 = haxe_ds_StringMap()
		_g39.h["saturn.client.programs.DNASequenceEditor"] = True
		value47 = _g39
		_g36.h["programs"] = value47
		value48 = None
		_g40 = haxe_ds_StringMap()
		_g40.h["entryCloneId"] = True
		value48 = _g40
		_g36.h["search"] = value48
		value49 = None
		_g41 = haxe_ds_StringMap()
		value50 = None
		_g42 = haxe_ds_StringMap()
		_g42.h["saturn.client.programs.DNASequenceEditor"] = True
		_g42.h["saturn.client.programs.ProteinSequenceEditor"] = True
		value50 = _g42
		value51 = value50
		_g41.h["canSave"] = value51
		_g41.h["alias"] = "Entry Clone"
		_g41.h["icon"] = "dna_conical_16.png"
		value52 = None
		_g43 = haxe_ds_StringMap()
		value53 = None
		_g44 = haxe_ds_StringMap()
		value54 = None
		_g45 = haxe_ds_StringMap()
		_g45.h["user_suffix"] = "Translation"
		_g45.h["function"] = "saturn.core.domain.SgcEntryClone.loadTranslation"
		_g45.h["icon"] = "structure_16.png"
		value54 = _g45
		_g44.h["translation"] = value54
		value53 = _g44
		_g43.h["search_bar"] = value53
		value52 = _g43
		value55 = value52
		_g41.h["actions"] = value55
		value49 = _g41
		_g36.h["options"] = value49
		value56 = None
		_g46 = haxe_ds_StringMap()
		_g46.h["schema"] = "SGC"
		_g46.h["name"] = "ENTRYCLONE"
		value56 = _g46
		_g36.h["table_info"] = value56
		value57 = None
		_g47 = haxe_ds_StringMap()
		_g47.h["Entry Clone ID"] = "entryCloneId"
		value57 = _g47
		_g36.h["model"] = value57
		value58 = None
		_g48 = haxe_ds_StringMap()
		value59 = None
		_g49 = haxe_ds_StringMap()
		_g49.h["field"] = "targetId"
		_g49.h["class"] = "saturn.core.domain.SgcTarget"
		_g49.h["fk_field"] = "targetId"
		value59 = _g49
		value60 = value59
		_g48.h["target"] = value60
		value58 = _g48
		_g36.h["fields.synthetic"] = value58
		value44 = _g36
		_g.h["saturn.core.domain.SgcEntryClone"] = value44
		value61 = None
		_g50 = haxe_ds_StringMap()
		value62 = None
		_g51 = haxe_ds_StringMap()
		_g51.h["enzymeName"] = "RESTRICTIONENZYMENAME"
		_g51.h["cutSequence"] = "RESTRICTIONENZYMESEQUENCERAW"
		_g51.h["id"] = "PKEY"
		value62 = _g51
		_g50.h["fields"] = value62
		value63 = None
		_g52 = haxe_ds_StringMap()
		_g52.h["enzymeName"] = False
		_g52.h["id"] = True
		value63 = _g52
		_g50.h["indexes"] = value63
		value64 = None
		_g53 = haxe_ds_StringMap()
		_g53.h["schema"] = "SGC"
		_g53.h["name"] = "RESTRICTIONENZYME"
		value64 = _g53
		_g50.h["table_info"] = value64
		value65 = None
		_g54 = haxe_ds_StringMap()
		_g54.h["saturn.client.programs.DNASequenceEditor"] = True
		value65 = _g54
		_g50.h["programs"] = value65
		value66 = None
		_g55 = haxe_ds_StringMap()
		_g55.h["Enzyme Name"] = "enzymeName"
		value66 = _g55
		_g50.h["model"] = value66
		value67 = None
		_g56 = haxe_ds_StringMap()
		_g56.h["alias"] = "Restriction site"
		value67 = _g56
		_g50.h["options"] = value67
		value68 = None
		_g57 = haxe_ds_StringMap()
		_g57.h["enzymeName"] = None
		value68 = _g57
		_g50.h["search"] = value68
		value61 = _g50
		_g.h["saturn.core.domain.SgcRestrictionSite"] = value61
		value69 = None
		_g58 = haxe_ds_StringMap()
		value70 = None
		_g59 = haxe_ds_StringMap()
		_g59.h["vectorId"] = "VECTORNAME"
		_g59.h["id"] = "PKEY"
		_g59.h["sequence"] = "VECTORSEQUENCERAW"
		_g59.h["vectorComments"] = "VECTORCOMMENTS"
		_g59.h["proteaseName"] = "PROTEASENAME"
		_g59.h["proteaseCutSequence"] = "PROTEASECUTSEQUENCE"
		_g59.h["proteaseProduct"] = "PROTEASEPRODUCT"
		_g59.h["antibiotic"] = "SGCANTIBIOTIC"
		_g59.h["organism"] = "SGCORGANISM"
		_g59.h["res1Id"] = "SGCRESTRICTENZ1"
		_g59.h["res2Id"] = "SGCRESTRICTENZ2"
		value70 = _g59
		_g58.h["fields"] = value70
		value71 = None
		_g60 = haxe_ds_StringMap()
		_g60.h["vectorId"] = None
		value71 = _g60
		_g58.h["search"] = value71
		value72 = None
		_g61 = haxe_ds_StringMap()
		_g61.h["saturn.client.programs.DNASequenceEditor"] = True
		value72 = _g61
		_g58.h["programs"] = value72
		value73 = None
		_g62 = haxe_ds_StringMap()
		_g62.h["vectorId"] = False
		_g62.h["id"] = True
		value73 = _g62
		_g58.h["indexes"] = value73
		value74 = None
		_g63 = haxe_ds_StringMap()
		value75 = None
		_g64 = haxe_ds_StringMap()
		_g64.h["field"] = "res1Id"
		_g64.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g64.h["fk_field"] = "enzymeName"
		value75 = _g64
		value76 = value75
		_g63.h["res1"] = value76
		value77 = None
		_g65 = haxe_ds_StringMap()
		_g65.h["field"] = "res2Id"
		_g65.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g65.h["fk_field"] = "enzymeName"
		value77 = _g65
		value78 = value77
		_g63.h["res2"] = value78
		value74 = _g63
		_g58.h["fields.synthetic"] = value74
		value79 = None
		_g66 = haxe_ds_StringMap()
		_g66.h["schema"] = "SGC"
		_g66.h["name"] = "VECTOR"
		value79 = _g66
		_g58.h["table_info"] = value79
		value80 = None
		_g67 = haxe_ds_StringMap()
		_g67.h["auto_activate"] = "3"
		_g67.h["alias"] = "Vector"
		value80 = _g67
		_g58.h["options"] = value80
		value81 = None
		_g68 = haxe_ds_StringMap()
		_g68.h["Name"] = "vectorId"
		_g68.h["Comments"] = "vectorComments"
		_g68.h["Protease"] = "proteaseName"
		_g68.h["Protease cut sequence"] = "proteaseCutSequence"
		_g68.h["Protease product"] = "proteaseProduct"
		_g68.h["Forward extension"] = "requiredForwardExtension"
		_g68.h["Reverse extension"] = "requiredReverseExtension"
		_g68.h["Restriction site 1"] = "res1.enzymeName"
		_g68.h["Restriction site 2"] = "res2.enzymeName"
		value81 = _g68
		_g58.h["model"] = value81
		value69 = _g58
		_g.h["saturn.core.domain.SgcVector"] = value69
		value82 = None
		_g69 = haxe_ds_StringMap()
		value83 = None
		_g70 = haxe_ds_StringMap()
		_g70.h["primerId"] = "PRIMERID"
		_g70.h["id"] = "PKEY"
		_g70.h["dnaSequence"] = "PRIMERRAWSEQUENCE"
		_g70.h["targetId"] = "SGCTARGET"
		value83 = _g70
		_g69.h["fields"] = value83
		value84 = None
		_g71 = haxe_ds_StringMap()
		_g71.h["primerId"] = False
		_g71.h["id"] = True
		value84 = _g71
		_g69.h["indexes"] = value84
		value85 = None
		_g72 = haxe_ds_StringMap()
		_g72.h["schema"] = "SGC"
		_g72.h["name"] = "PRIMER"
		value85 = _g72
		_g69.h["table_info"] = value85
		value86 = None
		_g73 = haxe_ds_StringMap()
		_g73.h["saturn.client.programs.DNASequenceEditor"] = True
		value86 = _g73
		_g69.h["programs"] = value86
		value87 = None
		_g74 = haxe_ds_StringMap()
		_g74.h["primerId"] = True
		value87 = _g74
		_g69.h["search"] = value87
		value88 = None
		_g75 = haxe_ds_StringMap()
		_g75.h["alias"] = "Forward Primer"
		_g75.h["icon"] = "dna_conical_16.png"
		value88 = _g75
		_g69.h["options"] = value88
		value89 = None
		_g76 = haxe_ds_StringMap()
		_g76.h["Primer ID"] = "primerId"
		value89 = _g76
		_g69.h["model"] = value89
		value82 = _g69
		_g.h["saturn.core.domain.SgcForwardPrimer"] = value82
		value90 = None
		_g77 = haxe_ds_StringMap()
		value91 = None
		_g78 = haxe_ds_StringMap()
		_g78.h["primerId"] = "PRIMERREVID"
		_g78.h["id"] = "PKEY"
		_g78.h["dnaSequence"] = "PRIMERRAWSEQUENCE"
		_g78.h["targetId"] = "SGCTARGET"
		value91 = _g78
		_g77.h["fields"] = value91
		value92 = None
		_g79 = haxe_ds_StringMap()
		_g79.h["primerId"] = False
		_g79.h["id"] = True
		value92 = _g79
		_g77.h["indexes"] = value92
		value93 = None
		_g80 = haxe_ds_StringMap()
		_g80.h["schema"] = "SGC"
		_g80.h["name"] = "PRIMERREV"
		value93 = _g80
		_g77.h["table_info"] = value93
		value94 = None
		_g81 = haxe_ds_StringMap()
		_g81.h["saturn.client.programs.DNASequenceEditor"] = True
		value94 = _g81
		_g77.h["programs"] = value94
		value95 = None
		_g82 = haxe_ds_StringMap()
		_g82.h["primerId"] = True
		value95 = _g82
		_g77.h["search"] = value95
		value96 = None
		_g83 = haxe_ds_StringMap()
		_g83.h["alias"] = "Reverse Primer"
		_g83.h["icon"] = "dna_conical_16.png"
		value96 = _g83
		_g77.h["options"] = value96
		value97 = None
		_g84 = haxe_ds_StringMap()
		_g84.h["Primer ID"] = "primerId"
		value97 = _g84
		_g77.h["model"] = value97
		value90 = _g77
		_g.h["saturn.core.domain.SgcReversePrimer"] = value90
		value98 = None
		_g85 = haxe_ds_StringMap()
		value99 = None
		_g86 = haxe_ds_StringMap()
		_g86.h["purificationId"] = "PURIFICATIONID"
		_g86.h["id"] = "PKEY"
		_g86.h["expressionId"] = "SGCSCALEUPEXPRESSION"
		_g86.h["column"] = "COLUMN1"
		_g86.h["elnId"] = "ELNEXPERIMENT"
		value99 = _g86
		_g85.h["fields"] = value99
		value100 = None
		_g87 = haxe_ds_StringMap()
		_g87.h["purificationId"] = False
		_g87.h["id"] = True
		value100 = _g87
		_g85.h["indexes"] = value100
		value101 = None
		_g88 = haxe_ds_StringMap()
		_g88.h["schema"] = "SGC"
		_g88.h["name"] = "PURIFICATION"
		value101 = _g88
		_g85.h["table_info"] = value101
		value102 = None
		_g89 = haxe_ds_StringMap()
		_g89.h["saturn.client.programs.DNASequenceEditor"] = True
		value102 = _g89
		_g85.h["programs"] = value102
		value103 = None
		_g90 = haxe_ds_StringMap()
		value104 = None
		_g91 = haxe_ds_StringMap()
		_g91.h["field"] = "expressionId"
		_g91.h["class"] = "saturn.core.domain.SgcExpression"
		_g91.h["fk_field"] = "expressionId"
		value104 = _g91
		value105 = value104
		_g90.h["expression"] = value105
		value103 = _g90
		_g85.h["fields.synthetic"] = value103
		value106 = None
		_g92 = haxe_ds_StringMap()
		_g92.h["Purification ID"] = "purificationId"
		value106 = _g92
		_g85.h["model"] = value106
		value98 = _g85
		_g.h["saturn.core.domain.SgcPurification"] = value98
		value107 = None
		_g93 = haxe_ds_StringMap()
		value108 = None
		_g94 = haxe_ds_StringMap()
		_g94.h["cloneId"] = "CLONEID"
		_g94.h["id"] = "PKEY"
		_g94.h["constructId"] = "SGCCONSTRUCT1"
		_g94.h["elnId"] = "ELNEXP"
		value108 = _g94
		_g93.h["fields"] = value108
		value109 = None
		_g95 = haxe_ds_StringMap()
		_g95.h["cloneId"] = False
		_g95.h["id"] = True
		value109 = _g95
		_g93.h["indexes"] = value109
		value110 = None
		_g96 = haxe_ds_StringMap()
		_g96.h["schema"] = "SGC"
		_g96.h["name"] = "CLONE"
		value110 = _g96
		_g93.h["table_info"] = value110
		value111 = None
		_g97 = haxe_ds_StringMap()
		_g97.h["saturn.client.programs.DNASequenceEditor"] = True
		value111 = _g97
		_g93.h["programs"] = value111
		value112 = None
		_g98 = haxe_ds_StringMap()
		value113 = None
		_g99 = haxe_ds_StringMap()
		_g99.h["field"] = "constructId"
		_g99.h["class"] = "saturn.core.domain.SgcConstruct"
		_g99.h["fk_field"] = "constructId"
		value113 = _g99
		value114 = value113
		_g98.h["construct"] = value114
		value112 = _g98
		_g93.h["fields.synthetic"] = value112
		value115 = None
		_g100 = haxe_ds_StringMap()
		_g100.h["Clone ID"] = "cloneId"
		value115 = _g100
		_g93.h["model"] = value115
		value107 = _g93
		_g.h["saturn.core.domain.SgcClone"] = value107
		value116 = None
		_g101 = haxe_ds_StringMap()
		value117 = None
		_g102 = haxe_ds_StringMap()
		_g102.h["expressionId"] = "SCALEUPEXPRESSIONID"
		_g102.h["id"] = "PKEY"
		_g102.h["cloneId"] = "SGCCLONE"
		_g102.h["elnId"] = "ELNEXPERIMENT"
		value117 = _g102
		_g101.h["fields"] = value117
		value118 = None
		_g103 = haxe_ds_StringMap()
		_g103.h["expressionId"] = False
		_g103.h["id"] = True
		value118 = _g103
		_g101.h["indexes"] = value118
		value119 = None
		_g104 = haxe_ds_StringMap()
		_g104.h["schema"] = "SGC"
		_g104.h["name"] = "SCALEUPEXPRESSION"
		value119 = _g104
		_g101.h["table_info"] = value119
		value120 = None
		_g105 = haxe_ds_StringMap()
		_g105.h["saturn.client.programs.DNASequenceEditor"] = True
		value120 = _g105
		_g101.h["programs"] = value120
		value121 = None
		_g106 = haxe_ds_StringMap()
		value122 = None
		_g107 = haxe_ds_StringMap()
		_g107.h["field"] = "cloneId"
		_g107.h["class"] = "saturn.core.domain.SgcClone"
		_g107.h["fk_field"] = "cloneId"
		value122 = _g107
		value123 = value122
		_g106.h["clone"] = value123
		value121 = _g106
		_g101.h["fields.synthetic"] = value121
		value124 = None
		_g108 = haxe_ds_StringMap()
		_g108.h["Expression ID"] = "expressionId"
		value124 = _g108
		_g101.h["model"] = value124
		value116 = _g101
		_g.h["saturn.core.domain.SgcExpression"] = value116
		value125 = None
		_g109 = haxe_ds_StringMap()
		value126 = None
		_g110 = haxe_ds_StringMap()
		_g110.h["targetId"] = "TARGETNAME"
		_g110.h["id"] = "PKEY"
		_g110.h["gi"] = "GENBANKID"
		_g110.h["geneId"] = "NCBIGENEID"
		_g110.h["proteinSeq"] = "PROTSEQ"
		_g110.h["dnaSeq"] = "DNASEQ"
		_g110.h["activeStatus"] = "ACTIVESTATUS"
		value126 = _g110
		_g109.h["fields"] = value126
		value127 = None
		_g111 = haxe_ds_StringMap()
		_g111.h["targetId"] = False
		_g111.h["id"] = True
		value127 = _g111
		_g109.h["indexes"] = value127
		value128 = None
		_g112 = haxe_ds_StringMap()
		_g112.h["schema"] = "SGC"
		_g112.h["name"] = "TARGET"
		_g112.h["human_name"] = "Target"
		_g112.h["human_name_plural"] = "Targets"
		value128 = _g112
		_g109.h["table_info"] = value128
		value129 = None
		_g113 = haxe_ds_StringMap()
		_g113.h["Target ID"] = "targetId"
		_g113.h["Genbank ID"] = "gi"
		_g113.h["DNA Sequence"] = "dnaSequence.sequence"
		_g113.h["__HIDDEN__PKEY__"] = "id"
		value129 = _g113
		_g109.h["model"] = value129
		value130 = None
		_g114 = haxe_ds_StringMap()
		_g114.h["id_pattern"] = ".*"
		_g114.h["alias"] = "Targets"
		_g114.h["icon"] = "protein_16.png"
		value131 = None
		_g115 = haxe_ds_StringMap()
		value132 = None
		_g116 = haxe_ds_StringMap()
		value133 = None
		_g117 = haxe_ds_StringMap()
		_g117.h["user_suffix"] = "Wonka"
		_g117.h["function"] = "saturn.core.domain.SgcTarget.loadWonka"
		value133 = _g117
		_g116.h["wonka"] = value133
		value132 = _g116
		_g115.h["search_bar"] = value132
		value131 = _g115
		value134 = value131
		_g114.h["actions"] = value134
		value130 = _g114
		_g109.h["options"] = value130
		value125 = _g109
		_g.h["saturn.core.domain.SgcTarget"] = value125
		value135 = None
		_g118 = haxe_ds_StringMap()
		value136 = None
		_g119 = haxe_ds_StringMap()
		_g119.h["sequence"] = "SEQ"
		_g119.h["id"] = "PKEY"
		_g119.h["type"] = "SEQTYPE"
		_g119.h["version"] = "TARGETVERSION"
		_g119.h["targetId"] = "SGCTARGET_PKEY"
		_g119.h["crc"] = "CRC"
		_g119.h["target"] = "TARGET_ID"
		value136 = _g119
		_g118.h["fields"] = value136
		value137 = None
		_g120 = haxe_ds_StringMap()
		_g120.h["id"] = True
		value137 = _g120
		_g118.h["indexes"] = value137
		value138 = None
		_g121 = haxe_ds_StringMap()
		_g121.h["schema"] = ""
		_g121.h["name"] = "SEQDATA"
		value138 = _g121
		_g118.h["table_info"] = value138
		value139 = None
		_g122 = haxe_ds_StringMap()
		_g122.h["field"] = "type"
		_g122.h["value"] = "Nucleotide"
		value139 = _g122
		_g118.h["selector"] = value139
		value135 = _g118
		_g.h["saturn.core.domain.SgcTargetDNA"] = value135
		value140 = None
		_g123 = haxe_ds_StringMap()
		value141 = None
		_g124 = haxe_ds_StringMap()
		_g124.h["sequence"] = "SEQ"
		_g124.h["id"] = "PKEY"
		_g124.h["type"] = "SEQTYPE"
		_g124.h["version"] = "TARGETVERSION"
		_g124.h["targetId"] = "SGCTARGET_PKEY"
		_g124.h["crc"] = "CRC"
		_g124.h["target"] = "TARGET_ID"
		value141 = _g124
		_g123.h["fields"] = value141
		value142 = None
		_g125 = haxe_ds_StringMap()
		_g125.h["id"] = True
		value142 = _g125
		_g123.h["indexes"] = value142
		value143 = None
		_g126 = haxe_ds_StringMap()
		_g126.h["schema"] = ""
		_g126.h["name"] = "SEQDATA"
		value143 = _g126
		_g123.h["table_info"] = value143
		value140 = _g123
		_g.h["saturn.core.domain.SgcSeqData"] = value140
		value144 = None
		_g127 = haxe_ds_StringMap()
		value145 = None
		_g128 = haxe_ds_StringMap()
		_g128.h["id"] = "PKEY"
		_g128.h["accession"] = "IDENTIFIER"
		_g128.h["start"] = "SEQSTART"
		_g128.h["stop"] = "SEQSTOP"
		_g128.h["targetId"] = "SGCTARGET_PKEY"
		value145 = _g128
		_g127.h["fields"] = value145
		value146 = None
		_g129 = haxe_ds_StringMap()
		_g129.h["accession"] = False
		_g129.h["id"] = True
		value146 = _g129
		_g127.h["indexes"] = value146
		value144 = _g127
		_g.h["saturn.core.domain.SgcDomain"] = value144
		value147 = None
		_g130 = haxe_ds_StringMap()
		value148 = None
		_g131 = haxe_ds_StringMap()
		_g131.h["id"] = "PKEY"
		_g131.h["plateName"] = "PLATENAME"
		_g131.h["elnRef"] = "ELNREF"
		value148 = _g131
		_g130.h["fields"] = value148
		value149 = None
		_g132 = haxe_ds_StringMap()
		_g132.h["plateName"] = False
		_g132.h["id"] = True
		value149 = _g132
		_g130.h["indexes"] = value149
		value150 = None
		_g133 = haxe_ds_StringMap()
		_g133.h["schema"] = "SGC"
		_g133.h["name"] = "PLATE"
		value150 = _g133
		_g130.h["table_info"] = value150
		value151 = None
		_g134 = haxe_ds_StringMap()
		_g134.h["workspace_wrapper"] = "saturn.client.workspace.MultiConstructHelperWO"
		_g134.h["icon"] = "dna_conical_16.png"
		_g134.h["alias"] = "Construct Plate"
		value151 = _g134
		_g130.h["options"] = value151
		value152 = None
		_g135 = haxe_ds_StringMap()
		_g135.h["plateName"] = True
		value152 = _g135
		_g130.h["fts"] = value152
		value147 = _g130
		_g.h["saturn.core.domain.SgcConstructPlate"] = value147
		value153 = None
		_g136 = haxe_ds_StringMap()
		value154 = None
		_g137 = haxe_ds_StringMap()
		_g137.h["id"] = "PKEY"
		_g137.h["plateName"] = "PLATENAME"
		_g137.h["elnRef"] = "ELNREF"
		value154 = _g137
		_g136.h["fields"] = value154
		value155 = None
		_g138 = haxe_ds_StringMap()
		_g138.h["plateName"] = False
		_g138.h["id"] = True
		value155 = _g138
		_g136.h["indexes"] = value155
		value156 = None
		_g139 = haxe_ds_StringMap()
		_g139.h["schema"] = "SGC"
		_g139.h["name"] = "PLATE"
		value156 = _g139
		_g136.h["table_info"] = value156
		value157 = None
		_g140 = haxe_ds_StringMap()
		_g140.h["workspace_wrapper"] = "saturn.client.workspace.MultiAlleleHelperWO"
		_g140.h["icon"] = "dna_conical_16.png"
		_g140.h["alias"] = "Allele Plate"
		value157 = _g140
		_g136.h["options"] = value157
		value158 = None
		_g141 = haxe_ds_StringMap()
		_g141.h["plateName"] = True
		value158 = _g141
		_g136.h["fts"] = value158
		value153 = _g136
		_g.h["saturn.core.domain.SgcAllelePlate"] = value153
		value159 = None
		_g142 = haxe_ds_StringMap()
		value160 = None
		_g143 = haxe_ds_StringMap()
		_g143.h["dnaId"] = "DNA_ID"
		_g143.h["id"] = "PKEY"
		_g143.h["dnaSeq"] = "DNASEQUENCE"
		value160 = _g143
		_g142.h["fields"] = value160
		value161 = None
		_g144 = haxe_ds_StringMap()
		_g144.h["dnaId"] = False
		_g144.h["id"] = True
		value161 = _g144
		_g142.h["indexes"] = value161
		value162 = None
		_g145 = haxe_ds_StringMap()
		_g145.h["schema"] = "SGC"
		_g145.h["name"] = "DNA"
		value162 = _g145
		_g142.h["table_info"] = value162
		value159 = _g142
		_g.h["saturn.core.domain.SgcDNA"] = value159
		value163 = None
		_g146 = haxe_ds_StringMap()
		value164 = None
		_g147 = haxe_ds_StringMap()
		_g147.h["pageId"] = "PAGEID"
		_g147.h["id"] = "PKEY"
		_g147.h["content"] = "CONTENT"
		value164 = _g147
		_g146.h["fields"] = value164
		value165 = None
		_g148 = haxe_ds_StringMap()
		_g148.h["pageId"] = False
		_g148.h["id"] = True
		value165 = _g148
		_g146.h["indexes"] = value165
		value166 = None
		_g149 = haxe_ds_StringMap()
		_g149.h["schema"] = "SGC"
		_g149.h["name"] = "TIDDLY_WIKI"
		value166 = _g149
		_g146.h["table_info"] = value166
		value163 = _g146
		_g.h["saturn.core.domain.TiddlyWiki"] = value163
		value167 = None
		_g150 = haxe_ds_StringMap()
		value168 = None
		_g151 = haxe_ds_StringMap()
		_g151.h["id"] = "PKEY"
		_g151.h["entityId"] = "ID"
		_g151.h["dataSourceId"] = "SOURCE_PKEY"
		_g151.h["reactionId"] = "SGCREACTION_PKEY"
		_g151.h["entityTypeId"] = "SGCENTITY_TYPE"
		_g151.h["altName"] = "ALTNAME"
		_g151.h["description"] = "DESCRIPTION"
		value168 = _g151
		_g150.h["fields"] = value168
		value169 = None
		_g152 = haxe_ds_StringMap()
		_g152.h["entityId"] = False
		_g152.h["id"] = True
		value169 = _g152
		_g150.h["indexes"] = value169
		value170 = None
		_g153 = haxe_ds_StringMap()
		_g153.h["schema"] = "SGC"
		_g153.h["name"] = "Z_ENTITY"
		value170 = _g153
		_g150.h["table_info"] = value170
		value171 = None
		_g154 = haxe_ds_StringMap()
		value172 = None
		_g155 = haxe_ds_StringMap()
		_g155.h["field"] = "dataSourceId"
		_g155.h["class"] = "saturn.core.domain.DataSource"
		_g155.h["fk_field"] = "id"
		value172 = _g155
		value173 = value172
		_g154.h["source"] = value173
		value174 = None
		_g156 = haxe_ds_StringMap()
		_g156.h["field"] = "reactionId"
		_g156.h["class"] = "saturn.core.Reaction"
		_g156.h["fk_field"] = "id"
		value174 = _g156
		value175 = value174
		_g154.h["reaction"] = value175
		value176 = None
		_g157 = haxe_ds_StringMap()
		_g157.h["field"] = "entityTypeId"
		_g157.h["class"] = "saturn.core.EntityType"
		_g157.h["fk_field"] = "id"
		value176 = _g157
		value177 = value176
		_g154.h["entityType"] = value177
		value171 = _g154
		_g150.h["fields.synthetic"] = value171
		value167 = _g150
		_g.h["saturn.core.domain.Entity"] = value167
		value178 = None
		_g158 = haxe_ds_StringMap()
		value179 = None
		_g159 = haxe_ds_StringMap()
		_g159.h["id"] = "PKEY"
		_g159.h["name"] = "ID"
		_g159.h["sequence"] = "LINEAR_SEQUENCE"
		_g159.h["entityId"] = "SGCENTITY_PKEY"
		value179 = _g159
		_g158.h["fields"] = value179
		value180 = None
		_g160 = haxe_ds_StringMap()
		_g160.h["name"] = False
		_g160.h["id"] = True
		value180 = _g160
		_g158.h["indexes"] = value180
		value181 = None
		_g161 = haxe_ds_StringMap()
		_g161.h["schema"] = "SGC"
		_g161.h["name"] = "Z_MOLECULE"
		value181 = _g161
		_g158.h["table_info"] = value181
		value182 = None
		_g162 = haxe_ds_StringMap()
		value183 = None
		_g163 = haxe_ds_StringMap()
		_g163.h["field"] = "entityId"
		_g163.h["class"] = "saturn.core.Entity"
		_g163.h["fk_field"] = "id"
		value183 = _g163
		value184 = value183
		_g162.h["entity"] = value184
		value182 = _g162
		_g158.h["fields.synthetic"] = value182
		value178 = _g158
		_g.h["saturn.core.domain.Molecule"] = value178
		value185 = None
		_g164 = haxe_ds_StringMap()
		value186 = None
		_g165 = haxe_ds_StringMap()
		_g165.h["id"] = "PKEY"
		_g165.h["name"] = "NAME"
		value186 = _g165
		_g164.h["fields"] = value186
		value187 = None
		_g166 = haxe_ds_StringMap()
		_g166.h["name"] = False
		_g166.h["id"] = True
		value187 = _g166
		_g164.h["indexes"] = value187
		value188 = None
		_g167 = haxe_ds_StringMap()
		_g167.h["schema"] = "SGC"
		_g167.h["name"] = "Z_REACTION_TYPE"
		value188 = _g167
		_g164.h["table_info"] = value188
		value185 = _g164
		_g.h["saturn.core.ReactionType"] = value185
		value189 = None
		_g168 = haxe_ds_StringMap()
		value190 = None
		_g169 = haxe_ds_StringMap()
		_g169.h["id"] = "PKEY"
		_g169.h["name"] = "NAME"
		value190 = _g169
		_g168.h["fields"] = value190
		value191 = None
		_g170 = haxe_ds_StringMap()
		_g170.h["name"] = False
		_g170.h["id"] = True
		value191 = _g170
		_g168.h["indexes"] = value191
		value192 = None
		_g171 = haxe_ds_StringMap()
		_g171.h["schema"] = "SGC"
		_g171.h["name"] = "Z_ENTITY_TYPE"
		value192 = _g171
		_g168.h["table_info"] = value192
		value189 = _g168
		_g.h["saturn.core.EntityType"] = value189
		value193 = None
		_g172 = haxe_ds_StringMap()
		value194 = None
		_g173 = haxe_ds_StringMap()
		_g173.h["id"] = "PKEY"
		_g173.h["name"] = "NAME"
		value194 = _g173
		_g172.h["fields"] = value194
		value195 = None
		_g174 = haxe_ds_StringMap()
		_g174.h["name"] = False
		_g174.h["id"] = True
		value195 = _g174
		_g172.h["indexes"] = value195
		value196 = None
		_g175 = haxe_ds_StringMap()
		_g175.h["schema"] = "SGC"
		_g175.h["name"] = "Z_REACTION_ROLE"
		value196 = _g175
		_g172.h["table_info"] = value196
		value193 = _g172
		_g.h["saturn.core.ReactionRole"] = value193
		value197 = None
		_g176 = haxe_ds_StringMap()
		value198 = None
		_g177 = haxe_ds_StringMap()
		_g177.h["id"] = "PKEY"
		_g177.h["name"] = "NAME"
		_g177.h["reactionTypeId"] = "SGCREACTION_TYPE"
		value198 = _g177
		_g176.h["fields"] = value198
		value199 = None
		_g178 = haxe_ds_StringMap()
		_g178.h["name"] = False
		_g178.h["id"] = True
		value199 = _g178
		_g176.h["indexes"] = value199
		value200 = None
		_g179 = haxe_ds_StringMap()
		_g179.h["schema"] = "SGC"
		_g179.h["name"] = "Z_REACTION"
		value200 = _g179
		_g176.h["table_info"] = value200
		value201 = None
		_g180 = haxe_ds_StringMap()
		value202 = None
		_g181 = haxe_ds_StringMap()
		_g181.h["field"] = "reactionTypeId"
		_g181.h["class"] = "saturn.core.ReactionType"
		_g181.h["fk_field"] = "id"
		value202 = _g181
		value203 = value202
		_g180.h["reactionType"] = value203
		value201 = _g180
		_g176.h["fields.synthetic"] = value201
		value197 = _g176
		_g.h["saturn.core.Reaction"] = value197
		value204 = None
		_g182 = haxe_ds_StringMap()
		value205 = None
		_g183 = haxe_ds_StringMap()
		_g183.h["id"] = "PKEY"
		_g183.h["reactionRoleId"] = "SGCROLE_PKEY"
		_g183.h["entityId"] = "SGCENTITY_PKEY"
		_g183.h["reactionId"] = "SGCREACTION_PKEY"
		_g183.h["position"] = "POSITION"
		value205 = _g183
		_g182.h["fields"] = value205
		value206 = None
		_g184 = haxe_ds_StringMap()
		_g184.h["id"] = True
		value206 = _g184
		_g182.h["indexes"] = value206
		value207 = None
		_g185 = haxe_ds_StringMap()
		_g185.h["schema"] = "SGC"
		_g185.h["name"] = "Z_REACTION_COMPONENT"
		value207 = _g185
		_g182.h["table_info"] = value207
		value208 = None
		_g186 = haxe_ds_StringMap()
		value209 = None
		_g187 = haxe_ds_StringMap()
		_g187.h["field"] = "reactionRoleId"
		_g187.h["class"] = "saturn.core.ReactionRole"
		_g187.h["fk_field"] = "id"
		value209 = _g187
		value210 = value209
		_g186.h["reactionRole"] = value210
		value211 = None
		_g188 = haxe_ds_StringMap()
		_g188.h["field"] = "reactionId"
		_g188.h["class"] = "saturn.core.Reaction"
		_g188.h["fk_field"] = "id"
		value211 = _g188
		value212 = value211
		_g186.h["reaction"] = value212
		value213 = None
		_g189 = haxe_ds_StringMap()
		_g189.h["field"] = "entityId"
		_g189.h["class"] = "saturn.core.Entity"
		_g189.h["fk_field"] = "id"
		value213 = _g189
		value214 = value213
		_g186.h["entity"] = value214
		value208 = _g186
		_g182.h["fields.synthetic"] = value208
		value204 = _g182
		_g.h["saturn.core.ReactionComponent"] = value204
		value215 = None
		_g190 = haxe_ds_StringMap()
		value216 = None
		_g191 = haxe_ds_StringMap()
		_g191.h["id"] = "PKEY"
		_g191.h["name"] = "NAME"
		value216 = _g191
		_g190.h["fields"] = value216
		value217 = None
		_g192 = haxe_ds_StringMap()
		_g192.h["name"] = False
		_g192.h["id"] = True
		value217 = _g192
		_g190.h["indexes"] = value217
		value218 = None
		_g193 = haxe_ds_StringMap()
		_g193.h["schema"] = "SGC"
		_g193.h["name"] = "Z_ENTITY_SOURCE"
		value218 = _g193
		_g190.h["table_info"] = value218
		value215 = _g190
		_g.h["saturn.core.domain.DataSource"] = value215
		value219 = None
		_g194 = haxe_ds_StringMap()
		value220 = None
		_g195 = haxe_ds_StringMap()
		_g195.h["id"] = "PKEY"
		_g195.h["entityId"] = "SGCENTITY_PKEY"
		_g195.h["labelId"] = "XREF_SGCENTITY_PKEY"
		_g195.h["start"] = "STARTPOS"
		_g195.h["stop"] = "STOPPOS"
		_g195.h["evalue"] = "EVALUE"
		value220 = _g195
		_g194.h["fields"] = value220
		value221 = None
		_g196 = haxe_ds_StringMap()
		_g196.h["id"] = True
		value221 = _g196
		_g194.h["indexes"] = value221
		value222 = None
		_g197 = haxe_ds_StringMap()
		_g197.h["schema"] = "SGC"
		_g197.h["name"] = "Z_ANNOTATION"
		value222 = _g197
		_g194.h["table_info"] = value222
		value223 = None
		_g198 = haxe_ds_StringMap()
		value224 = None
		_g199 = haxe_ds_StringMap()
		_g199.h["field"] = "entityId"
		_g199.h["class"] = "saturn.core.domain.Entity"
		_g199.h["fk_field"] = "id"
		value224 = _g199
		value225 = value224
		_g198.h["entity"] = value225
		value226 = None
		_g200 = haxe_ds_StringMap()
		_g200.h["field"] = "labelId"
		_g200.h["class"] = "saturn.core.domain.Entity"
		_g200.h["fk_field"] = "id"
		value226 = _g200
		value227 = value226
		_g198.h["referent"] = value227
		value223 = _g198
		_g194.h["fields.synthetic"] = value223
		value219 = _g194
		_g.h["saturn.core.domain.MoleculeAnnotation"] = value219
		value228 = None
		_g201 = haxe_ds_StringMap()
		value229 = None
		_g202 = haxe_ds_StringMap()
		_g202.h["id"] = "PKEY"
		_g202.h["modelId"] = "MODELID"
		_g202.h["pathToPdb"] = "PATHTOPDB"
		value229 = _g202
		_g201.h["fields"] = value229
		value230 = None
		_g203 = haxe_ds_StringMap()
		_g203.h["modelId"] = False
		_g203.h["id"] = True
		value230 = _g203
		_g201.h["indexes"] = value230
		value231 = None
		_g204 = haxe_ds_StringMap()
		_g204.h["schema"] = "SGC"
		_g204.h["name"] = "MODEL"
		value231 = _g204
		_g201.h["table_info"] = value231
		value232 = None
		_g205 = haxe_ds_StringMap()
		value233 = None
		_g206 = haxe_ds_StringMap()
		_g206.h["field"] = "pathToPdb"
		_g206.h["class"] = "saturn.core.domain.FileProxy"
		_g206.h["fk_field"] = "path"
		value233 = _g206
		value234 = value233
		_g205.h["pdb"] = value234
		value232 = _g205
		_g201.h["fields.synthetic"] = value232
		value235 = None
		_g207 = haxe_ds_StringMap()
		_g207.h["id_pattern"] = "\\w+-m"
		_g207.h["workspace_wrapper"] = "saturn.client.workspace.StructureModelWO"
		_g207.h["icon"] = "structure_16.png"
		_g207.h["alias"] = "Models"
		value235 = _g207
		_g201.h["options"] = value235
		value236 = None
		_g208 = haxe_ds_StringMap()
		_g208.h["modelId"] = "\\w+-m"
		value236 = _g208
		_g201.h["search"] = value236
		value237 = None
		_g209 = haxe_ds_StringMap()
		_g209.h["Model ID"] = "modelId"
		_g209.h["Path to PDB"] = "pathToPdb"
		value237 = _g209
		_g201.h["model"] = value237
		value228 = _g201
		_g.h["saturn.core.domain.StructureModel"] = value228
		value238 = None
		_g210 = haxe_ds_StringMap()
		value239 = None
		_g211 = haxe_ds_StringMap()
		_g211.h["path"] = "PATH"
		_g211.h["content"] = "CONTENT"
		value239 = _g211
		_g210.h["fields"] = value239
		value240 = None
		_g212 = haxe_ds_StringMap()
		_g212.h["path"] = True
		value240 = _g212
		_g210.h["indexes"] = value240
		value241 = None
		_g213 = haxe_ds_StringMap()
		value242 = None
		_g214 = haxe_ds_StringMap()
		_g214.h["/work"] = "W:"
		_g214.h["/home/share"] = "S:"
		value242 = _g214
		value243 = value242
		_g213.h["windows_conversions"] = value243
		value244 = None
		_g215 = haxe_ds_StringMap()
		_g215.h["WORK"] = "^W"
		value244 = _g215
		value245 = value244
		_g213.h["windows_allowed_paths_regex"] = value245
		value246 = None
		_g216 = haxe_ds_StringMap()
		_g216.h["W:"] = "/work"
		value246 = _g216
		value247 = value246
		_g213.h["linux_conversions"] = value247
		value248 = None
		_g217 = haxe_ds_StringMap()
		_g217.h["WORK"] = "^/work"
		value248 = _g217
		value249 = value248
		_g213.h["linux_allowed_paths_regex"] = value249
		value241 = _g213
		_g210.h["options"] = value241
		value238 = _g210
		_g.h["saturn.core.domain.FileProxy"] = value238
		value250 = None
		_g218 = haxe_ds_StringMap()
		value251 = None
		_g219 = haxe_ds_StringMap()
		_g219.h["moleculeName"] = "NAME"
		value251 = _g219
		_g218.h["fields"] = value251
		value252 = None
		_g220 = haxe_ds_StringMap()
		_g220.h["moleculeName"] = True
		value252 = _g220
		_g218.h["indexes"] = value252
		value253 = None
		_g221 = haxe_ds_StringMap()
		_g221.h["saturn.client.programs.DNASequenceEditor"] = False
		value253 = _g221
		_g218.h["programs"] = value253
		value254 = None
		_g222 = haxe_ds_StringMap()
		_g222.h["alias"] = "DNA"
		_g222.h["icon"] = "dna_conical_16.png"
		value254 = _g222
		_g218.h["options"] = value254
		value250 = _g218
		_g.h["saturn.core.DNA"] = value250
		value255 = None
		_g223 = haxe_ds_StringMap()
		value256 = None
		_g224 = haxe_ds_StringMap()
		_g224.h["moleculeName"] = "NAME"
		value256 = _g224
		_g223.h["fields"] = value256
		value257 = None
		_g225 = haxe_ds_StringMap()
		_g225.h["moleculeName"] = True
		value257 = _g225
		_g223.h["indexes"] = value257
		value258 = None
		_g226 = haxe_ds_StringMap()
		_g226.h["saturn.client.programs.ProteinSequenceEditor"] = False
		value258 = _g226
		_g223.h["programs"] = value258
		value259 = None
		_g227 = haxe_ds_StringMap()
		_g227.h["alias"] = "Proteins"
		_g227.h["icon"] = "structure_16.png"
		value259 = _g227
		_g223.h["options"] = value259
		value255 = _g223
		_g.h["saturn.core.Protein"] = value255
		value260 = None
		_g228 = haxe_ds_StringMap()
		value261 = None
		_g229 = haxe_ds_StringMap()
		_g229.h["name"] = "NAME"
		value261 = _g229
		_g228.h["fields"] = value261
		value262 = None
		_g230 = haxe_ds_StringMap()
		_g230.h["name"] = True
		value262 = _g230
		_g228.h["indexes"] = value262
		value263 = None
		_g231 = haxe_ds_StringMap()
		_g231.h["saturn.client.programs.TextEditor"] = True
		value263 = _g231
		_g228.h["programs"] = value263
		value264 = None
		_g232 = haxe_ds_StringMap()
		_g232.h["alias"] = "File"
		value264 = _g232
		_g228.h["options"] = value264
		value260 = _g228
		_g.h["saturn.core.TextFile"] = value260
		value265 = None
		_g233 = haxe_ds_StringMap()
		value266 = None
		_g234 = haxe_ds_StringMap()
		_g234.h["saturn.client.programs.BasicTableViewer"] = True
		value266 = _g234
		_g233.h["programs"] = value266
		value267 = None
		_g235 = haxe_ds_StringMap()
		_g235.h["alias"] = "Results"
		value267 = _g235
		_g233.h["options"] = value267
		value265 = _g233
		_g.h["saturn.core.BasicTable"] = value265
		value268 = None
		_g236 = haxe_ds_StringMap()
		value269 = None
		_g237 = haxe_ds_StringMap()
		_g237.h["saturn.client.programs.ConstructDesigner"] = False
		value269 = _g237
		_g236.h["programs"] = value269
		value270 = None
		_g238 = haxe_ds_StringMap()
		_g238.h["alias"] = "Construct Design"
		value270 = _g238
		_g236.h["options"] = value270
		value268 = _g236
		_g.h["saturn.core.ConstructDesignTable"] = value268
		value271 = None
		_g239 = haxe_ds_StringMap()
		value272 = None
		_g240 = haxe_ds_StringMap()
		_g240.h["saturn.client.programs.PurificationHelper"] = False
		value272 = _g240
		_g239.h["programs"] = value272
		value273 = None
		_g241 = haxe_ds_StringMap()
		_g241.h["alias"] = "Purifiaction Helper"
		value273 = _g241
		_g239.h["options"] = value273
		value271 = _g239
		_g.h["saturn.core.PurificationHelperTable"] = value271
		value274 = None
		_g242 = haxe_ds_StringMap()
		value275 = None
		_g243 = haxe_ds_StringMap()
		_g243.h["saturn.client.programs.SHRNADesigner"] = False
		value275 = _g243
		_g242.h["programs"] = value275
		value276 = None
		_g244 = haxe_ds_StringMap()
		_g244.h["alias"] = "shRNA Designer"
		_g244.h["icon"] = "shrna_16.png"
		value276 = _g244
		_g242.h["options"] = value276
		value274 = _g242
		_g.h["saturn.core.SHRNADesignTable"] = value274
		value277 = None
		_g245 = haxe_ds_StringMap()
		value278 = None
		_g246 = haxe_ds_StringMap()
		_g246.h["saturn.client.programs.BasicTableViewer"] = False
		value278 = _g246
		_g245.h["programs"] = value278
		value279 = None
		_g247 = haxe_ds_StringMap()
		_g247.h["alias"] = "Table"
		value279 = _g247
		_g245.h["options"] = value279
		value277 = _g245
		_g.h["saturn.core.Table"] = value277
		value280 = None
		_g248 = haxe_ds_StringMap()
		value281 = None
		_g249 = haxe_ds_StringMap()
		_g249.h["id"] = "PKEY"
		_g249.h["compoundId"] = "COMPOUNDNAME"
		_g249.h["shortCompoundId"] = "COMPOUNDID"
		_g249.h["supplierId"] = "EXTERNALID"
		_g249.h["sdf"] = "MOLFILE"
		_g249.h["supplier"] = "SUPPLIER"
		_g249.h["description"] = "DESCRIPTION"
		_g249.h["comments"] = "COMMENTS"
		_g249.h["mw"] = "MOLECULARWEIGHT"
		_g249.h["smiles"] = "SMILES"
		_g249.h["datestamp"] = "DATESTAMP"
		_g249.h["person"] = "PERSON"
		value281 = _g249
		_g248.h["fields"] = value281
		value282 = None
		_g250 = haxe_ds_StringMap()
		_g250.h["compoundId"] = False
		_g250.h["id"] = True
		value282 = _g250
		_g248.h["indexes"] = value282
		value283 = None
		_g251 = haxe_ds_StringMap()
		_g251.h["compoundId"] = None
		_g251.h["shortCompoundId"] = None
		_g251.h["supplierId"] = None
		_g251.h["supplier"] = None
		value283 = _g251
		_g248.h["search"] = value283
		value284 = None
		_g252 = haxe_ds_StringMap()
		_g252.h["schema"] = "SGC"
		_g252.h["name"] = "SGCCOMPOUND"
		value284 = _g252
		_g248.h["table_info"] = value284
		value285 = None
		_g253 = haxe_ds_StringMap()
		_g253.h["id_pattern"] = "^\\w{5}\\d{4}"
		_g253.h["workspace_wrapper"] = "saturn.client.workspace.CompoundWO"
		_g253.h["icon"] = "compound_16.png"
		_g253.h["alias"] = "Compounds"
		value286 = None
		_g254 = haxe_ds_StringMap()
		value287 = None
		_g255 = haxe_ds_StringMap()
		value288 = None
		_g256 = haxe_ds_StringMap()
		_g256.h["user_suffix"] = "Assay Results"
		_g256.h["function"] = "saturn.core.domain.Compound.assaySearch"
		value288 = _g256
		_g255.h["assay_results"] = value288
		value287 = _g255
		_g254.h["search_bar"] = value287
		value286 = _g254
		value289 = value286
		_g253.h["actions"] = value289
		value285 = _g253
		_g248.h["options"] = value285
		value290 = None
		_g257 = haxe_ds_StringMap()
		_g257.h["Global ID"] = "compoundId"
		_g257.h["Oxford ID"] = "shortCompoundId"
		_g257.h["Supplier ID"] = "supplierId"
		_g257.h["Supplier"] = "supplier"
		_g257.h["Description"] = "description"
		_g257.h["Comments"] = "comments"
		_g257.h["MW"] = "mw"
		_g257.h["Date"] = "datestamp"
		_g257.h["Person"] = "person"
		_g257.h["smiles"] = "smiles"
		value290 = _g257
		_g248.h["model"] = value290
		value291 = None
		_g258 = haxe_ds_StringMap()
		_g258.h["saturn.client.programs.CompoundViewer"] = True
		value291 = _g258
		_g248.h["programs"] = value291
		value280 = _g248
		_g.h["saturn.core.domain.Compound"] = value280
		value292 = None
		_g259 = haxe_ds_StringMap()
		value293 = None
		_g260 = haxe_ds_StringMap()
		value294 = None
		_g261 = haxe_ds_StringMap()
		_g261.h["SGC"] = True
		value294 = _g261
		value295 = value294
		_g260.h["flags"] = value295
		value293 = _g260
		_g259.h["options"] = value293
		value292 = _g259
		_g.h["saturn.app.SaturnClient"] = value292
		value296 = None
		_g262 = haxe_ds_StringMap()
		value297 = None
		_g263 = haxe_ds_StringMap()
		_g263.h["id"] = "PKEY"
		_g263.h["username"] = "USERID"
		_g263.h["fullname"] = "FULLNAME"
		value297 = _g263
		_g262.h["fields"] = value297
		value298 = None
		_g264 = haxe_ds_StringMap()
		_g264.h["id"] = True
		_g264.h["username"] = False
		value298 = _g264
		_g262.h["indexes"] = value298
		value299 = None
		_g265 = haxe_ds_StringMap()
		_g265.h["schema"] = "HIVE"
		_g265.h["name"] = "USER_DETAILS"
		value299 = _g265
		_g262.h["table_info"] = value299
		value296 = _g262
		_g.h["saturn.core.User"] = value296
		value300 = None
		_g266 = haxe_ds_StringMap()
		value301 = None
		_g267 = haxe_ds_StringMap()
		_g267.h["id"] = "PKEY"
		_g267.h["name"] = "NAME"
		value301 = _g267
		_g266.h["fields"] = value301
		value302 = None
		_g268 = haxe_ds_StringMap()
		_g268.h["id"] = True
		_g268.h["name"] = False
		value302 = _g268
		_g266.h["index"] = value302
		value303 = None
		_g269 = haxe_ds_StringMap()
		_g269.h["schema"] = "SGC"
		_g269.h["name"] = "SATURNPERMISSION"
		value303 = _g269
		_g266.h["table_info"] = value303
		value300 = _g266
		_g.h["saturn.core.Permission"] = value300
		value304 = None
		_g270 = haxe_ds_StringMap()
		value305 = None
		_g271 = haxe_ds_StringMap()
		_g271.h["id"] = "PKEY"
		_g271.h["permissionId"] = "PERMISSIONID"
		_g271.h["userId"] = "USERID"
		value305 = _g271
		_g270.h["fields"] = value305
		value306 = None
		_g272 = haxe_ds_StringMap()
		_g272.h["id"] = True
		value306 = _g272
		_g270.h["index"] = value306
		value307 = None
		_g273 = haxe_ds_StringMap()
		_g273.h["schema"] = "SGC"
		_g273.h["name"] = "SATURNUSER_TO_PERMISSION"
		value307 = _g273
		_g270.h["table_info"] = value307
		value304 = _g270
		_g.h["saturn.core.UserToPermission"] = value304
		value308 = None
		_g274 = haxe_ds_StringMap()
		value309 = None
		_g275 = haxe_ds_StringMap()
		_g275.h["id"] = "PKEY"
		_g275.h["userName"] = "USERNAME"
		_g275.h["isPublic"] = "ISPUBLIC"
		_g275.h["sessionContent"] = "SESSIONCONTENTS"
		_g275.h["sessionName"] = "SESSIONNAME"
		value309 = _g275
		_g274.h["fields"] = value309
		value310 = None
		_g276 = haxe_ds_StringMap()
		_g276.h["sessionName"] = False
		_g276.h["id"] = True
		value310 = _g276
		_g274.h["indexes"] = value310
		value311 = None
		_g277 = haxe_ds_StringMap()
		_g277.h["user.fullname"] = None
		value311 = _g277
		_g274.h["search"] = value311
		value312 = None
		_g278 = haxe_ds_StringMap()
		_g278.h["schema"] = "SGC"
		_g278.h["name"] = "SATURNSESSION"
		value312 = _g278
		_g274.h["table_info"] = value312
		value313 = None
		_g279 = haxe_ds_StringMap()
		_g279.h["alias"] = "Session"
		_g279.h["auto_activate"] = "3"
		value314 = None
		_g280 = haxe_ds_StringMap()
		_g280.h["user_constraint_field"] = "userName"
		_g280.h["public_constraint_field"] = "isPublic"
		value314 = _g280
		value315 = value314
		_g279.h["constraints"] = value315
		value316 = None
		_g281 = haxe_ds_StringMap()
		value317 = None
		_g282 = haxe_ds_StringMap()
		value318 = None
		_g283 = haxe_ds_StringMap()
		_g283.h["user_suffix"] = ""
		_g283.h["function"] = "saturn.core.domain.SaturnSession.load"
		value318 = _g283
		_g282.h["DEFAULT"] = value318
		value317 = _g282
		_g281.h["search_bar"] = value317
		value316 = _g281
		value319 = value316
		_g279.h["actions"] = value319
		value313 = _g279
		_g274.h["options"] = value313
		value320 = None
		_g284 = haxe_ds_StringMap()
		_g284.h["USERNAME"] = "insert.username"
		value320 = _g284
		_g274.h["auto_functions"] = value320
		value321 = None
		_g285 = haxe_ds_StringMap()
		value322 = None
		_g286 = haxe_ds_StringMap()
		_g286.h["field"] = "userName"
		_g286.h["class"] = "saturn.core.User"
		_g286.h["fk_field"] = "username"
		value322 = _g286
		value323 = value322
		_g285.h["user"] = value323
		value321 = _g285
		_g274.h["fields.synthetic"] = value321
		value308 = _g274
		_g.h["saturn.core.domain.SaturnSession"] = value308
		self.models = _g

	@staticmethod
	def getNextAvailableId(clazz,value,db,cb):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.models = None
saturn_db_mapping_KISGC._hx_class = saturn_db_mapping_KISGC
_hx_classes["saturn.db.mapping.KISGC"] = saturn_db_mapping_KISGC


class saturn_db_mapping_OPPFMapping:
	_hx_class_name = "saturn.db.mapping.OPPFMapping"
	_hx_statics = ["models"]
saturn_db_mapping_OPPFMapping._hx_class = saturn_db_mapping_OPPFMapping
_hx_classes["saturn.db.mapping.OPPFMapping"] = saturn_db_mapping_OPPFMapping


class saturn_db_mapping_SGC:
	_hx_class_name = "saturn.db.mapping.SGC"
	_hx_fields = ["models"]
	_hx_methods = ["buildModels"]
	_hx_statics = ["getNextAvailableId"]

	def __init__(self):
		self.models = None
		self.buildModels()

	def buildModels(self):
		_g = haxe_ds_StringMap()
		value = None
		_g1 = haxe_ds_StringMap()
		value1 = None
		_g2 = haxe_ds_StringMap()
		_g2.h["constructId"] = "CONSTRUCT_ID"
		_g2.h["id"] = "PKEY"
		_g2.h["proteinSeq"] = "CONSTRUCTPROTSEQ"
		_g2.h["proteinSeqNoTag"] = "CONSTRUCTPROTSEQNOTAG"
		_g2.h["dnaSeq"] = "CONSTRUCTDNASEQ"
		_g2.h["docId"] = "ELNEXP"
		_g2.h["vectorId"] = "SGCVECTOR_PKEY"
		_g2.h["alleleId"] = "SGCALLELE_PKEY"
		_g2.h["res1Id"] = "SGCRESTRICTENZ1_PKEY"
		_g2.h["res2Id"] = "SGCRESTRICTENZ2_PKEY"
		_g2.h["constructPlateId"] = "SGCCONSTRUCTPLATE_PKEY"
		_g2.h["wellId"] = "WELLID"
		_g2.h["expectedMass"] = "EXPECTEDMASS"
		_g2.h["expectedMassNoTag"] = "EXPETCEDMASSNOTAG"
		_g2.h["status"] = "STATUS"
		_g2.h["location"] = "SGCLOCATION"
		_g2.h["elnId"] = "ELNEXP"
		_g2.h["constructComments"] = "CONSTRUCTCOMMENTS"
		_g2.h["person"] = "PERSON"
		_g2.h["constructStart"] = "CONSTRUCTSTART"
		_g2.h["constructStop"] = "CONSTRUCTSTOP"
		value1 = _g2
		_g1.h["fields"] = value1
		value2 = None
		_g3 = haxe_ds_StringMap()
		_g3.h["status"] = "In progress"
		value2 = _g3
		_g1.h["defaults"] = value2
		value3 = None
		_g4 = haxe_ds_StringMap()
		_g4.h["PERSON"] = "insert.username"
		value3 = _g4
		_g1.h["auto_functions"] = value3
		value4 = None
		_g5 = haxe_ds_StringMap()
		_g5.h["wellId"] = "1"
		_g5.h["constructPlateId"] = "1"
		_g5.h["constructId"] = "1"
		_g5.h["alleleId"] = "1"
		_g5.h["vectorId"] = "1"
		value4 = _g5
		_g1.h["required"] = value4
		value5 = None
		_g6 = haxe_ds_StringMap()
		_g6.h["constructId"] = False
		_g6.h["id"] = True
		value5 = _g6
		_g1.h["indexes"] = value5
		value6 = None
		_g7 = haxe_ds_StringMap()
		_g7.h["Construct ID"] = "constructId"
		_g7.h["Construct Plate"] = "constructPlate.plateName"
		_g7.h["Well ID"] = "wellId"
		_g7.h["Vector ID"] = "vector.vectorId"
		_g7.h["Allele ID"] = "allele.alleleId"
		_g7.h["Status"] = "status"
		_g7.h["Protein Sequence"] = "proteinSeq"
		_g7.h["Expected Mass"] = "expectedMass"
		_g7.h["Restriction Site 1"] = "res1.enzymeName"
		_g7.h["Restriction Site 2"] = "res2.enzymeName"
		_g7.h["Protein Sequence (No Tag)"] = "proteinSeqNoTag"
		_g7.h["Expected Mass (No Tag)"] = "expectedMassNoTag"
		_g7.h["Construct DNA Sequence"] = "dnaSeq"
		_g7.h["Location"] = "location"
		_g7.h["ELN ID"] = "elnId"
		_g7.h["Construct Comments"] = "constructComments"
		_g7.h["Creator"] = "person"
		_g7.h["Construct Start"] = "constructStart"
		_g7.h["Construct Stop"] = "constructStop"
		_g7.h["__HIDDEN__PKEY__"] = "id"
		value6 = _g7
		_g1.h["model"] = value6
		value7 = None
		_g8 = haxe_ds_StringMap()
		value8 = None
		_g9 = haxe_ds_StringMap()
		_g9.h["field"] = "alleleId"
		_g9.h["class"] = "saturn.core.domain.SgcAllele"
		_g9.h["fk_field"] = "id"
		value8 = _g9
		value9 = value8
		_g8.h["allele"] = value9
		value10 = None
		_g10 = haxe_ds_StringMap()
		_g10.h["field"] = "vectorId"
		_g10.h["class"] = "saturn.core.domain.SgcVector"
		_g10.h["fk_field"] = "id"
		value10 = _g10
		value11 = value10
		_g8.h["vector"] = value11
		value12 = None
		_g11 = haxe_ds_StringMap()
		_g11.h["field"] = "res1Id"
		_g11.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g11.h["fk_field"] = "id"
		value12 = _g11
		value13 = value12
		_g8.h["res1"] = value13
		value14 = None
		_g12 = haxe_ds_StringMap()
		_g12.h["field"] = "res2Id"
		_g12.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g12.h["fk_field"] = "id"
		value14 = _g12
		value15 = value14
		_g8.h["res2"] = value15
		value16 = None
		_g13 = haxe_ds_StringMap()
		_g13.h["field"] = "constructPlateId"
		_g13.h["class"] = "saturn.core.domain.SgcConstructPlate"
		_g13.h["fk_field"] = "id"
		value16 = _g13
		value17 = value16
		_g8.h["constructPlate"] = value17
		value7 = _g8
		_g1.h["fields.synthetic"] = value7
		value18 = None
		_g14 = haxe_ds_StringMap()
		_g14.h["schema"] = "SGC"
		_g14.h["name"] = "CONSTRUCT"
		value18 = _g14
		_g1.h["table_info"] = value18
		value19 = None
		_g15 = haxe_ds_StringMap()
		_g15.h["saturn.client.programs.DNASequenceEditor"] = True
		value19 = _g15
		_g1.h["programs"] = value19
		value20 = None
		_g16 = haxe_ds_StringMap()
		_g16.h["constructId"] = True
		value20 = _g16
		_g1.h["search"] = value20
		value21 = None
		_g17 = haxe_ds_StringMap()
		_g17.h["alias"] = "Construct"
		_g17.h["icon"] = "dna_conical_16.png"
		_g17.h["auto_activate"] = "3"
		value21 = _g17
		_g1.h["options"] = value21
		value = _g1
		_g.h["saturn.core.domain.SgcConstruct"] = value
		value22 = None
		_g18 = haxe_ds_StringMap()
		value23 = None
		_g19 = haxe_ds_StringMap()
		_g19.h["constructPkey"] = "SGCCONSTRUCT_PKEY"
		_g19.h["status"] = "STATUS"
		value23 = _g19
		_g18.h["fields"] = value23
		value24 = None
		_g20 = haxe_ds_StringMap()
		_g20.h["schema"] = "SGC"
		_g20.h["name"] = "CONSTR_STATUS_SNAPSHOT"
		value24 = _g20
		_g18.h["table_info"] = value24
		value25 = None
		_g21 = haxe_ds_StringMap()
		_g21.h["constructPkey"] = True
		value25 = _g21
		_g18.h["indexes"] = value25
		value22 = _g18
		_g.h["saturn.core.domain.SgcConstructStatus"] = value22
		value26 = None
		_g22 = haxe_ds_StringMap()
		value27 = None
		_g23 = haxe_ds_StringMap()
		_g23.h["alleleId"] = "ALLELE_ID"
		_g23.h["allelePlateId"] = "SGCPLATE_PKEY"
		_g23.h["id"] = "PKEY"
		_g23.h["entryCloneId"] = "SGCENTRYCLONE_PKEY"
		_g23.h["forwardPrimerId"] = "SGCPRIMER5_PKEY"
		_g23.h["reversePrimerId"] = "SGCPRIMER3_PKEY"
		_g23.h["dnaSeq"] = "ALLELESEQUENCERAW"
		_g23.h["proteinSeq"] = "ALLELEPROTSEQ"
		_g23.h["status"] = "ALLELE_STATUS"
		_g23.h["location"] = "SGCLOCATION"
		_g23.h["comments"] = "ALLELECOMMENTS"
		_g23.h["elnId"] = "ELNEXP"
		_g23.h["dateStamp"] = "DATESTAMP"
		_g23.h["person"] = "PERSON"
		_g23.h["plateWell"] = "PLATEWELL"
		_g23.h["dnaSeqLen"] = "ALLELESEQLENGTH"
		_g23.h["complex"] = "COMPLEX"
		_g23.h["domainSummary"] = "DOMAINSUMMARY"
		_g23.h["domainStartDelta"] = "DOMAINSTARTDELTA"
		_g23.h["domainStopDelta"] = "DOMAINSTOPDELTA"
		_g23.h["containsPharmaDomain"] = "CONTAINSPHARMADOMAIN"
		_g23.h["domainSummaryLong"] = "DOMAINSUMMARYLONG"
		_g23.h["impPI"] = "IMPPI"
		_g23.h["alleleStatus"] = "ALLELE_STATUS"
		value27 = _g23
		_g22.h["fields"] = value27
		value28 = None
		_g24 = haxe_ds_StringMap()
		_g24.h["status"] = "In process"
		value28 = _g24
		_g22.h["defaults"] = value28
		value29 = None
		_g25 = haxe_ds_StringMap()
		_g25.h["Allele ID"] = "alleleId"
		_g25.h["Plate"] = "plate.plateName"
		_g25.h["Entry Clone ID"] = "entryClone.entryCloneId"
		_g25.h["Forward Primer ID"] = "forwardPrimer.primerId"
		_g25.h["Reverse Primer ID"] = "reversePrimer.primerId"
		_g25.h["DNA Sequence"] = "dnaSeq"
		_g25.h["Protein Sequence"] = "proteinSeq"
		_g25.h["Status"] = "status"
		_g25.h["Location"] = "location"
		_g25.h["Comments"] = "comments"
		_g25.h["ELN ID"] = "elnId"
		_g25.h["Date Record"] = "dateStamp"
		_g25.h["Person"] = "person"
		_g25.h["Plate Well"] = "plateWell"
		_g25.h["DNA Length"] = "dnaSeqLen"
		_g25.h["Complex"] = "complex"
		_g25.h["Domain Summary"] = "domainSummary"
		_g25.h["Domain  Start Delta"] = "domainStartDelta"
		_g25.h["Domain Stop Delta"] = "domainStopDelta"
		_g25.h["Contains Pharma Domain"] = "containsPharmaDomain"
		_g25.h["Domain Summary Long"] = "domainSummaryLong"
		_g25.h["IMP PI"] = "impPI"
		_g25.h["__HIDDEN__PKEY__"] = "id"
		value29 = _g25
		_g22.h["model"] = value29
		value30 = None
		_g26 = haxe_ds_StringMap()
		_g26.h["alleleId"] = False
		_g26.h["id"] = True
		value30 = _g26
		_g22.h["indexes"] = value30
		value31 = None
		_g27 = haxe_ds_StringMap()
		value32 = None
		_g28 = haxe_ds_StringMap()
		_g28.h["field"] = "entryCloneId"
		_g28.h["class"] = "saturn.core.domain.SgcEntryClone"
		_g28.h["fk_field"] = "id"
		value32 = _g28
		value33 = value32
		_g27.h["entryClone"] = value33
		value34 = None
		_g29 = haxe_ds_StringMap()
		_g29.h["field"] = "forwardPrimerId"
		_g29.h["class"] = "saturn.core.domain.SgcForwardPrimer"
		_g29.h["fk_field"] = "id"
		value34 = _g29
		value35 = value34
		_g27.h["forwardPrimer"] = value35
		value36 = None
		_g30 = haxe_ds_StringMap()
		_g30.h["field"] = "reversePrimerId"
		_g30.h["class"] = "saturn.core.domain.SgcReversePrimer"
		_g30.h["fk_field"] = "id"
		value36 = _g30
		value37 = value36
		_g27.h["reversePrimer"] = value37
		value38 = None
		_g31 = haxe_ds_StringMap()
		_g31.h["field"] = "allelePlateId"
		_g31.h["class"] = "saturn.core.domain.SgcAllelePlate"
		_g31.h["fk_field"] = "id"
		value38 = _g31
		value39 = value38
		_g27.h["plate"] = value39
		value31 = _g27
		_g22.h["fields.synthetic"] = value31
		value40 = None
		_g32 = haxe_ds_StringMap()
		_g32.h["schema"] = "SGC"
		_g32.h["name"] = "ALLELE"
		value40 = _g32
		_g22.h["table_info"] = value40
		value41 = None
		_g33 = haxe_ds_StringMap()
		_g33.h["saturn.client.programs.DNASequenceEditor"] = True
		value41 = _g33
		_g22.h["programs"] = value41
		value42 = None
		_g34 = haxe_ds_StringMap()
		_g34.h["alleleId"] = True
		value42 = _g34
		_g22.h["search"] = value42
		value43 = None
		_g35 = haxe_ds_StringMap()
		_g35.h["alias"] = "Allele"
		_g35.h["icon"] = "dna_conical_16.png"
		value43 = _g35
		_g22.h["options"] = value43
		value26 = _g22
		_g.h["saturn.core.domain.SgcAllele"] = value26
		value44 = None
		_g36 = haxe_ds_StringMap()
		value45 = None
		_g37 = haxe_ds_StringMap()
		_g37.h["entryCloneId"] = "ENTRY_CLONE_ID"
		_g37.h["id"] = "PKEY"
		_g37.h["dnaSeq"] = "DNARAWSEQUENCE"
		_g37.h["targetId"] = "SGCTARGET_PKEY"
		_g37.h["seqSource"] = "SEQSOURCE"
		_g37.h["sourceId"] = "SOURCEID"
		_g37.h["sequenceConfirmed"] = "SEQUENCECONFIRMED"
		_g37.h["elnId"] = "ELNEXPERIMENTID"
		value45 = _g37
		_g36.h["fields"] = value45
		value46 = None
		_g38 = haxe_ds_StringMap()
		_g38.h["entryCloneId"] = False
		_g38.h["id"] = True
		value46 = _g38
		_g36.h["indexes"] = value46
		value47 = None
		_g39 = haxe_ds_StringMap()
		_g39.h["saturn.client.programs.DNASequenceEditor"] = True
		value47 = _g39
		_g36.h["programs"] = value47
		value48 = None
		_g40 = haxe_ds_StringMap()
		_g40.h["entryCloneId"] = True
		value48 = _g40
		_g36.h["search"] = value48
		value49 = None
		_g41 = haxe_ds_StringMap()
		value50 = None
		_g42 = haxe_ds_StringMap()
		_g42.h["saturn.client.programs.DNASequenceEditor"] = True
		_g42.h["saturn.client.programs.ProteinSequenceEditor"] = True
		value50 = _g42
		value51 = value50
		_g41.h["canSave"] = value51
		_g41.h["alias"] = "Entry Clone"
		_g41.h["icon"] = "dna_conical_16.png"
		value52 = None
		_g43 = haxe_ds_StringMap()
		value53 = None
		_g44 = haxe_ds_StringMap()
		value54 = None
		_g45 = haxe_ds_StringMap()
		_g45.h["user_suffix"] = "Translation"
		_g45.h["function"] = "saturn.core.domain.SgcEntryClone.loadTranslation"
		_g45.h["icon"] = "structure_16.png"
		value54 = _g45
		_g44.h["translation"] = value54
		value53 = _g44
		_g43.h["search_bar"] = value53
		value52 = _g43
		value55 = value52
		_g41.h["actions"] = value55
		value49 = _g41
		_g36.h["options"] = value49
		value56 = None
		_g46 = haxe_ds_StringMap()
		_g46.h["schema"] = "SGC"
		_g46.h["name"] = "ENTRY_CLONE"
		value56 = _g46
		_g36.h["table_info"] = value56
		value57 = None
		_g47 = haxe_ds_StringMap()
		_g47.h["Entry Clone ID"] = "entryCloneId"
		value57 = _g47
		_g36.h["model"] = value57
		value58 = None
		_g48 = haxe_ds_StringMap()
		value59 = None
		_g49 = haxe_ds_StringMap()
		_g49.h["field"] = "targetId"
		_g49.h["class"] = "saturn.core.domain.SgcTarget"
		_g49.h["fk_field"] = "id"
		value59 = _g49
		value60 = value59
		_g48.h["target"] = value60
		value58 = _g48
		_g36.h["fields.synthetic"] = value58
		value44 = _g36
		_g.h["saturn.core.domain.SgcEntryClone"] = value44
		value61 = None
		_g50 = haxe_ds_StringMap()
		value62 = None
		_g51 = haxe_ds_StringMap()
		_g51.h["enzymeName"] = "RESTRICTION_ENZYME_NAME"
		_g51.h["cutSequence"] = "RESTRICTION_ENZYME_SEQUENCERAW"
		_g51.h["id"] = "PKEY"
		value62 = _g51
		_g50.h["fields"] = value62
		value63 = None
		_g52 = haxe_ds_StringMap()
		_g52.h["enzymeName"] = False
		_g52.h["id"] = True
		value63 = _g52
		_g50.h["indexes"] = value63
		value64 = None
		_g53 = haxe_ds_StringMap()
		_g53.h["schema"] = "SGC"
		_g53.h["name"] = "RESTRICTION_ENZYME"
		value64 = _g53
		_g50.h["table_info"] = value64
		value65 = None
		_g54 = haxe_ds_StringMap()
		_g54.h["saturn.client.programs.DNASequenceEditor"] = True
		value65 = _g54
		_g50.h["programs"] = value65
		value66 = None
		_g55 = haxe_ds_StringMap()
		_g55.h["Enzyme Name"] = "enzymeName"
		value66 = _g55
		_g50.h["model"] = value66
		value67 = None
		_g56 = haxe_ds_StringMap()
		_g56.h["alias"] = "Restriction site"
		value67 = _g56
		_g50.h["options"] = value67
		value68 = None
		_g57 = haxe_ds_StringMap()
		_g57.h["enzymeName"] = None
		value68 = _g57
		_g50.h["search"] = value68
		value61 = _g50
		_g.h["saturn.core.domain.SgcRestrictionSite"] = value61
		value69 = None
		_g58 = haxe_ds_StringMap()
		value70 = None
		_g59 = haxe_ds_StringMap()
		_g59.h["vectorId"] = "VECTOR_NAME"
		_g59.h["id"] = "PKEY"
		_g59.h["sequence"] = "VECTORSEQUENCERAW"
		_g59.h["vectorComments"] = "VECTORCOMMENTS"
		_g59.h["proteaseName"] = "PROTEASE_NAME"
		_g59.h["proteaseCutSequence"] = "PROTEASE_CUTSEQUENCE"
		_g59.h["proteaseProduct"] = "PROTEASE_PRODUCT"
		_g59.h["antibiotic"] = "ANTIBIOTIC"
		_g59.h["organism"] = "ORGANISM"
		_g59.h["res1Id"] = "SGCRESTRICTENZ1_PKEY"
		_g59.h["res2Id"] = "SGCRESTRICTENZ2_PKEY"
		_g59.h["addStopCodon"] = "REQUIRES_STOP_CODON"
		_g59.h["requiredForwardExtension"] = "REQUIRED_EXTENSION_FORWARD"
		_g59.h["requiredReverseExtension"] = "REQUIRED_EXTENSION_REVERSE"
		value70 = _g59
		_g58.h["fields"] = value70
		value71 = None
		_g60 = haxe_ds_StringMap()
		_g60.h["vectorId"] = None
		value71 = _g60
		_g58.h["search"] = value71
		value72 = None
		_g61 = haxe_ds_StringMap()
		_g61.h["saturn.client.programs.DNASequenceEditor"] = True
		value72 = _g61
		_g58.h["programs"] = value72
		value73 = None
		_g62 = haxe_ds_StringMap()
		_g62.h["vectorId"] = False
		_g62.h["id"] = True
		value73 = _g62
		_g58.h["indexes"] = value73
		value74 = None
		_g63 = haxe_ds_StringMap()
		value75 = None
		_g64 = haxe_ds_StringMap()
		_g64.h["field"] = "res1Id"
		_g64.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g64.h["fk_field"] = "id"
		value75 = _g64
		value76 = value75
		_g63.h["res1"] = value76
		value77 = None
		_g65 = haxe_ds_StringMap()
		_g65.h["field"] = "res2Id"
		_g65.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g65.h["fk_field"] = "id"
		value77 = _g65
		value78 = value77
		_g63.h["res2"] = value78
		value74 = _g63
		_g58.h["fields.synthetic"] = value74
		value79 = None
		_g66 = haxe_ds_StringMap()
		_g66.h["schema"] = "SGC"
		_g66.h["name"] = "VECTOR"
		value79 = _g66
		_g58.h["table_info"] = value79
		value80 = None
		_g67 = haxe_ds_StringMap()
		_g67.h["auto_activate"] = "3"
		_g67.h["alias"] = "Vector"
		value80 = _g67
		_g58.h["options"] = value80
		value81 = None
		_g68 = haxe_ds_StringMap()
		_g68.h["Name"] = "vectorId"
		_g68.h["Comments"] = "vectorComments"
		_g68.h["Protease"] = "proteaseName"
		_g68.h["Protease cut sequence"] = "proteaseCutSequence"
		_g68.h["Protease product"] = "proteaseProduct"
		_g68.h["Forward extension"] = "requiredForwardExtension"
		_g68.h["Reverse extension"] = "requiredReverseExtension"
		_g68.h["Restriction site 1"] = "res1.enzymeName"
		_g68.h["Restriction site 2"] = "res2.enzymeName"
		value81 = _g68
		_g58.h["model"] = value81
		value69 = _g58
		_g.h["saturn.core.domain.SgcVector"] = value69
		value82 = None
		_g69 = haxe_ds_StringMap()
		value83 = None
		_g70 = haxe_ds_StringMap()
		_g70.h["primerId"] = "PRIMERNAME"
		_g70.h["id"] = "PKEY"
		_g70.h["dnaSequence"] = "PRIMERRAWSEQUENCE"
		value83 = _g70
		_g69.h["fields"] = value83
		value84 = None
		_g71 = haxe_ds_StringMap()
		_g71.h["primerId"] = False
		_g71.h["id"] = True
		value84 = _g71
		_g69.h["indexes"] = value84
		value85 = None
		_g72 = haxe_ds_StringMap()
		_g72.h["schema"] = "SGC"
		_g72.h["name"] = "PRIMER"
		value85 = _g72
		_g69.h["table_info"] = value85
		value86 = None
		_g73 = haxe_ds_StringMap()
		_g73.h["saturn.client.programs.DNASequenceEditor"] = True
		value86 = _g73
		_g69.h["programs"] = value86
		value87 = None
		_g74 = haxe_ds_StringMap()
		_g74.h["primerId"] = True
		value87 = _g74
		_g69.h["search"] = value87
		value88 = None
		_g75 = haxe_ds_StringMap()
		_g75.h["alias"] = "Forward Primer"
		_g75.h["icon"] = "dna_conical_16.png"
		value88 = _g75
		_g69.h["options"] = value88
		value89 = None
		_g76 = haxe_ds_StringMap()
		_g76.h["Primer ID"] = "primerId"
		value89 = _g76
		_g69.h["model"] = value89
		value82 = _g69
		_g.h["saturn.core.domain.SgcForwardPrimer"] = value82
		value90 = None
		_g77 = haxe_ds_StringMap()
		value91 = None
		_g78 = haxe_ds_StringMap()
		_g78.h["primerId"] = "PRIMERNAME"
		_g78.h["id"] = "PKEY"
		_g78.h["dnaSequence"] = "PRIMERRAWSEQUENCE"
		value91 = _g78
		_g77.h["fields"] = value91
		value92 = None
		_g79 = haxe_ds_StringMap()
		_g79.h["primerId"] = False
		_g79.h["id"] = True
		value92 = _g79
		_g77.h["indexes"] = value92
		value93 = None
		_g80 = haxe_ds_StringMap()
		_g80.h["schema"] = "SGC"
		_g80.h["name"] = "PRIMERREV"
		value93 = _g80
		_g77.h["table_info"] = value93
		value94 = None
		_g81 = haxe_ds_StringMap()
		_g81.h["saturn.client.programs.DNASequenceEditor"] = True
		value94 = _g81
		_g77.h["programs"] = value94
		value95 = None
		_g82 = haxe_ds_StringMap()
		_g82.h["primerId"] = True
		value95 = _g82
		_g77.h["search"] = value95
		value96 = None
		_g83 = haxe_ds_StringMap()
		_g83.h["alias"] = "Reverse Primer"
		_g83.h["icon"] = "dna_conical_16.png"
		value96 = _g83
		_g77.h["options"] = value96
		value97 = None
		_g84 = haxe_ds_StringMap()
		_g84.h["Primer ID"] = "primerId"
		value97 = _g84
		_g77.h["model"] = value97
		value90 = _g77
		_g.h["saturn.core.domain.SgcReversePrimer"] = value90
		value98 = None
		_g85 = haxe_ds_StringMap()
		value99 = None
		_g86 = haxe_ds_StringMap()
		_g86.h["purificationId"] = "PURIFICATIONID"
		_g86.h["id"] = "PKEY"
		_g86.h["expressionId"] = "EXPRESSION_PKEY"
		_g86.h["column"] = "COLUMN1"
		_g86.h["elnId"] = "ELNEXP"
		_g86.h["comments"] = "COMMENTS"
		value99 = _g86
		_g85.h["fields"] = value99
		value100 = None
		_g87 = haxe_ds_StringMap()
		_g87.h["purificationId"] = False
		_g87.h["id"] = True
		value100 = _g87
		_g85.h["indexes"] = value100
		value101 = None
		_g88 = haxe_ds_StringMap()
		_g88.h["schema"] = "SGC"
		_g88.h["name"] = "PURIFICATION"
		value101 = _g88
		_g85.h["table_info"] = value101
		value102 = None
		_g89 = haxe_ds_StringMap()
		_g89.h["saturn.client.programs.DNASequenceEditor"] = True
		value102 = _g89
		_g85.h["programs"] = value102
		value103 = None
		_g90 = haxe_ds_StringMap()
		value104 = None
		_g91 = haxe_ds_StringMap()
		_g91.h["field"] = "expressionId"
		_g91.h["class"] = "saturn.core.domain.SgcExpression"
		_g91.h["fk_field"] = "id"
		value104 = _g91
		value105 = value104
		_g90.h["expression"] = value105
		value103 = _g90
		_g85.h["fields.synthetic"] = value103
		value106 = None
		_g92 = haxe_ds_StringMap()
		_g92.h["Purification ID"] = "purificationId"
		value106 = _g92
		_g85.h["model"] = value106
		value98 = _g85
		_g.h["saturn.core.domain.SgcPurification"] = value98
		value107 = None
		_g93 = haxe_ds_StringMap()
		value108 = None
		_g94 = haxe_ds_StringMap()
		_g94.h["cloneId"] = "CLONE_ID"
		_g94.h["id"] = "PKEY"
		_g94.h["constructId"] = "SGCCONSTRUCT1_PKEY"
		_g94.h["elnId"] = "ELNEXP"
		_g94.h["comments"] = "COMMENTS"
		value108 = _g94
		_g93.h["fields"] = value108
		value109 = None
		_g95 = haxe_ds_StringMap()
		_g95.h["cloneId"] = False
		_g95.h["id"] = True
		value109 = _g95
		_g93.h["indexes"] = value109
		value110 = None
		_g96 = haxe_ds_StringMap()
		_g96.h["schema"] = "SGC"
		_g96.h["name"] = "CLONE"
		value110 = _g96
		_g93.h["table_info"] = value110
		value111 = None
		_g97 = haxe_ds_StringMap()
		_g97.h["saturn.client.programs.DNASequenceEditor"] = True
		value111 = _g97
		_g93.h["programs"] = value111
		value112 = None
		_g98 = haxe_ds_StringMap()
		value113 = None
		_g99 = haxe_ds_StringMap()
		_g99.h["field"] = "constructId"
		_g99.h["class"] = "saturn.core.domain.SgcConstruct"
		_g99.h["fk_field"] = "id"
		value113 = _g99
		value114 = value113
		_g98.h["construct"] = value114
		value112 = _g98
		_g93.h["fields.synthetic"] = value112
		value115 = None
		_g100 = haxe_ds_StringMap()
		_g100.h["Clone ID"] = "cloneId"
		value115 = _g100
		_g93.h["model"] = value115
		value107 = _g93
		_g.h["saturn.core.domain.SgcClone"] = value107
		value116 = None
		_g101 = haxe_ds_StringMap()
		value117 = None
		_g102 = haxe_ds_StringMap()
		_g102.h["expressionId"] = "EXPRESSION_ID"
		_g102.h["id"] = "PKEY"
		_g102.h["cloneId"] = "SGCCLONE_PKEY"
		_g102.h["elnId"] = "ELNEXP"
		_g102.h["comments"] = "COMMENTS"
		value117 = _g102
		_g101.h["fields"] = value117
		value118 = None
		_g103 = haxe_ds_StringMap()
		_g103.h["expressionId"] = False
		_g103.h["id"] = True
		value118 = _g103
		_g101.h["indexes"] = value118
		value119 = None
		_g104 = haxe_ds_StringMap()
		_g104.h["schema"] = "SGC"
		_g104.h["name"] = "EXPRESSION"
		value119 = _g104
		_g101.h["table_info"] = value119
		value120 = None
		_g105 = haxe_ds_StringMap()
		_g105.h["saturn.client.programs.DNASequenceEditor"] = True
		value120 = _g105
		_g101.h["programs"] = value120
		value121 = None
		_g106 = haxe_ds_StringMap()
		value122 = None
		_g107 = haxe_ds_StringMap()
		_g107.h["field"] = "cloneId"
		_g107.h["class"] = "saturn.core.domain.SgcClone"
		_g107.h["fk_field"] = "id"
		value122 = _g107
		value123 = value122
		_g106.h["clone"] = value123
		value121 = _g106
		_g101.h["fields.synthetic"] = value121
		value124 = None
		_g108 = haxe_ds_StringMap()
		_g108.h["Expression ID"] = "expressionId"
		value124 = _g108
		_g101.h["model"] = value124
		value116 = _g101
		_g.h["saturn.core.domain.SgcExpression"] = value116
		value125 = None
		_g109 = haxe_ds_StringMap()
		value126 = None
		_g110 = haxe_ds_StringMap()
		_g110.h["targetId"] = "TARGET_ID"
		_g110.h["id"] = "PKEY"
		_g110.h["gi"] = "GENBANK_ID"
		_g110.h["geneId"] = "NCBIGENEID"
		_g110.h["proteinSeq"] = "PROTEINSEQUENCE"
		_g110.h["dnaSeq"] = "NUCLEOTIDESEQUENCE"
		_g110.h["activeStatus"] = "ACTIVESTATUS"
		_g110.h["pi"] = "PI"
		_g110.h["comments"] = "COMMENTS"
		value126 = _g110
		_g109.h["fields"] = value126
		value127 = None
		_g111 = haxe_ds_StringMap()
		_g111.h["targetId"] = False
		_g111.h["id"] = True
		value127 = _g111
		_g109.h["indexes"] = value127
		value128 = None
		_g112 = haxe_ds_StringMap()
		_g112.h["schema"] = "SGC"
		_g112.h["name"] = "TARGET"
		_g112.h["human_name"] = "Target"
		_g112.h["human_name_plural"] = "Targets"
		value128 = _g112
		_g109.h["table_info"] = value128
		value129 = None
		_g113 = haxe_ds_StringMap()
		_g113.h["Target ID"] = "targetId"
		_g113.h["Genbank ID"] = "gi"
		_g113.h["DNA Sequence"] = "dnaSequence.sequence"
		_g113.h["__HIDDEN__PKEY__"] = "id"
		value129 = _g113
		_g109.h["model"] = value129
		value130 = None
		_g114 = haxe_ds_StringMap()
		value131 = None
		_g115 = haxe_ds_StringMap()
		_g115.h["field"] = "id"
		_g115.h["class"] = "saturn.core.domain.SgcTargetDNA"
		_g115.h["fk_field"] = "targetId"
		value131 = _g115
		value132 = value131
		_g114.h["dnaSequence"] = value132
		value130 = _g114
		_g109.h["fields.synthetic"] = value130
		value133 = None
		_g116 = haxe_ds_StringMap()
		_g116.h["id_pattern"] = ".*"
		_g116.h["alias"] = "Targets"
		_g116.h["icon"] = "protein_16.png"
		value134 = None
		_g117 = haxe_ds_StringMap()
		value135 = None
		_g118 = haxe_ds_StringMap()
		value136 = None
		_g119 = haxe_ds_StringMap()
		_g119.h["user_suffix"] = "Wonka"
		_g119.h["function"] = "saturn.core.domain.SgcTarget.loadWonka"
		value136 = _g119
		_g118.h["wonka"] = value136
		value135 = _g118
		_g117.h["search_bar"] = value135
		value134 = _g117
		value137 = value134
		_g116.h["actions"] = value137
		value133 = _g116
		_g109.h["options"] = value133
		value125 = _g109
		_g.h["saturn.core.domain.SgcTarget"] = value125
		value138 = None
		_g120 = haxe_ds_StringMap()
		value139 = None
		_g121 = haxe_ds_StringMap()
		_g121.h["sequence"] = "SEQ"
		_g121.h["id"] = "PKEY"
		_g121.h["type"] = "SEQTYPE"
		_g121.h["version"] = "TARGETVERSION"
		_g121.h["targetId"] = "SGCTARGET_PKEY"
		_g121.h["crc"] = "CRC"
		_g121.h["target"] = "TARGET_ID"
		value139 = _g121
		_g120.h["fields"] = value139
		value140 = None
		_g122 = haxe_ds_StringMap()
		_g122.h["id"] = True
		value140 = _g122
		_g120.h["indexes"] = value140
		value141 = None
		_g123 = haxe_ds_StringMap()
		_g123.h["schema"] = ""
		_g123.h["name"] = "SEQDATA"
		value141 = _g123
		_g120.h["table_info"] = value141
		value142 = None
		_g124 = haxe_ds_StringMap()
		_g124.h["field"] = "type"
		_g124.h["value"] = "Nucleotide"
		value142 = _g124
		_g120.h["selector"] = value142
		value138 = _g120
		_g.h["saturn.core.domain.SgcTargetDNA"] = value138
		value143 = None
		_g125 = haxe_ds_StringMap()
		value144 = None
		_g126 = haxe_ds_StringMap()
		_g126.h["sequence"] = "SEQ"
		_g126.h["id"] = "PKEY"
		_g126.h["type"] = "SEQTYPE"
		_g126.h["version"] = "TARGETVERSION"
		_g126.h["targetId"] = "SGCTARGET_PKEY"
		_g126.h["crc"] = "CRC"
		_g126.h["target"] = "TARGET_ID"
		value144 = _g126
		_g125.h["fields"] = value144
		value145 = None
		_g127 = haxe_ds_StringMap()
		_g127.h["id"] = True
		value145 = _g127
		_g125.h["indexes"] = value145
		value146 = None
		_g128 = haxe_ds_StringMap()
		_g128.h["schema"] = ""
		_g128.h["name"] = "SEQDATA"
		value146 = _g128
		_g125.h["table_info"] = value146
		value143 = _g125
		_g.h["saturn.core.domain.SgcSeqData"] = value143
		value147 = None
		_g129 = haxe_ds_StringMap()
		value148 = None
		_g130 = haxe_ds_StringMap()
		_g130.h["id"] = "PKEY"
		_g130.h["accession"] = "IDENTIFIER"
		_g130.h["start"] = "SEQSTART"
		_g130.h["stop"] = "SEQSTOP"
		_g130.h["targetId"] = "SGCTARGET_PKEY"
		value148 = _g130
		_g129.h["fields"] = value148
		value149 = None
		_g131 = haxe_ds_StringMap()
		_g131.h["accession"] = False
		_g131.h["id"] = True
		value149 = _g131
		_g129.h["indexes"] = value149
		value147 = _g129
		_g.h["saturn.core.domain.SgcDomain"] = value147
		value150 = None
		_g132 = haxe_ds_StringMap()
		value151 = None
		_g133 = haxe_ds_StringMap()
		_g133.h["id"] = "PKEY"
		_g133.h["plateName"] = "PLATENAME"
		_g133.h["elnRef"] = "ELNREF"
		value151 = _g133
		_g132.h["fields"] = value151
		value152 = None
		_g134 = haxe_ds_StringMap()
		_g134.h["plateName"] = False
		_g134.h["id"] = True
		value152 = _g134
		_g132.h["indexes"] = value152
		value153 = None
		_g135 = haxe_ds_StringMap()
		_g135.h["schema"] = "SGC"
		_g135.h["name"] = "CONSTRUCTPLATE"
		value153 = _g135
		_g132.h["table_info"] = value153
		value154 = None
		_g136 = haxe_ds_StringMap()
		_g136.h["workspace_wrapper"] = "saturn.client.workspace.MultiConstructHelperWO"
		_g136.h["icon"] = "dna_conical_16.png"
		_g136.h["alias"] = "Construct Plate"
		value154 = _g136
		_g132.h["options"] = value154
		value155 = None
		_g137 = haxe_ds_StringMap()
		_g137.h["plateName"] = True
		value155 = _g137
		_g132.h["fts"] = value155
		value150 = _g132
		_g.h["saturn.core.domain.SgcConstructPlate"] = value150
		value156 = None
		_g138 = haxe_ds_StringMap()
		value157 = None
		_g139 = haxe_ds_StringMap()
		_g139.h["id"] = "PKEY"
		_g139.h["plateName"] = "PLATENAME"
		_g139.h["elnRef"] = "ELNREF"
		value157 = _g139
		_g138.h["fields"] = value157
		value158 = None
		_g140 = haxe_ds_StringMap()
		_g140.h["plateName"] = False
		_g140.h["id"] = True
		value158 = _g140
		_g138.h["indexes"] = value158
		value159 = None
		_g141 = haxe_ds_StringMap()
		_g141.h["schema"] = "SGC"
		_g141.h["name"] = "PLATE"
		value159 = _g141
		_g138.h["table_info"] = value159
		value160 = None
		_g142 = haxe_ds_StringMap()
		_g142.h["workspace_wrapper"] = "saturn.client.workspace.MultiAlleleHelperWO"
		_g142.h["icon"] = "dna_conical_16.png"
		_g142.h["alias"] = "Allele Plate"
		value160 = _g142
		_g138.h["options"] = value160
		value161 = None
		_g143 = haxe_ds_StringMap()
		_g143.h["plateName"] = True
		value161 = _g143
		_g138.h["fts"] = value161
		value156 = _g138
		_g.h["saturn.core.domain.SgcAllelePlate"] = value156
		value162 = None
		_g144 = haxe_ds_StringMap()
		value163 = None
		_g145 = haxe_ds_StringMap()
		_g145.h["dnaId"] = "DNA_ID"
		_g145.h["id"] = "PKEY"
		_g145.h["dnaSeq"] = "DNASEQUENCE"
		value163 = _g145
		_g144.h["fields"] = value163
		value164 = None
		_g146 = haxe_ds_StringMap()
		_g146.h["dnaId"] = False
		_g146.h["id"] = True
		value164 = _g146
		_g144.h["indexes"] = value164
		value165 = None
		_g147 = haxe_ds_StringMap()
		_g147.h["schema"] = "SGC"
		_g147.h["name"] = "DNA"
		value165 = _g147
		_g144.h["table_info"] = value165
		value162 = _g144
		_g.h["saturn.core.domain.SgcDNA"] = value162
		value166 = None
		_g148 = haxe_ds_StringMap()
		value167 = None
		_g149 = haxe_ds_StringMap()
		_g149.h["pageId"] = "PAGEID"
		_g149.h["id"] = "PKEY"
		_g149.h["content"] = "CONTENT"
		value167 = _g149
		_g148.h["fields"] = value167
		value168 = None
		_g150 = haxe_ds_StringMap()
		_g150.h["pageId"] = False
		_g150.h["id"] = True
		value168 = _g150
		_g148.h["indexes"] = value168
		value169 = None
		_g151 = haxe_ds_StringMap()
		_g151.h["schema"] = "SGC"
		_g151.h["name"] = "TIDDLY_WIKI"
		value169 = _g151
		_g148.h["table_info"] = value169
		value166 = _g148
		_g.h["saturn.core.domain.TiddlyWiki"] = value166
		value170 = None
		_g152 = haxe_ds_StringMap()
		value171 = None
		_g153 = haxe_ds_StringMap()
		_g153.h["id"] = "PKEY"
		_g153.h["entityId"] = "ID"
		_g153.h["dataSourceId"] = "SOURCE_PKEY"
		_g153.h["reactionId"] = "SGCREACTION_PKEY"
		_g153.h["entityTypeId"] = "SGCENTITY_TYPE"
		_g153.h["altName"] = "ALTNAME"
		_g153.h["description"] = "DESCRIPTION"
		value171 = _g153
		_g152.h["fields"] = value171
		value172 = None
		_g154 = haxe_ds_StringMap()
		_g154.h["entityId"] = False
		_g154.h["id"] = True
		value172 = _g154
		_g152.h["indexes"] = value172
		value173 = None
		_g155 = haxe_ds_StringMap()
		_g155.h["schema"] = "SGC"
		_g155.h["name"] = "Z_ENTITY"
		value173 = _g155
		_g152.h["table_info"] = value173
		value174 = None
		_g156 = haxe_ds_StringMap()
		value175 = None
		_g157 = haxe_ds_StringMap()
		_g157.h["field"] = "dataSourceId"
		_g157.h["class"] = "saturn.core.domain.DataSource"
		_g157.h["fk_field"] = "id"
		value175 = _g157
		value176 = value175
		_g156.h["source"] = value176
		value177 = None
		_g158 = haxe_ds_StringMap()
		_g158.h["field"] = "reactionId"
		_g158.h["class"] = "saturn.core.Reaction"
		_g158.h["fk_field"] = "id"
		value177 = _g158
		value178 = value177
		_g156.h["reaction"] = value178
		value179 = None
		_g159 = haxe_ds_StringMap()
		_g159.h["field"] = "entityTypeId"
		_g159.h["class"] = "saturn.core.EntityType"
		_g159.h["fk_field"] = "id"
		value179 = _g159
		value180 = value179
		_g156.h["entityType"] = value180
		value174 = _g156
		_g152.h["fields.synthetic"] = value174
		value170 = _g152
		_g.h["saturn.core.domain.Entity"] = value170
		value181 = None
		_g160 = haxe_ds_StringMap()
		value182 = None
		_g161 = haxe_ds_StringMap()
		_g161.h["id"] = "PKEY"
		_g161.h["name"] = "ID"
		_g161.h["sequence"] = "LINEAR_SEQUENCE"
		_g161.h["entityId"] = "SGCENTITY_PKEY"
		value182 = _g161
		_g160.h["fields"] = value182
		value183 = None
		_g162 = haxe_ds_StringMap()
		_g162.h["name"] = False
		_g162.h["id"] = True
		value183 = _g162
		_g160.h["indexes"] = value183
		value184 = None
		_g163 = haxe_ds_StringMap()
		_g163.h["schema"] = "SGC"
		_g163.h["name"] = "Z_MOLECULE"
		value184 = _g163
		_g160.h["table_info"] = value184
		value185 = None
		_g164 = haxe_ds_StringMap()
		value186 = None
		_g165 = haxe_ds_StringMap()
		_g165.h["field"] = "entityId"
		_g165.h["class"] = "saturn.core.Entity"
		_g165.h["fk_field"] = "id"
		value186 = _g165
		value187 = value186
		_g164.h["entity"] = value187
		value185 = _g164
		_g160.h["fields.synthetic"] = value185
		value181 = _g160
		_g.h["saturn.core.domain.Molecule"] = value181
		value188 = None
		_g166 = haxe_ds_StringMap()
		value189 = None
		_g167 = haxe_ds_StringMap()
		_g167.h["id"] = "PKEY"
		_g167.h["name"] = "NAME"
		value189 = _g167
		_g166.h["fields"] = value189
		value190 = None
		_g168 = haxe_ds_StringMap()
		_g168.h["name"] = False
		_g168.h["id"] = True
		value190 = _g168
		_g166.h["indexes"] = value190
		value191 = None
		_g169 = haxe_ds_StringMap()
		_g169.h["schema"] = "SGC"
		_g169.h["name"] = "Z_REACTION_TYPE"
		value191 = _g169
		_g166.h["table_info"] = value191
		value188 = _g166
		_g.h["saturn.core.ReactionType"] = value188
		value192 = None
		_g170 = haxe_ds_StringMap()
		value193 = None
		_g171 = haxe_ds_StringMap()
		_g171.h["id"] = "PKEY"
		_g171.h["name"] = "NAME"
		value193 = _g171
		_g170.h["fields"] = value193
		value194 = None
		_g172 = haxe_ds_StringMap()
		_g172.h["name"] = False
		_g172.h["id"] = True
		value194 = _g172
		_g170.h["indexes"] = value194
		value195 = None
		_g173 = haxe_ds_StringMap()
		_g173.h["schema"] = "SGC"
		_g173.h["name"] = "Z_ENTITY_TYPE"
		value195 = _g173
		_g170.h["table_info"] = value195
		value192 = _g170
		_g.h["saturn.core.EntityType"] = value192
		value196 = None
		_g174 = haxe_ds_StringMap()
		value197 = None
		_g175 = haxe_ds_StringMap()
		_g175.h["id"] = "PKEY"
		_g175.h["name"] = "NAME"
		value197 = _g175
		_g174.h["fields"] = value197
		value198 = None
		_g176 = haxe_ds_StringMap()
		_g176.h["name"] = False
		_g176.h["id"] = True
		value198 = _g176
		_g174.h["indexes"] = value198
		value199 = None
		_g177 = haxe_ds_StringMap()
		_g177.h["schema"] = "SGC"
		_g177.h["name"] = "Z_REACTION_ROLE"
		value199 = _g177
		_g174.h["table_info"] = value199
		value196 = _g174
		_g.h["saturn.core.ReactionRole"] = value196
		value200 = None
		_g178 = haxe_ds_StringMap()
		value201 = None
		_g179 = haxe_ds_StringMap()
		_g179.h["id"] = "PKEY"
		_g179.h["name"] = "NAME"
		_g179.h["reactionTypeId"] = "SGCREACTION_TYPE"
		value201 = _g179
		_g178.h["fields"] = value201
		value202 = None
		_g180 = haxe_ds_StringMap()
		_g180.h["name"] = False
		_g180.h["id"] = True
		value202 = _g180
		_g178.h["indexes"] = value202
		value203 = None
		_g181 = haxe_ds_StringMap()
		_g181.h["schema"] = "SGC"
		_g181.h["name"] = "Z_REACTION"
		value203 = _g181
		_g178.h["table_info"] = value203
		value204 = None
		_g182 = haxe_ds_StringMap()
		value205 = None
		_g183 = haxe_ds_StringMap()
		_g183.h["field"] = "reactionTypeId"
		_g183.h["class"] = "saturn.core.ReactionType"
		_g183.h["fk_field"] = "id"
		value205 = _g183
		value206 = value205
		_g182.h["reactionType"] = value206
		value204 = _g182
		_g178.h["fields.synthetic"] = value204
		value200 = _g178
		_g.h["saturn.core.Reaction"] = value200
		value207 = None
		_g184 = haxe_ds_StringMap()
		value208 = None
		_g185 = haxe_ds_StringMap()
		_g185.h["id"] = "PKEY"
		_g185.h["reactionRoleId"] = "SGCROLE_PKEY"
		_g185.h["entityId"] = "SGCENTITY_PKEY"
		_g185.h["reactionId"] = "SGCREACTION_PKEY"
		_g185.h["position"] = "POSITION"
		value208 = _g185
		_g184.h["fields"] = value208
		value209 = None
		_g186 = haxe_ds_StringMap()
		_g186.h["id"] = True
		value209 = _g186
		_g184.h["indexes"] = value209
		value210 = None
		_g187 = haxe_ds_StringMap()
		_g187.h["schema"] = "SGC"
		_g187.h["name"] = "Z_REACTION_COMPONENT"
		value210 = _g187
		_g184.h["table_info"] = value210
		value211 = None
		_g188 = haxe_ds_StringMap()
		value212 = None
		_g189 = haxe_ds_StringMap()
		_g189.h["field"] = "reactionRoleId"
		_g189.h["class"] = "saturn.core.ReactionRole"
		_g189.h["fk_field"] = "id"
		value212 = _g189
		value213 = value212
		_g188.h["reactionRole"] = value213
		value214 = None
		_g190 = haxe_ds_StringMap()
		_g190.h["field"] = "reactionId"
		_g190.h["class"] = "saturn.core.Reaction"
		_g190.h["fk_field"] = "id"
		value214 = _g190
		value215 = value214
		_g188.h["reaction"] = value215
		value216 = None
		_g191 = haxe_ds_StringMap()
		_g191.h["field"] = "entityId"
		_g191.h["class"] = "saturn.core.Entity"
		_g191.h["fk_field"] = "id"
		value216 = _g191
		value217 = value216
		_g188.h["entity"] = value217
		value211 = _g188
		_g184.h["fields.synthetic"] = value211
		value207 = _g184
		_g.h["saturn.core.ReactionComponent"] = value207
		value218 = None
		_g192 = haxe_ds_StringMap()
		value219 = None
		_g193 = haxe_ds_StringMap()
		_g193.h["id"] = "PKEY"
		_g193.h["name"] = "NAME"
		value219 = _g193
		_g192.h["fields"] = value219
		value220 = None
		_g194 = haxe_ds_StringMap()
		_g194.h["name"] = False
		_g194.h["id"] = True
		value220 = _g194
		_g192.h["indexes"] = value220
		value221 = None
		_g195 = haxe_ds_StringMap()
		_g195.h["schema"] = "SGC"
		_g195.h["name"] = "Z_ENTITY_SOURCE"
		value221 = _g195
		_g192.h["table_info"] = value221
		value218 = _g192
		_g.h["saturn.core.domain.DataSource"] = value218
		value222 = None
		_g196 = haxe_ds_StringMap()
		value223 = None
		_g197 = haxe_ds_StringMap()
		_g197.h["id"] = "PKEY"
		_g197.h["entityId"] = "SGCENTITY_PKEY"
		_g197.h["labelId"] = "XREF_SGCENTITY_PKEY"
		_g197.h["start"] = "STARTPOS"
		_g197.h["stop"] = "STOPPOS"
		_g197.h["evalue"] = "EVALUE"
		value223 = _g197
		_g196.h["fields"] = value223
		value224 = None
		_g198 = haxe_ds_StringMap()
		_g198.h["id"] = True
		value224 = _g198
		_g196.h["indexes"] = value224
		value225 = None
		_g199 = haxe_ds_StringMap()
		_g199.h["schema"] = "SGC"
		_g199.h["name"] = "Z_ANNOTATION"
		value225 = _g199
		_g196.h["table_info"] = value225
		value226 = None
		_g200 = haxe_ds_StringMap()
		value227 = None
		_g201 = haxe_ds_StringMap()
		_g201.h["field"] = "entityId"
		_g201.h["class"] = "saturn.core.domain.Entity"
		_g201.h["fk_field"] = "id"
		value227 = _g201
		value228 = value227
		_g200.h["entity"] = value228
		value229 = None
		_g202 = haxe_ds_StringMap()
		_g202.h["field"] = "labelId"
		_g202.h["class"] = "saturn.core.domain.Entity"
		_g202.h["fk_field"] = "id"
		value229 = _g202
		value230 = value229
		_g200.h["referent"] = value230
		value226 = _g200
		_g196.h["fields.synthetic"] = value226
		value222 = _g196
		_g.h["saturn.core.domain.MoleculeAnnotation"] = value222
		value231 = None
		_g203 = haxe_ds_StringMap()
		value232 = None
		_g204 = haxe_ds_StringMap()
		_g204.h["id"] = "PKEY"
		_g204.h["modelId"] = "MODELID"
		_g204.h["pathToPdb"] = "PATHTOPDB"
		value232 = _g204
		_g203.h["fields"] = value232
		value233 = None
		_g205 = haxe_ds_StringMap()
		_g205.h["modelId"] = False
		_g205.h["id"] = True
		value233 = _g205
		_g203.h["indexes"] = value233
		value234 = None
		_g206 = haxe_ds_StringMap()
		_g206.h["schema"] = "SGC"
		_g206.h["name"] = "MODEL"
		value234 = _g206
		_g203.h["table_info"] = value234
		value235 = None
		_g207 = haxe_ds_StringMap()
		value236 = None
		_g208 = haxe_ds_StringMap()
		_g208.h["field"] = "pathToPdb"
		_g208.h["class"] = "saturn.core.domain.FileProxy"
		_g208.h["fk_field"] = "path"
		value236 = _g208
		value237 = value236
		_g207.h["pdb"] = value237
		value235 = _g207
		_g203.h["fields.synthetic"] = value235
		value238 = None
		_g209 = haxe_ds_StringMap()
		_g209.h["id_pattern"] = "\\w+-m"
		_g209.h["workspace_wrapper"] = "saturn.client.workspace.StructureModelWO"
		_g209.h["icon"] = "structure_16.png"
		_g209.h["alias"] = "Models"
		value238 = _g209
		_g203.h["options"] = value238
		value239 = None
		_g210 = haxe_ds_StringMap()
		_g210.h["modelId"] = "\\w+-m"
		value239 = _g210
		_g203.h["search"] = value239
		value240 = None
		_g211 = haxe_ds_StringMap()
		_g211.h["Model ID"] = "modelId"
		_g211.h["Path to PDB"] = "pathToPdb"
		value240 = _g211
		_g203.h["model"] = value240
		value231 = _g203
		_g.h["saturn.core.domain.StructureModel"] = value231
		value241 = None
		_g212 = haxe_ds_StringMap()
		value242 = None
		_g213 = haxe_ds_StringMap()
		_g213.h["path"] = "PATH"
		_g213.h["content"] = "CONTENT"
		value242 = _g213
		_g212.h["fields"] = value242
		value243 = None
		_g214 = haxe_ds_StringMap()
		_g214.h["path"] = True
		value243 = _g214
		_g212.h["indexes"] = value243
		value244 = None
		_g215 = haxe_ds_StringMap()
		value245 = None
		_g216 = haxe_ds_StringMap()
		_g216.h["/work"] = "W:"
		_g216.h["/home/share"] = "S:"
		value245 = _g216
		value246 = value245
		_g215.h["windows_conversions"] = value246
		value247 = None
		_g217 = haxe_ds_StringMap()
		_g217.h["WORK"] = "^W"
		value247 = _g217
		value248 = value247
		_g215.h["windows_allowed_paths_regex"] = value248
		value249 = None
		_g218 = haxe_ds_StringMap()
		_g218.h["W:"] = "/work"
		value249 = _g218
		value250 = value249
		_g215.h["linux_conversions"] = value250
		value251 = None
		_g219 = haxe_ds_StringMap()
		_g219.h["WORK"] = "^/work"
		value251 = _g219
		value252 = value251
		_g215.h["linux_allowed_paths_regex"] = value252
		value244 = _g215
		_g212.h["options"] = value244
		value241 = _g212
		_g.h["saturn.core.domain.FileProxy"] = value241
		value253 = None
		_g220 = haxe_ds_StringMap()
		value254 = None
		_g221 = haxe_ds_StringMap()
		_g221.h["moleculeName"] = "NAME"
		value254 = _g221
		_g220.h["fields"] = value254
		value255 = None
		_g222 = haxe_ds_StringMap()
		_g222.h["moleculeName"] = True
		value255 = _g222
		_g220.h["indexes"] = value255
		value256 = None
		_g223 = haxe_ds_StringMap()
		_g223.h["saturn.client.programs.DNASequenceEditor"] = False
		value256 = _g223
		_g220.h["programs"] = value256
		value257 = None
		_g224 = haxe_ds_StringMap()
		_g224.h["alias"] = "DNA"
		_g224.h["icon"] = "dna_conical_16.png"
		value257 = _g224
		_g220.h["options"] = value257
		value253 = _g220
		_g.h["saturn.core.DNA"] = value253
		value258 = None
		_g225 = haxe_ds_StringMap()
		value259 = None
		_g226 = haxe_ds_StringMap()
		_g226.h["moleculeName"] = "NAME"
		value259 = _g226
		_g225.h["fields"] = value259
		value260 = None
		_g227 = haxe_ds_StringMap()
		_g227.h["moleculeName"] = True
		value260 = _g227
		_g225.h["indexes"] = value260
		value261 = None
		_g228 = haxe_ds_StringMap()
		_g228.h["saturn.client.programs.ProteinSequenceEditor"] = False
		value261 = _g228
		_g225.h["programs"] = value261
		value262 = None
		_g229 = haxe_ds_StringMap()
		_g229.h["alias"] = "Proteins"
		_g229.h["icon"] = "structure_16.png"
		value262 = _g229
		_g225.h["options"] = value262
		value258 = _g225
		_g.h["saturn.core.Protein"] = value258
		value263 = None
		_g230 = haxe_ds_StringMap()
		value264 = None
		_g231 = haxe_ds_StringMap()
		_g231.h["name"] = "NAME"
		value264 = _g231
		_g230.h["fields"] = value264
		value265 = None
		_g232 = haxe_ds_StringMap()
		_g232.h["name"] = True
		value265 = _g232
		_g230.h["indexes"] = value265
		value266 = None
		_g233 = haxe_ds_StringMap()
		_g233.h["saturn.client.programs.TextEditor"] = True
		value266 = _g233
		_g230.h["programs"] = value266
		value267 = None
		_g234 = haxe_ds_StringMap()
		_g234.h["alias"] = "File"
		value267 = _g234
		_g230.h["options"] = value267
		value263 = _g230
		_g.h["saturn.core.TextFile"] = value263
		value268 = None
		_g235 = haxe_ds_StringMap()
		value269 = None
		_g236 = haxe_ds_StringMap()
		_g236.h["saturn.client.programs.BasicTableViewer"] = True
		value269 = _g236
		_g235.h["programs"] = value269
		value270 = None
		_g237 = haxe_ds_StringMap()
		_g237.h["alias"] = "Results"
		value270 = _g237
		_g235.h["options"] = value270
		value268 = _g235
		_g.h["saturn.core.BasicTable"] = value268
		value271 = None
		_g238 = haxe_ds_StringMap()
		value272 = None
		_g239 = haxe_ds_StringMap()
		_g239.h["saturn.client.programs.ConstructDesigner"] = False
		value272 = _g239
		_g238.h["programs"] = value272
		value273 = None
		_g240 = haxe_ds_StringMap()
		_g240.h["alias"] = "Construct Design"
		value273 = _g240
		_g238.h["options"] = value273
		value271 = _g238
		_g.h["saturn.core.ConstructDesignTable"] = value271
		value274 = None
		_g241 = haxe_ds_StringMap()
		value275 = None
		_g242 = haxe_ds_StringMap()
		_g242.h["saturn.client.programs.PurificationHelper"] = False
		value275 = _g242
		_g241.h["programs"] = value275
		value276 = None
		_g243 = haxe_ds_StringMap()
		_g243.h["alias"] = "Purifiaction Helper"
		value276 = _g243
		_g241.h["options"] = value276
		value274 = _g241
		_g.h["saturn.core.PurificationHelperTable"] = value274
		value277 = None
		_g244 = haxe_ds_StringMap()
		value278 = None
		_g245 = haxe_ds_StringMap()
		_g245.h["saturn.client.programs.SHRNADesigner"] = False
		value278 = _g245
		_g244.h["programs"] = value278
		value279 = None
		_g246 = haxe_ds_StringMap()
		_g246.h["alias"] = "shRNA Designer"
		_g246.h["icon"] = "shrna_16.png"
		value279 = _g246
		_g244.h["options"] = value279
		value277 = _g244
		_g.h["saturn.core.SHRNADesignTable"] = value277
		value280 = None
		_g247 = haxe_ds_StringMap()
		value281 = None
		_g248 = haxe_ds_StringMap()
		_g248.h["saturn.client.programs.BasicTableViewer"] = False
		value281 = _g248
		_g247.h["programs"] = value281
		value282 = None
		_g249 = haxe_ds_StringMap()
		_g249.h["alias"] = "Table"
		value282 = _g249
		_g247.h["options"] = value282
		value280 = _g247
		_g.h["saturn.core.Table"] = value280
		value283 = None
		_g250 = haxe_ds_StringMap()
		value284 = None
		_g251 = haxe_ds_StringMap()
		_g251.h["id"] = "PKEY"
		_g251.h["compoundId"] = "SGCGLOBALID"
		_g251.h["shortCompoundId"] = "COMPOUND_ID"
		_g251.h["supplierId"] = "SUPPLIER_ID"
		_g251.h["sdf"] = "SDF"
		_g251.h["supplier"] = "SUPPLIER"
		_g251.h["description"] = "DESCRIPTION"
		_g251.h["concentration"] = "CONCENTRATION"
		_g251.h["location"] = "LOCATION"
		_g251.h["comments"] = "COMMENTS"
		_g251.h["solute"] = "SOLUTE"
		_g251.h["mw"] = "MW"
		_g251.h["confidential"] = "CONFIDENTIAL"
		_g251.h["inchi"] = "INCHI"
		_g251.h["smiles"] = "SMILES"
		_g251.h["datestamp"] = "DATESTAMP"
		_g251.h["person"] = "PERSON"
		value284 = _g251
		_g250.h["fields"] = value284
		value285 = None
		_g252 = haxe_ds_StringMap()
		_g252.h["compoundId"] = False
		_g252.h["id"] = True
		value285 = _g252
		_g250.h["indexes"] = value285
		value286 = None
		_g253 = haxe_ds_StringMap()
		_g253.h["compoundId"] = None
		_g253.h["shortCompoundId"] = None
		_g253.h["supplierId"] = None
		_g253.h["supplier"] = None
		value286 = _g253
		_g250.h["search"] = value286
		value287 = None
		_g254 = haxe_ds_StringMap()
		_g254.h["schema"] = "SGC"
		_g254.h["name"] = "SGCCOMPOUND"
		value287 = _g254
		_g250.h["table_info"] = value287
		value288 = None
		_g255 = haxe_ds_StringMap()
		_g255.h["id_pattern"] = "^\\w{5}\\d{4}"
		_g255.h["workspace_wrapper"] = "saturn.client.workspace.CompoundWO"
		_g255.h["icon"] = "compound_16.png"
		_g255.h["alias"] = "Compounds"
		value289 = None
		_g256 = haxe_ds_StringMap()
		value290 = None
		_g257 = haxe_ds_StringMap()
		value291 = None
		_g258 = haxe_ds_StringMap()
		_g258.h["user_suffix"] = "Assay Results"
		_g258.h["function"] = "saturn.core.domain.Compound.assaySearch"
		value291 = _g258
		_g257.h["assay_results"] = value291
		value290 = _g257
		_g256.h["search_bar"] = value290
		value289 = _g256
		value292 = value289
		_g255.h["actions"] = value292
		value288 = _g255
		_g250.h["options"] = value288
		value293 = None
		_g259 = haxe_ds_StringMap()
		_g259.h["Global ID"] = "compoundId"
		_g259.h["Oxford ID"] = "shortCompoundId"
		_g259.h["Supplier ID"] = "supplierId"
		_g259.h["Supplier"] = "supplier"
		_g259.h["Description"] = "description"
		_g259.h["Concentration"] = "concentration"
		_g259.h["Location"] = "location"
		_g259.h["Solute"] = "solute"
		_g259.h["Comments"] = "comments"
		_g259.h["MW"] = "mw"
		_g259.h["Confidential"] = "CONFIDENTIAL"
		_g259.h["Date"] = "datestamp"
		_g259.h["Person"] = "person"
		_g259.h["InChi"] = "inchi"
		_g259.h["smiles"] = "smiles"
		value293 = _g259
		_g250.h["model"] = value293
		value294 = None
		_g260 = haxe_ds_StringMap()
		_g260.h["saturn.client.programs.CompoundViewer"] = True
		value294 = _g260
		_g250.h["programs"] = value294
		value283 = _g250
		_g.h["saturn.core.domain.Compound"] = value283
		value295 = None
		_g261 = haxe_ds_StringMap()
		value296 = None
		_g262 = haxe_ds_StringMap()
		value297 = None
		_g263 = haxe_ds_StringMap()
		_g263.h["SGC"] = True
		value297 = _g263
		value298 = value297
		_g262.h["flags"] = value298
		value296 = _g262
		_g261.h["options"] = value296
		value295 = _g261
		_g.h["saturn.app.SaturnClient"] = value295
		value299 = None
		_g264 = haxe_ds_StringMap()
		value300 = None
		_g265 = haxe_ds_StringMap()
		_g265.h["id"] = "PKEY"
		_g265.h["username"] = "USERID"
		_g265.h["fullname"] = "FULLNAME"
		value300 = _g265
		_g264.h["fields"] = value300
		value301 = None
		_g266 = haxe_ds_StringMap()
		_g266.h["id"] = True
		_g266.h["username"] = False
		value301 = _g266
		_g264.h["indexes"] = value301
		value302 = None
		_g267 = haxe_ds_StringMap()
		_g267.h["schema"] = "HIVE"
		_g267.h["name"] = "USER_DETAILS"
		value302 = _g267
		_g264.h["table_info"] = value302
		value299 = _g264
		_g.h["saturn.core.User"] = value299
		value303 = None
		_g268 = haxe_ds_StringMap()
		value304 = None
		_g269 = haxe_ds_StringMap()
		_g269.h["id"] = "PKEY"
		_g269.h["name"] = "NAME"
		value304 = _g269
		_g268.h["fields"] = value304
		value305 = None
		_g270 = haxe_ds_StringMap()
		_g270.h["id"] = True
		_g270.h["name"] = False
		value305 = _g270
		_g268.h["index"] = value305
		value306 = None
		_g271 = haxe_ds_StringMap()
		_g271.h["schema"] = "SGC"
		_g271.h["name"] = "SATURNPERMISSION"
		value306 = _g271
		_g268.h["table_info"] = value306
		value303 = _g268
		_g.h["saturn.core.Permission"] = value303
		value307 = None
		_g272 = haxe_ds_StringMap()
		value308 = None
		_g273 = haxe_ds_StringMap()
		_g273.h["id"] = "PKEY"
		_g273.h["permissionId"] = "PERMISSIONID"
		_g273.h["userId"] = "USERID"
		value308 = _g273
		_g272.h["fields"] = value308
		value309 = None
		_g274 = haxe_ds_StringMap()
		_g274.h["id"] = True
		value309 = _g274
		_g272.h["index"] = value309
		value310 = None
		_g275 = haxe_ds_StringMap()
		_g275.h["schema"] = "SGC"
		_g275.h["name"] = "SATURNUSER_TO_PERMISSION"
		value310 = _g275
		_g272.h["table_info"] = value310
		value307 = _g272
		_g.h["saturn.core.UserToPermission"] = value307
		value311 = None
		_g276 = haxe_ds_StringMap()
		value312 = None
		_g277 = haxe_ds_StringMap()
		_g277.h["id"] = "PKEY"
		_g277.h["userName"] = "USERNAME"
		_g277.h["isPublic"] = "ISPUBLIC"
		_g277.h["sessionContent"] = "SESSIONCONTENTS"
		_g277.h["sessionName"] = "SESSIONNAME"
		value312 = _g277
		_g276.h["fields"] = value312
		value313 = None
		_g278 = haxe_ds_StringMap()
		_g278.h["sessionName"] = False
		_g278.h["id"] = True
		value313 = _g278
		_g276.h["indexes"] = value313
		value314 = None
		_g279 = haxe_ds_StringMap()
		_g279.h["user.fullname"] = None
		value314 = _g279
		_g276.h["search"] = value314
		value315 = None
		_g280 = haxe_ds_StringMap()
		_g280.h["schema"] = "SGC"
		_g280.h["name"] = "SATURNSESSION"
		value315 = _g280
		_g276.h["table_info"] = value315
		value316 = None
		_g281 = haxe_ds_StringMap()
		_g281.h["alias"] = "Session"
		_g281.h["auto_activate"] = "3"
		value317 = None
		_g282 = haxe_ds_StringMap()
		_g282.h["user_constraint_field"] = "userName"
		_g282.h["public_constraint_field"] = "isPublic"
		value317 = _g282
		value318 = value317
		_g281.h["constraints"] = value318
		value319 = None
		_g283 = haxe_ds_StringMap()
		value320 = None
		_g284 = haxe_ds_StringMap()
		value321 = None
		_g285 = haxe_ds_StringMap()
		_g285.h["user_suffix"] = ""
		_g285.h["function"] = "saturn.core.domain.SaturnSession.load"
		value321 = _g285
		_g284.h["DEFAULT"] = value321
		value320 = _g284
		_g283.h["search_bar"] = value320
		value319 = _g283
		value322 = value319
		_g281.h["actions"] = value322
		value316 = _g281
		_g276.h["options"] = value316
		value323 = None
		_g286 = haxe_ds_StringMap()
		_g286.h["USERNAME"] = "insert.username"
		value323 = _g286
		_g276.h["auto_functions"] = value323
		value324 = None
		_g287 = haxe_ds_StringMap()
		value325 = None
		_g288 = haxe_ds_StringMap()
		_g288.h["field"] = "userName"
		_g288.h["class"] = "saturn.core.User"
		_g288.h["fk_field"] = "username"
		value325 = _g288
		value326 = value325
		_g287.h["user"] = value326
		value324 = _g287
		_g276.h["fields.synthetic"] = value324
		value311 = _g276
		_g.h["saturn.core.domain.SaturnSession"] = value311
		value327 = None
		_g289 = haxe_ds_StringMap()
		value328 = None
		_g290 = haxe_ds_StringMap()
		_g290.h["id"] = "PKEY"
		_g290.h["barcode"] = "BARCODE"
		_g290.h["purificationId"] = "SGCPURIFICATION_PKEY"
		value328 = _g290
		_g289.h["fields"] = value328
		value329 = None
		_g291 = haxe_ds_StringMap()
		_g291.h["barcode"] = False
		_g291.h["id"] = True
		value329 = _g291
		_g289.h["indexes"] = value329
		value330 = None
		_g292 = haxe_ds_StringMap()
		_g292.h["schema"] = "SGC"
		_g292.h["name"] = "XTAL_PLATES"
		value330 = _g292
		_g289.h["table_info"] = value330
		value331 = None
		_g293 = haxe_ds_StringMap()
		value332 = None
		_g294 = haxe_ds_StringMap()
		_g294.h["field"] = "purificationId"
		_g294.h["class"] = "saturn.core.domain.SgcPurification"
		_g294.h["fk_field"] = "id"
		value332 = _g294
		value333 = value332
		_g293.h["purification"] = value333
		value331 = _g293
		_g289.h["fields.synthetic"] = value331
		value334 = None
		_g295 = haxe_ds_StringMap()
		_g295.h["alias"] = "Xtal Plates"
		value334 = _g295
		_g289.h["options"] = value334
		value335 = None
		_g296 = haxe_ds_StringMap()
		_g296.h["Barcode"] = "barcode"
		value335 = _g296
		_g289.h["model"] = value335
		value327 = _g289
		_g.h["saturn.core.domain.SgcXtalPlate"] = value327
		value336 = None
		_g297 = haxe_ds_StringMap()
		value337 = None
		_g298 = haxe_ds_StringMap()
		_g298.h["id"] = "PKEY"
		_g298.h["xtbmId"] = "XTBMID"
		_g298.h["plateRow"] = "PLATEROW"
		_g298.h["plateColumn"] = "PLATECOLUMN"
		_g298.h["subwell"] = "SUBWELL"
		_g298.h["xtalPlateId"] = "XTALPLATES_ID"
		_g298.h["score"] = "CATEGORYSCORE"
		_g298.h["barcode"] = "BARCODE"
		value337 = _g298
		_g297.h["fields"] = value337
		value338 = None
		_g299 = haxe_ds_StringMap()
		_g299.h["xtbmId"] = False
		_g299.h["id"] = True
		value338 = _g299
		_g297.h["indexes"] = value338
		value339 = None
		_g300 = haxe_ds_StringMap()
		_g300.h["schema"] = "SGC"
		_g300.h["name"] = "CRYSTALSTOBEMOUNTED"
		value339 = _g300
		_g297.h["table_info"] = value339
		value340 = None
		_g301 = haxe_ds_StringMap()
		value341 = None
		_g302 = haxe_ds_StringMap()
		_g302.h["field"] = "xtalPlateId"
		_g302.h["class"] = "saturn.core.domain.SgcXtalPlate"
		_g302.h["fk_field"] = "id"
		value341 = _g302
		value342 = value341
		_g301.h["xtalPlate"] = value342
		value340 = _g301
		_g297.h["fields.synthetic"] = value340
		value343 = None
		_g303 = haxe_ds_StringMap()
		_g303.h["alias"] = "XTBM"
		value343 = _g303
		_g297.h["options"] = value343
		value344 = None
		_g304 = haxe_ds_StringMap()
		_g304.h["XTBM ID"] = "xtbmId"
		_g304.h["Plate ID"] = "xtalPlateId"
		value344 = _g304
		_g297.h["model"] = value344
		value336 = _g297
		_g.h["saturn.core.domain.SgcXtbm"] = value336
		value345 = None
		_g305 = haxe_ds_StringMap()
		value346 = None
		_g306 = haxe_ds_StringMap()
		_g306.h["id"] = "PKEY"
		_g306.h["xtalMountId"] = "XTAL_MOUNT_ID"
		_g306.h["xtbmId"] = "SGCCRYSTALSTOBEMOUNTED_PKEY"
		_g306.h["xtalProjectId"] = "SGCPROJECTS_PKEY"
		_g306.h["dropStatus"] = "DROPSTATUS"
		_g306.h["compoundId"] = "SGCCOMPOUND_PKEY"
		_g306.h["pinId"] = "SGCPIN_PKEY"
		_g306.h["xtalFormId"] = "SGCXTALFORM_PKEY"
		value346 = _g306
		_g305.h["fields"] = value346
		value347 = None
		_g307 = haxe_ds_StringMap()
		_g307.h["xtalMountId"] = False
		_g307.h["id"] = True
		value347 = _g307
		_g305.h["indexes"] = value347
		value348 = None
		_g308 = haxe_ds_StringMap()
		_g308.h["schema"] = "SGC"
		_g308.h["name"] = "XTAL_MOUNT"
		value348 = _g308
		_g305.h["table_info"] = value348
		value349 = None
		_g309 = haxe_ds_StringMap()
		value350 = None
		_g310 = haxe_ds_StringMap()
		_g310.h["field"] = "xtbmId"
		_g310.h["class"] = "saturn.core.domain.SgcXtbm"
		_g310.h["fk_field"] = "id"
		value350 = _g310
		value351 = value350
		_g309.h["xtbm"] = value351
		value352 = None
		_g311 = haxe_ds_StringMap()
		_g311.h["field"] = "xtalProjectId"
		_g311.h["class"] = "saturn.core.domain.SgcXtalProject"
		_g311.h["fk_field"] = "id"
		value352 = _g311
		value353 = value352
		_g309.h["xtalProject"] = value353
		value354 = None
		_g312 = haxe_ds_StringMap()
		_g312.h["field"] = "compoundId"
		_g312.h["class"] = "saturn.core.domain.Compound"
		_g312.h["fk_field"] = "id"
		value354 = _g312
		value355 = value354
		_g309.h["compound"] = value355
		value356 = None
		_g313 = haxe_ds_StringMap()
		_g313.h["field"] = "xtalFormId"
		_g313.h["class"] = "saturn.core.domain.SgcXtalForm"
		_g313.h["fk_field"] = "id"
		value356 = _g313
		value357 = value356
		_g309.h["xtalForm"] = value357
		value349 = _g309
		_g305.h["fields.synthetic"] = value349
		value358 = None
		_g314 = haxe_ds_StringMap()
		_g314.h["alias"] = "Mounted Xtal"
		value358 = _g314
		_g305.h["options"] = value358
		value345 = _g305
		_g.h["saturn.core.domain.SgcXtalMount"] = value345
		value359 = None
		_g315 = haxe_ds_StringMap()
		value360 = None
		_g316 = haxe_ds_StringMap()
		_g316.h["id"] = "PKEY"
		_g316.h["xtalDataSetId"] = "DATASETID"
		_g316.h["xtalMountId"] = "SGCXTALMOUNT_PKEY"
		_g316.h["estimatedResolution"] = "ESTRESOLUTION"
		_g316.h["scaledResolution"] = "RESOLUTION"
		_g316.h["xtalProjectId"] = "SGCPROJECTS_PKEY"
		_g316.h["beamline"] = "BEAMLINE"
		_g316.h["outcome"] = "OUTCOME"
		_g316.h["dsType"] = "DSTYPE"
		_g316.h["visit"] = "VISIT"
		_g316.h["spaceGroup"] = "SPACEGROUP"
		_g316.h["dateRecordCreated"] = "DATESTAMP"
		value360 = _g316
		_g315.h["fields"] = value360
		value361 = None
		_g317 = haxe_ds_StringMap()
		_g317.h["xtalDataSetId"] = False
		_g317.h["id"] = True
		value361 = _g317
		_g315.h["indexes"] = value361
		value362 = None
		_g318 = haxe_ds_StringMap()
		_g318.h["schema"] = "SGC"
		_g318.h["name"] = "XTAL_DATASET"
		value362 = _g318
		_g315.h["table_info"] = value362
		value363 = None
		_g319 = haxe_ds_StringMap()
		value364 = None
		_g320 = haxe_ds_StringMap()
		_g320.h["field"] = "xtalMountId"
		_g320.h["class"] = "saturn.core.domain.SgcXtalMount"
		_g320.h["fk_field"] = "id"
		value364 = _g320
		value365 = value364
		_g319.h["xtalMount"] = value365
		value366 = None
		_g321 = haxe_ds_StringMap()
		_g321.h["field"] = "xtalProjectId"
		_g321.h["class"] = "saturn.core.domain.SgcXtalProject"
		_g321.h["fk_field"] = "id"
		value366 = _g321
		value367 = value366
		_g319.h["xtalProject"] = value367
		value363 = _g319
		_g315.h["fields.synthetic"] = value363
		value368 = None
		_g322 = haxe_ds_StringMap()
		_g322.h["alias"] = "Xtal DataSet"
		value368 = _g322
		_g315.h["options"] = value368
		value359 = _g315
		_g.h["saturn.core.domain.SgcXtalDataSet"] = value359
		value369 = None
		_g323 = haxe_ds_StringMap()
		value370 = None
		_g324 = haxe_ds_StringMap()
		_g324.h["id"] = "PKEY"
		_g324.h["xtalModelId"] = "MODELID"
		_g324.h["modelType"] = "MODELTYPE"
		_g324.h["compound1Id"] = "SGCCOMPOUND1_PKEY"
		_g324.h["compound2Id"] = "SGCCOMPOUND2_PKEY"
		_g324.h["xtalDataSetId"] = "SGCXTALDATASET_PKEY"
		_g324.h["status"] = "STATUS"
		_g324.h["pathToCrystallographicPDB"] = "PATHTOPDB"
		_g324.h["pathToChemistsPDB"] = "PATHTOBOUNDPDB"
		_g324.h["pathToMTZ"] = "PATHTOMTZ"
		_g324.h["pathToXDSLog"] = "PATHTOLOG"
		_g324.h["estimatedEffort"] = "ESTEFFORT"
		_g324.h["proofingEffort"] = "PROOFEFFORT"
		_g324.h["spaceGroup"] = "SPACEGROUP"
		value370 = _g324
		_g323.h["fields"] = value370
		value371 = None
		_g325 = haxe_ds_StringMap()
		_g325.h["xtalModelId"] = False
		_g325.h["id"] = True
		value371 = _g325
		_g323.h["indexes"] = value371
		value372 = None
		_g326 = haxe_ds_StringMap()
		_g326.h["schema"] = "SGC"
		_g326.h["name"] = "MODEL"
		value372 = _g326
		_g323.h["table_info"] = value372
		value373 = None
		_g327 = haxe_ds_StringMap()
		value374 = None
		_g328 = haxe_ds_StringMap()
		_g328.h["field"] = "xtalDataSetId"
		_g328.h["class"] = "saturn.core.domain.SgcXtalDataSet"
		_g328.h["fk_field"] = "id"
		value374 = _g328
		value375 = value374
		_g327.h["xtalDataSet"] = value375
		value373 = _g327
		_g323.h["fields.synthetic"] = value373
		value376 = None
		_g329 = haxe_ds_StringMap()
		_g329.h["alias"] = "Xtal Model"
		value376 = _g329
		_g323.h["options"] = value376
		value369 = _g323
		_g.h["saturn.core.domain.SgcXtalModel"] = value369
		value377 = None
		_g330 = haxe_ds_StringMap()
		value378 = None
		_g331 = haxe_ds_StringMap()
		_g331.h["id"] = "PKEY"
		_g331.h["pdbId"] = "PDBID"
		_g331.h["counted"] = "COUNTED"
		_g331.h["site"] = "SITE"
		_g331.h["followup"] = "FOLLOWUP"
		_g331.h["xtalModelId"] = "SGCMODEL_PKEY"
		_g331.h["dateDeposited"] = "DATEDEPOSITED"
		value378 = _g331
		_g330.h["fields"] = value378
		value379 = None
		_g332 = haxe_ds_StringMap()
		_g332.h["pdbId"] = False
		_g332.h["id"] = True
		value379 = _g332
		_g330.h["indexes"] = value379
		value380 = None
		_g333 = haxe_ds_StringMap()
		_g333.h["schema"] = "SGC"
		_g333.h["name"] = "DEPOSITION"
		value380 = _g333
		_g330.h["table_info"] = value380
		value381 = None
		_g334 = haxe_ds_StringMap()
		value382 = None
		_g335 = haxe_ds_StringMap()
		_g335.h["field"] = "xtalModelId"
		_g335.h["class"] = "saturn.core.domain.SgcXtalModel"
		_g335.h["fk_field"] = "id"
		value382 = _g335
		value383 = value382
		_g334.h["xtalModel"] = value383
		value381 = _g334
		_g330.h["fields.synthetic"] = value381
		value384 = None
		_g336 = haxe_ds_StringMap()
		_g336.h["alias"] = "Xtal Model"
		value384 = _g336
		_g330.h["options"] = value384
		value377 = _g330
		_g.h["saturn.core.domain.SgcXtalDeposition"] = value377
		value385 = None
		_g337 = haxe_ds_StringMap()
		value386 = None
		_g338 = haxe_ds_StringMap()
		_g338.h["id"] = "PKEY"
		_g338.h["xtalProjectId"] = "PROJECTID"
		_g338.h["dataPath"] = "DATA_PATH"
		_g338.h["targetId"] = "SGCTARGET_PKEY"
		value386 = _g338
		_g337.h["fields"] = value386
		value387 = None
		_g339 = haxe_ds_StringMap()
		_g339.h["xtalProjectId"] = False
		_g339.h["id"] = True
		value387 = _g339
		_g337.h["indexes"] = value387
		value388 = None
		_g340 = haxe_ds_StringMap()
		_g340.h["schema"] = "SGC"
		_g340.h["name"] = "PROJECTS"
		value388 = _g340
		_g337.h["table_info"] = value388
		value389 = None
		_g341 = haxe_ds_StringMap()
		value390 = None
		_g342 = haxe_ds_StringMap()
		_g342.h["field"] = "targetId"
		_g342.h["class"] = "saturn.core.domain.SgcTarget"
		_g342.h["fk_field"] = "id"
		value390 = _g342
		value391 = value390
		_g341.h["target"] = value391
		value389 = _g341
		_g337.h["fields.synthetic"] = value389
		value392 = None
		_g343 = haxe_ds_StringMap()
		_g343.h["alias"] = "Xtal Model"
		_g343.h["auto_activate"] = "3"
		value392 = _g343
		_g337.h["options"] = value392
		value385 = _g337
		_g.h["saturn.core.domain.SgcXtalProject"] = value385
		value393 = None
		_g344 = haxe_ds_StringMap()
		value394 = None
		_g345 = haxe_ds_StringMap()
		_g345.h["id"] = "PKEY"
		_g345.h["formId"] = "FORMID"
		_g345.h["phasingId"] = "SGCPHASING_PKEY"
		_g345.h["a"] = "A"
		_g345.h["b"] = "B"
		_g345.h["c"] = "C"
		_g345.h["alpha"] = "ALPHA"
		_g345.h["beta"] = "BETA"
		_g345.h["gamma"] = "GAMMA"
		_g345.h["lattice"] = "LATTICE"
		_g345.h["latticeSymbol"] = "LATTICESYMBOL"
		_g345.h["spaceGroup"] = "SPACEGROUP"
		value394 = _g345
		_g344.h["fields"] = value394
		value395 = None
		_g346 = haxe_ds_StringMap()
		_g346.h["formId"] = False
		_g346.h["id"] = True
		value395 = _g346
		_g344.h["indexes"] = value395
		value396 = None
		_g347 = haxe_ds_StringMap()
		_g347.h["schema"] = "SGC"
		_g347.h["name"] = "XTAL_FORM"
		value396 = _g347
		_g344.h["table_info"] = value396
		value397 = None
		_g348 = haxe_ds_StringMap()
		value398 = None
		_g349 = haxe_ds_StringMap()
		_g349.h["field"] = "phasingId"
		_g349.h["class"] = "saturn.core.domain.SgcXtalPhasing"
		_g349.h["fk_field"] = "id"
		value398 = _g349
		value399 = value398
		_g348.h["xtalPhasing"] = value399
		value397 = _g348
		_g344.h["fields.synthetic"] = value397
		value400 = None
		_g350 = haxe_ds_StringMap()
		_g350.h["alias"] = "Xtal Form"
		value400 = _g350
		_g344.h["options"] = value400
		value393 = _g344
		_g.h["saturn.core.domain.SgcXtalForm"] = value393
		value401 = None
		_g351 = haxe_ds_StringMap()
		value402 = None
		_g352 = haxe_ds_StringMap()
		_g352.h["id"] = "PKEY"
		_g352.h["phasingId"] = "PHASINGID"
		_g352.h["xtalDataSetId"] = "SGCXTALDATASET_PKEY1"
		_g352.h["phasingMethod"] = "PHASINGMETHOD"
		_g352.h["phasingConfidence"] = "CONFIDENCE"
		_g352.h["spaceGroup"] = "SPACEGROUP"
		value402 = _g352
		_g351.h["fields"] = value402
		value403 = None
		_g353 = haxe_ds_StringMap()
		_g353.h["phasingId"] = False
		_g353.h["id"] = True
		value403 = _g353
		_g351.h["indexes"] = value403
		value404 = None
		_g354 = haxe_ds_StringMap()
		_g354.h["schema"] = "SGC"
		_g354.h["name"] = "XTAL_PHASING"
		value404 = _g354
		_g351.h["table_info"] = value404
		value405 = None
		_g355 = haxe_ds_StringMap()
		value406 = None
		_g356 = haxe_ds_StringMap()
		_g356.h["field"] = "xtalDataSetId"
		_g356.h["class"] = "saturn.core.domain.SgcXtalDataSet"
		_g356.h["fk_field"] = "id"
		value406 = _g356
		value407 = value406
		_g355.h["xtalDataSet"] = value407
		value405 = _g355
		_g351.h["fields.synthetic"] = value405
		value408 = None
		_g357 = haxe_ds_StringMap()
		_g357.h["alias"] = "Xtal Phasing"
		value408 = _g357
		_g351.h["options"] = value408
		value401 = _g351
		_g.h["saturn.core.domain.SgcXtalPhasing"] = value401
		self.models = _g

	@staticmethod
	def getNextAvailableId(clazz,value,db,cb):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.models = None
saturn_db_mapping_SGC._hx_class = saturn_db_mapping_SGC
_hx_classes["saturn.db.mapping.SGC"] = saturn_db_mapping_SGC


class saturn_db_mapping_SGCSQLite(saturn_db_mapping_SGC):
	_hx_class_name = "saturn.db.mapping.SGCSQLite"
	_hx_fields = []
	_hx_methods = ["buildModels"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_mapping_SGC


	def __init__(self):
		super().__init__()
		saturn_core_Util.debug("Loading SQLite")

	def buildModels(self):
		super().buildModels()
		saturn_core_Util.debug("Adding flag")
		def _hx_local_0():
			this1 = None
			this2 = self.models.h.get("saturn.app.SaturnClient",None)
			this1 = this2.get("options")
			return this1.get("flags")
		Reflect.field((_hx_local_0()),"set")("NO_LOGIN",True)
		value = None
		_g = haxe_ds_StringMap()
		value1 = None
		_g1 = haxe_ds_StringMap()
		_g1.h["targetId"] = "TARGET_ID"
		_g1.h["id"] = "PKEY"
		_g1.h["gi"] = "GENBANK_ID"
		_g1.h["dnaSeq"] = "DNASEQ"
		_g1.h["proteinSeq"] = "PROTSEQ"
		value1 = _g1
		_g.h["fields"] = value1
		value2 = None
		_g2 = haxe_ds_StringMap()
		_g2.h["targetId"] = False
		_g2.h["id"] = True
		value2 = _g2
		_g.h["indexes"] = value2
		value3 = None
		_g3 = haxe_ds_StringMap()
		_g3.h["schema"] = "SGC"
		_g3.h["name"] = "TARGET"
		_g3.h["human_name"] = "Target"
		_g3.h["human_name_plural"] = "Targets"
		value3 = _g3
		_g.h["table_info"] = value3
		value4 = None
		_g4 = haxe_ds_StringMap()
		_g4.h["Target ID"] = "targetId"
		_g4.h["Genbank ID"] = "gi"
		_g4.h["Protein Sequence"] = "proteinSeq"
		_g4.h["__HIDDEN__PKEY__"] = "id"
		value4 = _g4
		_g.h["model"] = value4
		value5 = None
		_g5 = haxe_ds_StringMap()
		_g5.h["targetId"] = None
		value5 = _g5
		_g.h["search"] = value5
		value6 = None
		_g6 = haxe_ds_StringMap()
		_g6.h["saturn.client.programs.DNASequenceEditor"] = True
		value6 = _g6
		_g.h["programs"] = value6
		value7 = None
		_g7 = haxe_ds_StringMap()
		_g7.h["id_pattern"] = ".*"
		_g7.h["alias"] = "Target"
		_g7.h["icon"] = "dna_conical_16.png"
		value8 = None
		_g8 = haxe_ds_StringMap()
		value9 = None
		_g9 = haxe_ds_StringMap()
		value10 = None
		_g10 = haxe_ds_StringMap()
		_g10.h["user_suffix"] = "Wonka"
		_g10.h["function"] = "saturn.core.domain.SgcTarget.loadWonka"
		value10 = _g10
		_g9.h["wonka"] = value10
		value9 = _g9
		_g8.h["search_bar"] = value9
		value8 = _g8
		value11 = value8
		_g7.h["actions"] = value11
		value7 = _g7
		_g.h["options"] = value7
		value = _g
		self.models.h["saturn.core.domain.SgcTarget"] = value

	@staticmethod
	def _hx_empty_init(_hx_o):		pass
saturn_db_mapping_SGCSQLite._hx_class = saturn_db_mapping_SGCSQLite
_hx_classes["saturn.db.mapping.SGCSQLite"] = saturn_db_mapping_SGCSQLite


class saturn_db_mapping_SQLiteMapping:
	_hx_class_name = "saturn.db.mapping.SQLiteMapping"
	_hx_statics = ["models"]
saturn_db_mapping_SQLiteMapping._hx_class = saturn_db_mapping_SQLiteMapping
_hx_classes["saturn.db.mapping.SQLiteMapping"] = saturn_db_mapping_SQLiteMapping


class saturn_db_mapping_templates_DefaultMapping:
	_hx_class_name = "saturn.db.mapping.templates.DefaultMapping"
	_hx_fields = ["models"]
	_hx_methods = ["buildModels"]

	def __init__(self):
		self.models = None
		self.buildModels()

	def buildModels(self):
		self.models = haxe_ds_StringMap()

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.models = None
saturn_db_mapping_templates_DefaultMapping._hx_class = saturn_db_mapping_templates_DefaultMapping
_hx_classes["saturn.db.mapping.templates.DefaultMapping"] = saturn_db_mapping_templates_DefaultMapping


class saturn_db_provider_GenericRDBMSProvider(saturn_db_DefaultProvider):
	_hx_class_name = "saturn.db.provider.GenericRDBMSProvider"
	_hx_fields = ["debug", "theConnection", "modelsToProcess"]
	_hx_methods = ["setPlatform", "setUser", "generatedLinkedClone", "readModels", "_readModels", "generateQualifiedName", "getColumns", "_closeConnection", "getConnection", "_getConnection", "_getByIds", "_getObjects", "_getByValues", "getSelectorFieldConstraintSQL", "buildSqlInClause", "_getByPkeys", "_query", "_getByIdStartsWith", "limitAtEndPosition", "generateLimitClause", "columnToStringCommand", "convertComplexQuery", "_getByNamedQuery", "_update", "_insert", "cloneConfig", "_insertRecursive", "_updateRecursive", "_delete", "postConfigureModels", "parseObjectList", "dbSpecificParamPlaceholder", "getProviderType", "applyFunctions", "setUserName", "handleFileRequests", "setConnection", "_commit", "setAutoCommit", "generateUserConstraintSQL"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_DefaultProvider


	def __init__(self,models,config,autoClose):
		self.debug = None
		self.theConnection = None
		self.modelsToProcess = None
		self.modelsToProcess = 0
		self.theConnection = None
		self.debug = saturn_core_Util.debug
		super().__init__(models,config,autoClose)
		self.config = config
		self.user = saturn_core_User()
		self.user.username = Reflect.field(config,"username")
		self.user.password = Reflect.field(config,"password")
		_hx_local_0 = self.namedQueryHooks.keys()
		while _hx_local_0.hasNext():
			hook = _hx_local_0.next()
			self.debug(((("Installed hook: " + ("null" if hook is None else hook)) + "/") + Std.string(self.namedQueryHooks.h.get(hook,None))))

	def setPlatform(self):
		pass

	def setUser(self,user):
		self.debug("User called")
		super().setUser(user)

	def generatedLinkedClone(self):
		provider = super().generatedLinkedClone()
		provider.config = self.config
		provider.debug = self.debug
		provider.modelsToProcess = self.modelsToProcess
		provider.theConnection = None
		provider.user = self.user
		return provider

	def readModels(self,cb):
		_g = self
		modelClazzes = list()
		_hx_local_0 = self.theBindingMap.keys()
		while _hx_local_0.hasNext():
			modelClazz = _hx_local_0.next()
			modelClazzes.append(modelClazz)
		self.modelsToProcess = len(modelClazzes)
		def _hx_local_1(err,conn):
			if (err is not None):
				_g.debug("Error getting connection for reading models")
				_g.debug(err)
				cb(err)
			else:
				_g.debug("Querying database for model information")
				_g._readModels(modelClazzes,_g,conn,cb)
		self.getConnection(self.config,_hx_local_1)

	def _readModels(self,modelClazzes,provider,connection,cb):
		_g = self
		modelClazz = None
		modelClazz = (None if ((len(modelClazzes) == 0)) else modelClazzes.pop())
		self.debug(("Processing model: " + ("null" if modelClazz is None else modelClazz)))
		model = provider.getModelByStringName(modelClazz)
		captured_super = self.postConfigureModels
		if model.hasTableInfo():
			keyCol = model.getFirstKey_rdbms()
			priCol = model.getPrimaryKey_rdbms()
			tableName = model.getTableName()
			schemaName = model.getSchemaName()
			qName = self.generateQualifiedName(schemaName,tableName)
			def _hx_local_1(err,cols):
				if (err is not None):
					cb(err)
				else:
					provider.setSelectClause(modelClazz,((("SELECT DISTINCT " + HxOverrides.stringOrNull(",".join([python_Boot.toString1(x1,'') for x1 in cols]))) + " FROM ") + ("null" if qName is None else qName)))
					model.setInsertClause(("INSERT INTO " + ("null" if qName is None else qName)))
					model.setDeleteClause(((((("DELETE FROM " + ("null" if qName is None else qName)) + "WHERE ") + ("null" if priCol is None else priCol)) + " = ") + HxOverrides.stringOrNull(_g.dbSpecificParamPlaceholder(1))))
					model.setUpdateClause(("UPDATE " + ("null" if qName is None else qName)))
					model.setSelectKeyClause((((((("SELECT DISTINCT " + ("null" if keyCol is None else keyCol)) + ", ") + ("null" if priCol is None else priCol)) + " FROM ") + ("null" if qName is None else qName)) + " "))
					model.setColumns(cols)
					_g.modelsToProcess = (_g.modelsToProcess - 1)
					_g.debug(("Model processed: " + ("null" if modelClazz is None else modelClazz)))
					_g.debug(cols)
					if (_g.modelsToProcess == 0):
						_g.postConfigureModels()
						_g.closeConnection(connection)
						if (cb is not None):
							_g.debug("All Models have been processed (handing back control to caller callback)")
							cb(None)
					else:
						_g._readModels(modelClazzes,provider,connection,cb)
			func = _hx_local_1
			self.getColumns(connection,schemaName,tableName,func)
		elif ((len(modelClazzes) == 0) and ((self.modelsToProcess == 1))):
			self.closeConnection(connection)
			if (cb is not None):
				self.debug("All Models have been processed (handing back control to caller callback)")
				cb(None)
		else:
			_hx_local_2 = self
			_hx_local_3 = _hx_local_2.modelsToProcess
			_hx_local_2.modelsToProcess = (_hx_local_3 - 1)
			_hx_local_3
			self._readModels(modelClazzes,provider,connection,cb)

	def generateQualifiedName(self,schemaName,tableName):
		return ((("null" if schemaName is None else schemaName) + ".") + ("null" if tableName is None else tableName))

	def getColumns(self,connection,schemaName,tableName,cb):
		def _hx_local_1(err,results):
			if (err is None):
				cols = list()
				_g = 0
				while (_g < len(results)):
					row = (results[_g] if _g >= 0 and _g < len(results) else None)
					_g = (_g + 1)
					x = Reflect.field(row,"COLUMN_NAME")
					cols.append(x)
				cb(None,cols)
			else:
				cb(err,None)
		Reflect.field(connection,"execute")("select COLUMN_NAME from ALL_TAB_COLUMNS where OWNER=:1 AND TABLE_NAME=:2",[schemaName, tableName],_hx_local_1)

	def _closeConnection(self):
		self.debug("Closing connection!")
		if (self.theConnection is not None):
			self.theConnection.close()
			self.theConnection = None

	def getConnection(self,config,cb):
		_g = self
		if ((not self.autoClose) and ((self.theConnection is not None))):
			self.debug("Using existing connection")
			cb(None,self.theConnection)
			return
		def _hx_local_0(err,conn):
			_g.theConnection = conn
			cb(err,conn)
		self._getConnection(_hx_local_0)

	def _getConnection(self,cb):
		pass

	def _getByIds(self,ids,clazz,callBack):
		_g = self
		if (clazz == saturn_core_domain_FileProxy):
			self.handleFileRequests(ids,clazz,callBack)
			return
		model = self.getModel(clazz)
		selectClause = model.getSelectClause()
		keyCol = model.getFirstKey_rdbms()
		_g1 = 0
		_g2 = len(ids)
		while (_g1 < _g2):
			i = _g1
			_g1 = (_g1 + 1)
			python_internal_ArrayImpl._set(ids, i, (ids[i] if i >= 0 and i < len(ids) else None).upper())
		selectorSQL = self.getSelectorFieldConstraintSQL(clazz)
		if (selectorSQL != ""):
			selectorSQL = (" AND " + ("null" if selectorSQL is None else selectorSQL))
		def _hx_local_3(err,connection):
			if (err is not None):
				callBack(None,err)
			else:
				sql = ((((((("null" if selectClause is None else selectClause) + "  WHERE UPPER(") + HxOverrides.stringOrNull(_g.columnToStringCommand(keyCol))) + ") ") + HxOverrides.stringOrNull(_g.buildSqlInClause(len(ids)))) + " ") + ("null" if selectorSQL is None else selectorSQL))
				additionalSQL = _g.generateUserConstraintSQL(clazz)
				if (additionalSQL is not None):
					sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" AND " + ("null" if additionalSQL is None else additionalSQL)))))
				sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" ORDER BY " + ("null" if keyCol is None else keyCol)))))
				_g.debug(("SQL" + ("null" if sql is None else sql)))
				def _hx_local_2(err1,results):
					if (err1 is not None):
						callBack(None,err1)
					else:
						_g.debug("Sending results")
						callBack(results,None)
					_g.closeConnection(connection)
				try:
					connection.execute(sql,ids,_hx_local_2)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e = _hx_e1
					_g.closeConnection(connection)
					saturn_core_Util.debug(e)
					callBack(None,e)
		self.getConnection(self.config,_hx_local_3)

	def _getObjects(self,clazz,callBack):
		_g = self
		model = self.getModel(clazz)
		selectClause = model.getSelectClause()
		selectorSQL = self.getSelectorFieldConstraintSQL(clazz)
		if (selectorSQL != ""):
			selectorSQL = (" WHERE " + ("null" if selectorSQL is None else selectorSQL))
		def _hx_local_3(err,connection):
			if (err is not None):
				callBack(None,err)
			else:
				sql = ((("null" if selectClause is None else selectClause) + " ") + ("null" if selectorSQL is None else selectorSQL))
				additionalSQL = _g.generateUserConstraintSQL(clazz)
				if (additionalSQL is not None):
					sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" AND " + ("null" if additionalSQL is None else additionalSQL)))))
				sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" ORDER BY " + HxOverrides.stringOrNull(model.getFirstKey_rdbms())))))
				_g.debug(sql)
				def _hx_local_2(err1,results):
					if (err1 is not None):
						callBack(None,err1)
					else:
						callBack(results,None)
					_g.closeConnection(connection)
				try:
					connection.execute(sql,[],_hx_local_2)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e = _hx_e1
					_g.closeConnection(connection)
					saturn_core_Util.debug(e)
					callBack(None,e)
		self.getConnection(self.config,_hx_local_3)

	def _getByValues(self,values,clazz,field,callBack):
		_g = self
		if (clazz == saturn_core_domain_FileProxy):
			self.handleFileRequests(values,clazz,callBack)
			return
		model = self.getModel(clazz)
		selectClause = model.getSelectClause()
		sqlField = model.getSqlColumn(field)
		selectorSQL = self.getSelectorFieldConstraintSQL(clazz)
		if (selectorSQL != ""):
			selectorSQL = (" AND " + ("null" if selectorSQL is None else selectorSQL))
		def _hx_local_3(err,connection):
			if (err is not None):
				callBack(None,err)
			else:
				sql = ((((((("null" if selectClause is None else selectClause) + "  WHERE ") + ("null" if sqlField is None else sqlField)) + " ") + HxOverrides.stringOrNull(_g.buildSqlInClause(len(values)))) + " ") + ("null" if selectorSQL is None else selectorSQL))
				additionalSQL = _g.generateUserConstraintSQL(clazz)
				if (additionalSQL is not None):
					sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" AND " + ("null" if additionalSQL is None else additionalSQL)))))
				sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" ORDER BY " + ("null" if sqlField is None else sqlField)))))
				_g.debug(sql)
				_g.debug(values)
				def _hx_local_2(err1,results):
					if (err1 is not None):
						callBack(None,err1)
					else:
						_g.debug(((("Result count: " + Std.string(results)) + " ") + Std.string(values)))
						callBack(results,None)
					_g.closeConnection(connection)
				try:
					connection.execute(sql,values,_hx_local_2)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e = _hx_e1
					_g.closeConnection(connection)
					saturn_core_Util.debug(e)
					callBack(None,e)
		self.getConnection(self.config,_hx_local_3)

	def getSelectorFieldConstraintSQL(self,clazz):
		model = self.getModel(clazz)
		selectorField = model.getSelectorField()
		if (selectorField is not None):
			selectorValue = model.getSelectorValue()
			return (((("null" if selectorField is None else selectorField) + " = \"") + ("null" if selectorValue is None else selectorValue)) + "\"")
		else:
			return ""

	def buildSqlInClause(self,numIds,nextVal = 0,func = None):
		if (nextVal is None):
			nextVal = 0
		inClause_b = python_lib_io_StringIO()
		inClause_b.write("IN(")
		_g = 0
		while (_g < numIds):
			i = _g
			_g = (_g + 1)
			_hx_def = self.dbSpecificParamPlaceholder(((i + 1) + nextVal))
			if (func is not None):
				_hx_def = (((("null" if func is None else func) + "(") + ("null" if _hx_def is None else _hx_def)) + ")")
			inClause_b.write(Std.string(_hx_def))
			if (i != ((numIds - 1))):
				inClause_b.write(",")
		inClause_b.write(")")
		return inClause_b.getvalue()

	def _getByPkeys(self,ids,clazz,callBack):
		_g = self
		if (clazz == saturn_core_domain_FileProxy):
			self.handleFileRequests(ids,clazz,callBack)
			return
		model = self.getModel(clazz)
		selectClause = model.getSelectClause()
		keyCol = model.getPrimaryKey_rdbms()
		selectorSQL = self.getSelectorFieldConstraintSQL(clazz)
		if (selectorSQL != ""):
			selectorSQL = (" AND " + ("null" if selectorSQL is None else selectorSQL))
		def _hx_local_3(err,connection):
			if (err is not None):
				callBack(None,err)
			else:
				sql = (((((("null" if selectClause is None else selectClause) + "  WHERE ") + ("null" if keyCol is None else keyCol)) + " ") + HxOverrides.stringOrNull(_g.buildSqlInClause(len(ids)))) + ("null" if selectorSQL is None else selectorSQL))
				additionalSQL = _g.generateUserConstraintSQL(clazz)
				if (additionalSQL is not None):
					sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" AND " + ("null" if additionalSQL is None else additionalSQL)))))
				sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull((((" " + " ORDER BY ") + ("null" if keyCol is None else keyCol)))))
				_g.debug(sql)
				def _hx_local_2(err1,results):
					if (err1 is not None):
						callBack(None,err1)
					else:
						callBack(results,None)
					_g.closeConnection(connection)
				try:
					connection.execute(sql,ids,_hx_local_2)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e = _hx_e1
					_g.closeConnection(connection)
					callBack(None,e)
		self.getConnection(self.config,_hx_local_3)

	def _query(self,query,cb):
		_g = self
		def _hx_local_1(err,connection):
			if (err is not None):
				cb(None,err)
			else:
				try:
					visitor = saturn_db_query_lang_SQLVisitor(_g)
					sql = visitor.translate(query)
					_g.debug(sql)
					_g.debug(visitor.getValues())
					def _hx_local_0(err1,results):
						if (err1 is not None):
							cb(None,err1)
						else:
							results = visitor.getProcessedResults(results)
							cb(results,None)
						_g.closeConnection(connection)
					connection.execute(sql,visitor.getValues(),_hx_local_0)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e = _hx_e1
					_g.closeConnection(connection)
					_g.debug(("Error !!!!!!!!!!!!!" + Std.string(Reflect.field(e,"stack"))))
					cb(None,e)
		self.getConnection(self.config,_hx_local_1)

	def _getByIdStartsWith(self,id,field,clazz,limit,callBack):
		_g = self
		model = self.getModel(clazz)
		self.debug(("Provider class" + HxOverrides.stringOrNull(Type.getClassName(Type.getClass(self)))))
		self.debug(("Provider: " + HxOverrides.stringOrNull(model.getProviderName())))
		keyCol = None
		if (field is None):
			keyCol = model.getFirstKey_rdbms()
		elif model.isRDBMSField(field):
			keyCol = field
		busKey = model.getFirstKey_rdbms()
		priCol = model.getPrimaryKey_rdbms()
		tableName = model.getTableName()
		schemaName = model.getSchemaName()
		qName = self.generateQualifiedName(schemaName,tableName)
		selectClause = ((("SELECT DISTINCT " + ("null" if busKey is None else busKey)) + ", ") + ("null" if priCol is None else priCol))
		if ((keyCol != busKey) and ((keyCol != priCol))):
			selectClause = (("null" if selectClause is None else selectClause) + HxOverrides.stringOrNull(((", " + ("null" if keyCol is None else keyCol)))))
		selectClause = (("null" if selectClause is None else selectClause) + HxOverrides.stringOrNull(((" FROM " + ("null" if qName is None else qName)))))
		id = id.upper()
		selectorSQL = self.getSelectorFieldConstraintSQL(clazz)
		if (selectorSQL != ""):
			selectorSQL = (" AND " + ("null" if selectorSQL is None else selectorSQL))
		if (not self.limitAtEndPosition()):
			if (((limit is not None) and ((limit != 0))) and ((limit != -1))):
				selectorSQL = (("null" if selectorSQL is None else selectorSQL) + HxOverrides.stringOrNull(self.generateLimitClause(limit)))
		def _hx_local_7(err,connection):
			nonlocal id
			if (err is not None):
				callBack(None,err)
			else:
				sql = ((((((("null" if selectClause is None else selectClause) + "  WHERE UPPER(") + HxOverrides.stringOrNull(_g.columnToStringCommand(keyCol))) + ") like ") + HxOverrides.stringOrNull(_g.dbSpecificParamPlaceholder(1))) + " ") + ("null" if selectorSQL is None else selectorSQL))
				additionalSQL = _g.generateUserConstraintSQL(clazz)
				if (additionalSQL is not None):
					sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" AND " + ("null" if additionalSQL is None else additionalSQL)))))
				sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" ORDER BY " + ("null" if keyCol is None else keyCol)))))
				if _g.limitAtEndPosition():
					if (((limit is not None) and ((limit != 0))) and ((limit != -1))):
						sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(_g.generateLimitClause(limit)))
				id = (("%" + ("null" if id is None else id)) + "%")
				_g.debug(("startswith" + ("null" if sql is None else sql)))
				def _hx_local_6(err1,results):
					_g.debug(("startswith" + ("null" if err1 is None else err1)))
					if (err1 is not None):
						callBack(None,err1)
					else:
						callBack(results,None)
					_g.closeConnection(connection)
				try:
					connection.execute(sql,[id],_hx_local_6)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e = _hx_e1
					saturn_core_Util.debug(e)
					_g.closeConnection(connection)
					callBack(None,e)
		self.getConnection(self.config,_hx_local_7)

	def limitAtEndPosition(self):
		return False

	def generateLimitClause(self,limit):
		def _hx_local_2():
			def _hx_local_1():
				_hx_local_0 = None
				try:
					_hx_local_0 = int(limit)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e = _hx_e1
					_hx_local_0 = None
				return _hx_local_0
			return (" AND ROWNUM < " + Std.string(_hx_local_1()))
		return _hx_local_2()

	def columnToStringCommand(self,columnName):
		return columnName

	def convertComplexQuery(self,parameters):
		pass

	def _getByNamedQuery(self,queryId,parameters,clazz,cb):
		_g = self
		if (not hasattr(Reflect.field(self.config,"named_queries"),(("_hx_" + queryId) if (queryId in python_Boot.keywords) else (("_hx_" + queryId) if (((((len(queryId) > 2) and ((ord(queryId[0]) == 95))) and ((ord(queryId[1]) == 95))) and ((ord(queryId[(len(queryId) - 1)]) != 95)))) else queryId)))):
			cb(None,(("Query " + ("null" if queryId is None else queryId)) + " not found "))
		else:
			sql = Reflect.field(Reflect.field(self.config,"named_queries"),queryId)
			realParameters = list()
			if Std._hx_is(parameters,list):
				self.debug("Named query passed an Array")
				re = EReg("(<IN>)", "")
				def _hx_local_0():
					re.matchObj = python_lib_Re.search(re.pattern,sql)
					return (re.matchObj is not None)
				if _hx_local_0():
					sql = re.replace(sql,self.buildSqlInClause(Reflect.field(parameters,"length")))
				realParameters = parameters
			else:
				self.debug("Named query with other object type")
				dbPlaceHolderI = 0
				attributes = python_Boot.fields(parameters)
				if (len(attributes) == 0):
					cb(None,"Unknown parameter collection type")
					return
				else:
					self.debug("Named query passed object")
					re_in = EReg("^IN:", "")
					re1 = EReg("<:([^>]+)>", "")
					convertedSQL = ""
					matchMe = sql
					while (matchMe is not None):
						self.debug(("Looping: " + ("null" if matchMe is None else matchMe)))
						self.debug(("SQL: " + ("null" if convertedSQL is None else convertedSQL)))
						if re1.matchSub(matchMe,0):
							matchLeft = None
							_hx_len = re1.matchObj.start()
							matchLeft = HxString.substr(re1.matchObj.string,0,_hx_len)
							tagName = re1.matchObj.group(1)
							self.debug(("MatchLeft: " + ("null" if matchLeft is None else matchLeft)))
							self.debug(("Tag:" + ("null" if tagName is None else tagName)))
							convertedSQL = (("null" if convertedSQL is None else convertedSQL) + ("null" if matchLeft is None else matchLeft))
							if re_in.matchSub(tagName,0):
								self.debug("Found IN")
								tagName = re_in.replace(tagName,"")
								self.debug(("Real Tag Name" + ("null" if tagName is None else tagName)))
								if hasattr(parameters,(("_hx_" + tagName) if (tagName in python_Boot.keywords) else (("_hx_" + tagName) if (((((len(tagName) > 2) and ((ord(tagName[0]) == 95))) and ((ord(tagName[1]) == 95))) and ((ord(tagName[(len(tagName) - 1)]) != 95)))) else tagName))):
									self.debug("Found array")
									paramArray = Reflect.field(parameters,tagName)
									if Std._hx_is(paramArray,list):
										convertedSQL = (("null" if convertedSQL is None else convertedSQL) + HxOverrides.stringOrNull(self.buildSqlInClause(len(paramArray))))
										_g1 = 0
										_g2 = len(paramArray)
										while (_g1 < _g2):
											i = _g1
											_g1 = (_g1 + 1)
											x = (paramArray[i] if i >= 0 and i < len(paramArray) else None)
											realParameters.append(x)
									else:
										cb(None,(("Value to attribute " + ("null" if tagName is None else tagName)) + " should be an Array"))
										return
								else:
									cb(None,("Missing attribute " + ("null" if tagName is None else tagName)))
									return
							else:
								self.debug("Found non IN argument")
								if hasattr(parameters,(("_hx_" + tagName) if (tagName in python_Boot.keywords) else (("_hx_" + tagName) if (((((len(tagName) > 2) and ((ord(tagName[0]) == 95))) and ((ord(tagName[1]) == 95))) and ((ord(tagName[(len(tagName) - 1)]) != 95)))) else tagName))):
									def _hx_local_4():
										nonlocal dbPlaceHolderI
										_hx_local_3 = dbPlaceHolderI
										dbPlaceHolderI = (dbPlaceHolderI + 1)
										return _hx_local_3
									convertedSQL = (("null" if convertedSQL is None else convertedSQL) + HxOverrides.stringOrNull(self.dbSpecificParamPlaceholder(_hx_local_4())))
									value = Reflect.field(parameters,tagName)
									realParameters.append(value)
								else:
									cb(None,("Missing attribute " + ("null" if tagName is None else tagName)))
									return
							pos = re1.matchObj.end()
							matchMe = HxString.substr(re1.matchObj.string,pos,None)
							self.debug(("Found right " + ("null" if matchMe is None else matchMe)))
						else:
							convertedSQL = (("null" if convertedSQL is None else convertedSQL) + ("null" if matchMe is None else matchMe))
							matchMe = None
							self.debug("Terminating while")
					sql = convertedSQL
			self.debug(("SQL: " + ("null" if sql is None else sql)))
			self.debug(("Parameters: " + Std.string(realParameters)))
			def _hx_local_8(err,connection):
				if (err is not None):
					cb(None,err)
				else:
					_g.debug(sql)
					def _hx_local_7(err1,results):
						_g.debug("Named query returning")
						if (err1 is not None):
							cb(None,err1)
						else:
							cb(results,None)
						_g.closeConnection(connection)
					try:
						connection.execute(sql,realParameters,_hx_local_7)
					except Exception as _hx_e:
						_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
						e = _hx_e1
						_g.closeConnection(connection)
						cb(None,e)
			self.getConnection(self.config,_hx_local_8)

	def _update(self,attributeMaps,className,cb):
		_g = self
		self.applyFunctions(attributeMaps,className)
		def _hx_local_0(err,connection):
			if (err is not None):
				cb(err)
			else:
				clazz = Type.resolveClass(className)
				model = _g.getModel(clazz)
				_g._updateRecursive(attributeMaps,model,cb,connection)
		self.getConnection(self.config,_hx_local_0)

	def _insert(self,attributeMaps,className,cb):
		_g = self
		self.applyFunctions(attributeMaps,className)
		def _hx_local_0(err,connection):
			if (err is not None):
				cb(err)
			else:
				clazz = Type.resolveClass(className)
				model = _g.getModel(clazz)
				_g._insertRecursive(attributeMaps,model,cb,connection)
		self.getConnection(self.config,_hx_local_0)

	def cloneConfig(self):
		cloneData = haxe_Serializer.run(self.config)
		unserObj = haxe_Unserializer.run(cloneData)
		return unserObj

	def _insertRecursive(self,attributeMaps,model,cb,connection):
		_g = self
		self.debug(("Inserting  " + HxOverrides.stringOrNull(Type.getClassName(model.getClass()))))
		insertClause = model.getInsertClause()
		cols = model.getColumnSet()
		attributeMap = None
		attributeMap = (None if ((len(attributeMaps) == 0)) else attributeMaps.pop())
		colStr = StringBuf()
		valList = list()
		valStr = StringBuf()
		i = 0
		hasWork = False
		_hx_local_1 = attributeMap.keys()
		while _hx_local_1.hasNext():
			attribute = _hx_local_1.next()
			if ((cols is not None) and attribute in cols.h):
				if (i > 0):
					colStr.b.write(",")
					valStr.b.write(",")
				i = (i + 1)
				colStr.b.write(Std.string(attribute))
				x = self.dbSpecificParamPlaceholder(i)
				valStr.b.write(Std.string(x))
				val = attributeMap.h.get(attribute,None)
				if ((val == "") and (not Std._hx_is(val,Int))):
					val = None
				x1 = val
				valList.append(x1)
				hasWork = True
		if model.isPolymorph():
			i = (i + 1)
			x2 = ("," + HxOverrides.stringOrNull(model.getSelectorField()))
			colStr.b.write(Std.string(x2))
			x3 = ("," + HxOverrides.stringOrNull(self.dbSpecificParamPlaceholder(i)))
			valStr.b.write(Std.string(x3))
			x4 = model.getSelectorValue()
			valList.append(x4)
			hasWork = True
		if (not hasWork):
			self.debug("No work - returning error")
			cb(("Insert failure: no mapped fields for " + HxOverrides.stringOrNull(Type.getClassName(model.getClass()))))
			return
		sql = (((((("null" if insertClause is None else insertClause) + " (") + Std.string(colStr)) + ") VALUES(") + Std.string(valStr)) + ")")
		keyCol = model.getFirstKey_rdbms()
		keyVal = attributeMap.h.get(keyCol,None)
		self.debug(("MAP:" + HxOverrides.stringOrNull(attributeMap.toString())))
		self.debug(("SQL" + ("null" if sql is None else sql)))
		self.debug(("Values" + Std.string(valList)))
		def _hx_local_3(err,results):
			if (err is not None):
				error = _hx_AnonObject({'message': StringTools.replace(Std.string(err),"\n",""), 'source': keyVal})
				cb(error)
				_g.closeConnection(connection)
			elif (len(attributeMaps) == 0):
				cb(None)
				_g.closeConnection(connection)
			else:
				_g._insertRecursive(attributeMaps,model,cb,connection)
		try:
			connection.execute(sql,valList,_hx_local_3)
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			e = _hx_e1
			self.closeConnection(connection)
			error1 = _hx_AnonObject({'message': StringTools.replace(Std.string(e),"\n",""), 'source': keyVal})
			cb(error1)

	def _updateRecursive(self,attributeMaps,model,cb,connection):
		_g = self
		updateClause = model.getUpdateClause()
		cols = model.getColumnSet()
		attributeMap = None
		attributeMap = (None if ((len(attributeMaps) == 0)) else attributeMaps.pop())
		valList = list()
		updateStr = StringBuf()
		i = 0
		_hx_local_1 = attributeMap.keys()
		while _hx_local_1.hasNext():
			attribute = _hx_local_1.next()
			if (attribute in cols.h and ((attribute != model.getPrimaryKey_rdbms()))):
				if (attribute == "DATESTAMP"):
					continue
				if (i > 0):
					updateStr.b.write(",")
				i = (i + 1)
				x = ((("null" if attribute is None else attribute) + " = ") + HxOverrides.stringOrNull(self.dbSpecificParamPlaceholder(i)))
				updateStr.b.write(Std.string(x))
				val = attributeMap.h.get(attribute,None)
				if (val == ""):
					val = None
				x1 = val
				valList.append(x1)
		i = (i + 1)
		keyCol = model.getPrimaryKey_rdbms()
		sql = ((((((("null" if updateClause is None else updateClause) + " SET ") + Std.string(updateStr)) + " WHERE ") + ("null" if keyCol is None else keyCol)) + " = ") + HxOverrides.stringOrNull(self.dbSpecificParamPlaceholder(i)))
		additionalSQL = self.generateUserConstraintSQL(model.getClass())
		if (additionalSQL is not None):
			sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" AND " + ("null" if additionalSQL is None else additionalSQL)))))
		x2 = attributeMap.h.get(keyCol,None)
		valList.append(x2)
		self.debug(("SQL" + ("null" if sql is None else sql)))
		self.debug(("Values" + Std.string(valList)))
		def _hx_local_4(err,results):
			if (err is not None):
				saturn_core_Util.debug(("Error: " + ("null" if err is None else err)))
				cb(err)
				_g.closeConnection(connection)
			elif (len(attributeMaps) == 0):
				cb(None)
				_g.closeConnection(connection)
			else:
				_g._updateRecursive(attributeMaps,model,cb,connection)
		try:
			connection.execute(sql,valList,_hx_local_4)
		except Exception as _hx_e:
			_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
			e = _hx_e1
			self.closeConnection(connection)
			cb(e)

	def _delete(self,attributeMaps,className,cb):
		_g = self
		model = self.getModelByStringName(className)
		priField = model.getPrimaryKey()
		priFieldSql = model.getPrimaryKey_rdbms()
		pkeys = list()
		_g1 = 0
		while (_g1 < len(attributeMaps)):
			attributeMap = (attributeMaps[_g1] if _g1 >= 0 and _g1 < len(attributeMaps) else None)
			_g1 = (_g1 + 1)
			x = attributeMap.h.get(priFieldSql,None)
			pkeys.append(x)
		d = attributeMaps
		sql = ((((("DELETE FROM " + HxOverrides.stringOrNull(self.generateQualifiedName(model.getSchemaName(),model.getTableName()))) + " WHERE ") + ("null" if priFieldSql is None else priFieldSql)) + " ") + HxOverrides.stringOrNull(self.buildSqlInClause(len(pkeys))))
		additionalSQL = self.generateUserConstraintSQL(model.getClass())
		if (additionalSQL is not None):
			sql = (("null" if sql is None else sql) + HxOverrides.stringOrNull(((" AND " + ("null" if additionalSQL is None else additionalSQL)))))
		def _hx_local_3(err,connection):
			if (err is not None):
				cb(err)
			else:
				def _hx_local_2(err1,results):
					if (err1 is not None):
						saturn_core_Util.debug(("Error: " + ("null" if err1 is None else err1)))
						cb(err1)
						_g.closeConnection(connection)
					else:
						cb(None)
				try:
					connection.execute(sql,pkeys,_hx_local_2)
				except Exception as _hx_e:
					_hx_e1 = _hx_e.val if isinstance(_hx_e, _HxException) else _hx_e
					e = _hx_e1
					_g.closeConnection(connection)
					cb(e)
		self.getConnection(self.config,_hx_local_3)

	def postConfigureModels(self):
		super().postConfigureModels()

	def parseObjectList(self,data):
		return None

	def dbSpecificParamPlaceholder(self,i):
		return (":" + Std.string(i))

	def getProviderType(self):
		return "ORACLE"

	def applyFunctions(self,attributeMaps,className):
		context = self.user
		model = self.getModelByStringName(className)
		functions = model.getAutoFunctions()
		if (functions is not None):
			_hx_local_1 = functions.keys()
			while _hx_local_1.hasNext():
				field = _hx_local_1.next()
				functionString = functions.h.get(field,None)
				func = None
				if (functionString == "insert.username"):
					func = self.setUserName
				else:
					continue
				_g = 0
				while (_g < len(attributeMaps)):
					attributeMap = (attributeMaps[_g] if _g >= 0 and _g < len(attributeMaps) else None)
					_g = (_g + 1)
					if field in attributeMap.h:
						value = Reflect.callMethod(self,func,[attributeMap.h.get(field,None), context])
						value1 = value
						attributeMap.h[field] = value1
		return attributeMaps

	def setUserName(self,value,context = None):
		if ((context is not None) and ((Reflect.field(context,"username") is not None))):
			return Reflect.field(Reflect.field(context,"username"),"toUpperCase")()
		else:
			return value

	def handleFileRequests(self,values,clazz,callBack):
		pass

	def setConnection(self,conn):
		self.theConnection = conn

	def _commit(self,cb):
		def _hx_local_0(err,connection):
			if (err is not None):
				cb(err)
			else:
				connection.commit(cb)
		self.getConnection(self.config,_hx_local_0)

	def setAutoCommit(self,autoCommit,cb):
		def _hx_local_0(err,conn):
			if (err is None):
				conn.setAutoCommit(autoCommit)
				cb(None)
			else:
				cb(err)
		self.getConnection(self.config,_hx_local_0)

	def generateUserConstraintSQL(self,clazz):
		model = self.getModel(clazz)
		publicConstraintField = model.getPublicConstraintField()
		userConstraintField = model.getUserConstraintField()
		sql = None
		if (publicConstraintField is not None):
			columnName = model.getSqlColumn(publicConstraintField)
			sql = ((" " + ("null" if columnName is None else columnName)) + " = 'yes' ")
		if (userConstraintField is not None):
			inBlock = False
			if (sql is not None):
				sql = (("(" + ("null" if sql is None else sql)) + " OR ")
				inBlock = True
			columnName1 = model.getSqlColumn(userConstraintField)
			def _hx_local_0():
				_this = self.getUser().username
				return _this.upper()
			sql = ((((("null" if sql is None else sql) + ("null" if columnName1 is None else columnName1)) + " = '") + HxOverrides.stringOrNull(_hx_local_0())) + "'")
			if inBlock:
				sql = (("null" if sql is None else sql) + " ) ")
		return sql

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.debug = None
		_hx_o.theConnection = None
		_hx_o.modelsToProcess = None
saturn_db_provider_GenericRDBMSProvider._hx_class = saturn_db_provider_GenericRDBMSProvider
_hx_classes["saturn.db.provider.GenericRDBMSProvider"] = saturn_db_provider_GenericRDBMSProvider


class saturn_db_provider_hooks_ExternalJsonHook:
	_hx_class_name = "saturn.db.provider.hooks.ExternalJsonHook"
	_hx_statics = ["run"]

	@staticmethod
	def run(query,params,clazz,cb,hookConfig):
		saturn_core_Util.debug("Running external command")
		if (hookConfig is None):
			cb(None,"Hook configuration is missing")
			return
		program = None
		if hasattr(hookConfig,(("_hx_" + "program") if ("program" in python_Boot.keywords) else (("_hx_" + "program") if (((((len("program") > 2) and ((ord("program"[0]) == 95))) and ((ord("program"[1]) == 95))) and ((ord("program"[(len("program") - 1)]) != 95)))) else "program"))):
			program = Reflect.field(hookConfig,"program")
		else:
			cb(None,"Invalid configuration, program field missing")
			return
		progArguments = list()
		if hasattr(hookConfig,(("_hx_" + "arguments") if ("arguments" in python_Boot.keywords) else (("_hx_" + "arguments") if (((((len("arguments") > 2) and ((ord("arguments"[0]) == 95))) and ((ord("arguments"[1]) == 95))) and ((ord("arguments"[(len("arguments") - 1)]) != 95)))) else "arguments"))):
			localprogArguments = Reflect.field(hookConfig,"arguments")
			_g = 0
			while (_g < len(localprogArguments)):
				arg = (localprogArguments[_g] if _g >= 0 and _g < len(localprogArguments) else None)
				_g = (_g + 1)
				progArguments.append(arg)
		config = (params[0] if 0 < len(params) else None)
saturn_db_provider_hooks_ExternalJsonHook._hx_class = saturn_db_provider_hooks_ExternalJsonHook
_hx_classes["saturn.db.provider.hooks.ExternalJsonHook"] = saturn_db_provider_hooks_ExternalJsonHook


class saturn_db_provider_hooks_RawSQLHook:
	_hx_class_name = "saturn.db.provider.hooks.RawSQLHook"
	_hx_statics = ["run"]

	@staticmethod
	def run(query,params,clazz,cb,hookConfig):
		sql = (params[0] if 0 < len(params) else None)
		args = (params[1] if 1 < len(params) else None)
		def _hx_local_1(err,conn):
			def _hx_local_0(err1,results):
				cb(results,err1)
			Reflect.field(conn,"execute")(sql,args,_hx_local_0)
		saturn_core_Util.getProvider().getConnection(None,_hx_local_1)
saturn_db_provider_hooks_RawSQLHook._hx_class = saturn_db_provider_hooks_RawSQLHook
_hx_classes["saturn.db.provider.hooks.RawSQLHook"] = saturn_db_provider_hooks_RawSQLHook


class saturn_db_query_lang_Token:
	_hx_class_name = "saturn.db.query_lang.Token"
	_hx_fields = ["tokens", "name"]
	_hx_methods = ["as", "getTokens", "setTokens", "addToken", "field", "add", "removeToken", "like", "concat", "substr", "instr", "max", "length", "plus", "minus", "getClassList", "or"]

	def __init__(self,tokens = None):
		self.tokens = None
		self.name = None
		self.tokens = tokens
		if (self.tokens is not None):
			_g1 = 0
			_g = len(self.tokens)
			while (_g1 < _g):
				i = _g1
				_g1 = (_g1 + 1)
				value = (self.tokens[i] if i >= 0 and i < len(self.tokens) else None)
				if (value is not None):
					if (not Std._hx_is(value,saturn_db_query_lang_Token)):
						python_internal_ArrayImpl._set(self.tokens, i, saturn_db_query_lang_Value(value))

	def _hx_as(self,name):
		self.name = name
		return self

	def getTokens(self):
		return self.tokens

	def setTokens(self,tokens):
		self.tokens = tokens

	def addToken(self,token):
		if (self.tokens is None):
			self.tokens = list()
		_this = self.tokens
		_this.append(token)
		return self

	def field(self,clazz,attributeName,clazzAlias = None):
		f = saturn_db_query_lang_Field(clazz, attributeName, clazzAlias)
		self.add(f)
		return f

	def add(self,token):
		if Std._hx_is(token,saturn_db_query_lang_Operator):
			n = saturn_db_query_lang_Token()
			n.add(self)
			_this = n.tokens
			_this.append(token)
			return n
		else:
			return self.addToken(token)

	def removeToken(self,token):
		python_internal_ArrayImpl.remove(self.tokens,token)

	def like(self,token = None):
		l = saturn_db_query_lang_Like()
		if (token is not None):
			l.add(token)
		return self.add(l)

	def concat(self,token = None):
		c = saturn_db_query_lang_Concat(token)
		return self.add(c)

	def substr(self,position,length):
		return saturn_db_query_lang_Substr(self, position, length)

	def instr(self,substring,position = None,occurrence = None):
		return saturn_db_query_lang_Instr(self, substring, position, occurrence)

	def max(self):
		return saturn_db_query_lang_Max(self)

	def length(self):
		return saturn_db_query_lang_Length(self)

	def plus(self,token = None):
		c = saturn_db_query_lang_Plus(token)
		return self.add(c)

	def minus(self,token = None):
		c = saturn_db_query_lang_Minus(token)
		return self.add(c)

	def getClassList(self):
		_hx_list = list()
		tokens = self.getTokens()
		if ((tokens is not None) and ((len(tokens) > 0))):
			_g = 0
			while (_g < len(tokens)):
				token = (tokens[_g] if _g >= 0 and _g < len(tokens) else None)
				_g = (_g + 1)
				if Std._hx_is(token,saturn_db_query_lang_ClassToken):
					cToken = None
					def _hx_local_0():
						_hx_local_1 = token
						if Std._hx_is(_hx_local_1,saturn_db_query_lang_ClassToken):
							_hx_local_1
						else:
							raise _HxException("Class cast error")
						return _hx_local_1
					cToken = _hx_local_0()
					if (cToken.getClass() is not None):
						x = cToken.getClass()
						_hx_list.append(x)
				else:
					list2 = token.getClassList()
					_g1 = 0
					while (_g1 < len(list2)):
						item = (list2[_g1] if _g1 >= 0 and _g1 < len(list2) else None)
						_g1 = (_g1 + 1)
						_hx_list.append(item)
		return _hx_list

	def _hx_or(self):
		self.add(saturn_db_query_lang_Or())

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.tokens = None
		_hx_o.name = None
saturn_db_query_lang_Token._hx_class = saturn_db_query_lang_Token
_hx_classes["saturn.db.query_lang.Token"] = saturn_db_query_lang_Token


class saturn_db_query_lang_Operator(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Operator"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,token = None):
		if (token is not None):
			super().__init__([token])
		else:
			super().__init__(None)
saturn_db_query_lang_Operator._hx_class = saturn_db_query_lang_Operator
_hx_classes["saturn.db.query_lang.Operator"] = saturn_db_query_lang_Operator


class saturn_db_query_lang_And(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.And"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_And._hx_class = saturn_db_query_lang_And
_hx_classes["saturn.db.query_lang.And"] = saturn_db_query_lang_And


class saturn_db_query_lang_ClassToken(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.ClassToken"
	_hx_fields = ["clazz"]
	_hx_methods = ["getClass", "setClass"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,clazz):
		self.clazz = None
		self.setClass(clazz)
		super().__init__(None)

	def getClass(self):
		return self.clazz

	def setClass(self,clazz):
		if Std._hx_is(clazz,Class):
			c = None
			def _hx_local_0():
				_hx_local_0 = clazz
				if Std._hx_is(_hx_local_0,Class):
					_hx_local_0
				else:
					raise _HxException("Class cast error")
				return _hx_local_0
			c = _hx_local_0()
			self.clazz = Type.getClassName(c)
		else:
			self.clazz = clazz

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.clazz = None
saturn_db_query_lang_ClassToken._hx_class = saturn_db_query_lang_ClassToken
_hx_classes["saturn.db.query_lang.ClassToken"] = saturn_db_query_lang_ClassToken


class saturn_db_query_lang_Concat(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.Concat"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,value = None):
		if (value is None):
			super().__init__(None)
		else:
			super().__init__(value)
saturn_db_query_lang_Concat._hx_class = saturn_db_query_lang_Concat
_hx_classes["saturn.db.query_lang.Concat"] = saturn_db_query_lang_Concat


class saturn_db_query_lang_Function(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Function"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,tokens = None):
		super().__init__(tokens)
saturn_db_query_lang_Function._hx_class = saturn_db_query_lang_Function
_hx_classes["saturn.db.query_lang.Function"] = saturn_db_query_lang_Function


class saturn_db_query_lang_Count(saturn_db_query_lang_Function):
	_hx_class_name = "saturn.db.query_lang.Count"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Function


	def __init__(self,token):
		super().__init__([token])
saturn_db_query_lang_Count._hx_class = saturn_db_query_lang_Count
_hx_classes["saturn.db.query_lang.Count"] = saturn_db_query_lang_Count


class saturn_db_query_lang_EndBlock(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.EndBlock"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_EndBlock._hx_class = saturn_db_query_lang_EndBlock
_hx_classes["saturn.db.query_lang.EndBlock"] = saturn_db_query_lang_EndBlock


class saturn_db_query_lang_Equals(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.Equals"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,token = None):
		super().__init__(token)
saturn_db_query_lang_Equals._hx_class = saturn_db_query_lang_Equals
_hx_classes["saturn.db.query_lang.Equals"] = saturn_db_query_lang_Equals


class saturn_db_query_lang_Field(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Field"
	_hx_fields = ["clazz", "clazzAlias", "attributeName"]
	_hx_methods = ["getClass", "setClass", "getAttributeName", "setAttributeName"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,clazz,attributeName,clazzAlias = None):
		self.clazz = None
		self.clazzAlias = None
		self.attributeName = None
		self.setClass(clazz)
		self.attributeName = attributeName
		self.clazzAlias = clazzAlias
		super().__init__(None)

	def getClass(self):
		return self.clazz

	def setClass(self,clazz):
		if Std._hx_is(clazz,Class):
			c = None
			def _hx_local_0():
				_hx_local_0 = clazz
				if Std._hx_is(_hx_local_0,Class):
					_hx_local_0
				else:
					raise _HxException("Class cast error")
				return _hx_local_0
			c = _hx_local_0()
			self.clazz = Type.getClassName(c)
		else:
			self.clazz = clazz

	def getAttributeName(self):
		return self.attributeName

	def setAttributeName(self,name):
		self.attributeName = name

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.clazz = None
		_hx_o.clazzAlias = None
		_hx_o.attributeName = None
saturn_db_query_lang_Field._hx_class = saturn_db_query_lang_Field
_hx_classes["saturn.db.query_lang.Field"] = saturn_db_query_lang_Field


class saturn_db_query_lang_From(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.From"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_From._hx_class = saturn_db_query_lang_From
_hx_classes["saturn.db.query_lang.From"] = saturn_db_query_lang_From


class saturn_db_query_lang_GreaterThan(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.GreaterThan"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,token = None):
		super().__init__(token)
saturn_db_query_lang_GreaterThan._hx_class = saturn_db_query_lang_GreaterThan
_hx_classes["saturn.db.query_lang.GreaterThan"] = saturn_db_query_lang_GreaterThan


class saturn_db_query_lang_GreaterThanOrEqualTo(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.GreaterThanOrEqualTo"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,token = None):
		super().__init__(token)
saturn_db_query_lang_GreaterThanOrEqualTo._hx_class = saturn_db_query_lang_GreaterThanOrEqualTo
_hx_classes["saturn.db.query_lang.GreaterThanOrEqualTo"] = saturn_db_query_lang_GreaterThanOrEqualTo


class saturn_db_query_lang_Group(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Group"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_Group._hx_class = saturn_db_query_lang_Group
_hx_classes["saturn.db.query_lang.Group"] = saturn_db_query_lang_Group


class saturn_db_query_lang_In(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.In"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,token = None):
		super().__init__(token)
saturn_db_query_lang_In._hx_class = saturn_db_query_lang_In
_hx_classes["saturn.db.query_lang.In"] = saturn_db_query_lang_In


class saturn_db_query_lang_Instr(saturn_db_query_lang_Function):
	_hx_class_name = "saturn.db.query_lang.Instr"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Function


	def __init__(self,value,substring,position = None,occurrence = None):
		if (position is None):
			position = saturn_db_query_lang_Value(1)
		if (occurrence is None):
			occurrence = saturn_db_query_lang_Value(1)
		super().__init__([value, substring, position, occurrence])
saturn_db_query_lang_Instr._hx_class = saturn_db_query_lang_Instr
_hx_classes["saturn.db.query_lang.Instr"] = saturn_db_query_lang_Instr


class saturn_db_query_lang_IsNotNull(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.IsNotNull"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_IsNotNull._hx_class = saturn_db_query_lang_IsNotNull
_hx_classes["saturn.db.query_lang.IsNotNull"] = saturn_db_query_lang_IsNotNull


class saturn_db_query_lang_IsNull(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.IsNull"
	_hx_fields = ["empty"]
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self):
		self.empty = None
		self.empty = "NULL"
		super().__init__(None)

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.empty = None
saturn_db_query_lang_IsNull._hx_class = saturn_db_query_lang_IsNull
_hx_classes["saturn.db.query_lang.IsNull"] = saturn_db_query_lang_IsNull


class saturn_db_query_lang_Length(saturn_db_query_lang_Function):
	_hx_class_name = "saturn.db.query_lang.Length"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Function


	def __init__(self,value):
		super().__init__([value])
saturn_db_query_lang_Length._hx_class = saturn_db_query_lang_Length
_hx_classes["saturn.db.query_lang.Length"] = saturn_db_query_lang_Length


class saturn_db_query_lang_LessThan(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.LessThan"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,token = None):
		super().__init__(token)
saturn_db_query_lang_LessThan._hx_class = saturn_db_query_lang_LessThan
_hx_classes["saturn.db.query_lang.LessThan"] = saturn_db_query_lang_LessThan


class saturn_db_query_lang_LessThanOrEqualTo(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.LessThanOrEqualTo"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,token = None):
		super().__init__(token)
saturn_db_query_lang_LessThanOrEqualTo._hx_class = saturn_db_query_lang_LessThanOrEqualTo
_hx_classes["saturn.db.query_lang.LessThanOrEqualTo"] = saturn_db_query_lang_LessThanOrEqualTo


class saturn_db_query_lang_Like(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.Like"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_Like._hx_class = saturn_db_query_lang_Like
_hx_classes["saturn.db.query_lang.Like"] = saturn_db_query_lang_Like


class saturn_db_query_lang_Limit(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Limit"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,limit):
		super().__init__([limit])
saturn_db_query_lang_Limit._hx_class = saturn_db_query_lang_Limit
_hx_classes["saturn.db.query_lang.Limit"] = saturn_db_query_lang_Limit


class saturn_db_query_lang_Max(saturn_db_query_lang_Function):
	_hx_class_name = "saturn.db.query_lang.Max"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Function


	def __init__(self,value):
		super().__init__([value])
saturn_db_query_lang_Max._hx_class = saturn_db_query_lang_Max
_hx_classes["saturn.db.query_lang.Max"] = saturn_db_query_lang_Max


class saturn_db_query_lang_Minus(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.Minus"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,value = None):
		if (value is None):
			super().__init__(None)
		else:
			super().__init__(value)
saturn_db_query_lang_Minus._hx_class = saturn_db_query_lang_Minus
_hx_classes["saturn.db.query_lang.Minus"] = saturn_db_query_lang_Minus


class saturn_db_query_lang_NotEquals(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.NotEquals"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,token = None):
		super().__init__(token)
saturn_db_query_lang_NotEquals._hx_class = saturn_db_query_lang_NotEquals
_hx_classes["saturn.db.query_lang.NotEquals"] = saturn_db_query_lang_NotEquals


class saturn_db_query_lang_Or(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.Or"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_Or._hx_class = saturn_db_query_lang_Or
_hx_classes["saturn.db.query_lang.Or"] = saturn_db_query_lang_Or


class saturn_db_query_lang_OrderBy(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.OrderBy"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_OrderBy._hx_class = saturn_db_query_lang_OrderBy
_hx_classes["saturn.db.query_lang.OrderBy"] = saturn_db_query_lang_OrderBy


class saturn_db_query_lang_OrderByItem(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.OrderByItem"
	_hx_fields = ["descending"]
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,token,descending = False):
		if (descending is None):
			descending = False
		self.descending = None
		self.descending = False
		self.descending = descending
		super().__init__([token])

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.descending = None
saturn_db_query_lang_OrderByItem._hx_class = saturn_db_query_lang_OrderByItem
_hx_classes["saturn.db.query_lang.OrderByItem"] = saturn_db_query_lang_OrderByItem


class saturn_db_query_lang_Plus(saturn_db_query_lang_Operator):
	_hx_class_name = "saturn.db.query_lang.Plus"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Operator


	def __init__(self,value = None):
		if (value is None):
			super().__init__(None)
		else:
			super().__init__(value)
saturn_db_query_lang_Plus._hx_class = saturn_db_query_lang_Plus
_hx_classes["saturn.db.query_lang.Plus"] = saturn_db_query_lang_Plus


class saturn_db_query_lang_Query(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Query"
	_hx_fields = ["selectToken", "fromToken", "whereToken", "groupToken", "orderToken", "provider", "rawResults", "pageOn", "pageSize", "lastPagedRowValue", "results", "error"]
	_hx_methods = ["setPageOnToken", "getPageOnToken", "setLastPagedRowValue", "getLastPagedRowValue", "setPageSize", "getPageSize", "isPaging", "configurePaging", "fetchRawResults", "bindResults", "getTokens", "or", "and", "equals", "select", "getSelect", "getFrom", "getWhere", "getGroup", "clone", "serialise", "__getstate__", "run", "getSelectClassList", "unbindFields", "addClassToken", "get", "addExample", "getResults", "hasResults", "getError"]
	_hx_statics = ["deserialise", "deserialiseToken", "startsWith", "getByExample"]
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,provider):
		self.selectToken = None
		self.fromToken = None
		self.whereToken = None
		self.groupToken = None
		self.orderToken = None
		self.provider = None
		self.rawResults = None
		self.pageOn = None
		self.pageSize = None
		self.lastPagedRowValue = None
		self.results = None
		self.error = None
		super().__init__(None)
		self.provider = provider
		self.selectToken = saturn_db_query_lang_Select()
		self.whereToken = saturn_db_query_lang_Where()
		self.fromToken = saturn_db_query_lang_From()
		self.groupToken = saturn_db_query_lang_Group()
		self.orderToken = saturn_db_query_lang_OrderBy()

	def setPageOnToken(self,t):
		self.pageOn = t

	def getPageOnToken(self):
		return self.pageOn

	def setLastPagedRowValue(self,t):
		self.lastPagedRowValue = t

	def getLastPagedRowValue(self):
		return self.lastPagedRowValue

	def setPageSize(self,t):
		self.pageSize = t

	def getPageSize(self):
		return self.pageSize

	def isPaging(self):
		return ((self.pageOn is not None) and ((self.pageSize is not None)))

	def configurePaging(self,pageOn,pageSize):
		self.pageOn = pageOn
		self.pageSize = pageSize

	def fetchRawResults(self):
		self.rawResults = True

	def bindResults(self):
		return (not self.rawResults)

	def getTokens(self):
		tokens = list()
		checkTokens = [self.selectToken, self.whereToken]
		_g = 0
		while (_g < len(checkTokens)):
			token = (checkTokens[_g] if _g >= 0 and _g < len(checkTokens) else None)
			_g = (_g + 1)
			self.addClassToken(token)
		if (self.fromToken.getTokens() is not None):
			seen = haxe_ds_StringMap()
			tokens1 = list()
			_g1 = 0
			_g11 = self.fromToken.getTokens()
			while (_g1 < len(_g11)):
				token1 = (_g11[_g1] if _g1 >= 0 and _g1 < len(_g11) else None)
				_g1 = (_g1 + 1)
				if Std._hx_is(token1,saturn_db_query_lang_ClassToken):
					cToken = None
					def _hx_local_0():
						_hx_local_2 = token1
						if Std._hx_is(_hx_local_2,saturn_db_query_lang_ClassToken):
							_hx_local_2
						else:
							raise _HxException("Class cast error")
						return _hx_local_2
					cToken = _hx_local_0()
					if (cToken.getClass() is not None):
						clazzName = cToken.getClass()
						if (not clazzName in seen.h):
							tokens1.append(cToken)
							seen.h[clazzName] = ""
					else:
						tokens1.append(cToken)
				else:
					tokens1.append(token1)
			self.fromToken.setTokens(tokens1)
			saturn_core_Util.print(("Num targets" + Std.string(len(self.fromToken.getTokens()))))
		tokens.append(self.selectToken)
		tokens.append(self.fromToken)
		if ((self.whereToken.getTokens() is not None) and ((len(self.whereToken.getTokens()) > 0))):
			tokens.append(self.whereToken)
			if (self.isPaging() and ((self.lastPagedRowValue is not None))):
				x = saturn_db_query_lang_And()
				tokens.append(x)
				tokens.append(self.pageOn)
				x1 = saturn_db_query_lang_GreaterThan()
				tokens.append(x1)
				tokens.append(self.lastPagedRowValue)
		if ((self.groupToken.getTokens() is not None) and ((len(self.groupToken.getTokens()) > 0))):
			tokens.append(self.groupToken)
		if ((self.orderToken.getTokens() is not None) and ((len(self.orderToken.getTokens()) > 0))):
			tokens.append(self.orderToken)
		if self.isPaging():
			x2 = saturn_db_query_lang_OrderBy()
			tokens.append(x2)
			x3 = saturn_db_query_lang_OrderByItem(self.pageOn)
			tokens.append(x3)
			x4 = saturn_db_query_lang_Limit(self.pageSize)
			tokens.append(x4)
		if ((self.tokens is not None) and ((len(self.tokens) > 0))):
			_g2 = 0
			_g12 = self.tokens
			while (_g2 < len(_g12)):
				token2 = (_g12[_g2] if _g2 >= 0 and _g2 < len(_g12) else None)
				_g2 = (_g2 + 1)
				tokens.append(token2)
		return tokens

	def _hx_or(self):
		self.getWhere().addToken(saturn_db_query_lang_Or())

	def _hx_and(self):
		self.getWhere().addToken(saturn_db_query_lang_And())

	def equals(self,clazz,field,value):
		self.getWhere().addToken(saturn_db_query_lang_Field(clazz, field))
		self.getWhere().addToken(saturn_db_query_lang_Equals())
		self.getWhere().addToken(saturn_db_query_lang_Value(value))

	def select(self,clazz,field):
		self.getSelect().addToken(saturn_db_query_lang_Field(clazz, field))

	def getSelect(self):
		return self.selectToken

	def getFrom(self):
		return self.fromToken

	def getWhere(self):
		return self.whereToken

	def getGroup(self):
		return self.groupToken

	def clone(self):
		_hx_str = self.serialise()
		return saturn_db_query_lang_Query.deserialise(_hx_str)

	def serialise(self):
		keepMe = self.provider
		self.provider = None
		import pickle
		newMe = pickle.dumps(self)
		self.provider = keepMe
		return newMe

	def __getstate__(self):
		state = dict(self.__dict__)
		del state['provider']
		return state

	def run(self,cb = None):
		_g = self
		clone = self.clone()
		clone.provider = None
		clone.getTokens()
		def _hx_local_1(objs,err):
			if (((err is None) and ((len(objs) > 0))) and _g.isPaging()):
				fieldName = None
				if (_g.pageOn.name is not None):
					fieldName = _g.pageOn.name
				elif Std._hx_is(_g.pageOn,saturn_db_query_lang_Field):
					fToken = None
					def _hx_local_0():
						_hx_local_0 = _g.pageOn
						if Std._hx_is(_hx_local_0,saturn_db_query_lang_Field):
							_hx_local_0
						else:
							raise _HxException("Class cast error")
						return _hx_local_0
					fToken = _hx_local_0()
					fieldName = fToken.getAttributeName()
				if (fieldName is None):
					err = "Unable to determine value of last paged row"
				else:
					_g.setLastPagedRowValue(saturn_db_query_lang_Value(Reflect.field(python_internal_ArrayImpl._get(objs, (len(objs) - 1)),fieldName)))
			_g.results = objs
			_g.error = err
			if (_g.error is not None):
				raise _HxException(_g.error)
			if (cb is not None):
				cb(objs,err)
		self.provider.query(clone,_hx_local_1)

	def getSelectClassList(self):
		_hx_set = haxe_ds_StringMap()
		_g = 0
		_g1 = self.selectToken.getTokens()
		while (_g < len(_g1)):
			token = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
			_g = (_g + 1)
			if Std._hx_is(token,saturn_db_query_lang_Field):
				cToken = None
				def _hx_local_0():
					_hx_local_1 = token
					if Std._hx_is(_hx_local_1,saturn_db_query_lang_Field):
						_hx_local_1
					else:
						raise _HxException("Class cast error")
					return _hx_local_1
				cToken = _hx_local_0()
				clazz = cToken.getClass()
				if (clazz is not None):
					_hx_set.h[clazz] = clazz
		_hx_list = list()
		_hx_local_2 = _hx_set.keys()
		while _hx_local_2.hasNext():
			className = _hx_local_2.next()
			x = _hx_set.h.get(className,None)
			_hx_list.append(x)
		return _hx_list

	def unbindFields(self,token):
		if (token is None):
			return
		if Std._hx_is(token,saturn_db_query_lang_Field):
			cToken = None
			def _hx_local_0():
				_hx_local_0 = token
				if Std._hx_is(_hx_local_0,saturn_db_query_lang_Field):
					_hx_local_0
				else:
					raise _HxException("Class cast error")
				return _hx_local_0
			cToken = _hx_local_0()
			clazz = cToken.getClass()
			field = cToken.getAttributeName()
			model = self.provider.getModelByStringName(clazz)
			if (model is not None):
				if (field != "*"):
					unboundFieldName = model.unbindFieldName(field)
					cToken.setAttributeName(unboundFieldName)
		if (token.getTokens() is not None):
			_g = 0
			_g1 = token.getTokens()
			while (_g < len(_g1)):
				token1 = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
				_g = (_g + 1)
				self.unbindFields(token1)

	def addClassToken(self,token):
		if (Std._hx_is(token,saturn_db_query_lang_Query) or ((token is None))):
			return
		if Std._hx_is(token,saturn_db_query_lang_Field):
			fToken = None
			def _hx_local_0():
				_hx_local_0 = token
				if Std._hx_is(_hx_local_0,saturn_db_query_lang_Field):
					_hx_local_0
				else:
					raise _HxException("Class cast error")
				return _hx_local_0
			fToken = _hx_local_0()
			if (fToken.getClass() is not None):
				cToken = saturn_db_query_lang_ClassToken(fToken.getClass())
				if (fToken.clazzAlias is not None):
					cToken.name = fToken.clazzAlias
				self.fromToken.addToken(cToken)
		if (token.getTokens() is not None):
			_g = 0
			_g1 = token.getTokens()
			while (_g < len(_g1)):
				token1 = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
				_g = (_g + 1)
				self.addClassToken(token1)

	def get(self,obj):
		self.addExample(obj)

	def addExample(self,obj,fieldList = None):
		clazz = Type.getClass(obj)
		model = self.provider.getModel(clazz)
		if (fieldList is not None):
			if (len(fieldList) > 0):
				_g = 0
				while (_g < len(fieldList)):
					field = (fieldList[_g] if _g >= 0 and _g < len(fieldList) else None)
					_g = (_g + 1)
					self.getSelect().addToken(saturn_db_query_lang_Field(clazz, field))
		else:
			self.getSelect().addToken(saturn_db_query_lang_Field(clazz, "*"))
		fields = model.getAttributes()
		hasPrevious = False
		self.getWhere().addToken(saturn_db_query_lang_StartBlock())
		_g1 = 0
		_g2 = len(fields)
		while (_g1 < _g2):
			i = _g1
			_g1 = (_g1 + 1)
			field1 = (fields[i] if i >= 0 and i < len(fields) else None)
			value = Reflect.field(obj,field1)
			if (value is not None):
				if hasPrevious:
					self.getWhere().addToken(saturn_db_query_lang_And())
				self.getWhere().addToken(saturn_db_query_lang_Field(clazz, field1))
				if Std._hx_is(value,saturn_db_query_lang_Token):
					self.getWhere().addToken(value)
				else:
					self.getWhere().addToken(saturn_db_query_lang_Equals())
					if Std._hx_is(value,saturn_db_query_lang_IsNull):
						saturn_core_Util.print("Found NULL")
						self.getWhere().addToken(saturn_db_query_lang_IsNull())
					elif Std._hx_is(value,saturn_db_query_lang_IsNotNull):
						self.getWhere().addToken(saturn_db_query_lang_IsNotNull())
					else:
						saturn_core_Util.print(("Found value" + HxOverrides.stringOrNull(Type.getClassName(Type.getClass(value)))))
						self.getWhere().addToken(saturn_db_query_lang_Value(value))
				hasPrevious = True
		self.getWhere().addToken(saturn_db_query_lang_EndBlock())

	def getResults(self):
		return self.results

	def hasResults(self):
		return ((self.results is not None) and ((len(self.results) > 0)))

	def getError(self):
		return self.error

	@staticmethod
	def deserialise(querySer):
		import pickle
		clone = pickle.loads(querySer)
		return clone

	@staticmethod
	def deserialiseToken(token):
		if (token is None):
			return
		if (token.getTokens() is not None):
			_g = 0
			_g1 = token.getTokens()
			while (_g < len(_g1)):
				token1 = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
				_g = (_g + 1)
				saturn_db_query_lang_Query.deserialiseToken(token1)
		if Std._hx_is(token,saturn_db_query_lang_Query):
			qToken = None
			def _hx_local_0():
				_hx_local_1 = token
				if Std._hx_is(_hx_local_1,saturn_db_query_lang_Query):
					_hx_local_1
				else:
					raise _HxException("Class cast error")
				return _hx_local_1
			qToken = _hx_local_0()
			qToken.provider = None

	@staticmethod
	def startsWith(value):
		return saturn_db_query_lang_Like().add(saturn_db_query_lang_Value((("null" if value is None else value) + "%")))

	@staticmethod
	def getByExample(provider,example,cb = None):
		q = saturn_db_query_lang_Query(provider)
		q.addExample(example)
		q.run(cb)
		return q

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.selectToken = None
		_hx_o.fromToken = None
		_hx_o.whereToken = None
		_hx_o.groupToken = None
		_hx_o.orderToken = None
		_hx_o.provider = None
		_hx_o.rawResults = None
		_hx_o.pageOn = None
		_hx_o.pageSize = None
		_hx_o.lastPagedRowValue = None
		_hx_o.results = None
		_hx_o.error = None
saturn_db_query_lang_Query._hx_class = saturn_db_query_lang_Query
_hx_classes["saturn.db.query_lang.Query"] = saturn_db_query_lang_Query


class saturn_db_query_lang_QueryTests:
	_hx_class_name = "saturn.db.query_lang.QueryTests"
	_hx_methods = ["test1"]

	def __init__(self):
		pass

	def test1(self):
		query = saturn_db_query_lang_Query(saturn_core_Util.getProvider())
		query.getSelect().addToken(saturn_db_query_lang_Field(saturn_core_domain_SgcAllele, "alleleId", None))
		visitor = saturn_db_query_lang_SQLVisitor(saturn_core_Util.getProvider())
		visitor.translate(query)

	@staticmethod
	def _hx_empty_init(_hx_o):		pass
saturn_db_query_lang_QueryTests._hx_class = saturn_db_query_lang_QueryTests
_hx_classes["saturn.db.query_lang.QueryTests"] = saturn_db_query_lang_QueryTests


class saturn_db_query_lang_QueryVisitor:
	_hx_class_name = "saturn.db.query_lang.QueryVisitor"
	_hx_methods = ["translateQuery"]
saturn_db_query_lang_QueryVisitor._hx_class = saturn_db_query_lang_QueryVisitor
_hx_classes["saturn.db.query_lang.QueryVisitor"] = saturn_db_query_lang_QueryVisitor


class saturn_db_query_lang_SQLVisitor:
	_hx_class_name = "saturn.db.query_lang.SQLVisitor"
	_hx_fields = ["provider", "values", "valPos", "nextAliasId", "aliasToGenerated", "generatedToAlias"]
	_hx_methods = ["generateId", "getNextValuePosition", "getNextAliasId", "getValues", "translate", "getProcessedResults", "getParameterNotation", "postProcess", "getLimitClause", "buildSqlInClause"]
	_hx_statics = ["injection_check"]

	def __init__(self,provider,valPos = 1,aliasToGenerated = None,nextAliasId = 0):
		if (valPos is None):
			valPos = 1
		if (nextAliasId is None):
			nextAliasId = 0
		self.provider = None
		self.values = None
		self.valPos = None
		self.nextAliasId = None
		self.aliasToGenerated = None
		self.generatedToAlias = None
		self.provider = provider
		self.values = list()
		self.valPos = valPos
		if (aliasToGenerated is None):
			self.aliasToGenerated = haxe_ds_StringMap()
		else:
			self.aliasToGenerated = aliasToGenerated
		self.nextAliasId = nextAliasId

	def generateId(self,alias,baseValue = "ALIAS_"):
		if (baseValue is None):
			baseValue = "ALIAS_"
		if alias in self.aliasToGenerated.h:
			return self.aliasToGenerated.h.get(alias,None)
		_hx_local_0 = self
		_hx_local_1 = _hx_local_0.nextAliasId
		_hx_local_0.nextAliasId = (_hx_local_1 + 1)
		_hx_local_1
		id = (("null" if baseValue is None else baseValue) + Std.string(self.nextAliasId))
		self.aliasToGenerated.h[alias] = id
		saturn_core_Util.debug(((("Mapping" + ("null" if alias is None else alias)) + " to  ") + ("null" if id is None else id)))
		return id

	def getNextValuePosition(self):
		return self.valPos

	def getNextAliasId(self):
		return self.nextAliasId

	def getValues(self):
		return self.values

	def translate(self,token):
		sqlTranslation = ""
		if (token is None):
			pass
		elif Std._hx_is(token,saturn_db_query_lang_Query):
			query = None
			def _hx_local_0():
				_hx_local_0 = token
				if Std._hx_is(_hx_local_0,saturn_db_query_lang_Query):
					_hx_local_0
				else:
					raise _HxException("Class cast error")
				return _hx_local_0
			query = _hx_local_0()
			self.postProcess(query)
			sqlQuery = ""
			tokens = query.getTokens()
			_g = 0
			while (_g < len(tokens)):
				token1 = (tokens[_g] if _g >= 0 and _g < len(tokens) else None)
				_g = (_g + 1)
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + Std.string(self.translate(token1)))
		else:
			nestedTranslation = ""
			if (token.getTokens() is not None):
				tokenTranslations = list()
				if Std._hx_is(token,saturn_db_query_lang_Instr):
					if (self.provider.getProviderType() == "SQLITE"):
						_this = token.tokens
						if (len(_this) == 0):
							None
						else:
							_this.pop()
						_this1 = token.tokens
						if (len(_this1) == 0):
							None
						else:
							_this1.pop()
				_g1 = 0
				_g11 = token.getTokens()
				while (_g1 < len(_g11)):
					token2 = (_g11[_g1] if _g1 >= 0 and _g1 < len(_g11) else None)
					_g1 = (_g1 + 1)
					if Std._hx_is(token2,saturn_db_query_lang_Query):
						subVisitor = saturn_db_query_lang_SQLVisitor(self.provider, self.valPos, self.aliasToGenerated, self.nextAliasId)
						self.valPos = subVisitor.getNextValuePosition()
						self.nextAliasId = subVisitor.getNextAliasId()
						generatedAlias = ""
						if ((token2.name is not None) and ((token2.name != ""))):
							generatedAlias = self.generateId(token2.name)
						x = (((("(" + Std.string(subVisitor.translate(token2))) + ") ") + ("null" if generatedAlias is None else generatedAlias)) + " ")
						tokenTranslations.append(x)
						_g2 = 0
						_g3 = subVisitor.getValues()
						while (_g2 < len(_g3)):
							value = (_g3[_g2] if _g2 >= 0 and _g2 < len(_g3) else None)
							_g2 = (_g2 + 1)
							_this2 = self.values
							x1 = value
							_this2.append(x1)
					else:
						x2 = self.translate(token2)
						tokenTranslations.append(x2)
				joinSep = " "
				if ((((Std._hx_is(token,saturn_db_query_lang_Select) or Std._hx_is(token,saturn_db_query_lang_From)) or Std._hx_is(token,saturn_db_query_lang_Function)) or Std._hx_is(token,saturn_db_query_lang_Group)) or Std._hx_is(token,saturn_db_query_lang_OrderBy)):
					joinSep = ","
				nestedTranslation = joinSep.join([python_Boot.toString1(x1,'') for x1 in tokenTranslations])
			if Std._hx_is(token,saturn_db_query_lang_Value):
				cToken = None
				def _hx_local_0():
					_hx_local_5 = token
					if Std._hx_is(_hx_local_5,saturn_db_query_lang_Value):
						_hx_local_5
					else:
						raise _HxException("Class cast error")
					return _hx_local_5
				cToken = _hx_local_0()
				_this3 = self.values
				x3 = cToken.getValue()
				_this3.append(x3)
				def _hx_local_8():
					_hx_local_6 = self
					_hx_local_7 = _hx_local_6.valPos
					_hx_local_6.valPos = (_hx_local_7 + 1)
					return _hx_local_7
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull((((((" " + HxOverrides.stringOrNull(self.getParameterNotation(_hx_local_8()))) + " ") + ("null" if nestedTranslation is None else nestedTranslation)) + " "))))
			elif Std._hx_is(token,saturn_db_query_lang_Function):
				if Std._hx_is(token,saturn_db_query_lang_Trim):
					if (self.provider.getProviderType() == "SQLITE"):
						sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull((((("ltrim(" + ("null" if nestedTranslation is None else nestedTranslation)) + ",'0'") + ")"))))
					else:
						sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((("Trim( leading '0' from " + ("null" if nestedTranslation is None else nestedTranslation)) + ")"))))
				else:
					funcName = ""
					if Std._hx_is(token,saturn_db_query_lang_Max):
						funcName = "MAX"
					elif Std._hx_is(token,saturn_db_query_lang_Count):
						funcName = "COUNT"
					elif Std._hx_is(token,saturn_db_query_lang_Instr):
						funcName = "INSTR"
					elif Std._hx_is(token,saturn_db_query_lang_Substr):
						funcName = "SUBSTR"
					elif Std._hx_is(token,saturn_db_query_lang_Length):
						funcName = "LENGTH"
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((((("null" if funcName is None else funcName) + "( ") + ("null" if nestedTranslation is None else nestedTranslation)) + " )"))))
			elif Std._hx_is(token,saturn_db_query_lang_Select):
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" SELECT " + ("null" if nestedTranslation is None else nestedTranslation)))))
			elif Std._hx_is(token,saturn_db_query_lang_Field):
				cToken1 = None
				def _hx_local_0():
					_hx_local_14 = token
					if Std._hx_is(_hx_local_14,saturn_db_query_lang_Field):
						_hx_local_14
					else:
						raise _HxException("Class cast error")
					return _hx_local_14
				cToken1 = _hx_local_0()
				clazzName = cToken1.getClass()
				fieldPrefix = None
				fieldName = None
				if (cToken1.clazzAlias is not None):
					fieldPrefix = self.generateId(cToken1.clazzAlias)
				if (clazzName is not None):
					model = self.provider.getModelByStringName(clazzName)
					fieldName = model.getSqlColumn(cToken1.getAttributeName())
					if (fieldPrefix is None):
						tableName = model.getTableName()
						schemaName = model.getSchemaName()
						fieldPrefix = self.provider.generateQualifiedName(schemaName,tableName)
				else:
					fieldName = self.generateId(cToken1.attributeName)
				if (cToken1.getAttributeName() == "*"):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((("null" if fieldPrefix is None else fieldPrefix) + ".*"))))
				else:
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull((((("null" if fieldPrefix is None else fieldPrefix) + ".") + ("null" if fieldName is None else fieldName)))))
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull((((" " + ("null" if nestedTranslation is None else nestedTranslation)) + " "))))
			elif Std._hx_is(token,saturn_db_query_lang_Where):
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" WHERE " + ("null" if nestedTranslation is None else nestedTranslation)))))
			elif Std._hx_is(token,saturn_db_query_lang_Group):
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" GROUP BY " + ("null" if nestedTranslation is None else nestedTranslation)))))
			elif Std._hx_is(token,saturn_db_query_lang_From):
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" FROM " + ("null" if nestedTranslation is None else nestedTranslation)))))
			elif Std._hx_is(token,saturn_db_query_lang_OrderBy):
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" ORDER BY " + ("null" if nestedTranslation is None else nestedTranslation)))))
			elif Std._hx_is(token,saturn_db_query_lang_OrderByItem):
				oToken = None
				def _hx_local_0():
					_hx_local_22 = token
					if Std._hx_is(_hx_local_22,saturn_db_query_lang_OrderByItem):
						_hx_local_22
					else:
						raise _HxException("Class cast error")
					return _hx_local_22
				oToken = _hx_local_0()
				direction = "ASC"
				if oToken.descending:
					direction = "DESC"
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull((((("null" if nestedTranslation is None else nestedTranslation) + " ") + ("null" if direction is None else direction)))))
			elif Std._hx_is(token,saturn_db_query_lang_ClassToken):
				cToken2 = None
				def _hx_local_0():
					_hx_local_24 = token
					if Std._hx_is(_hx_local_24,saturn_db_query_lang_ClassToken):
						_hx_local_24
					else:
						raise _HxException("Class cast error")
					return _hx_local_24
				cToken2 = _hx_local_0()
				model1 = self.provider.getModelByStringName(cToken2.getClass())
				tableName1 = model1.getTableName()
				schemaName1 = model1.getSchemaName()
				name = self.provider.generateQualifiedName(schemaName1,tableName1)
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull((((" " + ("null" if name is None else name)) + " "))))
			elif Std._hx_is(token,saturn_db_query_lang_Operator):
				if Std._hx_is(token,saturn_db_query_lang_And):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" AND " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_Plus):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" + " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_Minus):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" - " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_Or):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" OR " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_Equals):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" = " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_IsNull):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" IS NULL " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_IsNotNull):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" IS NOT NULL " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_GreaterThan):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" > " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_GreaterThanOrEqualTo):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" >= " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_LessThan):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" < " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_LessThanOrEqualTo):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" <= " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_In):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" IN " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_Concat):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" || " + ("null" if nestedTranslation is None else nestedTranslation)))))
				elif Std._hx_is(token,saturn_db_query_lang_Like):
					sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((" LIKE " + ("null" if nestedTranslation is None else nestedTranslation)))))
			elif Std._hx_is(token,saturn_db_query_lang_ValueList):
				cToken3 = None
				def _hx_local_0():
					_hx_local_40 = token
					if Std._hx_is(_hx_local_40,saturn_db_query_lang_ValueList):
						_hx_local_40
					else:
						raise _HxException("Class cast error")
					return _hx_local_40
				cToken3 = _hx_local_0()
				values = cToken3.getValues()
				itemStrings = list()
				_g12 = 0
				_g4 = len(values)
				while (_g12 < _g4):
					i = _g12
					_g12 = (_g12 + 1)
					def _hx_local_43():
						_hx_local_41 = self
						_hx_local_42 = _hx_local_41.valPos
						_hx_local_41.valPos = (_hx_local_42 + 1)
						return _hx_local_42
					x4 = self.getParameterNotation(_hx_local_43())
					itemStrings.append(x4)
					x5 = (values[i] if i >= 0 and i < len(values) else None)
					values.append(x5)
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull((((" ( " + HxOverrides.stringOrNull(",".join([python_Boot.toString1(x1,'') for x1 in itemStrings]))) + " ) "))))
			elif Std._hx_is(token,saturn_db_query_lang_Limit):
				cToken4 = None
				def _hx_local_0():
					_hx_local_45 = token
					if Std._hx_is(_hx_local_45,saturn_db_query_lang_Limit):
						_hx_local_45
					else:
						raise _HxException("Class cast error")
					return _hx_local_45
				cToken4 = _hx_local_0()
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(self.getLimitClause(nestedTranslation)))
			elif Std._hx_is(token,saturn_db_query_lang_StartBlock):
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + " ( ")
			elif Std._hx_is(token,saturn_db_query_lang_EndBlock):
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + " ) ")
			else:
				sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull((((" " + ("null" if nestedTranslation is None else nestedTranslation)) + " "))))
		if (((token is not None) and ((token.name is not None))) and (not Std._hx_is(token,saturn_db_query_lang_Query))):
			generatedAlias1 = self.generateId(token.name)
			sqlTranslation = (("null" if sqlTranslation is None else sqlTranslation) + HxOverrides.stringOrNull(((("  \"" + ("null" if generatedAlias1 is None else generatedAlias1)) + "\""))))
		return sqlTranslation

	def getProcessedResults(self,results):
		if (len(results) > 0):
			self.generatedToAlias = haxe_ds_StringMap()
			_hx_local_0 = self.aliasToGenerated.keys()
			while _hx_local_0.hasNext():
				generated = _hx_local_0.next()
				key = self.aliasToGenerated.h.get(generated,None)
				self.generatedToAlias.h[key] = generated
			fields = python_Boot.fields((results[0] if 0 < len(results) else None))
			toRename = list()
			_g = 0
			while (_g < len(fields)):
				field = (fields[_g] if _g >= 0 and _g < len(fields) else None)
				_g = (_g + 1)
				if field in self.generatedToAlias.h:
					toRename.append(field)
			if (len(toRename) > 0):
				_g1 = 0
				while (_g1 < len(results)):
					row = (results[_g1] if _g1 >= 0 and _g1 < len(results) else None)
					_g1 = (_g1 + 1)
					_g11 = 0
					while (_g11 < len(toRename)):
						field1 = (toRename[_g11] if _g11 >= 0 and _g11 < len(toRename) else None)
						_g11 = (_g11 + 1)
						val = Reflect.field(row,field1)
						Reflect.deleteField(row,field1)
						field2 = self.generatedToAlias.h.get(field1,None)
						setattr(row,(("_hx_" + field2) if (field2 in python_Boot.keywords) else (("_hx_" + field2) if (((((len(field2) > 2) and ((ord(field2[0]) == 95))) and ((ord(field2[1]) == 95))) and ((ord(field2[(len(field2) - 1)]) != 95)))) else field2)),val)
		return results

	def getParameterNotation(self,i):
		if (self.provider.getProviderType() == "ORACLE"):
			return (":" + Std.string(i))
		elif (self.provider.getProviderType() == "MYSQL"):
			return "?"
		elif (self.provider.getProviderType() == "PGSQL"):
			return ("$" + Std.string(i))
		else:
			return "?"

	def postProcess(self,query):
		if (self.provider.getProviderType() == "ORACLE"):
			if ((query.tokens is not None) and ((len(query.tokens) > 0))):
				_g = 0
				_g1 = query.tokens
				while (_g < len(_g1)):
					token = (_g1[_g] if _g >= 0 and _g < len(_g1) else None)
					_g = (_g + 1)
					if Std._hx_is(token,saturn_db_query_lang_Limit):
						if (query.whereToken is None):
							query.whereToken = saturn_db_query_lang_Where()
						where = query.getWhere()
						where.add(token)
						python_internal_ArrayImpl.remove(query.tokens,token)

	def getLimitClause(self,txt):
		if (self.provider.getProviderType() == "ORACLE"):
			return (" ROWNUM < " + ("null" if txt is None else txt))
		elif (self.provider.getProviderType() == "MYSQL"):
			return (" limit " + ("null" if txt is None else txt))
		elif (self.provider.getProviderType() == "PGSQL"):
			return (" LIMIT " + ("null" if txt is None else txt))
		else:
			return (" limit " + ("null" if txt is None else txt))

	def buildSqlInClause(self,numIds,nextVal = 0,func = None):
		if (nextVal is None):
			nextVal = 0
		inClause_b = python_lib_io_StringIO()
		inClause_b.write("IN(")
		inClause_b.write(")")
		return inClause_b.getvalue()

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.provider = None
		_hx_o.values = None
		_hx_o.valPos = None
		_hx_o.nextAliasId = None
		_hx_o.aliasToGenerated = None
		_hx_o.generatedToAlias = None
saturn_db_query_lang_SQLVisitor._hx_class = saturn_db_query_lang_SQLVisitor
_hx_classes["saturn.db.query_lang.SQLVisitor"] = saturn_db_query_lang_SQLVisitor


class saturn_db_query_lang_Select(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Select"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_Select._hx_class = saturn_db_query_lang_Select
_hx_classes["saturn.db.query_lang.Select"] = saturn_db_query_lang_Select


class saturn_db_query_lang_StartBlock(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.StartBlock"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_StartBlock._hx_class = saturn_db_query_lang_StartBlock
_hx_classes["saturn.db.query_lang.StartBlock"] = saturn_db_query_lang_StartBlock


class saturn_db_query_lang_Substr(saturn_db_query_lang_Function):
	_hx_class_name = "saturn.db.query_lang.Substr"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Function


	def __init__(self,value,position = None,length = None):
		super().__init__([value, position, length])
saturn_db_query_lang_Substr._hx_class = saturn_db_query_lang_Substr
_hx_classes["saturn.db.query_lang.Substr"] = saturn_db_query_lang_Substr


class saturn_db_query_lang_Trim(saturn_db_query_lang_Function):
	_hx_class_name = "saturn.db.query_lang.Trim"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Function


	def __init__(self,value):
		super().__init__([value])
saturn_db_query_lang_Trim._hx_class = saturn_db_query_lang_Trim
_hx_classes["saturn.db.query_lang.Trim"] = saturn_db_query_lang_Trim


class saturn_db_query_lang_Value(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Value"
	_hx_fields = ["value"]
	_hx_methods = ["getValue"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,value):
		self.value = None
		super().__init__(None)
		self.value = value

	def getValue(self):
		return self.value

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.value = None
saturn_db_query_lang_Value._hx_class = saturn_db_query_lang_Value
_hx_classes["saturn.db.query_lang.Value"] = saturn_db_query_lang_Value


class saturn_db_query_lang_ValueList(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.ValueList"
	_hx_fields = ["values"]
	_hx_methods = ["getValues"]
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self,values):
		self.values = None
		self.values = values
		super().__init__(None)

	def getValues(self):
		return self.values

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.values = None
saturn_db_query_lang_ValueList._hx_class = saturn_db_query_lang_ValueList
_hx_classes["saturn.db.query_lang.ValueList"] = saturn_db_query_lang_ValueList


class saturn_db_query_lang_Where(saturn_db_query_lang_Token):
	_hx_class_name = "saturn.db.query_lang.Where"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = []
	_hx_interfaces = []
	_hx_super = saturn_db_query_lang_Token


	def __init__(self):
		super().__init__(None)
saturn_db_query_lang_Where._hx_class = saturn_db_query_lang_Where
_hx_classes["saturn.db.query_lang.Where"] = saturn_db_query_lang_Where


class saturn_util_StringUtils(StringTools):
	_hx_class_name = "saturn.util.StringUtils"
	_hx_fields = []
	_hx_methods = []
	_hx_statics = ["getRepeat", "reverse"]
	_hx_interfaces = []
	_hx_super = StringTools


	@staticmethod
	def getRepeat(txt,count):
		stringBuf_b = python_lib_io_StringIO()
		_g = 0
		while (_g < count):
			i = _g
			_g = (_g + 1)
			stringBuf_b.write(Std.string(txt))
		return stringBuf_b.getvalue()

	@staticmethod
	def reverse(txt):
		cols = list(txt)
		cols.reverse()
		return "".join([python_Boot.toString1(x1,'') for x1 in cols])
saturn_util_StringUtils._hx_class = saturn_util_StringUtils
_hx_classes["saturn.util.StringUtils"] = saturn_util_StringUtils


class saturn_workflow_Object:
	_hx_class_name = "saturn.workflow.Object"
	_hx_fields = ["error", "data", "response", "remote"]
	_hx_methods = ["setRemote", "isRemote", "getParameter", "setError", "getError", "setData", "getData", "getResponse", "setResponse", "setup"]

	def __init__(self):
		self.error = None
		self.data = None
		self.response = None
		self.remote = None
		self.remote = False

	def setRemote(self,remote):
		self.remote = remote

	def isRemote(self):
		return self.remote

	def getParameter(self,param):
		data = self.getData()
		if ((data is not None) and hasattr(data,(("_hx_" + param) if (param in python_Boot.keywords) else (("_hx_" + param) if (((((len(param) > 2) and ((ord(param[0]) == 95))) and ((ord(param[1]) == 95))) and ((ord(param[(len(param) - 1)]) != 95)))) else param)))):
			return Reflect.field(data,param)
		elif hasattr(self,(("_hx_" + param) if (param in python_Boot.keywords) else (("_hx_" + param) if (((((len(param) > 2) and ((ord(param[0]) == 95))) and ((ord(param[1]) == 95))) and ((ord(param[(len(param) - 1)]) != 95)))) else param))):
			return Reflect.field(self,param)
		else:
			return None

	def setError(self,error):
		saturn_core_Util.debug(error)
		self.error = error

	def getError(self):
		return self.error

	def setData(self,data):
		self.data = data

	def getData(self):
		return self.data

	def getResponse(self):
		return self.response

	def setResponse(self,resp):
		self.response = resp

	def setup(self,cb):
		pass

	@staticmethod
	def _hx_empty_init(_hx_o):
		_hx_o.error = None
		_hx_o.data = None
		_hx_o.response = None
		_hx_o.remote = None
saturn_workflow_Object._hx_class = saturn_workflow_Object
_hx_classes["saturn.workflow.Object"] = saturn_workflow_Object

Math.NEGATIVE_INFINITY = float("-inf")
Math.POSITIVE_INFINITY = float("inf")
Math.NaN = float("nan")
Math.PI = python_lib_Math.pi

Date.EPOCH_LOCAL = python_lib_datetime_Datetime.fromtimestamp(time.time())
haxe_Serializer.USE_CACHE = False
haxe_Serializer.USE_ENUM_INDEX = False
haxe_Serializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:"
haxe_Unserializer.DEFAULT_RESOLVER = Type
haxe_Unserializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:"
haxe_Unserializer.CODES = None
python_Boot.keywords = set(["and", "del", "from", "not", "with", "as", "elif", "global", "or", "yield", "assert", "else", "if", "pass", "None", "break", "except", "import", "raise", "True", "class", "exec", "in", "return", "False", "continue", "finally", "is", "try", "def", "for", "lambda", "while"])
python_Boot.prefixLength = len("_hx_")
saturn_client_core_CommonCore.pools = haxe_ds_StringMap()
saturn_client_core_CommonCore.resourceToPool = haxe_ds_ObjectMap()
saturn_client_core_CommonCore.providers = haxe_ds_StringMap()
saturn_client_core_CommonCore.combinedModels = None
saturn_core_molecule_Molecule.newLineReg = EReg("\n", "g")
saturn_core_molecule_Molecule.carLineReg = EReg("\r", "g")
saturn_core_molecule_Molecule.whiteSpaceReg = EReg("\\s", "g")
saturn_core_molecule_Molecule.reg_starReplace = EReg("\\*", "")
saturn_core_StandardGeneticCode.instance = saturn_core_StandardGeneticCode()
saturn_core_StandardGeneticCode.standardTable = saturn_core_StandardGeneticCode.instance.getCodonLookupTable()
saturn_core_StandardGeneticCode.aaToCodon = saturn_core_StandardGeneticCode.instance.getAAToCodonTable()
saturn_core_GeneticCodeRegistry.CODE_REGISTRY = saturn_core_GeneticCodeRegistry()
saturn_core_EUtils.eutils = None
saturn_core_domain_Compound.molCache = haxe_ds_StringMap()
saturn_core_domain_Compound.r = EReg("svg:", "g")
saturn_core_domain_Compound.rw = EReg("width='300px'", "g")
saturn_core_domain_Compound.rh = EReg("height='300px'", "g")
saturn_core_molecule_MoleculeConstants.aMW = 331.2
saturn_core_molecule_MoleculeConstants.tMW = 322.2
saturn_core_molecule_MoleculeConstants.gMW = 347.2
saturn_core_molecule_MoleculeConstants.cMW = 307.2
saturn_core_molecule_MoleculeConstants.aChainMW = 313.2
saturn_core_molecule_MoleculeConstants.tChainMW = 304.2
saturn_core_molecule_MoleculeConstants.gChainMW = 329.2
saturn_core_molecule_MoleculeConstants.cChainMW = 289.2
saturn_core_molecule_MoleculeConstants.O2H = 18.02
saturn_core_molecule_MoleculeConstants.OH = 17.01
saturn_core_molecule_MoleculeConstants.PO3 = 78.97
saturn_core_molecule_MoleculeSetRegistry.defaultRegistry = saturn_core_molecule_MoleculeSetRegistry()
saturn_db_DefaultProvider.r_date = EReg("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.000Z", "")
def _hx_init_saturn_db_mapping_FamaPublic_models():
	def _hx_local_0():
		_g = haxe_ds_StringMap()
		value = None
		_g1 = haxe_ds_StringMap()
		value1 = None
		_g2 = haxe_ds_StringMap()
		_g2.h["path"] = "PATH"
		_g2.h["content"] = "CONTENT"
		value1 = _g2
		_g1.h["fields"] = value1
		value2 = None
		_g3 = haxe_ds_StringMap()
		_g3.h["path"] = True
		value2 = _g3
		_g1.h["indexes"] = value2
		value3 = None
		_g4 = haxe_ds_StringMap()
		value4 = None
		_g5 = haxe_ds_StringMap()
		_g5.h["/work"] = "W:"
		_g5.h["/home/share"] = "S:"
		value4 = _g5
		value5 = value4
		_g4.h["windows_conversions"] = value5
		value6 = None
		_g6 = haxe_ds_StringMap()
		_g6.h["WORK"] = "^W"
		value6 = _g6
		value7 = value6
		_g4.h["windows_allowed_paths_regex"] = value7
		value8 = None
		_g7 = haxe_ds_StringMap()
		_g7.h["W:"] = "/work"
		value8 = _g7
		value9 = value8
		_g4.h["linux_conversions"] = value9
		value10 = None
		_g8 = haxe_ds_StringMap()
		_g8.h["WORK"] = "^/work"
		value10 = _g8
		value11 = value10
		_g4.h["linux_allowed_paths_regex"] = value11
		value3 = _g4
		_g1.h["options"] = value3
		value = _g1
		_g.h["saturn.core.domain.FileProxy"] = value
		value12 = None
		_g9 = haxe_ds_StringMap()
		value13 = None
		_g10 = haxe_ds_StringMap()
		_g10.h["moleculeName"] = "NAME"
		value13 = _g10
		_g9.h["fields"] = value13
		value14 = None
		_g11 = haxe_ds_StringMap()
		_g11.h["moleculeName"] = True
		value14 = _g11
		_g9.h["indexes"] = value14
		value15 = None
		_g12 = haxe_ds_StringMap()
		_g12.h["saturn.client.programs.DNASequenceEditor"] = True
		value15 = _g12
		_g9.h["programs"] = value15
		value16 = None
		_g13 = haxe_ds_StringMap()
		_g13.h["alias"] = "DNA"
		value16 = _g13
		_g9.h["options"] = value16
		value12 = _g9
		_g.h["saturn.core.DNA"] = value12
		value17 = None
		_g14 = haxe_ds_StringMap()
		value18 = None
		_g15 = haxe_ds_StringMap()
		_g15.h["moleculeName"] = "NAME"
		value18 = _g15
		_g14.h["fields"] = value18
		value19 = None
		_g16 = haxe_ds_StringMap()
		_g16.h["moleculeName"] = True
		value19 = _g16
		_g14.h["indexes"] = value19
		value20 = None
		_g17 = haxe_ds_StringMap()
		_g17.h["saturn.client.programs.ProteinSequenceEditor"] = True
		value20 = _g17
		_g14.h["programs"] = value20
		value21 = None
		_g18 = haxe_ds_StringMap()
		_g18.h["alias"] = "Proteins"
		value21 = _g18
		_g14.h["options"] = value21
		value17 = _g14
		_g.h["saturn.core.Protein"] = value17
		value22 = None
		_g19 = haxe_ds_StringMap()
		value23 = None
		_g20 = haxe_ds_StringMap()
		_g20.h["name"] = "NAME"
		value23 = _g20
		_g19.h["fields"] = value23
		value24 = None
		_g21 = haxe_ds_StringMap()
		_g21.h["name"] = True
		value24 = _g21
		_g19.h["indexes"] = value24
		value25 = None
		_g22 = haxe_ds_StringMap()
		_g22.h["saturn.client.programs.TextEditor"] = True
		value25 = _g22
		_g19.h["programs"] = value25
		value26 = None
		_g23 = haxe_ds_StringMap()
		_g23.h["alias"] = "File"
		value26 = _g23
		_g19.h["options"] = value26
		value22 = _g19
		_g.h["saturn.core.TextFile"] = value22
		value27 = None
		_g24 = haxe_ds_StringMap()
		value28 = None
		_g25 = haxe_ds_StringMap()
		_g25.h["saturn.client.programs.BasicTableViewer"] = True
		value28 = _g25
		_g24.h["programs"] = value28
		value29 = None
		_g26 = haxe_ds_StringMap()
		_g26.h["alias"] = "Results"
		value29 = _g26
		_g24.h["options"] = value29
		value27 = _g24
		_g.h["saturn.core.BasicTable"] = value27
		value30 = None
		_g27 = haxe_ds_StringMap()
		value31 = None
		_g28 = haxe_ds_StringMap()
		value32 = None
		_g29 = haxe_ds_StringMap()
		_g29.h["SGC"] = True
		value32 = _g29
		value33 = value32
		_g28.h["flags"] = value33
		value31 = _g28
		_g27.h["options"] = value31
		value30 = _g27
		_g.h["saturn.app.SaturnClient"] = value30
		return _g
	return _hx_local_0()
saturn_db_mapping_FamaPublic.models = _hx_init_saturn_db_mapping_FamaPublic_models()
def _hx_init_saturn_db_mapping_OPPFMapping_models():
	def _hx_local_0():
		_g = haxe_ds_StringMap()
		value = None
		_g1 = haxe_ds_StringMap()
		value1 = None
		_g2 = haxe_ds_StringMap()
		_g2.h["constructId"] = "construct_id"
		_g2.h["id"] = "id"
		_g2.h["start"] = "start"
		_g2.h["stop"] = "stop"
		_g2.h["description"] = "description"
		_g2.h["fwdAnnealLen"] = "fwd_anneal_len"
		_g2.h["revAnnealLen"] = "rev_anneal_len"
		_g2.h["fwdTagId"] = "fwd_tag_id"
		_g2.h["revTagId"] = "rev_tag_id"
		_g2.h["pickedBy"] = "picked_by"
		_g2.h["pickedAt"] = "picked_at"
		_g2.h["authBy"] = "auth_by"
		_g2.h["authAt"] = "auth_at"
		_g2.h["auth"] = "auth"
		_g2.h["manual"] = "manual"
		_g2.h["limsRead"] = "lims_read"
		_g2.h["annotationId"] = "annotation_id"
		_g2.h["vectorId"] = "vector_id"
		value1 = _g2
		_g1.h["fields"] = value1
		value2 = None
		_g3 = haxe_ds_StringMap()
		_g3.h["constructId"] = True
		value2 = _g3
		_g1.h["indexes"] = value2
		value3 = None
		_g4 = haxe_ds_StringMap()
		_g4.h["Target"] = "id"
		_g4.h["Start location"] = "start"
		_g4.h["Stop location"] = "stop"
		_g4.h["Description"] = "description"
		_g4.h["Forward Anneal Length"] = "fwdAnnealLen"
		_g4.h["Reverse Anneal Length"] = "revAnnealLen"
		_g4.h["Forward Tag Id"] = "fwdTagId"
		_g4.h["Reverse Tag Id"] = "revTagId"
		_g4.h["Picked By"] = "pickedBy"
		_g4.h["Picked At"] = "pickedAt"
		_g4.h["Authorised by"] = "authBy"
		_g4.h["Authorised at"] = "authAt"
		_g4.h["Authorisation status"] = "auth"
		_g4.h["Manual"] = "manual"
		_g4.h["LIMS Read"] = "lims_read"
		_g4.h["Annotation Id"] = "annotation_id"
		_g4.h["Vector ID"] = "vector_id"
		_g4.h["__HIDDEN__PKEY__"] = "constructId"
		value3 = _g4
		_g1.h["model"] = value3
		value4 = None
		_g5 = haxe_ds_StringMap()
		value5 = None
		_g6 = haxe_ds_StringMap()
		_g6.h["field"] = "revTagId"
		_g6.h["class"] = "saturn.core.domain.oppf.OppfReverseTag"
		_g6.h["fk_field"] = "id"
		value5 = _g6
		value6 = value5
		_g5.h["revTagId"] = value6
		value7 = None
		_g7 = haxe_ds_StringMap()
		_g7.h["field"] = "fwdTagId"
		_g7.h["class"] = "saturn.core.domain.oppf.OppfForwardTag"
		_g7.h["fk_field"] = "id"
		value7 = _g7
		value8 = value7
		_g5.h["forwardTag"] = value8
		value9 = None
		_g8 = haxe_ds_StringMap()
		_g8.h["field"] = "id"
		_g8.h["class"] = "saturn.core.domain.oppf.OppfGenbankInfo"
		_g8.h["fk_field"] = "id"
		value9 = _g8
		value10 = value9
		_g5.h["target"] = value10
		value11 = None
		_g9 = haxe_ds_StringMap()
		_g9.h["field"] = "vectorId"
		_g9.h["class"] = "saturn.core.domain.oppf.OppfVector"
		_g9.h["fk_field"] = "id"
		value11 = _g9
		value12 = value11
		_g5.h["vector"] = value12
		value4 = _g5
		_g1.h["fields.synthetic"] = value4
		value13 = None
		_g10 = haxe_ds_StringMap()
		_g10.h["icon"] = "construct_16.png"
		_g10.h["alias"] = "Construct"
		_g10.h["auto_activate"] = 3
		value14 = None
		_g11 = haxe_ds_StringMap()
		value15 = None
		_g12 = haxe_ds_StringMap()
		value16 = None
		_g13 = haxe_ds_StringMap()
		_g13.h["user_suffix"] = "Protein"
		_g13.h["function"] = "saturn.core.domain.oppf.OppfConstruct.showProtein"
		value16 = _g13
		_g12.h["protein"] = value16
		value15 = _g12
		_g11.h["search_bar"] = value15
		value14 = _g11
		value17 = value14
		_g10.h["actions"] = value17
		value13 = _g10
		_g1.h["options"] = value13
		value18 = None
		_g14 = haxe_ds_StringMap()
		value19 = None
		_g15 = haxe_ds_StringMap()
		_g15.h["search_when"] = "^OPPF"
		_g15.h["replace_with"] = ""
		value19 = _g15
		value20 = value19
		_g14.h["constructId"] = value20
		value18 = _g14
		_g1.h["search"] = value18
		value21 = None
		_g16 = haxe_ds_StringMap()
		_g16.h["schema"] = "optic"
		_g16.h["name"] = "construct"
		value21 = _g16
		_g1.h["table_info"] = value21
		value22 = None
		_g17 = haxe_ds_StringMap()
		_g17.h["saturn.client.programs.ProteinSequenceEditor"] = True
		value22 = _g17
		_g1.h["programs"] = value22
		value = _g1
		_g.h["saturn.core.domain.oppf.OppfConstruct"] = value
		value23 = None
		_g18 = haxe_ds_StringMap()
		value24 = None
		_g19 = haxe_ds_StringMap()
		_g19.h["id"] = "vector_id"
		_g19.h["name"] = "name"
		_g19.h["antibiotic"] = "antibiotic"
		_g19.h["background"] = "background"
		_g19.h["product"] = "product"
		_g19.h["infusion"] = "infusion"
		_g19.h["periplasm"] = "periplasm"
		_g19.h["eukaryotic"] = "eukaryotic"
		_g19.h["bacterial"] = "bacterial"
		_g19.h["mammalian"] = "mammalian"
		_g19.h["insect"] = "insect"
		_g19.h["stable"] = "stable"
		_g19.h["status"] = "status"
		_g19.h["rank"] = "rank"
		_g19.h["res1"] = "re1"
		_g19.h["res2"] = "re2"
		_g19.h["fwdSequence"] = "seq_fwd"
		_g19.h["revSequence"] = "seq_rev"
		_g19.h["glycerolPos"] = "glycerol_pos"
		value24 = _g19
		_g18.h["fields"] = value24
		value25 = None
		_g20 = haxe_ds_StringMap()
		_g20.h["id"] = True
		_g20.h["name"] = False
		value25 = _g20
		_g18.h["indexes"] = value25
		value26 = None
		_g21 = haxe_ds_StringMap()
		_g21.h["Vector Name"] = "name"
		_g21.h["Antibiotic"] = "antibiotic"
		_g21.h["Vector backbone"] = "background"
		_g21.h["Product"] = "product"
		_g21.h["Infusion compatible"] = "infusion"
		_g21.h["Periplasmic"] = "periplasm"
		_g21.h["Eukaryotic"] = "eurkaryotic"
		_g21.h["Bacterial"] = "bacterial"
		_g21.h["Mammalian"] = "mammalian"
		_g21.h["Insect"] = "insect"
		_g21.h["Stable"] = "stable"
		_g21.h["Status"] = "status"
		_g21.h["Rank"] = "rank"
		_g21.h["Restriction Enzyme 1"] = "re1"
		_g21.h["Restriction Enzyme 2"] = "re2"
		_g21.h["Forward sequence"] = "fwdSequence"
		_g21.h["Reverse sequence"] = "revSequence"
		_g21.h["Position of Glycerol"] = "glycerolPos"
		_g21.h["__HIDDEN__PKEY__"] = "id"
		value26 = _g21
		_g18.h["model"] = value26
		value27 = None
		_g22 = haxe_ds_StringMap()
		_g22.h["schema"] = "optic"
		_g22.h["name"] = "vector"
		value27 = _g22
		_g18.h["table_info"] = value27
		value23 = _g18
		_g.h["saturn.core.domain.oppf.OppfVector"] = value23
		value28 = None
		_g23 = haxe_ds_StringMap()
		value29 = None
		_g24 = haxe_ds_StringMap()
		_g24.h["id"] = "rev_tag_id"
		_g24.h["name"] = "rev_tag_name"
		_g24.h["sequence"] = "rev_tag_seq"
		value29 = _g24
		_g23.h["fields"] = value29
		value30 = None
		_g25 = haxe_ds_StringMap()
		_g25.h["id"] = True
		value30 = _g25
		_g23.h["ndexes"] = value30
		value31 = None
		_g26 = haxe_ds_StringMap()
		_g26.h["schema"] = "optic"
		_g26.h["name"] = "rev_tag"
		value31 = _g26
		_g23.h["table_info"] = value31
		value28 = _g23
		_g.h["saturn.core.domain.OppfReverseTag"] = value28
		value32 = None
		_g27 = haxe_ds_StringMap()
		value33 = None
		_g28 = haxe_ds_StringMap()
		_g28.h["id"] = "fwd_tag_id"
		_g28.h["name"] = "fwd_tag_name"
		_g28.h["sequence"] = "fwd_tag_seq"
		value33 = _g28
		_g27.h["fields"] = value33
		value34 = None
		_g29 = haxe_ds_StringMap()
		_g29.h["id"] = True
		value34 = _g29
		_g27.h["indexes"] = value34
		value35 = None
		_g30 = haxe_ds_StringMap()
		_g30.h["schema"] = "optic"
		_g30.h["name"] = "fwd_tag"
		value35 = _g30
		_g27.h["table_info"] = value35
		value32 = _g27
		_g.h["saturn.core.domain.oppf.OppfForwardTag"] = value32
		value36 = None
		_g31 = haxe_ds_StringMap()
		value37 = None
		_g32 = haxe_ds_StringMap()
		_g32.h["id"] = "annotation_id"
		_g32.h["genbankInfoId"] = "id"
		_g32.h["startSeq"] = "seq_start"
		_g32.h["endSeq"] = "seq_end"
		_g32.h["annotation"] = "annotation"
		_g32.h["annotatedBy"] = "annotation_by"
		_g32.h["annotatedAt"] = "annotation_at"
		_g32.h["annotationType"] = "annotation_type_id"
		_g32.h["referenceId"] = "reference_id"
		_g32.h["sequenceType"] = "seq_type"
		_g32.h["filePath"] = "path_to_file"
		value37 = _g32
		_g31.h["fields"] = value37
		value38 = None
		_g33 = haxe_ds_StringMap()
		_g33.h["id"] = True
		value38 = _g33
		_g31.h["indexes"] = value38
		value39 = None
		_g34 = haxe_ds_StringMap()
		_g34.h["__HIDDEN__PKEY__"] = "id"
		_g34.h["Protein information ID"] = "genbankInfoId"
		_g34.h["Start sequence"] = "startSeq"
		_g34.h["End sequence"] = "endSeq"
		_g34.h["Annotation"] = "annotation"
		_g34.h["Annotated by"] = "annotatedBy"
		_g34.h["Annotation at"] = "annotatedAt"
		_g34.h["Type of annotation"] = "annotationType"
		_g34.h["Reference Id"] = "referenceId"
		_g34.h["Sequence type"] = "sequenceType"
		_g34.h["Path to file"] = "filePath"
		value39 = _g34
		_g31.h["model"] = value39
		value40 = None
		_g35 = haxe_ds_StringMap()
		value41 = None
		_g36 = haxe_ds_StringMap()
		_g36.h["field"] = "genbankInfoId"
		_g36.h["class"] = "saturn.core.domain.oppf.OppfGenbankInfo"
		_g36.h["fk_field"] = "id"
		value41 = _g36
		value42 = value41
		_g35.h["genbank"] = value42
		value40 = _g35
		_g31.h["fields.synthetic"] = value40
		value43 = None
		_g37 = haxe_ds_StringMap()
		_g37.h["schema"] = "optic"
		_g37.h["name"] = "annotation"
		value43 = _g37
		_g31.h["table_info"] = value43
		value36 = _g31
		_g.h["saturn.core.domain.oppf.OppfAnnotation"] = value36
		value44 = None
		_g38 = haxe_ds_StringMap()
		value45 = None
		_g39 = haxe_ds_StringMap()
		_g39.h["id"] = "id"
		_g39.h["genbankAccession"] = "genbank_number"
		_g39.h["giNumber"] = "gi_number"
		_g39.h["mgcAccession"] = "mgc_number"
		_g39.h["imageNumber"] = "image_number"
		_g39.h["dnaSequence"] = "dna_sequence"
		_g39.h["proteinSequence"] = "protein_sequence"
		_g39.h["description"] = "description"
		_g39.h["dnaDescription"] = "dna_description"
		_g39.h["genbankLocus"] = "genbank"
		_g39.h["locus"] = "locus"
		_g39.h["speciesId"] = "species_id"
		value45 = _g39
		_g38.h["fields"] = value45
		value46 = None
		_g40 = haxe_ds_StringMap()
		_g40.h["id"] = True
		value46 = _g40
		_g38.h["indexes"] = value46
		value47 = None
		_g41 = haxe_ds_StringMap()
		_g41.h["Target Identifier"] = "id"
		_g41.h["Genbank Accession"] = "genbankAccession"
		_g41.h["GenInfo Identifier"] = "giNumber"
		_g41.h["MGC Accession"] = "mgcAccession"
		_g41.h["Image"] = "imageNumber"
		_g41.h["DNA Sequence"] = "dnaSequence"
		_g41.h["Protein Sequence"] = "proteinSequence"
		_g41.h["Description"] = "description"
		_g41.h["DNA description"] = "dnaDescription"
		_g41.h["GenBank Locus"] = "genbankLocus"
		_g41.h["Locus"] = "locus"
		_g41.h["Species Identifier"] = "speciesId"
		value47 = _g41
		_g38.h["model"] = value47
		value48 = None
		_g42 = haxe_ds_StringMap()
		_g42.h["id"] = True
		_g42.h["description"] = True
		value48 = _g42
		_g38.h["fts"] = value48
		value49 = None
		_g43 = haxe_ds_StringMap()
		_g43.h["icon"] = "target_16.png"
		_g43.h["alias"] = "Target"
		value50 = None
		_g44 = haxe_ds_StringMap()
		value51 = None
		_g45 = haxe_ds_StringMap()
		value52 = None
		_g46 = haxe_ds_StringMap()
		_g46.h["user_suffix"] = "protein"
		_g46.h["function"] = "saturn.core.domain.oppf.OppfGenbankInfo.showProtein"
		value52 = _g46
		_g45.h["protein"] = value52
		value51 = _g45
		_g44.h["search_bar"] = value51
		value50 = _g44
		value53 = value50
		_g43.h["actions"] = value53
		value49 = _g43
		_g38.h["options"] = value49
		value54 = None
		_g47 = haxe_ds_StringMap()
		value55 = None
		_g48 = haxe_ds_StringMap()
		_g48.h["search_when"] = "^OPTIC"
		_g48.h["replace_with"] = ""
		value55 = _g48
		value56 = value55
		_g47.h["id"] = value56
		value54 = _g47
		_g38.h["search"] = value54
		value57 = None
		_g49 = haxe_ds_StringMap()
		_g49.h["saturn.client.programs.DNASequenceEditor"] = True
		value57 = _g49
		_g38.h["programs"] = value57
		value58 = None
		_g50 = haxe_ds_StringMap()
		_g50.h["schema"] = "optic"
		_g50.h["name"] = "genbank_info"
		value58 = _g50
		_g38.h["table_info"] = value58
		value44 = _g38
		_g.h["saturn.core.domain.oppf.OppfGenbankInfo"] = value44
		value59 = None
		_g51 = haxe_ds_StringMap()
		value60 = None
		_g52 = haxe_ds_StringMap()
		_g52.h["path"] = "PATH"
		_g52.h["content"] = "CONTENT"
		value60 = _g52
		_g51.h["fields"] = value60
		value61 = None
		_g53 = haxe_ds_StringMap()
		_g53.h["path"] = True
		value61 = _g53
		_g51.h["indexes"] = value61
		value62 = None
		_g54 = haxe_ds_StringMap()
		value63 = None
		_g55 = haxe_ds_StringMap()
		_g55.h["/work"] = "W:"
		_g55.h["/home/share"] = "S:"
		value63 = _g55
		value64 = value63
		_g54.h["windows_conversions"] = value64
		value65 = None
		_g56 = haxe_ds_StringMap()
		_g56.h["WORK"] = "^W"
		value65 = _g56
		value66 = value65
		_g54.h["windows_allowed_paths_regex"] = value66
		value67 = None
		_g57 = haxe_ds_StringMap()
		_g57.h["W:"] = "/work"
		value67 = _g57
		value68 = value67
		_g54.h["linux_conversions"] = value68
		value69 = None
		_g58 = haxe_ds_StringMap()
		_g58.h["WORK"] = "^/work"
		value69 = _g58
		value70 = value69
		_g54.h["linux_allowed_paths_regex"] = value70
		value62 = _g54
		_g51.h["options"] = value62
		value59 = _g51
		_g.h["saturn.core.domain.FileProxy"] = value59
		value71 = None
		_g59 = haxe_ds_StringMap()
		value72 = None
		_g60 = haxe_ds_StringMap()
		value73 = None
		_g61 = haxe_ds_StringMap()
		_g61.h["SGC"] = False
		value73 = _g61
		value74 = value73
		_g60.h["flags"] = value74
		value72 = _g60
		_g59.h["options"] = value72
		value71 = _g59
		_g.h["saturn.app.SaturnClient"] = value71
		value75 = None
		_g62 = haxe_ds_StringMap()
		value76 = None
		_g63 = haxe_ds_StringMap()
		_g63.h["moleculeName"] = "NAME"
		value76 = _g63
		_g62.h["fields"] = value76
		value77 = None
		_g64 = haxe_ds_StringMap()
		_g64.h["moleculeName"] = True
		value77 = _g64
		_g62.h["indexes"] = value77
		value78 = None
		_g65 = haxe_ds_StringMap()
		_g65.h["saturn.client.programs.DNASequenceEditor"] = True
		value78 = _g65
		_g62.h["programs"] = value78
		value75 = _g62
		_g.h["saturn.core.DNA"] = value75
		value79 = None
		_g66 = haxe_ds_StringMap()
		value80 = None
		_g67 = haxe_ds_StringMap()
		_g67.h["moleculeName"] = "NAME"
		value80 = _g67
		_g66.h["fields"] = value80
		value81 = None
		_g68 = haxe_ds_StringMap()
		_g68.h["moleculeName"] = True
		value81 = _g68
		_g66.h["indexes"] = value81
		value82 = None
		_g69 = haxe_ds_StringMap()
		_g69.h["saturn.client.programs.ProteinSequenceEditor"] = True
		value82 = _g69
		_g66.h["programs"] = value82
		value79 = _g66
		_g.h["saturn.core.Protein"] = value79
		return _g
	return _hx_local_0()
saturn_db_mapping_OPPFMapping.models = _hx_init_saturn_db_mapping_OPPFMapping_models()
def _hx_init_saturn_db_mapping_SQLiteMapping_models():
	def _hx_local_0():
		_g = haxe_ds_StringMap()
		value = None
		_g1 = haxe_ds_StringMap()
		value1 = None
		_g2 = haxe_ds_StringMap()
		_g2.h["constructId"] = "CONSTRUCT_ID"
		_g2.h["id"] = "PKEY"
		_g2.h["proteinSeq"] = "CONSTRUCTPROTSEQ"
		_g2.h["proteinSeqNoTag"] = "CONSTRUCTPROTSEQNOTAG"
		_g2.h["dnaSeq"] = "CONSTRUCTDNASEQ"
		_g2.h["docId"] = "ELNEXP"
		_g2.h["vectorId"] = "SGCVECTOR_PKEY"
		_g2.h["alleleId"] = "SGCALLELE_PKEY"
		_g2.h["res1Id"] = "SGCRESTRICTENZ1_PKEY"
		_g2.h["res2Id"] = "SGCRESTRICTENZ2_PKEY"
		_g2.h["constructPlateId"] = "SGCCONSTRUCTPLATE_PKEY"
		_g2.h["wellId"] = "WELLID"
		_g2.h["expectedMass"] = "EXPECTEDMASS"
		_g2.h["expectedMassNoTag"] = "EXPETCEDMASSNOTAG"
		_g2.h["status"] = "STATUS"
		_g2.h["location"] = "SGCLOCATION"
		_g2.h["elnId"] = "ELNEXP"
		_g2.h["constructComments"] = "CONSTRUCTCOMMENTS"
		value1 = _g2
		_g1.h["fields"] = value1
		value2 = None
		_g3 = haxe_ds_StringMap()
		_g3.h["constructId"] = False
		_g3.h["id"] = True
		value2 = _g3
		_g1.h["indexes"] = value2
		value3 = None
		_g4 = haxe_ds_StringMap()
		_g4.h["Construct ID"] = "constructId"
		_g4.h["Construct Plate"] = "constructPlate.plateName"
		_g4.h["Well ID"] = "wellId"
		_g4.h["Vector ID"] = "vector.vectorId"
		_g4.h["Allele ID"] = "allele.alleleId"
		_g4.h["Status"] = "status"
		_g4.h["Protein Sequence"] = "proteinSeq"
		_g4.h["Expected Mass"] = "expectedMass"
		_g4.h["Restriction Site 1"] = "res1.enzymeName"
		_g4.h["Restriction Site 2"] = "res2.enzymeName"
		_g4.h["Protein Sequence (No Tag)"] = "proteinSeqNoTag"
		_g4.h["Expected Mass (No Tag)"] = "expectedMassNoTag"
		_g4.h["Construct DNA Sequence"] = "dnaSeq"
		_g4.h["Location"] = "location"
		_g4.h["ELN ID"] = "elnId"
		_g4.h["Construct Comments"] = "constructComments"
		_g4.h["__HIDDEN__PKEY__"] = "id"
		value3 = _g4
		_g1.h["model"] = value3
		value4 = None
		_g5 = haxe_ds_StringMap()
		value5 = None
		_g6 = haxe_ds_StringMap()
		_g6.h["field"] = "alleleId"
		_g6.h["class"] = "saturn.core.domain.SgcAllele"
		_g6.h["fk_field"] = "id"
		value5 = _g6
		value6 = value5
		_g5.h["allele"] = value6
		value7 = None
		_g7 = haxe_ds_StringMap()
		_g7.h["field"] = "vectorId"
		_g7.h["class"] = "saturn.core.domain.SgcVector"
		_g7.h["fk_field"] = "Id"
		value7 = _g7
		value8 = value7
		_g5.h["vector"] = value8
		value9 = None
		_g8 = haxe_ds_StringMap()
		_g8.h["field"] = "res1Id"
		_g8.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g8.h["fk_field"] = "id"
		value9 = _g8
		value10 = value9
		_g5.h["res1"] = value10
		value11 = None
		_g9 = haxe_ds_StringMap()
		_g9.h["field"] = "res2Id"
		_g9.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g9.h["fk_field"] = "id"
		value11 = _g9
		value12 = value11
		_g5.h["res2"] = value12
		value13 = None
		_g10 = haxe_ds_StringMap()
		_g10.h["field"] = "constructPlateId"
		_g10.h["class"] = "saturn.core.domain.SgcConstructPlate"
		_g10.h["fk_field"] = "id"
		value13 = _g10
		value14 = value13
		_g5.h["constructPlate"] = value14
		value4 = _g5
		_g1.h["fields.synthetic"] = value4
		value15 = None
		_g11 = haxe_ds_StringMap()
		_g11.h["schema"] = "SGC"
		_g11.h["name"] = "CONSTRUCT"
		value15 = _g11
		_g1.h["table_info"] = value15
		value = _g1
		_g.h["saturn.core.domain.SgcConstruct"] = value
		value16 = None
		_g12 = haxe_ds_StringMap()
		value17 = None
		_g13 = haxe_ds_StringMap()
		_g13.h["alleleId"] = "ALLELE_ID"
		_g13.h["allelePlateId"] = "SGCPLATE_PKEY"
		_g13.h["id"] = "PKEY"
		_g13.h["entryCloneId"] = "SGCENTRYCLONE_PKEY"
		_g13.h["forwardPrimerId"] = "SGCPRIMER5_PKEY"
		_g13.h["reversePrimerId"] = "SGCPRIMER3_PKEY"
		_g13.h["dnaSeq"] = "ALLELESEQUENCERAW"
		_g13.h["proteinSeq"] = "ALLELEPROTSEQ"
		_g13.h["status"] = "ALLELE_STATUS"
		_g13.h["location"] = "SGCLOCATION"
		_g13.h["comments"] = "ALLELECOMMENTS"
		_g13.h["elnId"] = "ELNEXP"
		_g13.h["dateStamp"] = "DATESTAMP"
		_g13.h["person"] = "PERSON"
		_g13.h["plateWell"] = "PLATEWELL"
		_g13.h["dnaSeqLen"] = "ALLELESEQLENGTH"
		_g13.h["complex"] = "COMPLEX"
		_g13.h["domainSummary"] = "DOMAINSUMMARY"
		_g13.h["domainStartDelta"] = "DOMAINSTARTDELTA"
		_g13.h["domainStopDelta"] = "DOMAINSTOPDELTA"
		_g13.h["containsPharmaDomain"] = "CONTAINSPHARMADOMAIN"
		_g13.h["domainSummaryLong"] = "DOMAINSUMMARYLONG"
		_g13.h["impPI"] = "IMPPI"
		value17 = _g13
		_g12.h["fields"] = value17
		value18 = None
		_g14 = haxe_ds_StringMap()
		_g14.h["status"] = "In process"
		value18 = _g14
		_g12.h["defaults"] = value18
		value19 = None
		_g15 = haxe_ds_StringMap()
		_g15.h["Allele ID"] = "alleleId"
		_g15.h["Plate"] = "plate.plateName"
		_g15.h["Entry Clone ID"] = "entryClone.entryCloneId"
		_g15.h["Forward Primer ID"] = "forwardPrimer.primerId"
		_g15.h["Reverse Primer ID"] = "reversePrimer.primerId"
		_g15.h["DNA Sequence"] = "dnaSeq"
		_g15.h["Protein Sequence"] = "proteinSeq"
		_g15.h["Status"] = "status"
		_g15.h["Location"] = "location"
		_g15.h["Comments"] = "comments"
		_g15.h["ELN ID"] = "elnId"
		_g15.h["Date Record"] = "dateStamp"
		_g15.h["Person"] = "person"
		_g15.h["Plate Well"] = "plateWell"
		_g15.h["DNA Length"] = "dnaSeqLen"
		_g15.h["Complex"] = "complex"
		_g15.h["Domain Summary"] = "domainSummary"
		_g15.h["Domain  Start Delta"] = "domainStartDelta"
		_g15.h["Domain Stop Delta"] = "domainStopDelta"
		_g15.h["Contains Pharma Domain"] = "containsPharmaDomain"
		_g15.h["Domain Summary Long"] = "domainSummaryLong"
		_g15.h["IMP PI"] = "impPI"
		_g15.h["__HIDDEN__PKEY__"] = "id"
		value19 = _g15
		_g12.h["model"] = value19
		value20 = None
		_g16 = haxe_ds_StringMap()
		_g16.h["alleleId"] = False
		_g16.h["id"] = True
		value20 = _g16
		_g12.h["indexes"] = value20
		value21 = None
		_g17 = haxe_ds_StringMap()
		value22 = None
		_g18 = haxe_ds_StringMap()
		_g18.h["field"] = "entryCloneId"
		_g18.h["class"] = "saturn.core.domain.SgcEntryClone"
		_g18.h["fk_field"] = "id"
		value22 = _g18
		value23 = value22
		_g17.h["entryClone"] = value23
		value24 = None
		_g19 = haxe_ds_StringMap()
		_g19.h["field"] = "forwardPrimerId"
		_g19.h["class"] = "saturn.core.domain.SgcForwardPrimer"
		_g19.h["fk_field"] = "id"
		value24 = _g19
		value25 = value24
		_g17.h["forwardPrimer"] = value25
		value26 = None
		_g20 = haxe_ds_StringMap()
		_g20.h["field"] = "reversePrimerId"
		_g20.h["class"] = "saturn.core.domain.SgcReversePrimer"
		_g20.h["fk_field"] = "id"
		value26 = _g20
		value27 = value26
		_g17.h["reversePrimer"] = value27
		value28 = None
		_g21 = haxe_ds_StringMap()
		_g21.h["field"] = "allelePlateId"
		_g21.h["class"] = "saturn.core.domain.SgcAllelePlate"
		_g21.h["fk_field"] = "id"
		value28 = _g21
		value29 = value28
		_g17.h["plate"] = value29
		value21 = _g17
		_g12.h["fields.synthetic"] = value21
		value30 = None
		_g22 = haxe_ds_StringMap()
		_g22.h["schema"] = "SGC"
		_g22.h["name"] = "ALLELE"
		value30 = _g22
		_g12.h["table_info"] = value30
		value16 = _g12
		_g.h["saturn.core.domain.SgcAllele"] = value16
		value31 = None
		_g23 = haxe_ds_StringMap()
		value32 = None
		_g24 = haxe_ds_StringMap()
		_g24.h["enzymeName"] = "RESTRICTION_ENZYME_NAME"
		_g24.h["cutSequence"] = "RESTRICTION_ENZYME_SEQUENCERAW"
		_g24.h["id"] = "PKEY"
		value32 = _g24
		_g23.h["fields"] = value32
		value33 = None
		_g25 = haxe_ds_StringMap()
		_g25.h["enzymeName"] = False
		_g25.h["id"] = True
		value33 = _g25
		_g23.h["indexes"] = value33
		value34 = None
		_g26 = haxe_ds_StringMap()
		_g26.h["schema"] = "SGC"
		_g26.h["name"] = "RESTRICTION_ENZYME"
		value34 = _g26
		_g23.h["table_info"] = value34
		value31 = _g23
		_g.h["saturn.core.domain.SgcRestrictionSite"] = value31
		value35 = None
		_g27 = haxe_ds_StringMap()
		value36 = None
		_g28 = haxe_ds_StringMap()
		_g28.h["vectorId"] = "VECTOR_NAME"
		_g28.h["Id"] = "PKEY"
		_g28.h["vectorSequence"] = "VECTORSEQUENCERAW"
		_g28.h["vectorComments"] = "VECTORCOMMENTS"
		_g28.h["proteaseName"] = "PROTEASE_NAME"
		_g28.h["proteaseCutSequence"] = "PROTEASE_CUTSEQUENCE"
		_g28.h["proteaseProduct"] = "PROTEASE_PRODUCT"
		_g28.h["antibiotic"] = "ANTIBIOTIC"
		_g28.h["organism"] = "ORGANISM"
		_g28.h["res1Id"] = "SGCRESTRICTENZ1_PKEY"
		_g28.h["res2Id"] = "SGCRESTRICTENZ2_PKEY"
		value36 = _g28
		_g27.h["fields"] = value36
		value37 = None
		_g29 = haxe_ds_StringMap()
		_g29.h["vectorId"] = False
		_g29.h["Id"] = True
		value37 = _g29
		_g27.h["indexes"] = value37
		value38 = None
		_g30 = haxe_ds_StringMap()
		value39 = None
		_g31 = haxe_ds_StringMap()
		_g31.h["field"] = "res1Id"
		_g31.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g31.h["fk_field"] = "id"
		value39 = _g31
		value40 = value39
		_g30.h["res1"] = value40
		value41 = None
		_g32 = haxe_ds_StringMap()
		_g32.h["field"] = "res2Id"
		_g32.h["class"] = "saturn.core.domain.SgcRestrictionSite"
		_g32.h["fk_field"] = "id"
		value41 = _g32
		value42 = value41
		_g30.h["res2"] = value42
		value38 = _g30
		_g27.h["fields.synthetic"] = value38
		value43 = None
		_g33 = haxe_ds_StringMap()
		_g33.h["schema"] = "SGC"
		_g33.h["name"] = "VECTOR"
		value43 = _g33
		_g27.h["table_info"] = value43
		value35 = _g27
		_g.h["saturn.core.domain.SgcVector"] = value35
		value44 = None
		_g34 = haxe_ds_StringMap()
		value45 = None
		_g35 = haxe_ds_StringMap()
		_g35.h["primerId"] = "PRIMERNAME"
		_g35.h["id"] = "PKEY"
		_g35.h["dnaSequence"] = "PRIMERRAWSEQUENCE"
		value45 = _g35
		_g34.h["fields"] = value45
		value46 = None
		_g36 = haxe_ds_StringMap()
		_g36.h["primerId"] = False
		_g36.h["id"] = True
		value46 = _g36
		_g34.h["indexes"] = value46
		value47 = None
		_g37 = haxe_ds_StringMap()
		_g37.h["schema"] = "SGC"
		_g37.h["name"] = "PRIMER"
		value47 = _g37
		_g34.h["table_info"] = value47
		value44 = _g34
		_g.h["saturn.core.domain.SgcForwardPrimer"] = value44
		value48 = None
		_g38 = haxe_ds_StringMap()
		value49 = None
		_g39 = haxe_ds_StringMap()
		_g39.h["primerId"] = "PRIMERNAME"
		_g39.h["id"] = "PKEY"
		_g39.h["dnaSequence"] = "PRIMERRAWSEQUENCE"
		value49 = _g39
		_g38.h["fields"] = value49
		value50 = None
		_g40 = haxe_ds_StringMap()
		_g40.h["primerId"] = False
		_g40.h["id"] = True
		value50 = _g40
		_g38.h["indexes"] = value50
		value51 = None
		_g41 = haxe_ds_StringMap()
		_g41.h["schema"] = "SGC"
		_g41.h["name"] = "PRIMERREV"
		value51 = _g41
		_g38.h["table_info"] = value51
		value48 = _g38
		_g.h["saturn.core.domain.SgcReversePrimer"] = value48
		value52 = None
		_g42 = haxe_ds_StringMap()
		value53 = None
		_g43 = haxe_ds_StringMap()
		_g43.h["sequence"] = "SEQ"
		_g43.h["id"] = "PKEY"
		_g43.h["type"] = "SEQTYPE"
		_g43.h["version"] = "TARGETVERSION"
		_g43.h["targetId"] = "SGCTARGET_PKEY"
		_g43.h["crc"] = "CRC"
		_g43.h["target"] = "TARGET_ID"
		value53 = _g43
		_g42.h["fields"] = value53
		value54 = None
		_g44 = haxe_ds_StringMap()
		_g44.h["id"] = True
		value54 = _g44
		_g42.h["indexes"] = value54
		value55 = None
		_g45 = haxe_ds_StringMap()
		_g45.h["schema"] = ""
		_g45.h["name"] = "SEQDATA"
		value55 = _g45
		_g42.h["table_info"] = value55
		value52 = _g42
		_g.h["saturn.core.domain.SgcSeqData"] = value52
		value56 = None
		_g46 = haxe_ds_StringMap()
		value57 = None
		_g47 = haxe_ds_StringMap()
		_g47.h["id"] = "PKEY"
		_g47.h["accession"] = "IDENTIFIER"
		_g47.h["start"] = "SEQSTART"
		_g47.h["stop"] = "SEQSTOP"
		_g47.h["targetId"] = "SGCTARGET_PKEY"
		value57 = _g47
		_g46.h["fields"] = value57
		value58 = None
		_g48 = haxe_ds_StringMap()
		_g48.h["accession"] = False
		_g48.h["id"] = True
		value58 = _g48
		_g46.h["indexes"] = value58
		value56 = _g46
		_g.h["saturn.core.domain.SgcDomain"] = value56
		value59 = None
		_g49 = haxe_ds_StringMap()
		value60 = None
		_g50 = haxe_ds_StringMap()
		_g50.h["id"] = "PKEY"
		_g50.h["plateName"] = "PLATENAME"
		_g50.h["elnRef"] = "ELNREF"
		value60 = _g50
		_g49.h["fields"] = value60
		value61 = None
		_g51 = haxe_ds_StringMap()
		_g51.h["plateName"] = False
		_g51.h["id"] = True
		value61 = _g51
		_g49.h["indexes"] = value61
		value62 = None
		_g52 = haxe_ds_StringMap()
		_g52.h["schema"] = "SGC"
		_g52.h["name"] = "CONSTRUCTPLATE"
		value62 = _g52
		_g49.h["table_info"] = value62
		value59 = _g49
		_g.h["saturn.core.domain.SgcConstructPlate"] = value59
		value63 = None
		_g53 = haxe_ds_StringMap()
		value64 = None
		_g54 = haxe_ds_StringMap()
		_g54.h["id"] = "PKEY"
		_g54.h["plateName"] = "PLATENAME"
		_g54.h["elnRef"] = "ELNREF"
		value64 = _g54
		_g53.h["fields"] = value64
		value65 = None
		_g55 = haxe_ds_StringMap()
		_g55.h["plateName"] = False
		_g55.h["id"] = True
		value65 = _g55
		_g53.h["indexes"] = value65
		value66 = None
		_g56 = haxe_ds_StringMap()
		_g56.h["schema"] = "SGC"
		_g56.h["name"] = "PLATE"
		value66 = _g56
		_g53.h["table_info"] = value66
		value63 = _g53
		_g.h["saturn.core.domain.SgcAllelePlate"] = value63
		value67 = None
		_g57 = haxe_ds_StringMap()
		value68 = None
		_g58 = haxe_ds_StringMap()
		_g58.h["targetId"] = "SEQUENCE_ID"
		_g58.h["id"] = "PKEY"
		_g58.h["dnaSeq"] = "DNA_SEQ"
		_g58.h["proteinSeq"] = "PROTEIN_SEQ"
		value68 = _g58
		_g57.h["fields"] = value68
		value69 = None
		_g59 = haxe_ds_StringMap()
		_g59.h["targetId"] = False
		_g59.h["id"] = True
		value69 = _g59
		_g57.h["indexes"] = value69
		value70 = None
		_g60 = haxe_ds_StringMap()
		_g60.h["schema"] = ""
		_g60.h["name"] = "DNA"
		value70 = _g60
		_g57.h["table_info"] = value70
		value71 = None
		_g61 = haxe_ds_StringMap()
		_g61.h["ID"] = "targetId"
		_g61.h["DNA Sequence"] = "dnaSeq"
		_g61.h["Protein Sequence"] = "proteinSeq"
		_g61.h["__HIDDEN__PKEY__"] = "id"
		value71 = _g61
		_g57.h["model"] = value71
		value72 = None
		_g62 = haxe_ds_StringMap()
		_g62.h["polymorph_key"] = "POLYMORPH_TYPE"
		_g62.h["value"] = "TARGET"
		value72 = _g62
		_g57.h["selector"] = value72
		value67 = _g57
		_g.h["saturn.core.domain.SgcTarget"] = value67
		value73 = None
		_g63 = haxe_ds_StringMap()
		value74 = None
		_g64 = haxe_ds_StringMap()
		_g64.h["entryCloneId"] = "SEQUENCE_ID"
		_g64.h["id"] = "PKEY"
		_g64.h["dnaSeq"] = "DNA_SEQ"
		value74 = _g64
		_g63.h["fields"] = value74
		value75 = None
		_g65 = haxe_ds_StringMap()
		_g65.h["entryCloneId"] = False
		_g65.h["id"] = True
		value75 = _g65
		_g63.h["indexes"] = value75
		value76 = None
		_g66 = haxe_ds_StringMap()
		_g66.h["schema"] = ""
		_g66.h["name"] = "DNA"
		value76 = _g66
		_g63.h["table_info"] = value76
		value77 = None
		_g67 = haxe_ds_StringMap()
		_g67.h["ID"] = "entryCloneId"
		_g67.h["DNA Sequence"] = "dnaSeq"
		_g67.h["__HIDDEN__PKEY__"] = "id"
		value77 = _g67
		_g63.h["model"] = value77
		value78 = None
		_g68 = haxe_ds_StringMap()
		_g68.h["polymorph_key"] = "POLYMORPH_TYPE"
		_g68.h["value"] = "ENTRY_CLONE"
		value78 = _g68
		_g63.h["selector"] = value78
		value73 = _g63
		_g.h["saturn.core.domain.SgcEntryClone"] = value73
		return _g
	return _hx_local_0()
saturn_db_mapping_SQLiteMapping.models = _hx_init_saturn_db_mapping_SQLiteMapping_models()
saturn_db_query_lang_SQLVisitor.injection_check = EReg("^([A-Za-z0-9\\.])+$", "")

saturn_app_PythonExport.main()