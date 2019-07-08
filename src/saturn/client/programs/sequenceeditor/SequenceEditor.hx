/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.sequenceeditor;

import saturn.core.MSA;
import saturn.client.workspace.GridVarWO;
import saturn.core.GridVar;
import saturn.core.domain.SgcRestrictionSite;
import saturn.core.Util;
import saturn.core.FastaEntity;
import saturn.core.molecule.Molecule;
import js.Browser;
import bindings.Ext.Element;
import bindings.Ext;

import saturn.client.programs.Sequence;
import saturn.client.WorkspaceApplication;
import saturn.client.BuildingBlock;
import saturn.client.ProgramRegistry;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.programs.plugins.AlignmentGVPlugin;

class SequenceEditor extends SimpleExtJSProgram{
    var theComponent : Dynamic; // The EXTJS representation of this component

    var sequence : String; // Current sequence
    
    var blockFields : Array<Dynamic>; // Blocks that are used to display the sequence


    var annotationSequences : Array<String>; // Array of annotation strings
    var annotationFields : Array<Array<AnnotationEditorBlock>>; // Blocks that are used to display the annotations
    var annotationRowCount : Int; // Number of annotations
    var annotationsOn : Array<Bool>; // Array to indicate which annotation lines should be shown
    var annotationPositions : Array<AnnotationPosition>;
    var annotationRowLabels : Array<Array<js.html.SpanElement>>;
    var hideAnnotationsItem : Dynamic;
    var showAnnotationsItem : Dynamic;
    var annotationLabels : Array<String>;
    var annotationToRow : Map<String,Int>;
    var annotationToClass : Array<Class<AnnotationEditorBlock>>;

    var defaultAnnotationBlockClass : Class<AnnotationEditorBlock>;

    var sequenceChangeListeners : Array<SequenceChangeListener>; // List of listeners to be notified when the sequence is changed
	
    var columnCount : Int; // Number of blocks/columns to display on a row
    public var blockSize : Int; // Number of characters to display in a block

    var selectableRow : Int; // The annotation or sequence which can be highlighted, -1 = sequence, -2 = none

    public var inputFocused : Dynamic;
    
    // Menus
    var viewAnnotations : Dynamic;
    var showAnnotationItems : Array<Dynamic>;
    var hideAnnotationItems : Array<Dynamic>;
    var liveUpdateOn : Bool;

    var offSet : Int;

    var lastSelected : SequenceRegion;

    var editorCharWidth : Float;
    var editorCharHeight : Float;

    static var reg_newLine  = ~/\n/g;
    static var reg_carReturn = ~/\r/g;
    static var reg_whiteSpace = ~/\s/g;
    static var reg_star = ~/\*/g;
    static var reg_num = ~/[0-9]/g;

    var menuState : Map<String, Bool>;

    var findAnnotationOn = false;

    var viewFastaMenuItem : Dynamic;
    var viewEditorMenuItem : Dynamic;
    var fastaViewer : Dynamic;

    var theTable : Dynamic;

    var fastaButton : Dynamic;
    var editorButton : Dynamic;

    public function new(){
        super();
    }

    public function isFindAnnotationOn() : Bool{
        return findAnnotationOn;
    }

    public function liveUpdateEnabled(){
        return liveUpdateOn;
    }

    private function determineEditorCharacterDimensions(){
        var s = js.Browser.document.createPreElement();
        s.className = 'molbio-sequenceeditor-block';
        s.textContent = 'GGGGGGGGGGGG';
        s.setAttribute('style', 'border:0px;margin:0px;position: absolute; top: -100px;');

        js.Browser.document.body.appendChild(s);

        editorCharWidth = s.offsetWidth/12;
        editorCharHeight = s.offsetHeight;

        //js.Browser.document.body.removeChild(s);
        var d : Dynamic = js.Browser.document;
        d.spanHelp=s;
    }

    public function getDefaultCharWidth(){
        return editorCharWidth;
    }
	
	override public function emptyInit() {
		super.emptyInit();

        determineEditorCharacterDimensions();

        if(defaultAnnotationBlockClass == null){
            defaultAnnotationBlockClass = AnnotationEditorBlock;
        }

        liveUpdateOn = true;

        menuState = new Map<String, Bool>();

        offSet = 0;

        selectableRow = -2; // Set initial annotation or sequence selection to none

		columnCount = 5; // Set initial row column/block size to 6
        blockSize = 20; // Set character limit of column/block to 20

        annotationRowCount = 0; // Set annotation count to 0

        // Initialse contains
        annotationToRow = new Map<String,Int>();
        blockFields = new Array<Dynamic>();
        annotationFields = new Array<Array<AnnotationEditorBlock>>();
		annotationsOn = new Array<Bool>();
        annotationPositions = new Array<AnnotationPosition>();
		annotationSequences = new Array<String>();
        annotationLabels = new Array<String>();
        annotationRowLabels = new Array<Array<js.html.SpanElement>>();
        annotationToClass = new Array<Class<AnnotationEditorBlock>>();

  		sequenceChangeListeners = new Array<SequenceChangeListener>();

        // Menus
        showAnnotationItems = new Array<Dynamic>();
        hideAnnotationItems = new Array<Dynamic>();

        theComponent = Ext.create('Ext.Panel', {
            width: '100%',
            height: '100%',
           // autoScroll : false,
            //autoEl: { tag: 'div', html: ""	},
            title: 'DNA Editor',
            layout: 'vbox',
            region:'center'
        });

        // Define the component that will be given to EXTJS to render this component

        if(!Ext.ClassManager.isCreated('sequence.table')){
            Ext.define('sequence.table',{
                title : 'DNA Editor',
                extend: 'Ext.Component',
                autoEl: {tag:'div'},
                width:'100%',
                height: '100%',
                autoScroll : true,
                flex:2
            } );
        }

        if(!Ext.ClassManager.isCreated('sequence.fasta')){
            Ext.define('sequence.fasta',{
                title : 'DNA Editor',
                extend: 'Ext.Component',
                autoEl: {tag:'div'},
                width:'100%',
                height: '100%',
                autoScroll : true,
                style: {
                    margin: '2px'
                },flex:2
            } );
        }

        setAnnotationCount(0);

        theTable = Ext.create('sequence.table', {
            listeners : { 
                'render' : Ext.bind( function() { initialiseDOMComponent(); }, this) 
            }
        });

        fastaViewer = Ext.create('sequence.fasta', { });

        theTable.parentBuildingBlock=this; // Create back-reference to this instance
        theTable.addCls('molbio-sequenceeditor-table');

        theComponent.add(theTable);
        //theComponent.add(fastaViewer);
        
        // Set initial mouse state
        inMouseMove = false;
        mouseDown = false;

        getApplication().getMiddleSouthPanel().addCls('seq-breaking');
	}

    public function getDomElement() : js.html.Element{
        return theTable.getEl().dom;
    }

    public function setDefaultAnnotationEditorBlockClass(
        annotationEditorClass : Class<AnnotationEditorBlock>){
        this.defaultAnnotationBlockClass = annotationEditorClass;
    }

    public function getDefaultAnnotationEditorBlockClass(){
        return this.defaultAnnotationBlockClass;
    }

    override function close(){
        super.close();

        deleteBlockRows(0);

        theTable.parentBuildingBlock = null;
        theComponent.parentBuildingBlock = null;

        getApplication().getMiddleSouthPanel().removeCls('seq-breaking');

        js.Browser.window.onkeyup = null;
        js.Browser.window.onkeydown = null;

        theTable = null;
        theComponent = null;
    }
	
    public function setAnnotationLabel( annotationNumber : Int, annotationLabel : String){
        annotationLabels[annotationNumber] = annotationLabel;
        annotationToRow[annotationLabel] = annotationNumber;
    }

    public function getAnnotationLabel( annotationNumber ){
        return annotationLabels[annotationNumber];
    }

