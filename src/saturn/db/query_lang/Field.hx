/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.query_lang;

class Field extends Token{
    var clazz : String;
    public var clazzAlias : String;
    public var attributeName : String;

    public function new(clazz : Dynamic, attributeName : String, ?clazzAlias : String = null) {
        setClass(clazz);

        this.attributeName = attributeName;
        this.clazzAlias = clazzAlias;

        super(null);
    }

    public function getClass() : String{
        return this.clazz;
    }

    public function setClass(clazz : Dynamic) : Void {
        if(Std.is(clazz, Class)){
            var c : Class<Dynamic> = cast(clazz, Class<Dynamic>);
            this.clazz = Type.getClassName(c);
        }else{
            this.clazz = clazz;
        }
    }

    public function getAttributeName() : String {
        return this.attributeName;
    }

    public function setAttributeName(name : String) : Void {
        this.attributeName = name;
    }
}
