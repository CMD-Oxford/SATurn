/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.SimpleExtJSProgram;

import saturn.core.Glycan;
import saturn.client.workspace.GlycanWO;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import bindings.Ext;

class GlycanBuilder extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ GlycanWO ];

    var theComponent : Dynamic;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

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
                        src : "http://localhost:8090/static/GlycanBuilder.html",
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
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().getEditMenu().add({
            text : "Click me",
            handler : function(){
                getApplication().showMessage('Menu','You clicked me!');
            }
        });

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
        var load = null;

        load = function(){
            if(!canvasLoaded()){
                haxe.Timer.delay(function(){
                    load();
                },1000);
            }else{
                js.Browser.window.console.log('Loading glycans');
                runCanvasCommand('import~'+contentType + '~' + content, function(res){

                });
            }
        };

        load();
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
}