    public function getAnnotationClass( annotationNumber ){
        return annotationToClass[annotationNumber];
    }

    /*
        Method set the number of annotations rows
    */   
	public function setAnnotationCount(annotationCount : Int) {
		if(annotationCount > this.annotationRowCount){
			for (i in this.annotationRowCount...annotationCount) {
				annotationsOn.push(false);
				annotationFields.push([]);
				annotationSequences.push("");
                annotationPositions.push(AnnotationPosition.BOTTOM);
                annotationLabels.push("Annotation: "+i);
                annotationToClass.push(this
                .getDefaultAnnotationEditorBlockClass());

                if(viewAnnotations != null){
                    addAnnotationMenuItem(i);
                }

                annotationRowLabels.push(new Array<js.html.SpanElement>());
			}
		}else {
			for (i in annotationCount...this.annotationRowCount) {
				annotationsOn.pop();
				annotationFields.pop();
				annotationSequences.pop();
                annotationPositions.pop();
                annotationLabels.pop();

                showAnnotationItems.pop();
                hideAnnotationItems.pop();

                annotationRowLabels.pop();
                annotationToClass.pop();
			}
		}
		
		this.annotationRowCount = annotationCount;
	}

    public function addAnnotation(annotationName : String){
        var annotationRowNo = getAnnotationRowCount();

        setAnnotationLabel(annotationRowNo,annotationName);
        setAnnotationCount(annotationRowNo+1);

        return annotationRowNo;
    }

    public function getAnnotationRowCount() : Int {
        return this.annotationRowCount;
    }

    private function addAnnotationMenuItems(){
        for(i in 0...annotationFields.length){
            addAnnotationMenuItem(i);
        }
    }

    private function addAnnotationMenuItem(annotationNumber : Int){
        var self : SequenceEditor = this;

        var showLabel = 'Show '+annotationLabels[annotationNumber];
        var hideLabel = 'Hide '+annotationLabels[annotationNumber];

        var showItem :Dynamic = null;
        var hideItem :Dynamic = null;

        showItem = viewAnnotations.add({
            text : showLabel,
            handler : function(){
                deleteBlockRows(0);
                self.setAnnotationOn(annotationNumber, true);
                redraw();

                hideItem.show();
                showItem.hide();

                if(allAnnotationsVisible()){
                    self.showAnnotationsItem.hide();

                    menuState.set('showAnnotationsItem', false);
                }

                menuState.set(hideLabel, true);
                menuState.set(showLabel, false);

                self.hideAnnotationsItem.show();

                menuState.set('hideAnnotationsItem', true);
            }
        });

        showAnnotationItems.push(showItem);

        if(menuState.exists(showLabel)){
            if(menuState.get(showLabel)){
                showItem.show();
            }else{
                showItem.hide();
            }
        }

        hideItem = viewAnnotations.add({
            text : hideLabel,
            hidden : true,
            handler : function(){
                deleteBlockRows(0);
                self.setAnnotationOn(annotationNumber, false);

                redraw();

                hideItem.hide();
                showItem.show();

                if(! hasAnnotationsVisible() ){
                    self.hideAnnotationsItem.hide();

                    menuState.set('hideAnnotationsItem', false);
                }

                menuState.set(hideLabel, false);
                menuState.set(showLabel, true);

                self.showAnnotationsItem.show();

                menuState.set('showAnnotationsItem', true);
            }
        });

        hideAnnotationItems.push(hideItem);

        if(menuState.exists(hideLabel)){
            if(menuState.get(hideLabel)){
                hideItem.show();
            }else{
                hideItem.hide();
            }
        }


    }

    private function hasAnnotationsVisible() : Bool {
        for(i in 0...annotationsOn.length){
            if(annotationsOn[i] == true){
                return true;
            }
        }

        return false;
    }

    private function allAnnotationsVisible(): Bool {
        for(i in 0...annotationsOn.length){
            if(annotationsOn[i] == false){
                return false;
            }
        }

        return true;
    }
	
	override public function setActiveObject(objectId : String) {
		super.setActiveObject(objectId);

        setTitle(super.getActiveObject(WorkspaceObject).getName());
	}	

    override public function setTitle(title : String){
        getApplication().setProgramTabTitle(this, title);
    }
	
    /*
        Method should be called once the main EXTJS component has been created.

        In SequenceEditor.emptyInit() you will see that this method is called by the
        EXTJS "render" listener.
    */
	override public function initialiseDOMComponent() {
		super.initialiseDOMComponent();
		
		addSequenceRows(1);

        this.makeAnnotationSelectable(-1);
                                
        this.mouseDown = false;
		
		//initialiseDragAndDrop();

        installFastaViewer();
	}

    public function installFastaViewer(){
        /*var parentNode = theComponent.el.dom.parentElement;

        fastaViewer = js.Browser.document.createElement('div');

        fastaViewer.style.width = '100%';
        fastaViewer.style.height = '100%';

        parentNode.appendChild(fastaViewer);*/
    }
	
	override public function installWindowListeners(window : Dynamic) : Void {        
		var self : SequenceEditor = this;
		
        /*
            Install KEYUP listener for the whole application.

            The problem we have is that a user might select part of the sequence
            being displayed by left-clicking and dragging bejound the bounds of 
            the elements that hold the sequence blocks.  If the user then presses 
            the DELETE or BACKSPACE key they would expect the sequence selected 
            to be deleted regardless of the fact that the keyup event isn't fired 
            against one of our SequenceEditor block elements.

            So we install a KEYUP listener on the Window and look for DELETE and
            BACKSPACE events.
                - We ignore all DELETE/BACKSAPCE events that come from INPUT 
                  elements as they are handled by a KEYUP/ONINPUT we install
                  directly on the INPUT elements.
                - We then use the SequenceEditor.getSelectedRegion() to
                  work out if any sequence has been highlighted.
        */

        window.onkeyup=function(event : Dynamic ){
            if (event.keyCode == 46 || event.keyCode == 8) {
                if(js.Browser.document.activeElement.tagName == 'INPUT'){
                    return ;
                }

                self.onSequenceDeleteRequest(event);
            }else{
                getApplication().onkeyup(event);
            }
        };

        /*
            Custom copy action

            Selecting part of the sequence will highlight only the sequence and
            not the row labels and extra white-space.  However when you press
            Ctrl+C the row labels and extra white-space will also be copied to
            the clipboard.

            The following window listener will listener for Ctrl down key events
            and shift the focus to the information panel which is automatically
            populated with the highlighted sequence without any extra characters.

            At this point if the user continues to hold-down Ctrl and press C the
            sequence in the information panel will be copied.

            For some reason this doesn't work in Scarab :(

            All Ctrl activated right-click menus need to be rebound to Alt to
            not conflict with this change.
         */

        window.onkeydown=function(event : Dynamic){
            if(event.altKey){
                var southPanel = getApplication().getMiddleSouthPanel();

                var node :js.html.Element = southPanel.getEl().dom.childNodes[1];

                if(node.innerText != ''){
                    var d : Dynamic = js.Browser.document;

                    if ( d.selection ) {
                        var range = d.body.createTextRange();
                        range.moveToElementText( node  );
                        range.select();
                    } else if ( untyped __js__('window.getSelection') ) {
                        var range = js.Browser.document.createRange();
                        range.selectNode( node );


                        js.Browser.window.getSelection().removeAllRanges();
                        js.Browser.window.getSelection().addRange( range );
                    }
                }
            }else{
                getApplication().onkeydown(event);
            }
        }
	}

    public function onSequenceDeleteRequest(event : Dynamic){
        var selectedCords : SequenceRegion = getSelectedRegion();

        if(selectedCords !=null){ 
            // We, might have to revisit this if any sub-classes want to catch this event.
            if(event.stopPropagation){
                event.stopPropagation();
            }

            event.cancelBubble = true;

            // Delete region requested by the user.
            blockChanged(null,null, selectedCords.getStartPosition(), selectedCords.getStopPosition(), null);
        }
    }
	
