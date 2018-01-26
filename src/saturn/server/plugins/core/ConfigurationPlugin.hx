/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.core;
import saturn.core.Util;
import js.Node.NodeChildProcess;
import bindings.NodeTemp;

class ConfigurationPlugin {
    public static function getConfiguration(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void, hookConfig : Map<String, Dynamic>){
        Util.debug('Returning configuration');

        if(hookConfig == null){
            cb(null, 'Hook configuration is missing');
        }else{
            if(Reflect.hasField(hookConfig, 'config')){
                cb(Reflect.field(hookConfig, 'config'), null);
            }else{
                cb(null, 'ConfigurationPlugin configuration block is missing config attribute from JSON');
            }
        }
    }
}
