/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.Util;
import saturn.client.WorkspaceApplication;
import saturn.client.workspace.Workspace;
import saturn.client.programs.SimpleExtJSProgram;

//TODO: Depreciated WO
import saturn.core.domain.TextFile;

import saturn.client.workspace.Workspace.WorkspaceObject;

import bindings.Ext;

class TextEditor extends SimpleExtJSProgram{
    var theComponent : Dynamic;
    var editor : Dynamic;

    var autoRunCBX : Dynamic;
    var saveAsFileName : String;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            //height: '95%',
            autoScroll : true,
            layout : 'border',
            region:'center',
            items : [
                {
                    xtype : "component",
                    region: "north",
                    autoEl : {
                        tag : "div",
                        itemid: "editor",
                        style: {
                            width: '100%',
                            height: '100%',
                            position: 'relative',
                            top: 0,
                            left:0,
                            overflow: 'auto'
                        }
                    }
                }
            ],
            listeners : {
                'render' : function() {
                    initialiseDOMComponent();
                },
                'resize': function(){
                    editor.resize();
                }
            }
        });
    }

    override public function initialiseDOMComponent() {
        super.initialiseDOMComponent();

        installEditorComponent();
    }

    public function installEditorComponent(){
        // trigger extension
        var dWin : Dynamic = js.Browser.window;

        var ace = dWin.ace;
        ace.require("ace/ext/language_tools");

        var dom = getEditorComponent();

        editor = ace.edit(dom.id);

        editor.session.setMode("ace/mode/javascript");
        editor.setTheme("ace/theme/tomorrow");
        editor.setOptions({
            enableBasicAutocompletion: true,
            enableSnippets: true,
            enableLiveAutocompletion: false
        });

        editor.on('change', function(){
            getObject().value = editor.getSession().getValue();
        });
    }

    public function getEditorComponent(){
        return theComponent.getEl().down('div[itemid*=editor]').dom;
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Run',
            handler: function(){
                runCodeFromEditor();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Run Selected',
            handler: function(){
                runSelectedCode();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'API',
            handler: function(){
                getApplication().openLocalURL('static/pages/index.html');
            }
        });

        var obj = getActiveObjectObject();

        autoRunCBX = getApplication().getToolBar().add({
            xtype: 'checkbox',
            boxLabel: 'auto-run',
            inputValue: '1',
            checked: obj != null && obj.autoRun ? true : false,
            handler: function(){
                var This = untyped __js__('this');

                getActiveObjectObject().autoRun = This.getValue();
            },
            listeners: {
                'afterrender': function(c){
                   Ext.QuickTips.register({dismissDelay: 10000, target: c.getEl(), text: 'Auto-run code when loading session<br/>Useful if you wish to extend classes or auto-load datasets dynamically'});
                }
            }
        });

        if(saturn.core.Util.isHostEnvironmentAvailable()){
            getApplication().getToolBar().add({
                iconCls :'x-btn-open',
                text:'Open',
                handler: function(){
                    Util.openFileAsDialog(function(err, fileName, contents){

                        setText(contents);
                        saveAsFileName = fileName;
                    });
                }
            });

            getApplication().getToolBar().add({
                iconCls :'x-btn-saveas',
                text:'Save As',
                handler: function(){
                    Util.saveFileAsDialog(getText(), function(err : String, fileName : String){
                        saveAsFileName = fileName;
                    });
                }
            });

            getApplication().getToolBar().add({
                iconCls :'x-btn-save',
                text:'Save',
                handler: function(){
                    if(saveAsFileName != null){
                        Util.saveFile(saveAsFileName, getText(), function(err){

                        });
                    }else{
                        Util.saveFileAsDialog(getText(), function(err : String, fileName : String){
                            saveAsFileName = fileName;
                        });
                    }
                }
            });
        }
    }

    public function runCodeFromEditor(){
        var value = editor.getSession().getValue();

        TextEditor.runCode(value);
    }

    public function runSelectedCode(){
        var value = editor.getSelectedText();

        TextEditor.runCode(value);
    }

    override public function updateActions(){
        super.updateActions();

        var obj = getActiveObjectObject();

        if(obj != null){
            if(obj.autoRun){
                autoRunCBX.setValue(true);
            }else{
                autoRunCBX.setValue(false);
            }
        }
    }

    public static function runCode(code : String){
        var app = WorkspaceApplication.getApplication();
        app.clearPrintBuffer();
        app.setInformationPanelText(app.getPrintBufferContent(), true);

        js.Lib.eval(code + '\nflush();');
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        setTitle(getObjectName());

        editor.getSession().setValue(getObject().value);

        setText(getObject().value);
    }

    public function setText(text : String){
        editor.getSession().setValue(text);
    }

    public function getText() : String{
        return editor.getSession().getValue();
    }

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }


    override public function getComponent() : Dynamic {
        return theComponent;
    }

    override public function saveObject(cb : String->Void){
        var entity = getEntity();

        entity.setText(getText());

        super.saveObject(cb);
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-copy',
                text:'Editor',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new TextFile(), true);
                }
            }
        ];
    }
}
