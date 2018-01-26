/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.scripts;

import js.Node;

class Run {
    public static var print : Dynamic = Node.console.log;

    public function new() {

    }

    public static function main(){
        if(Node.process.argv.length >= 4){
            var name = Node.process.argv[3];

            var clazzStr = 'saturn.scripts.' + name;

            var clazz = Type.resolveClass(clazzStr);

            if(clazz != null){
                var obj = Type.createInstance(clazz, []);
            }else{
                print(name + ' is not a valid script name\n');
                print('Valid scripts');
                printValidNames();
                Node.process.exit(-1);
            }
        }else{
            print('Usage\tService Configuration\n\tScript Name\n\t');
            print('Valid scripts');
            printValidNames();

            Node.process.exit(-1);
        }
    }

    public static function printValidNames(){
        var classes = CompileTime.getAllClasses("saturn.scripts");
        for(clazz in classes){
            var fqn = Type.getClassName(clazz);

            var parts = fqn.split('.');

            var name = parts[parts.length-1];

            if(name != 'Run' && name != 'BaseScript' && name != 'AsyncStackJob'){
                print('\t' + name);
            }
        }

    }
}
