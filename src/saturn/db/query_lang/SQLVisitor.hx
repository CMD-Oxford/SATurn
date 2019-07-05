/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.db.query_lang;

import saturn.core.Util;
import saturn.db.query_lang.EndBlock;


class SQLVisitor {
    public var provider : Provider;
    public var values : Array<Dynamic>;
    private var valPos : Int;
    private var nextAliasId : Int;

    var aliasToGenerated : Map<String, String>;
    var generatedToAlias : Map<String, String>;

    public static var injection_check =~/^([A-Za-z0-9\.])+$/;

    public function new(provider : Provider, ?valPos : Int = 1, ?aliasToGenerated : Map<String, String> =  null, ?nextAliasId : Int = 0) {
        this.provider = provider;
        this.values = new Array<Dynamic>();

        this.valPos = valPos;

        if(aliasToGenerated == null){
            this.aliasToGenerated = new Map<String, String>();
        }else{
            this.aliasToGenerated = aliasToGenerated;
        }

        this.nextAliasId = nextAliasId;
    }

    public function generateId(alias : String, baseValue = 'ALIAS_') : String{
        if(aliasToGenerated.exists(alias)){
            return aliasToGenerated.get(alias);
        }
        nextAliasId++;

        var id = baseValue + nextAliasId;

        aliasToGenerated.set(alias, id);

        Util.debug('Mapping' + alias + ' to  '+ id);

        return id;
    }

    public function getNextValuePosition() : Int {
        return this.valPos;
    }

    public function getNextAliasId() : Int{
        return this.nextAliasId;
    }

    public function getValues() : Array<Dynamic>{
        return this.values;
    }

