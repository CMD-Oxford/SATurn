package saturn.client.programs;

import saturn.client.programs.SimpleExtJSProgram;

import saturn.core.<OBJECT_TEMPLATE>;
import saturn.client.workspace.<WORKSPACE_TEMPLATE>;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import bindings.Ext;

class <PROGRAM_TEMPLATE> extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ <WORKSPACE_TEMPLATE> ];

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
                        tag : "div"
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

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Example Button'
        });

        getApplication().getEditMenu().add({
            text : "Click me",
            handler : function(){
                getApplication().showMessage('Menu','You clicked me!');
            }
        });
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var w0 : <WORKSPACE_TEMPLATE> = cast(super.getActiveObject(<WORKSPACE_TEMPLATE>), <WORKSPACE_TEMPLATE>);
        var obj : <OBJECT_TEMPLATE> = cast(w0.getObject(), <OBJECT_TEMPLATE>);

        setTitle(w0.getName());
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
                iconCls :'x-btn-dna',
                text:'<PROGRAM_TEMPLATE>',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new <WORKSPACE_TEMPLATE>(null, null), true);
                }
            }
        ];
    }
}
