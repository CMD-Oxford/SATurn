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
import sys.FileStat;
import sys.FileSystem;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.io.Process;

import StringTools;
import saturn.util.HaxeException;

import sgc.molbio.core.FastaEntity;

class BatchAlignSame{

	public function new() {
		
	}
	
	static function main() {
		var args : Array<String> = Sys.args();
		
		if (args.length != 3) {
			Sys.println('Usage\tInput FASTA file\n\tInput FASTA file\n\tOutput directory\n');
			Sys.exit(-1);
		}
		
		var inputFile1 = args[0];
		var inputFile2 = args[1];
		var outputDir = args[2];
		
		var fastaObjs1 : Array<FastaEntity> = FastaEntity.parseFastaFile(inputFile1);
		var fastaObjs2 : Array<FastaEntity> = FastaEntity.parseFastaFile(inputFile2);
		
		var mapFa1 : Map<String, FastaEntity> = new Map<String, FastaEntity>();
		for (fa in fastaObjs1) {
			mapFa1.set(fa.getName(), fa);
		}
		
		var summaryOutput : FileOutput = sys.io.File.write(outputDir + '/summary.csv', false);
		summaryOutput.writeString('Target ID, File 1 Identity, File 2 Identity\n');
		
		for (fa2 in fastaObjs2) {
			if (mapFa1.exists(fa2.getName())) {
				var fa1 = mapFa1.get(fa2.getName());
				
				var inputFile = 'clustal_input.fasta';
				var outputFile = outputDir + '/' + fa1.getName() + '_' + fa2.getName() + '.aln';
				
				var tmpOutput : FileOutput = sys.io.File.write(inputFile, false);
				
				tmpOutput.writeString('>' + fa1.getName() + '_1\n' + fa1.getSequence().toUpperCase()+'\n');
				tmpOutput.writeString('>' + fa2.getName() + '_2\n' + fa2.getSequence().toUpperCase() +'\n');
				
				tmpOutput.flush();
				tmpOutput.close();
				
				var p : Process = new Process("clustalo.exe",["--residuenumber","--force", "--infile="+inputFile, "-o", outputFile, "--outfmt=clustal"]); //decompress to STDOUT

				var stdout : String = p.stdout.readAll().toString(); //read file content
				var stderr : String = p.stderr.readAll().toString(); //read file content
				
				if (p.exitCode()==0) {
					Sys.println('Clustal returned success: '+outputFile);
				}else {
					Sys.println('Clustal failed: '+stdout +'\n'+stderr);
					Sys.exit(-1);
				}
				
				var alnInput : FileInput = sys.io.File.read(outputFile, false);
				var stringContent : String = alnInput.readAll().toString();
				
				var starCount = 0;
				for (i in 0...stringContent.length) {
					if (stringContent.charAt(i) == '*') {
						starCount++;
					}
				}
				
				var id1Parts = Std.string(starCount / fa1.getSequence().length).split('.');
				var id1StrR = id1Parts[0] + '.' + id1Parts[1].substring(0, 3);
				
				var id2Parts = Std.string(starCount / fa2.getSequence().length).split('.');
				var id2StrR = id2Parts[0] + '.' + id2Parts[1].substring(0, 3);
				
				var id2F = Std.parseFloat(id2StrR) * 100;
				var id1F = Std.parseFloat(id1StrR) * 100;
				
				summaryOutput.writeString(fa1.getName() + ',' + id1F + ',' + id2F + '\n');
			}
		}
		
		summaryOutput.flush();
		summaryOutput.close();
	}
}