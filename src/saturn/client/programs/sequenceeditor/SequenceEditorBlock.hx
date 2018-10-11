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
import saturn.client.WorkspaceApplication;
import bindings.Ext;
import saturn.client.workspace.Workspace.WorkspaceObject;

class SequenceEditorBlock {
	private var divElem : Dynamic;
	private var sequenceEditor : SequenceEditor;
    private var blockNumber : Int;
	
    public function new(blockNumber : Int, sequenceEditor :SequenceEditor) {
		this.sequenceEditor = sequenceEditor;
        this.blockNumber = blockNumber;
        initialise(blockNumber);
    }
	
	public function getElement() : Dynamic {
		return divElem;
	}
	
	public function getSequenceEditor() : SequenceEditor {
		return sequenceEditor;
	}

    public function destroy(){
        divElem.onmouseup = null;
        divElem.oncontextmenu = null;

        sequenceEditor = null;
    }

    
    private function initialise(blockNumber : Int) {
		var self = this;
		
        divElem = js.Browser.document.createElement('pre');
                
        divElem.onblur = function(){ 
            self.getSequenceEditor().onBlockBlur(divElem); 
        };
                
        divElem.onmousedown = function(event) {
            if(event.button > 1){
                return;
            }

            self.getSequenceEditor().makeAnnotationSelectable(-1);

			self.getSequenceEditor().mouseDown = true;
            self.getSequenceEditor().selectionUpdated();
        };
                    
        divElem.onmouseup = function(event) {
			self.getSequenceEditor().mouseDown = false;
                        
			var dWindow : Dynamic = js.Browser.window;

            var selectedRegion : SequenceRegion = getSequenceEditor().getSelectedRegion();

			var isClick : Bool = selectedRegion == null 
                                    || selectedRegion.getSequence() == null 
                                        || selectedRegion.getStartPosition() == selectedRegion.getStopPosition() ? true : false;

			if(isClick==true){
				onBlockClick();
			}
        };
                    
        divElem.onmousemove = function() {
            var seqEditor : SequenceEditor = self.getSequenceEditor();
            var app : WorkspaceApplication = WorkspaceApplication.getApplication();
        
            if(seqEditor.mouseDown==true){
                if(seqEditor.inputFocused != null){
                    var sequenceRegion : SequenceRegion = seqEditor.getSelectedRegion();

                    var displayBlock : Dynamic = seqEditor.inputFocused.nextSibling;

                    var inputBlockNumber : Int = displayBlock.blockNumber;

                    var offSet : Int = ( ( inputBlockNumber - 1 ) * seqEditor.blockSize );

                    var startPos : Int = sequenceRegion.getStartPosition() - offSet;
                    var stopPos : Int = sequenceRegion.getStopPosition() - offSet;

                    seqEditor.onBlockBlur(displayBlock);

                    var sel : Dynamic = js.Browser.window.getSelection();

                    sel.removeAllRanges();

                    var range : Dynamic = js.Browser.document.createRange();
                    var sel : Dynamic = js.Browser.window.getSelection();

                    /*
                        We cheat here to detect the selection direction from 
                        the user as we don't want to track the mouse x,y.

                        If the blockNumber associated with the INPUT element
                        is less than the blockNumber associated with the block
                        element that picked up this mouse move event then we
                        must be selecting down the sequence.  Otherwise we
                        are selecting back up the sequence.
                    */
                    if(blockNumber > inputBlockNumber){
                        range.setStart(displayBlock.firstChild, startPos); 
                        range.setEnd(displayBlock.firstChild, stopPos);

                        sel.addRange(range);
                    }else{
                        range.setStart(displayBlock.firstChild, stopPos); 

                        sel.addRange(range);
                        sel.extend(displayBlock.firstChild, startPos +1);
                    }
                }

                seqEditor.inMouseMove = true;
                seqEditor.selectionUpdated();
            }
        };
		
        divElem.className = divElem.className + " molbio-sequenceeditor-block";
        divElem.blockNumber=blockNumber;                
        divElem.style.dysplay="inline-block";    
    
        getSequenceEditor().autoSetBlockWidth(divElem);
    } 

