/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import js.Lib;
import saturn.core.PCRProduct;
import saturn.core.Primer;
import saturn.core.DNA;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.PCRProductWO;
import saturn.client.workspace.PrimerWorkspaceObject;
import saturn.util.StringUtils;

import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.WorkspaceApplication;

import bindings.Ext;

import saturn.client.workspace.AlleleWO;

class AlleleViewer extends PCRProductViewer {
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ AlleleWO ];
	
	var plateWindowActive : Bool;
	var wellWindowActive : Bool;
	var elnWindowActive : Bool;
	var statusWindowActive : Bool;
	
    public function new(){
        super();
    } 
	
	override public function emptyInit() {
		plateWindowActive = false;
		wellWindowActive = false;
		elnWindowActive = false;
		statusWindowActive = false;
		
		super.emptyInit();
		
		getWorkspace().addListener(this);
	}
    
    override public function onFocus(){
        super.onFocus();
		
		var app  = WorkspaceApplication.getApplication();
		app.getFileMenu().add({
            text : 'Save Allele',
            handler : function(){
				var wO : PCRProductWO<PCRProduct> = getActiveObject(PCRProductWO);
				
				var seq : String = getSequence();
				
				var dnaObj : DNA = new DNA(seq);
				
				var startPosition = dnaObj.getFirstStartCodonPositionByFrame(GeneticCodes.STANDARD, Frame.ONE);
				var stopPositions : List<Int> = dnaObj.getStopCodonPositions(GeneticCodes.STANDARD, Frame.ONE, false);
				
				var stopPosition : Int = null;
				
				for (stopPos in stopPositions) {
					if (stopPos > startPosition) {
						stopPosition = stopPos;
					}
				}
				
				if (stopPosition == null) {
					stopPosition = seq.length;
				}
				
				dnaObj = new DNA(seq.substring(startPosition, stopPosition));
				
				var proteinSeq = dnaObj.getTranslation(GeneticCodes.STANDARD,0, true);
				
				var workspace : Workspace = app.getWorkspace();
				
				var fPrimerWO : PrimerWorkspaceObject<Primer> = workspace.getObjectSafely(wO.getForwardPrimerId(), PrimerWorkspaceObject);
				
				var fSequence = fPrimerWO.getPrimer().getSequence();
				var fName = fPrimerWO.getName();
				
				var rPrimerWO : PrimerWorkspaceObject<Primer> = workspace.getObjectSafely(wO.getReversePrimerId(), PrimerWorkspaceObject);
				
				var rSequence = rPrimerWO.getPrimer().getSequence();
				var rName = rPrimerWO.getName();
				
				var dataStore :Dynamic = app.getOutlineDataStore('DEFAULT');
        
				var rootNode : Dynamic = dataStore.getRootNode();
					
				var elnId = dataStore.getNodeById('ELN_ID').get('ELN_ID');
				var plate = dataStore.getNodeById('ALLELE_PLATE').get('PLATE');
				var well = dataStore.getNodeById('WELL_LOCATION').get('WELL');
				var status = dataStore.getNodeById('STATUS').get('STATUS');
				
				var entryCloneWO : DNAWorkspaceObject<DNA> = workspace.getObjectSafely(wO.getTemplateId(), DNAWorkspaceObject);
				
				var json = { 
					ALLELE_ID : wO.getName(),
					SEQ:seq, 
					FSEQ:fSequence, 
					FNAME:fName, 
					RSEQ:rSequence, 
					RNAME:rName, 
					ELN: elnId, 
					PLATE:plate, 
					WELL: well, 
					STATUS: status ,
					PROTSEQ: proteinSeq,
					ENTRY_CLONE : entryCloneWO.getName()
				};
				
				var client : ICMClient = ICMClient.getClient();
				client.runCommand(
					'JSON_STR=\'' + JSON.stringify(json) + '\'\n' +
					'delete JSON_OBJ\n' + 
					'read json input=JSON_STR name="JSON_OBJ"\n' +
					'sgc.Allele.mInsertAllele(JSON_OBJ)\n',
					function(data) {
					
					}
				);
            }
        });
    }

    override public function serialise() : Dynamic {
        var object : Dynamic = super.serialise();

        return object;
	}
	
    override public function deserialise(object : Dynamic) : Void {
        super.deserialise(object);
	}
	
	override function installOutlineTree() {
        super.installOutlineTree();

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
		
		rootNode.appendChild( {
				text : 'Plate: ',
				leaf : true,
				expanded : true,
				id : 'ALLELE_PLATE'
		});
		
		rootNode.appendChild( {
			text : 'Well: ',
			leaf : true,
			expanded : true,
			id : 'WELL_LOCATION'
		});
		
		rootNode.appendChild( {
			text : 'ELN: ',
			leaf : true,
			expanded : true,
			id : 'ELN_ID'
		});
		
		rootNode.appendChild( {
			text : 'STATUS: ',
			leaf : true,
			expanded : true,
			id : 'STATUS'
		});
	}
	
	override public function onClick(view, rec, item, index) : Void {
		if (rec.data.id == 'ALLELE_PLATE') {
			if (plateWindowActive == false) {
				plateWindowActive = true;
				
				try{
					var client : ICMClient = ICMClient.getClient();
					client.runCommand(	
						'params = Collection();\n'+
						'params[\'IDS\']=sgc.AllelePlate.mGetPlateIds();\n', 
						function(data) {
							showPlateSelectionDialog(data.IDS);					  
						}
					);
				}catch (ex : Dynamic) {
					plateWindowActive = false;
					
					throw ex;
				}
			}
		}else if (rec.data.id == 'WELL_LOCATION') {
			if (wellWindowActive == false) {
				wellWindowActive = true;
				try{
					showWellLocationDialog();
				}catch (ex : Dynamic) {
					wellWindowActive = false;
					
					throw ex;
				}
			}
		}else if (rec.data.id == 'ELN_ID') {
			if (elnWindowActive == false) {
				elnWindowActive = true;
				
				try {
					showElnDialog();
				}catch (ex : Dynamic) {
					elnWindowActive = false;
					throw ex;
				}
			}
		}else if (rec.data.id == 'STATUS') {
			if (statusWindowActive == false) {
				statusWindowActive = true;
				
				try {
					showStatusDialog();
				}catch (ex : Dynamic) {
					statusWindowActive = false;
					throw ex;
				}
			}
		}
	}
	
	private function showElnDialog() {
		var windowId = Ext.id(null, 'UNIQUE_');
		var tId = Ext.id( null, 'UNIQUE_' );
		
		var vBoxLayout : Array<Dynamic> = new Array<Dynamic>();
        vBoxLayout.push({  
            xtype : 'textfield',
			id: tId,
        });

        var buttonLayoutItems : Array<Dynamic> = new Array<Dynamic>();
		buttonLayoutItems.push({
				xtype : 'button',
				text : 'Save',
				handler : function(){
					var comp = Ext.getCmp(tId);
                    var text = comp.getValue();
					
					var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

					var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
					var rootNode : Dynamic = dataStore.getRootNode();
					
					var node = dataStore.getNodeById('ELN_ID');
					node.set('text', 'ELN: ' +text);
					node.set('ELN_ID', text);
					node.commit();
					
					Ext.getCmp(windowId).close();
				}
		});

		buttonLayoutItems.push({
				xtype : 'button',
				text : 'Cancel',
				handler : function(){
					Ext.getCmp(windowId).close();
				}
		});
		
		vBoxLayout.push({
			xtype : 'panel',
			layout : { type: 'hbox', pack : 'center', padding : '2px', defaultMargins : '2px'},
			items : buttonLayoutItems
		});

		Ext.create('Ext.window.Window', {
			title: 'Set ELN Title',
			modal : true,
			id : windowId,
			layout : { type : 'vbox', align : 'stretch', padding: '2px' },
			items: vBoxLayout,
			listeners : {
				close: function() {
					elnWindowActive = false;
				}
			}
		}).show();
	}
	
	private function showWellLocationDialog() {
		var windowId = Ext.id(null, 'UNIQUE_');
		var cId = Ext.id( null, 'UNIQUE_' );
		
		var data = [ 
					  {NAME:'A01'},{NAME:'A02'},{NAME:'A03'},{NAME:'A04'},{NAME:'A05'},
					  {NAME:'A06'},{NAME:'A07'},{NAME:'A08'},{NAME:'A09'},{NAME:'A10'},
					  {NAME:'B01'},{NAME:'B02'},{NAME:'B03'},{NAME:'B04'},{NAME:'B05'},
					  {NAME:'B06'},{NAME:'B07'},{NAME:'B08'},{NAME:'B09'},{NAME:'B10'},
					  {NAME:'C01'},{NAME:'C02'},{NAME:'C03'},{NAME:'C04'},{NAME:'C05'},
					  {NAME:'C06'},{NAME:'C07'},{NAME:'C08'},{NAME:'C09'},{NAME:'C10'},
					  {NAME:'D01'},{NAME:'D02'},{NAME:'D03'},{NAME:'D04'},{NAME:'D05'},
					  {NAME:'D06'},{NAME:'D07'},{NAME:'D08'},{NAME:'D09'},{NAME:'D10'},
					  {NAME:'E01'},{NAME:'E02'},{NAME:'E03'},{NAME:'E04'},{NAME:'E05'},
					  {NAME:'E06'},{NAME:'E07'},{NAME:'E08'},{NAME:'E09'},{NAME:'E10'},
					  {NAME:'F01'},{NAME:'F02'},{NAME:'F03'},{NAME:'F04'},{NAME:'F05'},
					  {NAME:'F06'},{NAME:'F07'},{NAME:'F08'},{NAME:'F09'},{NAME:'F10'},
					  {NAME:'G01'},{NAME:'G02'},{NAME:'G03'},{NAME:'G04'},{NAME:'G05'},
					  {NAME:'G06'},{NAME:'G07'},{NAME:'G08'},{NAME:'G09'},{NAME:'G10'},
					  {NAME:'H01'},{NAME:'H02'},{NAME:'H03'},{NAME:'H04'},{NAME:'H05'},
					  {NAME:'H06'},{NAME:'H07'},{NAME:'H08'},{NAME:'H09'},{NAME:'H10'}
					 ];
		var store = Ext.create('Ext.data.Store', {
			fields: ['NAME'],
			data : data
		});
		
		var vBoxLayout : Array<Dynamic> = new Array<Dynamic>();
        vBoxLayout.push({  
            xtype : 'combobox',
            fieldLabel : 'Select well',
            store : store,
            queryMode : 'local',
            displayField : 'NAME',
            valueField : 'NAME',
			id: cId,
			forceSelection : true
        });

        var buttonLayoutItems : Array<Dynamic> = new Array<Dynamic>();
		buttonLayoutItems.push({
				xtype : 'button',
				text : 'Save',
				handler : function(){
					var comp = Ext.getCmp(cId);
                    var wellLocation = comp.getValue();
					
					var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

					var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
					var rootNode : Dynamic = dataStore.getRootNode();
					
					var node = dataStore.getNodeById('WELL_LOCATION');
					node.set('text', 'Well: ' +wellLocation);
					node.set('WELL', wellLocation);
					node.commit();
					
					Ext.getCmp(windowId).close();
				}
		});

		buttonLayoutItems.push({
				xtype : 'button',
				text : 'Cancel',
				handler : function(){
					Ext.getCmp(windowId).close();
				}
		});
		
		vBoxLayout.push({
			xtype : 'panel',
			layout : { type: 'hbox', pack : 'center', padding : '2px', defaultMargins : '2px'},
			items : buttonLayoutItems
		});

		Ext.create('Ext.window.Window', {
			title: 'Set well location',
			modal : true,
			id : windowId,
			layout : { type : 'vbox', align : 'stretch', padding: '2px' },
			items: vBoxLayout,
			listeners : {
				close: function() {
					wellWindowActive = false;
				}
			}
		}).show();
	}
	
	private function showStatusDialog() {
		var windowId = Ext.id(null, 'UNIQUE_');
		var cId = Ext.id( null, 'UNIQUE_' );
		
		var data = [ 
					  {NAME:'In Progress' }, { NAME:'Construct Complete' }, { NAME:'In Process' },
					  {NAME:'On hold'},{NAME:'Pending'},{NAME:'Abandoned'},{NAME:'n/a'}
					 ];
		var store = Ext.create('Ext.data.Store', {
			fields: ['NAME'],
			data : data
		});
		
		var vBoxLayout : Array<Dynamic> = new Array<Dynamic>();
        vBoxLayout.push({  
            xtype : 'combobox',
            fieldLabel : 'Select status',
            store : store,
            queryMode : 'local',
            displayField : 'NAME',
            valueField : 'NAME',
			id: cId,
			forceSelection : true
        });

        var buttonLayoutItems : Array<Dynamic> = new Array<Dynamic>();
		buttonLayoutItems.push({
				xtype : 'button',
				text : 'Save',
				handler : function(){
					var comp = Ext.getCmp(cId);
                    var wellLocation = comp.getValue();
					
					var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

					var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
					var rootNode : Dynamic = dataStore.getRootNode();
					
					var node = dataStore.getNodeById('STATUS');
					node.set('text', 'STATUS: ' +wellLocation);
					node.set('STATUS', wellLocation);
					node.commit();
					
					Ext.getCmp(windowId).close();
				}
		});

		buttonLayoutItems.push({
				xtype : 'button',
				text : 'Cancel',
				handler : function(){
					Ext.getCmp(windowId).close();
				}
		});
		
		vBoxLayout.push({
			xtype : 'panel',
			layout : { type: 'hbox', pack : 'center', padding : '2px', defaultMargins : '2px'},
			items : buttonLayoutItems
		});

		Ext.create('Ext.window.Window', {
			title: 'Set well location',
			modal : true,
			id : windowId,
			layout : { type : 'vbox', align : 'stretch', padding: '2px' },
			items: vBoxLayout,
			listeners : {
				close: function() {
					statusWindowActive = false;
				}
			}
		}).show();
	}
	
	private function showPlateSelectionDialog(plateNames : Array<String>) {
		var windowId = Ext.id(null, 'UNIQUE_');
		var cId = Ext.id( null, 'UNIQUE_' );
		
		var plateObjs = new Array<Dynamic>();
		
		for (plateName in plateNames) {
			plateObjs.push({NAME:plateName});
		}
		
		var store = Ext.create('Ext.data.Store', {
			fields : ['NAME'],
			data : plateObjs
		});
		
		var vBoxLayout : Array<Dynamic> = new Array<Dynamic>();
        vBoxLayout.push({  
            xtype : 'combobox',
            fieldLabel : 'Select plate',
            store : store,
            queryMode : 'local',
            displayField : 'NAME',
            valueField : 'NAME',
			id: cId,
			forceSelection : true
        });

        var buttonLayoutItems : Array<Dynamic> = new Array<Dynamic>();
		buttonLayoutItems.push({
				xtype : 'button',
				text : 'Save',
				handler : function(){
					var comp = Ext.getCmp(cId);
                    var plateName = comp.getValue();
					
					var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

					var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
					var rootNode : Dynamic = dataStore.getRootNode();
					
					var node = dataStore.getNodeById('ALLELE_PLATE');
					node.set('text', 'Plate: ' +plateName);
					node.set('PLATE', plateName);
					
					node.commit();
					
					Ext.getCmp(windowId).close();
				}
		});

		buttonLayoutItems.push({
				xtype : 'button',
				text : 'Cancel',
				handler : function(){
					Ext.getCmp(windowId).close();
				}
		});
		
		vBoxLayout.push({
			xtype : 'panel',
			layout : { type: 'hbox', pack : 'center', padding : '2px', defaultMargins : '2px'},
			items : buttonLayoutItems
		});

		Ext.create('Ext.window.Window', {
			title: 'Set plate name',
			modal : true,
			id : windowId,
			layout : { type : 'vbox', align : 'stretch', padding: '2px' },
			items: vBoxLayout,
			listeners : {
				close: function() {
					plateWindowActive = false;
				}
			}
		}).show();
	}
}
