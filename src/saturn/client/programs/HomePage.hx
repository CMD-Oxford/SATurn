/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.blocks.BaseTable;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.client.core.CommonCore;

import saturn.core.Home;
import saturn.client.workspace.HomeWO;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import haxe.Unserializer;
import haxe.Serializer;

import bindings.Ext;

class HomePage extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ HomeWO ];

    var theComponent : Dynamic;
    var theToolBar : Dynamic;

    var demoNameToUrl : Map<String, String>;

    var demos : Map<String,Demo>;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        demoNameToUrl = new Map<String,String>();
        demoNameToUrl.set('ABIExample1', '/static/demo/ABIExample.sat');

        demos = new Map<String,Demo>();

        addDemo({name: 'ABI (96 traces organised into folders - 20MB download slow on VPN)', url: '/static/demo/ABIExample.sat', icon: 'x-btn-trace'});
        addDemo({name: 'GYG2A progress (construct/target summary)', url: '/static/demo/GYG2A_Progress.sat', icon: 'x-btn-gridvar'});
        addDemo({name: 'KCNK1A construct alignment (example loads 53 sequences)', url: '/static/demo/KCNK1A-Protein-ALN.sat', icon: 'x-btn-aln'});
        addDemo({name: 'Glycosyltransferase tree (examples loads 200 sequences)', url: '/static/demo/GTTree.sat', icon: 'x-btn-tree'});
        addDemo({name: 'JMJD2DA constructs (loads 87 DNA and Protein sequences)', url: '/static/demo/JMJD2DA-Constructs.sat', icon: 'x-btn-structure'});
        addDemo({name: 'OG-Mut plate examples (loads 4 plates)', url: '/static/demo/OG-Mut-cp.sat', icon: 'x-btn-conical-dna'});
        addDemo({name: 'Coding examples', url: '/static/demo/coding.sat', icon: 'x-btn-conical-dna'});

        theToolBar = Ext.create('Ext.toolbar.Toolbar',
            {
                style: {
                    'background-color': 'white'
                },
                layout: {
                    type: 'vbox'
                },
                height: '100%'
            }
        );

        theComponent = Ext.create('Ext.panel.Panel', {
            height: '100%',
            width: '100%',
            listeners : {
                'render' : function() { initialiseDOMComponent(); },
            }
        });


        theComponent.add(theToolBar);
    }

    public function addDemo(demo : Demo){
        demos.set(demo.name, demo);
    }

    public function loadDemo(name : String){
        js.Browser.window.console.log('Loading: ' + name);
        if(demos.exists(name)){
            var demo = demos.get(name);
            var url = demo.url;

            CommonCore.getContent(url, function(content){
                getWorkspace()._openWorkspace(Unserializer.run(content));
            });
        }
    }

    override public function initialiseDOMComponent() {
        super.initialiseDOMComponent();

        buildDemoButtons();
    }

    private function buildDemoButtons(){
        for(name in demos.keys()){
            var demo = demos.get(name);

            js.Browser.window.console.log('Adding' + demo);
            theToolBar.add({
                iconCls :demo.icon,
                text: name,
                cls: 'quickLaunchButton',
                handler: function(){
                    loadDemo(name);
                },
                style:{
                    'margin-left':'auto', 'margin-right':0
                },
                width: '100%'
            });
        }
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().hideMiddleSouthPanel();
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var w0 : HomeWO = cast(super.getActiveObject(HomeWO), HomeWO);
        var obj : Home = cast(w0.getObject(), Home);

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
                iconCls :'x-btn-playground',
                text:'Examples',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new HomeWO(null, null), true);
                },
                tooltip: {dismissDelay: 10000, text: 'Play around with pre-saved sessions with example data'}
            }
        ];
    }
}

typedef Demo = {
    var name: String;
    var url: String;
    var icon: String;
}
