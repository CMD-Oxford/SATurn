/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.sequenceeditor.AnnotationEditorBlock;

import saturn.client.WorkspaceApplication;
import saturn.client.programs.sequenceeditor.SequenceEditor;
import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.core.Protein;
import saturn.core.BlastDatabase;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.Workspace.WorkspaceObject;

import bindings.Ext;

class DNAAnnotationSequenceEditorBlock extends AnnotationEditorBlock {
    public function new(blockNumber : Int, sequenceEditor :SequenceEditor, annotationNumber : Int) {
        super(blockNumber, sequenceEditor, annotationNumber);
    }

    override private function initialise(blockNumber : Int) {
        super.initialise(blockNumber);

		var contextMenu = function(event : Dynamic){     
            var sequenceRegion = sequenceEditor.getSelectedRegion();
            if(sequenceRegion != null){
                var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
					focusOnToFront : false,
                    items: [
                        {
                            text: 'Blast Selected',
                            handler: function(){ 
                                var sequence : String = sequenceRegion.getAnnotationSequence();

                                var blastName = 'Blastp '+sequenceEditor.getActiveObject(WorkspaceObject).getName()+' '+sequenceRegion.getAnnotationStartPosition()+' - '+sequenceRegion.getAnnotationStopPosition();

                                sequence = StringTools.replace(sequence, " ","");
                                cast(sequenceEditor,DNASequenceEditor).blastSequence(sequence, 'Constructs (Protein)', blastName);
                            }
                        },
						{
                            text: 'New Protein From Selected',
                            handler: function(){ 
                                var sequence : String = sequenceRegion.getAnnotationSequence();

                                var proteinName = 'Protein '+sequenceEditor.getActiveObject(WorkspaceObject).getName()+' '+sequenceRegion.getAnnotationStartPosition()+' - '+sequenceRegion.getAnnotationStopPosition();

                                sequence = StringTools.replace(sequence, " ","");
                                
								var wO : ProteinWorkspaceObject = new ProteinWorkspaceObject(new Protein(sequence), proteinName);
								
								WorkspaceApplication.getApplication().getWorkspace().addObject(wO, true);
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
		var previousOnMouseUp = elem.onmouseup;
		
		elem.onmouseup = function(event : Dynamic) {
			if (event.ctrlKey) {
				contextMenu(event);
			}else {
				previousOnMouseUp;
			}
		}
		
        elem.oncontextmenu = contextMenu;
    }
}
