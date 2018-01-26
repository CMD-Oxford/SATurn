/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.query_lang;
import saturn.core.Util;
class Token {
    public var tokens : Array<Token>;
    public var name : String;

    public function new(?tokens : Array<Token> = null) {
        this.tokens = tokens;

        if(this.tokens != null){
            for(i in 0...this.tokens.length){
                var value = this.tokens[i];

                if(value != null){
                    if(!Std.is(value, Token)){
                        this.tokens[i] = new Value(value);
                    }
                }
            }
        }
    }

    public function as(name : String) : Token{
        this.name = name;

        return this;
    }

    public function getTokens() : Array<Token> {
        return this.tokens;
    }

    public function setTokens(tokens : Array<Token>) : Void {
        this.tokens = tokens;
    }

    public function addToken(token : Token) : Token {
        if(tokens == null){
            tokens = new Array<Token>();
        }
        this.tokens.push(token);

        return this;
    }

    public function field(clazz : Class<Dynamic>, attributeName : String, ?clazzAlias : String = null) : Token{
        var f = new Field(clazz, attributeName, clazzAlias);

        add(f);

        return f;
    }

    public function add(token : Token) : Token{
        if(Std.is(token, Operator)){
            var n = new Token();
            n.add(this);
            n.tokens.push(token);

            return n;
        }else{
            return addToken(token);
        }
    }

    public function removeToken(token : Token) : Void{
        tokens.remove(token);
    }

    public function like(?token : Token=null) : Token{
        var l = new Like();

        if(token != null){
            l.add(token);
        }

        return add(l);
    }

    public function concat(?token : Dynamic=null) : Token {
        var c = new Concat(token);

        //if(token != null){
        //    c.add(token);
       // }

        return add(c);
    }

    public function substr(position : Dynamic, length: Dynamic) : Token {
        return new Substr(this, position, length);
    }

    public function instr(substring : Dynamic, ?position : Dynamic=null, ?occurrence : Dynamic=null) : Token {
        return new Instr(this, substring, position, occurrence);
    }

    public function max() : Token {
        return new Max(this);
    }

    public function length() : Token{
        return new Length(this);
    }

    public function plus(?token : Dynamic=null) : Token {
        var c = new Plus(token);

        //if(token != null){
        //    c.add(token);
        //}

        return add(c);
    }

    public function minus(?token : Dynamic=null) : Token {
        var c = new Minus(token);

        //if(token != null){
        //    c.add(token);
        //}

        return add(c);
    }

    public function getClassList() : Array<String>{
        var list = new Array<String>();
        var tokens = getTokens();
        if(tokens != null && tokens.length > 0){
            for(token in tokens){

                if(Std.is(token, ClassToken)){
                    var cToken = cast(token, ClassToken);
                    if(cToken.getClass() != null){
                        list.push(cToken.getClass());
                    }
                }else{
                    var list2 = token.getClassList();
                    for(item in list2){
                        list.push(item);
                    }
                }
            }
        }
        return list;
    }


}
