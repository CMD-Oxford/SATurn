/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.core;

import saturn.app.SaturnServer;
import js.Node;
import bindings.Ext.NodeSocket;
import saturn.server.plugins.socket.core.BaseServerSocketPlugin;

class BaseServerPlugin {
    var saturn : SaturnServer;
    var config : Dynamic;
    var plugins : Array<Dynamic>;

    var debug : Dynamic = Node.require('debug')('saturn:plugin');

    public function new(saturn : SaturnServer, config : Dynamic){
        this.saturn = saturn;

        this.config = config;

        plugins = new Array<Dynamic>();

        processConfig();

        registerPlugins();
    }

    private function processConfig(){

    }

    private function registerPlugins(){
        var clazzName = Type.getClassName(Type.getClass(this));
        if(Reflect.hasField(config, "plugins")){
            var pluginDefs : Array<Dynamic> = Reflect.field(config, "plugins");

            for(pluginDef in pluginDefs){
                var clazzStr = Reflect.field(pluginDef, "clazz");
                var clazz = Type.resolveClass(clazzStr);

                var plugin = Type.createInstance(clazz, [this, pluginDef]);

                debug('CHILD_PLUGIN' + Type.getClassName(clazz));

                plugins.push(plugin);
            }
        }
    }

    public function getSaturnServer() : SaturnServer{
        return saturn;
    }
}