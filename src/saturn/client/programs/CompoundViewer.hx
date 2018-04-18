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

import saturn.core.domain.Compound;
import saturn.client.workspace.CompoundWO;

import saturn.client.workspace.Workspace.WorkspaceObject;

import bindings.Ext;
import saturn.client.core.CommonCore;

class CompoundViewer extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ CompoundWO ];

    var theComponent : Dynamic;
    var molEditor : Dynamic;

    var editor : CompoundEditor;

    var loaded : Bool = false;

    var up = false;
    var lastSmilesImport = null;

    public function new(editor : CompoundEditor){
        if(editor == null){
            this.editor = CompoundEditor.Ketcher;
        }else{
            this.editor = editor;
        }

        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        var tagType = null;

        if(CompoundEditor.Molsoft == this.editor){
            tagType = 'div';
        }else if(CompoundEditor.Ketcher == this.editor){
            tagType = 'iframe';
        }

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            height: '95%',
            autoScroll : true,
            region:'center',
            /*layout : {
                type: 'hbox',
                align: 'middle',
                pack: 'center'
            },*/
            items : [
                {
                    xtype : "component",
                    region: "north",
                    autoEl : {
                        tag : tagType

                    },
                    listeners : {
                        'afterrender': function(){
                            installEditor();
                        }
                    },
                    flex:1
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

    public function installEditor(){
        var dom :js.html.Element = getComponent().down('component').getEl().dom;

        var id = dom.id;

        if(editor == CompoundEditor.Molsoft){
            molEditor = untyped __js__('new MolEdit.ChemicalView("",id, 600, 400 )');

            var applyStyle = null;

            applyStyle = function(){
                var tableElems : Dynamic = dom.getElementsByTagName('table');

                if(tableElems != null && tableElems.length > 0){
                    tableElems[0].style.margin = '0 auto';
                }else{
                    haxe.Timer.delay(applyStyle, 1000);
                }
            };

            applyStyle();

            up = true;

            if(getObject() != null){
                render();
            }
        }else if(editor == CompoundEditor.Ketcher){
            var iframe :Dynamic = dom;

            //iframe.setAttribute('id', 'ifketcher');
            iframe.setAttribute('src', 'js/ketcher/ketcher.html');
            iframe.setAttribute('width', '100%');
            iframe.setAttribute('height', '100%');
            iframe.style.width = '100%';
            iframe.style.height = '100%';
            iframe.style.position = 'absolute';
            iframe.style.border = 'none';

            var waitForLoad = null;

            waitForLoad = function(){
                var ui = null;
                if (untyped __js__("'contentDocument' in iframe")){
                    molEditor = iframe.contentWindow.ketcher;
                    ui = iframe.contentWindow.ui;
                }else{
                    var d_document :Dynamic = js.Browser.document;
                    molEditor = iframe.window.ketcher;
                    ui = iframe.window.ui;
                }

                if(ui != null && ui.initialized == true){
                    up = true;

                    if(getObject() != null){
                        haxe.Timer.delay(render, 100);
                        //render();
                    }
                }else{
                    haxe.Timer.delay(waitForLoad, 100);
                }
            };

            waitForLoad();
        }


    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().enableProgramSearchField(true);

        getApplication().hideMiddleSouthPanel();

        getApplication().installOutlineTree('MODELS',true, false, 'WorkspaceObject', 'GRID');

        if(getActiveObjectId() != null){
            var compound :Compound = getActiveObjectObject();

            addModelToOutline(compound, true);

            if(!loaded){
                render();
                loaded = true;
            }
        }
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var w0 : CompoundWO = cast(super.getActiveObject(CompoundWO), CompoundWO);
        var obj : Compound = cast(w0.getObject(), Compound);

        setTitle(w0.getName());

        if(getActiveObjectObject() != null && up){
            render();
        }
    }

    public function render(){
        loaded = true;

        var compound :Compound = getActiveObjectObject();

        if(compound.sdf != null){
            setCompoundInEditor(compound.sdf);
        }

        addModelToOutline(compound, true);
    }

    public function setCompoundInEditor(molBlock : String){
        if(this.editor == CompoundEditor.Molsoft){
            molEditor.importFromString(molBlock);
        }else if(this.editor == CompoundEditor.Ketcher){
            molEditor.setMolecule(molBlock);
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
                iconCls :'x-btn-compound',
                text:'CompoundViewer',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new CompoundWO(null, null), true);
                }
            }
        ];
    }

    override public function saveWait(cb){
        var obj = getActiveObjectObject();

        obj.sdf = getMolBlockFromEditor();

        cb();
    }

    public function getMolBlockFromEditor(){
        if(this.editor == CompoundEditor.Molsoft){
            return  molEditor.getMolfile();
        }else if(this.editor == CompoundEditor.Ketcher){
            return molEditor.getMolfile();
        }else{
            return null;
        }
    }

    override public function openFile(file : Dynamic, asNew : Bool, ? asNewOpenProgram : Bool = true) : Void{
        parseFile(file, function(contents){

        },asNewOpenProgram);
    }

    public static function parseFile(file : Dynamic, ?cb=null, ?asNewOpenProgram : Bool = true){
        var extension = CommonCore.getFileExtension(file.name);
        if(extension == 'sdf'){
            CommonCore.getFileAsText(file, function(contents){
                if(contents != null){
                    var molBlock = '';
                    var rdkit = untyped __js__('RDKit');

                    var lines = contents.split('\n');
                    var endOfMol = '$' + '$' + '$' + '$';

                    var auto_open = true;

                    for(line in lines){
                        molBlock += line + '\n';
                        if(line.indexOf(endOfMol) >= 0){
                            var compound = new Compound();
                            compound.sdf = molBlock;

                            var name = 'Unknown';

                            var mol = rdkit.Molecule.MolBlockToMol(compound.sdf);

                            var molLines = compound.sdf.split('\n');
                            var property_reg  = ~/>\s+<(.+)>/;
                            var property = null;

                            for(molLine in molLines){
                                if(property != null){
                                    mol.setProp(property, molLine);

                                    //Hard-coded
                                    if(property == 'CompoundID' || property == 'ID' || property == 'SupplierID'){
                                        name = molLine;
                                    }

                                    property = null;
                                }else if(property_reg.match(molLine)){
                                    property = property_reg.matched(1);
                                }
                            }

                            compound.smiles = mol.toSmiles();

                            WorkspaceApplication.getApplication().getWorkspace().addObject(new CompoundWO(compound, name), auto_open);

                            auto_open = false;

                            molBlock = '';
                        }
                    }
                }
            });
        }
    }

    override public function search(str : String) : Void{
        super.search(str);

        if(str != null && str != '' && lastSmilesImport != str){
            lastSmilesImport = str;
            var rdkit = untyped __js__('RDKit');

            var mol = rdkit.Molecule.fromSmiles(str);

            if(mol != null){
                mol.compute2DCoords();
                var molBlock = mol.toMolfile();

                getObject().sdf = molBlock;

                setCompoundInEditor(molBlock);
            }
        }
    }

    override public function saveObject(cb : String->Void){
        var molBlock = getMolBlockFromEditor();
        var compound = getObject();
        compound.sdf = molBlock;

        var rdkit = untyped __js__('RDKit');
        var mol = rdkit.Molecule.MolBlockToMol(compound.sdf);
        compound.smiles = mol.toSmiles();

        super.saveObject(cb);
    }
}

enum CompoundEditor{
    Molsoft;
    Ketcher;
}
