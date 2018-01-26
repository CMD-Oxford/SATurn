/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.query_lang;

import saturn.db.query_lang.IsNotNull;
import saturn.core.Util;
import saturn.util.HaxeException;
import haxe.Serializer;
import haxe.Unserializer;

#if python
import python.Syntax;
#end

class Query extends Token{
    public var selectToken : Select;
    public var fromToken : From;
    public var whereToken : Where;
    public var groupToken : Group;
    public var orderToken : OrderBy;
    public var provider : Provider;
    public var rawResults : Bool;

    //Paging properties
    public var pageOn : Token;
    public var pageSize : Token;
    public var lastPagedRowValue : Token;

    public function new(provider : Provider) {
        super(null);

        this.provider = provider;

        selectToken = new Select();
        whereToken = new Where();
        fromToken = new From();
        groupToken = new Group();
        orderToken = new OrderBy();
    }

    /**
    * Set the token that you would like to control paging with (typically a field token but could be any token)
    **/
    public function setPageOnToken(t : Token) : Void{
        pageOn = t;
    }

    /**
    * Get the token that will be used for paging (typically a field token but could be any token)
    **/
    public function getPageOnToken() : Token{
        return pageOn;
    }

    /**
    * Set the value of the last row for the paged field (typically a value token but could be any token)
    **/
    public function setLastPagedRowValue(t : Token) : Void{
        lastPagedRowValue = t;
    }

    /**
    * Get the value of the last row for the paged field (typically a value token but could be any token)
    **/
    public function getLastPagedRowValue() : Token{
        return lastPagedRowValue;
    }

    public function setPageSize(t : Token) : Void{
        pageSize = t;
    }

    public function getPageSize() : Token{
        return pageSize;
    }

    public function isPaging() : Bool{
        return pageOn != null && pageSize != null;
    }

    /**
    * enable paging by setting the token you would like to page with along with the page size
    **/
    public function configurePaging(pageOn : Token, pageSize : Token){
        this.pageOn = pageOn;
        this.pageSize = pageSize;
    }

    public function fetchRawResults()  {
        this.rawResults = true;
    }

    public function bindResults(){
        return !this.rawResults;
    }

    override public function getTokens() : Array<Token> {
        var tokens = new Array<Token>();

        //fromToken = new From();

        var checkTokens = [selectToken, whereToken];

        for(token in checkTokens){
            addClassToken(token);
        }

        if(fromToken.getTokens() != null){
            var seen = new Map<String, String>();
            var tokens = new Array<Token>();
            for(token in fromToken.getTokens()){
                if(Std.is(token, ClassToken)){
                    var cToken = cast(token, ClassToken);
                    if(cToken.getClass() != null){
                        var clazzName = cToken.getClass();
                        if(!seen.exists(clazzName)){
                            tokens.push(cToken);
                            seen.set(clazzName, '');
                        }
                    }else{
                        tokens.push(cToken);
                    }
                }else{
                    tokens.push(token);
                }
            }

            fromToken.setTokens(tokens);
            Util.print('Num targets' + fromToken.getTokens().length);
        }

        tokens.push(selectToken);
        tokens.push(fromToken);

        if(whereToken.getTokens() != null && whereToken.getTokens().length > 0){
            tokens.push(whereToken);

            if(isPaging() && lastPagedRowValue != null){
                tokens.push(new And());
                tokens.push(pageOn);
                tokens.push(new GreaterThan());
                tokens.push(lastPagedRowValue);
            }
        }

        if(groupToken.getTokens() != null && groupToken.getTokens().length > 0){
            tokens.push(groupToken);
        }

        if(orderToken.getTokens() != null && orderToken.getTokens().length >0){
            tokens.push(orderToken);
        }

        // Handle order by and limit required for paging
        if(isPaging()){
            tokens.push(new OrderBy());
            tokens.push(new OrderByItem(pageOn));
            tokens.push(new Limit(pageSize));
        }

        if(this.tokens != null && this.tokens.length > 0){
            for(token in this.tokens){
                tokens.push(token);
            }
        }

        return tokens;
    }

    /*override public function setTokens(token : Array<Token>) : Void {
        throw new HaxeException("Can't call setTokens on a Query instance");
    }

    override public function addToken(token : Token) : Token {
        throw new HaxeException("Can't call addToken on a query instance");
    }*/

    public function or() {
        getWhere().addToken(new Or());
    }

    public function and(){
        getWhere().addToken(new And());
    }

    public function equals(clazz : Class<Dynamic>, field : String, value : Dynamic ){
        getWhere().addToken(new Field(clazz, field));
        getWhere().addToken(new Equals());
        getWhere().addToken(new Value(value));
    }

    public function select(clazz : Class<Dynamic>, field : String){
        getSelect().addToken(new Field(clazz, field));
    }

    public function getSelect() : Select {
        return selectToken;
    }

    public function getFrom() : From {
        return fromToken;
    }

    public function getWhere() : Where {
        return whereToken;
    }

    public function getGroup() : Group {
        return groupToken;
    }

    public function clone() : Query{
        var str = serialise();
        return deserialise(str);
    }

    public  function serialise() : String{
        var keepMe = provider;
        provider = null;

        #if PYTHON
        untyped Syntax.pythonCode('import pickle');
        var newMe = untyped Syntax.pythonCode('pickle.dumps(self)');
        #else
        var newMe = Serializer.run(this);
        #end
        provider = keepMe;

        return newMe;
    }

