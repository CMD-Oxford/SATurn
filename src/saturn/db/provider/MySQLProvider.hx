/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.provider;

import saturn.db.provider.GenericRDBMSProvider;

import js.Node;

class MySQLProvider extends GenericRDBMSProvider{

    public function new(models : Map<String,Map<String,Map<String,Dynamic>>>, config : Dynamic, autoClose : Bool){
        super(models, config, autoClose);
    }

    override public function getColumns(connection : Dynamic, schemaName : String, tableName : String, cb:String->Array<String>->Void) : Void{
        connection.query('DESCRIBE ' + schemaName + '.' + tableName,[],function(err,rows : Array<Dynamic>){
            if(err != null){
                debug('Got DESCRIBE exception on  ' + tableName);
                cb(err,null);
            }else{
                var cols = new Array<String>();
                for(row in rows){
                    cols.push(row.Field);
                }

                cb(null, cols);
            }
        });
    }

    override public function getProviderType() : String{
        return 'MYSQL';
    }

    override public function _closeConnection(){
        debug('Closing connection!');

        if(theConnection != null){
            var d : Dynamic = theConnection;

            debug(Reflect.fields(d));

            d.close();

            theConnection = null;
        }
    }

    override public function limitAtEndPosition(){
        return true;
    }

    override public function generateLimitClause(limit){
        return ' limit ' + Std.int(limit);
    }

    override public function generateQualifiedName(schemaName : String, tableName : String) : String{
        return  schemaName + '.' + tableName;
    }

    override public function _getConnection(cb : String->Connection->Void){
        debug('Obtaining MySQL theDB');

        try{
            var mysql = Node.require('mysql2');

            var connection :Dynamic = mysql.createConnection({
                host: config.host,
                user: user.username,
                password: user.password,
                database: config.database
            });

            debug('Connecting to ' + config.database + ' as ' + user.username + ' with password ' + user.password + ' on host ' + config.host );

            connection.on('connect',function(connect) {
                if (connect) {
                    debug('Connected');
                    connection.execute = connection.query;
                    cb(null, connection);
                }else{
                    debug('Unable to connect');

                    cb('Unable to connect', null);
                }
            });

            connection.on('error', function(err : Dynamic){
                debug('Error connecting ' + err);
                if(!err.fatal){
                    return;
                }

                if(err.code != 'PROTOCOL_CONNECTION_LOST'){
                    throw err;
                }

                debug('Reconnecting!!!!');

                _getConnection(function(err : String, conn : Connection){
                    if(err != null){
                        throw 'Unable to reconnect MySQL session';
                    }else{
                        this.theConnection = conn;
                    }
                });
            });
        }catch(e : Dynamic){
            debug('Error' + e);
            cb(e,null); return;
        }
    }

    /*
     * used by saturn CRUD functionality to query MySQL db
     */
    override function dbSpecificParamPlaceholder(i: Int) : String {
        return '?';
    }
}