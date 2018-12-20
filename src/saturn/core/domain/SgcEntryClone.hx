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
import saturn.core.DNA.Frame;

class SgcEntryClone extends DNA{
    public var entryCloneId : String;
    public var id : Int;
    public var dnaSeq : String;
    public var target : SgcTarget;
    public var seqSource : String;
    public var sourceId : String;
    public var sequenceConfirmed : String;
    public var elnId : String;
    public var complex : String;

    public var proteinSequenceObj : Protein;

    public function new(){
        super(null);

        setup();
    }

    override public function getMoleculeName() : String{
        return entryCloneId;
    }

    public function setup(){
        setSequence(dnaSeq);

        if(dnaSeq != null && dnaSeq != '' && dnaSeq.length > 2){
            proteinSequenceObj = new Protein(getFrameTranslation(GeneticCodes.STANDARD, Frame.ONE));
        }else{
            proteinSequenceObj = new Protein(null);
        }

        proteinSequenceObj.setDNA(this);

        addProtein('Translation', proteinSequenceObj);
    }

    override public function setSequence(sequence : String){
        super.setSequence(sequence);

        dnaSeq = sequence;

        if(proteinSequenceObj != null && dnaSeq != null && dnaSeq != '' && dnaSeq.length > 2){
            proteinSequenceObj.setSequence(getFrameTranslation(GeneticCodes.STANDARD, Frame.ONE));
        }
    }

    public function loadTranslation(cb){
        proteinSequenceObj.setName(entryCloneId + ' (Protein)');

        cb(proteinSequenceObj);
    }
}