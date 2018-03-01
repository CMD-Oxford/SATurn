/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Stephen Joyce <stephen.joyce@ndorms.ox.ac.uk, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.ConstructDesignTable;
import saturn.app.SaturnClient;
import saturn.util.HaxeException;
import saturn.client.programs.sequenceeditor.SequenceEditorBlock;
import saturn.client.programs.sequenceeditor.SequenceEditor.SequenceChangeListener;
import saturn.client.workspace.Workspace;
import saturn.core.Protein;
import saturn.core.DNA;

import saturn.util.MathUtils;
import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.client.workspace.DNAWorkspaceObject;
import js.Lib;

import saturn.client.workspace.Workspace.WorkspaceObject;

import saturn.client.WorkspaceApplication;
import saturn.client.ProgramRegistry;
import saturn.client.programs.sequenceeditor.SequenceEditor;
import saturn.util.StringUtils;

import saturn.client.workspace.WebPage;
import saturn.client.workspace.WebPageWorkspaceObject;
import saturn.client.workspace.Workspace;

import saturn.core.FastaEntity;
import saturn.core.PDBParser;

import bindings.Ext;

class ProteinSequenceEditor implements SequenceChangeListener extends SequenceEditor{
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ ProteinWorkspaceObject ];
	
    var selectedStatsFolder : Dynamic;
	
	var lastWasMouseMoved : Bool;
    var frameOffSet : Int;
    
    public function new( delayLoad : Bool ){
        super();
    } 
	
	override
	public function emptyInit() {
		super.emptyInit();

        frameOffSet = 0;

		selectedStatsFolder = null;
		
		lastWasMouseMoved = false;
		
		setAnnotationCount(0);
		
		addSequenceChangeListener(this);
	}
    
	override
	public function setActiveObject(objectId : String) {
		super.setActiveObject(objectId);

        var proteinObject : Dynamic = getActiveObject(ProteinWorkspaceObject);

        var object : Protein;
        if(Std.is(proteinObject, saturn.core.Protein)){
            object = proteinObject;
        }else{
            object = proteinObject.object;
        }

        var sequence : String = object.getSequence();

        blockChanged(null, null, 0, null, sequence);
    }
	
    override
    public function onFocus(){
        super.onFocus();
    
        var self : ProteinSequenceEditor = this;

        var viewMenu :Dynamic = getApplication().getViewMenu();

        var toolsMenu = getApplication().getToolsMenu();

        var blastMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        toolsMenu.add({
            text:'BLAST',
            iconCls: 'bmenu',  // <-- icon
            menu: blastMenu, // assign menu by instance
            cls:'menu-item-FILE'
        });

        var blastItems = [];
        var blastDatabases = BioinformaticsServicesClient.getClient(null).getBlastList().PROT;
        for(dbName in Reflect.fields(blastDatabases)){
            var blastItem = blastMenu.add({
            text:dbName,
            hidden : false,
            handler: function(){
                var blastName = 'Blastp '+getActiveObject(ProteinWorkspaceObject).getName()+' 1 - '+self.sequence.length;

                self.blastSequence(self.sequence, dbName, blastName);
            }
            });

            blastItems.push({
                text:dbName,
                hidden : false,
                handler: function(){
                    var blastName = 'Blastp '+getActiveObject(ProteinWorkspaceObject).getName()+' 1 - '+self.sequence.length;

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
            menu:  Ext.create('Ext.menu.Menu',{
                items: blastItems
            }),
            iconCls :'x-btn-blast',
            cls: 'x-btn-split-black-background',
            tooltip: {dismissDelay: 10000, text: 'BLAST against a sequence database'}
        });

        getApplication().getToolBar().add(blastButton);

        viewMenu.add({
            text : 'Domain report',
            handler : function(){
                var name = 'PSIPred '+getActiveObject(ProteinWorkspaceObject).getName()+' 1 - '+self.sequence.length;
                psiPredSequence(sequence, name);
            }
        });

        viewMenu.add({
            text : 'Transmembrane Report',
            handler : function(){
                var name = 'TMHMM '+getActiveObject(ProteinWorkspaceObject).getName()+' 1 - '+self.sequence.length;
                tmhmmSequence(sequence, name);
            }
        });

		installOutlineTree();
		
        updateOutline();

        getApplication().getExportMenu().add({
            text: "FASTA",
            handler: function(){
                var name = getActiveObjectName();

                name = StringTools.replace(name, ' (Protein)', '');

                var contents = FastaEntity.formatFastaFile(name, getSequence());

                getApplication().saveTextFile(contents, name + '.fasta');
            }
        });

        var fetchItems = [];

        fetchItems.push({
            text: 'NCBI Gene',
            hidden : false,
            handler: function(){
                var idStr = getLastSearch();

                var ids :Array<String> = null;

                if(idStr.indexOf(',') > -1){
                    ids = idStr.split(',');
                }else{
                    ids = [idStr];
                }

                SaturnClient.addProteinsFromNCBIGene(ids, this);
            }
        });

        fetchItems.push({
            text: 'UniProtKB',
            hidden : false,
            handler: function(){
                var idStr = getLastSearch();

                var ids :Array<String> = null;

                if(idStr.indexOf(',') > -1){
                    ids = idStr.split(',');
                }else{
                    ids = [idStr];
                }

                SaturnClient.addProteinsFromUniProtKB(ids, this);
            }
        });

        var fetchButton = Ext.create('Ext.button.Button', {
            renderTo: Ext.getBody(),
            text: 'Fetch',
            handler: function() {
                //
            },
            menu:  Ext.create('Ext.menu.Menu',{
                items: fetchItems
            }),
            iconCls :'x-btn-fetch',
            cls: 'x-btn-split-black-background',
            tooltip: {dismissDelay: 10000, text: 'Fetch from remote database'}
        });

        getApplication().getToolBar().add(fetchButton);

        getApplication().getToolBar().add({
            text: 'Load DNA',
            handler: function(){
                loadDNA();
            }
        });
    }

    public function loadDNA(){
        var object = getObject();

        if(object != null){
            var dna = getObject().getDNA();

            getWorkspace().addObject(dna, true);
        }
    }

    public function getAddToPlateContextMenu(name : String, start : Int, stop : Int){
        var addPlateMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0'});

        if(name == null){
            var obj :Dynamic = getWorkspaceObject();

            if(obj.getDNA() != null){
                obj = obj.getDNA();
            }

            name = obj.getName();
        }

        var objs :Array<Dynamic>= getWorkspace().getAllObjects(ConstructDesignTable);
        for(obj in objs){
            addPlateMenu.add({
                text: obj.getName(),
                handler: function(){
                    var objectId = obj.getUUID();

                    var prog = getWorkspace().getProgramForObject(objectId);

                    if(prog != null){
                        var constructDesigner = cast(prog, ConstructDesigner);

                        constructDesigner.getTable().addRow({
                            'Entry Clone': name,
                            'Start position': start,
                            'Stop position': stop
                        });

                        getWorkspace().setActiveObject(objectId);
                    }
                }
            });
        }

        addPlateMenu.add({
            text: 'New plate',
            handler: function(){
                var table = new ConstructDesignTable(false);
                table.getData().push({
                    'Entry Clone': name,
                    'Start position': start,
                    'Stop position': stop
                });

                getWorkspace().addObject(table, true);
            }
        });

        return addPlateMenu;
    }

    override public function updateModelField(obj : Dynamic, field : String, value : String){
        var p = cast(getObject(), Protein);
        if(p.isLinked()){
            if(p.linkedOriginField == field){
                super.updateModelField(obj, field, getSequence());
                return;
            }
        }

        super.updateModelField(obj, field, value);
    }

    override public function getWorkspaceContextMenuItems() : Array<Dynamic>{
        var items = new Array<Dynamic>();

        var obj = getEntity();
        if(Std.is(obj, Protein)){
            var p = cast(obj, Protein);

            if(!p.isLinked()){
                var dnaItems  = getWorkspace().getObjectsByClass(saturn.core.DNA);
                //var oldDNAItems : Array<Dynamic>= getWorkspace().getAllObjects(DNAWorkspaceObject);

                var attachItems = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0'});

                for(dnaObj in dnaItems){
                    if(!dnaObj.isLinked()){
                        attachItems.add({
                            text: dnaObj.getName(),
                            handler : function(){
                                p.setDNA(dnaObj);
                            }
                        });
                    }
                }

                items.push({
                    text: 'Attach DNA',
                    menu: attachItems
                });
            }else{
                items.push({
                    text: 'Deattach DNA',
                    handler: function(){
                        obj.setDNA(null);
                    }
                });
            }
        }

        return items;
    }

    public function setFrameOffSet(offSet : Int){
        frameOffSet = offSet;
    }

    public function psiPredSequence(theSequence : String, name : String){
        BioinformaticsServicesClient.getClient().sendPsiPredReportRequest(theSequence, name, function(response,error){
            if(error == null){
                var htmlReportFile = response.json.htmlPsiPredReport;
                var location : js.html.Location = js.Browser.window.location;

                var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+htmlReportFile;

                var webPage : WebPage = new WebPage();
                webPage.setURL(dstURL);

                var w0 : WebPageWorkspaceObject = new WebPageWorkspaceObject(webPage, name);

                getApplication().getWorkspace().addObject(w0,true);
            }else{
                getApplication().showMessage('PSIPred Error', error);
            }
        });
    }

    public function tmhmmSequence(theSequence : String, name : String){
        BioinformaticsServicesClient.getClient().sendTMHMMReportRequest(theSequence, name, function(response,error){
            if(error == null){
                var htmlReportFile = response.json.htmlTMHMMReport;
                var location : js.html.Location = js.Browser.window.location;

                var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+htmlReportFile;

                var webPage : WebPage = new WebPage();
                webPage.setURL(dstURL);

                var w0 : WebPageWorkspaceObject = new WebPageWorkspaceObject(webPage, name);

                getApplication().getWorkspace().addObject(w0,true);
            }else{
                getApplication().showMessage('TMHMM Error', error);
            }
        });
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

                js.Browser.window.console.log('Gekk');

                getApplication().getWorkspace()._addObject(w0, true, true, 'BLAST');
            }else{
                getApplication().showMessage('BLAST Error', error);
            }
        });
    }
    
    override
    public function onBlur(){
        super.onBlur();
        
        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();
        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
    }
	
	function installOutlineTree() {
        getApplication().installOutlineTree('DEFAULT', false, false, null);

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
		
		var folderNames : Array<String> = ['Current', 'Selected'];

        Ext.suspendLayouts();
		
		for(folderName in folderNames){
			var gcContentStr : String = "0";
			var dnaNucCountStr : String = "0";
            var mw : String = "0";
        
			var currentStats : Dynamic = rootNode.appendChild({
				text : folderName,
				leaf : false,
				expanded : true,
				id : folderName
			});
        
			var lenNode = currentStats.appendChild({
				text : "Length : "+dnaNucCountStr,
				leaf : true,
				id : folderName + " : Length"
			});

            var mwNode = currentStats.appendChild({
                text : "MW : "+mw,
                leaf : true,
                id : folderName + " : MW"
            });

            currentStats.appendChild({
                text : "HP : ",
                leaf : true,
                id : folderName + " : HP"
            });

            currentStats.appendChild({
                text : "pI : ",
                leaf : true,
                id : folderName + " : pI"
            });

            currentStats.appendChild({
                text : "E (R) : ",
                leaf : true,
                id : folderName + " : E (R)",
            });

            currentStats.appendChild({
                text : "E (NR) : ",
                leaf : true,
                id : folderName + " : E (NR)",
            });
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
        
        //updateOutline();
    }
    
    override
    function updateOutline(){
        super.updateOutline();

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');

        var node : Dynamic = dataStore.getNodeById('Current' + " : Length");

        if(node !=null && sequence != null){
            node.set('text',"Length : "+sequence.length);
            node.commit();

            node  = dataStore.getNodeById('Current' + " : MW");

            if(node != null){
                var mw = 0.;
                if(sequence.length > 0){
                    mw = MathUtils.sigFigs(new Protein(sequence).getMW(),2);
                }

                node.set('text',"MW : "+mw);
                node.commit();
            }

            node  = dataStore.getNodeById('Current' + " : HP");
            if(node != null){


                var hp = 0.;
                if(sequence.length > 0){
                    hp = MathUtils.sigFigs(new Protein(sequence).getHydrophobicity(),2);
                }

                node.set('text',"HP : "+hp);
                node.commit();
            }

            node  = dataStore.getNodeById('Current' + " : pI");
            if(node != null){
                var pI = 0.;
                if(sequence.length > 0){
                    pI = MathUtils.sigFigs(new Protein(sequence).getpI(),2);
                }

                node.set('text',"pI : "+pI);
                node.commit();
            }

            node  = dataStore.getNodeById('Current' + " : E (R)");
            if(node != null){
                var E = 0.;
                if(sequence.length > 0){
                    E = MathUtils.sigFigs(new Protein(sequence).getExtinctionReduced(),2);
                }

                node.set('text',"E (R): "+E);
                node.commit();
            }

            node  = dataStore.getNodeById('Current' + " : E (NR)");
            if(node != null){
                var E = 0.;
                if(sequence.length > 0){
                    E = MathUtils.sigFigs(new Protein(sequence).getExtinctionNonReduced(),2);
                }

                node.set('text',"E (NR): "+E);
                node.commit();
            }
        }

        node = dataStore.getNodeById('Selected' + " : Length");

        if(node !=null){
            var sel = this.getSelectedRegion();
            if(sel != null){
                var selSeq = sel.getSequence();

                if(selSeq != null){
                    node.set('text',"Length : "+selSeq.length);
                    node.commit();

                    node  = dataStore.getNodeById('Selected' + " : MW");

                    var mw = 0.;
                    if(selSeq.length > 0){
                        mw = MathUtils.sigFigs(new Protein(selSeq).getMW(),2);
                    }

                    node.set('text',"MW : "+mw);
                    node.commit();

                    node  = dataStore.getNodeById('Selected' + " : HP");

                    var hp = 0.;
                    if(selSeq.length > 0){
                        hp = MathUtils.sigFigs(new Protein(selSeq).getHydrophobicity(),2);
                    }

                    node.set('text',"HP : "+hp);
                    node.commit();

                    node  = dataStore.getNodeById('Selected' + " : pI");

                    var pI = 0.;
                    if(selSeq.length > 0){
                        pI = MathUtils.sigFigs(new Protein(selSeq).getpI(),2);
                    }

                    node.set('text',"pI : "+pI);
                    node.commit();

                    node  = dataStore.getNodeById('Selected' + " : E (R)");

                    var E = 0.;
                    if(selSeq.length > 0){
                        E = MathUtils.sigFigs(new Protein(selSeq).getExtinctionReduced(),2);
                    }

                    node.set('text',"E (R): "+E);
                    node.commit();

                    node  = dataStore.getNodeById('Selected' + " : E (NR)");

                    var E = 0.;
                    if(selSeq.length > 0){
                        E = MathUtils.sigFigs(new Protein(selSeq).getExtinctionNonReduced(),2);
                    }

                    node.set('text',"E (NR): "+E);
                    node.commit();
                }
            }
        }
    }
	
	override
	public function openFile(file : Dynamic, asNew : Bool, ?asNewOpenProgram : Bool = true) : Void {
		if(asNew){
            var workspace : Workspace = getWorkspace();

			readFastaFile(file, Ext.bind(function(seqObjs : Array<FastaEntity>) {
				var openTabs = true;
				
				/*
				 * http://www.sencha.com/blog/optimizing-ext-js-4-1-based-applications/
				 * 
				 * Read once, twice, then once a week!
				 * 
				 * Suspending layout updates signficantly improves the speed of adding sequences
				 */
				
				WorkspaceApplication.suspendUpdates();
    
                for (seqObj in seqObjs) {
					var w0 : WorkspaceObject<Dynamic>;
					if ( seqObj.guessType() == FastaEntryType.DNA ) {
						w0 = new DNAWorkspaceObject(new DNA(seqObj.getSequence()), seqObj.getName());
					}else if (seqObj.guessType() == FastaEntryType.PROTEIN) {
						w0 = new ProteinWorkspaceObject(new Protein(seqObj.getSequence()), seqObj.getName());
					}else {
						throw new HaxeException('Unsupported FASTA file');
					}

                    workspace.addObject(w0, openTabs);
					
					openTabs = false;
                }
				
				WorkspaceApplication.resumeUpdates(true);
			}, this));
		}else {
			openFastaFile(file);
		}
	}

    public function openFastaFile(file : Dynamic) {		
		readFastaFile(file, Ext.bind(function(seqObjs : Array<FastaEntity>) {
            
            if(seqObjs.length > 0 ){
                blockChanged(null, null, 0, null, seqObjs[0].getSequence()); 

                getWorkspace().renameWorkspaceObject(this.getActiveObjectId(), seqObjs[0].getName());
            }
		},this));
	}
	
	public static function readFastaFile(file : Dynamic, onLoad) {
		var fileReader : Dynamic = untyped __js__('new FileReader()');
		
        fileReader.onload = function(e) {
			var contents : String = e.target.result;

			var fileName : String = file.name;
			
			var seqObjs : Array<FastaEntity> = null;
			
			if(StringTools.endsWith(fileName, '.fasta')){
				seqObjs = FastaEntity.parseFasta(contents);
			}else if (StringTools.endsWith(fileName, '.pdb')) {
				var pdbCode : String = PDBParser.extractPDBID(fileName);
				
				seqObjs = PDBParser.getSequences(contents, pdbCode, null);
			}else {
				Ext.Msg.alert("", "Unknown file format");
				return;
			}

            if(seqObjs == null || seqObjs.length == 0){
                Ext.Msg.alert("","No sequences found in FASTA file");
            }

            onLoad(seqObjs); 
        };
                    
        fileReader.readAsText(file);
	}

	public function sequenceChanged(sequence : String) {
        
	}

    override public function getSelectedRegion() : SequenceRegion {
        var region : SequenceRegion  = super.getSelectedRegion();
        

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

    override public function getNewMoleculeInstance(){
        return new Protein(sequence);
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-structure',
                html:'Protein<br/>Editor',
                cls: 'quickLaunchButton',
                handler: function(){
                    var prot = new Protein("");
                    prot.setMoleculeName("Protein");
                    WorkspaceApplication.getApplication().getWorkspace().addObject(prot, true);
                },
                tooltip: {dismissDelay: 10000, text: 'Editor for protein sequences.<br/>Supports annotations and submission to BLAST.'}
            }
        ];
    }

    override function getSequenceEditorBlock(blockNumber : Int, editor : SequenceEditor)  : SequenceEditorBlock{
        return new ProteinSequenceEditorBlock(blockNumber, editor);
    }
}

enum BlastDatabase{
   Constructs_DNA;
   Constructs_Protein;
}


