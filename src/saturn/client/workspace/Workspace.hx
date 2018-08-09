/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.workspace;

import saturn.client.WorkspaceApplication;
import saturn.client.core.ClientCore;
import saturn.db.Model;
import saturn.core.FileShim;
import saturn.core.domain.SaturnSession;
import saturn.client.programs.TextEditor;
import haxe.Json;
import saturn.client.core.CommonCore;
import saturn.util.HaxeException;
import bindings.IndexedDB;
import bindings.Ext;
import js.Lib;
import saturn.util.CollectionUtils;
import saturn.client.BuildingBlock;
import saturn.client.ProgramRegistry;
import saturn.client.WorkspaceApplication;

import haxe.Unserializer;
import haxe.Serializer;


class Workspace implements BuildingBlock{
    var theComponent : Dynamic;
    
    var theListeners : List<WorkspaceListener>;
    var theObjects : Map<String, WorkspaceObject<Dynamic>>;

    var nameToObjectUUID : Map<String, String>;

    var objectIdToOpenProgramId : Map<String, String>;
    
	var programIdToObjectIds : Map<String, Array<String>>;
	
	var programIdToProgram : Map<String, Program>;
	
    var nextObjectId : Int;
	
	var nextProgramId : Int;
	
	var theWorkspaceDatabase : WorkspaceStore;
    
	var theWorkspaceName : String;
	
	var theWorkspaceDataStore : Dynamic;

    var treeUpdatesSuspended : Bool;

    var wkModel : Dynamic;

    var reloading = false;
	
    public function new(){
        theListeners = new List<WorkspaceListener>();
        theObjects = new Map<String, WorkspaceObject<Dynamic>>();

        nameToObjectUUID = new Map<String,String>();

        objectIdToOpenProgramId = new Map<String, String>();
        
		programIdToObjectIds = new Map<String, Array<String>>();
		programIdToProgram = new Map<String, Program>();
		
        nextObjectId = 0;
		nextProgramId = 0;

        treeUpdatesSuspended = false;

        wkModel = Ext.define('WorkspaceObject', {
            extend : 'Ext.data.TreeModel',
            fields : [
                {name : 'objectId', type : 'string'},
                {name : 'text', type : 'string'},
                {name: 'type', type: 'string'}
            ],
            idProperty : 'objectId'
        });
        
        initialiseComponent();
		
		initialiseWorkspaceStore();
		
		theWorkspaceName = "DEFAULT";
    }

    public function getProgramForObject(objectId) : Program{
        if(objectIdToOpenProgramId.exists(objectId)){
            var programId :String = objectIdToOpenProgramId.get(objectId);
            if(programIdToProgram.exists(programId)){
                return programIdToProgram.get(programId);
            }
        }

        return null;
    }

	/**
	 * getProgram returns the Program associated with the given programId
	 * 
	 * @param	programId
	 * @return
	 */
	public function getProgram(programId): Program {
		return programIdToProgram.get(programId);
	}

    public function getTreeStore() : Dynamic{
        return theWorkspaceDataStore;
    }

	/**
	 * closeWorkspace() closes the current workspace
	 * 
	 * Method can be slow to return as each time a program is closed  the program next 
	 * in line is focused (which will cause it to redraw it's interface).  As a program 
	 * might require user input before it closes this isn't considered a bug.
	 * 
	 * After closing the workspace the workspace you are working with becomes the 
	 * default one.  Note however that if there is a saved version of the default
	 * workspace it won't be loaded.
	 */
    public function closeWorkspace() : Void {
        beginUpdate();

        setReloading(true);

		// Close all programs
        for(program in programIdToProgram){
           WorkspaceApplication.getApplication().closeProgram(program);
        }

		// Remove all objects
		for(key in theObjects.keys()){
			theObjects.remove(key);
        }
		
		// Remove all objects from internal indexes
		for (key in objectIdToOpenProgramId.keys()) {
			objectIdToOpenProgramId.remove(key);
		}
		
		for (key in programIdToProgram.keys()) {
			programIdToProgram.remove(key);
		}

        for(key in programIdToObjectIds.keys()){
            programIdToObjectIds.remove(key);
        }

        for(name in nameToObjectUUID.keys()){
            nameToObjectUUID.remove(name);
        }
		
		// Reset counters
        nextObjectId = 0;
        nextProgramId = 0;

        setReloading(false);

        WorkspaceApplication.getApplication().cleanEnvironment();

		// Reload workspace
        reloadWorkspace();

		// Set workspace name to the default
        theWorkspaceName = "DEFAULT";

        WorkspaceApplication.getApplication().setActiveProgram(null);

        createTreeStore();

        theComponent.reconfigure(theWorkspaceDataStore);
    }
	
	/**
	 * registerProgram Register program with the Workspace
	 * 
	 * Method will assign the program a new ID and pass it to the WorkspaceApplication for loading
	 * 
	 * Program will also be set as the currently active program which has the focus
	 * 
	 * @param	program
	 */
	public function registerProgram(program : Program) : Void {
		// Assign ID to program if it doesn't have one
		if (program.getId() == null) {
			program.setId(Std.string(nextProgramId));
			
			nextProgramId++;
		}
		
		// Pass the program to the WorkspaceApplication if we haven't see it before
		if(!programIdToProgram.exists(program.getId())) {
			var haxeApp : WorkspaceApplication = WorkspaceApplication.getApplication();
			
			haxeApp.addProgram(program, true);

            if(!isReloading()){
			    haxeApp.setActiveProgram(program);
            }
		
			var programId : String = Std.string(program.getId());
			
			programIdToProgram.set(programId, program);
		}
	}

    public function isReloading() : Bool{
        return reloading;
    }

    public function setReloading(reloading : Bool){
        this.reloading = reloading;
    }
	
	/**
	 * registerObjectWith should be called to register an WorkspaceObject with a Program
	 * 
	 * Neither the WorkspaceObject nor the Program need to be known by the Workspace before
	 * calling this method
	 * 
	 * @param	object
	 * @param	program
	 */
	public function registerObjectWith(object : Dynamic, program : Program) {
        if(object == null){
            return;
        }

		// Register Program (method will check if it is already known)
		registerProgram(program);
		
		var objectId : String = object.getUUID();
		
		// Register WorkspaceObject with the Workspace if it isn't already known
		if (objectId == null) {
			addObject(object, false);
			
			objectId = object.getUUID();
		}
		
		// Update internal indexes to associate the WorkspaceObject with the Program
		var programId : String = Std.string(program.getId());
		objectIdToOpenProgramId.set(objectId, programId);
		
		if(programIdToObjectIds.exists(programId) == false){
			programIdToObjectIds.set(programId, new Array<String>());
		}
		
		programIdToObjectIds.get(programId).push(objectId);
		
		// Pass the WorkspaceObject to the Program
		program.addWorkspaceObject(objectId);
	}

	/**
	 * removeObject Removes the object from the Workspace
	 * 
	 * If the WorkspaceObject is associated with an open Program that isn't associated with
	 * any other WorkspaceObjects it will be automatically closed by this method
	 * 
	 * @param	objectId
	 */
	@:throws('sgc.extjs.WorkspaceObjectNotFoundException')
    public function removeObject(objectId : String, reload = true) : Void {
		// Throw an exception if the WorkspaceObject isn't known to the Workspace
        if(!theObjects.exists(objectId)){
            throw new WorkspaceObjectNotFoundException("Object "+objectId+" not found in object tree");
        }else {
			// Notify all WorkspaceObjectListeners that the WorkspaceObject is about to be removed
			// from the Workspace
			var object : WorkspaceObject<Dynamic> = theObjects.get(objectId);

			for(listener in theListeners){
				listener.objectRemoved(object);
			}

            theObjects.remove(objectId);
            nameToObjectUUID.remove(object.getName());
		}
        
		// If the WorkspaceObject is associated with an open Program
		if (objectIdToOpenProgramId.exists(objectId)) {
			var programId : String = objectIdToOpenProgramId.get(objectId);

			// Remove association between the WorkspaceObject and the active Program 
			// associated with it
            objectIdToOpenProgramId.remove(objectId);
			
			// Tell the Program that the WorkspaceObject is being removed
			var program : Program = programIdToProgram.get(programId);
			
			program.closeWorkspaceObject(objectId);
			
			// Remove reverse association direction
			programIdToObjectIds.get(programId).remove(objectId);
			
			// If the Program isn't associated with anymore WorkspaceObjects then close it
			if (programIdToObjectIds.get(programId).length == 0) {
				WorkspaceApplication.getApplication().closeProgram(program);
				
				programIdToObjectIds.remove(programId);
				programIdToProgram.remove(programId);
			}
            
            if(!programIdToObjectIds.keys().hasNext()){
                WorkspaceApplication.getApplication().setActiveProgram(null);
            }
		}

        if(!reload){
            theWorkspaceDataStore.suspendEvents();
        }

        var node :Dynamic = theWorkspaceDataStore.getRootNode().findChild('objectId', objectId, true);
        if(node != null){
            node.remove(true);
            //node.parentNode.removeChild(node);
            theWorkspaceDataStore.remove(node, true);
        }

        if(reload){
            //theComponent.view.refresh();
            reloadWorkspace();
        }

		// Finally reload the Workspace
        //reloadWorkspace();
    }

