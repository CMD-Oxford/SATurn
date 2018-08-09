/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

import saturn.db.Model;
import saturn.db.Model;
import saturn.db.Provider;
import saturn.util.HaxeException;
import saturn.client.workspace.Workspace;
import saturn.client.Program;

import saturn.client.core.ClientCore;

class BaseProgram implements Program implements OutlineListener {
    var theId : String;

    var theActiveObjectId : String;

    var objectIds : Array<String>;

    var plugins : Array<ProgramPlugin<Dynamic>>;

    var pluginsInstalled : Bool;

    var delayedActivation = false;

    var closed = false;

    var saveable : Bool = false;

    var lastSearch : String;

    function new(){
        emptyInit();
    }

    public function getPlugins() : Array<ProgramPlugin<Dynamic>> {
        return plugins;
    }

    public function saveWait(cb) : Void{
        cb();
    }

    public function getReferences(name : String){
        var obj = getObject();

        if(obj != null){
            return obj.getReferences(name);
        }else{
            return null;
        }
    }

    public function getCentralPanelLayout(){
        return 'hbox';
    }

    public function onOutlineDrop(node :Dynamic, data :Dynamic, overModel :Dynamic, dropPosition :Dynamic, dropHandlers :Dynamic, eOpts :Dynamic) : Bool{
        return true;
    }

    public function emptyInit() {
        objectIds = new Array<String>();
        plugins = new Array<ProgramPlugin<Dynamic>>();
        pluginsInstalled = false;
    }

    public function arePluginsInstalled() : Bool{
        return pluginsInstalled;
    }

    public function setPluginsInstalled() : Void{
        pluginsInstalled =  true;
    }

    public function openFile(file : Dynamic, asNew : Bool, ?asNewOpenProgram :Bool = true) : Void{

    }

    public function setActiveObject(objectId) : Void{
        _setActiveObject(objectId);

        delayedActivation = false;

        updateActions();
    }

    public function isActivationDelayed() : Bool{
        return delayedActivation;
    }

    public function _setActiveObject(objectId) : Void {
        theActiveObjectId = objectId;

        delayedActivation = true;
    }

    public function getState() : WorkspaceObject <Dynamic>{
        return getActiveObject(WorkspaceObject);
    }

/**
    * Returns the current object associated with the program
    *
    * If the object is a depreciated WorkspaceObject then the internal object is returned
    **/
    public function getObject() : Dynamic {
        var obj :Dynamic = getWorkspace().getObject(theActiveObjectId);

        if(Std.is(obj, WorkspaceObject)){
            return obj.getObject();
        }else{
            return obj;
        }
    }

/**
    * Returns the WorkspaceObject
    *
    * This function is depreciated along with WorkspaceObject and shouldn't be used unless absolutely necessary whilst transitioning
    **/
    public function getWorkspaceObject() : Dynamic {
        return getWorkspace().getObject(theActiveObjectId);
    }

    public function getObjectName() : String{
        return getWorkspaceObject().getName();
    }

    public function getActiveObject<T : (WorkspaceObject<Dynamic>)>(type : Class<T>) : T {
//This is bad, but we don't have T at runtime so I don't
//know how to pass a type parameter to getObjectSafely
        var obj : T = getWorkspace().getObjectSafely(theActiveObjectId,type);

        return obj;
    }

    public function getActiveObjectObject() : Dynamic{
        var wo  : WorkspaceObject<Dynamic> = getActiveObject(WorkspaceObject);

        if(wo == null){
            return null;
        }else{
            return wo.getObject();
        }
    }



    public function getActiveObjectName() : String {
        var obj :  WorkspaceObject<Dynamic> =  getWorkspace().getObject(getActiveObjectId());

        return obj.getName();
    }

    public function getActiveObjectId() : String {
        return theActiveObjectId;
    }

    public function addWorkspaceObject(objectId : String) : Void {
        objectIds.push(objectId);

        if(theActiveObjectId == null){
            setActiveObject(objectId);
        }
    }

    public function closeWorkspaceObject(objectId : String ) : Void {
        objectIds.remove(objectId);

        if (objectId == theActiveObjectId) {
            theActiveObjectId = null;
        }
    }

    public function convertDragToWorkspaceObject(data : Dynamic) : WorkspaceObject<Dynamic> {
        return null;
    }


    public function close() : Void {
//WorkspaceApplication.getApplication().cleanEnvironment();

        WorkspaceApplication.getApplication().removeOutlineListener(this);

        closed = true;
    }