	override public function uninstallWindowListeners(window : Dynamic ) : Void {
		window.onkeyup = null;
	}
	

    
    override
    public function mousedown(event : Dynamic) : Void{
        /*
            Prevent contextmenu mouse events from being detected
        */
        var targetElem = event.srcElement;
        if(targetElem == null){
         targetElem = event.target;
        }
        
        var id : String = targetElem.id;
        if(! StringTools.startsWith(id, 'menuitem') ){
            var rightClick : Bool = false;
            if(event.which && event.button == 2){
                rightClick = true;
            }else if(event.button && event.button == 2){
                rightClick = true;
            }

            if(rightClick == false){
                mouseDown = true;
              
                clearSelection();  
            }
        }
    }
    
    override
    public function mouseup(event : Dynamic) : Void{
        /*
            Prevent contextmenu mouse events from being detected
        */
        
        var targetElem = event.srcElement;
        if(targetElem == null){
         targetElem = event.target;
        }
        
        var id : String = targetElem.id;
        if(! StringTools.startsWith(id, 'menuitem') ){
            var rightClick : Bool = false;
            if(event.which && event.button == 2){
                rightClick = true;
            }else if(event.button && event.button == 2){
                rightClick = true;
            }

            if(rightClick == false){
                mouseDown = false;
              
                selectionUpdated();
         
                inMouseMove = false;
            }
        }
    }
    
    /*
        Method adds "numRows" to SequenceEditor.

        This method is responsible for adding both Sequence and Annotation rows.

        Typically there shouldn't be a need for code outside of SequenceEditor to
        call this method.  However it's public so if you need to it's available.
    */
    public function addSequenceRows(numRows : Int){
        var blockNumber : Int = blockFields.length; // Current number of blocks

        var toAdd : Array<Dynamic> = new Array<Dynamic>();
        
        var tableElem : Dynamic = theTable.el; // Hack, to get at the underlying DIV that holds our blocks

        var rowSize : Int = blockSize*columnCount; // Number of characters in a row (used to generate the label)

        var startingRowCount : Int = blockFields.length*blockSize; // Get the number of characters that can be shown already

        var lastRow : Int = startingRowCount;

        for(j in 0...numRows){ // Loop over rows to add
            var startingBlockNumber : Int = blockNumber + 1;

            this.renderAnnotationsByPosition(AnnotationPosition.TOP, tableElem, startingBlockNumber);

            var rowElem : js.html.DivElement = js.Browser.document.createDivElement();
            rowElem.style.height='2.0em'; // Bad, move to CSS
            rowElem.className = "molbio-unselectable";

            tableElem.appendChild(rowElem); // Add ROW DIV to TABLE DIV

		    for(i in 0...columnCount){ // Loop over columns to add		   
                if(i==0){
                    // Assign the label to the first block of a new row
                    var currentRow : Int = lastRow+rowSize;

                    var lineNumberBlock : js.html.SpanElement = generateRowLabel(Std.string(lastRow+1+offSet)+"-"+Std.string(currentRow+offSet));

                    lastRow = currentRow;             

                    rowElem.appendChild(lineNumberBlock); // Append LABEL SPAN to ROW DIV
                }

		        var localBlockNumber=++blockNumber;
		        
		        var block : SequenceEditorBlock = getSequenceEditorBlock(localBlockNumber, this);
                         
				var divElem : Dynamic = block.getElement();

                /*
                    A particular annotation row or the sequence row might be set to selectable.
                    So we make sure that new sequence rows follow whatever the current selectable state is.
                */
                if(this.getSelectableRow() == -1){
                    SequenceEditor.makeSelectable(divElem, true);
                }else{
                    SequenceEditor.makeSelectable(divElem, false);
                }
				
                blockFields.push(block); // Store a reference to this SequenceEditorBlock
		        
		        rowElem.appendChild(divElem); // Add the BLOCK DIV to the ROW DIV
		    }

            // Add a new series of annotations rows for this new sequence row
            this.renderAnnotationsByPosition(AnnotationPosition.BOTTOM, tableElem, startingBlockNumber);
        }
    }

    function getSequenceEditorBlock(blockNumber : Int, editor : SequenceEditor)  : SequenceEditorBlock{
        return new SequenceEditorBlock(blockNumber, editor);
    }

    function getAnnotationSequenceEditorBlock(blockNumber : Int, editor : SequenceEditor, annotationRowCount : Int){
        return Type.createInstance(annotationToClass[annotationRowCount],[blockNumber, editor, annotationRowCount]);

        //return new AnnotationEditorBlock(blockNumber, editor, annotationRowCount);
    }

    public function setAnnotationClass(annotationName : String, annotationClass : Class<AnnotationEditorBlock>){
        if(annotationToRow.exists(annotationName)){
            annotationToClass[annotationToRow[annotationName]] = annotationClass;
        }
    }

    function renderAnnotationsByPosition(annotationPosition : AnnotationPosition, tableElem : Dynamic, startingBlockNumber : Int){
        for (k in 0...annotationRowCount) {
            var blockNumber : Int = startingBlockNumber;

			if (!isAnnotationOn(k)) continue;
            if (this.getAnnotationPosition(k) != annotationPosition) continue;

			var rowElem : Dynamic = js.Browser.document.createElement('div');

			rowElem.style.height = '2.0em';

            SequenceEditor.makeSelectable(rowElem, false);
			
			tableElem.appendChild(rowElem);
			
			for (i in 0...columnCount) {
                 if(i==0){
                    var rowLabel : js.html.SpanElement = generateRowLabel(annotationLabels[k]);

                    annotationRowLabels[k].push(rowLabel);

                    rowElem.appendChild(rowLabel);
                }

				var block : AnnotationEditorBlock = getAnnotationSequenceEditorBlock(blockNumber++, this, k);
                     
				var divElem : Dynamic = block.getElement();

                if(this.getSelectableRow() == k){
                    block.makeSelectable(true);
                }else{
                    block.makeSelectable(false);
                }
			
				annotationFields[k].push(block);
	        
				rowElem.appendChild(divElem);
			}
		}
    }

	
    public function setAnnotationPosition(annotationNumber : Int, annotationPosition : AnnotationPosition){
        annotationPositions[annotationNumber] = annotationPosition;
    }    

    function getAnnotationPosition(annotationNumber : Int){
        return annotationPositions[annotationNumber];
    }

	public function isAnnotationOn(annotationNumber : Int) {
		return annotationsOn[annotationNumber];
	}

    function setAnnotationOn(annotationNumber : Int, enable : Bool){
        annotationsOn[annotationNumber] = enable;
    }
    
    function setAnnotationsOn(enable : Bool){
        for(i in 0...annotationsOn.length){
            annotationsOn[i] = enable;
        }
    }

    function hasAnnotationsOn(){
        for(i in 0...annotationsOn.length){
            if(this.isAnnotationOn(i)){
                return true;
            }
        }
        return false;
    }

    function getSelectableRow() : Int {
        return this.selectableRow;
    }

    public function redraw() {
		WorkspaceApplication.suspendUpdates();
		
        var oldSeq = this.sequence;
        
        this.deleteBlockRows(0);

        this.addSequenceRows(1);

        var oldSelectableRow : Int = this.selectableRow;

        this.selectableRow = -2;

        this.makeAnnotationSelectable(oldSelectableRow);

        blockChanged(null, null, 0, null, oldSeq);
		
		WorkspaceApplication.resumeUpdates(true);
    }

