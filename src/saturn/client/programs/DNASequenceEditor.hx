/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.domain.SgcRestrictionSite;
import saturn.db.Model;
import saturn.core.domain.SgcVector;
import saturn.core.molecule.Molecule;
import saturn.client.WorkspaceApplication;
import saturn.client.WorkspaceApplication;
import haxe.Json;
import js.html.ArrayBuffer;
import saturn.client.core.CommonCore;
import saturn.client.programs.sequenceeditor.SequenceEditor;
import saturn.client.programs.sequenceeditor.SequenceEditorBlock;
import saturn.client.programs.sequenceeditor.SequenceEditor.SequenceChangeListener;
import saturn.client.workspace.Workspace;
import saturn.core.DNA;
import saturn.core.DNA.GeneticCodes;
import saturn.core.DNA.GeneticCode;
import saturn.core.DNA.GeneticCodeRegistry;
import saturn.core.DNA.Frame;
import saturn.core.DNA.Frames;
import saturn.core.DNA.Direction;
import saturn.core.BlastDatabase;
import saturn.core.Protein;
import saturn.core.RestrictionSite;
import saturn.client.workspace.PrimerWorkspaceObject;
import saturn.client.workspace.ProteinWorkspaceObject;

import saturn.util.MathUtils;
import saturn.client.workspace.DNAWorkspaceObject;
import js.Lib;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.ProgramRegistry;
import saturn.util.StringUtils;

import saturn.client.workspace.WebPage;
import saturn.client.workspace.WebPageWorkspaceObject;
import saturn.client.workspace.Workspace;

import saturn.core.FastaEntity;
import saturn.core.TmCalc;

import bindings.Ext;

import saturn.client.WorkspaceApplication;