    public function __getstate__(){
        var state = untyped Syntax.pythonCode('dict(self.__dict__)');
        untyped Syntax.pythonCode('del state[\'provider\']');
        return state;
    }

    public static function deserialise(querySer : String) : Query{
        #if PYTHON
        untyped Syntax.pythonCode('import pickle');
        var clone = untyped Syntax.pythonCode('pickle.loads(querySer)');
        #else
        var clone :Query = Unserializer.run(querySer);

        //The Haxe serializer doesn't restore class instances correctly which is required for binding
        deserialiseToken(clone);
        #end

        return clone;
    }

    public static function deserialiseToken(token : Token){
        if(token == null){
            return;
        }

        /*if(Std.is(token, Field)){
            var cToken = cast(token, Field);

            var clazz = cToken.getClass();
            if(clazz != null){
                cToken.setClass(Type.resolveClass(Type.getClassName(clazz)));
            }
        }*/

        if(token.getTokens() != null){
            for(token in token.getTokens()){
                deserialiseToken(token);
            }
        }

        if(Std.is(token, Query)){
            var qToken = cast(token, Query);
            qToken.provider = null;
        }
    }

    public function run(cb : Array<Dynamic>->String->Void) : Void{
        var clone = clone();

        clone.provider = null;

        /*if(provider.isDataBinding()){
            unbindFields(clone);
        }*/

        clone.getTokens();

        provider.query(clone, function(objs: Array<Dynamic>, err : String){
            // Handling paging
            if(err == null && objs.length > 0 && isPaging()){
                var fieldName = null;
                if(pageOn.name != null){
                    //Handle alises
                    fieldName = pageOn.name;
                }else if(Std.is(pageOn, Field)){
                    //Handle field tokens
                    var fToken = cast(pageOn, Field);

                    fieldName = fToken.getAttributeName();
                }

                if(fieldName == null){
                    err = 'Unable to determine value of last paged row';
                }else{
                    setLastPagedRowValue(new Value(Reflect.field(objs[objs.length-1], fieldName)));
                }
            }

            cb(objs, err);
        });
    }

    public function getSelectClassList() : Array<String>{
        var set : Map<String, String> = new Map<String, String>();

        for(token in selectToken.getTokens()){
            if(Std.is(token, Field)){
                var cToken = cast(token, Field);
                var clazz = cToken.getClass();

                if(clazz != null){
                    set.set(clazz, clazz);
                }
            }
        }

        var list : Array<String> = new Array<String>();
        for(className in set.keys()){
            list.push(set.get(className));
        }

        return list;
    }

    public function unbindFields(token : Token){
        if(token == null){
            return;
        }

        if(Std.is(token, Field)){
            var cToken = cast(token, Field);

            var clazz = cToken.getClass();
            var field = cToken.getAttributeName();

            var model = provider.getModelByStringName(clazz);

            if(model != null){
                if(field != '*'){
                    var unboundFieldName = model.unbindFieldName(field);
                    cToken.setAttributeName(unboundFieldName);
                }
            }
        }

        if(token.getTokens() != null){
            for(token in token.getTokens()){
                unbindFields(token);
            }
        }
    }

    public function addClassToken(token : Token) :Void {
        if(Std.is(token, Query) || token == null){
            return;
        }

        if(Std.is(token, Field)){
            var fToken = cast(token, Field);
            if(fToken.getClass() != null){
                var cToken = new ClassToken(fToken.getClass());

                if(fToken.clazzAlias != null){
                    cToken.name = fToken.clazzAlias;
                }

                fromToken.addToken(cToken);
            }
        }

        if(token.getTokens() != null){
            for(token in token.getTokens()){
                addClassToken(token);
            }
        }

    }

    /*public function getClassList() : Array<Class<Dynamic>>{

        var list = new Array<Class<Dynamic>>();

        if(fromToken != null){
            var tokens = fromToken.getTokens();
            if(tokens != null)
                for(token in tokens){{
                    if(Std.is(token, ClassToken)){
                        var cToken = cast(token, ClassToken);
                        list.push(cToken.getClass());
                    }else if(Std.is(token, Query)){
                        var qToken = cast(token, Query);
                        var qList = qToken.getClassList();

                        for(clazz in qList){
                            list.push(clazz);
                        }
                    }
                }
            }
        }

        return list;
    }*/

    public function addExample(obj : Dynamic, ?fieldList : Array<String> = null){
        var clazz = Type.getClass(obj);
        var model = provider.getModel(clazz);

        if(fieldList != null){
            if(fieldList.length > 0){
                for(field in fieldList){
                    getSelect().addToken(new Field(clazz, field));
                }
            }
        }else{
            getSelect().addToken(new Field(clazz, '*'));
        }

        var fields = model.getFields();

        var hasPrevious = false;

        getWhere().addToken(new StartBlock());

        for(i in 0...fields.length){
            var field = fields[i];
            var value = Reflect.field(obj, field);

            if(value != null){
                if(hasPrevious){
                    getWhere().addToken(new And());
                }

                getWhere().addToken(new Field(clazz, field));

                getWhere().addToken(new Equals());

                if(Std.is(value, IsNull)){
                    Util.print('Found NULL');
                    getWhere().addToken(new IsNull());
                }else if(Std.is(value, IsNotNull)){
                    getWhere().addToken(new IsNotNull());
                }else{
                    Util.print('Found value' + Type.getClassName(Type.getClass(value)));
                    getWhere().addToken(new Value(value));
                }

                hasPrevious = true;
            }
        }

        getWhere().addToken(new EndBlock());
    }
}
