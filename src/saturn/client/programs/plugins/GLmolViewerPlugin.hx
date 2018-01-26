/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.plugins;

class GLmolViewerPlugin extends AbstractPDBRendererPlugin {
    var glmol : Dynamic;

    override public function loadPDB() : Void{
        glmol.loadMoleculeStr(true, theProgram.getActiveObjectObject().contents);
    }

    override public function initialise() : Void{
        var dom = theProgram.getComponent().down('component').getEl().dom;
        dom.width = '600px';
        dom.height = '600px';

        var id = dom.id;
        glmol = untyped __js__('new GLmol(id, true)');
    }

    override public function destroy() : Void{
        var dom =theProgram.getComponent().down('component').getEl().dom;

        var children : Array<Dynamic> = dom.children;

        for(childNode in children){
            dom.removeChild(childNode);
        }
    }

    override public function getName() : String{
        return 'GLmol';
    }
}
