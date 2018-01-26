/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

#if !js
import haxe.ds.HashMap;
import sys.io.FileInput;
#end

class FastaEntity {
    var theName : String;
    var theSequence : String;
	
	static var DNA_CHARS : Map < String, Bool > = ['A' => true, 'T' => true, 'G' => true, 'C' => true, 'X' => true, 'U' => true];

    public function new(name : String, sequence : String){
        theName = name;
        theSequence = sequence;
    }

    public function getName() : String {
        return theName;
    }

    public function getSequence() : String {
        return theSequence;
    }
	
	public function append(sequence : String) {
		theSequence = theSequence + sequence;
	}
	
	public function guessType() : FastaEntryType {
		var c = 0;
		
		var l = 1;
		
		var sLen = theSequence.length;
		
		var pos = 0;
		while (sLen > pos) {
			var res = theSequence.charAt(pos);
			if ( ! DNA_CHARS.exists( res ) ) {
				c++;
				
				if ( c > l ) {
					return FastaEntryType.PROTEIN;
				}
			}
			
			pos++;
		}
		
		return FastaEntryType.DNA;
	}
	
	static var headerPattern1 = ~/^>(.+)/;

    public static function handleStrippedNewLines(line : String) : Array<String>{
        var blockSizeCounts = new Map<Int, Int>();
        var whiteBlocks = line.split(' ');
        for(whiteBlock in whiteBlocks){
            if(!blockSizeCounts.exists(whiteBlock.length)){
                blockSizeCounts.set(whiteBlock.length, 0);
            }

            blockSizeCounts.set(whiteBlock.length, blockSizeCounts.get(whiteBlock.length)+1);
        }
        var blockLen = 0;
        var blockSizeCountMax = -1;
        for(len in blockSizeCounts.keys()){
            var blockSizeCount = blockSizeCounts.get(len);
            if(blockSizeCountMax < blockSizeCount){
                blockSizeCountMax = blockSizeCount;
                blockLen = len;
            }
        }

        var lines = new Array<String>();
        whiteBlocks.reverse();
        lines.unshift(whiteBlocks.shift());
        var header = '';
        for(whiteBlock in whiteBlocks){
            if(whiteBlock.length == blockLen){
                lines.unshift(whiteBlock);
            }else{
                header = whiteBlock + ' ' + header;
            }
        }

        lines.unshift(header);
        return lines;
    }
	
	public static function parseFasta(contents : String) : Array<FastaEntity> {
        var seqObjs : Array<FastaEntity> = new Array<FastaEntity>(); 

        var currentName : String = null;
        var currentSeqBuf : StringBuf = new StringBuf();
        var lines : Array<String> = contents.split("\n");


        if(lines.length == 1){
            lines = handleStrippedNewLines(lines[0]);
        }

        var numLines = lines.length;

        for(i in 0...numLines){
            var seqLine : Bool = true;

            var line : String = lines[i];
            if(line.indexOf('>') > -1){
                seqLine = false;
            }

            if(seqLine == true){
                currentSeqBuf.add(line);
            }

            if(seqLine == false || i == numLines - 1 ){
                if(currentName != null){
                    var currentSeq : String = currentSeqBuf.toString();
                    if(currentSeq.length > 0){
                        seqObjs.push(new FastaEntity(currentName.substr(1,currentName.length), currentSeq));

                        currentSeqBuf = new StringBuf();
                    }
                }

                if(seqLine == false){
                    currentName  = line;
                }
            }
        }
		
		return seqObjs;
	}
	
	#if !js
	public static function parseFastaFile(fileName : String) : Array<FastaEntity> {
		var handle : FileInput = sys.io.File.read(fileName, false);
		
		return parseFasta(handle.readAll().toString());
	}
	#end

    public static function formatFastaFile(header : String, sequence : String) : String{
        var buf = new StringBuf();
        buf.add('>'+header+'\n');

        var sequenceLength = sequence.length - 1;
        var i = 0;
        while(true){
            var j = i + 50;

            if(j > sequenceLength){
                j = sequenceLength +1;
            }

            js.Browser.window.console.log('Hello' + i + '/' + j);

            buf.add(sequence.substring(i, j) + '\n');

            i = j;

            if(i >= sequenceLength+1){
                break;
            }
        }

        return buf.toString();
    }
}

enum FastaEntryType {
	DNA;
	PROTEIN;
}