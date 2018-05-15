/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

class ClustalOmegaParser {
    public static function read(content : String) : MSA{
        var msaMap = new Map<String, String>();

        var wr = ~/\s+/g;

        if(content != null){
            var lines :Array<String> = content.split('\n');

            var seqOrder = new Array<String>();

            var s = -1;

            for(i in 3...lines.length){
                var line = lines[i];

                line = StringTools.replace(line, '\n','');
                line = StringTools.replace(line, '\r','');

                if(line != ''){
                    var cols = wr.split(line);

                    if(cols.length <= 1){
                        continue;
                    }else if(cols[0] == ''){
                        cols[0] = ' ';
                    }

                    if(s == -1){
                        s = line.length - cols[1].length;
                    }

                    if(!msaMap.exists(cols[0])){
                        msaMap.set(cols[0], line.substr(s, line.length));

                        seqOrder.push(cols[0]);
                    }else{
                        msaMap.set(cols[0], msaMap.get(cols[0]) + line.substr(s, line.length));
                    }
                }
            }

            return new MSA(msaMap, seqOrder);
        }else{
            return new MSA();
        }
    }

    /****
    *Funtion which takes a clustal output of two proteins to determine start/stop positions of the shortest protein on
    * the longest protein. Determiend by identifying the positions of the first and last * character of the alignment.
    ****/

    public static function readStartStop(content : String) : Array<Int>{

        //splits the Clustal output into a String array of the lines
        var lines :Array<String> = content.split('\n');
        //String to hold all of the the clustal alignment symbols
        var alignmentSymbols : String = '';
        //Int array to hold the start and stop positions
        var startEndPos : Array<Int> = [];
        //iterates through the array of lines (skipping the heading lines)
        for(i in 3...lines.length){
            var line = lines[i];
            //removes the retuen characters from the end of each line
            line = StringTools.replace(line, '\n','');
            line = StringTools.replace(line, '\r','');
            //removes the first 14 characters (the white space and sequence names) of each row
            line = line.substring(14);
            //Selects only the lines which contrain the alignment symbols, need to change to dynamic method.
            if(i == 5|| i == 9 || i == 13 || i == 17 || i == 21 || i == 25 || i ==  29 || i ==  33 || i ==  37
            || i == 41 || i ==  45 || i ==  49 || i ==  53 || i ==  57 || i ==  61 || i ==  65){
                //adds alignment symbol rows (minus the preceding and return characters) to create a long string of the
                //alignment characters
                alignmentSymbols = alignmentSymbols + line;
            }
        }
        //Identifies the start and end positions (index, not sequence position) 
        var startPos : Int = alignmentSymbols.indexOf('*');
        var endPos : Int = alignmentSymbols.lastIndexOf('*');
        
        //Adds the start and stop postions to an array
        startEndPos.insert(0, endPos);
        startEndPos.insert(0, startPos);
        
        
        return startEndPos;
    }
}