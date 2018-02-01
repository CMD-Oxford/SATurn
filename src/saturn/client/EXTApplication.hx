/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

import saturn.client.core.ClientCore;
import saturn.db.Model;
import js.html.Screen;
import saturn.client.WorkspaceApplication.ScreenMode;
import saturn.core.FileShim;
import saturn.client.workspace.WebPageWorkspaceObject;
import saturn.client.workspace.WebPage;
import saturn.core.User;
import saturn.core.Protein;
import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.core.DNA;
import saturn.client.workspace.DNAWorkspaceObject;
import bindings.Ext;

import saturn.client.Program;
import saturn.client.workspace.Workspace;

class EXTApplication extends WorkspaceApplication{
    var viewPoint : Dynamic;
    var menuBar  : Dynamic;
    var navigatorPanel  : Dynamic;
    var middleSouthPanel  : Dynamic;
    var southPanel : Dynamic;
    var eastPanel  : Dynamic;
    var centralPanel : Dynamic;
	var searchBar : Dynamic;
    var tabPanel  : Dynamic;
    var centralInfoPanel : Dynamic;
	var searchBarStore : Dynamic;

    var appkeydown : Dynamic;
    var appkeyup : Dynamic;
    
    var fileMenu : Dynamic;
    var exportMenu : Dynamic;
    var importMenu : Dynamic;
    var workspaceExportMenu : Dynamic;
    var editMenu : Dynamic;
	var openMenu : Dynamic;
    var saveMenu : Dynamic;
    var saveAsMenu : Dynamic;
    var newMenu : Dynamic;
	
	var viewMenu : Dynamic;
    var helpMenu : Dynamic;
    var toolsMenu : Dynamic;
    
    var outlineDataStores : Map<String, Dynamic>;
    var outlineTrees : Map<String, Dynamic>;
	
	var jConsole : Dynamic;

    var enableOutlineDD : Bool;
	
	var theToolBar : Dynamic;

    var searchField : Dynamic;

    var northPanel : Dynamic;
    var rightMenu : Dynamic;
    var loginMenu : Dynamic;
    var loginMenuItem : Dynamic;
    var logoutMenuItem : Dynamic;
    var quickLaunchBar : Dynamic;
    var toolBar : Dynamic;
    var searchPanel : Dynamic;

    var northContainer : Dynamic;
    var appToolBar : Dynamic;
    var databaseMenu : Dynamic;

    var appContainer : SingleAppContainer;
    var oldToolBar : Dynamic;
    var reattachIndex :Int;
    var oldTitle : String;

    public function new(applicationTitle : String, navigationTitle : String, southTitle : String, detailsTitle : String, tabContainerTitle : String, searchBarTitle : String, nakedMode : Bool){
        super(applicationTitle, navigationTitle, southTitle, detailsTitle, tabContainerTitle, searchBarTitle, nakedMode);
    }

    override public function onProviderUp(){
        super.onProviderUp();

        enableOutlineDD = false;

        outlineTrees = new Map<String, Dynamic>();
        outlineDataStores = new Map<String, Dynamic>();

        Ext.Loader.setConfig({
            enabled: true,
            paths: {
                'Ext.ux': 'js/ext/ux',
                'Ext.grid.filters': 'js/ext/src/grid/filters'
            }
        });

        Ext.require('Ext.toolbar.Toolbar');
        Ext.require('Ext.data.TreeStore');
        Ext.require('Ext.container.Viewport');
        Ext.require('Ext.layout.container.Border');
        Ext.require('Ext.form.field.ComboBox');
        Ext.require('Ext.tree.Panel');
        Ext.require('Ext.tree.plugin.TreeViewDragDrop');
        Ext.require('Ext.grid.filters.Filters');

        Ext.define('org.sgc.TabReorder', {
            extend: 'Ext.tab.Panel',
            plugins: 'tabreorderer',
            requires: [
                'Ext.ux.TabReorderer'
            ],xtype: 'reorderable-tabs'

        });

        Ext.onReady(function() {
            Ext.application({
                name: 'Saturn',
                launch: function() {
                    viewPoint = Ext.create('Ext.container.Viewport', {layout: 'border'});

                    northContainer = Ext.create('Ext.Container', {layout: 'vbox', width   : '100%', region:'north', border: false});

                    northPanel = Ext.create('Ext.Container', {
                        layout: {
                            type:'hbox',
                            align:'center'
                        },
                        width: '100%',
                        region:'north',
                        border: false
                    });

                    northContainer.add(northPanel);

                    createAppToolBar();

                    viewPoint.add(northContainer);

                    js.Browser.window.onbeforeunload = function(event : js.html.Event){
                        return "Are you sure you want to close this window";
                    }

                    initApplication();
                }
            });
        });

        initialiseWindowListeners();
		
		jConsole = untyped __js__('console');

        clientCore.addLoginListener(setLoggedIn);
        clientCore.addLogoutListener(setLoggedOut);
    }

    override function initApplication(){
        super.initApplication();


    }

    public function getResourcesMenu() : Dynamic {
        return databaseMenu;
    }

