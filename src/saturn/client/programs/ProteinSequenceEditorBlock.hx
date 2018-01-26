/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.ConstructDesignTable;
import saturn.core.Protein;
import js.html.Event;
import saturn.client.programs.sequenceeditor.SequenceEditorBlock;
import saturn.client.programs.sequenceeditor.SequenceEditor;

import saturn.core.BlastDatabase;

import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.PrimerWorkspaceObject;
import saturn.core.DNA;
import saturn.core.Primer;
import saturn.client.workspace.Workspace.WorkspaceObject;


import bindings.Ext;

class ProteinSequenceEditorBlock extends SequenceEditorBlock {
    public function new(blockNumber : Int, sequenceEditor :SequenceEditor) {
        super(blockNumber, sequenceEditor);
    }

    override private function initialise(blockNumber : Int) {
        super.initialise(blockNumber);

		var contextMenu = function(event : Dynamic){     
            var sequenceRegion = sequenceEditor.getSelectedRegion();
            if(sequenceRegion != null){
                var baseName = sequenceEditor.getActiveObject(WorkspaceObject).getName()+' '+(sequenceRegion.getStartPosition()+1)+'-'+sequenceRegion.getStopPosition();
                var blastName = 'Blastn '+baseName;


                var protEditor = cast(sequenceEditor, ProteinSequenceEditor);

                var addPlateMenu = protEditor.getAddToPlateContextMenu(null,sequenceRegion.getStartPosition()+1,sequenceRegion.getStopPosition());

                /*
                var objs :Array<Dynamic>= getSequenceEditor().getWorkspace().getAllObjects(ConstructDesignTable);
                for(obj in objs){
                    addPlateMenu.add({
                        text: obj.getName(),
                        handler: function(){
                            var objectId = obj.getUUID();

                            var prog = sequenceEditor.getWorkspace().getProgramForObject(objectId);

                            if(prog != null){
                                var constructDesigner = cast(prog, ConstructDesigner);
                                var obj :Dynamic = sequenceEditor.getWorkspaceObject();
                                if(obj.isChild()){
                                    obj = obj.getParent();
                                }

                                constructDesigner.getTable().addRow({
                                    'Entry Clone': obj.getName(),
                                    'Start position': sequenceRegion.getStartPosition()+1,
                                    'Stop position': sequenceRegion.getStopPosition()
                                });

                                sequenceEditor.getWorkspace().setActiveObject(objectId);
                            }
                        }
                    });
                }

                addPlateMenu.add({
                    text: 'New plate',
                    handler: function(){
                        var obj :Dynamic = sequenceEditor.getWorkspaceObject();

                        if(obj.isChild()){
                            obj = obj.getParent();
                        }

                        var table = new ConstructDesignTable();
                        table.getData().push({
                            'Entry Clone': obj.getName(),
                            'Start position': sequenceRegion.getStartPosition()+1,
                            'Stop position': sequenceRegion.getStopPosition()
                        });

                        sequenceEditor.getWorkspace().addObject(table, true);
                    }
                });*/

                var items : Array<Dynamic> =  [
                    {
                        text: 'Blast Selected',
                        handler: function(){
                            cast(sequenceEditor,ProteinSequenceEditor).blastSequence(sequenceRegion.getSequence(), 'UniProt (Swiss-Prot)', blastName);
                        }
                    },
                    {
                        text : 'New From Selected',
                        handler : function(){
                            var prot = new Protein(sequenceRegion.getSequence());
                            prot.setMoleculeName(baseName);

                            sequenceEditor.getWorkspace().addObject(prot, true);
                        }
                    },
                    {
                        text: 'Add to plate',
                        menu: addPlateMenu
                    }
                ];

                var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                    focusOnToFront : false,
                    items:items
                });
                contextMenu.showAt(event.clientX, event.clientY);  

                event.preventDefault();
            }

            return true;   
        };
		
		/**
		 * Support platforms that override right-click
		 */
		var previousOnMouseUp = divElem.onmouseup;
		
		divElem.onmouseup = function(event : Dynamic) {
			if (event.ctrlKey) {
				contextMenu(event);
			}else {
				previousOnMouseUp(event);
			}
		}
		
        divElem.oncontextmenu =  contextMenu;
    }

    override public function destroy(){
        divElem.onmouseup = null;
        divElem.oncontextmenu = null;

        sequenceEditor = null;
    }
}
