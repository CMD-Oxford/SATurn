/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import bindings.Ext;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.client.workspace.WebPage;
import saturn.client.workspace.WebPageWorkspaceObject;

class EmptyViewer extends SimpleExtJSProgram{
    var theComponent : Dynamic;

    public function new(){
        super();
    }

    override public function emptyInit() {
		super.emptyInit();

        var self : EmptyViewer  = this;

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            height: '95%',
            autoScroll : true,
            layout : 'fit',
            listeners : { 
                'render' : function() { self.initialiseDOMComponent(); }
            }
        });      
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        setTitle(getObject().getName());
    }
	
	override public function initialiseDOMComponent() {
		super.initialiseDOMComponent();
	}

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }

    override public function getComponent() : Dynamic {
        return theComponent;
    }
}
