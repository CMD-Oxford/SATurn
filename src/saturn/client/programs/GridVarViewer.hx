/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.blocks.GridVarCanvasRenderer;
import saturn.client.programs.blocks.BaseScrollableCanvas;
import saturn.client.programs.plugins.GridVarPlugin;
import jQuery.JQuery;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.client.core.CommonCore;

import saturn.core.GridVar;
import saturn.client.workspace.GridVarWO;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import bindings.Ext;

import saturn.client.programs.blocks.BaseTable;
import saturn.client.programs.blocks.BaseTable.ColumnDefinition;

class GridVarViewer extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ GridVarWO ];

    var theComponent : Dynamic;

    var rowField : Dynamic;
    var gridVarDom : Dynamic;
    var dataTable : BaseTable;
    var styleTable : BaseTable;
    var annotationTable : BaseTable;

    var tabPanel : Dynamic;
    var gridVarElem : Dynamic;

    var cellSlider : Dynamic;
    var xLabelsCheckBox : Dynamic;

    var gridVarObj : GridVar;

    var canvasRender : Bool = true;
    var rendered : Bool = false;

    var dirty : Bool = false;

    //
    var data = new Array<Dynamic>();

    var columnToLabel = {};
    var columnOrder = [];
    var rowOrder = [];

    var canvasData = [];

    var type_to_styles = {};

    var paddingCheckbox : Dynamic;
    var fitToAreaCheckBox : Dynamic;

    var canvasGridVar : GridVarCanvasRenderer;

    var valueToSyles : Map<String, Array<Style>>;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        theComponent = Ext.create('Ext.panel.Panel', {
            layout : {
                type: 'accordion',
                multi: true,
                enableSplitters: true
            },
            listeners : {
                'afterrender' : function() { initialiseDOMComponent(); }
            }
        });

        var topPanel = Ext.create('Ext.panel.Panel', {
            title: "Graph",
            multiSelect: true,
            items : [
                {
                    xtype : "component",
                    autoEl : {
                        tag : "div",
                    },
                    style: {
                        'background-color': 'white',
                        height: '100%'
                    },
                    width: '100%',
                    itemId: 'gridvar_container',
                }
            ],
            style: {
                'background-color': 'white'
            },
            listeners : {
                'resize': function(){ if(rendered){redrawGridVar();} },
                'afterrender': function(){ rendered = true; redrawGridVar(); }
            },
            flex:1,
            layout:{
               type: 'fit'
            }
            //,
            //autoScroll: true
        });

        theComponent.add(topPanel);

        tabPanel = Ext.create('Ext.tab.Panel', {
            title: "Configuration",
            width:'100%',
            multiSelect: true,
            style: {
                'background-color': 'white'
            },
            flex:2,
            collapsed: false,
            listeners: {
                expand: function() {
                    if(gridVarObj != null){
                        gridVarObj.configCollapse = false;
                    }
                },
                collapse: function(){
                    if(gridVarObj != null){
                        gridVarObj.configCollapse = true;
                    }
                }
            }
        });

        theComponent.add(tabPanel);

        rowField = 'residue';

        addAnnotationTable();
        addStyleGridPanel();
        addDataGridPanel();

        tabPanel.setActiveTab(0);

        registerDropFolder('Objects', null, true);
    }

    override public function initialiseDOMComponent() {
        super.initialiseDOMComponent();
    }

    private function addStyleGridPanel(){
        var colDefs : Array<ColumnDefinition> = [
            { text: 'Annotation Group', dataIndex: 'data_type', editor: 'textfield'},
            { text: 'Mapping Value',  dataIndex: 'mapping', editor : 'textfield' },
            { text: 'Color',  dataIndex: 'color', editor : 'textfield' },
            { text: 'Annotation Label',  dataIndex: 'label', editor : 'textfield' },
            { text: 'Apply to rows',  dataIndex: 'columns', editor : 'textfield' },
            { text: 'Style', dataIndex: 'style', editor: 'textfield'}
        ];

        var data = [
            { 'data_type': 'covered',  "mapping":"1",  style: 'rec', "color":"purple", "label" : "Covered", 'columns': '*'  },
            { 'data_type': 'covered',  "mapping":"0",  style: 'rec', "color":"#f1f1f1", "label" : "Not Covered", 'columns': '*'  }
        ];

        styleTable = new BaseTable(colDefs, data, 'Styles');
        styleTable.build();

        styleTable.setEditListener(function(){
            setDirty(true);

            redrawGridVar();
        });

        tabPanel.add(styleTable.getComponent());
    }

    private function addDataGridPanel(){
        var colDefs : Array<ColumnDefinition> = [
            { text: 'Residue',  dataIndex: 'residue',editor : 'textfield' },
            { text: 'Construct', dataIndex: 'construct',editor : 'textfield' },
            { text: 'PDB', dataIndex: 'pdb', editor : 'textfield' }
        ];

        var data = [
            { 'residue': 'A',  "construct":"1",  "pdb":"1"  },
            { 'residue': 'T',  "construct":"1",  "pdb":"1"  },
            { 'residue': 'G',  "construct":"0",  "pdb":"1"  }
        ];

        dataTable = new BaseTable(colDefs, data, 'Raw Data');
        dataTable.build();
        dataTable.setEditListener(function(){
            setDirty(true);

            redrawGridVar();
        });

        tabPanel.add(dataTable.getComponent());
    }

    private function addAnnotationTable(){
        var colDefs : Array<ColumnDefinition> = [
            { text: 'Start',  dataIndex: 'start',editor : 'textfield' },
            { text: 'Stop', dataIndex: 'stop',editor : 'textfield' },
            { text: 'Value', dataIndex: 'value', editor : 'textfield' },
            { text: 'Row', dataIndex: 'column', editor : 'textfield' }
        ];

        var data = [
            { 'start': '1',  "stop":"3",  "value":"1"  }
        ];

        annotationTable = new BaseTable(colDefs, data, 'Annotations');
        annotationTable.build();
        annotationTable.setEditListener(function(){
            updateAnnotations();

            setDirty(true);

            redrawGridVar();
        });

        tabPanel.add(annotationTable.getComponent());
    }

    private function updateAnnotations(){
        annotationTable.getStore().each(function(record){
            if(annotationTable.isRecordEmpty(record)){
                return true;
            }

            var model = record.getData();

            var start :Dynamic = model.start -1;
            var stop :Dynamic = model.stop;
            var value = model.value;
            var column = model.column;

            if(column == null || column == ''){
                return true;
            }

            var columnIndex = null;

            for(columnDef in dataTable.getColumns()){
                if(columnDef.text == column){
                    columnIndex = columnDef.dataIndex;
                }
            }

            if(columnIndex == null){
                getApplication().showMessage('Invalid column name', 'Please enter a valid column name for ' + column);
                return false;
            }

            var dataStore = dataTable.getStore();

            var recordCount = dataStore.count();

            for(i in start...stop){
                if(i > recordCount){
                    dataTable.addNewRow();
                    recordCount++;
                }

                var model = dataStore.getAt(i);

                model.set(columnIndex, value);

                model.commit();
            }

            return true;
        });
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().hideMiddleSouthPanel();

        getApplication().getToolBar().add({
            iconCls :'x-btn-export',
            text: 'Export',
            handler: function(){
                exportSVGForCanvas();
            },
            tooltip: {dismissDelay: 10000, text: 'Export to SVG (open in Illustrator or Inkscape)'}
        });

        xLabelsCheckBox = getApplication().getToolBar().add({
            xtype: 'checkbox',
            boxLabel: 'x-labels',
            inputValue: '1',
            checked: gridVarObj != null && gridVarObj.showXLabels ? true : false,
            handler: function(){
                var This = untyped __js__('this');

                gridVarObj.showXLabels = This.getValue();

                redrawGridVar();
            },
            listeners: {
                'afterrender': function(c){
                   Ext.QuickTips.register({dismissDelay: 10000, target: c.getEl(), text: 'Show x-axis labels (for DNA/Protein this is the sequence)'});
                }
            }

        });

        paddingCheckbox = getApplication().getToolBar().add({
            xtype: 'checkbox',
            boxLabel: 'Squares',
            inputValue: '1',
            checked: gridVarObj != null && gridVarObj.padding ? true : false,
            handler: function(){
                var This = untyped __js__('this');

                gridVarObj.padding = This.getValue();

                redrawGridVar();
            },
            listeners: {
                'afterrender': function(c){
                    Ext.QuickTips.register({dismissDelay: 10000, target: c.getEl(), text: 'Draw individual squares'});
                }
            }
        });

        fitToAreaCheckBox = getApplication().getToolBar().add({
            xtype: 'checkbox',
            boxLabel: 'Fit',
            inputValue: '1',
            checked: gridVarObj != null && gridVarObj.fit ? true : false,
            handler: function(){
                var This = untyped __js__('this');

                gridVarObj.fit = This.getValue();

                updateActions();

                redrawGridVar();

                //gridVarObj.xCellSize = canvasGridVar.getXUnitSize();

                //cellSlider.setValue(gridVarObj.xCellSize);
            },listeners: {
                'afterrender': function(c){
                    Ext.QuickTips.register({dismissDelay: 10000, target: c.getEl(), text: 'Fit figure to smallest amount of space<br/>(more space may be consumed if x-labels are being shown)'});
                }
            }
        });

        cellSlider = getApplication().getToolBar().add({
                xtype: 'slider',
                width: 200,
                value: 9,
                increment: 0.2,
                minValue: 0.2,
                maxValue: 20,
                listeners: {
                    change: function(){
                        var This = untyped __js__('this');

                        gridVarObj.xCellSize = This.getValue();

                        redrawGridVar();
                    },
                    'afterrender': function(c){
                        Ext.QuickTips.register({dismissDelay: 10000, target: c.getEl(), text: 'Control the amount of space used to display the figure'});
                    }
                },
                disabled: gridVarObj != null && gridVarObj.fit ? true : false
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text: 'Add Row',
            handler: function(){
                dataTable.promptAddGridColumn(function(){
                    updateRowOrder();
                    redrawGridVar();
                });
            },
            tooltip: {dismissDelay: 10000, text: 'Add Row (rows are drawn along the y-axis)'}
        });

        getApplication().getViewMenu().add({
            text : "Update GridVar",
            handler : function(){
                redrawGridVar();
            }
        });
    }

    public function isDirty(){
        return dirty;
    }

    public function setDirty(dirty){
        this.dirty = dirty;
    }

    public function redrawGridVar(){
        if(getActiveObjectId() == null || gridVarObj == null){
            return;
        }

        var gridVar = getActiveObjectObject();

        gridVar.xCellSize = cellSlider.getValue();

        if(isDirty()){
            setDirty(false);
            regenerate();
        }

        gridVar.dataTableDefinition = dataTable.getTableDefinition();
        gridVar.styleTableDefinition = styleTable.getTableDefinition();
        gridVar.annotationTableDefinition = annotationTable.getTableDefinition();

        rowField = gridVar.dataTableDefinition.columnDefs[0].dataIndex;

        var domElem = theComponent.down('panel').down('component[itemId=gridvar_container]').getEl().dom;

        if(gridVarDom != null){
            domElem.removeChild(gridVarDom);
        }

        gridVarDom = js.Browser.document.createElement('div');
        gridVarDom.style.height = '100%';
        domElem.appendChild(gridVarDom);

        var lines :Dynamic = null;
        if(canvasGridVar != null){
            lines = canvasGridVar.lines;
        }else if(gridVarObj.lines != null){
            lines = gridVarObj.lines;
            gridVarObj.lines = null;
        }

        canvasGridVar = new GridVarCanvasRenderer(gridVarDom);

        if(lines != null){
            canvasGridVar.lines = lines;
        }

        js.Browser.window.console.log('width: ' +gridVarObj.xCellSize );

        canvasGridVar.setCellHeight(Math.max(gridVarObj.xCellSize,9));
        canvasGridVar.setCellWidth(gridVarObj.xCellSize);
        canvasGridVar.setColumnOrder(columnOrder);
        canvasGridVar.setData(canvasData);
        canvasGridVar.setColumnKeyToLabels(columnToLabel);
        canvasGridVar.setRowOrder(rowOrder);
        canvasGridVar.setStyles(valueToSyles);
        canvasGridVar.setRenderXLabels(gridVarObj.showXLabels);
        canvasGridVar.setPadding(gridVarObj.padding);
        canvasGridVar.setFitToArea(gridVarObj.fit);

        canvasGridVar.configure();

        js.Browser.window.console.log('width: ' +canvasGridVar.getXUnitSize() );

        canvasGridVar.render();
    }

    public function exportSVGForCanvas(){
        canvasGridVar.exportSVG();
    }

    public function updateStyles(){
        valueToSyles = new Map<String, Array<Style>>();

        styleTable.getStore().each(function(record){
            if(styleTable.isRecordEmpty(record)){
                return true;
            }

            var model = record.getData();

            var dataType = Reflect.field(model, 'data_type');
            var style =  Reflect.field(model, 'style');
            var value = Reflect.field(model, 'mapping');
            var colour = Reflect.field(model, 'color');
            var label = Reflect.field(model, 'label');
            var columns = Reflect.field(model, 'columns');

            if(dataType == null || dataType == '' ||
                value == null || value == '' ||
                    colour == null || colour == '' ||
                        label == null || label == '' ||
                            style == null || style == ''){
                return true;
            }

            var style : Style = {
                type:  style,
                colour: colour,
                name: label,
                columns: columns.split(','),
                value: value,
                group: dataType
            };

            if(!valueToSyles.exists(value)){
                valueToSyles.set(value, new Array<Style>());
            }

            valueToSyles.get(value).push(style);

            return true;
        });
    }

    public function updateData(){
        canvasData = [];

        columnOrder = [];

        columnToLabel = {};

        var i = 0;
        dataTable.getStore().each(function(record){
            if(dataTable.isRecordEmpty(record)){
                return true;
            }

            var model = record.getData();

            columnOrder.push(Std.string(i));

            canvasData[i] = [];

            var j = 0;
            for(field in rowOrder){
                canvasData[i][j] = Reflect.field(model, field);

                j++;
            }

            var rowValue = Reflect.field(model,rowField);
            Reflect.setField(columnToLabel,Std.string(i),rowValue);

            i++;

            return true;
        });
    }

    public function updateRowOrder(){
        rowOrder = [];

        for(field in dataTable.getModelFields()){
            if(field != rowField){
                rowOrder.push(field);
            }
        }
    }

    public function regenerate(){
        updateStyles();

        updateRowOrder();

        updateData();
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        update();
    }

    public function update(){
        Ext.suspendLayouts();

        var w0 : GridVarWO = cast(super.getActiveObject(GridVarWO), GridVarWO);
        var obj : GridVar = cast(w0.getObject(), GridVar);

        setTitle(w0.getName());

        setDirty(true);

        rowField = obj.dataTableDefinition.columnDefs[0].dataIndex;

        if(obj.fileContent != null){
            loadFromString(obj.fileContent);

            obj.fileContent = null;
        }

        dataTable.reconfigure(obj.dataTableDefinition);
        styleTable.reconfigure(obj.styleTableDefinition);
        annotationTable.reconfigure(obj.annotationTableDefinition);

        gridVarObj = obj;

        redrawGridVar();

        updateActions();

        if(gridVarObj != null){
            if(gridVarObj.configCollapse){
                tabPanel.collapse();
            }else{
                tabPanel.expand();
            }
        }

        Ext.resumeLayouts(true);
    }

    override public function updateActions(){
        super.updateActions();

        if(gridVarObj != null){
            if(gridVarObj.fit){
                fitToAreaCheckBox.setValue(true);
                cellSlider.disable();
            }else{
                fitToAreaCheckBox.setValue(false);
                cellSlider.enable();
            }

            if(gridVarObj.padding){
                paddingCheckbox.setValue(true);
            }else{
                paddingCheckbox.setValue(false);
            }

            if(gridVarObj.showXLabels){
                xLabelsCheckBox.setValue(true);
            }else{
                xLabelsCheckBox.setValue(false);
            }

            cellSlider.setValue(gridVarObj.xCellSize);
        }
    }

    public function reconfigure(dataTableDefinition : TableDefinition, styleTableDefinition : TableDefinition){
        var w0 : GridVarWO = cast(super.getActiveObject(GridVarWO), GridVarWO);
        var obj : GridVar = cast(w0.getObject(), GridVar);

        obj.dataTableDefinition = dataTableDefinition;
        obj.styleTableDefinition = styleTableDefinition;

        dataTable.reconfigure(obj.dataTableDefinition);
        styleTable.reconfigure(obj.styleTableDefinition);
    }

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }


    override public function getComponent() : Dynamic {
        return theComponent;
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-gridvar',
                text:'SeqFig<br/>Tool',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new GridVarWO(null, null), true);
                },
                tooltip: {dismissDelay: 10000, text: 'Summarise multi-dimensional data'}
            }
        ];
    }

    public static function parseFile(file : Dynamic){
        var ext = CommonCore.getFileExtension(file.name);

        if(ext == 'csv'){
            CommonCore.getFileAsText(file, function(content){
                if(content != null){
                    var obj = new GridVar();

                    obj.fileContent = content;

                    var wo = new GridVarWO(obj, file.name);

                    WorkspaceApplication.getApplication().getWorkspace().addObject(wo, true);
                }
            });
        }
    }

    public function getDataTable() : BaseTable {
        return dataTable;
    }

    override
    public function openFile(file : Dynamic, asNew : Bool, ?asNewOpenProgram :Bool = true) : Void {
        var pluginPos = 0;

        var next = null;

        next = function(){
            if(pluginPos < plugins.length){
                plugins[pluginPos++].openFile(file, next);
            }
        };

        next();
    }

    public function loadFromString(content : String){
        var lines = content.split('\n');

        var header = lines[0];
        var columns = header.split(',');

        var colDefs : Array<ColumnDefinition> = [];

        for(column in columns){
            colDefs.push({
                text: column,
                dataIndex: column,
                editor: 'textfield'

            });
        }

        rowField = colDefs[0].dataIndex;

        var data = new Array<Dynamic>();
        for(i in 1...lines.length){
            var line = lines[i];

            var cols = line.split(',');

            var row = {};

            for(j in 0...colDefs.length){
                Reflect.setField(row, colDefs[j].dataIndex, cols[j]);
            }

            data.push(row);
        }

        var dataTableDefinition = {
            columnDefs: colDefs,
            title: 'Raw Data',
            data: data,
            raw: null
        }

        var styleTableDefinition = {title: 'Styles', columnDefs: null, data: null};

        reconfigure(dataTableDefinition, styleTable.getTableDefinition());
    }

    override public function objectAddedToOutline(dropFolder :String, objectId : String){
        super.objectAddedToOutline(dropFolder, objectId);

        setDirty(true);

        for(plugin in getPlugins()){
            if(Std.is(plugin, GridVarPlugin)){
                var gvPlugin : GridVarPlugin = cast plugin;
                gvPlugin.outlineAdd(objectId);
            }
        }
    }

    override public function saveWait(cb){
        gridVarObj.lines = canvasGridVar.lines;

        cb();
    }
}
