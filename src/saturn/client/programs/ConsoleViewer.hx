/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.workspace.ConsoleWO;
import saturn.client.programs.SimpleExtJSProgram;

import saturn.client.core.ClientCore;

import bindings.Ext;

class ConsoleViewer extends SimpleExtJSProgram  {
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ ConsoleWO ];

    var theComponent : Dynamic;

    var listener : Dynamic;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        theComponent = Ext.create('Ext.Container', {
            width: '100%',
            height: '300',
            autoScroll : false,
            autoEl: { tag: 'div', html: ""	}
        });

        getWorkspace().addListener(this);

        listener = function(data : Dynamic){
            getDomElement().innerHTML = getDomElement().innerHTML + '<br/>' + data.event + '\t' + data.trigger;
        }

        ClientCore.getClientCore().registerListener('global.event', listener);
    }

    public function getDomElement() : js.html.Element{
        return theComponent.getEl().down('div[id*=innerCt]').dom;
    }

    override public function close(){
        ClientCore.getClientCore().removeListener('global.event', listener);
    }

    override public function setTitle(title : String){
        if(theComponent.tab != null){
            theComponent.tab.setText(title);
        }
    }

    override public function getComponent() : Dynamic {
        return theComponent;
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        setTitle(getActiveObjectName());
    }}
