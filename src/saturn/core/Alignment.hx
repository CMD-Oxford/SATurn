/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

class Alignment {
	var sequenceA : String;
	var sequenceB : String;
	
	var alnMatrix : Array<Array<Int>>;
	var alnDMatrix : Array<Array<String>>;
	
	var sequenceALen : Int;
	var sequenceBLen : Int;
	
	var gapScore : Int = -1;
	var matchScore : Int = 1;
	var missMatchScore : Int = -2;
	
	var sequenceAAlnStr : String;
	var sequenceBAlnStr : String;
	
	var localMode : Bool = false;
	var lMaxJ : Int = 0;
	var lMaxI : Int = 0;
	
	var lMaxScore : Int = -1;
	var lMinScore : Int = 2;
	
	var localBlocks : Array<LocalBlock>;

    var seqID : Int = 0;
	
	public function new( seqA : String, seqB : String) {
		sequenceA = seqA.toUpperCase();
		sequenceB = seqB.toUpperCase();

        localBlocks = new Array<LocalBlock>();
	}
	

	public function setAlignmentType(alnType : AlignmentType) {
		if (alnType == AlignmentType.SW) {
			localMode = true;
		}else {
			localMode = false;
		}
	}
	
	public function getAlignment() : Array<String> {
		var localBlock : LocalBlock = localBlocks[0];
		
		var retArray : Array<String> = [localBlock.sequenceA, localBlock.sequenceB];
		
		return retArray;
	}

    public function getAlignmentRegion() : Array<String>{
        return getAlignment();
    }

    public function setBlock(block : LocalBlock){
        localBlocks.push(block);
    }
	
	public function getAllLocalAlignments() : Array<LocalBlock> {
		return localBlocks;
	}
	
