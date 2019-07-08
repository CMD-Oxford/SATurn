/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.sequenceeditor;

import saturn.client.programs.sequenceeditor.SequenceEditor;
import saturn.client.workspace.Workspace.WorkspaceObject;

class AnnotationEditorBlock {
	private var elem : Dynamic;
	private var sequenceEditor : SequenceEditor;
    private var annotationNumber : Int;
    private var bNum : Int;
	
    public function new(blockNumber : Int, sequenceEditor :SequenceEditor, annotationNumber : Int) {
		this.sequenceEditor = sequenceEditor;
        this.annotationNumber = annotationNumber;
        initialise(blockNumber);
    }
	
	public function getElement() : Dynamic {
		return elem;
	}
	
	public function getSequenceEditor() : SequenceEditor {
		return sequenceEditor;
	}

    private function createElement(){
        elem = js.Browser.document.createPreElement();
    }

    private function installListeners(){
        var me = this;

        elem.onblur = function(){
            me.getSequenceEditor().onBlockBlur(elem);
        };

        elem.onmousedown = function(event) {
            if(event.button > 1){
                return;
            }
            me.getSequenceEditor().makeAnnotationSelectable(me.annotationNumber);
        };

        elem.onmouseup = function() {

        };

        elem.onmousemove = function() {

        };
    }

    public function destroy(){
        sequenceEditor = null;
        elem.onblur = null;
        elem.onmousedown = null;
        elem.onmouseup = null;
        elem.onmousemove = null;
    }
    
    private function initialise(blockNumber : Int) {
        createElement();

        installListeners();

        elem.blockNumber = blockNumber;
        bNum = blockNumber;

        elem.classList.add("molbio-sequenceeditor-block");

        elem.style.dysplay = "inline-block";

        getSequenceEditor().autoSetBlockWidth(elem);

        makeSelectable(false);
    }

    public function makeSelectable(makeSelectable : Bool) {
        SequenceEditor.makeSelectable(this.getElement(),makeSelectable);
    }

    public function setString(str : String){
        elem.innerText = str;
    }

    public function getBlockNumber() : Int {
        return bNum;
    }
}
