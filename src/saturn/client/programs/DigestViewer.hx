/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.util.HaxeException;
import saturn.core.DoubleDigest;
import saturn.core.DNA;
import saturn.core.RestrictionSite;
import saturn.client.workspace.DNAWorkspaceObject;

import saturn.client.workspace.DigestWO;

import saturn.util.StringUtils;

import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.WorkspaceApplication;

import bindings.Ext;

class DigestViewer extends DNASequenceEditor implements WorkspaceListener {
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ DigestWO ];
	
    public function new(){
        super();
    } 
	
	override public function emptyInit() {
		super.emptyInit();
		
		getWorkspace().addListener(this);
	}
    
	override public function setActiveObject(objectId : String) {
		super.setActiveObject(objectId);
	}
	
	override public function postRestore() : Void {
		super.postRestore();
		updateDigest();
	}
	
    override public function onFocus(){
        super.onFocus();
		
		var me = this;
		
		getApplication().getViewMenu().add({
            text : 'Update digest',
            handler : function(){
                me.updateDigest();
            }
        });
		
		showActiveSequence();
    }
	
	override public function close() : Void {
        super.close();
		
		getApplication().getWorkspace().removeListener(this);
    }

    override public function serialise() : Dynamic {
        var object : Dynamic = super.serialise();

        return object;
	}
	
    override public function deserialise(object : Dynamic) : Void {
        super.deserialise(object);
	}
	
	override public function onOutlineDrop(node :Dynamic, data :Dynamic, overModel :Dynamic, dropPosition :Dynamic, dropHandlers :Dynamic, eOpts :Dynamic) : Bool{
        var objectId : String = data.records[0].get('objectId');

        var dnaWO : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(objectId,DNAWorkspaceObject);
		
		if ( dnaWO != null ) {
			var update :Bool = false;
			
			var activeObject : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
			
			if (overModel.data.id == 'Template') {		
				activeObject.setTemplate(dnaWO);
				
				update = true;
			}else if (overModel.data.id == 'Restriction 1') {
				if (Std.is(dnaWO.getDNAObject(), RestrictionSite)) {
					activeObject.setRestrictionSite1(dnaWO);
			
					data.records[0].raw.objectId = data.records[0].raw.objectId + '_1';
					data.records[0].data.objectId = data.records[0].data.objectId + '_1';
					
					update = true;
				}
			}else if (overModel.data.id == 'Restriction 2') {
				if (Std.is(dnaWO.getDNAObject(), RestrictionSite)) {
					activeObject.setRestrictionSite2(dnaWO);
				
					data.records[0].raw.objectId = data.records[0].raw.objectId + '_1';
					data.records[0].data.objectId = data.records[0].data.objectId + '_1';
					
					update = true;
				}
			}
			
			if (update) {
				updateDigest();
				
				return true;
			}
		}
		
		dropHandlers.cancelDrop();
		
		return false;
    }
	
	function updateDigest() {
		if(getActiveObject(DigestWO) != null ){
			var activeObject : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
				
			if (activeObject.getTemplateId() == null || activeObject.getRes1Id() == null || activeObject.getRes2Id() == null) {
				return ;
			}
			
			try{
				activeObject.digest();
				
				setMiddleActive();
			}catch (ex : HaxeException) {
				js.Browser.alert(ex.getMessage()); return;
			}
		}
	}
	
	public function setLeftActive() {
		getActiveObject(DigestWO).setLeftActive();
		
		showActiveSequence();
	}
	
	public function setRightActive() {
		getActiveObject(DigestWO).setRightActive();
		
		showActiveSequence();
	}
	
	public function setMiddleActive() {
		getActiveObject(DigestWO).setMiddleActive();
		
		showActiveSequence();
	}
	
	public function showActiveSequence() {
		var me : Dynamic = this;
		if (WorkspaceApplication.getApplication().getActiveProgram() == me) {
			var activeObject : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
			if (activeObject != null) {
		
				var sequence : String = activeObject.getDNAObject().getSequence();
					
				if(sequence != null && sequence.length!=0){					
					blockChanged(null, null, 0, null, sequence);
				}
			}
		}
	}
	
	override function installOutlineTree() {
        super.installOutlineTree();

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
		
		var templateFolder : Dynamic = rootNode.appendChild({
				text : 'Template',
				leaf : false,
				expanded : true,
				id : 'Template'
		});
		
		var activeObject : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
		
		if (activeObject != null) {
			
			var templateId : String = activeObject.getTemplateId();
			
			if(templateId != null){
				var wO : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(templateId, DNAWorkspaceObject);
			
				var childNode : Dynamic = templateFolder.appendChild(Ext.create('WorkspaceObject', {
						text : wO.getName(),
						leaf : true,
						objectId : templateId,
						id : templateId
				}));
			}
		}
		
		var res1Folder: Dynamic = rootNode.appendChild({
				text : 'Restriction 1',
				leaf : false,
				expanded : true,
				id : 'Restriction 1'
		});
		
		var activeObject : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
		
		if (activeObject != null) {	
			var res1Id : String = activeObject.getRes1Id();
			
			if(res1Id != null){
				var wO : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(res1Id, DNAWorkspaceObject);
			
				var childNode : Dynamic = res1Folder.appendChild(Ext.create('WorkspaceObject', {
						text : wO.getName(),
						leaf : true,
						objectId : res1Id + '_1',
						id : res1Id + '_1'
				}));
			}
		}
		
		var res2Folder: Dynamic = rootNode.appendChild({
				text : 'Restriction 2',
				leaf : false,
				expanded : true,
				id : 'Restriction 2'
		});
		
		var activeObject : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
		
		if (activeObject != null) {	
			var res2Id : String = activeObject.getRes2Id();
			
			if(res2Id != null){
				var wO : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(res2Id, DNAWorkspaceObject);
			
				var childNode : Dynamic = res2Folder.appendChild(Ext.create('WorkspaceObject',{
						text : wO.getName(),
						leaf : true,
						objectId : res2Id + '_2',
						id : res2Id + '_2'
				}));
			}
		}
		
		var fragmentsFolder: Dynamic = rootNode.appendChild({
				text : 'Fragments',
				leaf : false,
				expanded : true,
				id : 'Fragments'
		});
		
		fragmentsFolder.appendChild(Ext.create('WorkspaceObject',{
						text : 'Left of cuts',
						leaf : true,
						id : 'Left of cuts',
						objectId : null
		}));
		
		fragmentsFolder.appendChild(Ext.create('WorkspaceObject',{
						text : 'Between cuts',
						leaf : true,
						id : 'Between cuts',
						objectId : null
		}));
		
		fragmentsFolder.appendChild(Ext.create('WorkspaceObject',{
						text : 'Right of cuts',
						leaf : true,
						id : 'Right of cuts',
						objectId : null
		}));
		
		var contextMenu = function(view : Dynamic, record : Dynamic, 
                                        item : Dynamic, index : Dynamic, event : Dynamic){
            var self = this;            
            var objectId = record.get('objectId');

            if(objectId != ""){
                var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                    items: [
                        {
                            text : 'Remove ',
                            handler : function(){
                                self.objectRemoved(self.getWorkspace().getObject(objectId));
                            }
                        }
                    ]
                });
    
                contextMenu.showAt(event.getXY());
    
                event.stopEvent();
            }
        };
		
		getApplication().getOutlineTree('DEFAULT').on('itemcontextmenu', contextMenu,this);
		
		var me = this;
		
		getApplication().getOutlineTree('DEFAULT').on('itemclick' ,
			function(view, rec, item, index, event) {
				if (event.ctrlKey) {
					contextMenu(view, rec, item, index, event);
				}else {
					var id = rec.get('id');
					if ('Left of cuts' == id) {
						me.setLeftActive();
					}else if ('Right of cuts' == id) {
						me.setRightActive();
					}else if ('Between cuts' == id) {
						me.setMiddleActive();
					}
				}
			}, this
		);
	}
	
	override public function convertDragToWorkspaceObject(data : Dynamic) : WorkspaceObject<Dynamic> {
		var wO : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
		var digest : DoubleDigest = wO.getObject();
		
		if (data.id == 'Left of cuts') {
			return new DNAWorkspaceObject(new DNA(digest.getLeftProduct().getSequence()),'Left');
		}else if (data.id == 'Right of cuts') {
			return new DNAWorkspaceObject(new DNA(digest.getRightProduct().getSequence()),'Right');
		}else if (data.id == 'Between cuts') {
			return new DNAWorkspaceObject(new DNA(digest.getCenterProduct().getSequence()),'Center');
		}else {
			return null;
		}
	}
	
	/**
	 * Workspace Listener
	 */
	
	override public function objectRenamed(object : WorkspaceObject<Dynamic>) : Void{
        var objectId : String = object.getUUID();
		
		var wO : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
		
		var isOurs = false;
		
		if (objectId == wO.getTemplateId()) {
			isOurs = true;
		}else if (objectId == wO.getRes1Id()) {
			isOurs = true;
		}else if (objectId == wO.getRes2Id()) {
			isOurs = true;
		}
		
		if (isOurs) {
			var node = getApplication().getOutlineDataStore('DEFAULT').getRootNode().findChild('objectId', objectId, true);
			
			if(node != null){
				node.set('text', object.getName());
				node.commit();			
			}
		}
    }
	
	override public function objectAdded(object : WorkspaceObject<Dynamic>) : Void{

    }

    override public function objectRemoved(object : WorkspaceObject<Dynamic>) : Void {
		var objectId :String = object.getUUID();
		
		var isOurs = false;
		
		var wO : DigestWO<DoubleDigest> = getActiveObject(DigestWO);
		
		if (wO == null) {
			return ; // We probably just got removed
		}
		
		if (objectId == wO.getTemplateId()) {
			isOurs = true;
			wO.setTemplate(null);
		}else if (objectId == wO.getRes1Id()) {
			isOurs = true;
			wO.setRestrictionSite1(null);
			
			objectId = objectId + '_1';
		}else if (objectId == wO.getRes2Id()) {
			isOurs = true;
			wO.setRestrictionSite2(null);
			
			objectId = objectId + '_2';
		}
		
		if (isOurs) {
			var node :Dynamic = getApplication().getOutlineDataStore('DEFAULT').getRootNode().findChild('objectId', objectId, true);
			if(node != null){
				node.parentNode.removeChild(node);
			}
		}
	}
}