	/**
	 * getOpenProgram returns the Program (if any) that is currently open on the
	 * give WorkspaceObject
	 * 
	 * @param	objectId
	 * @return
	 */
    public function getOpenProgram(objectId : String) : Program{
        if(objectIdToOpenProgramId.exists(objectId)){
            return programIdToProgram.get(objectIdToOpenProgramId.get(objectId));
        }else{
            return null;
        }
    }
	
	/**
	 * Close all Programs associated with all WorkspaceObjects except the one which
	 * is associated with the supplied WorkspaceObject ID
	 * 
	 * @param	keepId
	 */
	public function closeOtherObjects(keepId : String) {
        setReloading(true);
		// Close all Programs except the one associated with keepId
		for ( objectId in objectIdToOpenProgramId.keys() ) {
			if(objectId != keepId){
				_closeObject(objectId,false);
			}
		}

        setReloading(false);

        WorkspaceApplication.getApplication().cleanEnvironment();

        setActiveObject(keepId);
		
		// Finally reload Workspace
		reloadWorkspace();
	}
	
	/**
	 * closeAllObjects() in the Workspace
	 */
	public function closeAllObjects() : Void {
        setReloading(true);

		// Close all objects
		for ( objectId in objectIdToOpenProgramId.keys() ) {
			_closeObject(objectId,false);
		}

        setReloading(false);

        WorkspaceApplication.getApplication().cleanEnvironment();
		
		// Finally reload the Workspace
		reloadWorkspace();
	}

    public function closeObjectAndDelete(objectId : String){
        closeObject(objectId);

        removeObject(objectId);
    }

	/**
	 * closeObjects Closes the Program associated with the WorkspaceObject
	 * 
	 * Note that the WorkspaceObject itself isn't removed from the Workspace
	 * 
	 * @param	objectId
	 */
	public function closeObject(objectId : String) : Void {	
		_closeObject(objectId, true);
	}

	/**
	 * _closeObject Closes the Program associated with the WorkspaceObject like the
	 * method closeObject.  This method however allows you to control whether or
	 * not the Workspace Tree is refreshed after the program is closed.
	 * 
	 * Method is useful when you are closes lots of WorkspaceObjects all at once
	 * and only need the refresh to be performed once.   Note that a refresh
	 * is a very slow operation in EXTJS
	 * 
	 * @param	objectId
	 * @param	refresh
	 */
    public function _closeObject(objectId : String, refresh : Bool) : Void {	
		// Check that the WorkspaceObject is associated with a Program to close
		if (objectIdToOpenProgramId.exists(objectId)) {
			// Close Program and perform index cleanup
			var programId : String = objectIdToOpenProgramId.get(objectId);
				
			var program : Program = programIdToProgram.get(programId);
			
			program.closeWorkspaceObject(objectId);
			
			programIdToObjectIds.get(programId).remove(objectId);

            objectIdToOpenProgramId.remove(objectId);
			
			// Close the Program if it is no longer associated with any WorkspaceObjects
			if (programIdToObjectIds.get(programId).length == 0) {
				WorkspaceApplication.getApplication().closeProgram(program);
				
				programIdToObjectIds.remove(programId);
				programIdToProgram.remove(programId);
			}
		}
        
		// If requested perform a Workspace refresh
		if(refresh){
			reloadWorkspace();
		}
    }
	
	/**
	 * Method gives focus to the program associated with the given object.
	 * 
	 * When the object isn't already open a new program is created
	 * 
	 * @param	objectId
	 */
	public function setActiveObject(objectId : String) : Void {
		// Get the Program associated with the WorkspaceObject
		var programId : String = objectIdToOpenProgramId.get(objectId);
		
		var program : Program = programIdToProgram.get(programId);
					
		var haxeApp : WorkspaceApplication = WorkspaceApplication.getApplication();
		
		if (program == null) {
			// When no Program is open for the given WorkspaceObject
			var object : WorkspaceObject<Dynamic> = getObject(objectId);
						
			var objectId : String = object.getUUID();
			
			var progReg : ProgramRegistry = haxeApp.getProgramRegistry();
			
			// Get the default Program associated with the correspondong WorkspaceObject class
			var programType : Class<Program> = progReg.getDefaultProgram(Type.getClass(object));

            if(programType != null){
                // Create a new instance of the Program type
                var program : Dynamic = Type.createInstance(programType, []);

                progReg.installPlugins(program);

                // Below, should be removed once we are happy with the createInstance solution above
                //var program : Program<WorkspaceObject<Dynamic>> = Reflect.callMethod(programType,Reflect.field(programType, 'getNewInstance'),[null, false]);

                // Register WorkspaceObject and program together
                registerObjectWith(object, program);
            }

			// Set the active WorkspaceObject for the Program
			//program.setActiveObject(objectId);
		}else {
			// When a program already exists
			
			// Set the active ProgramF
			haxeApp.setActiveProgram(program);

            Ext.resumeLayouts(false);
			
			// Set the active WorkspaceObject associated with the Program
			// Calls like this might be dropped if we drop the idea of multiple
			// WorkspaceObjects being associated with the same Program instance
			//program.setActiveObject(objectId);
		}
	}

    public function getActiveObject() : Dynamic{
        return getObject(WorkspaceApplication.getApplication().getActiveProgram().getActiveObjectId());
    }
	
	public function initialiseWorkspaceStore() {
		if(WorkspaceApplication.getApplication().isNaked() == false){
			theWorkspaceDatabase = new WorkspaceStore("WORKSPACE_SESSIONS", 1, function(e) { WorkspaceApplication.getApplication().showMessage('',e); } );
		}
	}

    public function installRemoteWorkspaceStore(){
        if(WorkspaceApplication.getApplication().isNaked() == false){
            theWorkspaceDatabase = new WorkspaceStoreProvider("WORKSPACE_SESSIONS", 1, function(e) { WorkspaceApplication.getApplication().showMessage('',e); } );
        }
    }
	
	public function saveWorkspace() {
        var cb = function(res){
            theWorkspaceDatabase.store(res, function(e) { WorkspaceApplication.getApplication().showMessage('',e); }, function(e) { } );
        }

		serialise(cb);
	}

    public function saveWorkspaceToFile(fileName) {
        var cb = function(res){
            WorkspaceApplication.getApplication().saveTextFile(Serializer.run(res), fileName);
        };

        serialise(cb);
    }
	
	public function getDOMComponent() {
			return getComponent().el.dom;
	}

    private function createTreeStore(){
        theWorkspaceDataStore = Ext.create('Ext.data.TreeStore', {
            model : 'WorkspaceObject',
            root: {
                expanded: true,
                autoSync : false
            },
            proxy: {
                type: 'memory',
                reader: {
                    type: 'json'
                }
            }
        });
    }

