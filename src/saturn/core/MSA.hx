/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.util.HaxeException;
import saturn.client.programs.blocks.BaseTable.TableDefinition;
import saturn.client.programs.blocks.BaseTable.ColumnDefinition;

class MSA {
    public var idToAlnStr : Map<String, String>;
    public var seqOrder : Array<String>;

    public var psi : Float;

    var blockSize : Int = 60;

    public function new(msaMap : Map<String,String> = null, seqOrder : Array<String> = null){
        if(msaMap == null){
            idToAlnStr = new Map<String, String>();
        }else{
            idToAlnStr = msaMap;
        }

        if(seqOrder == null){
            seqOrder = new Array<String>();
        }else{
            this.seqOrder = seqOrder;
        }

        calculateStats();
    }

    public function getAlignmentRegion(){
        var lines = new Array<String>();

        for(id in seqOrder){
            if(id != ' '){
                lines.push(idToAlnStr.get(id));
            }
        }

        return lines;
    }

    public function fetchNucAlignmentToResidue(queryName : String, residueNumber, targetName){
        if(!idToAlnStr.exists(queryName)){
            throw new HaxeException('Invalid sequence name');
        }

        var alignmentString : String= idToAlnStr.get(queryName);

        var realPosition = -1;
        for(i in 0...alignmentString.length){
            if(alignmentString.charAt(i) != '-'){
                realPosition++;

                if(residueNumber < 0){
                    var j = i + residueNumber;
                    if(j < 0){
                        throw new HaxeException(residueNumber + "isn't within the alignment");
                    }else{
                        return fetchNucAtAlignmentColumn(j, targetName);
                    }
                }else if(realPosition == residueNumber){
                    return fetchNucAtAlignmentColumn(i, targetName);
                }
            }
        }

        throw new HaxeException(residueNumber + ' not found for ' + queryName);
    }

    public function fetchNucAtAlignmentColumn(column : Int, name : String){
        if(!idToAlnStr.exists(name)){
            throw new HaxeException('Invalid sequence name');
        }

        var alignmentString : String= idToAlnStr.get(name);
        if(alignmentString.length < column){
            throw new HaxeException('' + column + ' out of range 0...' + (alignmentString.length - 1));
        }

        return alignmentString.charAt(column);
    }

    public function calculateStats(){
        if(idToAlnStr.exists(' ')){
            var idCount =0;

            var idLine = idToAlnStr.get(' ');
            for(i in 0...idLine.length){
                if(idLine.charAt(i) == '*'){
                    idCount++;
                }
            }

            psi = idCount / idLine.length;
        }
    }

    public function getPSI() : Float{
        return psi;
    }

    public function inverseComplement(){
        for(id in idToAlnStr.keys()){
            var alnStr = idToAlnStr.get(id);

            var i = alnStr.length;

            var ic = new StringBuf();
            while(i > -1){
                var c = alnStr.charAt(i);
                if(c == 'A'){
                    c = 'T';
                }else if(c == 'T'){
                    c = 'A';
                }else if(c == 'C'){
                    c = 'G';
                }else if(c == 'G'){
                    c = 'C';
                }

                ic.add(c);

                i -= 1;
            }

            idToAlnStr.set(id, ic.toString());
        }
    }

    public function getSequence(name : String){
        if(idToAlnStr.exists(name)){
            var sequence : String = idToAlnStr.get(name);

            sequence = StringTools.replace(sequence, '-', '');

            return sequence;
        }else{
            return '';
        }
    }

    public function getAlignment(name : String){
        if(idToAlnStr.exists(name)){
            var sequence : String = idToAlnStr.get(name);

            return sequence;
        }else{
            return '';
        }
    }

    public function getFirstSequence() : String{
        return getSequence(seqOrder[0]);
    }

    public function getFirstName() : String{
        return seqOrder[0];
    }

    public function toString() : String {
        var maxIdLen = -1;

        for(id in idToAlnStr.keys()){
            if(id.length > maxIdLen){
                maxIdLen = id.length;
            }
        }

        var idToPadId = new Map<String, String>();
        for(id in idToAlnStr.keys()){
            idToPadId.set(id, padString(id, maxIdLen));
        }

        var buf = new StringBuf();

        buf.add('CLUSTAL O(1.2.0) multiple sequence alignment\n\n\n');

        var i = 0;

        var l = idToAlnStr.get(seqOrder[0]).length;

        while(true){
            for(id in seqOrder){
                buf.add(idToPadId.get(id) + '      ' + idToAlnStr.get(id).substr(i, blockSize) + '\n');
            }

            i += blockSize;

            if(i > l-1){
                break;
            }
        }

        buf.add('\n\n');

        return buf.toString();
    }

    public static function padString(text : String, padLen : Int){
        var buf = new StringBuf();

        buf.add(text);

        for(i in 0...padLen-text.length){
            buf.add(' ');
        }

        return buf.toString();
    }

    public function toGrid() : GridVar{
        //msa.idToAlnStr.remove(' ');

        var g = new GridVar();

        var baseItem = getFirstName();

        var baseSequence = getAlignment(baseItem);

        var overlaps = new Array<Array<String>>();

        g.dataTableDefinition.raw = this;

        var alns = new Array<String>();
        var columnOrder = new Array<String>();
        for(i in 0...seqOrder.length-1){
            var column = seqOrder[i];
            if(column != baseItem){
                columnOrder.push(column);
                alns.push(getAlignment(column));

                g.dataTableDefinition.columnDefs.unshift({text: column, dataIndex: column, editor: 'textfield'});
            }
        }

        g.addStyle('Aligned', 'Styles', '1', 'rec', 'grey', '*');

        g.dataTableDefinition.columnDefs.unshift({text: baseItem, dataIndex: 'residue', editor: 'textfield'});

        for(i in 0...baseSequence.length){
            var char = baseSequence.charAt(i);
            if(char != '-'){
                var row :Dynamic = {'residue': char};

                for(j in 0...columnOrder.length){
                    if(alns[j].charAt(i) != '-'){
                        Reflect.setField(row, columnOrder[j], '1');
                    }
                }

                g.dataTableDefinition.data.push(row);
            }
        }

        return g;
    }
}