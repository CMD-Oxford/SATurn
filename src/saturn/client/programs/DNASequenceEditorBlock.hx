/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

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

class DNASequenceEditorBlock extends SequenceEditorBlock {
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
                var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                    focusOnToFront : false,
                    items: [
                        {
                            text: 'Blast Selected',
                            handler: function(){ 
                                cast(sequenceEditor,DNASequenceEditor).blastSequence(sequenceRegion.getSequence(), 'Constructs (DNA)', blastName);
                            }
                        },
                        {
                            text : 'New From Selected',
                            handler : function(){
                                var w0 :DNAWorkspaceObject<DNA> = new DNAWorkspaceObject<DNA>(
                                                new DNA(sequenceRegion.getSequence()),
                                                baseName
                                );

                                sequenceEditor.getWorkspace().addObject(w0, true);
                            }
                        },
						{
                            text : 'Generate Forward Primer',
                            handler : function(){
                                var w0 : PrimerWorkspaceObject<Primer> = new PrimerWorkspaceObject<Primer>(
                                                new Primer(sequenceRegion.getSequence()),
                                                'Primer ' + baseName
                                );

                                sequenceEditor.getWorkspace().addObject(w0, true);
                            }
                        },
						{
                            text : 'Generate Reverse Primer',
                            handler : function(){
                                var w0 : PrimerWorkspaceObject<Primer> = new PrimerWorkspaceObject<Primer>(
                                                new Primer(new DNA(sequenceRegion.getSequence()).getInverseComplement()),
                                                'Primer ' + baseName
                                );

                                sequenceEditor.getWorkspace().addObject(w0, true);
                            }
                        },{
							text: 'Generate Primers',
							handler : function() {
								
							}
						}
                    ]
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