	public function align() {
		lMaxJ = 0;
		lMaxI = 0;
		lMaxScore = -1;
		
		alnMatrix = new Array<Array<Int>>();
		alnDMatrix = new Array<Array<String>>();
		
		localBlocks = new Array<LocalBlock>();
		
		sequenceALen = sequenceA.length;
		sequenceBLen = sequenceB.length;
		
		for (i in 0...sequenceBLen + 1) {
			var iAln : Array<Int> = new Array<Int>();
			var iDAln : Array<String> = new Array<String>();
			
			for (j in 0...sequenceALen + 1) {
				iAln.push(0);
				iDAln.push('');
			}
			
			alnMatrix.push(iAln);
			alnDMatrix.push(iDAln);
		}
		
		/** 
		 *        i
		 *    0 A B C
		 *   A 
		 * j B 
		 *   C
		 */
		alnMatrix[0][0] = 0; //j, i
		alnDMatrix[0][0] = 'N';
		
		for (i in 1...sequenceALen+1) {
			alnMatrix[0][i] = i * gapScore;
			alnDMatrix[0][i] = 'L';
		}
		
		for (j in 1...sequenceBLen+1) {
			alnMatrix[j][0] = j * gapScore;
			alnDMatrix[j][0] = 'L';
		}
		
		for (j in 1...sequenceBLen+1) {
			for ( i in 1...sequenceALen+1) {
				var dScore : Int;
				
				if (sequenceB.charAt(j-1) == sequenceA.charAt(i-1)) {
					dScore = alnMatrix[j - 1][i - 1] + matchScore;
				}else {
					dScore = alnMatrix[j - 1][i - 1] + missMatchScore;
				}
				
				var lScore : Int = alnMatrix[j][i -1] + gapScore;
				var uScore : Int = alnMatrix[j-1][i] + gapScore;
				
				if (dScore >= uScore) {
					if (dScore >= lScore) {
						alnMatrix[j][i] = dScore;
						alnDMatrix[j][i] = 'D';
					}else {
						alnMatrix[j][i] = lScore;
						alnDMatrix[j][i] = 'L';
					}
				}else {
					if (uScore >= lScore) {
						alnMatrix[j][i] = uScore;
						alnDMatrix[j][i] = 'U';
					}else {
						alnMatrix[j][i] = lScore;
						alnDMatrix[j][i] = 'L';
					}
				}
				
				if (localMode) {
					if ( 0 > alnMatrix[j][i] ) {
						alnMatrix[j][i] = 0;
						alnDMatrix[j][i] = 'S';
					}else {
						if (alnMatrix[j][i] > lMaxScore) {
							lMaxScore = alnMatrix[j][i];
							lMaxJ = j;
							lMaxI = i;
						}
						
						if (alnMatrix[j][i] > lMinScore) {
							localBlocks.push(new LocalBlock(j,i, alnMatrix[j][i]));
						}
					}
				}
			}
		}
		
		var blocksToProcess : Array<LocalBlock> = new Array<LocalBlock>();
		
		if (localMode) {
			var scoreToBlocks : Map < Int, Array<LocalBlock> > = new Map < Int, Array<LocalBlock> > ();
			
			for (l in 0...localBlocks.length) {
				var localBlock : LocalBlock = localBlocks[l];
				
				if (! scoreToBlocks.exists(localBlock.score)) {
					scoreToBlocks.set(localBlock.score, new Array<LocalBlock>());
				}
				
				scoreToBlocks.get(localBlock.score).push(localBlock);
			}
			
			var scoreList : Array<Int> = new Array<Int>();
			
			for (key in scoreToBlocks.keys()) {
				scoreList.push(key);
			}
			
			scoreList.sort(function(a, b) return b - a);
			
			for (score in scoreList) {
				for (localBlock in scoreToBlocks.get(score)) {
					blocksToProcess.push(localBlock);
				}
			}
			
		}else {
			blocksToProcess.push(new LocalBlock(sequenceBLen, sequenceALen, 0));
		}
		
		localBlocks = new Array<LocalBlock>();

        seqID = 0;
		
		var visitedPositions : Map<String, String> = new Map<String,String>();
		
		for (l in 0...blocksToProcess.length) {		
			var sequenceAAln : Array<String> = new Array<String>();
			var sequenceBAln : Array<String> = new Array<String>();
		
			var localBlock : LocalBlock = blocksToProcess[l];
			
			var i : Int = localBlock.iPosition;
			var j : Int = localBlock.jPosition;
			
			var breaked : Bool = false;
			
			while (true) {
				if (alnDMatrix[j][i] == 'N' || alnDMatrix[j][i] == 'S' || 0 > i) {
					break;
				}else {
					if (alnDMatrix[j][i] == 'D') {
						if (visitedPositions.exists('I'+Std.string(i-1))) {
							breaked = true;
							break;
						}else if (visitedPositions.exists('J'+Std.string(j - 1))) {
							breaked = true;
							break;
						}
						
						visitedPositions.set('I' + Std.string(i - 1),'');
						visitedPositions.set('J' + Std.string(j - 1),'');
						
						sequenceAAln.push(sequenceA.charAt(i - 1));
						sequenceBAln.push(sequenceB.charAt(j - 1));

                        if(sequenceA.charAt(i-1) == sequenceB.charAt(j-1)){
                            seqID++;
                        }

						j--;
						i--;
					}else if (alnDMatrix[j][i] == 'L') {
						if (visitedPositions.exists('I'+Std.string(i-1))) {
							breaked = true;
							break;
						}
						visitedPositions.set('I' + Std.string(i - 1),'');
						
						sequenceAAln.push(sequenceA.charAt(i - 1));
						sequenceBAln.push('-');
						i--;
					}else if (alnDMatrix[j][i] == 'U') {
						if (visitedPositions.exists('J'+Std.string(j-1))) {
							breaked = true;
							break;
						}
						
						visitedPositions.set('J' + Std.string(j - 1),'');
						
						sequenceBAln.push(sequenceB.charAt(j - 1));
						sequenceAAln.push('-');
						j--;
					}
				}
			}
			
			if (!breaked) {
				sequenceAAln.reverse();
				sequenceAAlnStr = sequenceAAln.join('');
		
				sequenceBAln.reverse();
				sequenceBAlnStr = sequenceBAln.join('');
				
				localBlock.sequenceA = sequenceAAlnStr;
				localBlock.sequenceB = sequenceBAlnStr;
				
				localBlocks.push(localBlock);
			}
		}
	}

    public function getSeqAId(){
        return (seqID / sequenceA.length) * 100;
    }
}

class LocalBlock {
	public var iPosition : Int;
	public var jPosition : Int;
	public var score : Int;
	
	public var sequenceA : String;
	public var sequenceB : String;
	
	public function new(j : Int, i :Int, hitScore : Int) {
		iPosition = i;
		jPosition = j;
		score = hitScore;
	}
}

enum AlignmentType {
	SW;
	NW;
}