    public function createAppToolBar(){
        appToolBar = Ext.create('Ext.toolbar.Toolbar', {
            region:'south',
            width   : '100%',
            minHeight: 26,
            maxHeight: 26,
            style: {
                //'background-color': '#2569B8'
                'background-color': '#6C6C6C'
            },
            flex: 1,
            border: false
        });

        appToolBar.add({
            iconCls :'x-btn-save-small',
            handler: function(){
                getWorkspace().saveWorkspace();
            },
            tooltip: {dismissDelay: 10000, text: 'Save workspace'}
        });

        appToolBar.add({
            iconCls :'x-btn-saveas-small',
            handler: function(){
                promptSaveAs();
            },
            tooltip: {dismissDelay: 10000, text: 'Save workspace as'}
        });

        appToolBar.add({
            iconCls :'x-btn-open-small',
            handler: function(){
                getWorkspace().openDefaultWorkspace();
            },
            tooltip: {dismissDelay: 10000, text: 'Open workspace (default)'}
        });

        appToolBar.add({
            iconCls :'x-btn-openas-small',
            handler: function(){
                promptOpenWorkspace();
            },
            tooltip: {dismissDelay: 10000, text: 'Open workspace (named)'}
        });

        appToolBar.add({
            iconCls :'x-btn-close-small',
            handler: function(){
                getWorkspace().closeWorkspace();
            },
            tooltip: {dismissDelay: 10000, text: 'Close workspace'}
        });

        /*appToolBar.add({
            iconCls :'x-btn-single-small',
            handler: function(){
                setMode(ScreenMode.SINGLE_APP);
            },
            tooltip: {dismissDelay: 10000, text: 'Enter single app mode'}
        });*/

        northContainer.add(appToolBar);
    }

    override public function addSaveAsOptions(){
        var p = getProvider();
        var activeProg = getActiveProgram();

        if(p == null || activeProg == null){
            return;
        }

        var progClazz = Type.getClass(getActiveProgram());
        var models : Array<Model> = activeProg.getSaveAsModelsForProgram();
        for(model in models){
            var name = model.getAlias();

            if(name == null){
                name = Type.getClassName(model.getClass());
            }

            getSaveAsMenu().add({
                text: name,
                handler: function(){
                    activeProg.saveObjectAsGUI(model);
                }
            });
        }
    }
	
	public function getConsole() {
		return jConsole;
	}
	
	override public function printInfo( message : String) {
		getConsole().info(message);
	}
    
    public function initialiseWindowListeners() : Void {
        var dWindow : Dynamic = js.Browser.document;
        
        dWindow.onmouseup=function(event){
            var activeProg : Program = getActiveProgram();
            
            if(activeProg != null){
                activeProg.mouseup(event);
            }
        };
        
        dWindow.onmousedown = function(event){
            var activeProg : Program = getActiveProgram();
            
            if(activeProg != null){
                activeProg.mousedown(event);
            }
        }

        var ctl = false;
		dWindow.onkeydown = function(event) {
			if (event.altKey) {
                ctl = true;

                event.preventDefault(); event.stopPropagation();
			}
		}

        appkeydown = dWindow.onkeydown;
		
		dWindow.onkeyup = function(event) {
            if(event.keyCode == 18){ //83
                ctl = false;
            }

			/*if (event.keyCode == 68 && ctl) {
                var dnaWO = new DNAWorkspaceObject(new DNA(""), 'DNA');

                getWorkspace().addObject(dnaWO, true);

                event.preventDefault(); event.stopPropagation();
			}else if (event.keyCode == 80 && ctl) {
                var dnaWO = new ProteinWorkspaceObject(new Protein(""), 'Protein');

                getWorkspace().addObject(dnaWO, true);

                event.preventDefault(); event.stopPropagation();
            }*/
		}

        appkeyup = dWindow.onkeyup;
    }

    override public function onkeyup(event){
        appkeyup(event);
    }

    override public function onkeydown(event){
        appkeydown(event);
    }
    
    public static function getCurrentApplication() : EXTApplication{
        return cast(WorkspaceApplication.getApplication(), EXTApplication);
    }
    
    override function addNewMenuItem(shortName : String, clazzName : String) {
		if (isNaked()) {
			return;
		}
		
        var self = this;
        var fileNewMenu : Dynamic = this.getFileNewMenu();

            fileNewMenu.add({ cls: 'menu-item-' + StringTools.replace(clazzName,'.','-'),text:shortName,handler: function(){
                var workspaceObject : Dynamic = Type.createInstance(Type.resolveClass(clazzName),[null, null]);
                
                self.getWorkspace().addObject(workspaceObject, true);
        }});
    }
	
	override function addSaveMenuItem() {
		if (nakedMode) {
			return;
		}
		

	}
	
	override function addOpenDefaultWorkspaceMenuItem() {
		if (nakedMode) {
			return;
		}
		
		var openMenu = getOpenMenu();

        if(isHostEnvironmentAvailable()){
            openMenu.add({
                text: 'Open File',
                handler: function(){
                    openHostFile(function(file: FileShim){
                        getWorkspace().openFile(file, true);
                    });
                }

            });
        }
		
		openMenu.add( { text:"Open Default Workspace", handler: Ext.bind(function() { theWorkspace.openDefaultWorkspace();	}, this) } );

        var self = this;

        getFileNewMenu().add({
            text : 'New workspace',
            handler : function(){
                Ext.Msg.show({
                    title:'Save Changes?',
                    msg: 'Save workspace before opening a new one?',
                    buttons: Ext.Msg.YESNOCANCEL,
                    icon: Ext.Msg.QUESTION,
                    fn : function(btn){
                        if(btn == 'yes'){
                            self.getWorkspace().saveWorkspace();                        
                        }

                        if(btn != 'cancel'){
                            self.getWorkspace().closeWorkspace();

                            Ext.Msg.prompt('New Workspace', 'Enter New Workspace name', function(btn, text){
                                self.getWorkspace().setWorkspaceName(text);
                                self.getWorkspace().saveWorkspace();
                            });
                        }
                    }
                });
            }
        });
	}
	
	override function addSaveWorkspaceMenuItem() {
		if (isNaked()) {
			return;
		}
		
		getSaveMenu().add( { text:"Save Workspace", handler: Ext.bind(function() { theWorkspace.saveWorkspace();	}, this) } );
	}

