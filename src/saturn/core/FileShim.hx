/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

#if (CLIENT_SIDE || SERVER_SIDE || SCRIPT_ENGINE)
import js.html.ArrayBuffer;
import js.html.Uint8Array;
#end

class FileShim {
    var name : String;
    var base64 :String;

    public function new(name : String, base64 : String) {
        this.name = name;
        this.base64 = base64;
    }

    public function getAsText() : String{
        #if !PYTHON
        return js.Browser.window.atob(this.base64);
        #else
        return '';
        #end
    }

    public function getAsArrayBuffer() : Dynamic{
        #if (CLIENT_SIDE || SERVER_SIDE || SCRIPT_ENGINE)
        var bstr = js.Browser.window.atob(this.base64);
        var buffer = new Uint8Array(bstr.length);
        for (i in 0...bstr.length) {
            buffer[i] = bstr.charCodeAt(i);
        }

        return buffer;
        #else
        return null;
        #end
    }
}