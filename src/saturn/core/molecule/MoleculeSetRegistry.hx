/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.molecule;

import saturn.core.StandardMoleculeSet;

class MoleculeSetRegistry {
    var moleculeSets : Map<String, MoleculeSet>;

    static var defaultRegistry = new MoleculeSetRegistry();

    public function new(){
        moleculeSets = new Map<String,MoleculeSet>();

        register(MoleculeSets.STANDARD, new StandardMoleculeSet());
    }

    public function register(setType : MoleculeSets, set : MoleculeSet){
        registerSet(Std.string(setType), set);
    }

    public function get(setType : MoleculeSets) : MoleculeSet{
        return getSet(Std.string(setType));
    }

    public function registerSet(name : String, set :MoleculeSet){
        moleculeSets.set(name, set);
    }

    public function getSet(name : String) : MoleculeSet{
        return moleculeSets.get(name);
    }

    public static function getStandardMoleculeSet() : MoleculeSet{
        return defaultRegistry.get(MoleculeSets.STANDARD);
    }
}

enum MoleculeSets {
    STANDARD;
}