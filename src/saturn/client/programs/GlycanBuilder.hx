/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import haxe.ds.HashMap;
import saturn.client.programs.SimpleExtJSProgram;

import saturn.core.domain.Glycan;
import saturn.client.workspace.GlycanWO;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import saturn.client.core.CommonCore;

import bindings.Ext;

/**
* GlycanBuilder is a wrapper for the Vaadin/Java GlycanBuilder application.
*
* This class expects to be able to communicate with GlycanBuilder on the same host and port as the SATurn server is
* listening on.  In the SATurn server service configuration file you will find a proxy directive which causes the
* NodeJS SATurn server to proxy requests to where you have configured GlycanBuilder to run from.
*
**/
class GlycanBuilder extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ GlycanWO ];

    // Used to store commands which we are trying to run before GlycanBuilder has been initialised
    var storedCommands : Array<Array<Dynamic>> = new Array<Array<Dynamic>>();

    var theComponent : Dynamic;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        var url = js.Browser.window.location.protocol + '//'+js.Browser.window.location.hostname+':'+js.Browser.window.location.port + '/GlycanBuilder/GlycanBuilder.html';

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            height: '95%',
            autoScroll : true,
            layout : 'border',
            items : [
                {
                    xtype : "component",
                    region: "north",
                    autoEl : {
                        tag : "iframe",
                        src : url,
                        width : "100%",
                        style: {
                            height : "100%"
                        }
                    }
                }
            ],
            listeners : {
                'render' : function() {
                    initialiseDOMComponent();
                }
            }
        });
    }

    override public function initialiseDOMComponent() {
        super.initialiseDOMComponent();

        // To communicate with the GlycanBuilder application we need a special object to be made available by the application
        // pokeCanvas causes this special object to be made available to us
        pokeCanvas(function(error : String){
            if(error != null){
                getApplication().showMessage('Error', error);
            }else{
                // Run any stacked commands
                if(storedCommands.length > 0){
                    while(storedCommands.length>0){
                        var unit = storedCommands.pop();
                        runCanvasCommand(unit[0],unit[1] );
                    }
                }
            }
        });
    }

    /**
    * pokeCanvas causes the GlycanBuilder canvas to make a special object available to us which we can use to
    * communicate with the canvas to import and export structures
    **/
    public function pokeCanvas(cb : String->Void){
        var giframe = getComponent().getEl().down('iframe').dom;
        var clicked = false;

        // There's a bug in the GlycanBuilder canvas which means that the special object we require to communicate with
        // isn't created unless GlycanBuilder has rendered the canvas once.  For now we trigger the rendering by
        // clicking the select-all button with JavaScript
        var checkCanvas = null;
        checkCanvas = function(){
            if(giframe != null){
                var giDocument = giframe.contentDocument;

                var matchingItems :Array<Dynamic> = giDocument.querySelectorAll("[src='/GlycanBuilder/VAADIN/themes/ucdb_2011theme/icons/selectall.png']");

                if(matchingItems.length > 0){
                    var imgElement = matchingItems[0];
                    var selectAllButton = imgElement.parentElement;
                    if(!clicked){
                        selectAllButton.click();
                        clicked = true;
                    }

                    if(giframe.contentWindow.glycanCanvas != null){
                        cb(null); return;
                    }
                }
            }

            haxe.Timer.delay(checkCanvas, 100);
        }

        checkCanvas();
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().installOutlineTree('MODELS',true, false, 'WorkspaceObject', 'GRID');

        if(getActiveObjectId() != null){
            var glycan :Glycan = getActiveObjectObject();

            addModelToOutline(glycan, true);
        }

        getApplication().hideMiddleSouthPanel();
    }

    /**
    * getCanvasContents can be used to get the contents of the Vaadin GlycanCanvas as a string
    *
    * cb: First parameter is the contents of the canvas as a string
    **/
    public function getCanvasContents(cb){
        runCanvasCommand('export~glycoct_condensed', cb);
    }

    /**
    * runCanvasCommand can be used to send a command to the Vaadin Glycan Canvas
    *
    * command: Command to run (i.e. export~glycoct_condensed)
    * cb: Passed response as first parameter
    **/
    public function runCanvasCommand(command, cb){
        var hook = getCanvasHook();

        if(hook == null){
            storedCommands.push([command,cb]);
            return;
        }

        // if first load you need to trick the canvas into building the canvas
        //var elems = document.querySelectorAll('[src]') find img with selectall then get button parent and click it

        var gcb = [];
        untyped {
            gcb.run = function(res){
                cb(res);
            };
        }

        hook.runCommand(command,gcb);
    }

    /**
    * canvasLoaded returns true if the Vaadin Glycan Canvas has loaded
    **/
    public function canvasLoaded(){
        return getCanvasHook() == null ? false : true;
    }

    /**
    * getCanvasHook returns the hook into the Vaadin Glycan Canvas
    **/
    public function getCanvasHook(){
        var giframe = getComponent().getEl().down('iframe').dom;

        return giframe.contentWindow.glycanCanvas;
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var w0 : GlycanWO = cast(super.getActiveObject(GlycanWO), GlycanWO);
        var obj : Glycan = cast(w0.getObject(), Glycan);

        setTitle(w0.getName());

        if(obj.content != null){
            // Load glycans if any exist
            loadContent(obj.contentType, obj.content);
        }
    }

    /**
    * loadContent glycans from string
    *
    * contentType: Notation format (i.e. glycoct_condensed
    * content: Glycan string
    **/
    public function loadContent(contentType : String, content : String){
        runCanvasCommand('import~'+contentType + '~' + content, function(res){

        });
    }

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }


    override public function getComponent() : Dynamic {
        return theComponent;
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-glycanbuilder',
                text:'GlycanBuilder',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new GlycanWO(null, null), true);
                }
            }
        ];
    }

    override public function saveWait(cb){
        var obj = getActiveObjectObject();

        // Get glycan canvas contents as a string
        getCanvasContents(function(res){
            var obj = getActiveObjectObject();
            obj.content = res;
            obj.contentType = 'glycoct_condensed';

            cb();
        });
    }

    override public function saveAsync(cb : String->Void){
        var glycan = getObject();

        getCanvasContents(function(res){
            glycan.content = res;
            glycan.contentType = 'glycoct_condensed';

            cb(null);
        });
    }

    override public function openFile(file : Dynamic, asNew : Bool, ? asNewOpenProgram : Bool = true) : Void{
        parseFile(file, function(contents){

        },asNewOpenProgram);
    }

    public static function parseFile(file : Dynamic, ?cb=null, ?asNewOpenProgram : Bool = true){
        var extension = CommonCore.getFileExtension(file.name);
        if(extension == 'glycoct_condensed'){
            CommonCore.getFileAsText(file, function(contents){
                if(contents != null){
                    var name = 'Glycan';
                    var glycan = new Glycan();
                    glycan.content = contents;
                    glycan.contentType = 'glycoct_condensed';
                    
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new GlycanWO(glycan, name), true);
                }
            });
        }
    }
}