    private function initialiseComponent(){
        createTreeStore();

        //theWorkspaceDataStore.getRootNode().appendChild(folder1);
		
		var menu =function(view : Dynamic, record : Dynamic, 
                                        item : Dynamic, index : Dynamic, event : Dynamic){
            var self = this;            
            var objectId = record.get('objectId');
            var object : WorkspaceObject<Dynamic> = self.getObject(objectId);   

			var menuArray = [
                    {
                        text: 'Rename '+record.get('text'),
                        handler: function(){
                            renameItem(objectId);
                            //self.renameWorkspaceObjectPrompt(objectId);
                        }
                    },
                    {
                        text : 'Remove '+record.get('text'),
                        handler : function(){
                            removeItem(objectId);
                        }
                    },
					{
                        text : 'Duplicate '+record.get('text'),
                        handler : function() {
                            duplicateItem(objectId);
                        }
                    },
                    {
                        text : 'Close Programs',
                        handler : function(){
                            closeItem(objectId);
                        }
                    }
            ];

            var prog = getProgramForObject(objectId);
            if(prog != null){
                var items = prog.getWorkspaceContextMenuItems();

                if(items != null){
                    for(item in items){
                        menuArray.push(item);
                    }
                }
            }

            if(record.get('type') == 'folder'){
                menuArray.push({
                    text : 'Add folder',
                    handler : function(){
                        addFolderPrompt(objectId);
                    }
                });
            }
			
            var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                items: menuArray
            });
			
			/*
			 var object : WorkspaceObject<Dynamic> = getObject(objectId);
						
			var objectId : String = object.getUUID();
			
			var progReg : ProgramRegistry = haxeApp.getProgramRegistry();
						
			var programDef : ProgramDefinition = progReg.getDefaultProgram(Type.getClassName(Type.getClass(object))); 
			*/ 

            contextMenu.showAt(event.getXY());

