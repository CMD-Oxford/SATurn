/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.WONKASession;
import saturn.client.programs.SimpleExtJSProgram;

import saturn.client.workspace.WONKAWO;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import bindings.Ext;

class WONKA extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ WONKAWO ];

    var theComponent : Dynamic;
    var molContainer : Dynamic;

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
                        src:  '/WONKA/',
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

        load();
    }

    public function getIframe(): Dynamic{
        var dom = getComponent().el.dom;
        var frames = dom.getElementsByTagName('iframe');
        var frame = frames[0];

        return frame;
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().hideMiddleSouthPanel();

        getApplication().getToolBar().add({
            html: 'Ligands',
            handler: function(){
                getFrame().contentWindow.show_one('all-ph4','viewer-one','all-ph4');
            },
            iconCls: 'x-btn-blast',
            tooltip: {dismissDelay: 10000, text: 'Ligands'}
        });

        getApplication().getToolBar().add({
            html: 'Residues',
            handler: function(){
                getFrame().contentWindow.show_one('max-res','viewer-one','res-shows','max_shift');
            },
            iconCls: 'x-btn-blast',
            tooltip: {dismissDelay: 10000, text: 'Ligands'}
        });

        getApplication().getToolBar().add({
            html: 'Waters',
            handler: function(){
                getFrame().contentWindow.show_one('key-water','viewer-one','water-shows','key_waters');
            },
            iconCls: 'x-btn-blast',
            tooltip: {dismissDelay: 10000, text: 'Ligands'}
        });

        getApplication().getToolBar().add({
            html: 'Sites',
            handler: function(){
                getFrame().contentWindow.show_one('mol-clusts','viewer-one','clust-shows','mol_clusts');
            },
            iconCls: 'x-btn-blast',
            tooltip: {dismissDelay: 10000, text: 'Ligands'}
        });



        if(molContainer != null){
            attachMolContainerToIframe();
        }
    }

    override
    public function onBlur(){
        super.onBlur();

        if(molContainer != null){
            var container = getApplication().getOutlineTree('DEFAULT').el.dom;

            container.appendChild(molContainer);

            container.childNodes[1].style.display='block';

            getFrame().contentDocument.body.appendChild(molContainer);
        }
    }

    public function attachMolContainerToIframe(){
        var container = getApplication().getOutlineTree('DEFAULT').el.dom;

        container.appendChild(molContainer);

        container.childNodes[1].style.display='None';
    }

    public function attachMolContainerToOutline(){
        var container = getApplication().getOutlineTree('DEFAULT').el.dom;

        container.appendChild(molContainer);

        container.childNodes[1].style.display='None';
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var w0 : WONKAWO = cast(super.getActiveObject(WONKAWO), WONKAWO);
        var obj : WONKASession = cast(w0.getObject(), WONKASession);

        setTitle(w0.getName());

        load();
    }

    public function load(){
        if(getActiveObjectId() != null){
            var w0 : WONKAWO = cast(super.getActiveObject(WONKAWO), WONKAWO);
            var obj : WONKASession = cast(w0.getObject(), WONKASession);

            if(obj != null && obj.src != null){
                getIframe().src = obj.src;
            }
        }

        var configure = null;

        configure = function(){
            var dom = getComponent().el.dom;

            var frames = dom.getElementsByTagName('iframe');
            var frame = frames[0];
            var navbar = frame.contentDocument.getElementsByClassName('navbar')[0];



            if(navbar != null){
                navbar.style.display = 'None';

                frame.contentDocument.body.style.paddingTop = '0px';

                var molContainer = frame.contentDocument.getElementById('mol-container');

                if(molContainer != null){
                    moveComponents();

                    return;
                }
            }
            haxe.Timer.delay(configure, 250);
        };

        configure();
    }

    public function getFrame() : Dynamic{
        var frames = getComponent().el.dom.getElementsByTagName('iframe');
        var frame :Dynamic = frames[0];

        return frame;
    }

    public function moveComponents(){
        var dom = getComponent().el.dom;

        var dwin : Dynamic = js.Browser.window;

        var frame = getFrame();
        frame.contentWindow.app = dwin.app;

        var navbar = frame.contentDocument.getElementsByClassName('navbar')[0];

        molContainer = frame.contentDocument.getElementById('mol-container');

        molContainer.style.overflow = 'auto';
        molContainer.style.height = '100%';
        molContainer.childNodes[15].style=[];

        var aElems :Array<Dynamic> = molContainer.getElementsByTagName('a');

        for(aElem in aElems){
            aElem.style.overflow = '';
            aElem.style.position = '';
            aElem.style.top = '';
            aElem.style.left = '';
            aElem.style.cursor = '';


            var elems : Array<Dynamic> = aElem.getElementsByTagName('img');

            if(elems != null && elems.length > 0){
                var imgElem = elems[0];

                imgElem.setAttribute('onclick', "app.getActiveProgram().getFrame().contentWindow." + imgElem.getAttribute('onclick'));
            }
        }

        var ddoc : Dynamic = js.Browser.document;

        var oldFunc :Dynamic = frame.contentDocument.getElementById;

        frame.contentDocument.getElementById = function(id){
            var oldFuncBind = oldFunc.bind(frame.contentDocument);
            var objs : Array<Dynamic> = oldFuncBind(id);

            if(objs == null || objs.length == 0){
                objs = ddoc.getElementById(id);
            }

            return objs;
        }

        attachMolContainerToIframe();

        var tabPanel :Dynamic = frame.contentDocument.getElementById('first-div');
        tabPanel.style.height='100%';
        tabPanel.getElementsByTagName('div')[0].style.height='';
        tabPanel.childNodes[5].style.height='100%';
        tabPanel.childNodes[5].style.overflow='auto';

        var header1 = frame.contentDocument.getElementsByTagName('h1')[0];
        header1.style.display='None';


        var btGroup = tabPanel.getElementsByTagName('div')[0].childNodes[1].style.display = 'None';

        var ids = ['key-water-div','key-frag-div','mol-clusts-div','key-ring-div','key-water-div','coll-water-div','key-ph4-div','all-ph4-div','oo-ph4-div','oo-frag-div','max-res-div'];

        for(id in ids){
            var elem :Dynamic = frame.contentDocument.getElementById(id);
            var h3 = elem.childNodes[1];

            h3.style.marginTop = '0px';
            h3.style.marginBottom = '0px';
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
                iconCls :'x-btn-wonka',
                text:'WONKA',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new WONKAWO(null, null), true);
                }
            }
        ];
    }
}