    public function autoSetBlockWidth(element : js.html.Element) : Void{
        /*if(Std.is(element, js.html.CanvasElement)){
            element.setAttribute('width',( blockSize * 0.585 ) + "em");
        }else{
            element.style.width = ( blockSize * 0.585 ) + "em";
        }*/

        //element.style.width = ( blockSize * 0.585 ) + "em";
       // element.style.height = '1.5em';

        if(js.Browser.window.navigator.appVersion.indexOf('Trident',0)>-1){
            element.style.width = (4+(editorCharWidth * blockSize)) + 'px';
        }else{
            element.style.width = (2+(editorCharWidth * blockSize)) + 'px';
        }



        /*
        if(Std.is(element,js.html.svg.SVGElement)){
            var svgElem = cast(element,js.html.svg.SVGElement);
            svgElem.setAttribute('width', ( blockSize * 0.585 ) + "em");
        }*/
    }

    public function setCursorPosition(region : SequenceRegion){
        var startPosition : Int = region.getStartPosition();
        var endPosition : Int = region.getStopPosition();
    
        //if(region.isForwardSelection()){
            startPosition = startPosition + offSet;
            endPosition = endPosition + offSet;
        //}

        var positionStr : String = "";
        if(Math.isNaN(startPosition) || startPosition == -1){
            positionStr = "";
        }else{
            if(startPosition == endPosition){
                startPosition = startPosition + 1;
                positionStr = startPosition+"";
            }else {
                startPosition = startPosition + 1;
                positionStr = startPosition+" - "+endPosition;
            }
        }
    
        var annotationPositionStr : String = "";
        if(region.getAnnotationStartPosition() != null ){
            var annotationRow : Int = region.getSelectedRow();
            annotationPositionStr = " ( " + getAnnotationLabel(annotationRow) + ": " + 
                region.getAnnotationStartPosition() + " - " + region.getAnnotationStopPosition()  + " ) ";
            Util.debug('Updating');
        }

        Util.debug('OffSet ' + offSet);

        WorkspaceApplication.getApplication().setCentralInfoPanelText('Selected: '+positionStr+"  "+annotationPositionStr);
    }
    
    public function onBlockBlur(block : Dynamic){
        if(block.isInput==true){
            var inputValue=block.previousSibling.value;

            block.textContent=inputValue;

            block.className = 'molbio-sequenceeditor-block molbio-selectable';

            block.isInput=false;

            autoSetBlockWidth(block);

            inputFocused = null;

            block.parentNode.removeChild(block.previousElementSibling);
        }
    }
    
    override
    public function getComponent(){
        return theComponent;
    }

    public function clearAnnotationRows() : Void{
        for (k in 0...annotationRowCount) {
		    if (!isAnnotationOn(k)) continue;
            for(blockNumber in 0...annotationFields[k].length){
    			var annotationBlock : AnnotationEditorBlock = annotationFields[k][blockNumber];

                annotationBlock.getElement().textContent = "";
            }
        }
    }

    public function getAnnotationBlocks(annotationName: String) : Array<AnnotationEditorBlock> {
        if(annotationToRow.exists(annotationName)){
            return annotationFields[annotationToRow[annotationName]];
        }else{
            return null;
        }
    }

    public function setSequence(sequence : String){
        blockChanged(null, null, 0, null, sequence);


    }
    
    public function blockChanged(textField : Dynamic, blockNumber : Int, startDelPosition : Int, endDelPosition : Int, newSequence : String){  
        WorkspaceApplication.suspendUpdates();

        var jConsole :Dynamic = untyped __js__('console');
        
        var dWindow : Dynamic = js.Browser.window;
        
        var sequenceCursorPos : Int = startDelPosition!=null ? startDelPosition : textField.selectionEnd + ( (blockNumber-1) * blockSize); 
        
        if(newSequence==null){
	        var sequenceBuf : StringBuf = new StringBuf();
	        
	        for(i in 0...blockFields.length){
	            var block : SequenceEditorBlock = blockFields[i];
	            
				var field : Dynamic = block.getElement();
				
	            if(field.isInput==true){
	                var localField : Dynamic =field.previousSibling;
	                sequenceBuf.add(localField.value);
	                localField.value="";
	            }else{
	                if(field.textContent!=null){
	                    sequenceBuf.add(field.textContent);    
	                }
	                
	                field.textContent = "";
	            }
	        }
        
            sequence = sequenceBuf.toString();
        
            if(startDelPosition!=null){
                sequence=sequence.substring(0, startDelPosition)+sequence.substring(endDelPosition, sequence.length);
            }
        }else{
            for(i in 0...blockFields.length){
                var block : SequenceEditorBlock = blockFields[i];
				var field : Dynamic = block.getElement();
                
                if(field.isInput==true){
                    var localField : Dynamic =field.previousSibling;
                    localField.value="";
                }else{                    
                    field.textContent = "";
                }
            }
            
            sequence=newSequence;
        }

        sequence = normaliseSequence(sequence);
        
        var pos=0;
        
        var blockNum=0;
         
        var seqLen : Int = sequence.length;
        
        var blockWithCursor : SequenceEditorBlock=null;
        
        var offSetPos : Int=null;
        
        var blocksToAdd : Int = 0;
        while(seqLen>pos){            
            var numChars = pos+blockSize > seqLen ? seqLen-pos : blockSize;
            
            if(blockNum > blockFields.length-1){
                blocksToAdd++;
            }
            
            pos+=numChars;

            blockNum++;
        }
        
        if(blocksToAdd > 0){
            this.addSequenceRows(blocksToAdd);
        }
        
        this.clearAnnotationRows();        

		fireSequenceChanged();
		
        pos=0;
        blockNum=0;

        var cursorRegion = null;
        
        while(seqLen>pos){            
            var numChars = pos+blockSize > seqLen ? seqLen-pos : blockSize;
            
            var blockSequence : String = sequence.substr(pos, numChars);
			
			if(blockNum > blockFields.length-1){
                this.addSequenceRows(1);
            }
			
			for (k in 0...annotationRowCount) {
				if (!isAnnotationOn(k)) continue;
				var annotationBlock : AnnotationEditorBlock = annotationFields[k][blockNum];
			
				var annotationSeq : String = annotationSequences[k];
                var annotationSeqBlock : String;

                if(annotationSeq == null){
                    annotationSeqBlock = '';
                }else{
                    var annotationSeqLen : Int = annotationSeq.length;


                    if (annotationSeqLen == 0 || annotationSeqLen < pos) {
                        annotationSeqBlock = "";
                    }else if (annotationSeqLen < pos+numChars){
                        var charCount : Int = annotationSeqLen-pos;
                        annotationSeqBlock = annotationSeq.substr(pos, charCount);
                    }else {
                        annotationSeqBlock = annotationSequences[k].substr(pos, numChars);
                    }
                }

				annotationBlock.getElement().textContent = annotationSeqBlock;
			}
			
            var block : SequenceEditorBlock = blockFields[blockNum++]; 
			var textFieldObj : Dynamic = block.getElement();
            
            if(textFieldObj.isInput==true){
                textFieldObj.previousSibling.value=blockSequence;
            }else{
                //textFieldObj.innerHTML = '<font color="red" blockNumber='+textFieldObj.blockNumber+'>' + blockSequence + '</font>';
                textFieldObj.textContent = blockSequence;
            }

            //DAVID: 01/12/17 if(((sequenceCursorPos==0 && pos==0) || sequenceCursorPos > pos) && sequenceCursorPos <= pos+numChars){
            if(sequenceCursorPos > pos && sequenceCursorPos <= pos+numChars){
                offSetPos = sequenceCursorPos-((blockNum - 1) * blockSize);
                
                if(blockNum==blockNumber){
                    //js.Lib.alert(offSetPos);
                    textFieldObj.previousSibling.setSelectionRange(offSetPos, offSetPos);

                    var cursorPosition : Int = ( ( blockNum - 1 ) * this.blockSize )+ offSetPos;

                    cursorRegion = new SequenceRegion(cursorPosition, cursorPosition,-1);

                    this.setCursorPosition( cursorRegion );
                }else{		            
		            blockWithCursor=block;
                }
            }
            
            pos+=numChars;
        }
        
        if(blockNum==0){
            blockNum=1;
            
            blockWithCursor=blockFields[0];
            offSetPos=1;
        }
        
        if(blockNum<blockFields.length){
            deleteBlockRows(blockNum);
        }

        //TODO, why does this need fireing twice?
        fireSequenceChanged();

        this.updateOutline();
        
        if (blockWithCursor != null) {
			var elem : Dynamic = blockWithCursor.getElement();
            elem.offSetPos=offSetPos;

            var etype = 'mouseup'; //was click  mouseup
            if (elem.fireEvent) {
                (elem.fireEvent('on' + etype));
            } else {
                var dDocument : Dynamic = js.Browser.document;
                var evObj = dDocument.createEvent('Events');
                evObj.initEvent(etype, true, false);
                elem.dispatchEvent(evObj);
            }
        }

        getObject().setSequence(sequence);

        WorkspaceApplication.resumeUpdates(false);
    }
	
