/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

import saturn.client.core.CommonCore;
import js.html.Screen;
import saturn.core.FileShim;
import bindings.Ext;
import saturn.core.Util;
import saturn.db.query_lang.Field;
import saturn.db.NodeProvider;
import haxe.Http;
import saturn.core.User;
import haxe.Json;
import js.html.Uint8Array;
import js.html.ArrayBuffer;
import bindings.FileSaver;
import js.html.Blob;
import saturn.db.Provider;
import js.Lib;
import saturn.client.workspace.Workspace;
import saturn.util.HaxeException;
import saturn.client.core.ClientCore;

import bindings.Ext;

import saturn.client.Program;

class WorkspaceApplication {
    static var theApplication : WorkspaceApplication;

    var theWorkspace : Workspace;
    
    var theProgramRegistry : ProgramRegistry;
    
    var applicationTitle : String;
    var navigationTitle : String;
    var southTitle : String;
    var detailsTitle : String;
    var tabContainerTitle : String;
	var searchBarTitle : String;

    var printBuffer : StringBuf;
    
    var programIdToTab : Map<String,Dynamic>;
    
    var theActiveProgram : Program;
	
	var searchBarListeners : Array<SearchBarListener>;
	var outlineListeners : Array<OutlineListener>;

	var nakedMode : Bool;

    var theClipBoard : ClipBoard;

    /**
    * Node WebSocket communication related
    **/


    var debugLogger : Dynamic;

    var rawQtChannel : Dynamic;

    var isInQtWebEngine : Bool = false;
    var qtSaveFileContents : String = null;

    var fileHostCB : FileShim->Void;

    var screenMode : ScreenMode = ScreenMode.DEFAULT;

    var progressWindow : Dynamic = null;
    var alwaysShowProgressWindow : Bool = false;
    var clientCore : ClientCore;


    public static function getApplication() : WorkspaceApplication {
        return theApplication;
    }
    
	public static function setApplication(application : WorkspaceApplication) {
		theApplication = application;
	}
	
    function new(applicationTitle : String, navigationTitle : String, southTitle : String, detailsTitle : String, tabContainerTitle : String, searchBarTitle : String, nakedMode : Bool) {
        WorkspaceApplication.setApplication(this);

		this.nakedMode = nakedMode;

        theClipBoard = new ClipBoard();
        printBuffer = new StringBuf();
		
		searchBarListeners = new Array<SearchBarListener>();
		outlineListeners = new Array<OutlineListener>();

        theProgramRegistry = new ProgramRegistry();
        
        this.applicationTitle = applicationTitle;
        this.navigationTitle = navigationTitle;
        this.southTitle = southTitle;
        this.detailsTitle = detailsTitle;
        this.tabContainerTitle = tabContainerTitle;
		this.searchBarTitle = searchBarTitle;
        
        programIdToTab = new Map<String, Dynamic>();

        untyped __js__('debug.enable("haxe:app")');
        debugLogger = untyped __js__('debug("haxe:app")');

        var onError : Dynamic = function(message: Dynamic, url, linenumber){
            try{
                showMessage('Unexpected exception',message);
            }catch(err : Dynamic){
                js.Browser.alert('Unexpected exception:' + message);
            }
        }

        js.Browser.window.onerror = onError;

        clientCore = ClientCore.startClientCore();
        clientCore.onProviderUp(onProviderUp);


        clientCore.setShowMessage(showMessage);
        clientCore.refreshSession(null);


    }

    public function onProviderUp(){
        clientCore.addUpdateListener(updateProgress);
        clientCore.addRefreshListener(refreshSession);

        createProgressWindow();

        checkBrowser();
    }

    public function refreshSession(){
        getWorkspace().installRemoteWorkspaceStore();
    }

    public function checkBrowser(){
        if(js.Browser.navigator.userAgent.indexOf('QtWebEngine') > -1){
            isInQtWebEngine = true;

            loadQtLibrary();
        }
    }

    public function isHostEnvironmentAvailable() : Bool{
        return isInQtWebEngine;
    }

