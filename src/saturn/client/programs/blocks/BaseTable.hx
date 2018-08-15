/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.blocks;

import saturn.client.WorkspaceApplication;
import saturn.client.WorkspaceApplication;
import bindings.Ext;

class BaseTable implements BuildingBlock {
    var component : Dynamic;
    var name : String;
    var columns :Array<ColumnDefinition>;
    var model : Dynamic;
    var modelName : String;
    public var store : Dynamic;
    var data : Array<Dynamic>;
    var modelFields : Array<String>;
    var cellClicked : Array<Int>;
    var title : String;

    var editListener : Dynamic;
    var fixedRowHeight : Int;

    var errorColumns : Array<String>;

    var customContextItems : Array<Dynamic>;
    var hideTitle: Bool;
    var enableAutoAddNewRow : Bool;

    public function new(columns :Array<ColumnDefinition>, data : Array<Dynamic>, title : String, ?fixedRowHeight : Int=null, hideTitle : Bool = false, autoAddNewRow = true){
        this.columns = columns;
        this.data = data;
        this.title = title;
        this.fixedRowHeight = fixedRowHeight;
        this.hideTitle = hideTitle;
        this.enableAutoAddNewRow = autoAddNewRow;

        customContextItems = new Array<Dynamic>();
    }

    public function addCustomContextItem(item : Dynamic){
        customContextItems.push(item);
    }

    public function setFixedRowHeight(height : Int){
        this.fixedRowHeight = height;
    }

    public function getColumns() : Array<ColumnDefinition>{
        return columns;
    }

    public function onFocus() : Void{

    }

    public function onBlur() : Void{

    }

    public function getComponent() : Dynamic{
        return component;
    }

    public function getRawComponent() : Dynamic{
        return getComponent();
    }

    public function getModelFields() : Array<String>{
        return modelFields;
    }

    public function setEditListener(listener : Dynamic){
        editListener = listener;
    }

    public function onEdit(){
        editListener();
    }

    public function addListener(callBack : Dynamic->Void){
        component.on('containerClick',callBack);
    }

    public function reconfigure(tableDef : TableDefinition = null){
        if(tableDef != null){
            this.columns = tableDef.columnDefs;
            this.data = tableDef.data;
            this.title = tableDef.title;
        }

        build();
    }

