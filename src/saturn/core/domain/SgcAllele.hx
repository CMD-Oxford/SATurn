/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

@:expose
class SgcAllele extends DNA{
    public var alleleId : String;
    public var id : Int;
    public var entryCloneId : Int;
    public var forwardPrimerId : Int;
    public var reversePrimerId : Int;
    public var dnaSeq : String;
    public var proteinSeq : String;
    public var plateWell : String;
    public var plate : SgcAllelePlate;
    public var entryClone : SgcEntryClone;
    public var elnId : String;
    public var status : String;
    public var complex : String;

    public var forwardPrimer : SgcForwardPrimer;
    public var reversePrimer : SgcReversePrimer;

    public var proteinSequenceObj : Protein;

    public function new(){
        super(null);

        setup();
    }

    public function setup(){
        setSequence(dnaSeq);

        sequenceField = 'dnaSeq';

        if(proteinSequenceObj == null){
            proteinSequenceObj = new Protein(null);
        }

        addProtein('Translation', proteinSequenceObj);
    }

    override public function getMoleculeName() : String{
        return alleleId;
    }

    public function loadProtein(cb){
        proteinSequenceObj.setName(alleleId + ' (Protein)');

        proteinSequenceObj.setDNA(this);

        cb(proteinSequenceObj);
    }

    override public function setSequence(sequence : String){
        super.setSequence(sequence);

        dnaSeq = sequence;
    }
}
