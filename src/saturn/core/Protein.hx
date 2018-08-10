/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Stephen Joyce <stephen.joyce@ndorms.ox.ac.uk, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.core.DNA.GeneticCodeRegistry;
import saturn.core.domain.MoleculeAnnotation;
import saturn.core.domain.DataSource;
import saturn.core.domain.Entity;
import saturn.core.molecule.MoleculeSet;
import saturn.core.molecule.MoleculeSetRegistry;
import saturn.core.molecule.Molecule;

import saturn.core.EntityType;
import saturn.core.ReactionRole;
import saturn.core.ReactionComponent;
import saturn.core.ReactionType;
import saturn.core.Reaction;
import saturn.core.Protein;
import saturn.core.EUtils;

using saturn.core.Util;

import saturn.core.Util.*;

class Protein extends Molecule{
    public var dna : DNA;
    var coordinates : String;

    var hydrophobicityLookUp = [
        'A'=>1.8,
        'G'=>-0.4,
        'M'=>1.9,
        'S'=>-0.8,
        'C'=>2.5,
        'H'=>-3.2,
        'N'=>-3.5,
        'T'=>-0.7,
        'D'=>-3.5,
        'I'=>4.5,
        'P'=>-1.6,
        'V'=>4.2,
        'E'=>-3.5,
        'K'=>-3.9,
        'Q'=>-3.5,
        'W'=>-0.9,
        'F'=>2.8,
        'L'=>3.8,
        'R'=>-4.5,
        'Y'=>-1.3
    ];

    /**
    * Lookup for pKa values for each amino acid used in pI calc.
    * Reference: Bjellqvist, B., Hughes, G. J., Pasquali, C., Paquet, N., Ravier, F., Sanchez, J.-C., Frutiger, S. and Hochstrasser, D. (1993), The focusing positions of polypeptides in immobilized pH gradients can be predicted from their amino acid sequences. ELECTROPHORESIS, 14: 1023–1031. doi:10.1002/elps.11501401163
    **/

    var lu_pKa = [
    'D'=>4.05,
    'E'=>4.45,
    'H'=>5.98,
    'Y'=>10,
    'K'=>10.4,
    'R'=>12.5,
    'C'=>9,
    'N-Term'=>8,
    'C-Term'=>3.55
];

    /**
    * Lookup for pKa values for each amino acid used in pI calc
    **/

    var lu_charge = [
        'D'=>-1,
        'E'=>-1,
        'H'=>1,
        'Y'=>-1,
        'K'=>1,
        'R'=>1,
        'C'=>-1,
        'N-Term'=>1,
        'C-Term'=>-1
    ];

    /**
    *Lookup for extinction coefficient values values for each amino acid used in Extinction Coefficienct Caluclation
    *Reference: Pace, C. N., Vajdos, F., Fee, L., Grimsley, G., & Gray, T. (1995). How to measure and predict the molar absorption coefficient of a protein. Protein Science : A Publication of the Protein Society, 4(11), 2411–2423.
    **/

    var lu_extinction = [
        'Y'=>1490,
        'W'=>5500,
        'C'=>125, /**Cystine not Cysteine**/
    ];

    /**
    * Set threshold for pI calculation (i.e. the pH where charge falls between 0.5 and -0.5) and the min and max pH values
    **/

    var threshold : Float = 0.1;
    var min_pH : Float = 3;
    var max_pH: Float = 13;

    override public function setSequence(sequence : String){
        super.setSequence(sequence);

        if(sequence != null){
            var mSet : MoleculeSet = MoleculeSetRegistry.getStandardMoleculeSet();

            var mw : Float = mSet.getMolecule('H2O').getFloatAttribute(MoleculeFloatAttribute.MW);
            for(i in 0...this.sequence.length){
                var molecule = mSet.getMolecule(this.sequence.charAt(i));

                if(molecule != null){
                    mw += molecule.getFloatAttribute(MoleculeFloatAttribute.MW_CONDESATION);
                }else{
                    mw = -1;
                    break;
                }
            }

            setFloatAttribute(MoleculeFloatAttribute.MW,mw);
        }

        if(isLinked()){
            var d : DNA = getParent();
            if(d != null){
                d.proteinSequenceUpdated(this.sequence);
            }
        }
    }

