/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db;

import saturn.core.Util.*;

import saturn.util.HaxeException;
class Model {
    var theModel : Map<String,Map<String,Dynamic>>;
    var theName : String;
    var busSingleColKey : String;
    var priColKey : String;

    var idRegEx : EReg;
    var stripIdPrefix : Bool;
    var file_new_label : String;

    var searchMap : Map<String, EReg>;
    var ftsColumns : Map<String, SearchDef>;

    var alias : String;

    var programs : Array<String>;
    var flags : Map<String, Bool>;

    var autoActivate : Int;

    var actionMap : Map<String, Map<String,ModelAction>>;

    var providerName : String;

    var publicConstraintField : String;
    var userConstraintField : String;
    var customSearchFunctionPath : String = null;

    public function new(model : Map<String,Map<String,Dynamic>>, name : String){
        theModel = model;
        theName = name;

        alias = '';

        actionMap = new Map<String, Map<String,ModelAction>>();

        if(theModel.exists('indexes')){
            var i=0;
            for(keyName in theModel.get('indexes').keys()){
                if(i==0){
                    busSingleColKey = keyName;
                }

                if(theModel.get('indexes').get(keyName)){
                    priColKey = keyName;
                }

                i++;
            }
        }

        if(theModel.exists('provider_name')){
            var name : String = cast(theModel.get('provider_name'), String);
            setProviderName(name);
        }

        if(theModel.exists('programs')){
            programs = new Array<String>();

            for(program in theModel.get('programs').keys()){
                programs.push(program);
            }
        }

        stripIdPrefix = false;

        autoActivate = -1;

        if(theModel.exists('options')){
            var options = theModel.get('options');
            if(options.exists('id_pattern')){
                setIdRegEx(options.get('id_pattern'));
            }

            if(options.exists('custom_search_function')){
                customSearchFunctionPath = options.get('custom_search_function');
            }

            if(options.exists('constraints')){
                if(options.get('constraints').exists('user_constraint_field')){
                    userConstraintField = options.get('constraints').get('user_constraint_field');
                }

                if(options.get('constraints').exists('public_constraint_field')){
                    publicConstraintField = options.get('constraints').get('public_constraint_field');
                }
            }

            if(options.get('windows_allowed_paths')){
                options.set('windows_allowed_paths_regex', compileRegEx(options.get('windows_allowed_paths')));
            }

            if(options.get('linux_allowed_paths')){
                options.set('linux_allowed_paths_regex', compileRegEx(options.get('linux_allowed_paths')));
            }

            if(options.exists('strip_id_prefix')){
                stripIdPrefix = options.get('strip_id_prefix');
            }

            if(options.exists('alias')){
                alias = options.get('alias');
            }

            if(options.exists('flags')){
                flags = options.get('flags');
            }else{
                flags = new Map<String, Bool>();
            }

            if(options.exists('file.new.label')){
                file_new_label = options.get('file.new.label');
            }

            if(options.exists('auto_activate')){
                autoActivate = Std.parseInt(options.get('auto_activate'));
            }

            if(options.exists('actions')){
                var actionTypeMap :Map<String, Map<String, Map<String, String>>> = options.get('actions');

                for(actionType in actionTypeMap.keys()){
                    var actions : Map<String, Map<String, String>> = actionTypeMap.get(actionType);

                    actionMap.set(actionType, new Map<String, ModelAction>());

                    for(actionName in actions.keys()){
                        var actionDef : Map<String, String> = actions.get(actionName);

                        if(!actionDef.exists('user_suffix')){
                            throw new HaxeException(actionName + ' action definition for ' + getName() + ' is missing user_suffix option');
                        }

                        if(!actionDef.exists('function')){
                            throw new HaxeException(actionName + ' action definition for ' + getName() + ' is missing function option');
                        }

                        var action = new ModelAction(actionName, actionDef.get('user_suffix'), actionDef.get('function'), actionDef.get('icon'));

                        if(actionType == 'search_bar'){
                            var clazz = Type.resolveClass(action.className);

                            if(clazz == null){
                                throw new HaxeException(action.className + ' does not exist for action ' + actionName);
                            }

                            var instanceFields = Type.getInstanceFields(clazz);

                            var match : Bool = false;
                            for(field in instanceFields){
                                if(field == action.functionName){
                                    match = true;
                                    break;
                                }
                            }

                            if(!match){
                                throw new HaxeException(action.className + ' does not have function ' + action.functionName + ' for action ' + actionName);
                            }
                        }

                        actionMap.get(actionType).set(actionName, action);
                    }
                }
            }
        }else{
            flags = new Map<String, Bool>();
            actionMap.set('searchBar', new Map<String, ModelAction>());
        }

        if(theModel.exists('search')){
            var fts :Map<String, Dynamic> = theModel.get('search');

            ftsColumns = new Map<String, SearchDef>();

            for(key in fts.keys()){
                var searchDef = fts.get(key);

                var searchObj = new SearchDef();

                if(searchDef != null){
                    if(Std.is(searchDef, Bool) && searchDef){
                        ftsColumns.set(key, searchObj);
                    }else if(Std.is(searchDef, String)){
                        searchObj.regex = new EReg(searchDef, '');
                    }else{
                        if(searchDef.exists('search_when')){
                            var regexStr = searchDef.get('search_when');

                            if(regexStr != null && regexStr != ''){
                                searchObj.regex = new EReg(regexStr, '');
                            }
                        }

                        if(searchDef.exists('replace_with')){
                            searchObj.replaceWith = searchDef.get('replace_with');
                        }
                    }
                }

                ftsColumns.set(key, searchObj);
            }
        }

        if(alias == null || alias == ''){
            alias = theName;
        }
    }