    public function translate(token : Token) : Dynamic{
        var sqlTranslation = '';

        if(token == null){

        }else if(Std.is(token, Query)){
            var query = cast(token, Query);

            postProcess(query);

            var sqlQuery = '';
            var tokens = query.getTokens();
            for(token in tokens){
                sqlTranslation += translate(token);
            }
        }else{
            var nestedTranslation = '';

            if(token.getTokens() != null){
                var tokenTranslations = new Array<String>();

                if(Std.is(token, Instr)){
                    if(provider.getProviderType() == 'SQLITE' || provider.getProviderType() == 'MYSQL'){
                        token.tokens.pop();
                        token.tokens.pop();
                    }
                }

                for(token in token.getTokens()){
                    if(Std.is(token, Query)){
                        var subVisitor : SQLVisitor = new SQLVisitor(provider, valPos, aliasToGenerated, nextAliasId);

                        valPos = subVisitor.getNextValuePosition();
                        nextAliasId = subVisitor.getNextAliasId();

                        var generatedAlias = '';
                        if(token.name != null && token.name != ''){
                            generatedAlias = generateId(token.name);
                        }

                        tokenTranslations.push('(' + subVisitor.translate(token) + ') ' + generatedAlias + ' ');

                        for(value in subVisitor.getValues()){
                            values.push(value);
                        }
                    }else{
                        tokenTranslations.push(translate(token));
                    }

                }

                var joinSep = ' ';
                if(Std.is(token, Select) || Std.is(token, From) || Std.is(token, Function) || Std.is(token, Group) || Std.is(token, OrderBy)){
                    joinSep = ',';
                }

                nestedTranslation = tokenTranslations.join(joinSep);
            }

            if(Std.is(token, Value)){
                var cToken : Value = cast(token, Value);

                values.push(cToken.getValue());

                sqlTranslation += ' ' + getParameterNotation(valPos++) + ' ' + nestedTranslation + ' ';
            }else if(Std.is(token, Function)){
                if(Std.is(token, Trim)){
                    if(provider.getProviderType() == 'SQLITE'){
                        sqlTranslation += 'ltrim('+nestedTranslation +',\'0\''+')';
                    }else{
                        sqlTranslation += 'Trim( leading \'0\' from ' + nestedTranslation + ')';
                    }
                }else{
                    var funcName = '';
                    var specialCastAsInt = false;

		            if(Std.is(token, Max)){
                        funcName = 'MAX';
                    }else if(Std.is(token, Count)){
                        funcName = 'COUNT';
                    }else if(Std.is(token, Instr)){
                        funcName = 'INSTR';
                    }else if(Std.is(token, Substr)){
                        funcName = 'SUBSTR';
                    }else if(Std.is(token, Length)){
                        funcName = 'LENGTH';
                    }else if(Std.is(token, Concat)){
                        funcName = 'CONCAT';
                    }else if(Std.is(token, RegexpLike)){
                        funcName = 'REGEXP_LIKE';
                    }else if(Std.is(token, ToNumber)){
                        if(provider.getProviderType() == 'MYSQL'){
                            funcName = 'cast';
                            specialCastAsInt = true;
                        }else{
                                        funcName = 'to_number';
                        }

                    }else if(Std.is(token, CastAsInt)){
                        funcName = 'cast';
			            specialCastAsInt = true;
                    }

                    if(!specialCastAsInt){
                        sqlTranslation += funcName + '( ' + nestedTranslation + ' )';
                    }else{
                        sqlTranslation += funcName + '( ' + nestedTranslation + ' as int)';
                    }

                }
            }else if(Std.is(token, Select)){
                sqlTranslation += ' SELECT ' + nestedTranslation;
            }else if(Std.is(token, Field)){
                var cToken : Field = cast(token, Field);
                var clazzName : String = cToken.getClass();

                var fieldPrefix :String = null;
                var fieldName : String = null;

                if(cToken.clazzAlias != null){
                    fieldPrefix = generateId(cToken.clazzAlias);
                }

                if(clazzName != null){
                    var model = provider.getModelByStringName(clazzName);
                    fieldName = model.getSqlColumn(cToken.getAttributeName());

                    if(fieldPrefix == null){
                        var tableName = model.getTableName();
                        var schemaName = model.getSchemaName();

                        fieldPrefix =   provider.generateQualifiedName(schemaName, tableName);
                    }
                }else{
                    fieldName = generateId(cToken.attributeName);
                }


                if(cToken.getAttributeName() == '*'){
                    sqlTranslation += fieldPrefix + '.*';
                }else{
                    sqlTranslation += fieldPrefix + '.' + fieldName;
                }

                sqlTranslation += ' ' + nestedTranslation + ' ';
            }else if(Std.is(token, Where)){
                sqlTranslation += ' WHERE ' + nestedTranslation;
            }else if(Std.is(token, Group)){
                sqlTranslation += ' GROUP BY ' + nestedTranslation;
            }else if(Std.is(token, From)){
                sqlTranslation += ' FROM ' + nestedTranslation;
            }else if(Std.is(token, OrderBy)){
                sqlTranslation += ' ORDER BY ' + nestedTranslation;
            }else if(Std.is(token, OrderByItem)){
                var oToken = cast(token, OrderByItem);

                var direction = 'ASC';

                if(oToken.descending){
                    direction = 'DESC';
                }

                sqlTranslation +=  nestedTranslation + ' ' + direction;
            }else if(Std.is(token, ClassToken)){
                var cToken : ClassToken = cast(token, ClassToken);
                var model = provider.getModelByStringName(cToken.getClass());

                var tableName = model.getTableName();
                var schemaName = model.getSchemaName();

                var name =   provider.generateQualifiedName(schemaName, tableName);

                sqlTranslation += ' '+ name + ' ';
            }else if(Std.is(token, Operator)){
                if(Std.is(token, And)){
                    sqlTranslation += ' AND ' + nestedTranslation;
                }else if(Std.is(token, Plus)){
                    sqlTranslation += ' + ' + nestedTranslation;
                }else if(Std.is(token, Minus)){
                    sqlTranslation += ' - ' + nestedTranslation;
                }else if(Std.is(token, Or)){
                    sqlTranslation += ' OR ' + nestedTranslation;
                }else if(Std.is(token, Equals)){
                    sqlTranslation += ' = ' + nestedTranslation;
                }else if(Std.is(token, IsNull)){
                    sqlTranslation += ' IS NULL ' + nestedTranslation;
                }else if(Std.is(token, IsNotNull)){
                    sqlTranslation += ' IS NOT NULL ' + nestedTranslation;
                }else if(Std.is(token, GreaterThan)){
                    sqlTranslation += ' > ' + nestedTranslation;
                }else if(Std.is(token, GreaterThanOrEqualTo)){
                    sqlTranslation += ' >= ' + nestedTranslation;
                }else if(Std.is(token, LessThan)){
                    sqlTranslation += ' < ' + nestedTranslation;
                }else if(Std.is(token, LessThanOrEqualTo)){
                    sqlTranslation += ' <= ' + nestedTranslation;
                }else if(Std.is(token, In)){
                    sqlTranslation += ' IN ' + nestedTranslation;
                }else if(Std.is(token, Concat)){
                    sqlTranslation += ' || ' + nestedTranslation;
                }else if(Std.is(token, Like)){
                    sqlTranslation += ' LIKE ' + nestedTranslation;
                }
            }else if(Std.is(token, ValueList)){
                var cToken : ValueList = cast(token, ValueList);

                var values : Array<Dynamic> = cToken.getValues();
                var itemStrings : Array<String> = new Array<String>();

                for(i in 0...values.length){
                    itemStrings.push(getParameterNotation(valPos++));
                    values.push(values[i]);
                }

                sqlTranslation += ' ( ' + itemStrings.join(',') + ' ) ';
            }else if(Std.is(token, Limit)){
                var cToken : Limit = cast(token, Limit);

                sqlTranslation += getLimitClause(nestedTranslation);
            }else if(Std.is(token, StartBlock)){
                sqlTranslation += ' ( ';
            }else if(Std.is(token,EndBlock)){
                sqlTranslation += ' ) ';
            }else{
                sqlTranslation += ' ' + nestedTranslation + ' ';
            }
        }

        if(token != null && token.name != null && !Std.is(token, Query)){
            var generatedAlias : String = generateId(token.name);

            sqlTranslation += '  "' + generatedAlias + '"';
        }

        //Util.debug(token + '/' + sqlTranslation);

        return sqlTranslation;
    }

