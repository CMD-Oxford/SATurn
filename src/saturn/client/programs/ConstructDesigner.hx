/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.domain.SgcConstruct;
import saturn.client.programs.blocks.TargetSummary;
import saturn.core.Protein;
import saturn.core.ConstructDesignTable;
import saturn.core.ConstructDesignTable;
import saturn.core.Table;
import saturn.client.programs.blocks.BaseTable;
import saturn.client.programs.SimpleExtJSProgram;

import saturn.core.ConstructPlan;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import bindings.Ext;

class ConstructDesigner extends BasicTableViewer {

    public function new(){
        super();
    }

    override public function initialiseDOMComponent(){
        super.initialiseDOMComponent();

        table.addCustomContextItem({
            text : 'Show construct alignment',
            handler : function(rowIndex) {
                var model = table.store.getAt(rowIndex);
                var val : String = model.get('Entry Clone');

                if(val == null){
                    getApplication().showMessage('Missing entry clone ID', 'Please enter the entry clone ID first');
                    return;
                }

                var target = val.split('-')[0];

                showAlignment(target);
            }
        });
    }

    public function showAlignment(target : String){
        var objectId = getActiveObjectId();

        var parentFolder = getWorkspace().getParentFolder(objectId);

        var folder = parentFolder.findChild('text', target);
        if(folder != null){
            getWorkspace().removeItem(folder.getId());
        }

        folder = getWorkspace()._addFolder(target, parentFolder);

        var constructs = new Array<SgcConstruct>();

        var n : Int = Std.int(table.store.data.length-1);
        for(i in 0...n){
            var model :Dynamic = table.store.getAt(i);
            var constructId :String = model.get('Construct ID');

            if(constructId == null){
                if(model.get('Start') == null || model.get('Stop') == null || model.get('Entry Clone') == null){
                    continue;
                }

                constructId = model.get('Entry Clone') + '_' + model.get('Start') + '-' + model.get('Stop');
            }

            if(constructId.split('-')[0] == target){
                var seq = model.get('Construct Protein (no tag)');

                if(seq == null){
                    continue;
                }

                var protObj = new Protein(seq);
                protObj.setMoleculeName(constructId);

                var construct = new SgcConstruct();
                construct.constructId = constructId;
                construct.proteinSeqNoTag = seq;
                construct.status = 'No progress';

                constructs.push(construct);

                getWorkspace().addObject(protObj, false, folder);
            }
        }

        var sum = new TargetSummary(target);
        sum.setSequences(constructs);
        sum.setParentFolder(folder);
        sum.getTargetSequence();
    }

    override public function onFocus(){
        getApplication().getToolBar().add({
            iconCls :'x-btn-calculate',
            text:'Prepare',
            handler: function(){
                this.prepare();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-save',
            text:'Save',
            handler: function(){
                this.saveNew();
            }
        });

        /*getApplication().getToolBar().add({
            text:'Fetch All',
            handler: function(){
                this.fetchAll();
            }
        });*/

        getApplication().getToolsMenu().add({
            iconCls :'x-btn-calculate',
            text:'Calculate',
            handler: function(){
                this.calculate();
            }
        });

        getApplication().getToolsMenu().add({
            iconCls :'x-btn-calculate',
            text:'Generate IDs',
            handler: function(){
                this.generateids();
            }
        });

        getApplication().getToolsMenu().add({
            iconCls :'x-btn-calculate',
            text:'Assign Wells',
            handler: function(){
                this.assignWells();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Duplicate & Change Vector',
            handler: function(){
                this.duplicateAndChangeVector();
            }
        });

        super.onFocus();
    }

    public function calculate(){
        var table = cast(getUpdatedTable(), ConstructDesignTable);

        table.calculate(function(){
            this.updateTable(table);
        });
    }

    public function duplicateAndChangeVector(){
        var table = cast(getUpdatedTable(), ConstructDesignTable);

        getApplication().userValuePrompt('New Vector Name', 'Enter name of new vector', function(vectorName : String){
            table.duplicateAndChangeVector(vectorName, function(){
                this.updateTable(table);
            });
        }, function(){});
    }

    public function saveNew(){
        var table = cast(getUpdatedTable(), ConstructDesignTable);

        table.saveNew(function(err : String){
            if(err != null){
                getApplication().showMessage('Save failure', 'Save failure '  + err);
            }else{
                getApplication().showMessage('Saved', 'All records saved');
            }
        });
    }

    public function fetchAll(){
        var table = cast(getUpdatedTable(), ConstructDesignTable);

        table.fetchall(function(){
            this.updateTable(table);
        });
    }

    public function generateids(){
        var table = cast(getUpdatedTable(), ConstructDesignTable);

        table.generateids(function(err : Dynamic){
            if(err != null){
                getApplication().showMessage('ID generation failure', err);
            }else{
                this.updateTable(table);
            }
        });
    }

    public function assignWells(){
        var table = cast(getUpdatedTable(), ConstructDesignTable);

        table.assignWells(function(err : Dynamic){
            if(err != null){
                getApplication().showMessage('ID generation failure', err);
            }else{
                this.updateTable(table);
            }
        });
    }

    public function prepare(){
        var table = cast(getUpdatedTable(), ConstructDesignTable);

        table.prepare(function(err : Dynamic){
            if(err != null){
                getApplication().showMessage('Error preparing', err);
            }else{
                this.updateTable(table);
            }
        });
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-conical-dna',
                text: 'Construct Designer',
                cls: 'quickLaunchButton',
                menu: Ext.create('Ext.menu.Menu',{
                    items: {
                        text: 'BRD1A Example',
                        handler: function(){
                            var table = new ConstructDesignTable(true);

                            WorkspaceApplication.getApplication().getWorkspace().addObject(table, true);
                        }
                    }
                }),
                handler: function(){
                    var table = new ConstructDesignTable(false);

                    WorkspaceApplication.getApplication().getWorkspace().addObject(table, true);
                },
                listeners: {
                    mouseover: function(){
                       // untyped hideTask.cancel();
                        if(!js.Lib.nativeThis.hasVisibleMenu()){
                            js.Lib.nativeThis.showMenu();
                        }
                    }
                }
            }
        ];
    }
}