    public function getFileNewLabel(): String{
        return file_new_label;
    }

    public function isProgramSaveAs(clazzName : String) : Bool{
        if(theModel.exists('programs') && theModel.get('programs').get(clazzName)){
            return true;
        }else if(theModel.get('options').exists('canSave')){
            return theModel.get('options').get('canSave').get(clazzName);
        }else{
            return false;
        }
    }

    public function getProviderName() : String{
        return providerName;
    }

    public function setProviderName(name : String) : Void{
        this.providerName = name;
    }

    public function getActions(actionType : String) : Map<String, ModelAction>{
        if(actionMap.exists(actionType)){
            return actionMap.get(actionType);
        }else{
            return new Map<String, ModelAction>();
        }
    }

    public function getAutoActivateLevel() : Int{
        return autoActivate;
    }

    public function hasFlag(flag : String) : Bool{
        if(flags.exists(flag)){
            return flags.get(flag);
        }else{
            return false;
        }
    }

    public function getCustomSearchFunction() : String{
        return customSearchFunctionPath;
    }

    public function getPrograms() : Array<String>{
        return programs;
    }

    public function getAlias() : String{
        return alias;
    }

    public function getFTSColumns() : Map<String, SearchDef>{
        if(ftsColumns != null){
            return ftsColumns;
        }else{
            return null;
        }
    }

    public function getSearchMap() : Map<String, EReg>{
        return searchMap;
    }

    public function getOptions() : Map<String, Dynamic>{
        return theModel.get('options');
    }

    private function compileRegEx(regexs : Map<String, String>) : Map<String, EReg>{
        var cregexs = new Map<String, EReg>();

        for(key in regexs.keys()){
            var regex = regexs.get(key);
            if(regex != ''){
                cregexs.set(key, new EReg(regex, ''));
            }
        }

        return cregexs;
    }

    public function setIdRegEx(idRegExStr : String){
        idRegEx = new EReg(idRegExStr, '');
    }

    public function getIdRegEx() : EReg{
        return idRegEx;
    }

    public function isValidId(id : String) : Bool{
        if(idRegEx != null){
            return idRegEx.match(id);
        }else{
            return false;
        }
    }

    public function stripPrefixes() : Bool{
        return stripIdPrefix;
    }

    public function processId(id : String) : String {
        if(stripIdPrefix){
            id = idRegEx.replace(id, '');
        }

        return id;
    }

    public function getIndexes(){
        var indexFields = new Array<String>();
        for(keyName in theModel.get('indexes').keys()){
            indexFields.push(keyName);
        }

        return indexFields;
    }

    public function getAutoFunctions(){
        if(theModel.exists('auto_functions')){
            return theModel.get('auto_functions');
        }else{
            return null;
        }
    }