    function deleteBlockRows(blockNum : Int){
        var delFrom = Math.ceil(blockNum/this.columnCount)*this.columnCount;

        js.Browser.window.console.log('Deleting from  ' + delFrom);

        var i=delFrom;
        
        while (i < blockFields.length) {
			var block : SequenceEditorBlock = blockFields[i];
            var node : Dynamic = block.getElement();
            var parentNode : js.html.Element = node.parentNode;

            if(node.isInput){
                // TODO: Discover what is causing this check to be required
                for(childNode in parentNode.childNodes){
                    if(childNode == node.inputNode){
                        parentNode.removeChild(node.inputNode);
                    }
                }
            }

            parentNode.removeChild(node);
            
            var parentParentNode : Dynamic = parentNode.parentNode;
            if(parentParentNode!=null){
                parentParentNode.removeChild(parentNode);    
            }
            
			for (k in 0...annotationRowCount) {
				if (!isAnnotationOn(k)) continue;
				var annotationBlock : AnnotationEditorBlock = annotationFields[k][i];
				
				var node : Dynamic = annotationBlock.getElement();
				var parentNode : Dynamic = node.parentNode;
            
				parentNode.removeChild(node);
            
				var parentParentNode : Dynamic = parentNode.parentNode;
				if(parentParentNode!=null){
					parentParentNode.removeChild(parentNode);    
				}

                annotationBlock.destroy();

               // annotationBlock.destroy();
			}
			
            //i+=this.columnCount;
            i++;

            block.destroy();
        }
        
        for(i in delFrom...blockFields.length){
            blockFields.pop();   
			
			for (k in 0...annotationRowCount) {
				if (!isAnnotationOn(k)) continue;
				annotationFields[k].pop();
			}
        }
    }

	function fireSequenceChanged() {
		for (listener in sequenceChangeListeners) {
			listener.sequenceChanged(this.sequence);
		}
	}
	
	public function addSequenceChangeListener(listener : SequenceChangeListener) {
		sequenceChangeListeners.push(listener);
	}
	
	public function removeSequenceChangeListener(listener: SequenceChangeListener) {
		sequenceChangeListeners.remove(listener);
	}
    
    function updateOutline(){
        
    }
    
    function cursorMoved(blockNumber : Dynamic, startPos : Int, endPos : Int){
        //js.Lib.alert("Block number = "+blockNumber+"|"+startPos+"x"+endPos);
    }
    
    public function selectionUpdated(){
        var selected : SequenceRegion = this.getSelectedRegion();

        if(lastSelected != null &&
            selected != null &&
                lastSelected.getStartPosition() == selected.getStartPosition() &&
                    selected.getStopPosition() == selected.getStartPosition()){
            return;
        }

        lastSelected = selected;

        updateOutline();

        if(selected != null){

            var sequence : String;
            if(selected.getSelectedRow() == -1){
                sequence = selected.getSequence();
            }else{
                sequence = selected.getAnnotationSequence();
            }

            getApplication().getMiddleSouthPanel().body.update(sequence);
            setCursorPosition(selected);
        }else{
            //lgetApplication().getSouthPanel().body.update("");
            setCursorPosition(new SequenceRegion(-1,-1,-1));
        }
    }

    public function getLastSelected() : SequenceRegion{
        return lastSelected;
    }
	
	public function setAnnotationSequence(annotationRow : Int, annotationSequence : String) {
		annotationSequences[annotationRow] = annotationSequence;
	}
    
    override
    public function onFocus(){		
		super.onFocus();

        getApplication().enableProgramSearchField(true);

        var obj = getNewMoleculeInstance();

        getApplication().setProgramSearchFieldEmptyText('Find in ' + Type.getClassName(Type.getClass(obj)).split('.').pop());

        getApplication().getMiddleSouthPanel().addCls('seq-breaking');

        var viewMenu : Dynamic = getApplication().getViewMenu();

        var self : SequenceEditor = this;

        viewAnnotations = Ext.create('Ext.menu.Menu', {
            margin: '0 0 10 0','z-index': 1000000});

            viewMenu.add({
            text:'Annotations',
            iconCls: 'bmenu',  // <-- icon
            menu: viewAnnotations  // assign menu by instance
        });

        hideAnnotationsItem = viewMenu.add({
                text:"Hide Annotations",
                hidden : true,
                handler: function(){      
                    self.hideAllAnnotations();

                    menuState.set('hideAnnotationsItem',false);
                    menuState.set('showAnnotationsItem',true);
                }
        });

        showAnnotationsItem = viewMenu.add({
                text:"Show Annotations",
                handler: function(){        
                   self.showAllAnnotations();

                    menuState.set('hideAnnotationsItem',true);
                    menuState.set('showAnnotationsItem',false);
                }
        });

        if(menuState.exists('showAnnotationsItem')){
            if(menuState.get('showAnnotationsItem')){
                showAnnotationsItem.show();
            }else{
                showAnnotationsItem.hide();
            }
        }

        if(menuState.exists('hideAnnotationsItem')){
            if(menuState.get('hideAnnotationsItem')){
                hideAnnotationsItem.show();
            }else{
                hideAnnotationsItem.hide();
            }
        }



        addAnnotationMenuItems();

        var enableLiveUpdateItem : Dynamic = null;
        var disableLiveUpdateItem : Dynamic = null;

        var disableLabel = 'Disable Live Update';
        var enableLabel = 'Enable Live Update';

        disableLiveUpdateItem = viewAnnotations.add({
            text : disableLabel,
            handler : function(){
                enableLiveUpdateItem.show();
                disableLiveUpdateItem.hide();

                menuState.set(enableLabel,true);
                menuState.set(disableLabel,false);

                liveUpdateOn = false;
            }
        });

        enableLiveUpdateItem = viewAnnotations.add({
            text : enableLabel,
            handler : function(){
                enableLiveUpdateItem.hide();
                disableLiveUpdateItem.show();

                liveUpdateOn = true;

                menuState.set(enableLabel,false);
                menuState.set(disableLabel,true);

                redraw();
            }
        });

        if(menuState.exists(disableLabel)){
            if(menuState.get(disableLabel)){
                disableLiveUpdateItem.show();
            }else{
                disableLiveUpdateItem.hide();
            }
        }

        if(menuState.exists(enableLabel)){
            if(menuState.get(enableLabel)){
                enableLiveUpdateItem.show();
            }else{
                enableLiveUpdateItem.hide();
            }
        }else{
            enableLiveUpdateItem.hide();
        }

        viewFastaMenuItem = viewMenu.add({
            text: 'FASTA',
            handler: function(){
                switchToFasta();
            }
        });

        viewEditorMenuItem = viewMenu.add({
            text: 'Editor',
            handler: function(){
                switchToEditor();
            },
            hidden: true
        });

        fastaButton = getApplication().getToolBar().add({
            text:  'FASTA',
            handler: function(){

                switchToFasta();
            },
            iconCls :'x-btn-fasta-dna',
            tooltip: {dismissDelay: 10000, text: 'View formatted as FASTA'}
        });

        editorButton = getApplication().getToolBar().add({
            text:  'Editor',
            handler: function(){

                switchToEditor();
            },
            iconCls :'x-btn-editor-dna',
            tooltip: {dismissDelay: 10000, text: 'Switch back to editor view'}
        });

        editorButton.hide();

        getApplication().getToolBar().add({
            text: 'SeqFig',
            iconCls :'x-btn-gridvar',
            handler: function(){
                var alnMap = new Map<String, String>();
                alnMap.set(getObjectName(),getSequence());

                var aln = new MSA(alnMap, [getObjectName()]);

                var gridVar = new GridVar();
                gridVar.dataTableDefinition = AlignmentGVPlugin.getTableDefinition(getObjectName(), aln);
                gridVar.fit = true;
                gridVar.padding = false;
                gridVar.showXLabels = false;
                gridVar.configCollapse = false;

                var wo = new GridVarWO(gridVar, getObjectName() + ' (SeqFig)');

                WorkspaceApplication.getApplication().getWorkspace().addObject(wo, true, null);
            }
        });

        if(menuState.exists('hideFastaMenuItem')){
            if(menuState.get('hideFastaMenuItem')){
                viewFastaMenuItem.hide();
                viewEditorMenuItem.show();

                fastaButton.hide();
                editorButton.show();

                switchToFasta();

                /*fastaViewer.el.dom.style.display = 'block';

                updateFastaViewer();

                theTable.el.dom.style.display = 'none';*/
            }
        }

        if(menuState.exists('hideEditorMenuItem')){
            if(menuState.get('hideEditorMenuItem')){
                viewEditorMenuItem.hide();

                /*fastaViewer.el.dom.style.display = 'none';

                theTable.el.dom.style.display = 'block';*/

                switchToEditor();

                fastaButton.show();
                editorButton.hide();
            }
        }

        var editMenu : Dynamic = getApplication().getEditMenu();
        
        editMenu.add({
            text : "Block size",
            handler : function(){
                var self = this;

                Ext.Msg.prompt('Edit block size', 'Enter new block size', function(btn, text){
                    if(btn == 'ok'){
                        self.setBlockSize(Std.parseInt(text));
                    }
                });
            }
        });

        editMenu.add({
            text : "Blocks per line",
            handler : function(){
                var self = this;
                Ext.Msg.prompt('Edit row block number', 'Enter new row block count', function(btn, text){
                    if(btn == 'ok'){
                        self.setColumnCount(Std.parseInt(text));
                    }
                });
            }
        });

        editMenu.add({
            text : 'Offset',
            handler : function() {
                var self = this;
                Ext.Msg.prompt('Edit sequence offset','Enter sequence offset', function(btn, text){
                    if(btn == 'ok'){
                        self.setOffSet(Std.parseInt(text));
                    }
                });
            }
        });
    }

