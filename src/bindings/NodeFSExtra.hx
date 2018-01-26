/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package bindings;

import js.Node;

class NodeFSExtra{
    static var fsExtra;

    public static function copy(src : String, dest : String, cb:Dynamic->Void) : Void{
        return fsExtra.copy(src, dest, cb);
    }

    public static function __init__(){
        fsExtra = untyped __js__("require('fs-extra')");
    }
}