            event.stopEvent();
        };
		
		var me = this;
		
		theComponent = Ext.create('Ext.tree.Panel', {
            store: theWorkspaceDataStore,
            rootVisible: false,
            enableDrag : true,
            border: false,
            autoScroll: true,
            viewConfig: {
                plugins: { 
					ptype: 'treeviewdragdrop',
					enableDrop : true,
                    pluginId : 'treedd',
                    allowContainerDrops : true,
					appendOnly: true,
                    containerScroll: true
                }, //copy : true,
				listeners: {
                    /*'beforedrop' : function( node, data, overModel, dropPosition, dropHandlers, eOpts ) {
						if(data.records[0].data.objectId == null){
							return true;
						}else {
							dropHandlers.cancelDrop();
							return false;
						}
					},
					'auto_open': function(data) {
						me.setActiveObject(data.records[0].data.objectId);
					}*/
				}
            },
            listeners:{
                itemclick:function(view, rec, item, index, event) {
					if (event.ctrlKey) {
						menu(view, rec, item, index, event);
					}else {
						var id = rec.get('objectId');

                        if(rec.get('type') != 'folder'){
                            setActiveObject(id);
                        }
					}
                },
				render : Ext.bind(function(self) {
					initialiseDOMComponent();
				}, this),
                containercontextmenu: function(node, event){
                    var menuItems : Array<Dynamic> = [];
                    menuItems.push({
                        text : 'Add folder',
                        handler : function(){
                            addFolderPrompt(null);
                        }
                    });

                    var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                        items: menuItems
                    });

                    contextMenu.showAt(event.getXY());

                    event.stopEvent();
                }
            },
            cls: 'x-drag-drop-background'

        });
		
        theComponent.on('itemcontextmenu', menu,this);
        //theComponent.on('contextmenu', menu , this);
    }
	
    private function renameWorkspaceObjectPrompt(objectId : String){
        var self = this;

        var dialog = Ext.Msg.prompt('Rename object', 'Type new name', function(btn, text){
               if(btn == 'ok'){
                     self.renameWorkspaceObject(objectId, text);


               }
        },this,false,theObjects.get(objectId).getName());
    }

    public function removeItem(objectId : String){
        theWorkspaceDataStore.suspendEvents();

        var firstNode :Dynamic = theWorkspaceDataStore.getRootNode().findChild('objectId', objectId, true);

        if(firstNode.get('type') != 'folder'){
            removeObject(objectId, true);
        }else{
            Ext.suspendLayouts();

            WorkspaceApplication.suspendUpdates();

            var objectIdsToRemove = getObjectIdsBelow(firstNode);

            for(woId in objectIdsToRemove){
                removeObject(woId, false);
            }

            firstNode.parentNode.removeChild(firstNode, false, false, true);

            Ext.resumeLayouts(true);

            reloadWorkspace();
        }
    }

    private function duplicateItem(objectId : String){
        theWorkspaceDataStore.suspendEvents();

        var firstNode :Dynamic = theWorkspaceDataStore.getRootNode().findChild('objectId', objectId, true);

        if(firstNode.get('type') != 'folder'){
            duplicateObject(objectId, true);
        }else{
            Ext.suspendLayouts();

            var objectIdsToDuplicate = getObjectIdsBelow(firstNode);

            var folder = _addFolder(firstNode.get('text'), firstNode.parentNode);

            for(woId in objectIdsToDuplicate){
                duplicateObject(woId, false, folder);
            }

            reloadWorkspace();
        }
    }

    private function duplicateObject(objectId: String, refresh, folder = null){
        var object :WorkspaceObject<Dynamic> = getObject(objectId);

        if(folder == null){
            folder = theWorkspaceDataStore.getRootNode().findChild('objectId', objectId, true).parentNode;
        }

        var workspaceObj = object.clone();
        if(workspaceObj != null){
            _addObject(workspaceObj, false, refresh, folder);
        }else {
            Ext.Msg.alert('','Duplicate not supported for object');
        }
    }

    public function closeItem(itemId : String){
        var firstNode :Dynamic = theWorkspaceDataStore.getRootNode().findChild('objectId', itemId, true);

        if(firstNode.get('type') != 'folder'){
            closeObject(itemId);
        }else{
            var objectIdsToClose = getObjectIdsBelow(firstNode);

            for(woId in objectIdsToClose){
                _closeObject(woId, false);
            }

            reloadWorkspace();
        }
    }

    public function findNode(itemId : String){
        return theWorkspaceDataStore.getRootNode().findChild('objectId', itemId, true);
    }

    public function getObjectIdsBelow(node){
        var nodes = [node];

        var objectIdsToRemove = new Array<String>();
        while(nodes.length > 0){
            var node = nodes.pop();

            var children :Array<Dynamic> = node.childNodes;

            if(children != null){
                for(child in children){
                    nodes.push(child);
                }
            }

            if(node.get('type') != 'folder'){
                objectIdsToRemove.push(node.get('objectId'));
            }
        }

        return objectIdsToRemove;
    }

    /**
    * getTreeAsSimple returns the Workspace tree in a form suitable for serialisation
    *
    * Algorithm details:
    *
    * Deep-first search algorithm which traverses the EXTJS tree store from the root.
    *
    * Each discovered node is added to the stack with a wrapper object which includes
    * a reference to the EXTJS tree node.  Once the node has been visited the reference
    * to the EXTJS tree node is removed from the wrapper object.  This technique gives
    * us a very simple iterative algorithm which generates a final tree without
    * references to the EXTJS models.
    **/
    public function getTreeAsSimple(){
        //Initialise with root node
        var nodes :Array<Dynamic> = [{model: theWorkspaceDataStore.getRootNode()}];

        //Hold a reference to the root node
        var root : Dynamic = nodes[0];

        //Visit nodes until none are left to visit
        while(nodes.length > 0){
            //Get next node to visit
            var node = nodes.pop();

            //Copy properties from model
            node.text = node.model.get('text');
            node.objectId = node.model.get('objectId');
            node.type = node.model.get('type');
            node.leaf = node.model.get('leaf');
            node.expanded = node.model.get('expanded');
            node.icon = node.model.get('icon');

            //Create new child node array
            node.children = [];

            //Get child nodes from model
            var childNodes : Array<Dynamic> = node.model.childNodes;

            //Check for child nodes
            if(childNodes != null){
                //Iterate child nodes
                for(childNode in childNodes){
                    //Create new simple object for child
                    var childNodeObj = {model: childNode};

                    //Add new child node object to list of children
                    node.children.unshift(childNodeObj);

                    //Add new child node object to the list that need to be visited
                    nodes.push(childNodeObj);
                }
            }

            //Remove model from node as it's no longer required
            node.model = null;
        }

        root = {'children' : root.children};

        //Return new root node which should be connected to all children
        return root;
    }

    public function beginUpdate(){
        Ext.suspendLayouts();
        theWorkspaceDataStore.suspendEvents();
    }

    /**
    *
    * Restoring the tree via either trying to fully rebuild via store.setRootNode
    * or appending children to the current root node results in numerous issues.
    *
    * Rather than wasting any more time this method will simply rebuild each node
    * via an Ext.Create to save any more hassle
    **/
    public function restoreTreeFromSimple(root : Dynamic){
        theWorkspaceDataStore.suspendEvents();
        Ext.suspendLayouts();

        var nodes :Array<Dynamic> = root.children;

        for(node in nodes){
            node.parentNode = theWorkspaceDataStore.getRootNode();
        }

        while(nodes.length > 0){
            var node = nodes.pop();

            var parentNode = node.parentNode;

            var treeNode = parentNode.appendChild(Ext.create('WorkspaceObject',{
                text: node.text,
                leaf: node.leaf,
                expandable: true,
                expanded: node.expanded,
                objectId: node.objectId,
                type: node.type,
                icon: node.icon
            }));

            var children :Array<Dynamic> = node.children;

            if(children != null && children.length > 0){
                for(child in children){
                    child.parentNode = treeNode;

                    nodes.push(child);
                }
            }
        }

        //theComponent.reconfigure(theWorkspaceDataStore);

        reloadWorkspace();
    }

    public function renameItem(objectId : String){
        var node = theWorkspaceDataStore.getRootNode().findChild('objectId', objectId, true);

        var dialog = Ext.Msg.prompt('Rename object', 'Type new name', function(btn, text){
            if(btn == 'ok'){
                if(node.get('type') == 'folder'){
                    node.set('text', text);
                    node.commit();

                    reloadWorkspace();
                }else{
                    renameWorkspaceObject(objectId, text);
                }
            }
        },this,false,node.get('text'));
    }

	/**
	 * renameWorkspaceObject Renames the WorkspaceObject to the given name
	 * 
	 * Note that all WorkspaceObjectListeners will be notified of this event
	 * incase they need to rename parts of their interface.
	 * 
	 * @param	objectId
	 * @param	newName
	 */
    public function renameWorkspaceObject(objectId : String, newName : String){
        var object : WorkspaceObject<Dynamic> = getObject(objectId);

        newName = generateName(newName,1,object.getUUID());

        nameToObjectUUID.remove(object.getName());

        var entity = object;
        if(Std.is(object, WorkspaceObject) ){
            entity = object.getObject();
        }

        var clazz = Type.getClass(entity);
        if(clazz != null){
            var model = WorkspaceApplication.getApplication().getProvider().getModel(clazz);

            if(model != null){
                var id_field = model.getFirstKey();

                if(id_field != null){
                    WorkspaceApplication.getApplication().getActiveProgram().setModelOutlineValue(id_field, newName);

                    Reflect.setField(entity, id_field, newName);
                }
            }
        }

        object.setName(newName);

        nameToObjectUUID.set(object.getName(), object.getUUID());

        var node = theWorkspaceDataStore.getRootNode().findChild('objectId', Std.string(objectId), true);
        if(node != null){
            node.set('text', newName);
            node.commit();
        }

        //reloadWorkspace();

        var program = getOpenProgram(objectId);
        if(program != null){
            program.setTitle(newName);
        }

        for(listener in theListeners){
            listener.objectRenamed(object);
        }

        reloadWorkspace();
    }
	
	private function initialiseDOMComponent() {
		initialiseDragAndDrop();
	}
	
	/**
	 * initialiseDragAndDrop Initialises the Workspace Tree so that files can be dropped onto it.
	 * 
	 */
	private function initialiseDragAndDrop() : Void {
		var elem : Dynamic = getDOMComponent();
		var self : Dynamic = this;
                                
        elem.addEventListener("dragenter", function(e){
            e.preventDefault();
            
			elem.style.backgroundColor = "rgba(168,168,168,0.5) ";
                    
            return false;
        });
                
        elem.addEventListener("dragexit", function(e){
            e.preventDefault();
                    
            elem.style.backgroundColor='green';
                    
            return false;
        });
                
        elem.addEventListener("dragover", function(e){
            e.preventDefault();
                      
            return false;
        });
		
		elem.addEventListener("dragleave", function(e){
            e.preventDefault();
            
			elem.style.backgroundColor='white';
			
            return false;
        });
                
        elem.addEventListener("drop", function(e) {
			// On file drop
			
			// Disable default action (i.e. open file in new/same window)
            e.preventDefault();
                    
			// Obtain handle to the drop file
            var file = e.dataTransfer.files[0];
                    
			// Pass file to Workspace for opening
            self.openFile(file);
			
			// Reset drop zone colour
			elem.style.backgroundColor='white';
                   
            return false;
        });
	}

    public function onFocus() : Void {
        
    }
    
    public function onBlur() : Void {
        
    }

    public function getComponent() : Dynamic {
        return theComponent;
    }

    public function getRawComponent() : Dynamic {
        return getRawComponent();
    }
    
	/**
	 * addListener Add a WorkspaceListener that will be notified as WorkspaceObjects
	 * are added, removed, or renamed.
	 * 
	 * @param	listener
	 */
    public function addListener(listener : WorkspaceListener) : Void {
        theListeners.add(listener);
    }
    
	/**
	 * removeListener Remove a WorkspaceListener from the Workspace
	 * 
	 * @param	listener
	 */
    public function removeListener(listener : WorkspaceListener) : Void {
        theListeners.remove(listener);
    }
	
	/**
	 * openFile Opens a file passed to it via a HTML5 file drop event
	 * @param	file
	 */
	public function openFile(file : Dynamic, openProgram : Bool) : Void {
        if(file == null){
            return;
        }

		var r = ~/\.(\w+)/;

		r.match(file.name);
		
		var extension :String = r.matched(1);

        if(extension == 'zip'){
            openZipFile(file);
        }else if(extension == 'sat'){
            CommonCore.getFileAsText(file, function(contents){
                var obj : Dynamic = Unserializer.run(contents);

                _openWorkspace(obj);
            });
        }else{
            var programRegistry : ProgramRegistry = WorkspaceApplication.getApplication().getProgramRegistry();

            // Get the class of the Program associated with the file extension
            var clazz : Class<Dynamic> = programRegistry.getDefaultProgramByFileExtension(extension);

            //Skip files we don't have a parser for
            if(clazz != null){
                if(Reflect.hasField(clazz, 'parseFile')){
                    var func = Reflect.field(clazz, 'parseFile');

                    Reflect.callMethod(clazz, func, [file, null, openProgram]);
                }else{
                    // Create a new instance of the program
                    var program : Dynamic = Type.createInstance(clazz, []);

                    // Pass the new Program instance the file to deal with
                    // We need to improve how this works because we risk leaving hanging Program instances
                    program.openFile(file, true, openProgram);
                }
            }
        }
	}

    public function openZipFile(file : Dynamic){
        var load = function(buf){
            var zip = new JSZip(buf);

            var open = true;

            for(file in Reflect.fields(zip.files)){
                var fh = zip.file(file);

                openFile(fh, open);

                open = false;
            }
        }

        if(Std.is(file, FileShim)){
            load(file.getAsArrayBuffer());
        }else{
            var fileReader : Dynamic = untyped __js__('new FileReader()');

            fileReader.onload = function(e) {
                load(e.target.result);
            }

            fileReader.readAsArrayBuffer(file);
        }

    }
    
	/**
	 * addObject Add a WorkspaceObject to the Workspace.
	 * 
	 * autoOpen to true causes the WorkspaceObject to be opened with the default Program
	 * 
	 * @param	object
	 * @param	autoOpen
	 */
	public function addObject(object : Dynamic, autoOpen : Bool, folderNode : Dynamic = null) : Void {
		_addObject(object, autoOpen, true, folderNode);
	}

    public function getParentFolder(objectId : String) : Dynamic {
        var node = theWorkspaceDataStore.getRootNode().findChild('objectId', objectId, true);
        return node.parentNode;
    }

    private function generateName(name : String, nextId: Int, uuid : String) : String{
        if(!nameToObjectUUID.exists(name)){
            return name;
        }else if(nameToObjectUUID.get(name) == uuid){
            return name;
        }

        var newName = name + ' ('+nextId+')';
        if(nameToObjectUUID.exists(newName)){
            if(nameToObjectUUID.get(newName) == uuid){
                return newName;
            }else{
                return generateName(name, ++nextId, uuid);
            }
        }else{
            return newName;
        }
    }

    public function changeObjectType(objectId : String, model : Model) : Dynamic{
        var newObj = Type.createInstance(model.getClass(), []);

        return switchObject(objectId, newObj);
    }

    public function switchObject(objectId : String, newObj : Dynamic) : Dynamic{
        if(!Std.is(newObj, WorkspaceObject)){
            Workspace.installWorkspaceExtensions(newObj);
        }

        var currentObject : WorkspaceObject<Dynamic> = getObject(objectId);

        newObj.setUUID(currentObject.getUUID());

        newObj.setName(currentObject.getName());

        _addObject(newObj, false, false, null, true);

        //TODO: remove this additional call
        if(Reflect.isFunction(newObj.setup)){
            newObj.setup();
        }

        return newObj;
    }

    public function _addObject(object : Dynamic, autoOpen : Bool, reload : Bool, folderNode : Dynamic = null, replacing = false) : Void{
        if(object == null){
            return;
        }

        // Add support for any object type
        if(!Std.is(object, WorkspaceObject) && !Reflect.hasField(object, '__WOEXTENSIONS')){
            Workspace.installWorkspaceExtensions(object);
        }

        //In the past an object passed to this method always had a new ID generated
        //Session restoration needs existing IDs taken into account
        if(object.getUUID() == null || object.getUUID() == ''){
            object.setUUID(Std.string(this.nextObjectId));

            var name = generateName(object.getName(),1, object.getUUID());
            object.setName(name);

            this.nextObjectId++;
        }

        // Handle cases where an object is already presentin the workspace
        if(theObjects.exists(object.getUUID()) && theObjects.get(object.getUUID()) == object){
            if(autoOpen){
                setActiveObject(object.getUUID());
            }
            return;
        }

        nameToObjectUUID.set(object.getName(), object.getUUID());
        
        theObjects.set(object.getUUID(), object);

        for(listener in theListeners){
            listener.objectAdded(object);
        }
        
        if(autoOpen){
            setActiveObject(object.getUUID());
        }

		if(replacing == false && !isTreeUpdatesSuspended()){
            var rootNode : Dynamic = theWorkspaceDataStore.getRootNode();

            var folderName : String = 'Objects';

            if(folderNode == null){
                var clazz = Type.getClass(object);

                var className : String;
                if(clazz != null){
                    var o = object;

                    if(Std.is(object, WorkspaceObject)){
                        o = object.getObject();
                    }

                    var ot = Type.getClass(o);

                    var model = WorkspaceApplication.getApplication().getProvider().getModel(ot);

                    if(model != null){
                        folderName = model.getAlias();
                    }else{
                        if(Reflect.hasField(clazz, 'getDefaultFolderName')){
                            folderName = Reflect.callMethod(clazz, Reflect.field(clazz,'getDefaultFolderName'), []);
                        }else{
                            folderName = Type.getClassName(clazz);
                        }
                    }
                }
            }

            if(folderNode == null){
                folderNode = theWorkspaceDataStore.getRootNode().findChild('text', folderName, false);
            }else if(Std.is(folderNode, String)){
                folderName = folderNode;

                folderNode = theWorkspaceDataStore.getRootNode().findChild('text', folderName, false);
            }

            if(folderNode == null){
                folderNode = rootNode.appendChild(Ext.create('WorkspaceObject',{
                    text: folderName,
                    leaf: false,
                    expanded: true,
                    objectId: this.nextObjectId++,
                    type: 'folder'
                }));
            }

            folderNode.appendChild(Ext.create('WorkspaceObject',{
                text : object.getName(),
                leaf : true,
                expanded : true,
                objectId : object.getUUID(),
                type: 'object',
                //iconCls: 'x-btn-structure',
                icon: object.getIconPath()
            }));
		}

        if(reload){
            reloadWorkspace();
        }
    }

    public function addFolderPrompt(objectId: String){
        var dialog = Ext.Msg.prompt('Add Folder', 'Folder name', function(btn, text){
            if(btn == 'ok'){
               addFolder(objectId, text);
            }
        },this,false,'');
    }

    public function addFolder(objectId : String, folderName : String){
        var folderNode;

        if(objectId == null){
            folderNode = theWorkspaceDataStore.getRootNode();
        }else{
            folderNode = theWorkspaceDataStore.getRootNode().findChild('objectId', objectId, true);
        }

        var folder = _addFolder(folderName, folderNode);

        theComponent.view.refresh();

        return folder;
    }

    public function _addFolder(folderName, parentFolder=null){
        var nextId = nextObjectId++;

        if(parentFolder == null){
            parentFolder = theWorkspaceDataStore.getRootNode();
        }

        var folder = parentFolder.appendChild(Ext.create('WorkspaceObject',{
            text: folderName,
            leaf: false,
            expanded: true,
            id: nextId,
            objectId: nextId,
            type: 'folder'
        }));

        return folder;
    }
    
	/**
	 * Method returns the WorkspaceObject associated with the given ID or null
	 * 
	 * Underscore support within ID 
	 * 
	 * A WorkspaceObject can only be referenced once within the OutlinePanel as a single ID
	 * can't be associated with multiple nodes on the tree.  To get around this issue you
	 * can append an "_INT" to the real WorkspaceObject ID.  For convenience this method can 
	 * be passed such an ID directly.
	 * 
	 * Generic return type
	 * 
	 * The type of the object returned by this method is determined by the left-side of the 
	 * expression that is calling the method.
	 * 
	 * i.e. the following is valid
	 * 
	 * var ligationObj : LigationObject = workspace.getObject('1');
	 * 
	 * Internally this is achieved by casting the WorkspaceObject to Dynamic before it is returned.
	 * Therefore if the WorkspaceObject doesn't descend from the type found on the left-side of 
	 * the expression, a class cast exception will be thrown at runtime.  To obtain the object
	 * without running the risk of a ClassCastException please call getObjectSafely instead.
	 * 
	 * @param	id
	 * @return WorkspaceObject<Dynamic> or null if the ID doesn't correspond to an object
	 */
    public function getObject(id : String) : Dynamic {
		return cast getObjectSafely(id, null);
    }

    public function _getObject(id) : WorkspaceObject<Dynamic>{
        var obj : WorkspaceObject<Dynamic> = getObjectSafely(id, null);

        return obj;
    }
	
	/**
	 * Method returns the WorkspaceObject associated with the given ID or null
	 * 
	 * Underscore support within ID 
	 * 
	 * A WorkspaceObject can only be referenced once within the OutlinePanel as a single ID
	 * can't be associated with multiple nodes on the tree.  To get around this issue you
	 * can append an "_INT" to the real WorkspaceObject ID.  For convenience this method can 
	 * be passed such an ID directly.
	 * 
	 * Generic return type
	 * 
	 * The type of the object returned by this method is determined by the left-side of the 
	 * expression that is calling the method.
	 * 
	 * i.e. the following is valid
	 * 
	 * var ligationObj : LigationWO = workspace.getObject('1', LigationWO);
	 * 
	 * The type parameter is used to determine at run-time if the WorkspaceObject can safely be
	 * cast to the type indicated by the left-side of the expression.  When the object can't be 
	 * cast to the type a null value is thrown. 
	 * 
	 * Null return value
	 * 
	 * A null value will be returned if the object doesn't exist or the object can't be cast to 
	 * the supplied type.  This is for convenience so that you don't have to embed calls to this
	 * method within a try/catch block.  To tell the difference between these two stats you will
	 * need to call the method isObject.
	 * 
	 * @param  id
	 * @param  type
	 * @return WorkspaceObject<Dynamic> or null if the ID doesn't correspond to an object
	 */
	public function getObjectSafely < T:WorkspaceObject<Dynamic> > (id : String,  type : Class<T>) : T {
		if (id == null) {
			return null;
		}
		
		id = convertId(id);
		
        if (theObjects.exists(id)) {
			var obj :Dynamic = theObjects.get(id);

			if (type == null) {
				return cast obj;
			}else{
				if(Std.is(obj, type)){
					return cast obj; 
				}else {
					return obj;
				}
			}
        }else{
            return null;
        }
	}
	
	public function isObject(id : String) {
		id = convertId(id);
		
		if (theObjects.exists(id)) {
			return true;
		}else {
			return false;
		}
	}
	
	public static function convertId(id : String) {
		var underScorePos : Int = id.indexOf('_');
		if (underScorePos > -1) {
			id = id.substring(0, underScorePos);
		}
		
		return id;
	}
	
	public function getAllObjects<T>(clazz: Class<T> ) : Array<T>{
		var objects : Array<T> = new Array<T>();
		
		for (objectId  in theObjects.keys()) {
			var object : Dynamic = theObjects.get(objectId);
			if (Std.is(object, clazz)) {
				objects.push(object);
			}
		}
		
		return objects;
	}

    public function getObjectsByClass(clazz: Class<Dynamic> ) : Array<Dynamic>{
        var objects : Array<Dynamic> = new Array<Dynamic>();

        for (objectId  in theObjects.keys()) {
            var object : Dynamic = theObjects.get(objectId);
            if (Std.is(object, clazz)) {
                objects.push(object);
            }
        }

        return objects;
    }
    
    public function reloadWorkspace() : Void {
        theWorkspaceDataStore.resumeEvents();

        theComponent.view.refresh();

        theWorkspaceDataStore.sync();

        Ext.resumeLayouts(true);

        //WorkspaceApplication.resumeUpdates(false);

        //if(Lambda.count(theObjects) == 0) return;

		/*WorkspaceApplication.suspendUpdates();
		
        var rootNode : Dynamic = theWorkspaceDataStore.getRootNode();
        
		//theWorkspaceDataStore.suspendEvents(false);
		
        rootNode.removeAll();

        var treeItems = new Array<Dynamic>();

        for(object in this.theObjects){
            treeItems.push(Ext.create('WorkspaceObject',{
                text : object.getName(),
                leaf : true,
                expanded : true,
                objectId : object.getUUID()
            }));
        }

        if(treeItems.length > 0){
            rootNode.appendChild(treeItems);
        }

		WorkspaceApplication.resumeUpdates(true);*/
		
		//theWorkspaceDataStore.resumeEvents();
    }

    public function serialise(cb) : Void {
        // Give each program a change to perform an async action before we actually save
        var programs = [];
        for (programObj in programIdToProgram) {
            programs.push(programObj);
        }

        var next = null;

        next = function(){
            if(programs.length == 0){
                //Actually perform the save operation here
                cb(_serialise());
                return;
            }

            var program = programs.pop();

            program.saveWait(next);
        };

        next();
    }
    
	public function _serialise() : Dynamic {
		var serialisedObjects  : Array<Dynamic> = new Array<Dynamic>();
		
		var retVal : Dynamic = {
			workspaceName: theWorkspaceName,
			nextObjectId : nextObjectId,
            nextProgramId: nextProgramId,
			workspaceObjects : [],
			programs : [],
			programStateMap : { },
			activeProgramId : WorkspaceApplication.getApplication().getActiveProgramId()
		}
		
		var i :Int  = 0;

		for (workspaceObj in theObjects) {
            var fieldMap = new Map<String, Dynamic>();

            for(field in Reflect.fields(workspaceObj)){
                var val :Dynamic = Reflect.field(workspaceObj, field);
                if(val != null && (Std.is(val, WorkspaceObject) || Reflect.hasField(val, '__WOEXTENSIONS'))){
                    fieldMap.set(field, val);

                    Reflect.setField(workspaceObj, field, '__LINKED_' + val.getUUID());
                }
            }


			retVal.workspaceObjects[i] = workspaceObj.serialise();

            for(field in fieldMap.keys()){
                Reflect.setField(workspaceObj, field, fieldMap.get(field));
            }
			
			i++;
		}
		
		i = 0;

        for (programObj in programIdToProgram) {
            retVal.programs[i] = programObj.serialise();
            i++;
        }

		for (objectId in objectIdToOpenProgramId.keys()) {
			retVal.programStateMap.objectId = objectIdToOpenProgramId.get(objectId);
		}
		
		retVal.programStateMap = objectIdToOpenProgramId;

        retVal.workspaceTree = getTreeAsSimple();
		
		return retVal;
	}

    public function getWorkspaceName(){
        return this.theWorkspaceName;
    }

    public  function setWorkspaceName(workspaceName : String){
        this.theWorkspaceName = workspaceName;
    }	

	public function openDefaultWorkspace() {
		openWorkspace("DEFAULT");
	}
	
	public function openWorkspace(workspaceName) {
		theWorkspaceDatabase.query(workspaceName, function(e) { WorkspaceApplication.getApplication().showMessage('',e); }, function(workspaceObject) {


            _openWorkspace(workspaceObject);
		} ); 
	}

    public function suspendTreeUpdates(suspend : Bool){
        treeUpdatesSuspended = suspend;
    }

    public function isTreeUpdatesSuspended() : Bool{
        return treeUpdatesSuspended;
    }

    var reg_linked =~/__LINKED_(\d+)/;

    public function _openWorkspace(workspaceObject : Dynamic){
        closeWorkspace();

        restoreTreeFromSimple(workspaceObject.workspaceTree);

        theWorkspaceName = workspaceObject.workspaceName;

        //return;

        Ext.suspendLayouts();

        suspendTreeUpdates(true);

        var objects : Array<Dynamic> = cast workspaceObject.workspaceObjects;

        for(workspaceObject in objects){
            var unserObj = Unserializer.run(workspaceObject);

            // Install WorkspaceObject extension functions if non WorkspaceObject type
            var clazz = Type.getClass(unserObj);

            if(clazz != null){
                if(!Std.is(unserObj, WorkspaceObject)){
                    installWOExtensionFunctions(unserObj);
                }
            }
            //addObject(unserObj, false);

            _addObject(unserObj, false, false);
        }

        for(uuid in theObjects.keys()){
            var obj = theObjects.get(uuid);
            for(field in Reflect.fields(obj)){
                var val :Dynamic = Reflect.field(obj, field);

                if(val != null && Std.is(val, String) && reg_linked.match(val)){
                    var linkedId = reg_linked.matched(1);

                    Reflect.setField(obj, field, theObjects.get(linkedId));
                }
            }
        }

        setReloading(true);

        var progReg : ProgramRegistry = WorkspaceApplication.getApplication().getProgramRegistry();
        var programs : Array<Dynamic> = cast workspaceObject.programs;
        for (program in programs) {
            var newProg : Dynamic = Type.createInstance(Type.resolveClass(program.CLASS),[]);

            newProg.deserialise(program);

            progReg.installPlugins(newProg);

            registerProgram(newProg);
        }

        var programStateMap : Dynamic = workspaceObject.programStateMap;

        for (field in Reflect.fields(programStateMap.h)) {
            var programId :String = Reflect.field(programStateMap.h, field);

            var objectId : String = field;//field.substring(1, field.length);

            var program = getProgram(programId);

            registerObjectWith(getObject(objectId), program);

            program._setActiveObject(objectId);

            program.setTitle(_getObject(objectId).getName());

            setActiveObject(objectId);

            program.postRestore();
        }

        setReloading(false);

        /*for (program in programIdToProgram) {
            setActiveObject
            program.postRestore();
        }*/

        if(workspaceObject.activeProgramId != "-1"){
            setActiveObject(getProgram(workspaceObject.activeProgramId).getActiveObjectId());
            //WorkspaceApplication.getApplication().setActiveProgram(getProgram(workspaceObject.activeProgramId));
        }

        nextObjectId = workspaceObject.nextObjectId;
        nextProgramId = workspaceObject.nextProgramId;

        for(objId in theObjects.keys()){
            var wo = theObjects.get(objId);

            if(Std.is(wo, TextFileWO)){
                var obj = wo.getObject();


                if(obj.autoRun){
                    if(obj.value != null){
                        TextEditor.runCode(obj.value);
                    }
                }
            }
        }

        Ext.resumeLayouts(true);

        suspendTreeUpdates(false);

        Ext.suspendLayouts();
        Ext.resumeLayouts(true);
    }

    public function getWorkspaceNames(onSuccess : Dynamic){
        theWorkspaceDatabase.getWorkspaceNames(onSuccess);
    }

    public static function generateClass(name : String){
        untyped __js__('$hxClasses[name] = function(){};');
        untyped __js__('$hxClasses[name].__name__ = name.split(\'.\')');
    }

    public static function installWorkspaceExtensions(obj : Dynamic){
        obj.uuid = null;
        obj.iconPath = null;

        if(!Reflect.hasField(obj, 'name') || Reflect.field(obj, 'name') == null || Reflect.field(obj, 'name') == ''){
            var name = 'Object';

            var clazz = Type.getClass(obj);
            if(clazz != null){
                var model = WorkspaceApplication.getApplication().getProvider().getModel(clazz);

                if(model != null){
                    var nameField = model.getFirstKey();
                    if(Reflect.hasField(obj, nameField)){
                        name = Reflect.field(obj, nameField);
                    }
                }
            }

            obj.name = name;
        }

        var clazz = Type.getClass(obj);
        if(clazz != null){
            var model = WorkspaceApplication.getApplication().getProvider().getModel(clazz);

            if(model != null){
                var icon = model.getIcon();

                if(icon != null){
                    obj.iconPath = '/static/js/images/' + icon;
                }
            }
        }

        obj.object = null;
        obj.hidden = null;
        
        var type_str = untyped __typeof__(obj.__class__);

        if(type_str != 'function' || Reflect.field(obj, '__class__') == null || Reflect.field(obj, '__class__') == ''){
            obj.__class__ = 'GENERIC';
        }

        obj.objectMap = new Map<String, Array<String>>();

        installWOExtensionFunctions(obj);

        obj.__WOEXTENSIONS = true;
    }

    private static function removeWOExtensionFunctions(obj : Dynamic){
        obj.clone = null;
        obj.getIconPath = null;

        obj.serialise = null;

        obj.deserialise = null;

        obj.setName = null;

        obj.getName = null;

        obj.getUUID = null;

        obj.setUUID = null;

        obj.getObject = null;

        obj.setObject = null;

        obj.toJSON = null;

        obj.isHidden = null;

        obj.hide = null;

        obj.addReference = null;

        obj.getReferences = null;

        obj.hasReference = null;

        obj.removeReferences = null;

        obj.getMatchingReferences = null;
    }

    private static function installWOExtensionFunctions(obj : Dynamic){
        obj.clone = function(): WorkspaceObject<Dynamic> {
            var cloneData = obj.serialise();

            var unserObj : WorkspaceObject<Dynamic> = cast Unserializer.run(cloneData);

            installWorkspaceExtensions(unserObj);

            unserObj.setUUID(null);

            return unserObj;
        };

        obj.getIconPath = function(): String{
            return obj.iconPath;
        }

        var serFunc = function(obj) : Dynamic {
            return Serializer.run(obj);
        };

        obj.serialise = function() : Dynamic {
            Workspace.removeWOExtensionFunctions(obj);

            var serial = serFunc(obj);

            Workspace.installWorkspaceExtensions(obj);

            return serial;
        };

        obj.deserialise = function(object : Dynamic) : Void{
            obj.setName(object.NAME);
            obj.setUUID(object.UUID);
            obj.hide(object.HIDDEN);
            obj.setIconPath(object.iconPath);
        };

        obj.setName = function(name : String) : Void {
            obj.name = name;

            var model = WorkspaceApplication.getApplication().getProvider().getModel(Type.getClass(obj));

            var field = model.getFirstKey();

            if(field != null){
                Reflect.setField(obj, field, name);
            }
        }

        obj.getName = function() : String {
            return obj.name;
        };


        obj.getUUID = function () : String {
            return obj.uuid;
        }

        obj.setUUID = function(uuid : String) : Void {
            obj.uuid=uuid;
        }

        obj.getObject = function() : Dynamic {
            return obj;
        };

        obj.setObject = function(object : Dynamic) : Void{
            obj.object=object;
        };

        obj.toJSON = function () : String {
            return "";
        };

        obj.isHidden = function() : Bool {
            return obj.hidden;
        };

        obj.hide = function(hide : Bool) : Void {
            obj.hidden = hide;
        };

        obj.addReference = function(group : String, objectId : String){
            if(!obj.objectMap.exists(group)){
                obj.objectMap.set(group, new Array<String>());
            }

            obj.objectMap.get(group).push(objectId);
        }

        obj.getReferences = function(group : String) : Array<String>{
            var refs = new Array<String>();

            if(obj.objectMap.exists(group)){
                var ids : Array<String> = obj.objectMap.get(group);
                for(objectId in ids){
                    refs.push(objectId);
                }
            }

            return refs;
        }

        obj.hasReference = function(group : String, objectId : String) : Bool {
            var match = false;

            if(obj.objectMap.exists(group)){
                var ids : Array<String> = obj.objectMap.get(group);
                for(id in ids){
                    var cId = Workspace.convertId(id);

                    if(cId == objectId){
                        match = true; break;
                    }
                }
            }

            return match;
        }

        obj.removeReferences = function(referenceId : String) : Array<String>{
            var removed = new Array<String>();

            var map :Map<String, Array<String>>= obj.objectMap;

            for(group in map.keys()){
                var ids : Array<String> = obj.objectMap.get(group);
                for(objectId in ids){
                    if(referenceId == objectId || Workspace.convertId(objectId) == referenceId){
                        obj.objectMap.get(group).remove(objectId);
                        removed.push(objectId);
                    }
                }
            }

            return removed;
        }

        obj.getMatchingReferences = function(referenceId : String) : Array<String>{
            var refs = new Array<String>();

            var map :Map<String, Array<String>>= obj.objectMap;

            for(group in map.keys()){
                var ids : Array<String> = obj.objectMap.get(group);
                for(objectId in ids){
                    if(referenceId == objectId || Workspace.convertId(objectId) == referenceId){
                        refs.push(objectId);
                    }
                }
            }

            return refs;
        }
    }
}

