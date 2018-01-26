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
import saturn.util.StringUtils;

import saturn.client.workspace.WebPage;
import saturn.client.workspace.WebPageWorkspaceObject;

import saturn.client.workspace.Workspace.WorkspaceObject;

import bindings.Ext;

class WebPageViewer extends SimpleExtJSProgram{
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ WebPageWorkspaceObject ];
	
    var theComponent : Dynamic;
    var internalFrameId : String = 'INTERNAL_FRAME';
	
	var pageUrl : String = '';

    public function new(){
        super();
    }

    override public function emptyInit() {
		super.emptyInit();

        var self : WebPageViewer  = this;

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            height: '95%',
            autoScroll : true,
            layout : 'fit',
            items : [{
                        xtype : "component",
                        itemId : internalFrameId,
                        autoEl : {
                            tag : "iframe"
                        }
                    }],
            listeners : { 
                'render' : function() { self.initialiseDOMComponent(); }
            }
        });      
    }
	
	override public function initialiseDOMComponent() {
		super.initialiseDOMComponent();
	}

    override
    public function onFocus(){
        super.onFocus();

        getApplication().hideMiddleSouthPanel();

        var self : WebPageViewer = this;
        getApplication().getEditMenu().add({
            text : 'Set URL',
            hidden : false,
            handler : function(){
                Ext.Msg.prompt('Set URL', 'Enter URL', function(btn, text){
                    if(btn == 'ok'){
                        self.setURL(text);

                        cast(cast(self.getActiveObject(WebPageWorkspaceObject), WebPageWorkspaceObject).getObject(), WebPage).setURL(text);
                    }
                });
            }
        });
		
		//if (pageUrl != null) {
		//	setURL(pageUrl);
		//}
    }

    override public function setActiveObject(objectId : String) {
		super.setActiveObject(objectId);

        var w0 : WebPageWorkspaceObject = cast(super.getActiveObject(WebPageWorkspaceObject), WebPageWorkspaceObject);
        var webPage : WebPage = cast(w0.getObject(), WebPage);

        var url : String = webPage.getURL();
        if(url == null || url == "" || url == "undefined"){
            var location : js.html.Location = js.Browser.window.location;
            url =  location.protocol+'//'+location.hostname+':'+location.port+'/'+"HoldingPage.html";
        }

        setURL(url);

        setTitle(w0.getName());
	}

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }

    public function setURL(url : String) {
		//var element : Dynamic = theComponent.getComponent(internalFrameId);
		var element : Dynamic = theComponent.items.items[0];
		if(element!=null && url !=null){
			var frame : Dynamic = element.getEl().dom;
			frame.src = url;
		}
		
		
		pageUrl = url;
    }

    override public function getComponent() : Dynamic {
        return theComponent;
    }
}