    public function getHydrophobicity() : Float{
        var proteinSequence = this.sequence;
        var seqLength = this.sequence.length;
        var totalGravy : Float = 0.0;
        var averageGravy : Float = 0.0;
        for(i in 0...seqLength){
            var aminoAcid = proteinSequence.substr(i,1);
            var hydroValue = hydrophobicityLookUp.get(aminoAcid);
            totalGravy+=hydroValue;
        }
        averageGravy = totalGravy/seqLength;
        return averageGravy;
    }

    public function setDNA(dna : DNA){
        this.dna = dna;
    }

    public function dnaSequenceUpdated(sequence : String){

    }

    public function getDNA() : DNA {
        return this.dna;
    }

    public function setReferenceCoordinates(coordinates : String){
        this.coordinates = coordinates;
    }

    public function getReferenceCoordinates() : String{
        return this.coordinates;
    }

    public static function _insertGene(geneId, source : String,cb : String->Void){
        var provider = getProvider();

        provider.getById(geneId, Entity, function(obj : Entity, err : String){
            if(err != null){
                cb(err);
            }else{
                if(obj != null){
                    cb(null);
                }else{
                    var gene = new Entity();
                    gene.entityId = geneId;
                    gene.source = new DataSource();
                    gene.source.name = source;
                    gene.entityType = new EntityType();
                    gene.entityType.name = 'DNA';

                    EUtils.getGeneInfo(Std.parseInt(geneId), function(err : String, info : Dynamic){
                        gene.altName = info.symbol;
                        gene.description = info.description;

                        provider.insertObjects([gene], function(err : String){
                            cb(err);
                        });
                    });
                }
            }
        });
    }