interface WorkspaceListener {
    function objectAdded(object : WorkspaceObject<Dynamic>) : Void;
    function objectRemoved(object : WorkspaceObject<Dynamic>) : Void;
    function objectRenamed(object : WorkspaceObject<Dynamic>) : Void;
}

interface WorkspaceObject<T> {
    function getName() : String;
	function setName(name : String) : Void;
    function getUUID() : String;
    function setUUID(uuid : String) : Void;
    function getObject() : T;
    function setObject(object : Dynamic) : Void;
    function toJSON() : String;
    function isHidden() : Bool;
    function hide(hide : Bool) : Void;
	function serialise() : Dynamic;
	function deserialise(object : Dynamic) : Void;
	function clone() : WorkspaceObject<T>;
    function getDocId() : String;
    function setDocId(docId : String) : Void;
    function setDomainObj(obj : Dynamic) : Void;
    function getDomainObj() : Dynamic;
    function addReference(group : String, objectId : String) : Void;
    function getReferences(group : String) : Array<String>;
    function hasReference(group : String, objectId : String) : Bool;
    function removeReferences(objectId : String) : Array<String>;
    function getMatchingReferences(referenceId : String) : Array<String>;
    function getIconPath() : String;
    function setIconPath(iconPath : String) : Void;
}