    public function makeAliasesAvailable(){
        var dwin : Dynamic = js.Browser.window;
        dwin.models = {};
        var pack : Dynamic = untyped __js__('saturn.core.domain');
        for(field in Reflect.fields(pack)){
            var qualifiedName = 'saturn.core.domain.' + field;
            var clazz : Class<Dynamic> = Type.resolveClass(qualifiedName);
            if(clazz != null){
                Reflect.setField(dwin, field, clazz);

                var model = getProvider().getModel(clazz);
                if(model != null){
                    Reflect.setField(dwin.models, field, {});

                    Util.debug('Alias ' + qualifiedName + ' created');

                    for(modelField in model.getAttributes()){
                        Reflect.setField(Reflect.field(dwin.models, field), modelField, new Field(clazz, modelField));
                    }
                }
            }
        }

        var pack : Dynamic = untyped __js__('saturn.db.query_lang');
        for(field in Reflect.fields(pack)){
            if(field == 'Function'){
                continue;
            }
            var qualifiedName = 'saturn.db.query_lang.' + field;
            var clazz : Class<Dynamic> = Type.resolveClass(qualifiedName);

            if(clazz != null){
                Util.debug('Alias ' + field + ' created');
                Reflect.setField(dwin, field, clazz);
            }else{
                Util.debug('Skipping ' + qualifiedName);
            }
        }
    }

    public function setProvider(provider : Provider){
        CommonCore.setDefaultProvider(provider, true);
    }

    public function getProvider() : Provider{
        return CommonCore.getDefaultProvider();
    }

	public function getActiveProgramId() : String {
        if(theActiveProgram != null){
    		return theActiveProgram.getId();
        }else{
            return "-1";
        }
	}

    public function installOutlineTree(name : String, enableDrop : Bool, enableContainerDrop : Bool, modelName : String, mode : String = 'STANDARD'){

    }
    
	public function cleanEnvironment() {
        js.Browser.window.console.log('Cleaning!');

		WorkspaceApplication.suspendUpdates();
		
		destroyMenu();
        destroyToolBar();
        createToolBar();
		createMenuBar();

        populateNewMenu();
		
		clearDetailsPanel();
		clearSouthPanel();

        clearProgramSearchField();
		
		WorkspaceApplication.resumeUpdates(true);
	}

    public function destroyToolBar(){
        js.Browser.window.console.log('Destroying tool bar');
    }

    public function createToolBar(){

    }

    public function getToolBar() : Dynamic {
        return null;
    }

    public function onkeyup(event){

    }

    public function onkeydown(event){

    }

    public function setActiveProgram(program : Program){
        if(program == null){
            theActiveProgram = null;
            //cleanEnvironment();
            return;
        }

        if(theActiveProgram != null && theActiveProgram == program){
            return;
        }

        var programId : String = Std.string(program.getId());
        
        if(programIdToTab.exists(programId)){
            var tab : Dynamic = programIdToTab.get(programId);
            
            if(theActiveProgram != null){
                if(theActiveProgram != program){

					
					//destroyMenu();
					//createMenuBar();
                    //populateNewMenu();
                    //destroyToolBar();
                    //createToolBar();

                    if(!theActiveProgram.isClosed()){
                        theActiveProgram.onBlur();
                        theActiveProgram.onBlurNotifyPlugins();

                        cleanEnvironment();
                    }
                }
            }
            
            if (theActiveProgram == null || theActiveProgram != program) {
				//clearDetailsPanel();
				//clearSouthPanel();


				
				theActiveProgram = program;
				
				if(WorkspaceApplication.getApplication().isNaked() == false){
					getTabContainer().setActiveTab(tab);
				}
            
                program.focusProgram();

                /*if(program.isActivationDelayed()){
                    program.setActiveObject(program.getActiveObjectId());
                }*/
            }
        }else{
            throw new HaxeException("Program with ID "+programId+" is not known to the main application");
        }
    }

    public function getProgramTab(program : Program){
        return programIdToTab.get(program.getId());
    }

    public function setProgramTabTitle(program : Program, title : String){
        var tab = getProgramTab(program);
        tab.tab.setText(title);
    }
    
