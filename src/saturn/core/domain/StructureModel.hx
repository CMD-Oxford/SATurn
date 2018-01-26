/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

import saturn.core.DNA.GeneticCodes;
import saturn.core.domain.FileProxy;

class StructureModel {
    public var id : Int;
    public var modelId : String;
    public var contents : String;

    public var pdb : FileProxy;
    public var pathToPdb : String;

    public var ribbonOn : Bool;
    public var wireOn : Bool;
    public var labelsOn : Bool;

    public var renderer : String;
    public var icbURL : String;

    public function new(){
        ribbonOn = true;
        wireOn = false;
    }

    public function getContent() : String {
        if(contents != null){
            return contents;
        }
        #if !PYTHON
        else if(pdb != null){
            var array = new js.html.Uint8Array(pdb.content);
            var stringjs :Dynamic = untyped __js__('String');

            var contents = "";
            for(i in 0...array.length){
                contents += String.fromCharCode(array[i]);
            }

            //contents = stringjs.fromCharCode.apply(null, array);

            return contents;
        }
        #end
        else{
            return null;
        }
    }
}
