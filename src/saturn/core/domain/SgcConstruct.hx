/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

import saturn.client.core.CommonCore;

class SgcConstruct extends DNA{
    public var constructId : String;
    public var id : Int;
    public var proteinSeq : String;
    public var proteinSeqNoTag : String;
    public var dnaSeq : String;
    public var docId : String;
    public var vectorId : Int;
    public var alleleId : Int;
    public var constructStart : String;
    public var constructStop : String;

    public var vector : SgcVector;
    public var person : String;
    public var status : String;
    public var allele : SgcAllele;
    public var wellId : String;
    public var constructPlate : SgcConstructPlate;
    public var res1 : SgcRestrictionSite;
    public var res2 : SgcRestrictionSite;
    public var expectedMassNoTag : Float;
    public var expectedMass : Float;
    public var elnId : String;
    public var constructComments : String;

    public var proteinSequenceObj : Protein;
    public var proteinSequenceNoTagObj : Protein;

    public function new(){
        super(null);

        setup();
    }

    public function setup(){
        setSequence(dnaSeq);

        sequenceField = 'dnaSeq';

        addProtein('Translation', proteinSequenceObj);

        addProtein('Translation No Tag', proteinSequenceNoTagObj);
    }

    override public function getMoleculeName() : String{
        return constructId;
    }

    override public function setSequence(sequence : String){
        super.setSequence(sequence);

        dnaSeq = sequence;
    }

    public function loadProtein(cb){
        proteinSequenceObj.setName(constructId + ' (Protein)');

        proteinSequenceObj.setDNA(this);

        cb(proteinSequenceObj);
    }

    public function loadProteinNoTag(cb){
        proteinSequenceNoTagObj.setName(constructId + ' (Protein No Tag)');
        cb(proteinSequenceNoTagObj);
    }
}