class WorkspaceObjectBase<T> implements WorkspaceObject<T> {
    var uuid : String;
    var name : String;
    var object : Dynamic;
    var hidden : Bool;
    var docId : String;
    var iconPath : String;
	
	var fileImportExtensions : Array<String>;

    var domainObj : Dynamic;

    var objectMap : Map<String, Array<String>>;
    
    public function new(object : Dynamic, name : String){
        this.object = object;
        this.name = name;
        this.objectMap = new Map<String, Array<String>>();
    }

    public function getIconPath() : String  {
        return iconPath;
    }

    public function setIconPath(iconPath) : Void {
        this.iconPath = iconPath;
    }

    public function setDomainObj(obj: Dynamic){
        this.domainObj = obj;
    }

    public function getDomainObj(): Dynamic{
        return this.domainObj;
    }
	
	public function clone() : WorkspaceObject<T> {
		var cloneData = this.serialise();

        var unserObj : WorkspaceObject<T> = cast Unserializer.run(cloneData);

        unserObj.setUUID(null);

        return unserObj;
	}

    public function setDocId(docId :String) : Void{
        this.docId = docId;
    }

    public function getDocId() : String{
        return this.docId;
    }

	public function serialise() : Dynamic {
		/*var clazz : Class<Dynamic> = Type.getClass(this);
		
		var serialisedObject : Dynamic = {
			CLASS : Type.getClassName(clazz),
			NAME : name,
			UUID : uuid,
			HIDDEN : hidden
		};
		
		return serialisedObject;*/

        return Serializer.run(this);
	}
	
