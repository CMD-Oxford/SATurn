/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.plugins;

import saturn.client.ProgramPlugin.BaseProgramPlugin;

class AbstractPDBRendererPlugin extends BaseProgramPlugin<PDBViewer> {
    public function new(){
        super();
    }

    public function surfaceOn(){

    }

    public function surfaceOff(){

    }

    public function resize() : Void{

    }

    public function loadPDB() : Void{

    }

    public function loadICB() : Void{

    }

    public function initialise(): Void{

    }

    public function ribbonOn() : Void{

    }

    public function ribbonOff() : Void{

    }

    public function wireOn() : Void{

    }

    public function wireOff() : Void{

    }

    public function labelsOn() : Void {

    }

    public function labelsOff() : Void {

    }

    public function getName() : String{
        return 'PDB Renderer';
    }
}