class DNASequenceEditor implements SequenceChangeListener extends SequenceEditor{
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ DNAWorkspaceObject, PrimerWorkspaceObject ];
	
    var selectedStatsFolder : Dynamic;
	
	var lastWasMouseMoved : Bool;
    var frameOffSet : Int;
	
	var tmCalcEngine : TmCalc;
    var proteinItemsMenu : Dynamic;
    
    public function new(){
        super();
    } 
	
	override
	public function emptyInit() {
		tmCalcEngine = new TmCalc();

        setDefaultAnnotationEditorBlockClass(DNAAnnotationSequenceEditorBlock);

		super.emptyInit();

        frameOffSet = 0;

		selectedStatsFolder = null;
		
		lastWasMouseMoved = false;
		
		setAnnotationCount(6);

        this.setAnnotationPosition(0, AnnotationPosition.TOP);
        this.setAnnotationPosition(1, AnnotationPosition.TOP);
        this.setAnnotationPosition(2, AnnotationPosition.TOP);

        setAnnotationLabel(0, "Frame 1");
        setAnnotationLabel(1, "Frame 2");
        setAnnotationLabel(2, "Frame 3");

        setAnnotationLabel(3, "Reverse Frame 1");
        setAnnotationLabel(4, "Reverse Frame 2");
        setAnnotationLabel(5, "Reverse Frame 3");
		
		addSequenceChangeListener(this);
	}
    
	override
	public function setActiveObject(objectId : String) {
		super.setActiveObject(objectId);
		
		var dnaObject : Dynamic = getActiveObject(DNAWorkspaceObject);

        var object : DNA;
        if(Std.is(dnaObject, saturn.core.DNA)){
            object = dnaObject;
        }else{
            object = dnaObject.getDNAObject();
        }

		var sequence : String = object.getSequence();
		if (Std.is(object, RestrictionSite)) {
			sequence = cast(object, RestrictionSite).getStarSequence();
		}
		
		blockChanged(null, null, 0, null, sequence);

        updateProteinMenuItems();
	}
	
    override
    public function onFocus(){
        super.onFocus();
    
        var self : DNASequenceEditor = this;

        var viewMenu = getApplication().getViewMenu();

        var toolsMenu = getApplication().getToolsMenu();

        var blastMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        toolsMenu.add({
            text:'BLAST',
            iconCls: 'bmenu',  // <-- icon
            menu: blastMenu, // assign menu by instance
            cls:'menu-item-FILE'
        });

        var blastItems = [];
        var blastDatabases = BioinformaticsServicesClient.getClient(null).getBlastList().DNA;
        for(dbName in Reflect.fields(blastDatabases)){
            var blastItem = blastMenu.add({
            text:dbName,
            hidden : false,
            handler: function(){
                var blastName = 'Blastn '+getActiveObject(DNAWorkspaceObject).getName()+' 1 - '+self.sequence.length;

                self.blastSequence(self.sequence, dbName, blastName);
            }
            });

            blastItems.push({
                text:dbName,
                hidden : false,
                handler: function(){
                    var blastName = 'Blastn '+getActiveObject(DNAWorkspaceObject).getName()+' 1 - '+self.sequence.length;

                    self.blastSequence(self.sequence, dbName, blastName);
                }
            });
        }

        var blastButton = Ext.create('Ext.button.Button', {
            renderTo: Ext.getBody(),
            text: 'BLAST',
            handler: function() {
                //
            },
            menu: Ext.create('Ext.menu.Menu',{
                items: blastItems
            }),
            iconCls :'x-btn-blast',
            cls: 'x-btn-split-black-background',
            tooltip: {dismissDelay: 10000, text: 'BLAST against a sequence database'}
        });

        getApplication().getToolBar().add(blastButton);

        getApplication().getEditMenu().add({
            text : "Frame OffSet",
            handler : function(){
                Ext.Msg.prompt('Edit Frame OffSet', 'Enter new Frame OffSet', function(btn, text){
                    if(btn == 'ok'){
                        self.setFrameOffSet(Std.parseInt(text));
                    }
                });
            }
        });
		
		getApplication().getEditMenu().add( {
			text : "Inverse complement",
            handler : function(){
                inverseComplement();
            }
		});

        getApplication().getEditMenu().add( {
            text : "Complement",
            handler : function(){
                complement();
            }
        });

        getApplication().getEditMenu().add( {
            text : "Inverse",
            handler : function(){
                inverse();
            }
        });

        getApplication().getToolBar().add({
            html: 'Inverse<br/>Complement',
            handler: function(){
                inverseComplement();
            },
            iconCls: 'x-btn-inverse-complement',
            tooltip: {dismissDelay: 10000, text: 'Inverse complement sequence'}
        });

        getApplication().getToolBar().add({
            html: 'Complement',
            handler: function(){
                complement();
            },
            tooltip: {dismissDelay: 10000, text: 'Complement sequence'}
        });

        getApplication().getToolBar().add({
            html: 'Inverse',
            handler: function(){
                inverse();
            },
            tooltip: {dismissDelay: 10000, text: 'Inverse sequence'}
        });

		installOutlineTree();
		
        updateOutline();

        getApplication().getExportMenu().add({
            text: "FASTA",
            handler: function(){
                var name = getActiveObjectName();

                name = StringTools.replace(name, ' (DNA)', '');

                var contents = FastaEntity.formatFastaFile(name, getSequence());

                getApplication().saveTextFile(contents, name + '.fasta');
            }
        });

        var importMenu = getApplication().getImportMenu();

        var frames = [Frame.ONE, Frame.TWO, Frame.THREE];

        for(j in 0...2){
            for(i in 1...4){
                var label = 'Import Frame ' + i;

                if(j == 1){
                    label += ' (reverse)';
                }

                importMenu.add({
                    text: label,
                    handler: function(){
                        var dna = new DNA(getSequence());

                        if(j == 1){
                            dna = new DNA(dna.getInverseComplement());
                        }

                        var protein = new Protein(dna.getFrameTranslation(GeneticCodes.STANDARD, frames[i-1]));
                        getWorkspace()._addObject(new ProteinWorkspaceObject(protein, getActiveObjectName() + ' (Frame ' + i + ')'), true, true);
                    }
                });
            }
        }
        //Beginnings of outline structure for related objects
        /*if(getActiveObjectId() != null){
            var obj :Dynamic = getActiveObjectObject();

            addModelToOutline(obj, true);
        }*/

        proteinItemsMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        getApplication().getToolBar().add({
            text: 'Load Protein',
            menu: proteinItemsMenu
        });

        updateProteinMenuItems();
    }

    public function updateProteinMenuItems(){
        var dnaObj = getEntity();

        if(dnaObj != null){
            var proteinNames : Array<String> = dnaObj.getProteinNames();
            for(name in proteinNames){
                proteinItemsMenu.add({
                    text:name,
                    hidden : false,
                    handler: function(){
                        var prot = dnaObj.getProtein(name);
                        prot.setName(dnaObj.getName() + '(' + name + ')');
                        getWorkspace().addObject(prot, true);
                    }
                });
            }
        }
    }

    public function loadProtein(){
        var entity = getEntity();

        if(entity != null){
            var prot :Protein = entity.getProtein();
            //prot.setParent(this);

            getWorkspace().addObject(prot, true);
        }
    }

    override public function updateModelField(obj : Dynamic, field : String, value : String){
        var d = cast(getObject(), DNA);
        if(d.isLinked()){
            if(d.linkedOriginField == field){
                super.updateModelField(obj, field, getSequence());
                return;
            }
        }

        super.updateModelField(obj, field, value);
    }

    public function setFrameOffSet(offSet : Int){
        frameOffSet = offSet;    
    }

    public function blastSequence(theSequence : String, database : String, blastName : String){
        BioinformaticsServicesClient.getClient().sendBlastReportRequest(theSequence,blastName, database, function(response,error){
            if(error == null){
                var reportFile = response.json.reportFile;

                var location : js.html.Location = js.Browser.window.location;

                var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+reportFile;

                var webPage : WebPage = new WebPage();
                webPage.setURL(dstURL);

                var w0 : WebPageWorkspaceObject = new WebPageWorkspaceObject(webPage, blastName);

                //getApplication().getWorkspace().addObject(w0,true);

                getApplication().getWorkspace()._addObject(w0, true, true, 'BLAST');
            }else{
                getApplication().showMessage('BLAST Error', error);
            }
        });
    }

    public function inverseComplement(){
        var dnaObj = new DNA(sequence);
        blockChanged(null, null, 0, null, dnaObj.getInverseComplement());
    }

    public function complement(){
        var dnaObj = new DNA(sequence);
        blockChanged(null, null, 0, null, dnaObj.getComplement());
    }

    public function inverse(){
        var dnaObj = new DNA(sequence);
        blockChanged(null, null, 0, null, dnaObj.getInverse());
    }

    override public function getNewMoleculeInstance(){
        return new DNA(sequence);
    }
    
    override
    public function onBlur(){
        super.onBlur();
        
        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();
        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
    }
	
	function installOutlineTree() {
        getApplication().installOutlineTree('DEFAULT', true, false, null);

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
		
		var folderNames : Array<String> = ['Current', 'Selected'];

        Ext.suspendLayouts();
		
		for(folderName in folderNames){
			var gcContentStr : String = "0";
			var dnaNucCountStr : String = "0";
        
			var currentStats : Dynamic = rootNode.appendChild({
				text : folderName,
				leaf : false,
				expanded : true,
				id : folderName
			});
        
			var gcContentItem = currentStats.appendChild({
				text : "% GC : "+gcContentStr,
				leaf : true,
				id : folderName + " : GC"
			});
        
			var nucContentItem = currentStats.appendChild({
				text : "Length : "+dnaNucCountStr,
				leaf : true,
				id : folderName + " : Length"
			});

            if(folderName == 'Selected'){
                var nucContentItem = currentStats.appendChild({
				    text : "Melting Temp : ",
				    leaf : true,
				    id : folderName + " : Melting Temp"
			    });
            }
		}

        Ext.resumeLayouts(true);
	}
    
    override
    function blockChanged(textField : Dynamic, blockNumber : Int, startDelPosition : Int, endDelPosition : Int, newSequence : String){ 
        super.blockChanged(textField, blockNumber, startDelPosition, endDelPosition, newSequence);
    }
    
    override
    function selectionUpdated(){
        super.selectionUpdated();
    }

    override function getSequenceEditorBlock(blockNumber : Int, editor : SequenceEditor)  : SequenceEditorBlock{
        return new DNASequenceEditorBlock(blockNumber, editor);
    }
    
    function updateStatsPanel(folderName : String, dnaObj : DNA){
        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();
        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var gcContentStr : String = "0";
        var dnaNucCountStr : String = "0";
        var meltingTempStr : String = "0";
        if(dnaObj!=null){
            var gcContent : Float = dnaObj.getGCFraction();
            gcContentStr = Std.string(MathUtils.sigFigs(gcContent * 100, 2));
			
			if (gcContentStr == "NaN") {
				gcContentStr = "0";
			}
            
            dnaNucCountStr = ""+dnaObj.getLength();    

            if (folderName == 'Selected') {
                meltingTempStr = ""+MathUtils.sigFigs(tmCalcEngine.tmCalculation(dnaObj, 50, 300), 2);
            }
        }
		
		var node : Dynamic = dataStore.getNodeById(folderName + " : Length");

        if(node !=null){
		    node.set('text',"Length : "+dnaNucCountStr);
		    node.commit();
		
		    node = dataStore.getNodeById(folderName + " : GC");
		    node.set('text', "% GC : " + gcContentStr);
		    node.commit();

            if(folderName == 'Selected'){
                var node : Dynamic = dataStore.getNodeById(folderName + " : Melting Temp");

    		    node.set('text',"Melting Temp : "+meltingTempStr);
	    	    node.commit();
            }
        }
    }
    
    override
    function updateOutline(){
        super.updateOutline();
       
        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();
        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
        
        var dnaObj : Dynamic = null;
        
        if(sequence!=null && sequence!=""){
            //dnaObj = new DNA(sequence);
			var wO : DNAWorkspaceObject<DNA> = getActiveObject(DNAWorkspaceObject);
			if (wO == null) {
				dnaObj = new DNA('');
			}else{
                if(Std.is(wO, saturn.core.DNA)){
                    dnaObj = wO;
                }else{
                    dnaObj = wO.getDNAObject();
                }
			}
        }
       
        updateStatsPanel('Current', dnaObj);
		
        if(inMouseMove || lastWasMouseMoved ){
			//selection can only have changed in response to a mouse move event

            var subSeq : String;
            if(this.getSelectableRow() != -1){
                subSeq = "";
            }else{
    			subSeq = getSelectedSequence();
            }

			if (subSeq != null) {
				if (inMouseMove == false) {
					subSeq = "";
				}
            }else {
				subSeq = "";
			}
			
			dnaObj= new DNA(subSeq);
			
            updateStatsPanel('Selected', dnaObj);
			
			if (inMouseMove) {
				lastWasMouseMoved = true;
			}else {
				lastWasMouseMoved = false;
			}
        }
    }
	
	static var reg_replaceStar : EReg = ~/\*/;
	
	override
	public function openFile(file : Dynamic, asNew : Bool, ?asNewOpenProgram :Bool = true) : Void {
        var extension = CommonCore.getFileExtension(file.name);
        if(extension == 'ab1'){
           // processABIFile(file);
        }else{
            if(asNew){
                parseFile(file, null, asNewOpenProgram);
            }else {
                parseFile(file, function(objs){
                    if(objs.length > 0 ){
                        blockChanged(null, null, 0, null, objs[0].getSequence());

                        getWorkspace().renameWorkspaceObject(this.getActiveObjectId(), objs[0].getName());
                    }
                });
            }
        }
	}

    public static function processABIFile(base64 : String, load: Bool, ?cb=null){
        BioinformaticsServicesClient.getClient().sendABIReportRequest(base64, function(data : Dynamic, error : String){
            var obj = Json.parse(data);
            js.Browser.alert('hello');
        });
    }

    public static function parseFile(file : Dynamic, ?cb=null, ?asNewOpenProgram : Bool = true){
        var load = cb == null ? true : false;

        var extension = CommonCore.getFileExtension(file.name);
        if(extension == 'ab1'){
            CommonCore.getFileAsArrayBuffer(file, function(content : ArrayBuffer){
                var base64 = CommonCore.convertArrayBufferToBase64(content);

                processABIFile(base64, load, cb);
            });

            //processABIFile(file, cb);
            //return;
        }else{
            CommonCore.getFileAsText(file,function(content : String){
                var objs = null;

                if(extension == 'fasta'){
                    objs = parseFastaString(content, load, asNewOpenProgram);
                }else if(extension == 'seq'){
                    objs = parseSequenceString(content, file.name, load, asNewOpenProgram);
                }

                if(cb != null && objs != null){
                    cb(objs);
                }
            });
        }
    }

    public static function parseSequenceString(contents, name : String,  ?load=false, ?asNewOpenProgram : Bool = true) : Array<FastaEntity>{
        var seqObjs : Array<FastaEntity> = new Array<FastaEntity>();

        seqObjs.push(new FastaEntity(name, contents));

        if(load){
            loadFastaEntitiesIntoWorkspace(seqObjs, asNewOpenProgram);
        }

        return seqObjs;
    }

    public static function parseFastaString(contents, ?load=false, ?asNewOpenProgram : Bool = true) : Array<FastaEntity>{
        var headerPattern1 = ~/^>(.+)/;

        var seqObjs : Array<FastaEntity> = new Array<FastaEntity>();

        var currentName : String = null;
        var currentSeqBuf : StringBuf = new StringBuf();
        var lines : Array<String> = contents.split("\n");

        if(lines.length == 1){
            lines = contents.split(' ');
        }

        var numLines = lines.length;

        var app : WorkspaceApplication = WorkspaceApplication.getApplication();

        app.printInfo("Lines: "+numLines);

        for(i in 0...numLines){
            var seqLine : Bool = true;

            var line : String = lines[i];
            if(headerPattern1.match(line)){
                seqLine = false;
            }

            if(seqLine == true){
                currentSeqBuf.add(line);
            }

            if(seqLine == false || i == numLines - 1 ){
                if(currentName != null){
                    var currentSeq : String = currentSeqBuf.toString();
                    if(currentSeq.length > 0){
                        seqObjs.push(new FastaEntity(currentName, currentSeq));

                        currentSeqBuf = new StringBuf();
                    }
                }

                if(seqLine == false){
                    currentName  = headerPattern1.matched(1);
                }
            }
        }

        if(load){
            loadFastaEntitiesIntoWorkspace(seqObjs, asNewOpenProgram);
        }

        return seqObjs;
    }

    public static function loadFastaEntitiesIntoWorkspace(seqObjs : Array<FastaEntity>, ?asNewOpenProgram : Bool = true){
        var workspace = WorkspaceApplication.getApplication().getWorkspace();

        //var open = true;

        WorkspaceApplication.getApplication().getWorkspace().beginUpdate();

        for (seqObj in seqObjs) {
            var isDNA = true;

            var sequence : String = seqObj.getSequence();

            var dnaObj = new DNA(sequence); //clean of whitespace etc
            sequence = dnaObj.getSequence();

            var sLen = sequence.length;

            if (sLen > 20) {
                sLen = 20;
            }

            for ( i in 0...sLen) {
                switch( sequence.charAt(i) ) {
                    case 'A', 'T', 'C', 'G', 'N', 'X':
                        isDNA;
                    default:
                        isDNA = false;
                }
            }

            if(isDNA){
                workspace._addObject(new DNAWorkspaceObject(dnaObj, seqObj.getName()), asNewOpenProgram, false);
            }else {
                workspace._addObject(new ProteinWorkspaceObject(new Protein(sequence), seqObj.getName()), asNewOpenProgram, false);
            }

            asNewOpenProgram = false;

            //open = false;
        }

        //Ext.resumeLayouts(true);

        workspace.reloadWorkspace();
    }

	public function sequenceChanged(sequence : String) {
        if(!this.hasAnnotationsOn()) return ;

		var dnaObj : DNA = new DNA(sequence);

		if(sequence.length>2){
            var dnaObjs = [dnaObj, new DNA(dnaObj.getInverseComplement())];

            var annotationPos : Int = 0;
            for(j in 0...dnaObjs.length){

                dnaObj = dnaObjs[j];

                for(i in 0...3){
                    var seqLen : Int = dnaObj.getLength() - i;

                    var translation : String = dnaObj.getTranslation(GeneticCodes.STANDARD, i,false);

                    var transSpacer : StringBuf = new StringBuf();
    
                    if(j==0){
                        transSpacer.add(StringUtils.getRepeat(" ",i+1)+translation.charAt(0));
                    }else{ 
                        translation = StringUtils.reverse(translation);
                        transSpacer.add(StringUtils.getRepeat(" ", (seqLen%3)+1)+translation.charAt(0));
                    }

                    var defaultSpace: String = StringUtils.getRepeat(" ", 2);

                    for(i in 1...translation.length){
                        transSpacer.add(defaultSpace+translation.charAt(i));
                    }

			        setAnnotationSequence(annotationPos, transSpacer.toString());
                    annotationPos++;
                }
            }
		}else {
			setAnnotationSequence(0, "");
            setAnnotationSequence(1, "");
            setAnnotationSequence(2, "");
		}
	}

    override public function getSelectedRegion() : SequenceRegion {
        var region : SequenceRegion  = super.getSelectedRegion();
        
        if(region == null){
            return region;
        }

        var dnaFrame : Int = region.getSelectedRow();    

        if(dnaFrame > -1){
            var dnaPStart : Int = region.getStartPosition();
            var dnaPStop : Int = region.getStopPosition();

            var annotationSequence : String = annotationSequences[dnaFrame];

            var annotationSelectedSequence : String = annotationSequence.substring(dnaPStart, dnaPStop);

            annotationSelectedSequence = StringTools.replace(annotationSelectedSequence, " ", "");

            if(annotationSelectedSequence.length > 0){
                var annotationBeforeSelectedSequence : String;
                if(dnaFrame < 3){
                    annotationBeforeSelectedSequence = annotationSequence.substring(0, dnaPStart);
                }else{
                    annotationBeforeSelectedSequence = annotationSequence.substring(dnaPStop + 1, annotationSequence.length);
                }

                annotationBeforeSelectedSequence = StringTools.replace(annotationBeforeSelectedSequence, " ", "");

                var beforeLength : Int = annotationBeforeSelectedSequence.length;

                var startPosition : Int = beforeLength + 1;

                var endPosition : Int = beforeLength + annotationSelectedSequence.length;

                region.setAnnotationStartPosition(startPosition+frameOffSet);
                region.setAnnotationStopPosition(endPosition+frameOffSet);
                region.setAnnotationSequence(annotationSelectedSequence);
            }

            if(dnaFrame > 2){
                var seqLen = sequence.length;

                var startPos = seqLen - region.getStopPosition();
                var stopPos = seqLen - region.getStartPosition();

                region.setStartPosition(startPos+offSet);
                region.setStopPosition(stopPos+offSet);

                region.setIsForward(false);
           }else{
                region.setIsForward(true);
           }
        }else{
            region.setIsForward(true);
        }

        return region;
    }

    override
    public function serialise() : Dynamic {
        var object : Dynamic = super.serialise();

        object.FRAME_OFFSET = frameOffSet;

        return object;
	}
	
    override
	public function deserialise(object : Dynamic) : Void {
        super.deserialise(object);

        frameOffSet = object.FRAME_OFFSET;
	}

    override public function normaliseSequence(sequence : String) : String{


        return super.normaliseSequence(sequence);
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-dna',
                html:'DNA<br/>Editor',
                cls: 'quickLaunchButton',
                handler: function(){
                    var dna = new DNA("");
                    dna.setMoleculeName("DNA");

                    WorkspaceApplication.getApplication().getWorkspace().addObject(dna, true);
                },
                tooltip: {dismissDelay: 10000, text: 'Editor for DNA sequences.<br/>Supports annotations and submission to BLAST.'}
            }
        ];
    }
    
    override public function getWorkspaceContextMenuItems() : Array<Dynamic>{
        var items = new Array<Dynamic>();

        var obj = getEntity();
        if(Std.is(obj, saturn.core.DNA)){
            var d = cast(obj, saturn.core.DNA);

            if(!d.isLinked()){
                var proteinItems  = getWorkspace().getObjectsByClass(saturn.core.Protein);
                //var oldProteinItems : Array<Dynamic>= getWorkspace().getAllObjects(ProteinWorkspaceObject);

                var attachItems = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0'});

                for(protObj in proteinItems){
                    if(!protObj.isLinked()){
                        attachItems.add({
                            text: protObj.getName(),
                            handler : function(){
                                //d.setProtein(protObj);
                            }
                        });
                    }
                }

                items.push({
                    text: 'Attach Protein',
                    menu: attachItems
                });
            }else{
                items.push({
                    text: 'Deattach Protein',
                    handler: function(){
                        obj.setProtein(null);
                    }
                });
            }
        }

        return items;
    }

    override public function changeObjectType(model : Model) : Dynamic{
        var newObj = super.changeObjectType(model);
        var object = getObject();

        if(getObject().isLinked()){
            newObj.setProtein(object.getProtein());
        }

        newObj.setSequence(getSequence());

        return newObj;
    }
}
