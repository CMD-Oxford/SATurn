/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.plugins;

class ThreeDMolViewer extends AbstractPDBRendererPlugin {
    var viewer : Dynamic;
    var ready : Bool = false;
    var delayedLoad : Bool = false;
    var waiting : Bool = false;

    override public function loadPDB() : Void{
        if(ready){
            viewer.clear();
            viewer.addModel(theProgram.getActiveObjectObject().contents, "pdb");
            viewer.zoomTo();
            viewer.render();

            viewer.addSurface(untyped __js__('$3Dmol.SurfaceType.VDW'),{opacity:0.7, color:'white'},{}, {});
            viewer.setStyle({}, {cartoon:{color:'spectrum'}});
            viewer.setBackgroundColor('white');

            theProgram.getActiveObjectObject().surfaceOn = true;
            theProgram.getActiveObjectObject().ribbonOn = true;
        }else{
            delayedLoad = true;
        }
    }

    override public function labelsOn() : Void {
        if(viewer != null){
            viewer.addResLabels({});
            viewer.render();
        }
    }

    override public function labelsOff() : Void {
        if(viewer != null){
            viewer.removeAllLabels({});
            viewer.render();
        }
    }

    override public function surfaceOn(){
        if(viewer != null){
            viewer.addSurface(untyped __js__('$3Dmol.SurfaceType.VDW'),{opacity:0.7, color:'white'},{}, {});
        }
    }

    override public function surfaceOff(){
        if(viewer != null){
            viewer.removeAllSurfaces();
        }
    }

    override public function ribbonOn() : Void{
        if(viewer != null){
            viewer.setStyle({}, {cartoon:{color:'spectrum'}});
            viewer.render();
        }
    }

    override public function ribbonOff() : Void{
        if(viewer != null){
            viewer.setStyle({}, {line:{}});
            viewer.render();
        }
    }

    override public function initialise() : Void{
        var dom = theProgram.getComponent().down('component').getEl().dom;

        dom.style.height = theProgram.getHeight();
        dom.style.width = theProgram.getWidth();

        var run = null;

        run = function(){
            var dom = theProgram.getComponent().down('component').getEl().dom;

            var height : Int = dom.offsetHeight;

            if(height > 1){
                var id = dom.id;

                var config = untyped __js__('{defaultcolors: $3Dmol.rasmolElementColors }');
                viewer = untyped __js__('$3Dmol.createViewer(id, config)');

                ready = true;

                if(delayedLoad){
                    loadPDB();

                    delayedLoad = false;
                }
            }else{
                haxe.Timer.delay(run, 1000);
            }
        };

        run();
    }

    override public function resize() : Void {
        if(waiting){
            return;
        }else{
            waiting = true;

            haxe.Timer.delay(function(){
                try{
                    var dom = theProgram.getComponent().down('component').getEl().dom;

                    dom.style.height = theProgram.getHeight();
                    dom.style.width = theProgram.getWidth();

                    viewer.resize();
                }catch(exception : Dynamic){
                    //ignore
                }

                waiting = false;
            }, 500);
        }
    }

    override public function destroy() : Void{
        var dom =theProgram.getComponent().down('component').getEl().dom;

        var children : Array<Dynamic> = dom.children;

        for(childNode in children){
            dom.removeChild(childNode);
        }
    }

    override public function getName() : String{
        return '3DMol';
    }
}
