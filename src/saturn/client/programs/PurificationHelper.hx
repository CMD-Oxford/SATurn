/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.PurificationHelperTable;
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

class PurificationHelper extends BasicTableViewer {

    public function new(){
        super();
    }

    override public function initialiseDOMComponent(){
        super.initialiseDOMComponent();
    }

    override public function onFocus(){
        super.onFocus();

        getApplication().getToolBar().add({
            iconCls :'x-btn-calculate',
            text:'generate IDs',
            handler: function(){
                this.generateids();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-save',
            text:'Save',
            handler: function(){
                this.saveNew();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-save',
            text:'Start',
            handler: function(){
                startGUI();
            }
        });
    }

    public function startGUI(){
        getApplication().userValuePrompt(
            'Start',
            'Enter PrepX run name',
            function(runname : String){
                runStage0(runname);
            },
            function(){

            }
        );
    }

    public function runStage0(runname : String){
        var table = cast(getUpdatedTable(), PurificationHelperTable);

        table.runStage0(runname, function(err : Dynamic){
            if(err != null){
                getApplication().showMessage('Run failure', err);
            }else{
                getApplication().showMessage('Success','Run complete!!!');
                this.updateTable(table);
            }
        });
    }



    public function saveNew(){
        var table = cast(getUpdatedTable(), PurificationHelperTable);

        table.saveNew(function(err : String){
            if(err != null){
                getApplication().showMessage('Save failure', 'Save failure '  + err);
            }else{
                getApplication().showMessage('Saved', 'All records saved');
            }
        });
    }


    public function generateids(){
        var table = cast(getUpdatedTable(), PurificationHelperTable);

        table.generateids(function(err : Dynamic){
            if(err != null){
                getApplication().showMessage('ID generation failure', err);
            }else{
                this.updateTable(table);
            }
        });
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-structure',
                text: 'Purification Helper',
                cls: 'quickLaunchButton',
                handler: function(){
                    var table = new PurificationHelperTable();

                    WorkspaceApplication.getApplication().getWorkspace().addObject(table, true);
                }
            }
        ];
    }
}