    override function addSaveWorkspaceAsMenuItem() {
		if (isNaked()) {
			return;
		}
		
        var self = this;

        getSaveMenu().add({
            text : 'Save Workspace As',
            handler : function(){
                promptSaveAs();
            }
        });
    }

    override function addOpenSavedWorkspaceMenuItem() {
		if (isNaked()) {
			return;
		}
		
        var self = this;

        getOpenMenu().add({
            text : 'Open Workspace',
            handler : function(){
                promptOpenWorkspace();
            }
        });
    }

    public function promptOpenWorkspace(){
        getWorkspace().getWorkspaceNames(function(workspaceNames : Array<String>){
                    var workspaceData : Array<Dynamic> = new Array<Dynamic>();

                    for(workspaceName in workspaceNames){
                        workspaceData.push({'name':workspaceName});
                    }

                    var workspaces  = Ext.create('Ext.data.Store', {
                        fields : ['name'],
                        data  : workspaceData
                    });

                    var windowId = Ext.id(null, 'UNIQUE_');
                    var uniqueId = Ext.id( null, 'UNIQUE_' );

                    var vBoxLayout : Array<Dynamic> = new Array<Dynamic>();
                    vBoxLayout.push({
                            xtype : 'combobox',
                            fieldLabel : 'Select workspace',
                            store : workspaces,
                            queryMode : 'local',
                            displayField : 'name',
                            valueField : 'name',
                            id : uniqueId
                    });

                    var buttonLayoutItems : Array<Dynamic> = new Array<Dynamic>();
                    buttonLayoutItems.push({
                            xtype : 'button',
                            text : 'Open',
                            handler : function(){
                                var comp = Ext.getCmp(uniqueId);
                                var workspaceName = comp.getValue();

                                getWorkspace().openWorkspace(workspaceName);

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
                        title: 'Open Workspace',
                        modal : true,
                        id : windowId,
                        layout : { type : 'vbox', align : 'stretch', padding: '2px' },
                        items: vBoxLayout,
                        width:600
                    }).show();
                });
    }

    public function promptSaveAs(){
        getWorkspace().getWorkspaceNames(function(workspaceNames : Array<String>){
            var workspaceData : Array<Dynamic> = new Array<Dynamic>();

            for(workspaceName in workspaceNames){
                workspaceData.push({'name':workspaceName});
            }

            var workspaces  = Ext.create('Ext.data.Store', {
                fields : ['name'],
                data  : workspaceData
            });

            var vBoxLayout : Array<Dynamic> = new Array<Dynamic>();

            vBoxLayout.push({
                xtype : 'form',
                layout : { type: 'hbox', pack : 'center', padding : '2px', defaultMargins : '2px'},
                items : {
                    xtype : 'combobox',
                    fieldLabel : 'Save As',
                    store : workspaces,
                    queryMode : 'local',
                    displayField : 'name',
                    valueField : 'name',
                    name: 'workspace'
                },
                buttons: [
                    {
                        xtype : 'button',
                        text : 'Save',
                        handler : function(btn){
                            var win = btn.up('window');
                            var form = win.down('form');

                            var name = form.getForm().findField('workspace').getValue();

                            getWorkspace().setWorkspaceName(name);
                            getWorkspace().saveWorkspace();

                            win.close();
                        }
                    },
                    {
                        xtype : 'button',
                        text : 'Cancel',
                        handler : function(btn){
                            btn.up('window').close();
                        }
                    }
                ]
            });

            Ext.create('Ext.window.Window', {
                title: 'Save As',
                modal : true,
                layout : { type : 'vbox', align : 'stretch', padding: '2px' },
                items: vBoxLayout
            }).show();
        });
    }
    
    override function createMenuBar() {
		if (isNaked()) {
			return;
		}

       Ext.suspendLayouts();

       var self = this;

       menuBar = Ext.create('Ext.toolbar.Toolbar', {
			region:'west',
            //renderTo: northPanel,
            width   : 500,
            listener:{
                render:function(){

                }
            },
            flex: 2,
            border: false
		});

        rightMenu = Ext.create('Ext.toolbar.Toolbar', {
            region:'east',
            //renderTo: js.Browser.document.body,
            listener:{
                render:function(){

                }
            },
            border: false
        });

        loginMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        var loginText = ClientCore.getClientCore().isLoggedIn() ? ClientCore.getClientCore().getUser().fullname : 'Login';

        loginMenuItem = rightMenu.add({
            text: loginText,
            iconCls: 'bmenu',  // <-- icon
            menu: loginMenu, // assign menu by instance
            cls:'menu-item-FILE',
            handler: function(){
                if(!ClientCore.getClientCore().loggedIn){
                    loginMenu.hide();

                    loginPrompt();


                }
            }
        });

        logoutMenuItem = loginMenu.add({
            text: 'Logout',
            handler: function(){
                ClientCore.getClientCore().logout();
            },
            hidden : !ClientCore.getClientCore().isLoggedIn()
        });

        northPanel.add(menuBar);
        northPanel.add(searchBar);
        northPanel.add(rightMenu);

        //panel.add(menuBar);
        //panel.add(rightMenu);

        menuBar.suspendLayouts();
        
        fileMenu = Ext.create('Ext.menu.Menu', {
			margin: '0 0 10 0','z-index': 1000000});

	    menuBar.add({
            text:'File',
            iconCls: 'bmenu',  // <-- icon
            menu: fileMenu, // assign menu by instance
            cls:'menu-item-FILE'
        });

		newMenu = Ext.create('Ext.menu.Menu', {
            margin: '0 0 10 0'});

        fileMenu.add({
            text:'New',
            iconCls: 'bmenu',  // <-- icon
            menu: newMenu,  // assign menu by instance
            cls: 'menu-item-NEW',
        });

		openMenu = Ext.create('Ext.menu.Menu', {
            margin: '0 0 10 0'});

        fileMenu.add({
            text:'Open',
            iconCls: 'bmenu',  // <-- icon
            menu: openMenu  // assign menu by instance
        });

        saveMenu = Ext.create('Ext.menu.Menu', {
            margin: '0 0 10 0'});

        fileMenu.add({
            text:'Save',
            iconCls: 'bmenu',  // <-- icon
            menu: saveMenu  // assign menu by instance
        });

        saveAsMenu = Ext.create('Ext.menu.Menu', {
            margin: '0 0 10 0'});

        fileMenu.add({
            text:'Save As',
            iconCls: 'bmenu',  // <-- icon
            menu: saveAsMenu  // assign menu by instance
        });

        exportMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        fileMenu.add({
            text:'Export',
            iconCls: 'bmenu',  // <-- icon
            menu: exportMenu, // assign menu by instance
            cls:'menu-item-FILE'
        });

        workspaceExportMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        fileMenu.add({
            text:'Workspace Export',
            iconCls: 'bmenu',  // <-- icon
            menu: workspaceExportMenu, // assign menu by instance
            cls:'menu-item-FILE'
        });

        workspaceExportMenu.add({
            text: 'Export to file',
            handler: function(){
                getWorkspace().saveWorkspaceToFile(getWorkspace().getWorkspaceName() + '.sat');
            }
        });

        importMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        fileMenu.add({
            text:'Import',
            iconCls: 'bmenu',  // <-- icon
            menu: importMenu, // assign menu by instance
            cls:'menu-item-FILE'
        });

        editMenu = Ext.create('Ext.menu.Menu', {
			margin: '0 0 10 0','z-index': 1000000});

	    menuBar.add({
            text:'Edit',
            iconCls: 'bmenu',  // <-- icon
            menu: editMenu  // assign menu by instance
        });

		viewMenu = Ext.create('Ext.menu.Menu', {
			margin: '0 0 10 0','z-index': 1000000});

	    menuBar.add({
            text:'View',
            iconCls: 'bmenu',  // <-- icon
            menu: viewMenu  // assign menu by instance
        });
        toolsMenu = Ext.create('Ext.menu.Menu', {
        margin: '0 0 10 0','z-index': 1000000});

        menuBar.add({
            text:'Tools',
            iconCls: 'bmenu',  // <-- icon
            menu: toolsMenu  // assign menu by instance
        });

        databaseMenu = Ext.create('Ext.menu.Menu', {
        margin: '0 0 10 0','z-index': 1000000});

        toolsMenu.add({
            text:'Resources',
            iconCls: 'bmenu',  // <-- icon
            menu: databaseMenu  // assign menu by instance
        });

        toolsMenu.add({
            text: 'Toggle Progress Window',
            handler: function(){
                if(!progressWindow.isVisible()){
                    progressWindow.show();
                    alwaysShowProgressWindow = true;

                    updateProgress();
                }else{
                    progressWindow.hide();
                    alwaysShowProgressWindow = false;
                }
            }
        });

        databaseMenu.add({
            text : 'Clear cache',
            handler : function(){
                getProvider().resetCache();
            }
        });

        databaseMenu.add({
            text: 'Alias active',
            handler: function(){
                userValuePrompt('Alias Active', 'Enter global variable name', function(name){
                    var d : Dynamic = js.Browser.window;

                    Reflect.setField(d, name, getActiveProgram());
                }, null);
            }
        });

        helpMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        helpMenu.add({
            text : 'About',
            handler : function(){
                var items = new Array<Dynamic>();

                var hItems : Array<Dynamic> = [
                    {
                        xtype: 'imagecomponent',
                        src: '/static/js/images/saturn.png',
                        width: 50,
                        height: 72,
                        title: 'Saturn'
                    },
                    {
                        xtype: 'label',
                        text: 'SATURN v 1.0'
                    }
                ];

                items.push({
                    xtype:'container',
                    layout: {
                        type: 'hbox',
                        align: 'center'
                    },
                    items: hItems
                });

                items.push({
                    xtype: 'panel',
                    items: [
                        {
                            xtype: 'component',
                            html: '<div>License: GPL version 3 (copyright SGC 2014)<br/><br/>David Damerell<br/>Brian Marsden<br/>Claire Strain-Damerell</div>'
                        }
                    ]
                });

                var dataItems = new Array<Dynamic>();
                for(clazz in getProgramRegistry().getProgramList()){
                    dataItems.push({plugin: Type.getClassName(clazz)});
                }

                Ext.create('Ext.window.Window', {
                    title: 'About',
                    modal : true,
                    layout : { type : 'vbox', align : 'stretch', padding: '2px' },
                    items: items
                }).show();

                //showMessage('About','License: GPL version 3<br/>Authors: David Damerell<br/>Brian Marsden<br/>Claire Strain-Damerell');
            }
        });

        helpMenu.add({
            text: 'Manual',
            handler: function(){
                var guide = new WebPage();

                guide.setURL('http://athena:8090/MolBioGuide.html');

                var wo = new WebPageWorkspaceObject(guide,'Guide');

                var wk = getWorkspace();

                wk.addObject(wo,true);
            }
        });

        menuBar.add({
            text:'Help',
            iconCls: 'bmenu',  // <-- icon
            menu: helpMenu  // assign menu by instance
        });

        getFileMenu().add({
            text : 'Close workspace',
            handler : function(){
                Ext.Msg.show({
                title:'Save Changes?',
                msg: 'Save workspace before closing?',
                buttons: Ext.Msg.YESNOCANCEL,
                icon: Ext.Msg.QUESTION,
                fn : function(btn){
                    if(btn == 'yes'){
                        self.getWorkspace().saveWorkspace();
                    }

                    if(btn != 'cancel'){
                        self.getWorkspace().closeWorkspace();
                    }
                }
                });
            }
        });

        getFileMenu().add( {
            text:'Close all programs',
            handler : function() {
                self.getWorkspace().closeAllObjects();
            }
        });

        menuBar.resumeLayouts(true);

        Ext.resumeLayouts(true);
        //viewPoint.add(northPanel);
    }
	
	override function destroyMenu() {
		//viewPoint.remove(menuBar);
        northPanel.remove(menuBar);
        northPanel.remove(rightMenu);
	}
	
	override public function getOpenMenu() {
			return openMenu;
	}

    override public function getSaveMenu() {
        return saveMenu;
    }

    override public function getSaveAsMenu() {
        return saveAsMenu;
    }
    
	override public function getFileMenu() {
			return fileMenu;
	}

    override public function getExportMenu() {
        return exportMenu;
    }

    override public function getImportMenu() {
        return importMenu;
    }

    override public function getWorkspaceExportMenu() : Dynamic {
        return workspaceExportMenu;
    }

	override public function getViewMenu() {
		return viewMenu;
	}

    override public function getToolsMenu(){
        return toolsMenu;
    }
	
    override public function getFileNewMenu(){
        return this.newMenu;
    }
    
    override public function getMenuBar(){
        return this.menuBar;
    }

    override public function getEditMenu(){
        return this.editMenu;
    }
    
    override function createNavigationPanel(navTitle : String) {
		theWorkspace = new Workspace();
		
		if (isNaked()) {
			return;
		}
		
        navigatorPanel =  Ext.create('Ext.panel.Panel',
			{
				region: 'west',
                collapsible: true,
                collapseMode: 'mini',
                hideCollapseTool: true,
                title: navTitle,
                split: true,
                width: 150,
                layout: 'fit'
				/*layout: {
					type: 'vbox',
					align : 'stretch',
					pack  : 'start',
				} */
			}
		);
													
		/*theToolBar = Ext.create('Ext.toolbar.Toolbar', {
			items : [
				{
					text : 'Test'
				}
			]
		});
		
		navigatorPanel.add(theToolBar);*/
        
        navigatorPanel.add(theWorkspace.getComponent());
                                                    
        viewPoint.add(navigatorPanel);
    }
    
    override public function getNavigationPanel(){
        return this.navigatorPanel;
    }
    
    override function createMiddleSouthPanel(southTitle : String) {
		if (isNaked()) {
			return;
		}
		
        middleSouthPanel = Ext.create('Ext.panel.Panel',
            {
                region: 'south',
                title: southTitle,
                collapsible: true,
                collapseMode:'mini',
                hideCollapseTool: true,
                html: '',
                split: true,
                height: 100,
                minHeight: 100,
                border: false,
                autoScroll: true
            }
        );

        centralPanel.add(middleSouthPanel);
    }

    override function createSouthPanel(southTitle : String) {
        if (isNaked()) {
            return;
        }

        js.Browser.window.console.log('Creating south panel');

        southPanel = Ext.create('Ext.Container',
            {
                region: 'south',
                title: southTitle,
                collapsible: false,
                collapseMode: 'mini',
                hideCollapseTool: true,
                html: '',
                split: true,
                height: 50,
                minHeight: 50,
                border: false,
                style: {
                    'background-color': 'white'
                }
            }
        );

        quickLaunchBar = Ext.create('Ext.toolbar.Toolbar', {
            flex: 1,
            border: false,
            style: {
                'background-color': 'white'
            },
            overflowHandler: 'menu' //scroller
        });

        /*quickLaunchBar.add({
            xtype: 'label',
            text: 'Apps',
            style: {
                'font-family': "Arial, 'Helvetica Neue', Helvetica, sans-serif",
               'font-size': '24px',
                'border-right': '1px solid'
            }
        });*/

        southPanel.add(quickLaunchBar);

        viewPoint.add(southPanel);
    }
	
	override function clearSouthPanel() {
		if (isNaked()) {
			return;
		}

        showMiddleSouthPanel();
        //hideMiddleSouthPanel();
	}
    
    override public function getMiddleSouthPanel(){
        return this.middleSouthPanel;
    }

    override public function hideMiddleSouthPanel(){
        middleSouthPanel.setVisible(false);
        centralInfoPanel.setVisible(false);
    }

    override public function showMiddleSouthPanel(){
        middleSouthPanel.setVisible(true);
        centralInfoPanel.setVisible(true);
    }

    override public function getQuickLaunchBar(){
        return quickLaunchBar;
    }
    
    override function createDetailsPanel(detailsTitle : String) {     
		if (isNaked()) {
			return;
		}
		
        eastPanel = Ext.create('Ext.panel.Panel',
                                    {
                                        region: 'east',
                                        title: detailsTitle,
                                        collapsible: true,
                                        split: true,
                                        width: 150, 
                                        layout: 'border',
                                        border: true,
                                        collapseMode: 'mini',
                                        hideCollapseTool: true,
                                        height: '100%'
                                     }
        );

        installOutlineTree('DEFAULT',false, false, null);
                                                
        viewPoint.add(eastPanel);
    }

    override public function installOutlineTree(name: String, enableDrop : Bool, enableContainerDrop : Bool, modelName : String, mode : String = 'STANDARD') {
        var self : EXTApplication = this;

        if(outlineTrees.exists(name)){
            eastPanel.remove(outlineTrees.get(name));
        }
        var outlineDataStore = null;

		if (modelName == null) {
			outlineDataStore = Ext.create('Ext.data.TreeStore', {
				root: {
					expanded: true,
					autoSync : true
				},proxy: {
                    type: 'memory'
                }
			});
		}else{
			outlineDataStore = Ext.create('Ext.data.TreeStore', {
				model : modelName,
				root: {
					expanded: true,
					autoSync : true,
					allowDrop : enableContainerDrop
				},proxy: {
					type: 'memory'
				}
			});
		}
		
		if (isNaked()) {
			return;
		}

        var region = name == 'MODELS' ? 'center': 'north';

        var plugins = '';

        var columns : Array<Dynamic> = null;

        if(mode == 'GRID'){
            plugins = 'cellediting';

            columns = [
                {
                    xtype: 'treecolumn',
                    dataIndex: 'folder',
                    flex: 1
                },
                {
                    dataIndex: 'text',
                    flex: 1,
                    editor: {
                        xtype: 'textfield',
                        readonly: false
                    }
                }
            ];
        }

        var viewConfig = {};

        if(name == 'DEFAULT'){
            viewConfig = {
                plugins: {
                        ptype: 'treeviewdragdrop',
                        enableDrag : true,
                        enableDrop : enableDrop,
                        pluginId : 'treedd',
                        allowContainerDrops : false,
						appendOnly: true
                },
				copy:true,
				listeners: {
                    'beforedrop' : function( node, data, overModel, dropPosition, dropHandlers, eOpts ){
                        return self.onOutlineDrop(node, data, overModel, dropPosition, dropHandlers, eOpts);
                    },
					itemclick:function(view, rec, item, index) {
						fireOutlineItemClicked(view, rec, item, index);
					}
                 },
                region:region
             };
        }

        var outlineTree = Ext.create('Ext.tree.Panel', {
            store: outlineDataStore,
            rootVisible: false,
            //renderTo: Ext.getBody(),
            hideHeaders: true,
            viewConfig: viewConfig,
            border: false,
            columns: columns,
            plugins: plugins,
            region: region//,
        //autoHeight: true
         });

        outlineTrees.set(name, outlineTree);
        outlineDataStores.set(name, outlineDataStore);
        
         eastPanel.add(outlineTree);

        eastPanel.doLayout();
    }

    override public function getEastPanel() : Dynamic {
        return eastPanel;
    }

    override public function getOutlineTree(name : String) : Dynamic{
        return outlineTrees.get(name);
    }

    public function onOutlineDrop(node, data, overModel, dropPosition, dropHandlers, eOpts){
        return getActiveProgram().onOutlineDrop(node, data, overModel, dropPosition, dropHandlers, eOpts);
    }
	
	override function clearDetailsPanel() {
		if (isNaked()) {
			return;
		}

        for(name in outlineDataStores.keys()){
            var dataStore :Dynamic = getOutlineDataStore(name);

            var rootNode : Dynamic = dataStore.getRootNode();

            rootNode.removeAll();
        }

	}
    
    override public function getOultineTree(name : String){
        return this.outlineTrees.get(name);
    }
    
    override public function getOutlineDataStore(name : String){
        return this.outlineDataStores.get(name);
    }
    
    override public function getDetailsPanel(){
        return this.eastPanel;
    }
    
    override function createCentralPanel() {
		var regionPosition = 'center';
		if (isNaked()) {
			regionPosition = 'north';
		}
		
        centralPanel = Ext.create('Ext.Container',{
            layout : 'border',
            region : regionPosition,
			height : '100%'
        });

        viewPoint.add(centralPanel);
    }

    override public function setCentralInfoPanelText( txt : String){
        centralInfoPanel.body.update(txt);
    }
	
	override public function createSearchBar(searchBarTitle : String) {		
		if (isNaked()) {
			return;
		}
		
		var fieldArray :  Array<Dynamic> = [
				{
					name: 'title',
					mapping: function(raw) {
						return raw.title;
					}
				},
				{
					name: 'id',
					mapping: function(raw) {
						return raw.id;
					}
				},
                {
                    name: 'icon',
                    mapping: function(raw) {
                        return raw.icon;
                    }
                }
			];
		
		this.searchBarStore = Ext.create('Ext.data.Store', {
			fields:  fieldArray,
			storeId : 'SEARCH_BAR',
            //data :[{'title': '', id:''}]
		});


	
		var self = this;

        searchBar = Ext.create('Ext.form.field.ComboBox', {
            displayField: 'title',
            focusOnToFront: false,
            valueField: 'id',
            region: 'west',
            emptyText: 'Type to search (targets/constructs/alleles/entry clones/primers/compounds)',
            store:  Ext.data.StoreManager.lookup('SEARCH_BAR'),
            enableKeyEvents: true,
            doQuery: function(queryStr) {
                if (queryStr == "") {
                    if(searchBar.rawValue == ''){
                        self.autocomplete_update([]);

                        /**
                        * Deleting the search term quickly can result in a portion of the search term
                        * reappearing after a very small deley.  Calling setRawValue with an empty
                        * value seems to prevent this.
                        **/
                        searchBar.setRawValue('');
                    }else{
                        searchBar.expand();
                    }

                    return true;
                }else{
                    var value = searchBar.rawValue;

                    self.autoCompleteSearchBar(queryStr);

                    return true;
                }
            },
            listeners: {
                select : function(comboBox, records) {
                    self.fireSearchObjectSelected(records);
                },
                'afterrender': function(){
                    Ext.QuickTips.register({dismissDelay: 10000, target: searchBar.getEl(), text: 'Prefix searches (cp-Construct Plate, ap-Allele Plate, pdb-PDB ID'});
                }
            },
            flex:1,
            tpl: Ext.create('Ext.XTemplate',


                '<tpl for=".">' +
                '<tpl if="this.group != values.group">' +
                '<tpl exec="this.group = values.group"></tpl>' +
                '<div  style="background-color:grey;color:white;padding-left:2px" title="{group}">{group}</div>' +
                '</tpl>' +
                '<div class="x-boundlist-item" style="background-image: url(/static/js/images/{icon});padding-left:20px;background-position: left center;background-repeat: no-repeat; ">{title}</div>' +
                '</tpl>'
            ),
            defaultListConfig:{
               maxHeight: 500
            }
        });

        //class="x-panel-header-default x-panel-header-text-container x-panel-header-text x-panel-header-text-default"

        /*'<tpl for=".">'+
        '<div class="x-boundlist-item" style="background-image: url(/static/js/images/{icon});padding-left:20px;background-position: left center;background-repeat: no-repeat; ">{title}</div>'+
        '</tpl>'*/


        //Ext.form.Panel
        searchPanel = Ext.create('Ext.Panel', {
            layout: {
                type: 'hbox',       // Arrange child items vertically
                padding: 5,
                align: 'center'
            },
            region : 'north',
            border: false
        });

        //northPanel.add(searchBar);

        var searchFN = function(){
            var value = searchField.getValue();

            getActiveProgram().search(value);
        };

        searchField = Ext.create('Ext.form.field.Text', {
            name: 'name',
            enableKeyEvents: true,
            valueField: 'searchBox',
            emptyText: 'Type to search',
            listeners:{
                keyup: {
                    fn: searchFN
                },
                focus: {
                    fn: searchFN
                }
            },
            disabled: true,
            style: {
                'margin-left': '4px'
            }
            //fieldLabel: 'Name'
        });

        createToolBar();
        searchPanel.add(searchField);
		
		centralPanel.add(searchPanel);
	}

    override public function destroyToolBar(){
        js.Browser.window.console.log('Removing toolbar');
        //searchPanel.remove(toolBar);

        Ext.suspendLayouts();

        toolBar.removeAll();

        Ext.resumeLayouts(true);

        //toolBar = null;
    }

    override public function createToolBar(){
        js.Browser.window.console.log('Creating toolbar');
        if(toolBar ==null){
            toolBar = Ext.create('Ext.toolbar.Toolbar', {
                region:'east',
                width   : 500,
                minHeight: 26,
                listener:{
                    render:function(){

                    }
                },
                flex: 1,
                border: false,
                enableOverflow: true
            });

            searchPanel.add(toolBar);
        }

        /*toolBar.add({
            iconCls :'x-btn-save',
            handler: function(){
                getWorkspace().saveWorkspace();
            }
        });*/
    }

    override public function setProgramSearchFieldEmptyText(emptyText : String){
        searchField.emptyText = emptyText;
        searchField.applyEmptyText();
    }

    override public function clearProgramSearchField(){
        searchField.setValue('');
    }

    override public function enableProgramSearchField(enable : Bool){
        searchField.setDisabled(!enable);
    }
	
	function autoCompleteSearchBar(queryStr) {
		fireSearchTermChanged(queryStr);
	}

    override function createTabContainer(tabTitle : String) {
		var regionPosition = 'center';
		var regionHeight = '90%';
		
		if (isNaked()) {
			regionPosition = 'north';
			regionHeight = '100%';
			
			tabPanel = Ext.create('Ext.Panel',{
                                            region: regionPosition,
                                            layout: 'fit',height:regionHeight,
                                            xtype: 'panel' // TabPanel itself has no title
											
                                           });
			centralPanel.add(tabPanel);
		}else{


			tabPanel = Ext.create('org.sgc.TabReorder',{
                border: false,
                                            region: regionPosition,
                                            layout: 'fit',height:regionHeight,
                                            //xtype: 'tabpanel', // TabPanel itself has no title
                                            activeTab: 0      // First tab active by default
                                           });
			centralPanel.add(tabPanel);
        
			tabPanel.addListener('tabchange',function(tabContainer, newTab, previousTab){
                if(screenMode != ScreenMode.SINGLE_APP){
                    setProgramSearchFieldEmptyText('Type to search');
                    enableProgramSearchField(false);

                    if(Std.is(newTab.parentBuildingBlock, BuildingBlock)){
                        var buildingBlock : BuildingBlock = newTab.parentBuildingBlock;

                        var program : Dynamic = buildingBlock;

                        if (theActiveProgram == null || theActiveProgram != program && !getWorkspace().isReloading()) {
//getWorkspace().setActiveObject(program.getActiveObjectId());
                            setActiveProgram(program);
                        }
                    }
                }
			});
		}
    }

    override function createCentralInfoPanel() {
		if (isNaked()) {
			return;
		}
		
		centralInfoPanel = Ext.create('Ext.Panel', {
			region:'south',
			height : 20,
			layout: 'auto',
            border: false,
            cls: 'saturn-info-panel',
            style: {
                'background-color': 'grey'
            }
			/*items :[
				{tag:'u', html:'Information'}
			]*/
			//html : '<u>Information</ul>'
		});

		centralPanel.add(centralInfoPanel);
    }
    
    override public function getTabContainer(){
        return this.tabPanel;
    }
	
	override private function autocomplete_update(items : Array<Dynamic>) {
        js.Browser.window.console.log('Size: ' +items.length);

		searchBarStore.loadData(items);

        //Bug in EXTJS 5 http://www.sencha.com/forum/showthread.php?291487
        searchBar.picker.navigationModel.recordIndex = 0;
        searchBar.picker.navigationModel.record = null;

        searchBar.bindStore(searchBarStore, true);

        if(items.length > 0){
            searchBar.expand();
        }else{
            //searchBar.collapse();
        }
	}

    override public function setInformationPanelText(content : String, isHtml : Bool){
        var southPanel = getMiddleSouthPanel();

        var node :js.html.Element = middleSouthPanel.getEl().dom.childNodes[1];

        if(isHtml){
            node.innerHTML = content;
        }else{
            node.innerText = content;
        }
    }

    override public function loginPrompt(){
        var windowId = Ext.id(null, 'UNIQUE_');

        //Function to perform login
        var loginfn = function(obj){
            //Get modal dialog and form objects
            var win = obj.up('window');
            var form = win.down('form');

            //Get username and password from input fields
            var username = form.getForm().findField('username').getValue();
            var password = form.getForm().findField('password').getValue();

            //Perform login
            ClientCore.getClientCore().login(username, password, function(err, user : User){
                if(err){
                    Ext.Msg.alert(err);
                }else{
                    win.close();
                }
            });
        };

        //Function to handle Enter and Tab key press on input fields
        var onSpecialKey = function(obj : Dynamic,e){
            //Get modal dialog and form objects
            var win = obj.up('window');
            var form = win.down('form');

            if(e.getKey()==e.ENTER){
                //Enter pressed - check if input is valid
                var values = form.query("field{isValid()==false}");

                if(values.length == 0){
                    //Submit form
                    loginfn(obj);
                }
            }else if(e.getKey() == e.TAB){
                //Tab key pressed
                //TODO: Upgrade EXTJS so we don't have to do this ourselves

                //Check field has focus and move focus to the other
                var isUsernameField = false;
                if(obj.getFieldLabel() == 'Username'){
                    isUsernameField = true;
                }

                if(isUsernameField){
                    //Delay required as we aren't supressing the browser tab event
                    form.getForm().findField('password').focus(false, 200);
                }else{
                    //Delay required as we aren't supressing the browser tab event
                    form.getForm().findField('username').focus(false, 200);
                }
            }
        };

        //Form components
        var components : Array<Dynamic> = [
            {
                fieldLabel: 'Username',
                name: 'username',
                listeners: {
                    specialkey: onSpecialKey
                }
            },
            {
                fieldLabel: 'Password',
                name: 'password',
                inputType: 'password',
                allowBlank: false,
                listeners:{
                    specialkey: onSpecialKey
                }
            }
        ];

        //Window components
        var items : Array<Dynamic> = [];
        items.push({
            xtype: 'form',
            height: 150,
            width: 300,
            bodyPadding: 10,
            defaultType: 'textfield',
            items: components,
            buttons: [
                {
                    xtype: 'button',
                    text: 'Login',
                    formBind: true,
                    disabled: true,
                    handler: function(obj){
                        loginfn(obj);
                    }
                }
            ]
        });

        //Create modal window
        Ext.create('Ext.window.Window', {
            title: 'Login',
            modal : true,
            id : windowId,
            layout : { type : 'vbox', align : 'stretch', padding: '2px' },
            items: items,
            autoShow: true,
            //EXTJS query find form and then textfields
            defaultFocus: 'form textfield'
        });

    }

    public function getLoginMenuItem() : Dynamic {
        return loginMenuItem;
    }

    override public function setLoggedIn(user : Dynamic){
        loginMenuItem.setText(user.fullname);

        if(!ClientCore.getClientCore().isLogoutDisabled()){
            logoutMenuItem.show();
        }else{
            loginMenuItem.menu = null;
        }
    }

    override public function setLoggedOut(){
        loginMenuItem.setText('Login');

        logoutMenuItem.hide();
    }

    override public function getToolBar() : Dynamic {
        return toolBar;
    }

    override public function exitSingleMode(){
        var prog = getActiveProgram();

        if(prog != null){
            tabPanel.insert(reattachIndex,prog.getComponent());

            centralPanel.add(middleSouthPanel);
            centralPanel.add(centralInfoPanel);

            viewPoint.remove(appContainer.getComponent());

            viewPoint.doLayout();

            viewPoint.add(northContainer);
            viewPoint.add(navigatorPanel);
            viewPoint.add(eastPanel);
            viewPoint.add(southPanel);
            viewPoint.add(centralPanel);

            toolBar = oldToolBar;

            viewPoint.doLayout();

            tabPanel.setActiveTab(reattachIndex);

            prog.setTitle(oldTitle);
        }
    }

    override public function enterSingleAppMode(){
        var prog = getActiveProgram();

        if(prog != null){
            //prog.blurProgram();

            oldTitle = prog.getComponent().tab.text;

            reattachIndex = tabPanel.items.findIndex('id', tabPanel.getActiveTab().id);

            viewPoint.remove(northContainer, false);
            viewPoint.remove(navigatorPanel, false);
            viewPoint.remove(eastPanel, false);
            viewPoint.remove(southPanel, false);
            viewPoint.remove(centralPanel, false);

            viewPoint.doLayout();

            appContainer = new SingleAppContainer();

            viewPoint.add(appContainer.getComponent());

            oldToolBar = toolBar;

            toolBar = appContainer.getControlToolBar();

            appContainer.setProgram(prog);

            appContainer.getCentralContainer().add(middleSouthPanel);
            appContainer.getCentralContainer().add(centralInfoPanel);

            viewPoint.show();
            viewPoint.doLayout();

            //prog.getComponent().doLayout();
        }
    }

    override public function getSingleAppContainer() : SingleAppContainer {
        return appContainer;
    }
}
