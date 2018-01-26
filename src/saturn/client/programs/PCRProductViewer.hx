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
import saturn.core.PCRProduct;
import saturn.core.Primer;
import saturn.core.DNA;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.PCRProductWO;
import saturn.util.StringUtils;

import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.WorkspaceApplication;

import bindings.Ext;

class PCRProductViewer extends DNASequenceEditor implements WorkspaceListener {
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ PCRProductWO ];
	
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
	
    override public function onFocus(){
        super.onFocus();
    
        updatePCRProduct();
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

        var wO : WorkspaceObject<Dynamic> = getWorkspace().getObject(objectId);
		
		if ( Std.is(wO, DNAWorkspaceObject) ) {
			var dnaWO : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(objectId, DNAWorkspaceObject);
			
			var update :Bool = false;
			
			var activeObject : PCRProductWO<PCRProduct> = getActiveObject(PCRProductWO);
			
			if (overModel.data.id == 'Forward Primer') {			
				activeObject.setForwardPrimer(dnaWO);
				
				update = true;
			}else if (overModel.data.id == 'Reverse Primer') {
				activeObject.setReversePrimer(dnaWO);
			
				update = true;
			}else if (overModel.data.id == 'Template') {
				activeObject.setTemplate(dnaWO);
				
				update = true;
			}
			
			if (update) {
				updatePCRProduct();
				
				return true;
			}
		}
		
		dropHandlers.cancelDrop();
		
	  return false;
    }
	
	function updatePCRProduct() {
		if(getActiveObject(PCRProductWO) != null ){
			var activeObject : PCRProductWO<PCRProduct> = getActiveObject(PCRProductWO);
				
			try{
				activeObject.updateProduct();
					
				var sequence : String = activeObject.getObject().getSequence();
					
				if(sequence != null && sequence.length!=0){					
					blockChanged(null, null, 0, null, sequence);
				}
			}catch (ex : HaxeException) {
				js.Browser.alert(ex.getMessage());
			}
		}
	}
	
	override function installOutlineTree() {
        super.installOutlineTree();

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
		
		var fPrimerFolder : Dynamic = rootNode.appendChild({
				text : 'Forward Primer',
				leaf : false,
				expanded : true,
				id : 'Forward Primer'
		});
		
		if (getActiveObject(PCRProductWO) != null) {
			var activeObject : PCRProductWO<PCRProduct> = getActiveObject(PCRProductWO);
			
			var fPrimerId : String = activeObject.getForwardPrimerId();
			
			if(fPrimerId != null){
				var wO : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(fPrimerId, DNAWorkspaceObject);
			
				var childNode : Dynamic = fPrimerFolder.appendChild(Ext.create('WorkspaceObject', {
						text : wO.getName(),
						leaf : true,
						objectId : fPrimerId,
						id : fPrimerId
				}));
			}
		}
		
		var rPrimerFolder: Dynamic = rootNode.appendChild({
				text : 'Reverse Primer',
				leaf : false,
				expanded : true,
				id : 'Reverse Primer'
		});
		
		if (getActiveObject(PCRProductWO) != null) {	
			var activeObject : PCRProductWO<PCRProduct> = getActiveObject(PCRProductWO);
			var rPrimerId : String = activeObject.getReversePrimerId();
			
			if(rPrimerId != null){
				var wO : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(rPrimerId, DNAWorkspaceObject);
			
				var childNode : Dynamic = rPrimerFolder.appendChild(Ext.create('WorkspaceObject',{
						text : wO.getName(),
						leaf : true,
						objectId : rPrimerId,
						id : rPrimerId
				}));
			}
		}
		
		var templateFolder : Dynamic = rootNode.appendChild({
				text : 'Template',
				leaf : false,
				expanded : true,
				id : 'Template'
		});
		
		if (getActiveObject(PCRProductWO) != null) {	
			var activeObject : PCRProductWO<PCRProduct> = getActiveObject(PCRProductWO);
			var templateId : String = activeObject.getTemplateId();
			
			if(templateId != null){
				var wO : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(templateId, DNAWorkspaceObject);
			
				var childNode : Dynamic = templateFolder.appendChild(Ext.create('WorkspaceObject',{
						text : wO.getName(),
						leaf : true,
						objectId : templateId,
						id : templateId
				}));
			}
		}
		
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
		
		getApplication().getOutlineTree('DEFAULT').on('itemclick' ,
			function(view, rec, item, index, event) {
				if (event.ctrlKey) {
					contextMenu(view, rec, item, index, event);
				}
			}, this
		);
	}
	
	/**
	 * Workspace Listener
	 */
	
	override public function objectRenamed(object : WorkspaceObject<Dynamic>) : Void{
        var objectId : String = object.getUUID();
		
		var wO : PCRProductWO<PCRProduct> = getActiveObject(PCRProductWO);
		
		var isOurs = false;
		
		if (objectId == wO.getForwardPrimerId()) {
			isOurs = true;
		}else if (objectId == wO.getReversePrimerId()) {
			isOurs = true;
		}else if (objectId == wO.getTemplateId()) {
			isOurs = true;
		}
		
		if (isOurs) {
			var node = getApplication().getOutlineDataStore('DEFAULT').getRootNode().findChild('objectId', objectId, true);
			node.set('text', object.getName());
			node.commit();			
		}
    }
	
	override public function objectAdded(object : WorkspaceObject<Dynamic>) : Void{

    }

    override public function objectRemoved(object : WorkspaceObject<Dynamic>) : Void {
		var objectId :String = object.getUUID();
		
		var isOurs = false;
		
		var wO : PCRProductWO<PCRProduct> = getActiveObject(PCRProductWO);
		
		if (wO == null) {
			return ; // We probably just got removed
		}
		
		if (objectId == wO.getForwardPrimerId()) {
			isOurs = true;
			wO.setForwardPrimer(null);
		}else if (objectId == wO.getReversePrimerId()) {
			isOurs = true;
			wO.setReversePrimer(null);
		}else if (objectId == wO.getTemplateId()) {
			isOurs = true;
			wO.setTemplate(null);
		}
		
		if (isOurs) {
			var node :Dynamic = getApplication().getOutlineDataStore('DEFAULT').getRootNode().findChild('objectId', objectId, true);
			if(node != null){
				node.parentNode.removeChild(node);
			}
		}
	}
}