    public function switchToEditor(){
        /*theTable.el.dom.style.display = 'block';
        fastaViewer.el.dom.style.display = 'none';*/

        /*theTable.setVisible(true);
        fastaViewer.setVisible(false);*/

        theComponent.remove(fastaViewer, false);
        theComponent.add(theTable);

        theComponent.doLayout();

        viewFastaMenuItem.show();
        viewEditorMenuItem.hide();

        fastaButton.show();
        editorButton.hide();

        menuState.set('hideFastaMenuItem', false);
        menuState.set('hideEditorMenuItem',true);

        redraw();
    }

    public function switchToFasta(){
        /*theTable.el.dom.style.display = 'none';
        fastaViewer.el.dom.style.display = 'block';*/

        /*theTable.setVisible(false);
        fastaViewer.setVisible(true);*/

        theComponent.remove(theTable, false);
        theComponent.add(fastaViewer);

        viewFastaMenuItem.hide();
        viewEditorMenuItem.show();

        fastaButton.hide();
        editorButton.show();

        menuState.set('hideFastaMenuItem', true);
        menuState.set('hideEditorMenuItem',false);

        updateFastaViewer();

        theComponent.doLayout();
    }

    public function updateFastaViewer(){
        var name = getActiveObjectName();

        name = StringTools.replace(name, ' (DNA)', '');

        name = StringTools.replace(name, ' (Protein)', '');

        fastaViewer.el.dom.innerHTML = '<pre>' + FastaEntity.formatFastaFile(name, getSequence()) + '</pre>';
    }

    public function setOffSet(offSet : Int): Void {
        deleteBlockRows(0);

        this.offSet = offSet;

        this.redraw();
    }

    public function setBlockSize( blockSize : Int) : Void {
        deleteBlockRows(0);

        this.blockSize = blockSize;

        this.redraw();
    }

    public function setColumnCount( columnCount : Int) : Void {
        deleteBlockRows(0);

        this.columnCount = columnCount;

        this.redraw();
    }

    public function hideAllAnnotations(){
        deleteBlockRows(0);

        setAnnotationsOn(false);

        for(i in 0...showAnnotationItems.length){
            showAnnotationItems[i].show();
            hideAnnotationItems[i].hide();
        }          

        redraw();

        showAnnotationsItem.show();
        hideAnnotationsItem.hide();
    }

    public function showAllAnnotations(){
        deleteBlockRows(0);     

        setAnnotationsOn(true);   

        for(i in 0...showAnnotationItems.length){
            hideAnnotationItems[i].show();
            showAnnotationItems[i].hide();
        } 

        redraw();

        hideAnnotationsItem.show();
        showAnnotationsItem.hide();
    }
    
    override
    public function onBlur(){
        super.onBlur();

        getApplication().getMiddleSouthPanel().removeCls('seq-breaking');

        /*
        showAnnotationItems = [];
        hideAnnotationItems = [];
        viewAnnotations = [];*/
    }
    
