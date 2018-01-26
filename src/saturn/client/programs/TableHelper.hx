/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.TableHelperData;
import saturn.client.workspace.TableHelperWO;
import saturn.client.workspace.Workspace.WorkspaceObject;
import js.html.Blob;
import bindings.FileSaver;
import saturn.db.Model;
import haxe.Json;

import saturn.client.programs.SimpleExtJSProgram;
import bindings.Ext;

import saturn.client.WorkspaceApplication;

import saturn.db.BatchFetch;

class TableHelper extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ TableHelperWO ];

    var theComponent : Dynamic;
    var theTable : Dynamic;
    var cellClicked : Array<Int>;
    var theModel : Model;

    var theModelClass : Class<Dynamic>;

    var theTitle : String;

    static var next_store_id = 0;

    var storeId : String;

    var viewReady = false;
    var loadRequired = false;

    var invalidRows : Array<String>;

    var internalIdField : String;

    var hideHiddenColumns : Bool;

    var showInternalRowId : Bool;

    var rowValidField : String;

    var resetOnActions = true;

    var loadedExisting = false;

    var tableColumns : Array<Dynamic>;

    public function new(modelClass){
        theModelClass = modelClass;

        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        hideHiddenColumns = true;

        internalIdField = '__HIDDEN_ROW_ID';

        rowValidField = '__HIDDEN_ROW_VALID';

        showInternalRowId = false;

        invalidRows = new Array<String>();

        theModel = getApplication().getProvider().getModel(theModelClass);
        if(theModel ==  null){
            getApplication().showMessage('Data mapping error','Unable to find model ' + theModelClass);
            return;
        }

        var fields = theModel.getFieldDefs();
        fields.unshift('ROWNUM');

        fields.unshift(internalIdField);
        fields.unshift(rowValidField);

        if(!Ext.ClassManager.isCreated(theModel.getExtModelName())){
            var dWin :Dynamic = cast js.Browser.window;

            dWin.fields = fields;
            dWin.internalId = internalIdField;
            dWin.name = theModel.getExtModelName();

            Ext.define(theModel.getExtModelName(), {
                extend: 'Ext.data.Model',
                fields : fields,
    //requires: ['Ext.data.SequentialIdGenerator'],
    //idgen: 'sequential',
                idProperty: internalIdField,
                identifier: {
                    type: 'sequential'
                }
            });
        }

        storeId = next_store_id + ':' + theModel.getExtStoreName();

        next_store_id++;

        Ext.create('Ext.data.Store', {
            storeId: storeId,
            model : theModel.getExtModelName(),
            data: [{ROWNUMBER:'1'}],
            proxy: {
                type: 'memory'
            }
        });

        theComponent = Ext.create('Ext.panel.Panel', {
            title: theTitle,
            width:'100%',
            height: '95%',
            region:'middle',
            autoScroll : true,
            layout : {
                type: 'vbox',
                align : 'stretch',
                pack  : 'start'
            },
            multiSelect: true,
            //items : getButtonPanelConfiguration(),
            listeners : {
                'render' : function(obj) {
                    theComponent = obj;

                    initialiseDOMComponent();
                }

            },
            //viewConfig:{trackOver: false}
        });
    }

    public function getButtonPanelConfiguration() : Array<Dynamic>{

        return [
                    {
                        region : 'center',
                        xtype : 'button',
                        text : 'Save',
                        handler : function() {
                            upsert();
                        }
                    },
                    {
                        region : 'center',
                        xtype : 'button',
                        text : 'Fetch all',
                        handler : function() {
                            fetchAll(function(){
                                getApplication().showMessage('Fetch successful','Fetch complete');
                            });
                        }
                    }
        ];
    }

    public function getContextMenuItems(modelColumn : String, rowIndex : Int) : Array<Dynamic>{
        var items = new Array<Dynamic>();

        var c = getStore().count();

        if( rowIndex != c-1 ){
            var model = getStore().getAt(rowIndex).getData();

            var priKey = theModel.getPrimaryKey();

            var val = Reflect.field(model, priKey);

            if(val != null && val != ''){
                items.push({
                    text : "Delete from database",
                    handler : function() {
                        var onCancel = function(){

                        };

                        var firstKey = theModel.getFirstKey();
                        var firstVal = Reflect.field(model, firstKey);

                        getApplication().userPrompt('Delete confirmation','Are you sure you want to delete ' + firstVal,function(){
                            var models = [model];
                            getProvider().modelToReal(theModel, models, function(err, realModels){
                                if(err == null){
                                    var realModel = realModels[0];

                                    insertOrDeletePerformed();

                                    getProvider().delete(realModel,function(err){
                                        if(err == null){
                                            getApplication().showMessage('Success','Delete successful');
                                            getStore().removeAt(rowIndex);

                                            autoAddNewRow();

                                            /*getProvider().commit(function(err){
                                                if(err == null){
                                                    getStore().removeAt(rowIndex);

                                                    autoAddNewRow();
                                                }else{
                                                    getApplication().showMessage('Delete failure',err.message);
                                                }
                                            });*/
                                        }else{
                                            var d : Dynamic = js.Browser.window;
                                            d.err = err;
                                            getApplication().showMessage('Delete failure',err);
                                        }
                                    });
                                }else{
                                    getApplication().showMessage('Delete failure',err);
                                }
                            });

                            autoAddNewRow();
                        },onCancel,onCancel);

                    }
                });
            }else{
                items.push({
                    text : "Delete Row",
                    handler : function() {
                        getStore().removeAt(rowIndex);

                        autoAddNewRow();
                    }
                });
            }

            items.push({
                text : 'Fill down',
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var val = model.get(modelColumn);

                    var c = getStore().count();

                    for(i in rowIndex...(c-1)){
                        var row = getStore().getAt(i);
                        row.set(modelColumn,val);

                        //row.commit();
                    }
                }
            });

            items.push({
                text : 'Copy',
                handler : function(){
                    var model = getStore().getAt(rowIndex);

                    var fields = theModel.getFields();
                    var priField = theModel.getPrimaryKey();

                    var cb = getApplication().getClipBoard();

                    var cbContents = new ClipBoardRow();

                    for(field in fields){
                        if(field != priField){
                            cbContents.set(field, model.get(field));
                        }
                    }

                    cb.setContents(cbContents);

                    /*
                    var entityStore = Ext.data.StoreManager.lookup(theModel.getExtStoreName());

                    var model = entityStore.insert(c++,Ext.create(theModel.getExtModelName(), { }))[0];

                    model.set(firstKey,val);*/
                }
            });
        }

        var cb = getApplication().getClipBoard();

        var contents = cb.getContents();

        if(Std.is(contents, ClipBoardRow)){
            if( rowIndex != c-1 ){
                items.push({
                    text : 'Paste After',
                    handler : function(){
                        pasteRow(rowIndex + 1);
                    }
                });
            }

            items.push({
            text : 'Paste Before',
            handler : function(){
                pasteRow(rowIndex);
            }
            });
        }

        return items;
    }

    public function pasteRow(atPosition : Int){
        var cb = getApplication().getClipBoard();
        var contents = cb.getContents();

        if(Std.is(contents, ClipBoardRow)){
            WorkspaceApplication.suspendUpdates();
            var tableRowCopy = contents;
            var attributes = tableRowCopy.getContents();

            var entityStore = getStore();

            var fields = theModel.getFields();
            var priField = theModel.getPrimaryKey();

            var model = entityStore.insert(atPosition,Ext.create(theModel.getExtModelName(), { }))[0];

            for(field in fields){
                if(field != priField){
                    model.set(field,attributes.get(field));
                }
            }
            WorkspaceApplication.resumeUpdates(false);
        }
    }

    override public function initialiseDOMComponent() {
        super.initialiseDOMComponent();

        var me = this;

        completeSetup();

        /*haxe.Timer.delay(function() {
            me.completeSetup();
        },2000);*/
    }

    function completeSetup() {
        tableColumns = theModel.getExtTableDefinition();

        if(hideHiddenColumns){
            for(tableColumn in tableColumns){
                if(StringTools.startsWith(tableColumn.dataIndex,'__HIDDEN')){
                    tableColumns.remove(tableColumn);
                }
            }
        }else{
            tableColumns.push({
                header:'Row Valid',
                dataIndex:rowValidField
            });
        }

        if(showInternalRowId){
            tableColumns.push({
                header:'Internal Field ID',
                dataIndex:internalIdField
            });
        }

        //var me = this;

        theTable = Ext.create('Ext.grid.Panel', {
            selType: 'cellmodel',
            flex: 1,
            region: 'south',
            store: getStore(),
            columns: tableColumns,
            plugins: [
                Ext.create('Ext.grid.plugin.CellEditing', {
                   // clicksToEdit: 2
                })
            ],
            listeners: {
                edit : function(editor,e){
                    //e.record.commit();
                    autoAddNewRow();
                },
                cellclick: function(grid, td, cellIndex, record, tr, rowIndex, e, eOpts ){
                    this.cellClicked = [cellIndex,rowIndex];
                },
                'cellcontextmenu':  function(view, cell, cellIndex, record, row, rowIndex, event) {
                    var column = view.getHeaderByCell(cell);
                    var position = view.getPositionByEvent(event);
                    var columnIndex = position.column;
                    var dataIndex = column.dataIndex;

                    var contextMenuItems : Array<Dynamic> = getContextMenuItems(column.dataIndex,rowIndex);
                    if(contextMenuItems.length > 0){
                        var contextMenu = Ext.create("Ext.menu.Menu",{
                            items : contextMenuItems
                        });

                        contextMenu.showAt(event.getXY());
                        event.stopEvent();
                    }
                },
                'beforecellmouseup': function( view, cell, cellIndex, record, tr, rowIndex, event, eOpts ){
                    //var column = view.getHeaderByCell(cell);
                    if (event.ctrlKey) {
                        var column = view.getHeaderByCell(cell);
                        var position = view.getPositionByEvent(event);
                        var columnIndex = position.column;
                        var dataIndex = column.dataIndex;

                        var contextMenuItems : Array<Dynamic> = getContextMenuItems(column.dataIndex,rowIndex);//getContextMenuItems(column.dataIndex,rowIndex);
                        if(contextMenuItems.length > 0){
                            var contextMenu = Ext.create("Ext.menu.Menu",{
                                items : contextMenuItems
                            });

                            contextMenu.showAt(event.getXY());
                            event.stopEvent();
                        }
                    }
                }
            },
            viewConfig: {
                enableTextSelection: true,
                stripeRows: false,
                listeners: {
                    viewready: function(view) {
                        /*var columnsManager = view.getHeaderCt();
                        var columnsCount = columnsManager.getColumnCount();

                        Ext.suspendLayouts();
                        //view.suspendEvents();

                        for(headerIndex in 0...columnsCount){
                            // This is a dirty hack to only resize based on the first column
                            // see http://docs.sencha.com/extjs/4.2.1/source/Table3.html#Ext-view-Table-method-autoSizeColumn
                            var header = columnsManager.getHeaderAtIndex(headerIndex);

                            header.flex = null;

                            var cells :Array<Dynamic>= view.el.query(header.getCellInnerSelector());
                            var originalWidth = header.getWidth();

                            var hasPaddingBug = Ext.supports.ScrollWidthInlinePaddingBug;
                            var columnSizer = view.body.select(view.getColumnSizerSelector(header));
                            var paddingAdjust = 0;
                            var ln = cells.length;

                            if (hasPaddingBug && ln > 0) {
                                paddingAdjust = view.getCellPaddingAfter(cells[0]);
                            }

                            columnSizer.setWidth(1);

                            var maxWidth :Float = header.textEl.dom.offsetWidth + header.titleEl.getPadding('lr');

                            maxWidth = Math.max(maxWidth, cells[0].scrollWidth);

                            if (hasPaddingBug) {
                                maxWidth += paddingAdjust;
                            }

                            maxWidth = Math.max(maxWidth, 40);

                            columnSizer.setWidth(originalWidth);

                            header.suspendLayout = true;

                            //header.setWidth(Math.min(maxWidth, 200));

                            view.autoSizeColumn(header);
                        }

                        //view.refresh();

                        Ext.resumeLayouts(true);

                        //view.refresh();

                        //Ext.resumeLayouts(false);
                        //view.resumeEvents(true);
                        */
                        if(loadRequired){
                            loadExistingModels();

                            if(!loadedExisting){
                                queryLoad();
                            }
                        }

                        viewReady = true;

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

                                        this.performPaste(pasteZone.value, view);

                                        js.Browser.document.body.removeChild(pasteZone);
                                    },100);

                                    pasteZone.focus();
                                    pasteZone.select();
                                }
                        }]);

                        var key : String = theModel.getFirstKey();
                        var validField = rowValidField;

                        view.tooltip = Ext.create('Ext.tip.ToolTip', {
                            target: view.el,
                            delegate: view.itemSelector,
                            trackMouse: true,
                            renderTo: Ext.getBody(),
                            listeners: {
                                beforeshow: function updateTipBody(tip) {
                                    var msg = view.getRecord(tip.triggerElement).get(validField);
                                    if(msg != null && msg != ''){
                                        tip.update( msg );
                                    }else{
                                        tip.update( view.getRecord(tip.triggerElement).get(key) );
                                    }
                                }
                            }
                        });
                    }
                },getRowClass: function(record) {
                    return getRecordCSS(record);
                }
            }
        });

        theComponent.add(theTable);
    }

    function getRecordCSS(record){
        var valid = record.get(rowValidField);

        if(valid != null && valid != ''){
            return 'gridrow-invalid';
        }else{
            return 'x-grid-cell';
        }
    }

    public function setRecordValid(record, msg : String){
        record.set(rowValidField,msg);
    }

    public function performPaste(content : String, grid : Dynamic){
        WorkspaceApplication.suspendUpdates();

        var columns :Dynamic = theTable.columns;
        var colCount = columns.length;

        var rowSep = '\n';

        if(content.indexOf('\r\n') > -1){
            rowSep = '\r\n';
        }

        var rows = content.split(rowSep);

        var colClicked = this.cellClicked[0];
        var rowClicked = this.cellClicked[1];

        var currentCol = colClicked;
        var currentRow = rowClicked;

        var store = getStore();
        var storeCount = store.count();

        for(row in rows){
            if(row == ''){
                break;
            }

            var cols = row.split('\t');
            var pasteColIndex = 0;

            var model :Dynamic;

            if(currentRow > store.count() - 1 ){
                model = Ext.create(theModel.getExtModelName(), { });
                store.insert(currentRow,model);
            }else{
                model = store.getAt(currentRow);
            }

            currentRow++;

            for(col in currentCol...colCount){
                var field = columns[col].dataIndex;
                if(field != rowValidField && field != internalIdField){
                    model.set(columns[col].dataIndex,cols[pasteColIndex++]);
                }else{
                    pasteColIndex++;
                }

                if(pasteColIndex > cols.length-1){
                    break;
                }
            }

            //model.commit();
            //model.setDirty(true);

            currentCol = colClicked;
        }
        autoAddNewRow();
        WorkspaceApplication.resumeUpdates(false);
    }

    public function queryLoad(){

    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().hideMiddleSouthPanel();

        if (isNaked()) {
            return;
        }

        var fileMenu = getApplication().getFileMenu();

        var exportMenu = getApplication().getExportMenu();

        exportMenu.add({
            text: 'Tab separated file',
            hidden : false,
            handler: function(){
                var entityStore = getStore();
                var entityCount :Int = entityStore.count() -1 ;

                var strBuf = new StringBuf();

                var fields = theModel.getFields();
                var priField = theModel.getPrimaryKey();

                for(field in fields){
                    strBuf.add(field+'\t');
                }

                strBuf.add('\n');

                for(i in 0...entityCount){
                    var entityModel : Dynamic = entityStore.getAt(i);

                    for(field in fields){
                        if(field != priField){
                            var value = entityModel.get(field);

                            if(value == null){
                                value = '';
                            }

                            strBuf.add(value+'\t');
                        }
                    }

                    strBuf.add('\n');
                }

                var wo : WorkspaceObject<Dynamic> = getActiveObject(WorkspaceObject);

                getApplication().saveTextFile(strBuf.toString(), wo.getName() + '.tsv');
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-save',
            text: 'Save',
            handler: function(){
               upsert();
            },
            tooltip: {dismissDelay: 10000, text: 'Save changes to the database'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text: 'Fetch All',
            handler: function(){
                fetchAll(function(){
                    getApplication().showMessage('Fetch successful','Fetch complete');
                });
            },
            tooltip: {dismissDelay: 10000, text: 'Retrieve information from database (enter IDs into first column)'}
        });
    }

    public function upsert(){
        getApplication().showMessage('Please wait','Please wait.....');

        var store = getStore();
        //var constructs = [];

        var priKey = theModel.getPrimaryKey();

        var fields = theModel.getFields();
        var clazz = theModel.getClass();

        var models = new Array<Dynamic>();
        store.each(function(record){
            if(!isRecordEmpty(record) && record.dirty){
                var model = record.getData();

                models.push(model);
            }

            return true;
        });

        getProvider().modelToReal(theModel, models, function(exception : String, models : Array<Dynamic>){
            if(exception != null){
                getApplication().showMessage('Unexpected exception', exception);
                return;
            }

            var priField = theModel.getPrimaryKey();

            var insertList = new Array<Dynamic>();
            var updateList = new Array<Dynamic>();

            for(model in models){
                var val = Reflect.field(model, priField);
                if(val == null || val == ''){
                    insertList.push(model);
                }else{
                    updateList.push(model);
                }
            }

            var evHandler = function(err : Dynamic){
                if(err != null){
                    if(Reflect.hasField(err, 'source')){
                        var buzValue = err.source;
                        var buzField = theModel.getFirstKey();

                        var store = getStore();

                        var c = store.count();

                        for(i in 0...c){
                            var model = store.getAt(i);
                            var modelBuzValue = model.get(buzField);

                            if(buzValue == modelBuzValue){
                                setRecordValid(model, err.message);

                                break;
                            }
                        }

                        getApplication().showMessage('Database error', err.message);

                        theTable.getView().refresh();
                    }else{
                        getApplication().showMessage('Data update exception',err);
                    }

                    //getApplication().showMessage('Data update exception',err.message);

                    /*getProvider().rollback(function(err){
                        if(err != null){
                            getApplication().showMessage(
                                'Rollback failed',
                                'Save operation has failed as has the rollback operation.\n'+
                                'Please restart the program!'
                            );
                        }
                    });*/


                }else{
                    getApplication().showMessage('Save successful','All records saved succesfully');

                    var c = store.count();

                    for(i in 0...c){
                        var model = store.getAt(i);

                        setRecordValid(model, null);
                    }

                    fetchAll(function(){
                        getApplication().showMessage('Save successful','All records saved succesfully');
                    });
                    
                    /*getProvider().commit(function(err){
                        if(err == null){
                            getApplication().showMessage('Save successful','All records saved succesfully');

                            var c = store.count();

                            for(i in 0...c){
                                var model = store.getAt(i);

                                setRecordValid(model, null);
                            }

                            fetchAll(function(){
                                getApplication().showMessage('Save successful','All records saved succesfully');
                            });
                        }else{
                            getProvider().rollback(function(err){
                                if(err == null){
                                    getApplication().showMessage(
                                        'Rollback failed',
                                        'Save operation has failed as has the rollback operation.\n'+
                                        'Please restart the program!'
                                    );
                                }
                            });
                        }
                    });*/
                }
            };

            if(insertList.length > 0){
                getProvider().insertObjects(insertList,function(err){
                    if(err == null && updateList.length > 0){
                        getProvider().updateObjects(updateList, evHandler);
                    }else{
                        evHandler(err);
                    }

                    insertOrDeletePerformed();
                });
            }else if(updateList.length > 0){
                getProvider().updateObjects(updateList, evHandler);
            }else{
                getApplication().showMessage('','No changes to save');
            }
        });
    }

    public function insertOrDeletePerformed(){

    }

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }

    override public function getComponent() : Dynamic {
        return theComponent;
    }

    public function autoAddNewRow(){
        var store = getStore();

        var storeLen = store.count();

        var addNewRow = true;

        if(storeLen > 0){
            var record = store.getAt(storeLen-1);

            addNewRow = !isRecordEmpty(record);
        }

        if(addNewRow){
            store.insert(storeLen,Ext.create(theModel.getExtModelName(), { }));
        }

        //WorkspaceApplication.resumeUpdates(true);

        //store.commitChanges();
    }

    public function isRecordEmpty(record : Dynamic){
        var rowOccupied = false;

        record.fields.forEach(function(field){
            if(field.name != null && field.name != '' && field.name != internalIdField){
                var value = record.get(field.name);
                if(value != null && value != ''){
                    var fieldDefault = theModel.getFieldDefault(field.name);
                    if(fieldDefault == null || fieldDefault != value){
                        rowOccupied = true;
                        return false;
                    }
                }
            }

            return true;
        });

        return !rowOccupied;
    }

    public function fetchAll(cb){
        getApplication().showMessage('Please wait','Please wait.....');

        var entityStore = getStore();
        var entityCount :Int = entityStore.count() -1;

        var entityMap = new Map<String,String>();

        for(i in 0...entityCount){
            var entityModel : Dynamic = entityStore.getAt(i);

            if(isRecordEmpty(entityModel)){
                continue;
            }

            var keyVal = theModel.getFirstKey();

            if(keyVal == null || keyVal == ''){
                continue;
            }

            var entityId = entityModel.get(keyVal);
            entityMap.set(entityId,'');
        }

        var entityList = new Array<String>();
        for(entityId in entityMap.keys()){
            entityList.push(entityId);
        }

        var batchFetch = new BatchFetch(function(obj, err){
            getApplication().showMessage('Batch fetch failure', err);
        });

        batchFetch.getByIds(entityList,theModel.getClass(),'MODELS',function(obj, err){
            if(err == null){
                var objs = batchFetch.getObject('MODELS');
                getApplication().getProvider().activate(objs, 2, function(err : String){
                    if(err != null){
                        getApplication().showMessage('Batch fetch failure', err);
                        return;
                    }
                    WorkspaceApplication.suspendUpdates();
                    for(i in 0...entityCount){
                        var entityModel : Dynamic = entityStore.getAt(i);

                        var entityId = entityModel.get(theModel.getFirstKey());

                        var cacheObject :Dynamic = getApplication().getProvider().getObjectFromCache(theModel.getClass(),theModel.getFirstKey(),entityId);
                        if(cacheObject != null){
                            for(field in theModel.getFields()){
                                if(field.indexOf('.') > -1){
                                    var parts = field.split('.');
                                    var valObj = cacheObject;
                                    for(part in parts){
                                        var val = Reflect.field(valObj,part);
                                        if(val == null){
                                            valObj = null;
                                            break;
                                        }else{
                                            valObj = val;
                                        }
                                    }
                                    entityModel.set(field, valObj);
                                }else{
                                    var val = Reflect.field(cacheObject,field);
                                    entityModel.set(field,val);
                                }
                            }

                            setRecordValid(entityModel,null);
                        }else{
                            setRecordValid(entityModel, entityId + ' not found in database');
                        }
                    }


                    entityStore.commitChanges();

                    WorkspaceApplication.resumeUpdates(true);

                    theTable.getView().refresh();

                    cb();
                });
            }else{
                getApplication().showMessage('',err);
            }
        });
        batchFetch.execute();
    }

    public function isNullOrEmpty(value : String){
        if(value == null){
            return true;
        }else if(StringTools.replace(Std.string(value),' ','') == ''){
            return true;
        }else{
            return false;
        }
    }

    public function loadObjects(objs : Array<Dynamic>){
        getApplication().getProvider().activate(objs, 2, function(err : String){
            if(err != null){
                getApplication().showMessage('Batch fetch failure', err);
                return;
            }

            //WorkspaceApplication.suspendUpdates();
            var entityStore = getStore();
            entityStore.suspendEvents();

            var firstKey = theModel.getFirstKey();
            var c = entityStore.count();

            if(c>0 && isRecordEmpty(entityStore.getAt(c-1))){
                c = c-1;
            }

            for(obj in objs){
                var val = Reflect.field(obj,firstKey);
                var model = entityStore.insert(c++,Ext.create(theModel.getExtModelName(), { }))[0];

                model.set(firstKey,val);

                //Reflect.setField(model, firstKey, val);
            }

            c = entityStore.count();
            for(i in 0...c){
                var entityModel : Dynamic = entityStore.getAt(i);

                var entityId = entityModel.get(theModel.getFirstKey());

                var cacheObject :Dynamic = getApplication().getProvider().getObjectFromCache(theModel.getClass(),theModel.getFirstKey(),entityId);
                if(cacheObject != null){
                    for(field in theModel.getFields()){
                        if(field.indexOf('.') > -1){
                            var parts = field.split('.');
                            var valObj = cacheObject;
                            for(part in parts){
                                var val = Reflect.field(valObj,part);
                                if(val == null){
                                    valObj = null;
                                    break;
                                }else{
                                    valObj = val;
                                }
                            }
                            entityModel.set(field, valObj);
                        }else{
                            var val = Reflect.field(cacheObject,field);
                            entityModel.set(field,val);
                        }
                    }
                }

                entityModel.commit();
            }
            autoAddNewRow();
            entityStore.resumeEvents();
            theTable.getView().refresh();
            //theTable.reconfigure(entityStore, tableColumns);
            //theTable.resumeLayouts(true);
            //WorkspaceApplication.resumeUpdates(true);
        });
    }

    public function loadModels(models : Array<Dynamic>){
        WorkspaceApplication.suspendUpdates();

        var entityStore = getStore();

        var priKey = theModel.getPrimaryKey();
        var fields = theModel.getFields();

        var i = 0;
        for(model in models){
            var newModel = entityStore.insert(i++,Ext.create(theModel.getExtModelName(), { }))[0];

            for(field in fields){
                if(field != priKey){
                    newModel.set(field,model.get(field));
                }
            }
        }

        autoAddNewRow();
        WorkspaceApplication.resumeUpdates(false);
    }

    public function getModels() : Array<Dynamic>{
        var store = getStore();

        var models = new Array<Dynamic>();

        var c = store.count();
        for(i in 0...c){
            var model : Dynamic = store.getAt(i);

            models.push(model);
        }

        return models;
    }

    public function getStore() : Dynamic{
        var store = Ext.data.StoreManager.lookup(storeId);

        return store;
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        loadedExisting = false;

        if(viewReady){
            loadExistingModels();
        }else{
            loadRequired = true;
        }
    }

    public function loadExistingModels(){
        var wo : WorkspaceObject<Dynamic> = getWorkspace().getObjectSafely(getActiveObjectId(), WorkspaceObject);

        if(wo != null){
            var data = wo.getObject();

            if(Std.is(data,TableHelperModelData)){
                var modelData = cast(data, TableHelperModelData);

                var modelsToCopy = modelData.getModelsToCopy();

                var models = modelData.getModels();

                var rawModels = modelData.getRawModels();

                if(modelsToCopy != null){
                    loadModels(modelsToCopy);

                    modelData.setModelsToCopy(null);

                    loadedExisting = true;
                }else if(models != null){
                    getStore().loadRecords(models);

                    loadedExisting = true;
                }else if(rawModels != null){
                    getStore().loadData(rawModels);

                    modelData.setRawModels(null);

                    loadedExisting = true;
                }else if(modelData.getObjects() != null){
                    loadObjects(modelData.getObjects());

                    loadedExisting = true;
                }
            }
        }

        loadRequired = false;
    }


    override public function closeWorkspaceObject(objectId : String ) : Void {
        var wo = getActiveObject(WorkspaceObject);

        if(wo != null){
            var data = wo.getObject();
            if(Std.is(data, TableHelperModelData)){
                var modelData = cast(data, TableHelperModelData);
                var models = getModels();

                modelData.setModels(models);
            }
        }

        super.closeWorkspaceObject(objectId);
    }

    static public function openViewer(name : String, objs : Array<Dynamic>, clazz : Class<Dynamic>){
        var data = new TableHelperData(objs);

        var program = new TableHelper(clazz);
        program.setTitle(name);

        var wo = new TableHelperWO(data, name);

        var wk = WorkspaceApplication.getApplication().getWorkspace();

        wk.registerObjectWith(wo, program);
    }

    override public function close(){
        if(theTable != null){
            theTable.view.tooltip.config.listeners.beforeshow = null;
            theTable.view.tooltip.events.beforeshow.listeners[0].fireFn = null;
            theTable.view.tooltip.events.beforeshow.listeners[0].fn = null;
            theTable.view.keyMap.fn = null;

            for(i in 0...theTable.view.keyMap.bindings.length){
                theTable.view.keyMap.bindings[i].fn = null;
            }

            //Ext.destroy(theTable.view.tooltip);
            theTable.config.listeners.beforecellmouseup = null;
            theTable.config.viewConfig.getRowClass = null;
            theTable.viewConfig.getRowClass = null;
            theTable.config.listeners.cellcontextmenu = null;
            theTable.config.listeners.cellclick = null;
            theTable.config.listeners.edit = null;
            theTable.view.config.getRowClass = null;
            theTable.view.config.listeners.beforeshow = null;
            theTable.view.config.listeners.viewready = null;
            theTable.view.getRowClass = null;
            theTable.view.initialConfig.getRowClass = null;
            theTable.view.initialConfig.listeners.beforeshow = null;
            theTable.view.initialConfig.listeners.viewready = null;
        }

        theComponent.config.listeners.render =  null;

        if(theComponent.config.items != null){
            for(i in 0...theComponent.config.items.length){
                theComponent.config.items[i].handler = null;
            }
        }


        if(theTable != null){
            theTable.viewConfig.getRowClass = null;


            theTable.clearListeners();
            theTable.getView().clearListeners();

            theTable.viewConfig.listeners = null;
        }

        //theComponent.remove(theTable);

        //theTable.parentBuildingBlock = null;
        //theTable = null;

        super.close();
    }
}

interface TableHelperModelData {
    public function setModelsToCopy(models : Array<Dynamic>) : Void;

    public function getModelsToCopy() : Array<Dynamic>;

    public function setModels(models : Array<Dynamic>) : Void;

    public function getModels() : Array<Dynamic>;


    public function setRawModels(models : Array<Dynamic>) : Void;
    public function setObjects(objs : Array<Dynamic>) : Void;


    public function getRawModels() : Array<Dynamic>;
    public function getObjects() : Array<Dynamic>;
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
