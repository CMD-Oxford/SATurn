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

class CompoundViewer extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ CompoundWO ];

    var theComponent : Dynamic;
    var molEditor : Dynamic;

    var loaded : Bool = false;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            height: '95%',
            autoScroll : true,
            region:'center',
            layout : {
                type: 'hbox',
                align: 'middle',
                pack: 'center'
            },
            items : [
                {
                    xtype : "component",
                    region: "north",
                    autoEl : {
                        tag : "div"

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

        if(getActiveObjectObject() != null){
            render();
        }
    }

    public function render(){
        loaded = true;

        var compound :Compound = getActiveObjectObject();

        if(compound.sdf != null){
            molEditor.importFromString(compound.sdf);
        }

        addModelToOutline(compound, true);
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

        obj.sdf = molEditor.getMolfile();

        cb();
    }
}