    public function getActiveProgram() : Program {
        return theActiveProgram;
    }
    
    public function addProgram(program : Program, active : Bool) {
		if (program.getId() == null) {
			getWorkspace().registerProgram(program);
		}else {
			var prog = program.getComponent();
			var self = this;
			prog.tabConfig = {
				listeners: {
					afterrender : function(tabHeader, b) {
						var contextMenu = function(event : Dynamic) {
							
							var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                
								items: [
									{
										text: 'Close',
										handler: function() { 
											self.getWorkspace().closeObject(prog.parentBuildingBlock.getActiveObjectId());
										}
									},
                                    {
                                        text: 'Close & Delete',
                                        handler: function() {
                                            self.getWorkspace().closeObjectAndDelete(prog.parentBuildingBlock.getActiveObjectId());
                                        }
                                    },
									{
										text: 'Close All',
										handler: function() { 
											self.getWorkspace().closeAllObjects();
										}
									},
									{
										text: 'Close Others',
										handler: function() { 
											self.getWorkspace().closeOtherObjects(prog.parentBuildingBlock.getActiveObjectId());
										}
									}
								]
							});
							
							contextMenu.showAt(event.clientX, event.clientY);  

							event.preventDefault();
						};
						
						/**
						 * Support for platforms that override right-click
						 */
						tabHeader.el.dom.onmouseup = function(event : Dynamic) {
							if (event.ctrlKey) {
								contextMenu(event);
							}
						};
						
						tabHeader.el.dom.oncontextmenu = contextMenu;
					}
				}	
			};
			
			var tab : Dynamic = this.getTabContainer().add(prog);
			
            tab.parentBuildingBlock = program;
        
			programIdToTab.set(program.getId(), tab);
        