    public function getFields() : Array<String>{
        var fields = new Array<String>();
        for(field in theModel.get('model')){
            fields.push(field);
        }

        return fields;
    }

    public function getAttributes() : Array<String>{
        var fields = new Array<String>();
        if(theModel.exists('fields')){
            for(field in theModel.get('fields').keys()){
                fields.push(field);
            }
        }

        return fields;
    }

    public function isField(field : String) : Bool{
        return theModel.get('fields').exists(field);
    }

    public function isRDBMSField(rdbmsField : String) : Bool {
        var fields = theModel.get('fields');
        for(field in fields.keys()){
            if(fields.get(field) == rdbmsField){
                return true;
            }
        }

        return false;
    }

    public function modelAtrributeToRDBMS(field : String){
        return theModel.get('fields').get(field);
    }

    public function hasDefaults(){
        return theModel.exists('defaults');
    }

    public function hasOptions() : Bool{
        return theModel.exists('options');
    }

    public function getFieldDefault(field : String){
        if(hasDefaults() && theModel.get('defaults').exists(field)){
            return theModel.get('defaults').get(field);
        }else{
            return null;
        }
    }

    public function hasRequired(){
        return theModel.exists('required');
    }

    public function isRequired(field : String){
        if(hasRequired()){
            if(theModel.get('required').exists(field)){
                return true;
            }else if(field.indexOf('.') > 0){
                var cmps = field.split('.');

                var refField = getSyntheticallyBoundField(cmps[0]);

                return isRequired(refField);
            }
        }

        return false;
    }

    public function getFieldDefs() : Array<Dynamic>{
        var fields = new Array<Dynamic>();
        var defaults = null;

        if(theModel.exists('defaults')){
            defaults = theModel.get('defaults');
        }else{
            return getFields();
        }

        for(field in theModel.get('model')){
            var val = null;

            if(defaults.exists(field)){
                val = theModel.get('defaults').get(field);
            }

            fields.push({name:field, defaultValue:val});
        }

        return fields;
    }

    public function getUserFieldDefinitions() : Array<Dynamic>{
        var fields = new Array<Dynamic>();
        var defaults = null;

        if(theModel.exists('defaults')){
            defaults = theModel.get('defaults');
        }else{
            defaults = new Map<String, String>();
        }

        var model = theModel.get('model');

        if(model == null){
            return null;
        }

        for(field in model.keys()){
            var val = null;

            if(defaults.exists(field)){
                val = theModel.get('defaults').get(field);
            }

            fields.push({name:field, defaultValue:val, field: theModel.get('model').get(field)});
        }

        return fields;
    }

    public function convertUserFieldName(userFieldName : String){
        if(theModel.exists('model')){
            if(theModel.get('model').exists(userFieldName)){
                return theModel.get('model').get(userFieldName);
            }else{
                return null;
            }
        }else{
            return null;
        }
    }

    public function getExtTableDefinition() : Array<Dynamic>{
        var tableDefinition = new Array<Dynamic>();
        for(name in theModel.get('model').keys()){
            var field = theModel.get('model').get(name);
            var def :Dynamic = {header:name,dataIndex:field,editor : 'textfield'};

            if(isRequired(field)){
                def.tdCls = 'required-column';
                def.allowBlank = false;
            }

            tableDefinition.push(def);
        }

        return tableDefinition;
    }

    public function getSynthenticFields() :Map<String,Dynamic>{
        return theModel.get('fields.synthetic');
    }

    public function isSyntheticallyBound(fieldName : String) {
        var synthFields = theModel.get('fields.synthetic');
        if(synthFields != null){
            for(syntheticFieldName in synthFields.keys()){
                if(synthFields.get(syntheticFieldName).get('field') == fieldName){
                    return true;
                }
            }
        }

        return false;
    }

    public function isSynthetic(fieldName : String){
        if(theModel.exists('fields.synthetic')){
            return theModel.get('fields.synthetic').exists(fieldName);
        }else{
            return false;
        }
    }

    public function getPseudoSyntheticObjectName(fieldName : String){
        if(theModel.exists('fields.synthetic')){
            for(objName in theModel.get('fields.synthetic').keys()){
                if(theModel.get('fields.synthetic').get(objName).get('fk_field') == null){
                    var boundField = theModel.get('fields.synthetic').get(objName).get('field');

                    if(fieldName == boundField){
                        return objName;
                    }
                }
            }
        }

        return null;
    }

