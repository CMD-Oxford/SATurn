/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.core.domain.SgcReversePrimer;
import saturn.core.domain.SgcForwardPrimer;
import saturn.client.WorkspaceApplication;
import saturn.core.domain.SgcConstruct;

class ConstructSet {
    var constructs : Array<SgcConstruct>;

    public function new(? constructs : Array<SgcConstruct>){
        setConstructs(constructs);
    }

    public function setConstructs(constructs : Array<SgcConstruct>){
        this.constructs = constructs;
    }

    public function getForwardPrimers() : Map<String, SgcForwardPrimer>{
        var primers = new Map<String, SgcForwardPrimer>();
        for(construct in this.constructs){
            if(construct.allele != null && construct.allele.forwardPrimer != null){
                var primer = construct.allele.forwardPrimer;
                if(!primers.exists(primer.primerId)){
                    primers.set(primer.primerId, primer);
                }
            }
        }

        return primers;
    }

    public function getReversePrimers() : Map<String, SgcReversePrimer>{
        var primers = new Map<String, SgcReversePrimer>();
        for(construct in this.constructs){
            if(construct.allele != null && construct.allele.reversePrimer != null){
                var primer = construct.allele.reversePrimer;
                if(!primers.exists(primer.primerId)){
                    primers.set(primer.primerId, primer);
                }
            }
        }

        return primers;
    }

    public function generatePrimerReport() : String{
        var forwardPrimers = getForwardPrimers();
        var reversePrimers = getReversePrimers();

        var primers = new Array<Dynamic>();
        for(id in forwardPrimers.keys()){
            primers.push(forwardPrimers.get(id));
        }

        for(id in reversePrimers.keys()){
            primers.push(reversePrimers.get(id));
        }

        primers.sort(function(p1:Dynamic, p2:Dynamic):Int{
            var a : String = p1.primerId.toLowerCase();
            var b : String = p2.primerId.toLowerCase();

            if(a.indexOf('-f') != -1){
                if(b.indexOf('-r') != -1){
                    return -1;
                }
            }else if(a.indexOf('-r') != -1){
                if(b.indexOf('-f') != -1){
                    return 1;
                }
            }

            if (a < b) return -1;
            if (a > b) return 1;
            return 0;
        });

        var row = 'A';
        var col = 1;

        var buf = new StringBuf();

        for(primer in primers){

            var well = row + col;

            buf.add(well + ',' + primer.primerId + ',' + primer.dnaSequence + '\n');

            if(col == 12){
                col = 1;

                row = String.fromCharCode(row.charCodeAt(0) + 1);
            }else{
                col++;
            }
        }

        return buf.toString();
    }
}