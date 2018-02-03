/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.WorkspaceApplication;
import saturn.client.programs.plugins.AbstractPDBRendererPlugin;
import saturn.client.WorkspaceApplication;
import saturn.core.Protein;
import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.client.core.CommonCore;

import saturn.core.domain.StructureModel;
import saturn.client.workspace.StructureModelWO;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;
import saturn.core.PDBParser;

import bindings.Ext;
import haxe.Json;
import js.html.ArrayBuffer;

class PDBViewer extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ StructureModelWO ];

    var theComponent : Dynamic;

    var renderer : AbstractPDBRendererPlugin;

    var delayedLoad : Bool;
    var ready : Bool;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        delayedLoad = false;
        ready = false;

        theComponent = Ext.create('Ext.Panel', {
            width:'100%',
            height: '100%',
            //autoScroll : true,
            layout : {
                type:'fit',
                //align: 'center',
                //pack: 'center'
            },
            items : [
                {
                    xtype : "component",
                    region: "north",
                    autoEl : {
                        tag : "div",
                        height: '100%',
                        width: '100%'
                    },
                    'flex':1,
                     listeners : {
                        'render' : function() {

                        }
                    },
                    style: {
                        'background-color': 'white'
                    }
                }
            ],
            listeners : {
                'render' : function() {
                    initialiseDOMComponent();
                },
                'resize': function(){resize();}
            },
            bodyCls: 'glmol-container',
            flex: 1
        });
    }

    override public function setPluginsInstalled() : Void{
        /*if(!ready){
            delayedLoad = true;
        }else{
            initialiseRenderer();
        }*/
    }

    public function initialiseRenderer(){
        /*var plugins = getPlugins();

        for(plugin in plugins){
            if(Std.is(plugin, AbstractPDBRendererPlugin)){
                renderer  = cast plugin;
                renderer.initialise();
                break;
            }
        }*/
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

        getApplication().getToolBar().add({
            iconCls :'x-btn-import',
            text:'Import sequences',
            handler: function(){
                var object = getActiveObjectObject();

                var seqObjs = PDBParser.getSequences(object.contents, object.modelId, null);

                var open = true;
                for(seqObj in seqObjs){
                    var name :String = seqObj.getName();

                    name = name.substr(1, name.length -1);

                    getWorkspace()._addObject(new ProteinWorkspaceObject(new Protein(seqObj.getSequence()), name), open, false);
                    open = false;
                }
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Ribbon',
            handler: function(){
                toggleRibbon();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Wire',
            handler: function(){
                toggleWire();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Surface',
            handler: function(){
                toggleSurface();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Labels',
            handler: function(){
                toggleLabels();
            }
        });

        getWorkspace().reloadWorkspace();

        getApplication().enableProgramSearchField(true);

        getApplication().setProgramSearchFieldEmptyText('Enter PDB ID ');

        getApplication().hideMiddleSouthPanel();

        getApplication().installOutlineTree('DEFAULT', true, false, 'WorkspaceObject', 'GRID');

        var options = new Array<Dynamic>();
        var pluginToName = new Map<String, AbstractPDBRendererPlugin>();

        for(plugin in plugins){
            if(Std.is(plugin, AbstractPDBRendererPlugin)){
                var renderer : AbstractPDBRendererPlugin = cast plugin;
                var name = renderer.getName();
                options.unshift({name:name});
                pluginToName.set(name, renderer);
            }
        }

        var myStore = Ext.create('Ext.data.Store',{
            fields:['name'],
            data:options
        });

        getApplication().getToolBar().add({
            xtype: 'combo',
           // data: options,
            store: myStore,
            displayField: 'name',
            valueField: 'name',
            listeners: {
                change: function(This, value){
                    switchRenderer(pluginToName.get(value));
                }
            },
            value: options[0].name
        });
    }

    public function switchRenderer(newRenderer : AbstractPDBRendererPlugin){
        getActiveObjectObject().renderer = Type.getClassName(Type.getClass(newRenderer));

        if(renderer != null){
            renderer.destroy();
        }

        newRenderer.initialise();

        renderer = newRenderer;

        reload();
    }

    public function toggleRibbon(){
        if(getActiveObjectObject().ribbonOn){
            getActiveObjectObject().ribbonOn = false;
            ribbonOff();
        }else{
            getActiveObjectObject().ribbonOn = true;

            ribbonOn();
        }
    }

    public function ribbonOn(){
        renderer.ribbonOn();
    }

    public function ribbonOff(){
        renderer.ribbonOff();
    }

    public function toggleLabels(){
        if(getActiveObjectObject().labelsOn){
            getActiveObjectObject().labelsOn = false;

            labelsOff();
        }else{
            getActiveObjectObject().labelsOn = true;

            labelsOn();
        }
    }

    public function labelsOn(){
        renderer.labelsOn();
    }

    public function labelsOff(){
        renderer.labelsOff();
    }

    public function toggleSurface(){
        if(getActiveObjectObject().surfaceOn){
            getActiveObjectObject().surfaceOn = false;
            surfaceOff();
        }else{
            getActiveObjectObject().surfaceOn = true;

            surfaceOn();
        }
    }

    public function surfaceOn(){
        renderer.surfaceOn();
    }

    public function surfaceOff(){
        renderer.surfaceOff();
    }

    public function toggleWire(){
        if(getActiveObjectObject().wireOn){
            getActiveObjectObject().wireOn = false;
            wireOff();
        }else{
            getActiveObjectObject().wireOn = true;

            wireOn();
        }
    }

    public function wireOn(){
        renderer.wireOn();
    }

    public function wireOff(){
        renderer.wireOff();
    }

    override public function search(text : String) : Void{
        if(text.length >= 4){
            if(getActiveObjectObject().modelId != text){
                loadPdbFromId(text);
                getWorkspace().renameWorkspaceObject(getActiveObjectId(), text);
            }
        }
    }

    public function loadPdbFromId(modelId : String){
        getActiveObjectObject().modelId = modelId;

        // Check what the user typed against the format for model IDs
        if(getProvider().getModel(StructureModel).isValidId(modelId)){
            getProvider().getById(modelId, StructureModel, function(obj : StructureModel, err : String){
                if(err != null){
                    getApplication().showMessage('','Unable to retrieve model');
                }else{
                    getProvider().activate([obj], 2, function(err : String){
                        if(err != null){
                            getApplication().showMessage('','Unable to retrieve model');
                        }else{
                            var content : Dynamic = obj.getContent();

                            setPdbString(content);
                            reload();
                        }
                    });
                }
            });
        }else{
            BioinformaticsServicesClient.getClient().sendPDBRequest(modelId, function(response, error){
                if(error == null){
                    setPdbString(response.json.pdb);
                    reload();
                }else{
                    getApplication().showMessage('Retrieval failure', 'Unable to retrieve PDB for ' + modelId);
                }
            });
        }
    }

    public function setPdbString(contents : String){
        getActiveObjectObject().contents = contents;
    }

    public function loadPdb(){
        renderer.loadPDB();
    }

    public function loadICB(){
        renderer.loadICB();
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        setTitle(getActiveObjectName());

        if(getActiveObjectObject().renderer == null){
            for(plugin in plugins){
                if(Std.is(plugin, AbstractPDBRendererPlugin)){
                    getActiveObjectObject().renderer = Type.getClassName(Type.getClass(plugin));
                }
            }
        }

        if(getActiveObjectObject().modelId != null || getActiveObjectObject().contents != null || getActiveObjectObject().icbURL != null){
            reload();
        }
    }

    public function configureRenderer(){
        var rendererClazz = getActiveObjectObject().renderer;

        var load = false;

        if(renderer == null){
            load = true;
        }else{
            var currentRendererClazz = Type.getClassName(Type.getClass(renderer));
            if(rendererClazz != currentRendererClazz){
                load = true;
            }
        }

        if(load){
            for(plugin in plugins){
                if(Std.is(plugin, Type.resolveClass(rendererClazz))){
                    if(renderer != null){
                        renderer.destroy();
                    }

                    var newRenderer : AbstractPDBRendererPlugin = cast plugin;

                    newRenderer.initialise();

                    theComponent.updateLayout();

                    renderer = newRenderer;

                    break;
                }
            }
        }
    }

    public function resize(){
        if(renderer != null){
            renderer.resize();
        }
    }

    public function getWidth(){
        return getComponent().getEl().dom.offsetWidth;
    }

    public function getHeight(){
        return getComponent().getEl().dom.offsetHeight;
    }

    public function reload(){
        if(getActiveObjectId() != null){
            configureRenderer();

            var w0 : StructureModelWO = cast(super.getActiveObject(StructureModelWO), StructureModelWO);
            var obj : StructureModel = cast(w0.getObject(), StructureModel);

            addModelToOutline(obj, true);

            if(obj.contents != null){
                loadPdb();
            }else if(obj.modelId != null){
                loadPdbFromId(obj.modelId);
            }else if(obj.icbURL != null){
                loadICB();
            }
        }
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
                iconCls :'x-btn-structure',
                html:'PDB<br/>Viewer',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new StructureModelWO(null, null), true);
                },
                tooltip: {dismissDelay: 10000, text: 'View PDB structures'}
            }
        ];
    }

    public static function parseFile(file : Dynamic, ?cb=null, ?asNewOpenProgram : Bool = true){
        CommonCore.getFileAsText(file, function(contents){
            var fileName : String = file.name;

            var extension = CommonCore.getFileExtension(file.name);

            if (extension == 'pdb') {
                var pdbCode : String = PDBParser.extractPDBID(fileName);

                var obj = new StructureModel();
                obj.modelId = pdbCode;
                obj.contents = contents;

                var wo = new StructureModelWO(obj, pdbCode);

                WorkspaceApplication.getApplication().getWorkspace()._addObject(wo, true, true);
            }else if(extension == 'icb'){
                CommonCore.getFileAsArrayBuffer(file, function(content : ArrayBuffer){
                    var base64 = CommonCore.convertArrayBufferToBase64(content);

                    BioinformaticsServicesClient.getClient().upload(base64, 'icb', function(data : Dynamic, error : String){
                        if(error != null){
                            WorkspaceApplication.getApplication().showMessage('Unable to show ICB', error);
                        }else{

                            var obj = new StructureModel();
                            obj.icbURL = CommonCore.makeFullyQualified(data.json.url);

                            var wo = new StructureModelWO(obj, fileName);

                            WorkspaceApplication.getApplication().getWorkspace()._addObject(wo, true, true);
                        }
                    });
                });
            }else {
                Ext.Msg.alert("", "Unknown file format");
                return;
            }
        });
    }
}
