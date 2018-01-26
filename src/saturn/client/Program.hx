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
import saturn.util.HaxeException;
import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceObject;
interface Program extends BuildingBlock {
    function addWorkspaceObject(objectId : String) : Void;
    function closeWorkspaceObject(objectId : String ) : Void;
    public function getSaveAsModelsForProgram() : Array<Model>;
    public function saveObjectAsGUI(model : Model) : Void;
/**
	 * close() is called when your application is being closed by the workspace
	 */
    function close() : Void;

    public function getWorkspaceContextMenuItems() : Array<Dynamic>;

    function setId(id : String) : Void;
    function getId() : String;
    function setActiveObject(objectId : String) : Void;
    function _setActiveObject(objectId : String) : Void;
    function getActiveObject < T : (WorkspaceObject<Dynamic>) > (type : Class<T>) : T;
    function getActiveObjectId() : String;
    function mouseup(event : Dynamic) : Void;
    function mousedown(event: Dynamic) : Void;
    function openFile(file : Dynamic, asNew : Bool, ? asNewOpenProgram : Bool = true) : Void;

    function setModelOutlineValue(field :String, value : Dynamic) : Void;

/**
    * saveWait called by the workspace before the session is serialised so the program can perform an async action
    *
    * cb: Call when ready to notify the workspace that you are ready for the session to be saved
    **/
    function saveWait(cb : Dynamic) : Void;
/**
	 * serialise() is called by the workspace when a session save has been triggered
	 *
	 * Return an object that contains the state of your program to have the state
	 * restored when the session is reopened.
	 *
	 * @return
	 */
    function serialise() : Dynamic;
    function deserialise(object : Dynamic) : Void;
    function emptyInit() : Void;

    function postRestore() : Void;
    function installWindowListeners(window : Dynamic) : Void;
    function uninstallWindowListeners(window : Dynamic) : Void;
    function getWorkspace() : Workspace;
    function getApplication() : WorkspaceApplication;
    function setTitle(title : String) : Void;
    function onOutlineDrop(node :Dynamic, data :Dynamic, overModel :Dynamic, dropPosition :Dynamic, dropHandlers :Dynamic, eOpts :Dynamic) : Bool;

    function getCentralPanelLayout():String;

/**
	 * onFocus() is called when the application is given focus.
	 *
	 * The central program tab will be restored for you by the workspace.
	 *
	 * HOWEVER you are responsible for restoring all other tabs
	 */
//function onFocus() : Void;

/**
	 * onBlur() is called when the application looses focus.
	 *
	 * The central program tab will be saved for you by the workspace.
	 *
	 * ALL other panels are cleared by the workspace and will need to be
	 * recreated by your application when onFocus() is called.
	 */
//function onBlur() : Void;

    function convertDragToWorkspaceObject(data : Dynamic) : WorkspaceObject<Dynamic>;
    function addPlugin(plugin : ProgramPlugin<Dynamic>) : Void;

    function focusProgram() : Void;
    function blurProgram() : Void;

/**
	 * onFocusNotifyPlugins() is called after the application has been given
	 * focus and it's own onFocus() method has been called.
	 */
    function onFocusNotifyPlugins() : Void;

/**
	 * onBlurNotifyPlugins() is called after the application has lost focus
	 * and it's own onBlur() method has been called.
	 */
    function onBlurNotifyPlugins() : Void;

    function processException(ex : HaxeException) : Void;

    function arePluginsInstalled() : Bool;
    function setPluginsInstalled() : Void;

    function search(regex : String) : Void;

    public function getActiveObjectName() : String;

    function isActivationDelayed() : Bool;

    function isClosed() : Bool;

    function getPlugins() : Array<ProgramPlugin<Dynamic>>;
    public function getEntity() : Dynamic;
}
