/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.provider;

import saturn.db.query_lang.SQLVisitor;
import saturn.db.query_lang.Query;

import saturn.core.User;
#if SERVER_SIDE
import saturn.app.SaturnServer;
import js.Node;
#end

import saturn.db.DefaultProvider;

import haxe.Unserializer;
import haxe.Serializer;

import saturn.core.Util;
#if SERVER_SIDE
import com.dongxiguo.continuation.Continuation;
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
#end
class GenericRDBMSProvider extends DefaultProvider{
    #if SERVER_SIDE
    var debug : Dynamic = Node.require('debug')('saturn:sql');
    #else
    var debug : Dynamic = Util.debug;
    #end

    var theConnection = null;

    //Used by readmodels to determine when all models have been asynchrounously processed
    var modelsToProcess = 0;


    public function new(models : Map<String,Map<String,Map<String,Dynamic>>>, config : Dynamic, autoClose : Bool){
        super(models, config, autoClose);

        this.config = config;

        user = new User();
        user.username = config.username;
        user.password = config.password;

        /*if(Reflect.hasField(config, 'named_query_hooks')){
            addHooks(Reflect.field(config, 'named_query_hooks'));
        }*/

        for(hook in namedQueryHooks.keys()){
            debug('Installed hook: ' + hook + '/' + namedQueryHooks.get(hook));
        }

        #if SERVER_SIDE
        debug('Platform: ' + Node.process.platform);
        debug('Platform key: ' + platform);
        #end
    }

    override public function setPlatform(){
        #if SERVER_SIDE
        if(Node.process.platform == 'win32'){
            platform = 'windows';
        }else{
            platform = Node.process.platform;
        }
        #end
    }

    override public function setUser(user : User) : Void {
        debug('User called');
        super.setUser(user);
    }

    override public function generatedLinkedClone() : Provider {
        var provider : GenericRDBMSProvider = cast super.generatedLinkedClone();

        provider.config = config;
        provider.debug = debug;
        provider.modelsToProcess = modelsToProcess;
        provider.theConnection = null;
        provider.user = user;

        return provider;
    }

    override public function readModels(cb : String->Void){
        var modelClazzes = new Array<String>();
        for(modelClazz in theBindingMap.keys()){
            modelClazzes.push(modelClazz);
        }

        modelsToProcess = modelClazzes.length;

        getConnection(config, function(err : String, conn : Connection){
            if(err != null){
                debug('Error getting connection for reading models');
                debug(err);
                cb(err);
            }else{
                debug('Querying database for model information');
                _readModels(modelClazzes, this, conn, cb);
            }
        });
    }

    /**
    * _readModels is a recursive function which prepares SQL statements for each model in modelClazzes.
    *
    * Note that this function is cps and therefore needs an additional callback argument which isn't specified in the function signature.
    *
    * The connection passed to _readModels is called once all models have been processed.
    *
    **/
    function _readModels(modelClazzes : Array<String>, provider : GenericRDBMSProvider, connection : Connection, cb : String->Void) : Void{
        var modelClazz = modelClazzes.pop(); // Remove next model to work on

        debug('Processing model: ' + modelClazz);

        var model = provider.getModelByStringName(modelClazz); // Get model instance

        var captured_super = postConfigureModels;

        if(model.hasTableInfo()){
            var keyCol = model.getFirstKey_rdbms();
            var priCol = model.getPrimaryKey_rdbms();
            var tableName = model.getTableName();
            var schemaName = model.getSchemaName();

            var qName = generateQualifiedName(schemaName, tableName);

            var func = function(err : String, cols : Array<String>){
                if(err != null){
                    cb(err);
                }else{
                    // Pregenerate SQL
                    provider.setSelectClause(modelClazz,'SELECT DISTINCT ' + cols.join(',') + ' FROM ' + qName);

                    model.setInsertClause('INSERT INTO ' + qName);
                    model.setDeleteClause('DELETE FROM ' + qName + 'WHERE ' + priCol + ' = ' + dbSpecificParamPlaceholder(1));
                    model.setUpdateClause('UPDATE ' + qName);
                    model.setSelectKeyClause('SELECT DISTINCT ' + keyCol + ', ' + priCol + ' FROM ' + qName + ' ');
                    model.setColumns(cols);

                    // Subtract one from models left to process
                    modelsToProcess--;

                    debug('Model processed: ' + modelClazz);
                    debug(cols);

                    if(modelsToProcess == 0){
                        postConfigureModels();

                        // We get here if there are no more models to process
                        closeConnection(connection);

                        if(cb != null){
                            debug('All Models have been processed (handing back control to caller callback)');
                            cb(null);
                        }
                    }else{
                        _readModels(modelClazzes, provider, connection, cb);
                    }
                }
            };

            getColumns(connection, schemaName, tableName,  func);
        }else{
            if(modelClazzes.length == 0 && modelsToProcess == 1){
                postConfigureModels();
                // Should only be possible to get here if all the models lack table information
                closeConnection(connection);

                if(cb != null){
                    debug('All Models have been processed (handing back control to caller callback2)');
                    cb(null);
                }
            }else{
                modelsToProcess--;

                _readModels(modelClazzes, provider, connection, cb);
            }
        }
    }