    public function build() : BaseTable{
        name = 'store_'+Ext.id();

        modelName = 'model' + Ext.id();

        modelFields = [];

        if(columns != null){
            for(column in columns){
                modelFields.push(column.dataIndex);
            }
        }

        if(store == null){
            model =  Ext.define(modelName, {
                extend: 'Ext.data.Model',
                fields: modelFields
            });

            store = Ext.create('Ext.data.Store', {
                storeId: name,
                model: model,
                data:{
                    'items': data
                },
                proxy: {
                    type: 'memory',
                    reader: {
                        type: 'json',
                        rootProperty: 'items'
                    }
                }
            });

            component = Ext.create('Ext.grid.Panel',{
                store: store,
                columns: columns,
                width: '100%',
                region: 'center',
                scrollable: true,
                flex:1,
                //header: false,
                //features: [filters],
                title: title,
                preventHeader: hideTitle,
                plugins: [
                    Ext.create('Ext.grid.plugin.CellEditing', {
                        clicksToEdit: 2
                    }),
                    'gridfilters'
                ],
                selType: 'cellmodel',
                viewConfig: {
                    enableTextSelection: true,
                    stripeRows: false,
                     listeners: {
                        viewready: function(view) {
                            view.keyMap = new KeyMap(view.getEl(),[{
                                    key: "v",
                                    ctrl: true,
                                    fn: function(keyCode, e) {
                                        var pasteZone = js.Browser.document.createTextAreaElement();
                                        pasteZone.style.position = 'absolute';
                                        pasteZone.style.top = '-1000px';
                                        pasteZone.style.left = '-1000px';

                                        js.Browser.document.body.appendChild(pasteZone);

                                        js.Browser.window.setTimeout(function(){
                                            performPaste(pasteZone.value, cellClicked);

                                            js.Browser.document.body.removeChild(pasteZone);
                                        },100);

                                        pasteZone.focus();
                                        pasteZone.select();
                                    }
                            }]);

                            view.tooltip = Ext.create('Ext.tip.ToolTip', {
                                target: view.el,
                                delegate: view.itemSelector,
                                trackMouse: true,
                                renderTo: Ext.getBody(),
                                listeners: {
                                    beforeshow: function updateTipBody(tip) {
                                        var msg : String = null;
                                        var record = view.getRecord(tip.triggerElement);
                                        if(errorColumns != null){
                                            for(col in errorColumns){
                                                var value = record.get(col);

                                                if(value != null && value != ''){
                                                    msg = value;
                                                    break;
                                                }
                                            }
                                        }

                                        if(msg == null || msg == ''){
                                            msg = record.get(columns[0].dataIndex);
                                        }

                                        tip.update(msg);
                                    }
                                }
                            });
                        }
                    },
                    getRowClass: function(record, rowIndex, rowParams, store){
                        var css = this.getRecordCSS(record);

                        if(fixedRowHeight != null){
                            if(css == null){
                                css = '';
                            }
                            css += 'saturn-row-fixed-height';
                        }

                        WorkspaceApplication.getApplication().debug(css);

                        return css;

                        //return  'saturn-row-fixed-height';
                    }
                },
                listeners: {
                    edit : function(editor,e){
                        autoAddNewRow();

                        onEdit();
                    },
                    'cellcontextmenu':  function(view, cell, cellIndex, record, row, rowIndex, event) {
                        var column = view.getHeaderByCell(cell);
                        var position = view.getPositionByEvent(event);
                        var columnIndex = position.column;
                        var dataIndex = column.dataIndex;

                        var contextMenuItems : Array<Dynamic> = [
                            {
                                text : "Delete Row",
                                handler : function() {
                                    store.removeAt(rowIndex);

                                    autoAddNewRow();

                                    onEdit();
                                }
                            },
                            {
                                text : 'Copy',
                                handler : function(){
                                    var model = store.getAt(rowIndex);

                                    var fields = model.getFields();

                                    var cb = WorkspaceApplication.getApplication().getClipBoard();

                                    var cbContents = new ClipBoardRow();

                                    for(column in columns){
                                        if(column.dataIndex != 'id'){
                                            cbContents.set(column.dataIndex, model.get(column.dataIndex));
                                        }
                                    }

                                    cb.setContents(cbContents);
                                }
                            },
                            {
                                text : 'Fill down',
                                handler : function() {
                                    var model = store.getAt(rowIndex);
                                    var val = model.get(column.dataIndex);

                                    var c = store.count();

                                    for(i in rowIndex...(c-1)){
                                        var row = store.getAt(i);
                                        row.set(column.dataIndex,val);
                                    }

                                    onEdit();
                                }
                            },
                            {
                                text: 'Remove column',
                                handler: function(){
                                    removeColumn(dataIndex);
                                }
                            }
                        ];

                        var cb = WorkspaceApplication.getApplication().getClipBoard();
                        var contents = cb.getContents();
                        if(contents !=null && Std.is(contents, ClipBoardRow)){
                            contextMenuItems.push({
                                text : 'Paste After',
                                handler : function(){
                                    pasteRow(rowIndex + 1);
                                }
                            });

                            contextMenuItems.push({
                                text : 'Paste Before',
                                handler : function(){
                                    pasteRow(rowIndex);
                                }
                            });
                        }

                        for(item in customContextItems){
                            contextMenuItems.push({
                                text: item.text,
                                handler: function(){
                                    item.handler(rowIndex);
                                }
                            });
                        }

                        var contextMenu = Ext.create("Ext.menu.Menu",{
                            items : contextMenuItems
                        });

                        contextMenu.showAt(event.getXY());
                        event.stopEvent();
                    },
                    cellclick: function(grid, td, cellIndex, record, tr, rowIndex, e, eOpts ){
                        cellClicked = [cellIndex,rowIndex];

                        js.Browser.window.console.log('Clicked');
                    }
                }
            });
        }else{
            store.model.addFields(modelFields);

            store.setData(data);

            component.reconfigure(store, columns);
        }

        autoAddNewRow();

        return this;
    }

