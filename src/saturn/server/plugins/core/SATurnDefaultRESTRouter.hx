package saturn.server.plugins.core;

/**
* SATurnDefaultRESTRouter
*
* Includes a number of static methods to provide a binding between the simple REST API command and the underlying
* raw Socket.IO API
**/
class SATurnDefaultRESTRouter {
    public function new() {

    }

    /**
    * update_blastdb updates the BLAST DB indicated in req.params.databaseName
    **/
    public static function update_blastdb(path : String , req : Dynamic, res : Dynamic, next, handle_function){
        var command = '_blast_updater_';

        if(!Reflect.hasField(req.params, 'database') || req.params.database == null){
            res.status(400);
            res.send('Bad Request - database parameter missing');

            next();
        }else{
            var jsonObj = {'database': req.params.database};

            handle_function(path,req, res, next, command, jsonObj);
        }
    }
}
