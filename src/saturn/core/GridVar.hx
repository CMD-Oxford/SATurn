/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.util.HaxeException;
import saturn.client.programs.blocks.BaseTable.TableDefinition;
import saturn.client.programs.blocks.BaseTable.ColumnDefinition;

class GridVar {
    public var dataTableDefinition : TableDefinition;
    public var styleTableDefinition : TableDefinition;
    public var annotationTableDefinition : TableDefinition;

    public var fileContent : String;
    public var showXLabels : Bool = true;
    public var xCellSize : Float = 10;
    public var padding : Bool = true;
    public var fit : Bool = true;
    public var configCollapse : Bool = false;

    public var lines : Array<Dynamic>;

    public function new(){
        styleTableDefinition = {
            columnDefs : [
                { text: 'Annotation Group', dataIndex: 'data_type', editor: 'textfield'},
                { text: 'Annotation Label',  dataIndex: 'label', editor : 'textfield' },
                { text: 'Apply to rows',  dataIndex: 'columns', editor : 'textfield' },
                { text: 'Mapping Value',  dataIndex: 'mapping', editor : 'textfield' },
                { text: 'Color',  dataIndex: 'color', editor : 'textfield' },
                { text: 'Style', dataIndex: 'style', editor: 'textfield'}
            ],
            title: 'Styles',
            data: [
                /*
                { 'data_type': 'covered',  "mapping":"1",  style: 'rec', "color":"purple", "label" : "Covered", 'columns': '*'  },
                { 'data_type': 'covered',  "mapping":"0",  style: 'rec', "color":"#f1f1f1", "label" : "Not Covered", 'columns': '*'  }*/
            ],
            raw: null
        };

        dataTableDefinition = {
            title: 'Raw Data',
            data: [],
            columnDefs:[{ text: 'Position',  dataIndex: 'position',editor : 'textfield' },{ text: 'Domain',  dataIndex: 'Domain',editor : 'textfield' }],
            raw: null
        };

        annotationTableDefinition = {
            columnDefs:[
                { text: 'Start',  dataIndex: 'start',editor : 'textfield' },
                { text: 'Stop', dataIndex: 'stop',editor : 'textfield' },
                { text: 'Value', dataIndex: 'value', editor : 'textfield' },
                { text: 'Row', dataIndex: 'column', editor : 'textfield' }
            ],
            title: 'Annotations',
            data: [],
            raw: null
        }
    }

    public function setShowXLabels(show : Bool){
        this.showXLabels = show;
    }

    public function setFit(fit : Bool){
        this.fit = fit;
    }

    public function addStyle(label : String, group : String, styleCode : String, styleShape : String, styleColour : String, columns: String = '*'){
        styleTableDefinition.data.push({
            data_type: group,
            mapping: styleCode,
            style: styleShape,
            color: styleColour,
            label: label,
            columns: columns
        });
    }

    public function setLength(length : Int){
        dataTableDefinition.data = [];

        if(dataTableDefinition.columnDefs.length == 0){
            dataTableDefinition.columnDefs.push({
                dataIndex: 'position',
                editor: 'textfield',
                text: 'Position'
            });
        }

        for(i in 0...length){
            var obj = {};

            var j = 0;
            for(columnDef in dataTableDefinition.columnDefs){
                if(j==0){
                    Reflect.setField(obj, columnDef.dataIndex, i);
                }else{
                    Reflect.setField(obj, columnDef.dataIndex, null);
                }

                j++;
            }

            dataTableDefinition.data.push(obj);
        }
    }

    public function setSequence(sequence : String){
        //Clear Annotations
        dataTableDefinition.data = [];

        if(dataTableDefinition.columnDefs.length == 0){
            dataTableDefinition.columnDefs.push({
                dataIndex: 'position',
                editor: 'textfield',
                text: 'Position'
            });
        }

        for(i in 0...sequence.length){
            var obj = {};

            var j = 0;
            for(columnDef in dataTableDefinition.columnDefs){
                if(j==0){
                    Reflect.setField(obj, columnDef.dataIndex, sequence.charAt(i));
                }else{
                    Reflect.setField(obj, columnDef.dataIndex, null);
                }

                j++;
            }

            dataTableDefinition.data.push(obj);
        }
    }

    public function addAnnotation(type : String, start : Int, stop : Int, styleCode : String) {
        if(stop > dataTableDefinition.data.length){
            throw new HaxeException('Annotation stop coordinate is larger than the table dimension');
        }

        for(i in start...stop){
            Reflect.setField(dataTableDefinition.data[i], type, styleCode);
        }

        var match = false;
        for(columnDef in dataTableDefinition.columnDefs){
            if(Reflect.field(columnDef, 'dataIndex') == type){
                match = true;
                break;
            }
        }

        annotationTableDefinition.data.push({
            start: start,
            stop: stop,
            value: styleCode,
            column: type
        });

        if(!match){
            dataTableDefinition.columnDefs.push({
                dataIndex: type,
                editor: 'textfield',
                text: type
            });
        }
    }

    public function setStyle(annotationKey : String, colour : String, value : String, styleName : String, styleGroup : String){
        for(j in 0...dataTableDefinition.data.length){
            if(Reflect.field(dataTableDefinition.data[j], annotationKey) == 1){
                Reflect.setField(dataTableDefinition.data[j], annotationKey, value);
            }
        }

        addStyle(styleName, styleGroup, value, 'rec', colour, '*');
    }
}
