/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.core.molecule.Molecule;
import saturn.core.molecule.Molecule.MoleculeFloatAttribute;
import saturn.core.molecule.MoleculeSet;


class StandardMoleculeSet extends MoleculeSet{
    public function new(){
        super();

        var mMap = [
                        {'NAME' : 'A','MW':71.0788},
                        {'NAME' : 'R','MW':156.1875},
                        {'NAME' : 'N','MW':114.1038},
                        {'NAME' : 'D','MW':115.0886},
                        {'NAME' : 'C','MW':103.1448},
                        {'NAME' : 'E','MW':129.1155},
                        {'NAME' : 'Q','MW':128.1308},
                        {'NAME' : 'G','MW':57.052},
                        {'NAME' : 'H','MW':137.1412},
                        {'NAME' : 'I','MW':113.1595},
                        {'NAME' : 'L','MW':113.1595},
                        {'NAME' : 'K','MW':128.1742},
                        {'NAME' : 'M','MW':131.1986},
                        {'NAME' : 'F','MW':147.1766},
                        {'NAME' : 'P','MW':97.1167},
                        {'NAME' : 'S','MW':87.0782},
                        {'NAME' : 'T','MW':101.1051},
                        {'NAME' : 'W','MW':186.2133},
                        {'NAME' : 'Y','MW':163.176},
                        {'NAME' : 'V','MW':99.1326}
        ];

        for(mDef in mMap){
            var m = new Molecule(mDef.NAME);
            m.setFloatAttribute(MoleculeFloatAttribute.MW_CONDESATION, mDef.MW);
            m.setStringAttribute(MoleculeStringAttribute.NAME,mDef.NAME);

            this.setMolecule(mDef.NAME,m);
        }

        mMap = [{'NAME' : 'H2O','MW':18.02}];

        for(mDef in mMap){
            var m = new Molecule(mDef.NAME);
            m.setFloatAttribute(MoleculeFloatAttribute.MW, mDef.MW);
            m.setStringAttribute(MoleculeStringAttribute.NAME,mDef.NAME);

            this.setMolecule(mDef.NAME,m);
        }
    }
}