	public function deserialise(object : Dynamic) : Void{
		setName(object.NAME);
		setUUID(object.UUID);
		hide(object.HIDDEN);
        setIconPath(object.iconPath);
	}
	
	public function setName(name : String) : Void {
		this.name = name;
	}
    
    public function getName() : String {
        return name;
    }
    
    public function getUUID() : String {
        return uuid;
    }
    
    public function setUUID(uuid : String) : Void {
        this.uuid=uuid;
    }
    
    public function getObject() : T {
        return object;
    }
    
    public function setObject(object : Dynamic) : Void{
        this.object=object;
    }
    
    public function toJSON() : String {
        return "";
    }
    
    public function isHidden() : Bool {
        return hidden;
    }
    
    public function hide(hide : Bool) : Void {
        this.hidden = hide;
    }

    public function addReference(group : String, objectId : String){
        if(!this.objectMap.exists(group)){
            this.objectMap.set(group, new Array<String>());
        }

        this.objectMap.get(group).push(objectId);
    }

    public function getReferences(group : String) : Array<String>{
        var refs = new Array<String>();

        if(this.objectMap.exists(group)){
            for(objectId in this.objectMap.get(group)){
                refs.push(objectId);
            }
        }

        return refs;
    }

    public function hasReference(group : String, objectId : String) : Bool {
        var match = false;

        if(this.objectMap.exists(group)){
            for(id in this.objectMap.get(group)){
                var cId = Workspace.convertId(id);

                if(cId == objectId){
                    match = true; break;
                }
            }
        }

        return match;
    }

