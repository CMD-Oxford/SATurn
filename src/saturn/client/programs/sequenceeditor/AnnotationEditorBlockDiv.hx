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

import jQuery.JQuery;

class AnnotationEditorBlockDiv extends AnnotationEditorBlock{
	
    public function new(blockNumber : Int, sequenceEditor :SequenceEditor, annotationNumber : Int) {
		super(blockNumber, sequenceEditor,annotationNumber);
    }

    override private function createElement(){
        elem = js.Browser.document.createDivElement();
    }

    public function setHtml(str : String){
        elem.innerHTML = str;
    }
}
