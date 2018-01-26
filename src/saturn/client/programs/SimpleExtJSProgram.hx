/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.Protein;
import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.core.DNA;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.WorkspaceApplication;
import saturn.client.ProgramRegistry;
import saturn.client.BuildingBlock;
import saturn.client.EXTApplication;

import saturn.db.Model;

import saturn.client.workspace.Workspace;

import js.Lib;

import bindings.Ext;

/**
 * SimpleExtJSProgram
 * 
 * Developers should create plugins by extending this class unless though know what they are doing.
 * 
 * Class provides boiler plate code that allows for
 *  a) Automatic configuration of drop folders on the Outline Tree which can accept WorkspaceObjects dragged
 *     from the Workspace Tree
 *  b) Drop folders can be configured to only accept WorkspaceObjects of a particular class and can be configured
 *     to either accept one or many WorkspaceObjects
 *  c) Folder names are automatically compared against the list of setters for the plugin WorkspaceObject. 
 *     Matching setters are automatically called with the dropped WorkspaceObject
 * 
 * saturn.core.programs.LigationViewer is currently the simplest plugin that makes use of the new features above
 */
class SimpleExtJSProgram extends BaseProgram implements BuildingBlock implements WorkspaceListener {
	// Local WorkspaceObject indexes
	var folderToDropClass : Map <String, Class<Dynamic>> ; // Which class a drop folder supports
	var folderToAllowMany : Map <String, Bool>; // Stores whether a drop folder supports multiple WorkspaceObjects
	var folderToObjects : Map <String, Array<String>> ; // Stores which WorkspaceObjects are currently docked below a drop folder
	var objectToFolder : Map <String, String>; // Stores the folder a  WorkspaceObject is docked below
	
	var nextObjectValue = 0; // Counter used to make object IDs unique within a plugin

    public var mouseDown : Bool;

    public var inMouseMove : Bool;

    var autoConfigureOutline : Bool = false;
    var groupToTreeItem : Map<String, Dynamic>;

    var saveButton : Dynamic;
    var deleteButton : Dynamic;
	
	public function new() {
		super();
	}
	
	public function getDOMComponent() {
			return getComponent().el.dom;
	}
	
	override public function emptyInit() {
		folderToDropClass = new Map < String, Class<Dynamic> > ();
		folderToAllowMany = new Map < String, Bool >();
		folderToObjects = new Map < String, Array<String> > ();
		objectToFolder = new Map <String,String>();
        groupToTreeItem = new Map<String, Dynamic>();
		
		super.emptyInit();
		
		getWorkspace().addListener(this);
	}
	
	/**
	 * onFocus() is called when this plugin recieves the focus
	 * 
	 * Plugins must recreate their interface in full when they recieve this event
	 */
	override public function onFocus() : Void {
		super.onFocus();

        getApplication().enableProgramSearchField(false);

        getApplication().setProgramSearchFieldEmptyText('');

		installWindowListeners(js.Browser.window);

        restoreDropFolders();

        saveButton = getApplication().getToolBar().add({
            iconCls :'x-btn-save',
            text:'Save',
            handler: function(){
                saveObjectGUI();
            }
        });

        deleteButton = getApplication().getToolBar().add({
            iconCls :'x-btn-delete',
            text: 'Delete',
            handler: function(){
                deleteObjectGUI();
            }
        });
	}

	/**
	 * onBlur() is called when a plugin is blurred
	 * 
	 * For most plugins the default onBlur action will be enough
	 */
	override public function onBlur() : Void {
		super.onBlur();
		
		uninstallWindowListeners(js.Browser.window);

        getApplication().setInformationPanelText('', false);
        getApplication().setCentralInfoPanelText('');
	}
	
	override
    public function getComponent() : Dynamic {
		return null;
	}
	
	public function postRender() {
		initialiseDOMComponent();
	}

    override public function getCentralPanelLayout(){
        return 'border';
    }

	public function initialiseDOMComponent() {
        initialiseDragAndDrop();
    }

