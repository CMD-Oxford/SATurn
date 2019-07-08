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

class NodeTemp {
    static var temp : Dynamic;

    public static function open(prefix : String, cb:Dynamic->Dynamic->Void) : Int{
        return temp.open(prefix, cb);
    }

    public static function open_untracked(prefix : String, cb:Dynamic->Dynamic->Void) : Int{
        var filePath = temp.path(prefix);

        var cnst = Node.require('constants');

        var RDWR_EXCL = cnst.O_CREAT | cnst.O_TRUNC | cnst.O_RDWR | cnst.O_EXCL;

        Node.require('fs').open(filePath, RDWR_EXCL, untyped parseInt('0600', 8), function(err, fd) {
            if (cb != null) {
                cb(err, {path: filePath, fd: fd});
            }
        });

        return 1;
    }

    public static function __init__(){
        temp = untyped __js__("require('temp')");
    }
}