    public function getSelectedRegion() : SequenceRegion {
        if(sequence == null){
            return null;
        }

        /*
            Detecting the selected region of an INPUT element
            requires different logic to detecting the selected
            region of DIV elements.

            So we start with the logic to detect the selected 
            region of an INPUT element.
        */
        var focusNode : Dynamic = js.Browser.document.activeElement;

        var sequenceRegion : SequenceRegion = null;

        if(focusNode != null){
            if(focusNode.tagName == 'INPUT'){
                var startOffSet : Int = focusNode.selectionStart;
                var stopOffSet : Int = focusNode.selectionEnd;
   
                var blockNumber : Int = focusNode.blockNumber;

                var cursorStartPosition : Int = ( ( blockNumber-1 ) * blockSize ) + startOffSet;
                var cursorEndPosition : Int = ( ( blockNumber-1 ) * blockSize ) + stopOffSet;

                var forwardSelection : Bool = true;

                if(cursorStartPosition > cursorEndPosition){
                    var tmp : Int = cursorStartPosition;
                    cursorStartPosition = cursorEndPosition;
                    cursorEndPosition = tmp;

                    forwardSelection = false;
                }



                sequenceRegion = new SequenceRegion(cursorStartPosition, cursorEndPosition, this.getSelectableRow());
                sequenceRegion.setIsForward(forwardSelection);
            }
        }

        if(sequenceRegion == null){
            /*
                We, get here when we haven't be able to detect that the active
                element is an INPUT element.
            */
            var dWindow : Dynamic = js.Browser.window;
            var sel : Dynamic = dWindow.getSelection();
    
            var retVal : Dynamic = null;
            if(sel.rangeCount){
                if(sel.anchorNode!=null && sel.anchorNode.parentNode!=null){
                    var anchorOffSet = sel.anchorOffset;
                    var focusOffSet = sel.focusOffset;

                    if(Reflect.hasField(sel.anchorNode,'blockNumber')){
                        sel.anchorNode.parentNode = sel.anchorNode;
                    }

                    var anchorParentNode :Dynamic = sel.anchorNode.parentNode;

                    if(anchorParentNode.tagName == 'FONT'){
                        anchorParentNode = anchorParentNode.parentNode;
                        anchorOffSet += Std.parseInt(sel.anchorNode.parentNode.getAttribute('seq_position_offset'));
                    }

                    var anchorBlockNumber : Int = anchorParentNode.blockNumber;

                    /*if(anchorBlockNumber == null && Reflect.hasField(sel.anchorNode, 'blockNumber')){
                        anchorBlockNumber = sel.anchorNode.blockNumber;
                    }*/

                    var anchorBOffSet = null;
                    if(anchorBlockNumber == null){
                        anchorBlockNumber = anchorParentNode.getAttribute('blockNumber');
                        anchorBOffSet = Std.parseInt(anchorParentNode.getAttribute('block_part_start'));
                    }

                    var focusParentNode :Dynamic = sel.focusNode.parentNode;

                    if(focusParentNode.tagName == 'FONT'){
                        focusParentNode = focusParentNode.parentNode;
                        focusOffSet += Std.parseInt(sel.focusNode.parentNode.getAttribute('seq_position_offset'));
                    }

                    var focusBlockNumber : Int = focusParentNode.blockNumber;
                    var focusBOffSet = null;
                    if(focusBlockNumber == null){
                        focusBlockNumber = focusParentNode.getAttribute('blockNumber');
                        focusBOffSet =  Std.parseInt(focusParentNode.getAttribute('block_part_start'));
                    }

                    if(focusBOffSet == null){
                        focusBOffSet = 0;
                    }

                    if(anchorBOffSet == null){
                        anchorBOffSet = 0;
                    }
                    


                    if( ! ( focusBlockNumber == null && anchorBlockNumber == null ) ){   
                        var focusRealPosition : Int = 0;
                        var anchorRealPosition : Int = 0;

                        if(focusBlockNumber == null){
                            focusRealPosition = this.sequence.length;
                            anchorRealPosition = (anchorBOffSet + anchorOffSet) + ( (anchorBlockNumber-1) * blockSize) ;
                        }else{
                            focusRealPosition = (focusBOffSet + focusOffSet) + ( (focusBlockNumber-1) * blockSize);

                            if(anchorBlockNumber == null){
                                anchorRealPosition = this.sequence.length;
                            }else{
                                anchorRealPosition = (anchorBOffSet + anchorOffSet) + ( (anchorBlockNumber-1) * blockSize);
                            }
                        }
                
                        var startPosition : Int = anchorRealPosition < focusRealPosition ? anchorRealPosition : focusRealPosition;
                        var endPosition : Int = anchorRealPosition == startPosition ? focusRealPosition : anchorRealPosition;

                        sequenceRegion = new SequenceRegion(startPosition, endPosition, this.getSelectableRow());
                    }
                }
            }
        }

        if(sequenceRegion == null || sequence == null){
            return null;
        }else{
            var selectedSequence : String = sequence.substring(sequenceRegion.getStartPosition(), sequenceRegion.getStopPosition());

            sequenceRegion.setSequence(selectedSequence);

            if(sequenceRegion.getSelectedRow() >= 0){
                var annotationSequence : String = this.annotationSequences[sequenceRegion.getSelectedRow()].substr(sequenceRegion.getStartPosition(), sequenceRegion.getStopPosition());

                sequenceRegion.setAnnotationSequence(annotationSequence);
            }


            return sequenceRegion;
        }
    }

    public function getSelectedSequence() : String {
        var region : SequenceRegion = getSelectedRegion();
        if(region == null || sequence == null){
            return null;
        }else{
            return getSelectedRegion().getSequence();
        }
    }
    
    public function clearSelection(){
        var dWindow : Dynamic = js.Browser.window;
        var sel : Dynamic = dWindow.getSelection();
            
        if(sel.empty){
            sel.empty();
        }
    }

    private function generateRowLabel( rowLabel : String) : js.html.SpanElement{
        var lineNumberBlock : js.html.SpanElement = js.Browser.document.createSpanElement();

        lineNumberBlock.textContent = rowLabel;

        lineNumberBlock.style.display="inline-block";     

        lineNumberBlock.style.width = "100px";    

        lineNumberBlock.style.textAlign = "right";

        lineNumberBlock.className = "molbio-sequenceeditor-row-label";

        SequenceEditor.makeSelectable(lineNumberBlock, false);

        return lineNumberBlock;
    }

    public function makeAnnotationSelectable(annotationNumber : Int){
        if(annotationNumber!=this.selectableRow){
            if(this.selectableRow == -1){
                for(i in 0...this.blockFields.length){
                    var blockField : SequenceEditorBlock = this.blockFields[i];
                    SequenceEditor.makeSelectable(blockField.getElement(), false);
                }
            }else if(this.selectableRow > -2){
                for(i in 0...this.annotationFields[this.selectableRow].length){
                    var annotationField : AnnotationEditorBlock = this.annotationFields[this.selectableRow][i];

                    annotationField.makeSelectable(false);
                }
            }

            if(annotationNumber == -1){
                for(i in 0...this.blockFields.length){
                    var blockField : SequenceEditorBlock = this.blockFields[i];
                    SequenceEditor.makeSelectable(blockField.getElement(), true);
                }
            }else{
                for(i in 0...this.annotationFields[annotationNumber].length){
                    var annotationField : AnnotationEditorBlock = this.annotationFields[annotationNumber][i];

                    annotationField.makeSelectable(true);
                }
            }

            this.selectableRow = annotationNumber;
        }
    }

    override
    public function serialise() : Dynamic {
        var object : Dynamic = super.serialise();

        object.OFFSET = offSet;
        object.BLOCK_SIZE = blockSize;
        object.COLUMN_COUNT = columnCount;

        return object;
	}
	
    override
	public function deserialise(object : Dynamic) : Void {
        super.deserialise(object);

        offSet = object.OFFSET;
        blockSize = object.BLOCK_SIZE;
        columnCount = object.COLUMN_COUNT;
	}
	
	public function getSequence() : String {
		return sequence;
	}

    /*
        Function takes the given element and applies the CSS class molbio-selectable when
        makeSelectable is true and molbio-unselectable when it is false.  For compatibility
        with IE>9 the attribute "unselectable" is added to the element when makeSelectable 
        is false and removed when it is true
    */
    public static function makeSelectable(elem : js.html.Element, makeSelectable : Bool) {
		if (makeSelectable) {
            elem.classList.remove("molbio-unselectable");
            elem.classList.add("molbio-selectable");
			/*jElem.removeClass("molbio-unselectable");
			jElem.addClass("molbio-selectable");*/
			
			elem.removeAttribute("unselectable");
		}else {
            elem.classList.add("molbio-unselectable");
            elem.classList.remove("molbio-selectable");
			/*jElem.addClass("molbio-unselectable");
			jElem.removeClass("molbio-selectable");*/
			
			elem.setAttribute("unselectable","on");
		}
    }

    public function normaliseSequence(sequence : String) : String{
        if(sequence.indexOf('>') > -1){
            var objs = FastaEntity.parseFasta(sequence);

            if(objs != null && objs.length >0){
                var obj = objs[0];
                getWorkspace().renameWorkspaceObject(getActiveObjectId(),obj.getName());

                sequence = obj.getSequence();
            }

            /*
            if(sequence.indexOf('>') == 0){
                var lastSeqPos = 0;
                var nonSpaceCount = 0;
                for(i in 0...sequence.length){
                    if(sequence.charAt(i) == ' '){
                        lastSeqPos = i;
                        nonSpaceCount = 0;
                    }else if(nonSpaceCount > 50){
                        break;
                    }else{
                        nonSpaceCount += 1;
                    }
                }

                getWorkspace().renameWorkspaceObject(getActiveObjectId(),sequence.substr(1, lastSeqPos-1));

                sequence = sequence.substr(lastSeqPos+1,sequence.length);
            }*/
        }

        sequence = reg_newLine.replace(sequence,'');
        sequence = reg_carReturn.replace(sequence, '');

        // Allow for editing of restriction sites which require the star
        var entity = getEntity();
        if(entity == null || !Std.is(entity, SgcRestrictionSite)){
            sequence = reg_star.replace(sequence,'');
        }

        sequence = reg_whiteSpace.replace(sequence,'');
        sequence = reg_num.replace(sequence,'');
        sequence = sequence.toUpperCase();

        return sequence;
    }