    public function isClosed() : Bool{
        return closed;
    }

    public function getComponent() : Dynamic {
        return null;
    }

    public function getRawComponent() : Dynamic {
        return getComponent();
    }

    public function setId(id : String) : Void {
        theId = id;
    }

    public function getId() : String {
        return theId;
    }

    public function onFocus() : Void {
        getApplication().addSaveAsOptions();
    }

    public function onBlur() : Void {
        if(isSaveable()){
            syncModelFromOutline();
        }
    }

    public function setModelOutlineValue(field :String, value : Dynamic){
        var dataStore = getApplication().getOutlineDataStore('MODELS');

        if(dataStore == null){
            return;
        }

        var rootNode : Dynamic = dataStore.getRootNode();

        var entity = getEntity();

        var model = getProvider().getModel(Type.getClass(entity));
        var busKey = model.getFirstKey();

        var folderName = Reflect.field(entity, busKey);

        var fields = model.getUserFieldDefinitions();

        var folderId = '_folder_' +folderName;

        var modelNode = rootNode.findChild('id', folderId, false);

        if(modelNode == null){
            return;
        }

        if(field == busKey){
            modelNode.set('id', '_folder_' + value);
        }

        var children : Array<Dynamic> =  modelNode.childNodes;

        for(childNode in children){
            var label = childNode.data.folder;
            var modelField = model.convertUserFieldName(label);

            if(modelField == field){
                childNode.set('text', value);
                childNode.commit();
                break;
            }
        }
    }

    public function syncModelFromOutline(){
        var dataStore = getApplication().getOutlineDataStore('MODELS');

        if(dataStore == null){
            return;
        }

        var rootNode : Dynamic = dataStore.getRootNode();

        var entity = getEntity();

        var model = getProvider().getModel(Type.getClass(entity));

        var busKey = model.getFirstKey();

        var folderName = Reflect.field(entity, busKey);

        var fields = model.getUserFieldDefinitions();

        var folderId = '_folder_' +folderName;

        var modelNode = rootNode.findChild('id', folderId, false);

        if(modelNode == null){
            return;
        }

        var children : Array<Dynamic> =  modelNode.childNodes;

        for(childNode in children){
            var label = childNode.data.folder;
            var modelField = model.convertUserFieldName(label);

            if(modelField != null){
                var psueodSyntheticField = model.getPseudoSyntheticObjectName(modelField);
                if(psueodSyntheticField != null){
                    Reflect.field(entity, psueodSyntheticField).setValue(childNode.data.text);
                }else{
                    updateModelField(entity, modelField, childNode.data.text);
                }
            }
        }
    }

    public function updateModelField(obj : Dynamic, field : String, value : String){
        Model.setField(obj, field, value,true);
    }

/**
	 * Register default Outline listener
	 */
    public function focusProgram() : Void {
        WorkspaceApplication.getApplication().addOutlineListener(this);

        onFocus();

        onFocusNotifyPlugins();

        updateActions();
    }


    public function updateActions(){
        setSaveVisible(isSaveable());
    }

/**
	 * Deregister default Outline listener
	 */
    public function blurProgram() : Void {
        WorkspaceApplication.getApplication().removeOutlineListener(this);

        onBlur();

        onBlurNotifyPlugins();
    }

    public function onFocusNotifyPlugins() : Void {
        for (plugin in plugins) {
            plugin.onFocus();
        }
    }

    public function onBlurNotifyPlugins() : Void {
        for (plugin in plugins) {
            plugin.onBlur();
        }
    }

    public function mouseup(event: Dynamic) : Void {

    }

    public function mousedown(event: Dynamic) : Void {

    }

    public function serialise() : Dynamic {
        var clazz : Class<Dynamic> = Type.getClass(this);
        return { 'ID' : getId(), 'CLASS' : Type.getClassName(clazz), 'ACTIVE_ID' : theActiveObjectId };
    }

    public function deserialise(object : Dynamic) : Void {
        setId(object.ID);

        theActiveObjectId = object.ACTIVE_ID;
    }

    public function postRestore() : Void {
        var objectId = theActiveObjectId;
//theActiveObjectId = null;

        setActiveObject(objectId); //not as futile as it looks


    }

    public function installWindowListeners(window : Dynamic) : Void {

    }

    public function uninstallWindowListeners(window : Dynamic) : Void {

    }