    public function getSyntheticallyBoundField(syntheticFieldName : String){
        if(theModel.exists('fields.synthetic')){
            if(theModel.get('fields.synthetic').exists(syntheticFieldName)){
                return theModel.get('fields.synthetic').get(syntheticFieldName).get('field');
            }
        }

        return null;
    }

    public function getClass() : Class<Dynamic>{
        return Type.resolveClass(theName);
    }

    public function getFirstKey() : String{
        return busSingleColKey;
    }

    public function getIcon() : String {
        if(hasOptions()){
            if(getOptions().exists('icon')){
                return getOptions().get('icon');
            }
        }

        return '';
    }

    public function getWorkspaceWrapper() : String {
        if(hasOptions()){
            if(getOptions().exists('workspace_wrapper')){
                return getOptions().get('workspace_wrapper');
            }
        }

        return '';
    }

    public function getWorkspaceWrapperClass() : Class<Dynamic>{
        return Type.resolveClass(getWorkspaceWrapper());
    }

    public function getPrimaryKey() : String{
        return priColKey;
    }

    public function getName() : String{
        return theName;
    }

    public function getExtModelName() : String{
        return theName + '.MODEL';
    }

    public function getExtStoreName() : String{
        return theName + '.STORE';
    }

    public function getFirstKey_rdbms() : String {
        return theModel.get('fields').get(getFirstKey());
    }

    public function getSqlColumn(field : String) : String {
        return theModel.get('fields').get(field);
    }

    public function unbindFieldName(field : String) : String{
        return getSqlColumn(field);
    }

    public function getPrimaryKey_rdbms() : String {
        return theModel.get('fields').get(getPrimaryKey());
    }

    public function getSchemaName() : String{
        return theModel.get('table_info').get('schema');
    }

    public function getTableName() : String{
        return theModel.get('table_info').get('name');
    }

    public function getQualifiedTableName() : String {
        //Support for tables without a schema name
        var schemaName = getSchemaName();
        if(schemaName == null || schemaName == ''){
            return getTableName();
        }else{
            return getSchemaName() + '.' + getTableName();
        }
    }

    public function hasTableInfo() : Bool {
        return theModel.exists('table_info');
    }



    public function getSelectClause() : String{
        return theModel.get('statements').get('SELECT');
    }

    public function setInsertClause(insertClause : String) : Void {
        theModel.get('statements').set('INSERT', insertClause);
    }

    public function getInsertClause() : String{
        return theModel.get('statements').get('INSERT');
    }

    public function setUpdateClause(updateClause : String) : Void {
        theModel.get('statements').set('UPDATE', updateClause);
    }

    public function getUpdateClause() : String{
        return theModel.get('statements').get('UPDATE');
    }

    public function setDeleteClause(deleteClause : String) : Void {
        theModel.get('statements').set('DELETE', deleteClause);
    }

    public function getDeleteClause() : String{
        return theModel.get('statements').get('DELETE');
    }

    public function setSelectKeyClause(selKeyClause : String) : Void {
        theModel.get('statements').set('SELECT_KEY', selKeyClause);
    }

    public function getSelectKeyClause() : String{
        return theModel.get('statements').get('SELECT_KEY');
    }

    public function setColumns(columns : Array<String>) : Void {
        theModel.get('statements').set('COLUMNS', columns);

        var colSet = new Map<String,String>();

        for(column in columns){
            colSet.set(column,"");
        }

        theModel.get('statements').set('COLUMNS_SET', colSet);
    }

    public function getColumns() : Array<String>{
        return theModel.get('statements').get('COLUMNS');
    }

    public function getColumnSet() : Map<String, String>{
        return theModel.get('statements').get('COLUMNS_SET');
    }

    public function getSelectorField() : String {
        if(theModel.exists('selector')){
            return theModel.get('selector').get('polymorph_key');
        }else{
            return null;
        }
    }

    public function getSelectorValue() : String{
        return theModel.get('selector').get('value');
    }

    public function isPolymorph() : Bool{
        return theModel.exists('selector');
    }

