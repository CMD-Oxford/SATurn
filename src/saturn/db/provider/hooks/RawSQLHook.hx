/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.provider.hooks;
import haxe.Json;
import saturn.core.Util;

#if CLIENT_SIDE

#elseif NODE
import js.Node.NodeChildProcess;
import bindings.NodeTemp;
#end

class RawSQLHook {
    public static function run(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void, hookConfig : Map<String, Dynamic>){
        var sql = params[0];
        var args = params[1];

        Util.getProvider().getConnection(null, function(err : String, conn : Dynamic){

            conn.execute(sql, args, function(err, results){

                cb(results, err);
            });
        });
    }
}