			if(active && !getWorkspace().isReloading()){
				setActiveProgram(program);
			}
		}
    }

    public function addSaveAsOptions(){

    }

    public function closeProgram(program : Program){
        program.close();

        if(!getWorkspace().isReloading()){
            cleanEnvironment();
        }
        
        var tab : Dynamic = programIdToTab.get(program.getId());

        getTabContainer().remove(tab);

        programIdToTab.remove(program.getId());
    }
    
    public function getProgramRegistry(){
        return theProgramRegistry;
    }
    
    function initApplication(){
        createCentralPanel();
        createSearchBar(searchBarTitle);
        createMenuBar();
        createNavigationPanel(navigationTitle);
        createMiddleSouthPanel(southTitle);
        createSouthPanel(southTitle);
        createDetailsPanel(detailsTitle);


        createTabContainer(tabContainerTitle);
        createCentralInfoPanel();
        
        registerPrograms();
        
        populateNewMenu();

        var quickLaunchItems = this.getProgramRegistry().getQuickLaunchItems();

        for(quickLaunchItem in quickLaunchItems){
            getQuickLaunchBar().add(quickLaunchItem);
        }

        /*ClientCore.getClientCore().refreshSession(function(err : String){
            if(err != null){
                debug(err);
            }
        });*/

    }
    
    function createMenuBar(){
        
    }
	
	function destroyMenu() {
		
	}
    
    function createNavigationPanel(navigationTitle : String){
        
    }
    
    function createMiddleSouthPanel(southTitle : String){
        
    }

    function createSouthPanel(southTitle : String){

    }
    
    function createDetailsPanel(detailsTitle : String){
        
    }
	
	function clearDetailsPanel() {
		
	}
	
	function clearSouthPanel() {
		
	}
	
    function createTabContainer(tabContainerTitle : String){
        
    }

    function createCentralPanel() {

    }

    function createCentralInfoPanel(){

    }

    public function setCentralInfoPanelText( txt : String){

    }
    
    function registerPrograms(){
        
    }
	
	function createSearchBar(searchBarTitle : String) {
		
	}
    
    function populateNewMenu(){
        var shortNames : Map<String, String> = this.getProgramRegistry().getRegisteredWorkspaceObjectShortNames();

        var menuItems = new Array<String>();
        var menuTextToShortName : Map<String, String> = new Map<String,String>();
        for(shortName in shortNames.keys()){
            var clazzName = shortNames.get(shortName);

            var clazz : Class<Dynamic> = Type.resolveClass(clazzName);

            //var fl: Dynamic = Reflect.field(clazz, "getNewMenuText");

            var newText : String = null;

            //if(fl != null){
            //    newText = Reflect.callMethod(clazz, fl, []);
            //}else{
                var model = getProvider().getModel(clazz);
                if(model != null){
                    newText = model.getFileNewLabel();
                }
            //}

            if(newText != null){
                menuTextToShortName.set(newText, shortName);

                menuItems.push(newText);
            }
        }

        menuItems.sort( function( a : String, b : String) : Int {
            a = a.toLowerCase();
            b = b.toLowerCase();
            if (a < b) return -1;
            if (a > b) return 1;
            return 0;
        });

        for(menuItem in menuItems){
            var shortName = menuTextToShortName.get(menuItem);

            var clazzName = shortNames.get(shortName);

            addNewMenuItem(menuItem, clazzName);
        }

        /*
        var shortNameArray : Array<String> = new Array<String>();
        for(shortName in shortNames.keys()){
            shortNameArray.push(shortName);
        }
        
        shortNameArray.sort( function( a : String, b : String) : Int {
                a = a.toLowerCase();
                b = b.toLowerCase();
                if (a < b) return -1;
                if (a > b) return 1;
                return 0;
        });
		
		shortNameArray.sort(function(a:String, b:String):Int{
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		});
        
        for(shortName in shortNameArray){
            var clazzName : String = shortNames.get(shortName);
            
            var clazz : Class<Dynamic> = Type.resolveClass(clazzName);
            
            var fl: Dynamic = Reflect.field(clazz, "getNewMenuText");
            
            var newText : String = Reflect.callMethod(clazz, fl, []); 
            
            addNewMenuItem(newText, clazzName);
        }*/
		
		addSaveMenuItem();
		addOpenDefaultWorkspaceMenuItem();
		addSaveWorkspaceMenuItem();
        addSaveWorkspaceAsMenuItem();
        addOpenSavedWorkspaceMenuItem();
    }
    
    function addNewMenuItem(shortName : String, clazzName : String){
        
    }
	
	function addSaveMenuItem() {
		
	}
	
	function addSaveWorkspaceMenuItem() {
		
	}
	
	function addOpenDefaultWorkspaceMenuItem() {
		
	}

    function addSaveWorkspaceAsMenuItem() {

    }

    function addOpenSavedWorkspaceMenuItem(){

    }
    
    public function getWorkspace() : Workspace{
        return theWorkspace;
    }
    
    public function getFileNewMenu() : Dynamic {
        return null;
    }
    
	public function getFileMenu() : Dynamic {
		return null;
	}

    public function getToolsMenu() : Dynamic {
        return null;
    }

    public function getExportMenu() : Dynamic {
        return null;
    }

    public function getImportMenu() : Dynamic {
        return null;
    }

    public function getWorkspaceExportMenu() : Dynamic {
        return null;
    }

	public function getViewMenu() : Dynamic {
		return null;
	}

    public function getEditMenu() : Dynamic {
        return null;
    }
	
	public function getOpenMenu() : Dynamic {
		return null;
	}

    public function getSaveMenu() : Dynamic {
        return null;
    }

    public function getSaveAsMenu() : Dynamic {
        return null;
    }
	
    public function getMenuBar()  : Dynamic {
        return null;
    }
    
    public function getNavigationPanel() : Dynamic{
        return null;
    }
    
    public function getMiddleSouthPanel() : Dynamic{
        return null;
    }
    
    public function getOultineTree(name : String) : Dynamic{
        return null;
    }
    
    public function getOutlineDataStore(name : String) : Dynamic{
        return null;
    }
    
    public function getDetailsPanel() : Dynamic{
        return null;
    }
    
    public function getTabContainer() : Dynamic{
        return null;
    }
    
    public function getOutlineTree(name : String) : Dynamic {
        return null;
    }   
	
	public function printInfo( message : String) {
		
	}
	
	public function isNaked() : Bool {
		return nakedMode;
	}

    public function getEastPanel() : Dynamic {
        return null;
    }
	
	/**
	 * Event handlers
	 */
	
	/**
	 * Add search bar autocomplete listener to the start of the listener list
	 * @param	listener
	 */
	public function addSearchBarListener( listener : SearchBarListener) {
		searchBarListeners.unshift(listener);
	}
	
	public function removeSearchBarListeners( listener : SearchBarListener ) {
		searchBarListeners.remove(listener);
	}
	
	function fireSearchObjectSelected( objSelected ) {
		var it :Dynamic = searchBarListeners.iterator();
		
		it.realNext = it.next;
		
		it.next = (function next() {
			if(it.hasNext()){
				var listener = it.realNext();
				
				listener.objectSelected(this, objSelected, it);
			}
		});
		
		it.next();
	}
	
	function fireSearchTermChanged( searchTerm : String ) {
		var it :Dynamic = searchBarListeners.iterator();
		
		it.realNext = it.next;
		
		it.next = (function next() {
			if(it.hasNext()){
				var listener = it.realNext();
				
				listener.textChanged(this, searchTerm, it);
			}
		});
		
		it.next();
	}
	
	public function addOutlineListener( listener : OutlineListener ) {
		for (eListener in outlineListeners) {
			if (listener ==  eListener) {
				return;
			}
		}
		
		outlineListeners.unshift(listener);
	}
	
	public function removeOutlineListener( listener : OutlineListener ) {
		outlineListeners.remove(listener);
	}
	
	function fireOutlineItemClicked(view,rec,item,index) {
		for( listener in outlineListeners) {
			listener.onClick(view, rec, item, index);
		}
	}
	
	private function autocomplete_update(items : Array<Dynamic>) {
		
	}

    public function processException(ex : HaxeException){
        showMessage('Warning', ex.getMessage());
    }

    /**
    * showMessage displays a dialog box to the user containing the supplied message and an "Ok" button
    *
    * title: Message to show to the user
    **/
    public function showMessage(title, obj : Dynamic){
        var message : String = 'Missing message<br/>Contact Developers';
        if(obj != null){
            if(Std.is(obj, String)){
                if(StringTools.startsWith(obj, "\"")){
                    message = Json.parse(obj);
                }else{
                    message = obj;
                }
            }else if(Reflect.hasField(obj, 'message')){
                message = obj.message;
            }
        }

        Ext.Msg.alert(title, message);

        /*try{
            throw new js.Error();
        }catch(err : Dynamic){
            Ext.Msg.alert(title, err.stack);
        }*/
    }

    /**
    * userPrompt prompts the user with a question and three options "Yes", "No", and "Cancel"
    *
    * title: Title of the dialog window
    * question: Message shown to the user
    * onYes: Function called if the user clicks the "Yes" button
    * onNo: Function called if the user clicks the "No" button
    * onCancel: Function called if the user clicks the "Cancel" button
    **/
    public function userPrompt(title : String, question : String, onYes : Dynamic, ?onNo : Dynamic, ?onCancel : Dynamic){
        Ext.Msg.show({
            title: title,
            msg: question,
            buttons: Ext.Msg.YESNOCANCEL,
            icon: Ext.Msg.QUESTION,
            fn: function(btn){
                if(btn == 'yes'){
                    onYes();
                }else if(btn == 'no'){
                    if(onNo != null){
                        onNo();
                    }
                }else{
                    if(onCancel != null){
                        onCancel();
                    }
                }
            }
        });
    }

    /**
    * userValuePrompt prompts the user to provide a text value along with the options "Ok", "Cancel"
    *
    * title: Title of the dialog window
    * question: Message shown to the user
    * onOk: Function called if the user clicks "Ok"
    * onCancel: Function called if the user clicks "Cancel"
    **/
    public function userValuePrompt(title : String, question : String, onOk : Dynamic, onCancel : Dynamic){
        Ext.Msg.prompt(title, question, function(btn, text){
            if(btn == 'ok'){
                onOk(text);
            }else if(onCancel != null){
                onCancel();
            }
        });
    }

    public function showELN(){

    }

    public function openLocalURL(path : String){
        var location : js.html.Location = js.Browser.window.location;

        var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+path;

        openUrl(dstURL);
    }

    public  function openUrl(url : String){
        if(inIcm()){
            ICMClient.getClient().openUrl(url, false);
        }else{
            js.Browser.window.open(url,'_blank');
        }
    }

    public function inIcm(){
        return Reflect.hasField(js.Browser.window,"ICMScript");
    }

    public function getClipBoard() : ClipBoard{
        return theClipBoard;
    }

    /**
    * blob = Blob or String
    **/
    public function saveFile(blob : Dynamic, fileName : String){
        if(Reflect.hasField(js.Browser.window,"ICMScript")){
            blob = StringTools.replace(blob,'\n','<__MOLBIO__N>');
            blob = StringTools.replace(blob, '\t','<__MOLBIO_SEP>');

            var icmSetCommand = ICMClient.getClient().generateSetStringCommand('MOLBIO_FILE',blob);
            ICMClient.getClient().runCommand(
                icmSetCommand+'\n'+
                'sgc.molbio.exportToFileDialog(MOLBIO_FILE,\''+fileName+'\')\n',
                function(data,err){
                    if(err != null){

                    }
                }
            );
        }else{
            var dWin = untyped js.Browser.window;

            dWin.saveAs(blob,fileName);

            //new FileSaver(blob,fileName);
        }
    }

    public function saveTextFile(content : String, fileName : String){
        var blob :Dynamic;

        if(Reflect.hasField(js.Browser.window,"ICMScript")){
            blob = content;
        }else{
            blob = new Blob([content], {type: "text/plain;charset=utf-8"});
        }

        saveFile(blob, fileName);
    }

    public function canvasToBlob(canvas : Dynamic) : Blob{
        //No toBlob from Google so followed the help here - https://code.google.com/p/chromium/issues/detail?id=67587

        var extractPattern = ~/data:([^;]*)(;base64)?,([0-9A-Za-z+\/]+)/;

        extractPattern.match(canvas.toDataURL());

        //assume base64 encoding
        var binStr = js.Browser.window.atob(extractPattern.matched(3));

        //convert to binary in ArrayBuffer
        var buf = new ArrayBuffer(binStr.length);
        var view = new Uint8Array(buf);

        for(i in 0...view.length){
            view[i] = binStr.charCodeAt(i);
        }

        var blob = new Blob([view], {type: extractPattern.matched(1)});

        return blob;
    }

    public function saveCanvasToFile(canvas : Dynamic, fileName : String){
        saveFile(canvasToBlob(canvas), fileName);
    }

    /**
    * Node WebSocket related methods
    **/

    /**
    * installNodeSocket opens a NodeSocket/WebSocket connection to the hosting Node instance
    **/


    public function createProgressWindow(){
        progressWindow = Ext.create('Ext.window.Window', {
            title: 'Progress',
            height: 200,
            width: 400,
            layout: 'fit',
            closeAction:'hide',
        items: {  // Let's put an empty grid in just to illustrate fit layout
                xtype: 'panel',
                html: '',
                autoScroll: true,
                style:{
                    'overflow-y': 'scroll'
                }
            }
        });
    }

    public function updateProgress(){
        var html = '';

        var showMsgIds = new Array<String>();
        for(msgId in ClientCore.getClientCore().msgIds){
            var job = ClientCore.getClientCore().msgIdToJobInfo.get(msgId);
            var json = Reflect.field(job, 'JSON');
            var msg :String = Reflect.field(job, 'MSG');
            if(msg == '_remote_provider_._data_request_objects_namedquery'){
                if(Reflect.field(json,'queryId') == 'saturn.workflow'){
                    if(Reflect.field(json, 'class_name') == 'saturn.workflow.HMMerResponse'){
                        showMsgIds.push(msgId);
                    }
                }
            }else if(msg == '_clustal_' || msg == '_thmm_' || msg == '_blast_' || msg == '_phylo_' || msg == '_psipred_'){
                showMsgIds.push(msgId);
            }
        }

        var runTimer = false;

        if(showMsgIds.length == 0 && !alwaysShowProgressWindow){
            progressWindow.hide();
        }else{
            if(!progressWindow.isVisible()){
                progressWindow.show();
            }

            html = '<ul>';

            for(msgId in showMsgIds){
                var job = ClientCore.getClientCore().msgIdToJobInfo.get(msgId);
                var json = Reflect.field(job, 'JSON');
                var msg :String = Reflect.field(job, 'MSG');
               // msg = msg + ' ' + Reflect.field(json,'queryId');
                //saturn.workflow
                if(msg == '_remote_provider_._data_request_objects_namedquery'){
                    if(Reflect.field(json,'queryId') == 'saturn.workflow'){
                        if(Reflect.field(json, 'class_name') == 'saturn.workflow.HMMerResponse'){
                            msg = 'Running domain prediction';
                        }
                    }
                }else if (msg == '_clustal_'){
                    msg = 'Running clustal alignment';
                }else if (msg == '_thmm_'){
                    msg = 'Running transmembrane prediction';
                }else if (msg == '_blast_'){
                    msg = 'Running BLAST';
                }else if (msg == '_phylo_'){
                    msg = 'Generating phylogenetic tree';
                }else if (msg == '_psipred_'){
                    msg = 'Running secondary structure prediction';
                }

                var startTime = Reflect.field( job,'START_TIME');
                var endTime = Reflect.field(job, 'END_TIME');

                if(endTime == null){
                    endTime = untyped __js__('Date.now()');
                    runTimer = true;
                }else{
                    msg = msg + " <font color='green'>DONE</font>:";
                }

                var diff = endTime - startTime;

                if(diff > 1000){
                    msg = msg + ' ' + Std.string(diff/1000) + 's';
                }else{
                    msg = msg + ' ' + Std.string(diff) + 'ms';
                }

                html += '<li>' + msg + '</li>';
            }

            html += '</ul>';
        }

        if(progressWindow.down('panel').el != null){
            progressWindow.down('panel').el.dom.innerHTML = html;

            if(runTimer){
                haxe.Timer.delay(function(){
                    if(progressWindow.isVisible()){
                        updateProgress();
                    }
                },1000);
            }
        }
    }





    static var layoutsSuspended = 0;

    public static function resumeUpdates(b : Bool, ?force :Bool = false) : Void{
        if(force){
            layoutsSuspended = 0;
        }else{
            layoutsSuspended--;
        }


        if(layoutsSuspended == 0){
            Ext.resumeLayouts(b);
        }
    }

    public static function suspendUpdates(?force : Bool = false) : Void{
        layoutsSuspended++;

        if(layoutsSuspended == 0 || force){
            Ext.suspendLayouts();
        }
    }

    public static function updatesSuspended() : Bool {
        return layoutsSuspended > 0;
    }

    public function setInformationPanelText(content : String, isHtml : Bool){

    }

    public function setProgramSearchFieldEmptyText(emptyText : String){

    }

    public function enableProgramSearchField(enable : Bool){

    }

    public function getPrintBufferContent() : String {
        return printBuffer.toString();
    }

    public function addToPrintBuffer(content : Dynamic) : Void {
        printBuffer.add('&lt;'+Std.string(content) + '\n<br/>');
    }

    public function clearPrintBuffer() : Void {
        printBuffer = new StringBuf();
    }

    public function flushBufferToPanel(){
        setInformationPanelText('<font style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;">'+getApplication().getPrintBufferContent()+'</font>', true);
    }

    public function loginPrompt(){

    }

    public function getQuickLaunchBar() : Dynamic{
        return null;
    }

    public function hideMiddleSouthPanel(){

    }

    public function showMiddleSouthPanel(){

    }

    public function clearProgramSearchField(){

    }

    public function debug(message : String) : Void{
        debugLogger(message);
    }

    public function setLoggedIn(user : User){
        ClientCore.getClientCore().setLoggedIn(user);

    }

    public function setLoggedOut(){
        ClientCore.getClientCore().setLoggedOut();
    }

    public function loadQtLibrary() : Void {
        var scriptElem = js.Browser.document.createScriptElement();
        scriptElem.setAttribute('type','text/javascript');
        scriptElem.setAttribute('src', 'qrc:///qtwebchannel/qwebchannel.js');
        js.Browser.document.getElementsByTagName('head')[0].appendChild(scriptElem);

        connectQtWebChannel();
    }

    private function connectQtWebChannel(){
        haxe.Timer.delay(function(){
            try{
                //var qWebChannel : Dynamic = untyped __js__('QWebChannel');
                new QWebChannel(untyped __js__('qt.webChannelTransport'), function(channel) {
                    rawQtChannel = channel;

                    var dialog = rawQtChannel.objects.fileDialog;

                    dialog.fileSelected.connect(function(filePath) {
                        if(qtSaveFileContents == null){
                            rawQtChannel.objects.HostFileReader.read_b64(filePath, function(contents){
                                var file = new FileShim(filePath, contents);

                                fileHostCB(file);
                            });
                        }else{
                            Util.getNewExternalProcess(function(process){
                                process.writeFile(filePath, qtSaveFileContents);
                            });
                        }

                    });
                });

                return;
            }catch(exception : Dynamic){
                connectQtWebChannel();
            }
        },100);
    }

    public function refreshNewQtWebChannelObjects(cb : Dynamic->Void){
        rawQtChannel.exec(untyped __js__('{type:QWebChannelMessageTypes.init}'), function(data : Array<Dynamic>){
            for(objectName in Reflect.fields(data)){
                Util.debug('Looking for ' + objectName);
                if(!rawQtChannel.objects.hasOwnProperty(objectName)){
                    Util.debug('Found ' + objectName);

                    var object = untyped __js__('new QObject(objectName, data[objectName], _g2.rawQtChannel)');

                    Reflect.field(rawQtChannel.objects,objectName).unwrapProperties();
                }
            }

            rawQtChannel.exec(untyped __js__('{type: QWebChannelMessageTypes.idle}'));

            cb(rawQtChannel);
        });
    }

    /**
    *  app.getNewQtProcess(function(process){
    *    process.start('C:\\windows\\notepad.exe',['c:\\output.txt']);
    *    process.finished.connect(function(){
    *      print('Finished');
    *      flush();
    *    });
    *  });
    **/

    public function getNewQtProcess(cb : Dynamic->Void){
        rawQtChannel.objects.foo.createNewProcess(function(objectId : String){
            refreshNewQtWebChannelObjects(function(channel : Dynamic){
                cb(Reflect.field(channel.objects, objectId));
            });
        });
    }

    public function getNewFileDialog(cb: String->Dynamic->Void){
        rawQtChannel.objects.foo.createNewDialog(function(objectId : String){
            refreshNewQtWebChannelObjects(function(channel : Dynamic){
                cb(null, Reflect.field(channel.objects, objectId));
            });
        });
    }

    public function openHostFile(cb : FileShim->Void){
        fileHostCB = cb;

        var dialog = rawQtChannel.objects.fileDialog;

        dialog.visible = true;
    }

    public function getScreenMode() : ScreenMode {
        return screenMode;
    }

    public function setMode(mode : ScreenMode){
        if(mode == screenMode){
            return;
        }

        var oldMode = screenMode;

        screenMode = mode;

        if(mode == ScreenMode.SINGLE_APP){
            enterSingleAppMode();
        }else if(mode == ScreenMode.DEFAULT){
            if(oldMode == ScreenMode.SINGLE_APP){
                exitSingleMode();
            }
        }
    }

    public function getSingleAppContainer() : SingleAppContainer{
        return null;
    }

    public function enterSingleAppMode(){

    }

    public function exitSingleMode(){

    }
}

enum ScreenMode {
    SINGLE_APP;
    DEFAULT;
}