    public function onBlockClick(){
        if(divElem.isInput==true){

        }else if(divElem.tagName == 'INPUT'){
            // We, get here when the blocked clicked was the surrogate INPUT element
        }else{
            if(sequenceEditor.isFindAnnotationOn()){
                sequenceEditor.redrawSequenceOnly();
            }

            var spanTextNode = divElem.lastChild;
            
            var offSetPos=divElem.offSetPos;
            
            if(offSetPos==null){
                var sel = js.Browser.window.getSelection();
   
                var selPos=1;
                if(sel.focusNode==spanTextNode){
                    selPos=sel.focusOffset;
                }
                
                offSetPos=selPos;
            }else{
                divElem.offSetPos=null;
            }
   
            var inputElem : js.html.InputElement = js.Browser.document.createInputElement();
            inputElem.className="molbio-sequenceeditor-block-input molbio-selectable";
            inputElem.value=divElem.textContent;

            sequenceEditor.autoSetBlockWidth(inputElem);

            divElem.isInput=true;
            divElem.innerText="";
            divElem.innerHTML="";
            divElem.style.width = "0em";

            if(divElem.parentNode.insertBefore){
                // We, get here on Firefox
                divElem.parentNode.insertBefore(inputElem, divElem);
            }else{
                // We, get here on Chrome/Blink
                divElem.insertAdjacentElement('beforeBegin', inputElem);
            }

            divElem.className = 'molbio-sequenceeditor-block-hidden';

            inputElem.focus();
            inputElem.setSelectionRange(offSetPos,offSetPos);

            var inputElemD :Dynamic = inputElem;

            /*
                Cursor block jumping doesn't work if blockNumber isn't set as an
                attribute of the INPUT element.  I haven't been able to find the 
                code that is pulling this number as code shouldn't be using this.
            */
            inputElemD.blockNumber = blockNumber; 

            var cursorPosition : Int = ( ( blockNumber-1 ) * sequenceEditor.blockSize ) + offSetPos;
            
            getSequenceEditor().setCursorPosition(new SequenceRegion(cursorPosition, cursorPosition, - 1));
                            
            var self : SequenceEditorBlock = this;

            inputElem.addEventListener('blur',  function(e : js.html.Event){
                /*
                    We, get here when the current INPUT element looses focus.

                    onBlockBlur will uninstall the inputElem ensuring that only
                    one INPUT element is ever present for the SequenceEditor.

                    When the cursor equals the SequenceEditor block size 
                    SequenceEditor.blockChanged will programmatically click the
                    next block which cause the focus to shift from this INPUT element
                    to a new one that is installed by onBlockClicked.  This obviously
                    causes the current INPUT element's onblur to fire which uninstalls
                    this INPUT element.
                */
                self.sequenceEditor.onBlockBlur(inputElem.nextSibling);
            });

            inputElem.addEventListener('input', function(event : Dynamic){
                event.cancelBubble = true;

                event.stopPropagation();

                self.sequenceEditor.blockChanged(inputElem, self.blockNumber, null, null, null);
            });

            /*
                New
            */
            inputElem.addEventListener('mousedown',  function(e : js.html.Event){
                self.sequenceEditor.makeAnnotationSelectable(-1);

	    		self.sequenceEditor.mouseDown = true;
            });

            inputElem.addEventListener('mouseup', function(e : js.html.Event){ 
                self.onBlockClick(); 

  	    		self.sequenceEditor.mouseDown = false; //NEW
            });
                            
            inputElem.onkeyup = function(event : Dynamic){   
                if (!(event.keyCode == 46 || event.keyCode == 8)) {
                    event.cancelBubble = true;
                    if(event.stopPropagation){
                        event.stopPropagation();
                    }

                    var blockNumber : Int = inputElemD.blockNumber;
                               
                    self.sequenceEditor.blockChanged(inputElem, self.blockNumber, null, null, null);
    
                    self.sequenceEditor.mouseDown=false;

                    getSequenceEditor().getApplication().onkeyup(event);
                }
            };

            inputElem.onkeydown = function(event : Dynamic){
                getSequenceEditor().getApplication().onkeydown(event);
            }

            sequenceEditor.inputFocused = inputElem;
        }
    }
}
