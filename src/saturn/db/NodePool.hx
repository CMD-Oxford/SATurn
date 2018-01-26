/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

import js.Node;

class NodePool {
    /**
    *
    * name : Pool Name
    * max : Maximum size of Pool
    * min : Minimum size of Pool
    * idleTimeout : Idle timeout
    * log : Enable logging
    * createCb : Callback to create an item for the Pool
    *           function(cb){
    *               var client = new Client();
    *               client.connect(function(err){
    *                   if(err){
    *                       cb('Error connecting',null);
    *                   }else{
    *                       cb(null, client);
    *                   }
    *               });
    *           }
    * destroyCb : Callback to cleanup a resource
    *           function(client){
    *               client.close();
    *           }
    **/
    public static function generatePool(name : String, max : Int, min : Int, idleTimeout : Int, log : Bool, createCb : Dynamic->Void, destroyCb : Dynamic->Void ) : Pool{
        var genericPool :Dynamic = Node.require('generic-pool');

        var d : Dynamic = {
            'name' : name,
            'create' : createCb,
            'destroy' : destroyCb,
            'max' : max,
            'min' : min,
            'idleTimeoutMillis' : idleTimeout,
            'log' : log
        };

        var pool :Pool = genericPool.Pool(d);

        return pool;
    }
}