    override public function generateQualifiedName(schemaName : String, tableName : String) : String{
        return  schemaName + '.' + tableName;
    }

    public function getColumns(connection : Dynamic, schemaName : String, tableName : String, cb:String->Array<String>->Void) : Void{
        connection.execute("select COLUMN_NAME from ALL_TAB_COLUMNS where OWNER=:1 AND TABLE_NAME=:2", [schemaName, tableName], function(err : String, results : Array<String>){
            if(err == null){
                var cols = new Array<String>();
                for(row in results){
                    cols.push(Reflect.field(row,'COLUMN_NAME'));
                }

                cb(null, cols);
            }else{
                cb(err,null);
            }
        });
    }

    override public function _closeConnection(){
        debug('Closing connection!');

        if(theConnection != null){

            theConnection.close();

            theConnection = null;
        }
    }

    override public function getConnection(config : Dynamic, cb : String->Connection->Void){
        if(!autoClose && theConnection != null){
            debug('Using existing connection');

            cb(null,theConnection);

            return;
        }

        _getConnection(function(err :String , conn : Connection){
            theConnection = conn;

            cb(err, conn);
        });
    }

    public function _getConnection(cb : String->Connection->Void){

    }

    override public function _getByIds(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic) : Void{
        if(clazz == saturn.core.domain.FileProxy){
            handleFileRequests(ids, clazz, callBack);

            return;
        }

        var model = getModel(clazz);

        var selectClause = model.getSelectClause();

        var keyCol = model.getFirstKey_rdbms();

        for(i in 0...ids.length){
            ids[i] = ids[i].toUpperCase();
        }

        var selectorSQL = getSelectorFieldConstraintSQL(clazz);

        if(selectorSQL != ''){
            selectorSQL = ' AND ' + selectorSQL;
        }

        getConnection(config, function(err, connection){
            if(err != null){
                callBack(null, err);
            }else{
                var sql = selectClause + '  WHERE UPPER(' + columnToStringCommand(keyCol) + ') ' + buildSqlInClause(ids.length, 0,'upper') + ' ' + selectorSQL;

                var additionalSQL = generateUserConstraintSQL(clazz);
                if(additionalSQL != null){
                    sql += ' AND ' + additionalSQL;
                }

                sql += ' ORDER BY ' + keyCol;

                debug('SQL' + sql);

                try {
                    connection.execute(sql, ids, function(err, results){
                        if(err != null){
                            callBack(null, err);
                        }else{
                            debug('Sending results');
                            callBack(results, null);
                        }

                        closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    closeConnection(connection);

                    Util.debug(e);

                    callBack(null, e);
                }
            }
        });
    }

    override private function _getObjects(clazz : Class<Dynamic>, callBack : Dynamic){
        var model = getModel(clazz);

        var selectClause = model.getSelectClause();

        var selectorSQL = getSelectorFieldConstraintSQL(clazz);

        if(selectorSQL != ''){
            selectorSQL = ' WHERE ' + selectorSQL;
        }

        getConnection(config, function(err, connection){
            if(err != null){
                callBack(null, err);
            }else{
                var sql = selectClause + ' ' + selectorSQL;

                var additionalSQL = generateUserConstraintSQL(clazz);
                if(additionalSQL != null){
                    sql += ' AND ' + additionalSQL;
                }

                sql += ' ORDER BY ' + model.getFirstKey_rdbms();

                debug(sql);

                try {
                    connection.execute(sql, [], function(err : Dynamic, results){
                        if(err != null){
                            callBack(null, err);
                        }else{
                            callBack(results, null);
                        }

                        closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    closeConnection(connection);

                    Util.debug(e);

                    callBack(null, e);
                }
            }
        });
    }

    override private function _getByValues(values : Array<String>, clazz : Class<Dynamic>, field : String, callBack : Dynamic){
        if(clazz == saturn.core.domain.FileProxy){
            handleFileRequests(values, clazz, callBack);

            return;
        }

        var model = getModel(clazz);

        var selectClause = model.getSelectClause();

        var sqlField = model.getSqlColumn(field);

        var selectorSQL = getSelectorFieldConstraintSQL(clazz);

        if(selectorSQL != ''){
            selectorSQL = ' AND ' + selectorSQL;
        }

        getConnection(config, function(err, connection){
            if(err != null){
                callBack(null, err);
            }else{
                var sql = selectClause + '  WHERE ' + sqlField + ' ' + buildSqlInClause(values.length) + ' ' + selectorSQL;

                var additionalSQL = generateUserConstraintSQL(clazz);
                if(additionalSQL != null){
                    sql += ' AND ' + additionalSQL;
                }

                sql += ' ORDER BY ' + sqlField;

                debug(sql);
                debug(values);

                try {
                    connection.execute(sql, values, function(err, results){
                        if(err != null){
                            callBack(null, err);
                        }else{
                            debug('Result count: ' + results + ' ' + values);
                            callBack(results, null);
                        }

                        closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    closeConnection(connection);

                    Util.debug(e);

                    callBack(null, e);
                }
            }
        });
    }

    function getSelectorFieldConstraintSQL(clazz : Class<Dynamic>){
        var model = getModel(clazz);

        var selectorField = model.getSelectorField();

        if(selectorField != null){
            var selectorValue = model.getSelectorValue();

            return selectorField + ' = "' + selectorValue + '"';
        }else{
            return '';
        }
    }

    public function buildSqlInClause(numIds : Int, ?nextVal = 0, ?func : String = null) : String{
        var inClause = new StringBuf();

        inClause.add('IN(');

        for(i in 0...numIds){
            var def = dbSpecificParamPlaceholder(i+1+nextVal);

            if(func != null){
                def = func + '(' + def + ')';
            }

            inClause.add(def);

            if(i != numIds-1){
                inClause.add(',');
            }
        }

        inClause.add(')');

        return inClause.toString();
    }

    override private function _getByPkeys(ids : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic){
        if(clazz == saturn.core.domain.FileProxy){
            handleFileRequests(ids, clazz, callBack);

            return;
        }

        var model = getModel(clazz);

        var selectClause = model.getSelectClause();

        var keyCol = model.getPrimaryKey_rdbms();

        var selectorSQL = getSelectorFieldConstraintSQL(clazz);

        if(selectorSQL != ''){
            selectorSQL = ' AND ' + selectorSQL;
        }

        getConnection(config, function(err, connection){
            if(err != null){
                callBack(null, err);
            }else{
                var sql = selectClause + '  WHERE ' + keyCol + ' ' + buildSqlInClause(ids.length) + selectorSQL;

                var additionalSQL = generateUserConstraintSQL(clazz);
                if(additionalSQL != null){
                    sql += ' AND ' + additionalSQL;
                }

                sql += ' ' + ' ORDER BY ' + keyCol;

                debug(sql);

                try {
                    connection.execute(sql, ids, function(err, results){
                        if(err != null){
                            callBack(null, err);
                        }else{
                            callBack(results, null);
                        }

                        closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    closeConnection(connection);

                    callBack(null, e);
                }
            }
        });
    }

    override private function _query(query : Query, cb : Array<Dynamic>->Dynamic->Void){


        getConnection(config, function(err, connection){
            if(err != null){
                cb(null, err);
            }else{
                try {
                    var visitor = new SQLVisitor(this);
                    var sql = visitor.translate(query);

                    debug(sql);
                    debug(visitor.getValues());

                    connection.execute(sql, visitor.getValues(), function(err, results){
                        if(err != null){
                            cb(null, err);
                        }else{
                            results = visitor.getProcessedResults(results);

                            cb(results, null);
                        }

                        closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    closeConnection(connection);
                    debug('Error !!!!!!!!!!!!!' + e.stack);
                    cb(null, e);
                }
            }
        });
    }



    override private function _getByIdStartsWith(id : String, field: String, clazz : Class<Dynamic>, limit : Int, callBack : Dynamic) : Void{
        var model = getModel(clazz);
        debug('Provider class' + Type.getClassName(Type.getClass(this)));
        debug('Provider: ' + model.getProviderName());

        //var selectClause = model.getSelectKeyClause();

        var keyCol = null;

        if(field == null){
            keyCol = model.getFirstKey_rdbms();
        }else{
            if(model.isRDBMSField(field)){
                keyCol = field;
            }
        }

        var busKey = model.getFirstKey_rdbms();
        var priCol = model.getPrimaryKey_rdbms();
        var tableName = model.getTableName();
        var schemaName = model.getSchemaName();

        var qName = generateQualifiedName(schemaName, tableName);

        var selectClause = 'SELECT DISTINCT ' + busKey + ', ' + priCol;

        if(keyCol != busKey && keyCol != priCol){
            selectClause += ', ' + keyCol;
        }

        selectClause += ' FROM ' + qName;

        id = id.toUpperCase();

        var selectorSQL = getSelectorFieldConstraintSQL(clazz);

        if(selectorSQL != ''){
            selectorSQL = ' AND ' + selectorSQL;
        }

        if(!limitAtEndPosition()){
            if(limit != null && limit != 0 && limit != -1){
                selectorSQL += generateLimitClause(limit);
            }
        }

        getConnection(config, function(err, connection){
            if(err != null){
                callBack(null, err);
            }else{

                var sql = selectClause + '  WHERE UPPER(' + columnToStringCommand(keyCol) + ') like ' + dbSpecificParamPlaceholder(1) + ' ' + selectorSQL;

                var additionalSQL = generateUserConstraintSQL(clazz);
                if(additionalSQL != null){
                    sql += ' AND ' + additionalSQL;
                }

                sql += ' ORDER BY ' + keyCol;

                if(limitAtEndPosition()){
                    if(limit != null && limit != 0 && limit != -1){
                        sql += generateLimitClause(limit);
                    }
                }

                id = '%' + id + '%';

                debug('startswith' + sql);
                try {
                    connection.execute(sql, [id], function(err, results){
                        if(err != null){
                            callBack(null, err);
                        }else{
                            callBack(results, null);
                        }

                        closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    Util.debug(e);
                    closeConnection(connection);

                    callBack(null, e);
                }
            }
        });
    }

    private function limitAtEndPosition(){
        return false;
    }

    public function generateLimitClause(limit){
        return ' AND ROWNUM < ' + Std.int(limit);
    }

    private function columnToStringCommand(columnName : String){
        return columnName;
    }

    private function convertComplexQuery(parameters : Array<Dynamic>){

    }

    override public function _getByNamedQuery(queryId : String, parameters : Dynamic, clazz : Class<Dynamic>, cb : Dynamic) : Void{
        if(!Reflect.hasField(config.named_queries,queryId)){
            debug('Hook is missing');
            cb(null, 'Query ' + queryId + ' not found ');
        }else{
            debug('Calling SQL query');
            var sql :String = Reflect.field(config.named_queries, queryId);

            var realParameters = new Array<Dynamic>();

            if(Std.is(parameters, Array)){
                debug('Named query passed an Array');
                var re : EReg =~/(<IN>)/;

                if(re.match(sql)){
                    sql = re.replace(sql, buildSqlInClause(parameters.length));
                }

                realParameters = parameters;
            }else {
                debug('Named query with other object type');
                var dbPlaceHolderI = 0;
                var attributes = Reflect.fields(parameters);

                if(attributes.length == 0){
                    cb(null, 'Unknown parameter collection type'); return;
                }else{
                    debug('Named query passed object');
                    var re_in : EReg =~/^IN:/;
                    var re : EReg =~/<:([^>]+)>/;

                    var convertedSQL = '';

                    var matchMe = sql;

                    while(matchMe != null){
                        debug('Looping: ' + matchMe);
                        debug('SQL: ' + convertedSQL);
                        if(re.matchSub(matchMe,0)){
                            var matchLeft = re.matchedLeft();

                            var tagName = re.matched(1);

                            debug('MatchLeft: ' + matchLeft);
                            debug('Tag:' + tagName);

                            convertedSQL += matchLeft;

                            if(re_in.matchSub(tagName,0)){
                                debug('Found IN');
                                tagName = re_in.replace(tagName, '');

                                debug('Real Tag Name' + tagName);

                                if(Reflect.hasField(parameters, tagName)){
                                    debug('Found array');
                                    var paramArray :Array<Dynamic> = Reflect.field(parameters, tagName);

                                    if(Std.is(paramArray, Array)){
                                        convertedSQL += buildSqlInClause(paramArray.length);

                                        for(i in 0...paramArray.length){
                                            realParameters.push(paramArray[i]);
                                        }
                                    }else{
                                        cb(null, 'Value to attribute ' + tagName + ' should be an Array'); return;
                                    }


                                }else{
                                    cb(null, 'Missing attribute ' + tagName); return;
                                }
                            }else{
                                debug('Found non IN argument');
                                if(Reflect.hasField(parameters, tagName)){
                                    convertedSQL += dbSpecificParamPlaceholder(dbPlaceHolderI++);

                                    var value = Reflect.field(parameters, tagName);

                                    realParameters.push(value);
                                }else{
                                    cb(null, 'Missing attribute ' + tagName); return;
                                }
                            }
                            matchMe = re.matchedRight();
                            debug('Found right ' + matchMe);
                        }else{
                            convertedSQL += matchMe;

                            matchMe = null;

                            debug('Terminating while');
                        }
                    }

                    sql = convertedSQL;
                }
            }

            debug('SQL: ' + sql);
            debug('Parameters: ' + realParameters);

            getConnection(config, function(err, connection){
                if(err != null){
                    cb(null, err);
                }else{
                    debug(sql);
                    try {
                        connection.execute(sql, realParameters, function(err, results){
                            debug('Named query returning');

                            if(err != null){
                                cb(null, err);
                            }else{
                                //cb(null, null);
                                cb(results, null);
                            }

                            closeConnection(connection);
                        });
                    }catch(e:Dynamic){
                        closeConnection(connection);

                        cb(null, e);
                    }
                }
            });
        }
    }

    override public function _update(attributeMaps : Array<Map<String, Dynamic>>,className : String,  cb : Dynamic) : Void{
        applyFunctions(attributeMaps, className);

        getConnection(config, function(err, connection){
            if(err != null){
                cb(err);//
            }else{
                var clazz = Type.resolveClass(className);

                var model = getModel(clazz);

                _updateRecursive(attributeMaps, model, cb, connection);
            }
        });
    }

    override public function _insert(attributeMaps : Array<Map<String, Dynamic>>,className : String,  cb : Dynamic) : Void{
        applyFunctions(attributeMaps, className);

        getConnection(config, function(err, connection){
            if(err != null){
                cb(err);//
            }else{
                /*connection.execute('',[],function(err){

                });*/

                var clazz = Type.resolveClass(className);

                var model = getModel(clazz);

                _insertRecursive(attributeMaps, model, cb, connection);
            }
        });
    }

    public function cloneConfig(){
        var cloneData = Serializer.run(config);

        var unserObj = Unserializer.run(cloneData);

        return unserObj;
    }

    private function _insertRecursive(attributeMaps : Array<Map<String, Dynamic>>,model : Model,  cb : Dynamic, connection : Connection) : Void{
        debug('Inserting  ' + Type.getClassName(model.getClass()));
        var insertClause = model.getInsertClause();
        var cols = model.getColumnSet();

        var attributeMap = attributeMaps.pop();

        var colStr = new StringBuf();
        var valList = new Array<Dynamic>();
        var valStr = new StringBuf();

        var i = 0;

        var hasWork = false;

        for(attribute in attributeMap.keys()){
            if(cols != null && cols.exists(attribute)){
                if(i>0){
                    colStr.add(',');
                    valStr.add(',');
                }

                i++;

                colStr.add(attribute);
                valStr.add(dbSpecificParamPlaceholder(i));

                var val = attributeMap.get(attribute);

                if(val == '' && !Std.is(val, Int)){
                    val = null; //
                }

                valList.push(val);

                hasWork = true;
            }
        }

        if(model.isPolymorph()){
            i++;
            colStr.add(',' + model.getSelectorField() );
            valStr.add(',' + dbSpecificParamPlaceholder(i));

            valList.push(model.getSelectorValue());

            hasWork = true;
        }

        if(!hasWork){
            debug('No work - returning error');
            cb('Insert failure: no mapped fields for ' + Type.getClassName(model.getClass()));
            return;
        }

        var sql = insertClause + ' (' + colStr + ') VALUES('+valStr+')';

        var keyCol = model.getFirstKey_rdbms();
        var keyVal = attributeMap.get(keyCol);

        debug('MAP:' + attributeMap);
        debug('SQL'+ sql);
        debug('Values' + valList);

        try {
            connection.execute(sql, valList, function(err, results){
                if(err != null){
                    var error = {message: StringTools.replace(Std.string(err), '\n', ''), source: keyVal};

                    cb(error);

                    closeConnection(connection);
                }else{
                    if(attributeMaps.length == 0){
                        cb(null);

                        closeConnection(connection);
                    }else{
                        _insertRecursive(attributeMaps, model, cb, connection);
                    }
                }
            });
        }catch(e:Dynamic){
            closeConnection(connection);

            var error = {message: StringTools.replace(Std.string(e), '\n', ''), source: keyVal};

            cb(error);
        }
    }

    private function _updateRecursive(attributeMaps : Array<Map<String, Dynamic>>,model : Model,  cb : Dynamic, connection : Connection) : Void{
        var updateClause = model.getUpdateClause();
        var cols = model.getColumnSet();

        var attributeMap = attributeMaps.pop();

        var valList = new Array<Dynamic>();
        var updateStr = new StringBuf();

        var i = 0;

        for(attribute in attributeMap.keys()){
            if(cols.exists(attribute) && attribute != model.getPrimaryKey_rdbms()){
                if(attribute == 'DATESTAMP'){
                    continue;
                }

                if(i>0){
                    updateStr.add(',');
                }

                i++;

                 updateStr.add(attribute + ' = ' + dbSpecificParamPlaceholder(i));

                var val = attributeMap.get(attribute);

                if(val == ''){
                    val = null;
                }

                valList.push(val);
            }
        }

        i++;

        //TODO: Breaking change
        var keyCol = model.getPrimaryKey_rdbms();

        var sql = updateClause + ' SET ' + updateStr+ ' WHERE ' + keyCol + ' = ' + dbSpecificParamPlaceholder(i);

        var additionalSQL = generateUserConstraintSQL(model.getClass());
        if(additionalSQL != null){
            sql += ' AND ' + additionalSQL;
        }

        valList.push(attributeMap.get(keyCol));

        debug('SQL' + sql);
        debug('Values' + valList);

        try {
            connection.execute(sql, valList, function(err, results){
                if(err != null){
                    Util.debug('Error: ' + err);
                    cb(err);

                    closeConnection(connection);
                }else{
                    if(attributeMaps.length == 0){
                        cb(null);

                        closeConnection(connection);
                    }else{
                        _updateRecursive(attributeMaps, model, cb, connection);
                    }
                }
            });
        }catch(e:Dynamic){
            closeConnection(connection);

            cb(e);
        }
    }

    override public function _delete(attributeMaps : Array<Map<String, Dynamic>>,className : String,  cb : Dynamic) : Void{
        var model = getModelByStringName(className);

        var priField = model.getPrimaryKey();

        var priFieldSql = model.getPrimaryKey_rdbms();

        var pkeys = new Array<String>();

        for(attributeMap in attributeMaps){
            pkeys.push(attributeMap.get(priFieldSql));
        }

        var d :Dynamic = cast attributeMaps;

        var sql = 'DELETE FROM ' + generateQualifiedName(model.getSchemaName(), model.getTableName()) + ' WHERE ' + priFieldSql + ' ' + buildSqlInClause(pkeys.length);

        var additionalSQL = generateUserConstraintSQL(model.getClass());
        if(additionalSQL != null){
            sql += ' AND ' + additionalSQL;
        }

        getConnection(config, function(err, connection){
            if(err != null){
                cb(err);//
            }else{
                try {
                    connection.execute(sql, pkeys, function(err, results){
                        if(err != null){
                            Util.debug('Error: ' + err);
                            cb(err);

                            closeConnection(connection);
                        }else{
                            cb(null);
                        }
                    });
                }catch(e:Dynamic){
                    closeConnection(connection);

                    cb(e);
                }
            }
        });
    }

    override public function postConfigureModels(){
        super.postConfigureModels();
    }

    private function parseObjectList(data) : Array<Dynamic>{
        return null;
    }

    /*
     * To be implemented in classes that extend GenericRDBMSProvider i.e. MySQLProvider, OracleProvider, etc.
     */
    public function dbSpecificParamPlaceholder(i: Int) : String {
        return ':' + i;
    }

    override public function getProviderType() : String{
        return 'ORACLE';
    }

    public function applyFunctions(attributeMaps : Array<Map<String, Dynamic>>,className : String){
        var context = user;
        var model = getModelByStringName(className);

        var functions = model.getAutoFunctions();

        if(functions != null){
            for(field in functions.keys()){
                var functionString = functions.get(field);
                var func :Dynamic =  null;

                if(functionString == 'insert.username'){
                    func = setUserName;
                }else{
                    continue;
                }

                for(attributeMap in attributeMaps){
                    if(attributeMap.exists(field)){
                        attributeMap.set(field, Reflect.callMethod(this,func,[attributeMap.get(field), context]));
                    }
                }
            }
        }

        return attributeMaps;
    }

    public function setUserName(value : String, context :Dynamic = null){
        if(context != null && context.username != null){
            return context.username.toUpperCase();
        }else{
            return value;
        }
    }

    public function handleFileRequests(values : Array<String>, clazz : Class<Dynamic>, callBack : Dynamic){
        #if SERVER_SIDE
        var i = 0;

        var next = null;
        var results = new Array<Dynamic>();

        next = function(){
            if(i < values.length){
                var value = values[i];

                var key = value;

                debug('Processing file requests');
                debug(conversions);

                for(conversion in conversions.keys()){
                    var replacement = conversions.get(conversion);
                    value = StringTools.replace(value, conversion, replacement);
                }

                if(platform == 'windows'){
                    value = StringTools.replace(value, '/', '\\');
                }

                debug('Unlinking path ' + value);

                Node.fs.realpath(value, function(err: NodeErr, abspath :String){
                    if(err != null){
                        debug('File realpath error: ' + err);
                        callBack(null, SaturnServer.getStandardUserInputError());
                    }else{
                        var match = false;
                        for(key in regexs.keys()){
                            if(regexs.get(key).match(value)){
                                match = true;
                                break;
                            }
                        }

                        if(match){
                            debug('Reading path: ' + abspath);

                            Node.fs.readFile(abspath, null, function(err, content){
                                if(err != null){
                                    debug('File read error: ' + err + '/' + abspath);

                                    callBack(null, SaturnServer.getStandardUserInputError());
                                }else{
                                    var match = false;
                                    for(key in regexs.keys()){
                                        if(regexs.get(key).match(value)){
                                            match = true;
                                            break;
                                        }
                                    }

                                    i++;

                                    results.push({'PATH': key, 'CONTENT': content});

                                    next();
                                }
                            });
                        }else{
                            debug('File read error: ' + err);
                            callBack(null, SaturnServer.getStandardUserInputError());
                        }
                    }
                });
            }else{
                callBack(results, null);
            }
        };

        next();
        #end
    }

    public function setConnection(conn : Dynamic){
        this.theConnection = conn;
    }

    override private function _commit(cb : Dynamic) : Void{
        getConnection(config, function(err, connection){
            if(err != null){
                cb(err);//
            }else{
                connection.commit(cb);
            }
        });
    }

    override public function setAutoCommit(autoCommit : Bool, cb : String->Void) : Void{
        getConnection(config, function(err :String, conn : Connection){
            if(err == null){
                conn.setAutoCommit(autoCommit);

                cb(null);
            }else{
                cb(err);
            }
        });
    }

    public function generateUserConstraintSQL(clazz : Class<Dynamic>){
        var model = getModel(clazz);

        var publicConstraintField = model.getPublicConstraintField();
        var userConstraintField = model.getUserConstraintField();

        var sql = null;

        if(publicConstraintField != null){
            var columnName = model.getSqlColumn(publicConstraintField);

            sql = " " + columnName + " = 'yes' ";
        }

        if(userConstraintField != null){
            var inBlock = false;
            if(sql != null){
                sql = '(' + sql + ' OR ';

                inBlock = true;
            }

            var columnName = model.getSqlColumn(userConstraintField);

            sql = sql + columnName + " = '" + getUser().username.toUpperCase() + "'";

            if(inBlock){
                sql += ' ) ';
            }
        }

        return sql;
    }
}