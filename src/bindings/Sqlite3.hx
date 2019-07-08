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

@:native('Sqlite3')
extern class Sqlite3 {
    static var lib;

    private static function __init__() : Void untyped {
        #if SQLITE
        var Sqlite3 = untyped __js__("require('sqlite3')").verbose().Database;
        #end
    }

    public function new(databaseName: String);
}