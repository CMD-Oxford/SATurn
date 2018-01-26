/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.provider;

import bindings.NodePostgres;
import saturn.core.User;
import saturn.db.provider.GenericRDBMSProvider;

import js.Node;

class PostgreSQLProvider extends GenericRDBMSProvider{

    public function new(models : Map<String,Map<String,Map<String,Dynamic>>>, config : Dynamic, autoClose : Bool){
        super(models, config, autoClose);
    }

    override public function getProviderType() : String{
        return 'PGSQL';
    }

    override public function getColumns(connection : Dynamic, schemaName : String, tableName : String, cb:String->Array<String>->Void) : Void{

        connection.execute("
            SELECT
                column_name
            FROM
                INFORMATION_SCHEMA.columns
            WHERE
                LOWER(table_schema)=LOWER($1) AND
                LOWER(table_name)=LOWER($2)",
            [schemaName, tableName],
            function(err,rows : Array<Dynamic>){
                var cols = new Array<String>();
                for(row in rows){
                    cols.push(row.column_name);
                }

                cb(null, cols);
            }
        );
    }

    override private function limitAtEndPosition(){
        return true;
    }

    override public function dbSpecificParamPlaceholder(i: Int) : String {
        return '$' + i;
    }

    override public function generateLimitClause(limit){
        return ' LIMIT ' + Std.int(limit);
    }

    override private function columnToStringCommand(columnName : String){
        return ' cast(' + columnName + ' as TEXT) ';
    }

    override public function _getConnection(cb : String->Connection->Void){
        var conString = "postgres://" + user.username + ":" + user.password + "@" + config.host + "/" + config.database;

        var pg = Node.require('pg');


        pg.connect(conString, function(err, client : Dynamic) {
            if(err != null) {
                debug('Error connecting to PostgreSQL');
                cb(err, null);
            }else{
                client.execute = function(sql, args, cb){
                    client.query(sql, args, function(err, results){
                        if(err == null){
                            cb(null, results.rows);
                        }else{
                            cb(err, null);
                        }
                    });
                };

                cb(null, client);
            }
        });
    }
}