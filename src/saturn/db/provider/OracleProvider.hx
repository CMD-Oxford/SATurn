/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.provider;

import js.Node;

class OracleProvider extends GenericRDBMSProvider{

    public function new(models : Map<String,Map<String,Map<String,Dynamic>>>, config : Dynamic, autoClose : Bool) {
        super(models, config, autoClose);
    }

    override public function _getConnection(cb : String->Connection->Void){
        #if ORACLE
        debug('Opening new connection as ' + user.username);

        var oracle = Node.require('oracle'); //Node.require(oracle)
        var connString = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST="+config.host+")(PORT="+config.port+"))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME="+config.service_name+")))";
        var connectData = { "tns": connString, "user": user.username, "password": user.password };

        oracle.connect(connectData, function(err, connection) {
            cb(err, connection);
        });
        #end
    }
}