    public function autoAddNewRow(){
        if(!enableAutoAddNewRow){
            return;
        }

        var storeLen = store.count();

        var newRow = true;

        if(storeLen > 0){
            var record = store.getAt(storeLen-1);

            newRow = !isRecordEmpty(record);
        }

        if(newRow){
            addNewRow();
        }
    }

    public function addNewRow(){
        var model = Ext.create(model, { });

        for(colDef in columns){
            if(colDef.defaultValue != null && colDef.defaultValue != ''){
                model.set(colDef.dataIndex, colDef.defaultValue);
            }
        }

        store.insert(store.count(),model);
    }

    public function isRecordEmpty(record : Dynamic){
        var rowOccupied = false;

        for(col in columns){
            var dataIndex = col.dataIndex;

            if(dataIndex != null && dataIndex != '' && dataIndex != 'id'){
                var value = record.get(dataIndex);
                if(value != null && value != ''){
                    if(col.defaultValue != null && col.defaultValue != '' && col.defaultValue == value){
                        continue;
                    }

                    rowOccupied = true;
                    return false;
                }
            }
        }

        return !rowOccupied;
    }

    public function addColumn(columnDef : ColumnDefinition, reconfigure : Bool = true){
        var columnName = columnDef.dataIndex;

        columns.push(columnDef);

        modelFields.push(columnName);

        store.model.addFields([columnName]);

        if(reconfigure){
            component.reconfigure(store, columns);
        }
    }

    public function removeColumn(columnName : String){
        for(column in columns){
            if(column.dataIndex == columnName){
                columns.remove(column);
            }
        }

        modelFields.remove(columnName);

        store.model.replaceFields(null, [columnName]);

        component.reconfigure(store, columns);

        onEdit();
    }

    public function promptAddGridColumn(cb = null){
        WorkspaceApplication.getApplication().userValuePrompt('New Row', 'Add Row', function(columnName){
            if(columnName != null){
                addColumn({text: columnName, dataIndex: columnName, editor : 'textfield'});
                if(cb != null){
                    cb();
                }
            }
        }, null);
    }

    public function getStore() : Dynamic{
        return store;
    }

    public function getSize() : Int{
        return store.count();
    }

    public function performPaste(content : String, index : Dynamic){
        //WorkspaceApplication.suspendUpdates();
        Ext.suspendLayouts();

        //var columns :Dynamic = theTable.columns;
        var colCount = columns.length;

        var rowSep = '\n';

        if(content.indexOf('\r\n') > -1){
            rowSep = '\r\n';
        }

        var rows = content.split(rowSep);

        var colClicked = index[0];
        var rowClicked = index[1];

        var currentCol = colClicked;
        var currentRow = rowClicked;

        //var store = getStore();
        var storeCount = store.count();

        for(row in rows){
            if(row == ''){
                break;
            }

            var cols = row.split('\t');

            var pasteColIndex = 0;

            var newModel :Dynamic;

            if(currentRow > store.count() - 1 ){
                newModel = Ext.create(model, { });
                store.insert(currentRow,newModel);
            }else{
                newModel = store.getAt(currentRow);
            }

            currentRow++;

            for(col in currentCol...colCount){
                var field = columns[col].dataIndex;
                var value = cols[pasteColIndex++];

                if(value == null || value == '' && columns[col].defaultValue != null && columns[col].defaultValue != '' ){
                    value = columns[col].defaultValue;
                }

                if(field != 'id'){
                    newModel.set(columns[col].dataIndex,value);
                }else{
                    pasteColIndex++;
                }

                if(pasteColIndex > cols.length-1){
                    break;
                }
            }
            currentCol = colClicked;
        }
        autoAddNewRow();
        //WorkspaceApplication.resumeUpdates(false);
        Ext.resumeLayouts(false);

        onEdit();
    }

