/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.client.programs.blocks.BaseTable.TableDefinition;
import saturn.client.programs.blocks.BaseTable.ColumnDefinition;
class Table {
    public var tableDefinition : TableDefinition;
    public var errorColumns : Array<String>;

    var fixedRowHeight : Int;

    static var r_d =~/^\d*\.?\d*$/;

    public var name : String;

    public function new(){

    }

    public function setName(name : String) : Void {
        this.name = name;

        if(tableDefinition != null){
            tableDefinition.title = name;
        }
    }

    public function getName() : String {
        return this.name;
    }

    public function setErrorColumns(columns : Array<String>){
        this.errorColumns = columns;
    }

    public function getErrorColumns() : Array<String>{
        return this.errorColumns;
    }

    public function setFixedRowHeight(height : Int){
        this.fixedRowHeight = height;
    }

    public function getFixedRowHeight(): Int{
        return this.fixedRowHeight;
    }

    public function setTitle(title:String){
        tableDefinition.title=title;
    }

    public function setData(data : Array<Dynamic>, ?fieldConfig : Dynamic){
        var obj = data[0];

        var columnDefs = new Array<ColumnDefinition>();

        for(field in Reflect.fields(obj)){
            var filterType = 'string';

            //Automatically determine types - going to be slow
            for(i in 0...data.length){
                var obj1 = data[i];

                var value = Reflect.field(obj, field);

                if(value != null){
                    if(Std.is(value, Date)){
                        filterType = 'date';
                    }else if(r_d.match(value)){
                        filterType = 'numeric';
                    }

                    break;
                }
            }

            var config : ColumnDefinition = {text:field, dataIndex:field, editor:null, filter: {type:filterType}};

            if(fieldConfig != null && Reflect.hasField(fieldConfig,field)){
                if(Reflect.hasField(Reflect.field(fieldConfig,field),'renderer')){
                    Reflect.setField(config,'renderer', Reflect.field(Reflect.field(fieldConfig,field),'renderer'));
                }

                if(Reflect.hasField(Reflect.field(fieldConfig,field),'editor')){
                    Reflect.setField(config,'editor', Reflect.field(Reflect.field(fieldConfig,field),'editor'));
                }

                if(Reflect.hasField(Reflect.field(fieldConfig,field),'xtype')){
                    Reflect.setField(config,'xtype', Reflect.field(Reflect.field(fieldConfig,field),'xtype'));
                }

                if(Reflect.hasField(Reflect.field(fieldConfig,field),'dataindex')){
                    Reflect.setField(config,'dataindex', Reflect.field(Reflect.field(fieldConfig,field),'dataindex'));
                }

                if(Reflect.hasField(Reflect.field(fieldConfig,field),'text')){
                    Reflect.setField(config,'text', Reflect.field(Reflect.field(fieldConfig,field),'text'));
                }

                if(Reflect.hasField(Reflect.field(fieldConfig,field),'default')){
                    Reflect.setField(config,'defaultValue', Reflect.field(Reflect.field(fieldConfig,field),'default'));
                }
            }
            columnDefs.push(config);
        }

        tableDefinition = {
            columnDefs: columnDefs,
            title: 'Assay Results',
            data: data,
            raw: null
        };
    }

    public function getData(){
        return tableDefinition.data;
    }

    public function updateData(data : Array<Dynamic>){
        tableDefinition.data = data;
    }
}