    /**
    * insertTranslation - temporary method to get RefSeq type data into the normalised reaction tables
    *
    * Much of this will be done for us once we improve the mapping in SGC.hx
    **/
    public static function insertTranslation(dnaId : String, dnaAltName : String, dnaSeq : String, dnaSource : String, protId : String, protAltName : String,protSeq : String, protSource : String, geneId : String, geneSource : String, cb : String->Void){
        var provider = getProvider();

        _insertGene(geneId, geneSource,function(err : String){
            if(err != null){
                cb(err);
            }else{
                //Build DNA
                var dna = new Entity();
                dna.entityId = dnaId;
                dna.altName = dnaAltName;
                dna.source = new DataSource();
                dna.source.name = dnaSource;
                dna.entityType = new EntityType();
                dna.entityType.name = 'DNA';

                var dna_mol = new saturn.core.domain.Molecule();
                dna_mol.entity = dna;
                dna_mol.sequence = dnaSeq;

                //Build xreference to Gene

                var annotation = new MoleculeAnnotation();
                annotation.entity = dna;
                annotation.referent = new Entity();
                annotation.referent.entityId = geneId;
                annotation.referent.source = new DataSource();
                annotation.referent.source.name = 'GENE';

                //Build Protein
                var prot = new Entity();
                prot.entityId = protId;
                prot.altName = protAltName;
                prot.source = new DataSource();
                prot.source.name = protSource;
                prot.entityType = new EntityType();
                prot.entityType.name = 'PROTEIN';

                var prot_mol = new saturn.core.domain.Molecule();
                prot_mol.entity = prot;
                prot_mol.sequence = protSeq;

                //Build translation reaction
                var reaction = new Reaction();
                reaction.name = dnaId + '-TRANS';
                reaction.reactionType = new ReactionType();
                reaction.reactionType.name = 'TRANSLATION';

                prot.reaction = reaction;

                var reactionComp = new ReactionComponent();
                reactionComp.entity = dna;
                reactionComp.reactionRole = new ReactionRole();
                reactionComp.reactionRole.name = 'TEMPLATE';
                reactionComp.reaction = reaction;
                reactionComp.position = 1;

                //Insert DNA
                provider.insertObjects([dna], function(err : String){
                    if(err != null){
                        cb(err);
                    }else{
                        //Insert molecule
                        provider.insertObjects([dna_mol], function(err : String){
                            if(err != null){
                                cb(err);
                            }else{
                                //Insert translation reaction
                                provider.insertObjects([reaction], function(err : String){
                                    if(err != null){
                                        cb(err);
                                    }else{
                                        //Insert reaction component
                                        provider.insertObjects([reactionComp], function(err : String){
                                            if(err != null){
                                                cb(err);
                                            }else{
                                                //Insert protein
                                                provider.insertObjects([prot], function(err : String){
                                                    if(err != null){
                                                        cb(err);
                                                    }else{
                                                        //Insert molecule
                                                        provider.insertObjects([prot_mol], function(err : String){
                                                            if(err != null){
                                                                cb(err);
                                                            }else{
                                                                //Insert annotation
                                                                provider.insertObjects([annotation], function(err : String){
                                                                    if(err != null){
                                                                        debug(err);
                                                                    }

                                                                    cb(err);
                                                                });
                                                            }
                                                        });
                                                    }
                                                });
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    }

    /**
    getaminoAcidCharge calculates the charge of an amino acid
    **/

    public function getAminoAcidCharge(aa : String, mid_pH : Float): Float {
        var aminoAcid = aa;
        var pH = mid_pH;
        var ratio = 1/(1+Math.pow(10,(pH - lu_pKa.get(aminoAcid))));
        if (lu_charge.get(aminoAcid) == 1)
            return ratio;
        else
            return ratio - 1;
    };

    /**
    *  getProteinCharge calculates the whole protein at a certain pH
    **/

    public function getProteinCharge(mid_pH : Float): Float {
        var seqLength = this.sequence.length;
        var proteinSequence = this.sequence;

        var aa = 'N-Term';
        var proteinCharge = getAminoAcidCharge(aa, mid_pH);

        aa = 'C-Term';
        proteinCharge += getAminoAcidCharge(aa, mid_pH);

        for(i in 0...seqLength){
            aa = proteinSequence.substr(i,1);

            if(this.lu_pKa.exists(aa)){
                proteinCharge += getAminoAcidCharge(aa, mid_pH);
            }
        };

        return proteinCharge;
    };

    /**
    getpI Calculates the pI of a protein, calculates the pH when charge falls between -threshold and +threshold.
    **/

    public function getpI(): Float {
        var proteinSequence = this.sequence;

        while (true){
            var mid_pH = 0.5 * (max_pH + min_pH);
            var proteinCharge = getProteinCharge(mid_pH);

            if (proteinCharge > threshold){
                min_pH = mid_pH;
            }else if (proteinCharge < -threshold){
                max_pH = mid_pH;
            }else{
                return mid_pH;
            }
        }
    }

    /**
    getExtinctionNonReduced calculates the extinction coefficient of a protein, assuming that all pairs of cystein residues form disulphide bonds.
    Reference: Source: Pace, C. N., Vajdos, F., Fee, L., Grimsley, G., & Gray, T. (1995). How to measure and predict the molar absorption coefficient of a protein. Protein Science : A Publication of the Protein Society, 4(11), 2411–2423.
    **/

    public function getExtinctionNonReduced(): Float {
        var proteinSequence = this.sequence;
        var seqLength = this.sequence.length;
        var aa : String;
        var extinctionNonReduced : Float = 0.0;
        var numberCysteines : Float = 0.0;
        var pairsCysteins : Float = 0.0;

        for(i in 0...seqLength){
            aa = proteinSequence.substr(i,1);

            if(this.lu_extinction.exists(aa) && aa != 'C'){
                extinctionNonReduced += lu_extinction.get(aa);
            }

            if(aa == 'C'){
                numberCysteines += 1;
            }
        };

        if ((numberCysteines%2) == 0) {
            pairsCysteins = (numberCysteines)/2;
        }
        else {
            pairsCysteins = ((numberCysteines)/2)-0.5;
            }

        extinctionNonReduced += pairsCysteins*lu_extinction.get('C');

        return extinctionNonReduced;
    }

    /**
    getExtinctionNonReduced calculates the extinction coefficient of a protein, assuming that no disulphide bonds are formed
    Reference: Source: Pace, C. N., Vajdos, F., Fee, L., Grimsley, G., & Gray, T. (1995). How to measure and predict the molar absorption coefficient of a protein. Protein Science : A Publication of the Protein Society, 4(11), 2411–2423.
    **/

    public function getExtinctionReduced(): Float {
        var proteinSequence = this.sequence;
        var seqLength = this.sequence.length;
        var aa : String;
        var extinctionReduced : Float = 0.0;

        for(i in 0...seqLength){
            aa = proteinSequence.substr(i,1);

            if(this.lu_extinction.exists(aa) && aa != 'C') {
                extinctionReduced += lu_extinction.get(aa);
            }
        };

        return extinctionReduced;
    }

    public static function isProtein(sequence : String){
        var seqLen=sequence.length;

        var valid_res = GeneticCodeRegistry.getDefault().getAAToCodonTable();

        for(i in 0...seqLen){
            var res : String = sequence.charAt(i).toUpperCase();

            if(!valid_res.exists(res)){
                return false;
            }
        }

        return true;
    }
}