    public static function generateIDMap(objs : Array<Dynamic>) : Map<String, String>{
        if(objs == null || objs.length == 0){
            return null;
        }else{
            var map = new Map<String, String>();

            var model : Model = getProvider().getModel(Type.getClass(objs[0]));
            var firstKey = model.getFirstKey();
            var priKey = model.getPrimaryKey();

            for(obj in objs){
                map.set(Reflect.field(obj, firstKey), Reflect.field(obj, priKey));
            }

            return map;
        }
    }

    public static function generateUniqueList(objs: Array<Dynamic>) : Array<String>{
        if(objs == null || objs.length == 0){
            return null;
        }else{
            var model : Model = getProvider().getModel(Type.getClass(objs[0]));

            var firstKey = model.getFirstKey();

            return generateUniqueListWithField(objs, firstKey);
        }
    }

    public static function generateUniqueListWithField(objs : Array<Dynamic>, field : String) : Array<String>{
        var set = new Map<String, String>();

        for(obj in objs){
            set.set(extractField(obj, field), null);
        }

        var ids = new Array<String>();
        for(key in set.keys()){
            ids.push(key);
        }

        return ids;
    }

    public static function extractField(obj : Dynamic, field : String){
        if(field.indexOf('.') < 0){
            return Reflect.field(obj, field);
        }else{
            var a = field.indexOf('.') -1;
            var nextField = field.substring(0, a+1);

            var nextObj = Reflect.field(obj, nextField);

            var remaining = field.substring(a+2, field.length);

            return extractField(nextObj, remaining);
        }
    }

    public static function setField(obj : Dynamic, field : String, value : String, newTerminal : Bool = false){
        if(field.indexOf('.') < 0){
            Reflect.setField(obj, field, value);
        }else{
            var a = field.indexOf('.') -1;
            var nextField = field.substring(0, a+1);

            var nextObj = Reflect.field(obj, nextField);

            var remaining = field.substring(a+2, field.length);

            // Autovivification support
            if(nextObj == null || (newTerminal && remaining.indexOf('.') < 0)){
                var clazz = Type.getClass(obj);
                if(clazz != null){
                    var model = saturn.core.Util.getProvider().getModel(clazz);
                    var synthDef = model.getSynthenticFields().get(nextField);

                    if(synthDef != null){
                        var clazzStr = synthDef.get('class');

                        nextObj = Type.createInstance(Type.resolveClass(clazzStr),[]);

                        Reflect.setField(obj, nextField, nextObj);
                        Reflect.setField(obj, synthDef.field, null);
                    }
                }
            }

            setField(nextObj, remaining, value);
        }
    }


    public static function getModel(obj : Dynamic) : Model{
        return getProvider().getModel(Type.getClass(obj));
    }

    public static function generateMap(objs : Array<Dynamic>): Map<String, Dynamic>{
        var model : Model = getModel(objs[0]);

        var firstKey = model.getFirstKey();

        return generateMapWithField(objs, firstKey);
    }

    public static function generateMapWithField(objs : Array<Dynamic>, field : String) : Map<String, Dynamic>{
        var map = new Map<String, Dynamic>();

        for(obj in objs){
            map.set(extractField(obj, field), obj);
        }

        return map;
    }

    public function getUserConstraintField() : String{
        return userConstraintField;
    }

    public function getPublicConstraintField() : String {
        return publicConstraintField;
    }
}

class SearchDef {
    public var regex : EReg;
    public var replaceWith : String;

    public function new(){
        replaceWith = null;
        regex = null;
    }
}

class ModelAction {
    public var name : String;
    public var userSuffix : String;
    public var functionName : String;
    public var className : String;
    public var icon : String;

    public function new(name : String, userSuffix : String, qName : String, icon : String){
        this.name = name;
        this.userSuffix =  userSuffix;
        setQualifiedName(qName);
        this.icon = icon;
    }

    public function setQualifiedName(qName : String) : Void{
        var i = qName.lastIndexOf('.');
        functionName = qName.substring(i+1, qName.length);
        className = qName.substring(0, i);
    }

    public function run(obj : Dynamic, cb : Dynamic->Void) : Void{
        Reflect.callMethod(obj, Reflect.field(obj, functionName), [cb]);
    }
}