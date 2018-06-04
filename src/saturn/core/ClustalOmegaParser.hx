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

    public static function readStartStop(content : String, consreuctIdLength : Int) : Array<Int>{

        //splits the Clustal output into a String array of the lines
        var lines :Array<String> = content.split('\n');
        //String to hold all of the the clustal alignment symbols
        var alignmentSymbols : String = '';
        //Int array to hold the start and stop positions
        var startEndPos : Array<Int> = [];
        //int to hold the lenght of the leading characters in the clustal file
        var lengthOfLeading : Int = 0;


        //Determine lenght of lead characters (name and spaces)
        //Selects the first construct line of the clustal file
        var constructLine : String = lines[3];
        //Iterates througgh all characters after the construct name. The first non-space character is determined as the
        // start of the alignment
        for(i in consreuctIdLength...constructLine.length){
            if(constructLine.charAt(i) != ' '){
                lengthOfLeading = i;
                break;
            }
        }

        //Target position offset calculation, if the construct begins before the target in the clustal file
        var alignmentTarget : String = '';
        var targetOffset : Int = 0;

        for(i in 3...lines.length){
            var line = lines[i];
            //removes the return characters from the end of each line
            line = StringTools.replace(line, '\n','');
            line = StringTools.replace(line, '\r','');
            //removes the trailing characters characters (the white space and sequence names) of each row
            line = line.substring(lengthOfLeading);
            //Selects only the lines which contrain the target sequence.
            if(i == 4|| i == 8 || i == 12 || i == 16 || i == 20 || i == 24 || i ==  28 || i ==  32 || i ==  36
            || i == 40 || i ==  44 || i ==  48 || i ==  52 || i ==  56 || i ==  60 || i ==  64){
                //adds alignment symbol rows (minus the preceding and return characters) to create a long string of the
                //alignment target
                alignmentTarget = alignmentTarget + line;
            }
        }

        for(i in 0...alignmentTarget.length){
            if(alignmentTarget.charAt(i) != '-'){
                targetOffset = i;
                break;
            }
        }

        //iterates through the array of lines (skipping the heading lines) to create  a long string of thr alignment
        // characters
        for(i in 3...lines.length){
            var line = lines[i];
            //removes the retuen characters from the end of each line
            line = StringTools.replace(line, '\n','');
            line = StringTools.replace(line, '\r','');
            //removes the trailing characters characters (the white space and sequence names) of each row
            line = line.substring(lengthOfLeading);
            //Selects only the lines which contrain the alignment symbols, need to change to dynamic method.
            if(i == 5|| i == 9 || i == 13 || i == 17 || i == 21 || i == 25 || i ==  29 || i ==  33 || i ==  37
            || i == 41 || i ==  45 || i ==  49 || i ==  53 || i ==  57 || i ==  61 || i ==  65){
                //adds alignment symbol rows (minus the preceding and return characters) to create a long string of the
                //alignment characters
                alignmentSymbols = alignmentSymbols + line;
            }
        }
        //Identifies the start and end positions (index, not sequence position) 
        var startPos : Int = alignmentSymbols.indexOf('*') - targetOffset;
        var endPos : Int = alignmentSymbols.lastIndexOf('*') - targetOffset;
        
        //Adds the start and stop postions to an array
        startEndPos.insert(0, endPos);
        startEndPos.insert(0, startPos);
        
        
        return startEndPos;
    }
}