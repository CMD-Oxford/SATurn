/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

class SgcRestrictionSite extends DNA{
    public var enzymeName : String;
    public var cutSequence : String;
    public var id : Int;

    public function new(){
        super(null);

        allowStar = true;
    }

    public function setup(){
        setSequence(cutSequence);
    }

    override public function setSequence(sequence : String){
        super.setSequence(sequence);

        cutSequence = sequence;
    }

    override public function getSequence() : String {
        return cutSequence;
    }
}

/*
SGC.RESTRICTION_ENZYME
(
PKEY                            NUMBER(38)    NOT NULL,
RESTRICTION_ENZYME_NAME         VARCHAR2(250 BYTE) NOT NULL,
RESTRICTION_ENZYME_SEQUENCERAW*/