    public function getWorkspace() : Workspace {
        return getApplication().getWorkspace();
    }

    public function getApplication() : WorkspaceApplication {
        return WorkspaceApplication.getApplication();
    }

    public function setTitle(title : String){

    }

    public function onClick(view, rec, item, index) : Void {

    }

    public function addPlugin(plugin : ProgramPlugin<Dynamic>): Void {
        plugins.push(plugin);

        plugin.setProgram(this);
        plugin.emptyInit();
    }

    public function removePlugin(plugin : ProgramPlugin<Dynamic>) : Void {
        plugins.remove(plugin);
    }

    public function processException(ex : HaxeException) : Void{
        getApplication().processException(ex);
    }

    public function getProvider() : Provider{
        return getApplication().getProvider();
    }

    public function search(regex : String) : Void{
        lastSearch = regex;
    }

    public function getLastSearch() : String{
        return lastSearch;
    }

/**
    * Returns true if the user is logged in
    *
    * Convenience method that calls WorkspaceApplication.isLoggedIn
    **/
    public function isLoggedIn() : Bool {
        return ClientCore.getClientCore().isLoggedIn();
    }

/**
    * Returns true when the object held by the program can be saved to the backend database
    **/
    public function isSaveable() : Bool{
        if(!isLoggedIn()){
            return false;
        }

        var object = getEntity();

        var model = getProvider().getModel(Type.getClass(object));

        if(model != null){
            return model.isProgramSaveAs(Type.getClassName(Type.getClass(this)));
        }else{
            return false;
        }
    }

    public function saveObject(cb : String->Void){
        var object = getEntity();

        syncModelFromOutline();

        saveAsync(function(err : String){
            if(err != null){
                getApplication().showMessage('Error', err);
            }else{


                getProvider().save(object, function(err : String){
                    if(err == null){
                        getProvider().attach([object], false,function(err : String){
                            if(err == null){
                                var dataStore = getApplication().getOutlineDataStore('MODELS');

                                if(dataStore != null){
                                    dataStore.commitChanges();
                                }

                                cb(null);
                            }else{
                                cb(err);
                            }
                        });
                    }

                    cb(err);
                }, true);
            }
        });
    }

    public function saveAsync(cb : String->Void){
        cb(null);
    }

    public function saveObjectAsGUI(model : Model){
        changeObjectType(model);

        saveObjectGUI();
    }

    public function changeObjectType(model : Model) : Dynamic{
        var obj = getWorkspace().changeObjectType(getActiveObjectId(), model);

        updateActions();

        return obj;
    }

    public function getWorkspaceContextMenuItems() : Array<Dynamic>{
        return null;
    }

    public function deleteObject(cb : String->Void){
        var object = getObject();

        getProvider().delete(object, cb);
    }

    public function saveObjectGUI(){
        saveObject(function(err : String){
            if(err != null){
                getApplication().showMessage('Save failure', 'Unable to save to database');
            }else{
                getApplication().showMessage('Saved', 'Save successfull');
            }
        });
    }

    public function deleteObjectGUI(){
        deleteObject(function(err : String){
            if(err != null){
                getApplication().showMessage('Delete failure', 'Unable to delete from database');
            }else{
                getApplication().showMessage('Deleted', 'Delete successfull');
            }
        });
    }

    public function setSaveVisible(visble : Bool) {

    }

    public function getSaveAsModelsForProgram() : Array<Model>{
        var models = new Array<Model>();

        var clazzes : Array<Class<Dynamic>> = getApplication().getProgramRegistry().getClassesForProgram(Type.getClass(this));
        for(clazz in clazzes){
            var model = getProvider().getModel(clazz);

            if(model != null){
                if(model.isProgramSaveAs(Type.getClassName(Type.getClass(this)))){
                    models.push(model);
                }
            }
        }

        return models;
    }

    //To replace my mess of getObject methods
    public function getEntity() : Dynamic{
        var obj :Dynamic = getWorkspaceObject();

        if(obj != null){
            if(Std.is(obj, WorkspaceObject)){
                obj = cast(obj, WorkspaceObject<Dynamic>).getObject();
            }

            if(Reflect.isFunction(obj.isLinked) && obj.isLinked()){
                if(Reflect.isFunction(obj.getParent) && obj.getParent() != null){
                    obj = obj.getParent();
                }
            }

            return obj;
        }else{
            return null;
        }
    }
}
