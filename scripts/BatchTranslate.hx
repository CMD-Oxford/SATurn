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

import sgc.molbio.core.DNA;
import sys.io.FileInput;
import StringTools;
import sys.io.FileOutput;

import saturn.util.HaxeException;

class BatchTranslate{
	public function new() {
		
	}
	
	static function main() {
		var args : Array<String> = Sys.args();
		
		if (args.length != 2) {
			Sys.println('Usage\tInput FASTA file\n\tOutput FASTA file\n');
			Sys.exit(-1);
		}
		
		var inputFile = args[0];
		var outputFile = args[1];
		
		var inputHandle : FileInput = sys.io.File.read(inputFile, false);
		var outputHandle : FileOutput = sys.io.File.write(outputFile, false);
		
		var headerLine = null;
		var sequence = '';
		
		while (! inputHandle.eof() ) {
			var line : String = inputHandle.readLine();
			
			if (StringTools.startsWith(line, '>')) {
				if(headerLine != null && sequence.length > 2){
					var dna : DNA = new DNA(sequence);
					
					try{
						var translation : String = dna.getTranslation(GeneticCodes.STANDARD, 0);
						outputHandle.writeString(headerLine + '\n' + translation + '\n');
					}catch (exception : HaxeException) {
						Sys.println(exception.getMessage());
						Sys.exit(-1);
					}
				}

				sequence = '';
				headerLine = line;
			}else if(headerLine != null){
				sequence = sequence + line;
			}
		}
		
		if(sequence.length > 2){
			var dna : DNA = new DNA(sequence);
			
			try{
				var translation : String = dna.getTranslation(GeneticCodes.STANDARD, 0);
				outputHandle.writeString(headerLine + '\n' + translation);
			}catch (exception : HaxeException) {
				Sys.println(exception.getMessage());
				Sys.exit(-1);
			}
		}
				
		
		outputHandle.flush();
		outputHandle.close();
		
		inputHandle.close();
		
	}
}