    public function getProcessedResults(results : Array<Dynamic>) : Array<Dynamic>{
        if(results.length > 0){
            generatedToAlias = new Map<String, String>();
            for(generated in aliasToGenerated.keys()){
                generatedToAlias.set(aliasToGenerated.get(generated), generated);
            }

            var fields = Reflect.fields(results[0]);
            var toRename = new Array<String>();

            for(field in fields){
                if(generatedToAlias.exists(field)){
                    toRename.push(field);
                }
            }

            if(toRename.length > 0){
                for(row in results){
                    for(field in toRename){
                        var val = Reflect.field(row, field);
                        Reflect.deleteField(row, field);
                        Reflect.setField(row, generatedToAlias.get(field), val);
                    }
                }
            }


        }

        return results;
    }

    public function getParameterNotation( i : Int){
        if(provider.getProviderType() == 'ORACLE'){
            return ':' + i;
        }else if(provider.getProviderType() == 'MYSQL'){
            return '?';
        }else if(provider.getProviderType() == 'PGSQL'){
            return '$' + i;
        }else{
            return '?';
        }
    }

    public function postProcess(query : Query){
        if(provider.getProviderType() == 'ORACLE'){
            if(query.tokens != null && query.tokens.length > 0){
                for(token in query.tokens){
                    if(Std.is(token, Limit)){
                        if(query.whereToken == null){
                            query.whereToken = new Where();
                        }

                        var where = query.getWhere();
                        where.add(token);

                        query.tokens.remove(token);
                    }
                }
            }

        }
    }

    public function getLimitClause(txt){
        if(provider.getProviderType() == 'ORACLE'){
            return ' ROWNUM < ' + txt;
        }else if(provider.getProviderType() == 'MYSQL'){
            return ' limit ' + txt;
        }else if(provider.getProviderType() == 'PGSQL'){
            return ' LIMIT ' + txt;
        }else{
            return ' limit ' + txt;
        }
    }

    public function buildSqlInClause(numIds : Int, ?nextVal = 0, ?func : String = null) : String{
        var inClause = new StringBuf();

        inClause.add('IN(');



        inClause.add(')');

        return inClause.toString();
    }
}