    public function redrawSequenceOnly(){
        findAnnotationOn = false;

        var blockSequence = '';
        var blockSeqLen = 0;

        var blockNumber = 0;

        for(i in 0...sequence.length){
            blockSequence +=  sequence.charAt(i);

            blockSeqLen++;

            if(blockSeqLen == blockSize){
                var block : SequenceEditorBlock = blockFields[blockNumber];
                var textFieldObj : Dynamic = block.getElement();

                textFieldObj.innerHTML = blockSequence;

                blockSequence = '';

                blockNumber++;
                blockSeqLen = 0;
            }
        }

        if(blockSequence != ''){
            var block : SequenceEditorBlock = blockFields[blockNumber];
            var textFieldObj : Dynamic = block.getElement();

            textFieldObj.innerHTML = blockSequence;
        }
    }

    /**
    * getNewMoleculeInstance returns a new molecule instance with the current sequence
    *
    * Editor sub-classes should override this method to return an ojbect of the
    * appropriate class.  For example the DNASequenceEditor class returns a new
    * DNA instance from this method
    **/
    public function getNewMoleculeInstance(){
        return new Molecule(sequence);
    }

    public function findSequence(search : String){
        //TODO: Cleanup the addition of font tags to prevent empty font tags being added
        redrawSequenceOnly();

        //remove spaces
        var wsub =~/\s+/g;

        search = wsub.replace(search, '');

        //remove numbers
        //var dsub =~/\d+/g;

        //search = dsub.replace(search, '');

        //remove hypens
        //var hsub =~/\-/g;

        //search = hsub.replace(search, '');

        var mol = getNewMoleculeInstance();
        var positions = mol.findMatchingLocuses(search);

        if(positions.length < 1){
            return;
        }

        findAnnotationOn = true;

        var startPositions = new Map<Int, Int>();
        var stopPositions = new Map<Int, Int>();
        var missMatchPositions = new Map<Int, Int>();

        for(position in positions){
            startPositions.set(position.start, 1);
            stopPositions.set(position.end, 1);

            if(position.missMatchPositions != null){
                for(position in position.missMatchPositions){
                    missMatchPositions.set(position, 1);
                }
            }
        }

        var blockSequence = '<font color="black" seq_position_offset="0">';
        var inAnnotationBlock = false;

        var blockNumber = 0;
        var blockSeqLen = 0;

        var matchColor = '#90ec8d';
        var missmatchColor = '#FF7DC8';

        for(i in 0...sequence.length){
            if(startPositions.exists(i)){
                if(missMatchPositions.exists(i)){
                    blockSequence += '</font><font color="'+missmatchColor+'" seq_position_offset="' + blockSeqLen + '">' + sequence.charAt(i) + '</font>';
                    blockSequence += '</font><font color="'+matchColor+'" seq_position_offset="' + (blockSeqLen +1) + '">';
                }else{
                    blockSequence += '</font><font color="'+matchColor+'" seq_position_offset="' + blockSeqLen + '">';
                    blockSequence += sequence.charAt(i);
                }

                if(stopPositions.exists(i)){
                    blockSequence += '</font>';

                    //added both lines
                    blockSequence += '<font color="black" seq_position_offset="' + (blockSeqLen + 1) +'">';
                    inAnnotationBlock = false;
                }else{
                    inAnnotationBlock = true;
                }
            }else if(stopPositions.exists(i)){
                if(missMatchPositions.exists(i)){
                    blockSequence += '<font color="'+missmatchColor+'" seq_position_offset="' + blockSeqLen + '">' + sequence.charAt(i) + '</font></font>';
                }else{
                    blockSequence += sequence.charAt(i) + '</font>';
                }

                blockSequence += '<font color="black" seq_position_offset="' + (blockSeqLen + 1) +'">';
                inAnnotationBlock = false;
            }else{
                if(missMatchPositions.exists(i)){
                    if(inAnnotationBlock){
                        blockSequence += '</font>';
                    }
                    blockSequence += '<font color="'+missmatchColor+'" seq_position_offset="' + blockSeqLen + '">' + sequence.charAt(i) + '</font>';
                    if(inAnnotationBlock){
                        //chnaged red to blue
                        blockSequence += '<font color="'+matchColor+'" seq_position_offset="' + (blockSeqLen +1)+ '">';
                    }else{
                        blockSequence += '<font color="black" seq_position_offset="' + (blockSeqLen + 1) +'">';
                    }
                }else{
                    blockSequence += sequence.charAt(i);
                }
            }

            blockSeqLen++;

            if(blockSeqLen == blockSize){
                var block : SequenceEditorBlock = blockFields[blockNumber];
                var textFieldObj : Dynamic = block.getElement();

                if(inAnnotationBlock){
                    blockSequence += '</font>';
                }

                textFieldObj.innerHTML = blockSequence;

                blockSequence = '<font color="black" seq_position_offset="0">';

                if(inAnnotationBlock){
                    blockSequence += '<font color="'+matchColor+'" seq_position_offset="' + blockSeqLen + '">';
                }

                blockNumber++;
                blockSeqLen = 0;
            }
        }

        if(blockSequence != ''){
            var block : SequenceEditorBlock = blockFields[blockNumber];
            var textFieldObj : Dynamic = block.getElement();

            if(inAnnotationBlock){
                blockSequence += '</font>';
            }

            textFieldObj.innerHTML = blockSequence;
        }
    }

    override public function search(regex : String) : Void{
        super.search(regex);

        findSequence(regex);
    }
}

interface SequenceChangeListener {
	function sequenceChanged(sequence : String) : Void;
}

enum AnnotationPosition {
    TOP;
    BOTTOM;
}

class SequenceRegion{
    var startPosition : Int;
    var stopPosition : Int;

    var selectedRow : Int;
    var sequence : String ;

    var annotationStartPosition : Int;
    var annotationStopPosition : Int;
    var annotationSequence : String;

    var forwardSelection : Bool;

    public function new(startPosition : Int, stopPosition : Int, selectedRow : Int){
        this.startPosition = startPosition;
        this.stopPosition = stopPosition;
        this.selectedRow = selectedRow;
    }

    public function setStartPosition(startPosition : Int){
        this.startPosition = startPosition;
    }

    public function setStopPosition(stopPosition : Int){
        this.stopPosition = stopPosition;
    }

    public function setIsForward(isForwardSelection : Bool){
        forwardSelection = isForwardSelection;
    }

    public function isForwardSelection(){
        return forwardSelection;
    }

    public function setAnnotationSequence(annotationSequence : String){
        this.annotationSequence = annotationSequence;
    }

    public function getAnnotationSequence() : String{
        return this.annotationSequence;
    }

    public function setAnnotationStartPosition(startPosition : Int){
        this.annotationStartPosition = startPosition;
    }

    public function getAnnotationStartPosition() : Int{
        return this.annotationStartPosition;
    }

    public function setAnnotationStopPosition(stopPosition : Int){
        this.annotationStopPosition = stopPosition;
    }

    public function getAnnotationStopPosition() : Int{
        return this.annotationStopPosition;
    }

    public function getSelectedRow() : Int {
        return this.selectedRow;
    }

    public function setSequence(sequence : String){
        this.sequence = sequence;
    }

    public function getSequence() : String {
        return sequence;
    }

    public function getStartPosition() : Int {
        return this.startPosition;
    }

    public function getStopPosition() : Int {
        return this.stopPosition;
    }
}