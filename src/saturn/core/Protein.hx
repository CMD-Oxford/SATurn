/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

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

    //Lookup for pKa values for each amino acid used in pI calc

    var lu_pKa = [
        'D'=>3.9,
        'E'=>4.4,
        'H'=>6.8,
        'Y'=>9.6,
        'K'=>10.4,
        'R'=>13.5,
        'C'=>8.3,
        'N-Term'=>8,
        'C-Term'=>3.6
    ];

    //Lookup for pKa values for each amino acid used in pI calc

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

    //Set threshold for pI calculation (i.e. the pH where charge falls between 0.5 and -0.5) and min and max pH

    var threshold : Float = 0.5;
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

    //calculate individual aa charge

    public function getAminoAcidCharge(aa : String, mid_pH : Float): Float {
        var aminoAcid = aa;
        var pH = mid_pH;
        var ratio = 1/(1+Math.pow(10,(pH - lu_pKa.get(aminoAcid))));
        if (lu_charge.get(aminoAcid) == 1)
            return ratio;
        else
            return ratio - 1;
    };

    //calculate whole protein charge at pH set by Var pH

    /**
    *  getProteinCharge calculates the whole protein at pH set by.....
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

    //calculate pI,

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
}