    private function initialiseDragAndDrop() : Void {
        var elem : Dynamic = getDOMComponent();
        var self : Dynamic = this;

        elem.onmousemove = function() {
            if(self.mouseDown==true){
                self.inMouseMove = true;
                self.selectionUpdated();
            }
        };

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

        elem.addEventListener("drop", function(e){
            e.preventDefault();

            var file = e.dataTransfer.files[0];

            self.openFile(file, false);

            elem.style.backgroundColor='white';

            return false;
        });
    }
	
	override
	public function setActiveObject(objectId : String) {
		super.setActiveObject(objectId);

        if(!delayedActivation){
            restoreDropFolders();
        }
	}

    override public function postRestore() : Void{
       // restoreDropFolders();
    }
	
	/**
	 * Print a message to the JS console
	 * @param	message
	 */
    public function printInfo(message : String){
        getApplication().printInfo(message);
    }
	
	/**
	 * Returns tree if the application is working in plugin full screen mode
	 * 
	 * In naked mode, the following components are not present
	 *   a) Workspace Tree
	 *   b) Outline Tree
	 *   c) Information Panel
	 *   d) Menus
	 * 
	 * Most plugins will probably not be compatible with this mode as it was designed
	 * specifcally for use within Scarab for the CrystalHelper
	 * 
	 * @return
	 */
	public function isNaked() : Bool{
		return getApplication().isNaked();
	}

	/**
	 * printStackTrace will cause a JS stack trace to be printed to the JS console
	 */
    public function printStackTrace(){
        var error = untyped  __js__('new Error()');
        printInfo(error.stack);
    }
	
	/**
	 * objectRenamed is called when a WorkspaceObject is renamed
	 * 
	 * Default implementation renames a corresponding instance located in the Outline tree
	 * 
	 * Be sure to call super.objectRenamed if you override this method
	 * 
	 * @param	object
	 */
	public function objectRenamed(object : WorkspaceObject<Dynamic>) : Void{
        var progObj = getState();
        var refs = progObj.getMatchingReferences(object.getUUID());

        for(ref in refs){
            var node = getApplication().getOutlineDataStore('DEFAULT').getRootNode().findChild('objectId', ref, true);
            if(node != null){
                node.set('text', object.getName());
                node.commit();
            }
        }


    }
	
	public function objectAdded(object : WorkspaceObject<Dynamic>) : Void{

    }
	
	/**
	 * objectRemoved is called when a WorkspaceObject has been deleted.
	 * 
	 * Default implementation calls removeObjectFromOutline() which will remove
	 * the object from the outline tree if it is present.
	 * 
	 * @param	object
	 */
    public function objectRemoved(object : WorkspaceObject<Dynamic>) : Void {
		removeObjectFromOutline(object.getUUID());
	}

    public function registerDropFolder(folderName : String, acceptClazz : Class<Dynamic>, allowMany : Bool){
        // Setup local indexes _folder_

        folderToDropClass.set(folderName, acceptClazz);
        folderToAllowMany.set(folderName, allowMany);

        folderToObjects.set(folderName, new Array<String>());

        autoConfigureOutline = true;
    }

    public function restoreDropFolders(){
        if(autoConfigureOutline){
            getApplication().installOutlineTree('DEFAULT',true, false, 'WorkspaceObject');

            Ext.suspendLayouts();

            for(folderName in folderToObjects.keys()){
                restoreDropFolder(folderName);
            }

            Ext.resumeLayouts(true);
        }
    }

    public function restoreDropFolder(folderName : String) {
		var app : WorkspaceApplication = getApplication();

        var dataStore : Dynamic = app.getOutlineDataStore('DEFAULT');

        var rootNode : Dynamic = dataStore.getRootNode();

		var workspaceFolder : Dynamic = rootNode.appendChild({
				text: folderName,
				leaf: false,
				expanded: true,
				id: '_folder_' +folderName
		});

        groupToTreeItem.set(folderName, workspaceFolder);

        var obj = getState();
        if(obj != null){
            for(objectId in obj.getReferences(folderName)){
                var object = app.getWorkspace()._getObject(objectId);
                workspaceFolder.appendChild(Ext.create('WorkspaceObject',{
                    text: object.getName(),
                    leaf: true,
                    objectId: objectId,
                    id: objectId,
                    icon: object.getIconPath()
                }));
            }

            getApplication().getOutlineTree('DEFAULT').on('itemcontextmenu', showTreeContextMenu,this);

            // Add support for those without access to right-click (i.e. Scarab users)
            getApplication().getOutlineTree('DEFAULT').on('itemclick' ,
                function(view, rec, item, index, event) {
                    if (event.ctrlKey) {
                        showTreeContextMenu(view, rec, item, index, event);
                    }
                }, this
            );
        }
	}