    public function addRow(data : Dynamic){
        var lastRow =  store.count() -1;
        var record = store.getAt(lastRow);

        for(field in Reflect.fields(data)){
            record.set(field, Reflect.field(data, field));
        }

        autoAddNewRow();
    }

    public function pasteRow(atPosition : Float){
        var cb = WorkspaceApplication.getApplication().getClipBoard();
        var contents = cb.getContents();

        if(Std.is(contents, ClipBoardRow)){
            WorkspaceApplication.suspendUpdates();
            var tableRowCopy = contents;
            var attributes = tableRowCopy.getContents();

            var model = store.insert(atPosition,Ext.create(model, { }))[0];

            for(column in columns){
                if(column.dataIndex != 'id'){
                    model.set(column.dataIndex,attributes.get(column.dataIndex));
                }
            }
            WorkspaceApplication.resumeUpdates(false);
        }

        onEdit();
    }

    public function getData() : Array<Dynamic> {
        return storeToData();
    }

    private function storeToData() : Array<Dynamic>{
        var data = new Array<Dynamic>();

        store.each(function(record){
            if(isRecordEmpty(record)){
                return true;
            }

            var model = record.getData();

            var row = {};

            for(columnDef in columns){
                var field = columnDef.dataIndex;
                if(field != 'id'){
                    Reflect.setField(row, field, Reflect.field(model, field));
                }
            }

            data.push(row);

            return true;
        });

        return data;
    }

    public function getTableDefinition(){
        return {
            columnDefs: columns,
            title: title,
            data: storeToData(),
            raw: null
        }
    }

    public function exportToString() : String{
        var entityStore = getStore();
        var entityCount :Int = entityStore.count() -1 ;

        var strBuf = new StringBuf();

        for(colDef in columns){
            strBuf.add(colDef.text+'\t');
        }

        strBuf.add('\n');

        for(i in 0...entityCount){
            var entityModel : Dynamic = entityStore.getAt(i);

            for(field in columns){
                var value = entityModel.get(field.dataIndex);

                if(value == null){
                    value = '';
                }

                strBuf.add(value+'\t');
            }

            strBuf.add('\n');
        }

        return strBuf.toString();
    }

    public function exportToFile(name){
        var str = exportToString();
        WorkspaceApplication.getApplication().saveTextFile(str, name + '.tsv');
    }

    public function setErrorColumns(columns : Array<String>){
        this.errorColumns = columns;
    }

    public function getErrorColumns() : Array<String>{
        return this.errorColumns;
    }

    function getRecordCSS(record){
        var invalid = false;

        if(errorColumns != null){
            for(errorColumn in this.errorColumns){
                var value = record.get(errorColumn);

                if(value != null && value != ''){
                    invalid = true;
                    break;
                }
            }
        }

        if(invalid){
            return 'gridrow-invalid';
        }else{
            return 'x-grid-cell';
        }
    }
}

typedef TableDefinition = {
    var columnDefs :Array<ColumnDefinition>;
    var title : String;
    var data : Array<Dynamic>;
    var raw : Dynamic;
}

typedef ColumnDefinition = {
    var text : String;
    var dataIndex : String;
    var editor : String;
    @:optional var renderer : Dynamic;
    @:optional var filter : Dynamic;
    @:optional var defaultValue : Dynamic;
}

class ClipBoardRow {
    var contents : Map<String,Dynamic>;

    public function new(){
        contents = new Map<String,Dynamic>();
    }

    public function set(key : String, value : Dynamic) : Void{
        contents.set(key, value);
    }

    public function getContents() : Map<String,Dynamic>{
        return contents;
    }
}