    public function removeReferences(referenceId : String) : Array<String>{
        var removed = new Array<String>();

        for(group in this.objectMap.keys()){
            for(objectId in this.objectMap.get(group)){
                if(referenceId == objectId || Workspace.convertId(objectId) == referenceId){
                    this.objectMap.get(group).remove(objectId);
                    removed.push(objectId);
                }
            }
        }

        return removed;
    }

    public function getMatchingReferences(referenceId : String) : Array<String>{
        var refs = new Array<String>();

        for(group in this.objectMap.keys()){
            for(objectId in this.objectMap.get(group)){
                if(referenceId == objectId || Workspace.convertId(objectId) == referenceId){
                    //this.objectMap.get(group).remove(objectId);
                    refs.push(objectId);
                }
            }
        }

        return refs;
    }
}

class WorkspaceStore {
	var databaseName : String;
	var version : Int;
	
	var conn : Dynamic;
    var onErrorAction : Dynamic;
	
	public function new(databaseName : String, version : Int, onErrorAction) {
		this.databaseName = databaseName;
		this.version = version;
        this.onErrorAction = onErrorAction;
		
		init();
	}

    public function init(){
        if(untyped __js__('window.indexedDB')){ //tmp
            var request : Dynamic = IndexedDB.open(databaseName, version);

            request.onupgradeneeded = function(e) {
                var db : Dynamic = e.target.result;

// A versionchange transaction is started automatically.
                e.target.transaction.onerror = onErrorAction;

                if(db.objectStoreNames.contains(databaseName)) {
                    db.deleteObjectStore(databaseName);
                }

                var store = db.createObjectStore(databaseName,
                {keyPath: "workspaceName"});
            };

            request.onsuccess = function(e) {
                conn = e.target.result;
            }

            request.onerror = onErrorAction;
        }
    }
	
	public function store(object : Dynamic, onErrorAction : Dynamic, onSuccessAction : Dynamic) {
		var trans : Dynamic = conn.transaction([databaseName], "readwrite");
		var store : Dynamic = trans.objectStore(databaseName);
			
		var request : Dynamic = store.put(object);
		
		//request.onsuccess = onSuccess;
		
		//request.onerror = onError;
	}
	
	public function query(key : String, onError : Dynamic, onSuccess : Dynamic) {
		var trans :Dynamic = conn.transaction([databaseName]);
		var objectStore :Dynamic = trans.objectStore(databaseName);
		
		var request :Dynamic = objectStore.get(key);
		request.onerror = onError;
		
		request.onsuccess = function(result){
            onSuccess(result.target.result);
        };
	}

    public function getWorkspaceNames(onSuccess) : Void {
        var trans : Dynamic = conn.transaction([databaseName], "readonly");
        var objectStore : Dynamic = trans.objectStore(databaseName);

        var workspaceNames : Array<String> = new Array<String>();

        objectStore.openCursor().onsuccess = function(event){
            var cursor : js.html.idb.Cursor = untyped __js__('this.result');
            if(cursor != null){
                workspaceNames.push(cursor.key);
                cursor.advance(1);
            }else{
                onSuccess(workspaceNames);
            }
        }
    }
}

class WorkspaceStoreProvider extends WorkspaceStore {

    public function new(databaseName : String, version : Int, onErrorAction) {
        super(databaseName, version, onErrorAction);


    }

    override public function store(rawSession : Dynamic, onErrorAction : Dynamic, onSuccessAction : Dynamic) {
        var app =  WorkspaceApplication.getApplication();

        var name = ClientCore.getClientCore().getUser().fullname + ' - ' + rawSession.workspaceName;

        rawSession = Json.stringify(rawSession);

        app.getProvider().getByValue(name, saturn.core.domain.SaturnSession, 'sessionName',function(obj : SaturnSession, error){
            if(error != null){
                onErrorAction(error);
            }else{
                if(obj == null){
                    obj = new SaturnSession();
                    obj.sessionName = name;
                    obj.sessionContent = rawSession;
                    obj.isPublic = 'yes';

                    app.getProvider().insertObjects([obj], function(error : String){
                        //We could just evict obj from the cache but it's good to periodically clear the cache
                        app.getProvider().resetCache();

                        if(error != null){
                            onErrorAction(error);
                        }else{
                            onSuccessAction();
                        }
                    });
                }else{
                    obj.sessionContent = rawSession;

                    app.getProvider().updateObjects([obj], function(error : String){
                        //We could just evict obj from the cache but it's good to periodically clear the cache
                        app.getProvider().resetCache();

                        if(error != null){
                            onErrorAction(error);
                        }else{
                            onSuccessAction();
                        }
                    });
                }
            }
        });
    }

    override public function query(key : String, onError : Dynamic, onSuccess : Dynamic) {
        var app =  WorkspaceApplication.getApplication();

        if(key.indexOf('~') ==-1){
            key = ClientCore.getClientCore().getUser().fullname + ' - ' + key;
        }

        app.getProvider().getByValue(key, saturn.core.domain.SaturnSession, 'sessionName',function(obj : SaturnSession, error){
            //We could just evict obj from the cache but it's good to periodically clear the cache
            app.getProvider().resetCache();

            if(error != null){
                onError(error);
            }else{
                if(obj != null ){
                    var rawSession = obj.sessionContent;

                    rawSession = Json.parse(rawSession);

                    onSuccess(rawSession);
                }else{
                    onError("A default session doesn't exist for your account.");
                }

            }
        });
    }

    override public function getWorkspaceNames(onSuccess) : Void {
        var workspaceNames : Array<String> = new Array<String>();

        var app =  WorkspaceApplication.getApplication();

        app.getProvider().getByValues([ClientCore.getClientCore().getUser().username], saturn.core.domain.SaturnSession, 'userName',function(objs : Array<SaturnSession>, error){
            //We could just evict obj from the cache but it's good to periodically clear the cache
            app.getProvider().resetCache();

            var names = new Array<String>();
            if(objs != null){
                for(obj in objs){
                    names.push(obj.sessionName);
                }
            }

            onSuccess(names);
        });
    }

    override public function init(){

    }
}



class WorkspaceObjectNotFoundException extends HaxeException{
    public function new(message : String){
        super(message);
    }
}


/*

var folder1 = Ext.create('WorkspaceObject',{
            text: 'A Folder',
            leaf: false,
            expanded: true,
            objectId: '_folder_A Folder'
        });

        var item1 = Ext.create('WorkspaceObject',{
            text: 'Item1',
            leaf: false,
            expanded: true,
            objectId: 'Item2'
        });

        item1.appendChild(Ext.create('WorkspaceObject',{
            text: 'Item3',
            leaf: true,
            expanded: true,
            objectId: 'Item3'
        }));

        folder1.appendChild(item1);
 */
