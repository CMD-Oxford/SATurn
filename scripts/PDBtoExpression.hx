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


import sys.io.File;
import sys.io.FileOutput;
import sys.FileSystem;

import sys.io.Process;

import sgc.molbio.core.PDBParser;

class PDBtoExpression {
	
	static var whiteSpaceReg = ~/\s+/g; 
	static var onlyWhiteSpaceReg = ~/^\s+$/g; 
	static var pdbCodeReg : EReg = ~/^pdb([0-9A-Za-z]+)/;
	
	static var fastaFd : FileOutput;
	  
	public function new() {
		
	}
	
	static function main() {
		if (Sys.args().length != 1) {
			Sys.println('Usage\tOutput Fasta File\n');
			Sys.exit(0);
		}
		
		var outputFileName = Sys.args()[0];
		
		var fastaFd : FileOutput = sys.io.File.write(outputFileName, false);

        fastaFd.writeString('PDB Code~'+
            'Chain~'+
            'Molecule ID~'+
            'Deposition date~'+
            'Resolution~' +
            'Experiment Type~' +
            'Title~' +
            'Authors~' +
            'Expression System~' +
            'Expression ID~' +
            'Gene System~' +
            'Gene System ID~' +
            'Release Date\n'
        );
		
		var pdbMirrorPath : String = '/db/PDB/data/structures/divided/pdb';
		var files : Array<String> = sys.FileSystem.readDirectory(pdbMirrorPath);
		
		var count : Int = 0;
		
		for ( file in files ) {
			var itemPath : String = pdbMirrorPath + '/' + file;
			if (FileSystem.isDirectory(itemPath)) {
				var subItems : Array<String> = sys.FileSystem.readDirectory(itemPath);
				for (subItem in subItems) {
					var subItemPath = itemPath + '/' + subItem;
					if (! FileSystem.isDirectory(subItemPath) ) {
						count++;
						
						pdbCodeReg.match(subItem);
						
						var pdbCode : String = pdbCodeReg.matched(1);
						/*
						if (pdbCode == null ) {
							continue;
						}else if(pdbCode != '3ioj') {
							//Sys.println('Skipping: ' + pdbCode + ' / ' +count);
							continue;
						}*/
						
						Sys.println(subItemPath+'/'+count);
		
						//NEW
						var p : Process = new Process("gzip", ['-d', subItemPath, '-c'] ); //decompress to STDOUT

						var fileContent : String = p.stdout.readAll().toString(); //read file content

						if (p.exitCode()==0) {
							Sys.println('Uncompressed');
						}else {
							Sys.println('Failed to uncompress');
							Sys.exit(-1);
						}
 						
						PDBParser.getExpression(fileContent, pdbCode, fastaFd);
					}
				}
			}
		}
		
		fastaFd.close();
	}
}