/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

class SgcVector extends DNA{
    public var vectorId : String;
    public var id : Int;
    public var vectorComments : String;
    public var proteaseName : String;
    public var proteaseCutSequence : String;
    public var proteaseProduct : String;
    public var antibiotic : String;
    public var organism : String;
    public var res1Id : Int;
    public var res2Id : Int;

    public var res1 : SgcRestrictionSite;
    public var res2 : SgcRestrictionSite;
    public var addStopCodon = 'no';

    public var requiredForwardExtension : String;
    public var requiredReverseExtension : String;

    public function new(){
        super(null);
    }

    public function setup(){

    }
}