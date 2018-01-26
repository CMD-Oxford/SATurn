/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.plugins;

import bindings.Ext;

class ActiveICMPlugin extends AbstractPDBRendererPlugin {
    var id : String;
    var object : Dynamic;

    public function new(){
        super();
    }

    override public function loadPDB() : Void{
        //theProgram.getActiveObjectObject().contents
        //RunCommands



        var pdbId : String = theProgram.getActiveObjectObject().pdbId;
        var url = '"http://www.rcsb.org/pdb/files/' + pdbId.toUpperCase() + '.pdb"';

        clear();

        object.RunCommands('read pdb '+url);

        display();

        applyConfiguration();
    }

    override public function loadICB() : Void{
        object.RunCommands('read binary "' + theProgram.getActiveObjectObject().icbURL + '"');

        display();
        //applyConfiguration();
    }

    public function clear(){
        object.RunCommands('delete all');
    }

    public function display(){
        object.RunCommands('display');
    }

    public function applyConfiguration(){
        if(theProgram.getActiveObjectObject().ribbonOn){
            ribbonOn();
        }else{
            ribbonOff();
        }

        if(theProgram.getActiveObjectObject().wireOn){
            wireOn();
        }else{
            wireOff();
        }
    }

    override public function ribbonOn() : Void{
        object.RunCommands('display ribbon');
    }

    override public function ribbonOff() : Void{
        object.RunCommands('undisplay ribbon');
    }

    override public function wireOn() : Void{
        object.RunCommands('display wire');
    }

    override public function wireOff() : Void{
        object.RunCommands('undisplay wire');
    }

    override public function initialise() : Void{
        var dom = theProgram.getComponent().down('component').getEl().dom;

        object = js.Browser.document.createElement('object');
        object.setAttribute('type', 'application/x-molsoft-icb');
        object.setAttribute('width', '600px');
        object.setAttribute('height', '600px');

        id = Ext.id();

        object.setAttribute('id', id);

        dom.appendChild(object);
    }

    override public function destroy() : Void{
        var dom =theProgram.getComponent().down('component').getEl().dom;

        var children : Array<Dynamic> = dom.children;

        for(childNode in children){
            dom.removeChild(childNode);
        }
    }

    override public function onFocus() : Void{
        super.onFocus();

        theProgram.reload();

        /*if(object != null){
            if(object.RunCommands){

            }else{
                haxe.Timer.delay(function(){
                    object.RunCommands('display');
                }, 2);
            }
        }*/
    }

    override public function getName() : String{
        return 'ActiveICM';
    }
}
