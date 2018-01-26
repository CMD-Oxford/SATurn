/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

import bindings.Sqlite3;
import js.Node;
class SQLiteProvider extends GenericRDBMSProvider{
    var theDB : Dynamic;

    public function new(models : Map<String,Map<String,Map<String,Dynamic>>>, config : Dynamic, autoClose : Bool){
        super(models, config, autoClose);
    }

    override public function getColumns(connection : Dynamic, schemaName : String, tableName : String, cb:String->Array<String>->Void) : Void{
        connection.serialize(function() {
            connection.all('PRAGMA table_info('+tableName+')',[],function(err,rows : Array<Dynamic>){
                if(err != null){
                    Node.console.log('Got pragma exception on  ' + tableName);
                    cb(err,null);
                }else{
                    Node.console.log('Got columns for '  + tableName);
                    Node.console.log('cols: ' + rows);
                    var cols = new Array<String>();
                    for(row in rows){
                        cols.push(row.name);
                        Node.console.log(row.name);
                    }

                    cb(null, cols);
                }
            });
        });
    }

    override public function getProviderType() : String{
        return 'SQLITE';
    }

    override public function generateQualifiedName(schemaName : String, tableName : String) : String{
        return  tableName;
    }

    override public function getConnection(config :Dynamic, cb : String->Connection->Void){
        Node.console.log('Obtaining connection');
        if(theDB == null){
            try{
                theDB = new Sqlite3(config.file_name);
                Node.console.log('Got connection');

                theDB.execute = theDB.all;
            }catch(e : Dynamic){
                theDB = null;
                Node.console.log('Error' + e);
                cb(e,null); return;
            }
        }

        cb(null,theDB);
    }

    override private function _commit(cb : Dynamic) : Void{
        cb(null);
    }

    override public  function closeConnection(connection : Dynamic){
        //if(autoClose){
        //    connection.close();
        //}
    }

    /*
    override private function beginTransaction(connection : Connection, cb:String->Void){
        connection.execute('begin transaction',[],function(err){
            if(err != null){
                cb(err);
            }else{
                cb(null);
            }
        });
    }

    override private function endTransaction(connection : Connection, cb:String->Void){
        connection.execute('end transaction',[],function(err){
            if(err != null){
                cb(err);
            }else{
                cb(null);
            }
        });
    }

    override private function _rollback(connection, cb : Dynamic) : Void{
        connection.execute('rollback transaction',[],function(err){
            if(err != null){
                cb(err);
            }else{
                cb(null);
            }
        });
    }

    override private function _commit(connection, cb : Dynamic) : Void{
        connection.execute('commit transaction',[],function(err){
            if(err != null){
                cb(err);
            }else{
                cb(null);
            }
        });
    }*/
}