/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.db.Provider;
import saturn.util.HaxeException;
import saturn.core.DNA;
import saturn.client.BioinformaticsServicesClient;

class SHRNADesignTable extends Table{
    var targetSequence : String;

    public function new(?empty = true) {
        super();

        this.setErrorColumns(['Errors']);

        var data = [{
            'sequence': '',
            'linker':'TAGTGAAGCCACAGATGTA',
            'oligo':'',
            'target': '',
            'rule_one': '',
            'rule_two': '',
            'rule_three': '',
            'rule_four': '',
            'rule_five': '',
            'rule_six': '',
            'rule_seven': '',
            'errors': ''
        }];

        if(!empty){
            data = [
                {
                    'sequence': 'UUGUUGUGCAAACUGACUGCU',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGCAGCAGTCAGTTTGCACAACAATAGTGAAGCCACAGATGTATTGTTGTGCAAACTGACTGCTTTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UUUCCUGAGGUGUAGGUCCCG',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGACGGGACCTACACCTCAGGAAATAGTGAAGCCACAGATGTATTTCCTGAGGTGTAGGTCCCGCTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                'errors': ''
                },
                {
                    'sequence': 'UCUUGUUGUGCAAACUGACUG',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGACAGTCAGTTTGCACAACAAGATAGTGAAGCCACAGATGTATCTTGTTGTGCAAACTGACTGCTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UUGUCUCCUCGGUACACAGUG',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGACACTGTGTACCGAGGAGACAATAGTGAAGCCACAGATGTATTGTCTCCTCGGTACACAGTGCTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UGCUGUUUAACAACCUUCCCU',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGAAGGGAAGGTTGTTAAACAGCATAGTGAAGCCACAGATGTATGCTGTTTAACAACCTTCCCTGTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UCAGUGUCCAUACUUGAUCCG',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGACGGATCAAGTATGGACACTGATAGTGAAGCCACAGATGTATCAGTGTCCATACTTGATCCGCTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UAGGUGACAUCAUCAAGCUGG',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGCCCAGCTTGATGATGTCACCTATAGTGAAGCCACAGATGTATAGGTGACATCATCAAGCTGGATGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UUUGGAACCCUUUCUGCGCUU',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGCAAGCGCAGAAAGGGTTCCAAATAGTGAAGCCACAGATGTATTTGGAACCCTTTCTGCGCTTTTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UCUAGCUGGAAGUACUUGCGC',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGCGCGCAAGTACTTCCAGCTAGATAGTGAAGCCACAGATGTATCTAGCTGGAAGTACTTGCGCATGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'AUAUGAGGACUCUCGUAGCUG',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGACAGCTACGAGAGTCCTCATATTAGTGAAGCCACAGATGTAATATGAGGACTCTCGTAGCTGCTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UUCCUUCUUGUAAUAAAGGGA',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGCTCCCTTTATTACAAGAAGGAATAGTGAAGCCACAGATGTATTCCTTCTTGTAATAAAGGGAATGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UUCACUUAAUUCCUCCACCUC',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGAGAGGTGGAGGAATTAAGTGAATAGTGAAGCCACAGATGTATTCACTTAATTCCTCCACCTCCTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UUGGAAGUGGGAGUCCACGGA',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGCTCCGTGGACTCCCACTTCCAATAGTGAAGCCACAGATGTATTGGAAGTGGGAGTCCACGGAATGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                },
                {
                    'sequence': 'UGAGGACUCUCGUAGCUGCUG',
                    'linker':'TAGTGAAGCCACAGATGTA',
                    'oligo':'',
                    'target': 'TGCTGTTGACAGTGAGCGACAGCAGCTACGAGAGTCCTCATAGTGAAGCCACAGATGTATGAGGACTCTCGTAGCTGCTGCTGCCTACTGCCTCGGA',
                    'rule_one': '',
                    'rule_two': '',
                    'rule_three': '',
                    'rule_four': '',
                    'rule_five': '',
                    'rule_six': '',
                    'rule_seven': '',
                    'errors': ''
                }
            ];
        }

        this.setData(
            data,
            {
                'sequence':{'editor': 'textfield', 'text':'Sequence'},
                'linker':{'editor': 'textfield', 'text':'Linker', 'default': 'TAGTGAAGCCACAGATGTA'},
                'oligo':{'editor': 'textfield', 'text':'Oligo'},
                'rule_one':{'editor': 'textfield', 'text':'A/U position 1'},
                'rule_two':{'editor': 'textfield', 'text':'A/U 40-80%'},
                'rule_three':{'editor': 'textfield', 'text':'>50 % A/U 1-14'},
                'rule_four':{'editor': 'textfield', 'text':'% A/U 1-14 / % A/U 15-21 > 1'},
                'rule_five':{'editor': 'textfield', 'text':'Positon 20 not A'},
                'rule_six':{'editor': 'textfield', 'text':'A/U @ 13 or U @ 14'},
                'rule_seven':{'editor': 'textfield', 'text':'no AAAAAA, UUUUU, GGGG, CCCC'},
                'errors':{'editor': 'textfield', 'text':'Errors'}
            }
        );

        this.setName('shRNA Table');
    }

    public function setSequence(sequence : String){
        this.targetSequence = sequence;
    }

    public function calculateOligos(cb : String->Void){
        if(targetSequence == null || targetSequence.length == 0){
            cb('Please set the target sequence first');
        }

        for(row in getData()){
            var rnaStr = row.sequence;
            var linker = row.linker;

            var rna = new RNA(rnaStr);

            var dna = new DNA(rna.convertToDNA());

            var fivePrimeSeq = dna.getInverseComplement();
            var threePrimeSeq = dna.getSequence();

            var fasta : String = '>TARGET\n' + targetSequence;

            fasta += '\n>QUERY\n' + fivePrimeSeq;

            BioinformaticsServicesClient.getClient().getAlignment(fasta, function(err : String, msa : MSA){
                if(err == null){
                    try{
                        var nuc5 = msa.fetchNucAlignmentToResidue('QUERY', -1, 'TARGET');

                        if(nuc5 == 'A' || nuc5 == 'T'){
                            fivePrimeSeq = 'C' + fivePrimeSeq;
                        }else{
                            fivePrimeSeq = 'A' + fivePrimeSeq;
                        }

                        threePrimeSeq = threePrimeSeq + new DNA(nuc5).getInverseComplement();

                        var fivePrimeExtension = 'TGCTGTTGACAGTGAGCG';
                        var threePrimeExtension = 'TGCCTACTGCCTCGGA';

                        var oligo =  fivePrimeExtension + fivePrimeSeq + linker + threePrimeSeq + threePrimeExtension;

                        updateRules(rna, row);

                        row.oligo = oligo;

                        if(row.oligo == row.target){
                            row.errors = 'No Errors';
                        }else{
                            row.errors = "calculated oligo doesn't match target";
                        }

                        cb(null);
                    }catch(ex : HaxeException){
                        cb(ex.getMessage());
                    }
                }else{
                    cb(err);
                }
            });
        }
    }

    public function updateRules(rna : RNA, row : Dynamic){
        updateRuleOne(rna, row);
        updateRuleTwo(rna, row);
        updateRuleThreeAndFour(rna, row);
        updateRuleFive(rna, row);
        updateRuleSix(rna, row);
        updateRuleSeven(rna, row);
    }

    public function updateRuleOne(rna : RNA, row : Dynamic){
        var c = rna.getSequence().charAt(0);
        if(c == 'A' || c == 'U'){
            row.rule_one = 'yes';
        }else{
            row.rule_one = 'no';
        }
    }

    public function updateRuleTwo(rna : RNA, row: Dynamic){
        var comp = rna.getComposition();
        var auFraction = (comp.aCount + comp.tCount) / rna.getLength();
        if(auFraction >= 0.4 && auFraction <= 0.8){
            row.rule_two = 'yes';
        }else{
            row.rule_two = 'no - ' + auFraction;
        }
    }

    public function updateRuleThreeAndFour(rna : RNA, row: Dynamic){
        var subRNA1 = new RNA(rna.getFrom(1, 14));
        var comp = subRNA1.getComposition();
        var auFraction1 = (comp.aCount + comp.tCount) / subRNA1.getLength();
        if(auFraction1 >= 0.5){
            row.rule_three = 'yes';
        }else{
            row.rule_three = 'no';
        }

        var subRNA2 = new RNA(rna.getFrom(15, 21));
        var comp = subRNA2.getComposition();
        var auFraction2 = (comp.aCount + comp.tCount) / subRNA2.getLength();

        if(auFraction1 / auFraction2 >= 1){
            row.rule_four = 'yes';
        }else{
            row.rule_four = 'no';
        }
    }

    public function updateRuleFive(rna : RNA, row : Dynamic){
        if(rna.getSequence().charAt(19) != 'A'){
            row.rule_five = 'yes';
        }else{
            row.rule_five = 'no';
        }
    }

    public function updateRuleSix(rna : RNA, row : Dynamic){
        var pos13 = rna.getSequence().charAt(12);
        var pos14 = rna.getSequence().charAt(13);

        if(pos13 == 'A' || pos13 == 'U' || pos14 == 'U'){
            row.rule_six = 'yes';
        }else{
            row.rule_six = 'no';
        }
    }

    public function updateRuleSeven(rna: RNA, row : Dynamic){
        if(rna.findMatchingLocusesSimple('AAAAAA').length > 0 ||
            rna.findMatchingLocusesSimple('UUUUU').length > 0 ||
                rna.findMatchingLocusesSimple('GGGG').length > 0 ||
                    rna.findMatchingLocusesSimple('CCCC').length > 0){
            row.rule_seven = 'no';
        }else{
            row.rule_seven = 'yes';
        }
    }
}