    public function showTreeContextMenu(view : Dynamic, record : Dynamic,
                                        item : Dynamic, index : Dynamic, event : Dynamic){
        var objectId = record.get('objectId');

        js.Browser.window.console.log('ID: ' + record.get('id'));

        if(record.get('id').indexOf('_folder_') == -1){
            if(objectId != ""){
                var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                    items: [
                        {
                            text : 'Remove',
                            handler : function(){
                                removeObjectFromOutline(objectId);
                            }
                        }
                    ]
                });

                contextMenu.showAt(event.getXY());

                event.stopEvent();
            }
        }else{
            var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                items: [
                    {
                        text : 'Remove All',
                        handler : function(){
                            var group = record.get('text');

                            var refs = getState().getReferences(group);
                            for(ref in refs){
                                removeObjectFromOutline(ref);
                            }
                        }
                    }
                ]
            });

            contextMenu.showAt(event.getXY());

            event.stopEvent();
        }
    }

    public function registerReference(objectId : String, group : String){
        var newId = objectId + '_' + getNextObjectId();

        objectAddedToOutline(group, newId);

        if(groupToTreeItem.exists(group)){
            groupToTreeItem.get(group).appendChild(Ext.create('WorkspaceObject',{
                text: getWorkspace()._getObject(objectId).getName(),
                leaf: true,
                objectId: newId,
                id: newId
            }));
        }
    }
	
	/**
	 * addWorkspaceDropFolder can be used to add a folder to the Outline tree onto
	 * which WorkspaceObjects can be dropped from the Workspace tree.
	 * 
	 * @param	folderName Name of folder/drop target
	 * @param	object WorkspaceObject associate with folder (set to null if you don't have one)
	 * @param	dropClass Restrict dropped objects to those that are instances of the supplied class
	 * @param	allowMany Flag to allow for multiple WorkspaceObjects to be associated with the same folder
	 */
	public function addWorkspaceDropFolder(folderName : String, object : Dynamic, dropClass : Class<Dynamic>, allowMany : Bool) {
		// Setup local indexes
		folderToDropClass.set(folderName, dropClass);
		folderToAllowMany.set(folderName, allowMany);
		
		if (!folderToObjects.exists(folderName)) {
			folderToObjects.set(folderName, new Array<String>());
		}
		
		// Add folder to Outline tree
		var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore : Dynamic = webApp.getOutlineDataStore('DEFAULT');
        
        var rootNode : Dynamic = dataStore.getRootNode();
		
		var workspaceFolder : Dynamic = rootNode.appendChild({
				text : folderName,
				leaf : false,
				expanded : true,
				id : folderName
		});
		
		// Add object below folder if one has been passed
		if (object != null) {
			var objectId = object.getUUID();
			var pseudoObjectId = objectId + '_' + getNextObjectId();
			
			folderToObjects.get(folderName).push(pseudoObjectId);
			
			workspaceFolder.appendChild(Ext.ModelManager.create({
				text : object.getName(),
				leaf : true,
				objectId : pseudoObjectId,
				id : pseudoObjectId
			},'WorkspaceObject'));
			
			objectAddedToOutline(folderName, pseudoObjectId);
		}
		
		getApplication().getOutlineTree('DEFAULT').on('itemcontextmenu', showTreeContextMenu,this);
		
		// Add support for those without access to right-click (i.e. Scarab users)
		getApplication().getOutlineTree('DEFAULT').on('itemclick' ,
			function(view, rec, item, index, event) {
				if (event.ctrlKey) {
                    showTreeContextMenu(view, rec, item, index, event);
				}
			}, this
		);
	}

    override public function close() {
        super.close();

        getWorkspace().removeListener(this);

        for(plugin in plugins){
            plugin.destroy();
        }

        getComponent().parentBuildingBlock = null;
    }
	
	/**
	 * objectAddedToOutline should be called when an object has been added to the Outline tree
	 * 
	 * Method will add the object to the internal list of objects that need to be tracked
	 * 
	 * The object will also be automatically passed to the active WorkspaceObject if it
	 * has a setter of the same name as the folder it is associated with
	 * 
	 * @param	dropFolder
	 * @param	objectID
	 */
	public function objectAddedToOutline(dropFolder :String, objectId : String) {
		var state : WorkspaceObject<Dynamic> = getState();

        state.addReference(dropFolder, objectId);
    }

    public function hasReference(dropFolder : String, objectId : String) : Bool{
        var state : WorkspaceObject<Dynamic> = getState();

        return state.hasReference(dropFolder, objectId);
    }
	
	public function removeObjectFromOutline(objectId : String) {
        var state = getState();

        if(state != null){
            var removed  = state.removeReferences(objectId);

            for(objectId in removed){
                var node :Dynamic = getApplication().getOutlineDataStore('DEFAULT').getRootNode().findChild('objectId', objectId, true);
                if(node != null){
                    node.parentNode.removeChild(node);
                }
            }
        }
	}
	
	/**
	 * workspaceObjectUpdated should be called anytime the workspace object has been updated
	 * 
	 * The default implementation calls this method when a field of the active WorkspaceObject
	 * has been updated by the 
	 */
	public function workspaceObjectUpdated() {
		
	}
	
	/**
	 * onOutlineDrop is called when an object is dropped onto the Outline tree.
	 * 
	 * This method is called before the actualy drop has taken place and can be voeted by this method.
	 * 
	 * Method checks if the drop target is in the list of those that can accept dropped objects and cancels
	 * the drop if either a) the folder isn't in the list or b) the object to be dropped isn't an instance of
	 * the configured value class for this folder.
	 * 
	 * @param	node
	 * @param	data
	 * @param	overModel
	 * @param	dropPosition
	 * @param	dropHandlers
	 * @param	eOpts
	 * @return
	 */
	override public function onOutlineDrop(node :Dynamic, data :Dynamic, overModel :Dynamic, dropPosition :Dynamic, dropHandlers :Dynamic, eOpts :Dynamic) : Bool{
        var objectId : String = data.records[0].get('objectId');
        var dropFolder = overModel.data.id;
        dropFolder = StringTools.replace(dropFolder, '_folder_', '');

        if(data.records[0].get('type') == 'folder'){
            var nodes = new Array<Dynamic>();
            var childIds = getWorkspace().getObjectIdsBelow(data.records[0]);

            var count = 0;

            for(childId in childIds){
                if(!hasReference(dropFolder, childId)){
                    var wo : WorkspaceObject<Dynamic> = getWorkspace().getObject(childId);
                    if (folderToDropClass.get(dropFolder) == null || Std.is(wo, folderToDropClass.get(dropFolder))) {

                        var childNode = getWorkspace().findNode(childId);
                        if(childNode != null){
                            var copy = childNode.copy();

                            var pseudoObjectId = childId + '_' + getNextObjectId();

                            copy.set('id', pseudoObjectId);
                            copy.set('objectId', pseudoObjectId);

                            nodes.unshift(copy);

                            objectAddedToOutline(dropFolder, pseudoObjectId);

                            count += 1;
                        }
                    }
                }
            }

            if(count > 0){
                data.records = nodes;

                return true;
            }
        }else{
            if (folderToDropClass.exists(dropFolder)) {
                var wo : WorkspaceObject<Dynamic> = getWorkspace().getObject(objectId);

                // Check that the object type can be dropped here
                if (folderToDropClass.get(dropFolder) == null || Std.is(wo, folderToDropClass.get(dropFolder))) {
                    var match = hasReference(dropFolder,objectId);

                    if(!match){
                         // To make it easy to have the same WorkspaceObject represented in multiple places
                        // on the Outline tree we automatically add a unique prefix to the object ID
                        // The object ID is unique only to the plugin and not across the program

                        var pseudoObjectId = objectId + '_' + getNextObjectId();

                        // Below is necessary update the state of the model which represents the WorkspaceObject in the Outline tree
                        //data.records[0].raw.objectId = pseudoObjectId;
                        //data.records[0].data.objectId = pseudoObjectId;

                        data.records[0] = data.records[0].copy();
                        data.records[0].data.id = pseudoObjectId;
                        data.records[0].data.objectId = pseudoObjectId;

                        // Add object to internal indexes and caller setting if there is one
                        // Note this method doesn't add the object to the Outline, as this is carried out by an EXTJS method
                        objectAddedToOutline(dropFolder, pseudoObjectId);

                        // Accept drop event
                        return true;
                    }
                }
            }
        }

        // Cancel drop event
        dropHandlers.cancelDrop();

        return false;
    }
	
	/**
	 * getNextObjectID returns the next available object ID prefix for this plugin
	 * @return
	 */
	public function getNextObjectId() : Int {
		var oldValue = nextObjectValue;
		
		nextObjectValue = nextObjectValue + 1;
		
		return oldValue;
	}
	
	override public function setTitle(title : String) {
		getComponent().setTitle(title);
	}

    public function registerAllFromWorkspace(clazz : Class<Dynamic>, group : String) {
		var workspace : Workspace = getWorkspace();

		var objs : Array<Dynamic> = workspace.getAllObjects(clazz);
        if(clazz == DNAWorkspaceObject){
            var objs2: Array<Dynamic> = workspace.getAllObjects(DNA);
            if(objs2 !=null){
                for(obj in objs2){
                    objs.push(obj);
                }
            }
        }

        if(clazz == ProteinWorkspaceObject){
            var objs2: Array<Dynamic> = workspace.getAllObjects(Protein);

            if(objs2 !=null){
                for(obj in objs2){
                    objs.push(obj);
                }
            }
        }

		WorkspaceApplication.suspendUpdates();

		for (obj in objs) {
			var objectId : String = obj.getUUID();

            registerReference(objectId, group);
		}

		WorkspaceApplication.resumeUpdates(true);
	}

    public function addModelToOutline(obj : Dynamic, clearAll : Bool, folderName : String = null){
        var dataStore :Dynamic = getApplication().getOutlineDataStore('MODELS');

        var rootNode : Dynamic = dataStore.getRootNode();

        if(clearAll){
            rootNode.removeAll();
        }

        Ext.suspendLayouts();

        var model = getProvider().getModel(Type.getClass(obj));
        var busKey = model.getFirstKey();

        if(folderName == null){
            folderName = Reflect.field(obj, busKey);
        }

        var fields = model.getUserFieldDefinitions();

        if(fields == null){
            return;
        }

        var workspaceFolder : Dynamic = rootNode.appendChild({
            folder: folderName,
            leaf: false,
            expanded: true,
            id: '_folder_' +folderName
        });

        for(field in fields){
            var nodeName = field.name;

            if(nodeName == '__HIDDEN__PKEY__'){
                continue;
            }

            var modelField = field.field;

            var value :Dynamic = Model.extractField(obj, modelField);

            if(value == null){
                value = '';
            }

            if(Std.is(value, Date)){
                value = value.getDate() + '/' + value.getMonth() + '/' +value.getFullYear();
            }

            var name =  value;

            workspaceFolder.appendChild({
                folder: nodeName,
                text: name,
                id: name + ',' + folderName,
                leaf: true
            });
        }

        Ext.resumeLayouts(false);
    }

    public function debug(msg : String){
        getApplication().debug(msg);
    }

    override public function setSaveVisible(visible : Bool) {
        saveButton.setVisible(visible);
        deleteButton.setVisible(visible);

        if(visible){
            getApplication().installOutlineTree('MODELS',true, false, 'WorkspaceObject', 'GRID');

            var obj : Dynamic = getEntity();

            var model = getProvider().getModel(Type.getClass(obj));

            var syntheticFields = model.getSynthenticFields();

            if(syntheticFields != null){
                for(syntheticField in syntheticFields.keys()){
                    if(syntheticFields.get(syntheticField).get('fk_field') == null){
                        var field = syntheticFields.get(syntheticField).get('field');

                        var syn_obj = Reflect.field(obj, syntheticField);

                        var program = getWorkspace().getProgramForObject(syn_obj.uuid);

                        if(program != null){
                            Reflect.setField(obj, field, syn_obj.getValue());
                        }
                    }
                }
            }

            addModelToOutline(obj, true);
        }
    }
}
