/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.FastaEntity;
import saturn.core.EUtils;
import saturn.core.DNA;
import saturn.core.SHRNADesignTable;
import saturn.core.domain.SgcConstruct;
import saturn.client.programs.blocks.TargetSummary;
import saturn.core.Protein;
import saturn.core.Table;
import saturn.client.programs.blocks.BaseTable;
import saturn.client.programs.SimpleExtJSProgram;

import saturn.core.ConstructPlan;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import bindings.Ext;

class SHRNADesigner extends BasicTableViewer {
    var reg_ncbi =~/^\s*\w+_\d+\s*/;

    public function new(){
        super();
    }

    override public function initialiseDOMComponent(){
        hideTitle = true;

        super.initialiseDOMComponent();

        table.addCustomContextItem({
            text : 'Show construct alignment',
            handler : function(rowIndex) {

            }
        });

        registerDropFolder('Target Sequence', saturn.core.DNA, true);
    }

    override public function onFocus(){
        super.onFocus();

        getApplication().getToolBar().add({
            text:'Calculate',
            handler: function(){
                calculate();
            },
            iconCls: 'x-btn-calculate'
        });

        getApplication().enableProgramSearchField(true);
    }

    public function calculate(){
        var table = cast(getUpdatedTable(), SHRNADesignTable);

        var references : Array<String> = getReferences('Target Sequence');

        if(references != null && references.length >0){
            var dna :DNA = getWorkspace().getObject(references[0]);

            table.setSequence(dna.getSequence());

            table.calculateOligos(function(err : String){
                if(err == null){
                    updateTable(table);
                }else{
                    getApplication().showMessage('Calculation error', 'Please check all fields\n'+err);
                }
            });
        }else{
            getApplication().showMessage('Calculation error', 'Please set the target sequence first');
        }
    }

    override public function search(text : String) : Void{
        if(text == lastSearch || text == ''){
            return;
        }else{
            lastSearch = text;
        }

        var loadFunc = function(sequence : String, name : String){
            var targetSequences :Array<String> = getReferences('Target Sequence');

            if(targetSequences != null && targetSequences.length > 0){
                var obj = getWorkspace().getObject(targetSequences[0]);
                obj.setSequence(sequence);
                obj.setName(name);

                getWorkspace().renameWorkspaceObject(obj.getUUID(), name);
                var prog = getWorkspace().getProgramForObject(obj.getUUID());
                if(prog != null){
                    if(Std.is(prog, DNASequenceEditor)){
                        var dnaProg = cast(prog, DNASequenceEditor);
                        dnaProg.setSequence(sequence);
                        //dnaProg.setTitle(name);
                    }
                }
            }else{
                var dna : Dynamic = new DNA(sequence);
                dna.setName(name);

                getWorkspace().addObject(dna, false);

                registerReference(dna.getUUID(), 'Target Sequence');
            }
        }

        if(reg_ncbi.match(text)){
            EUtils.getDNAForAccessions([text], function(err : String, objs : Array<DNA>){
                if(err == null){
                    if(objs != null && objs.length > 0){
                        debug('Loading remote sequence');
                        loadFunc(objs[0].getSequence(), objs[0].getName());
                    }else{
                        getApplication().showMessage('Download failure', 'No sequences found');
                    }
                }else{
                    getApplication().showMessage('Download failure','Unable to download sequence for ' + text);
                }
            });
        }else{
            if(text.indexOf('>') > -1){
                var entities :Array<FastaEntity> = FastaEntity.parseFasta(text);
                if(entities == null || entities.length == 0){
                    getApplication().showMessage('Invalid FASTA', 'Invalid FASTA string');
                }else{
                    loadFunc(entities[0].getSequence(), entities[0].getName());
                }
            }else{
                loadFunc(text,'shRNA Template');
            }
        }


    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-shrna',
                text: 'shRNA Designer',
                cls: 'quickLaunchButton',
                menu: Ext.create('Ext.menu.Menu',{
                    items: {
                        text: 'OGG1 Example',
                        handler: function(){
                            var table = new SHRNADesignTable(false);

                            WorkspaceApplication.getApplication().getWorkspace().addObject(table, true);
                        }
                    }
                }),
                handler: function(){
                    var table = new SHRNADesignTable(true);

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
