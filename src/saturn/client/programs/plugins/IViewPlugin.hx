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

class IViewPlugin extends AbstractPDBRendererPlugin {
    var iview : Dynamic;

    public function new(){
        super();
    }

    override public function loadPDB() : Void{
        iview.loadPDB(theProgram.getActiveObjectObject().contents);
    }

    override public function initialise() : Void{
        var dom = theProgram.getComponent().down('component').getEl().dom;
        //dom.width = '600px';
        //dom.height = '600px';

        js.Browser.window.console.log('w:' + dom.width);

        var canvas : js.html.CanvasElement = cast js.Browser.document.createElement('canvas');
        canvas.width = 600;
        canvas.height = 600;
        canvas.id = Ext.id();

        dom.appendChild(canvas);

        var id = dom.id;
        iview = untyped __js__('new iview(canvas.id)');

        iview.options.secondaryStructure = 'ribbon';
        iview.options.surface = 'Van der Waals surface';
    }

    override public function destroy() : Void{
        var dom =theProgram.getComponent().down('component').getEl().dom;

        var children : Array<Dynamic> = dom.children;

        for(childNode in children){
            dom.removeChild(childNode);
        }
    }

    override public function getName() : String{
        return 'IView';
    }

    public static function loadResources(){
        var head = js.Browser.document.head;

        var scripts = [
            'js/iview/three.min.js',
            'js/iview/AnaglyphEffect.js',
            'js/iview/ParallaxBarrierEffect.js',
            'js/iview/OculusRiftEffect.js',
            'js/iview/StereoEffect.js',
            'js/iview/iview.js',
            'js/iview/surface.min.js'
        ];

        for(script in scripts){
            var scriptElem = js.Browser.document.createScriptElement();

            scriptElem.setAttribute('src', script);
            scriptElem.setAttribute('type', 'text/javascript');

            head.appendChild(scriptElem);
        }
    }
}
