/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Copyright (C) 2015  Structural Genomics Consortium
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import ac.uk.ox.sgc.molbio.core.Alignment;
import ac.uk.ox.sgc.StringUtils;

class AlignmentHelper{
	public function new() {
		
	}
	
	static function main() {
		var args : Array<String> =  Sys.args();
		var argNo : Int = args.length;
		
		var seqA : String = args[0];
		var seqB : String = args[1];
		
		var aln : Alignment = new Alignment(seqA, seqB);
		
		aln.align();
		
		var alnArray : Array<String> = aln.getAlignment();
		
		Sys.println('Global alignment');
		
		Sys.println(alnArray[0]);
		Sys.println(alnArray[1]);
		
		aln.setAlignmentType(AlignmentType.SW);
		
		aln.align();
		
		var alnArray : Array<String> = aln.getAlignment();
		
		Sys.println('Highest scoring local alignment');
		
		Sys.println(alnArray[0]);
		Sys.println(alnArray[1]);
		
		Sys.println('All local alignments');
		
		for (localBlock in aln.getAllLocalAlignments()) {
			Sys.println('>A' + Std.string(localBlock.iPosition));
			Sys.println('>B' + Std.string(localBlock.jPosition));
			Sys.println('>SCORE' + Std.string(localBlock.score));
			
			Sys.println(localBlock.sequenceA);
			Sys.println(localBlock.sequenceB);
		}
		
	}
}