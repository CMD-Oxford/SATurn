/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.blocks.BaseTable;
import saturn.client.programs.SimpleExtJSProgram;

import saturn.core.Table;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import bindings.Ext;

class BasicTableViewer extends SimpleExtJSProgram{

    var theComponent : Dynamic;

    var table : BaseTable;

    var firstBuild = true;
    var hideTitle : Bool = false;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            flex:2,layout:'fit',
            listeners : {
                'render' : function() {
                    initialiseDOMComponent();
                }
            }
        });
    }

    override public function initialiseDOMComponent() {
        super.initialiseDOMComponent();

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

        table = new BaseTable(colDefs, data, 'Data', null, hideTitle);
        table.setEditListener(function(){});

    }

    public function getUpdatedTable() : Table{
        var data = getTable().getData();

        var table : Table = getObject();

        table.updateData(data);

        return table;
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().getToolBar().add({
            iconCls :'x-btn-export',
            text:'Export',
            handler: function(){
                table.exportToFile(getObject().getName());
            }
        });

        getApplication().getEditMenu().add({
            text : "Click me",
            handler : function(){
                getApplication().showMessage('Menu','You clicked me!');
            }
        });

        getApplication().hideMiddleSouthPanel();

        if(table != null && table.getComponent() != null){
            updateTable(getUpdatedTable());
        }
    }

    override public function onBlur(){
        super.onBlur();

        getUpdatedTable();
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var obj : Dynamic = super.getActiveObject(null);

        updateTable(obj);
    }

    public function updateTable(obj : Table){
        setTitle(obj.getName());

        table.setErrorColumns(obj.getErrorColumns());

        table.reconfigure(obj.tableDefinition);

        table.setFixedRowHeight(obj.getFixedRowHeight());

        if(firstBuild){
            firstBuild = false;

            getComponent().add(table.getComponent());
        }
    }

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }


    override public function getComponent() : Dynamic {
        return theComponent;
    }

    public function getTable() : BaseTable {
        return table;
    }

    override public function saveWait(cb : Dynamic) : Void{
        //Ensure that changes visible in the table are serialised when the current session is
        getUpdatedTable();

        cb();
    }
}
